#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>


/***********************************Constants***********************************/
#define BUFFER_SIZE		1024
#define LINE_SIZE		10
#define BLOCK_SIZE		26
#define GROUP_SIZE		4*BLOCK_SIZE
#define PLAUSIBLE_TOLERANCE	3

const char *INPUT_FILENAME = 	"decodedaten.txt";
const char *OUTPUT_FILENAME = 	"RDSdecoded.txt";


/***********************************Prototypes***********************************/
struct EndOfBlockPlausible CheckEndOfBlock(uint16_t syndrome, uint16_t offset_word);


/***********************************Structs and misc***********************************/
enum EndOfBlock {NO_END, A, B, C, Cs, D};
enum Plausible {NO, YES};

struct EndOfBlockPlausible
{
	enum EndOfBlock endOfBlock;
	enum Plausible plausible;
};

void main()
{
	char line[10];
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
			shift_register_10bit &= 0b0000 0011 1111 1110;	//alternatively 0b0000 0011 1111 1111
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
		//TODO
		//Decoden
		//TODO

	}
}


/**********************************************************************
*---------------------------------------------------------------------*
***********************************************************************/
struct EndOfBlockPlausible CheckEndOfBlock(uint16_t syndrome, uint16_t offset_word)
{
	static enum EndOfBlock lastBlock = NO_END;
	static uint8_t count = 0;	//mod 26 for the bits inside each block
	struct EndOfBlockPlausible endOfBlock;

	endOfBlock.plausible = NO;
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

	//check whether this outcome is plausible
	switch(endOfBlock.endOfBlock)
	{
		case A:
			if(lastBlock == D)
				if(count > BLOCK_SIZE - PLAUSIBLE_TOLERANCE)
					endOfBlock.plausible = YES;
			break;

		case B:
			if(lastBlock == A)
				if(count > BLOCK_SIZE - PLAUSIBLE_TOLERANCE)
					endOfBlock.plausible = YES;
			break;

		case C:
			if(lastBlock == B)
				if(count > BLOCK_SIZE - PLAUSIBLE_TOLERANCE)
					endOfBlock.plausible = YES;
			break;

		case Cs:
			if(lastBlock == B)
				if(count > BLOCK_SIZE - PLAUSIBLE_TOLERANCE)
					endOfBlock.plausible = YES;
			break;

		case D:
			if(lastBlock == C || lastBlock == Cs)
				if(count > BLOCK_SIZE - PLAUSIBLE_TOLERANCE)
					endOfBlock.plausible = YES;
			break;

		case NO_END:
			if(count < BLOCK_SIZE + PLAUSIBLE_TOLERANCE)
				endOfBlock.plausible = YES;
			break;

		default:
			printf("Error on line %u\nControl flow should never enter this section", __LINE__);
			exit(1);
	}

	lastBlock = endOfBlock.endOfBlock;
	if(endOfBlock == NO_END)
		count++;
	else
		count = 0;

	return endOfBlock;
}
