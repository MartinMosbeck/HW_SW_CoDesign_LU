#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <stdbool.h>
//#include <math.h>


/***********************************Constants***********************************/
#define BUFFER_SIZE		1024
#define LINE_SIZE		10
#define BLOCK_SIZE		26
#define GROUP_SIZE		4*BLOCK_SIZE
#define PLAUSIBLE_TOLERANCE	8

const char *INPUT_FILENAME = 	"decodedaten.txt";
const char *OUTPUT_FILENAME = 	"RDSdecoded.txt";


/***********************************Prototypes***********************************/
struct EndOfBlockPlausible CheckEndOfBlock(uint16_t syndrome, uint16_t offset_word);


/***********************************Structs and misc***********************************/
enum EndOfBlock {NO_END, A, B, C, Cs, D};

struct EndOfBlockPlausible
{
	enum EndOfBlock endOfBlock;
	//states whether the end of a block is plausible regarding the last detected block
	bool historyPlausible;
	//a negative drift indicates that a block was discovered too early
	//a positive drift indicates that a block was discovered too late
	int16_t drift;
};

void main()
{
	char line[LINE_SIZE];
	uint8_t character;
	uint32_t shift_register_26bit = 0;
	uint16_t shift_register_10bit = 0;
	const uint16_t crcpolynom = 0b0000 0101 1011 1001;
	//A,B,C,CStrich,D
	const uint16_t offsetword[5]={0b00 1111 1100, 0b01 1001 1000,
		0b01 0110 1000, 0b11 0101 0000,
		0b01 1011 0100};
	const uint16_t syndrome[5]={0b11 1101 1000, 0b11 1101 0100,
		0b10 0101 1100, 0b11 1100 1100,
		0b10 0101 1000};
	struct EndOfBlockPlausible endOfBlock;

	char path[BUFFER_SIZE];
	FILE *fInput = NULL, *fOutput = NULL;


	/********************opening the input and output files********************/
	strcat(strcpy(path, "./"), INPUT_FILENAME);
	if((fInput = fopen(path, "r")) == NULL)
	{
		printf("\nError with fopen\nPath: %s\n", path);
		exit(1);
	}
	strcat(strcpy(path, "./"), OUTPUT_FILENAME);
	if((fOutput = fopen(path, "w")) == NULL)
	{
		printf("\nError with fopen\nPath: %s\n", path);
		exit(1);
	}

	fseek(fInput, 0L, SEEK_SET);

	while(!feof(fInput))
	{
		if(fgets(line, sizeof(line), fInput) == NULL)
		{
			printf("\nError with fgets()\n");
			exit(1);
		}
		//read next bit
		if(line[0]=='0')
			character=0;
		else if(line[0]=='1')
			character=1;

		//Synchronization

		shift_register_26bit = shift_register_26bit >> 1;
		if(character==1)
			shift_register_26bit |=  (1<<25); 

		//a)
		uint32_t data_out = 0;
		shift_register_10bit = 0;
		uint8_t message_input_bit = 0;
		uint8_t offset_word_input_bit = 0;
		uint16_t syndrome = 0;
		uint16_t offset_word = 0;
		//b)
		for(int i=0; i<16; i++)
		{
			//shift data xored with the 10th bit in the 10bit shift register
			message_input_bit = (shift_register_26bit >> i) & 0x1;
			message_input_bit ^= shift_register_10bit >> 9;
			if(message_input_bit == 1)
			{
				shift_register_10bit |= 0x1;
				shift_register_10bit ^= crcpolynom;
			}
			shift_register_10bit <<= 1;
			if(shift_register_10bit & 0b0000 0100 0000 0000)
				data_out |= (1<<i);
			shift_register_10bit &= 0b0000 0011 1111 1110;	//alternatively 0b0000 0011 1111 1111 does the same
		}
		//d)
		for(int i=16; i<26; i++)
		{
			offset_word_input_bit = (shift_register_26bit >> i) & 0x1;
			if(offset_word_input_bit ^ ((shift_register_10bit >> i) & 0x1))
				data_out |= (1<<i);
		}
		syndrome = data_out >> 16;
		offset_word = shift_register_26bit >> 16;
		endOfBlock = CheckEndOfBlock(syndrome, offset_word);
		//CRC
		//TODO Continue reading on page 68 in the RDS specification
		//Decoden
		//TODO

	}
}


/**********************************************************************
*---------------------------------------------------------------------*
***********************************************************************/

struct EndOfBlockPlausible CheckEndOfBlock(uint16_t syndrome, uint16_t offset_word)
{
	static enum EndOfBlock lastBlock = D;	//since initially we want to start at block A
	static int16_t count = 0;	//after a block has been detected
	struct EndOfBlockPlausible endOfBlock;
	static bool insync = false;

	endOfBlock.historyPlausible = false;
	endOfBlock.endOfBlock = NO_END;

	if(syndrome == 0b01 0111 1111)
	{
		//block A detected
		if(offset_word == 0b00 1111 1100)
			endOfBlock.endOfBlock = A;
	}
	else if(syndrome == 0b00 0000 1110)
	{
		//block B detected
		if(offset_word == 0b01 1001 1000)
			endOfBlock.endOfBlock = B;
	}
	else if(syndrome == 0b01 0010 1111)
	{
		//block C detected
		if(offset_word == 0b01 0110 1000)
			endOfBlock.endOfBlock = C;
	}
	else if(syndrome == 0b10 1110 1100)
	{
		//block C' detected
		if(offset_word == 0b11 0101 0000)
			endOfBlock.endOfBlock = Cs;
	}
	else if(syndrome == 0b10 1001 0111)
	{
		//block D detected
		if(offset_word == 0b01 1011 0100)
			endOfBlock.endOfBlock = D;
	}

	//check whether this outcome is plausible regarding the last detected block
	endOfBlock.drift = count - BLOCK_SIZE;
	switch(endOfBlock.endOfBlock)
	{
		case A:
			if(lastBlock == D)
				endOfBlock.historyPlausible = true;
			break;

		case B:
			if(lastBlock == A)
				endOfBlock.historyPlausible = true;
			break;

		case C:
			if(lastBlock == B)
				endOfBlock.historyPlausible = true;
			break;

		case Cs:
			if(lastBlock == B)
				endOfBlock.historyPlausible = true;
			break;

		case D:
			if(lastBlock == C || lastBlock == Cs)
				endOfBlock.historyPlausible = true;
			break;

		case NO_END:
				//do nothing
			break;

		default:
			printf("Error on line %u\nControl flow should never enter this section", __LINE__);
			exit(1);
	}

	//if the block detection is insync
	if(insync)
	{
		//if we are within a certain tolerance time window
		if(abs(endOfBlock.drift) < PLAUSIBLE_TOLERANCE)
		{
			//if a block end has been detected and deemed valid
			if(endOfBlock.endOfBlock != NO_END && endOfBlock.historyPlausible == true)
			{
				count = 0;
				lastBlock = endOfBlock.endOfBlock;
				assume = false;
			}
			//if the wrong block end has been detected we keep on going
			else
			{
				count++;
			}
		}
		//if the block end detection is outside a certain tolerance window and no valid block as been detected
		else
		{
			//if we already "assumed" last time then we are probably now out of sync but still try to assume
			//that a clock synchronization has happened
			if(assume)
				insync = false;
			//assume a clock synchronization happened "drift" cycles ago
			assume = true;
			count = endOfBlock.drift;
			switch(lastBlock)
			{
			case A:
				lastBlock = B;
				break;
			case B:
				lastBlock = C;
				break;
			case C:
				lastBlock = D;
				break;
			case Cs:
				lastBlock = D;
				break;
			case D:
				lastBlock = A;
				break;
			}
		}
	}
	//if the block detection is not insync then we simply look for any block end
	else
	{
		if(endOfBlock.endOfBlock != NO_END)
		{
			insync = true;
			lastBlock = endOfBlock.endOfBlock;
			count = 0;
			//the drif is 0, since there is no predecessor
			endOfBlock.drift = 0;
		}
	}


	return endOfBlock;
}
