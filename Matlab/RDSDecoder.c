#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <stdbool.h>
//#include <math.h>

//can remove this if compiling in linux
#define WIN


/***********************************Constants***********************************/
#define BUFFER_SIZE		1024
#define LINE_SIZE		10
#define BLOCK_SIZE		26
#define GROUP_SIZE		4*BLOCK_SIZE
#define PLAUSIBLE_TOLERANCE	3
#define TEXT_LENGTH		BUFFER_SIZE

#ifndef WIN
	#define SYNDROM_A		0b01 0111 1111
	#define SYNDROM_B		0b00 0000 1110
	#define SYNDROM_C		0b01 0010 1111
	#define SYNDROM_Cs		0b10 1110 1100
	#define SYNDROM_D		0b10 1001 0111

	#define OFFSETWORD_A	0b00 1111 1100
	#define OFFSETWORD_B	0b01 1001 1000
	#define OFFSETWORD_C	0b01 0110 1000
	#define OFFSETWORD_Cs	0b11 0101 0000
	#define OFFSETWORD_D	0b01 1011 0100
#else
	#define SYNDROM_A		0x17F
	#define SYNDROM_B		0x00E
	#define SYNDROM_C		0x12F
	#define SYNDROM_Cs		0x2EC
	#define SYNDROM_D		0x297

	#define OFFSETWORD_A	0x0FC
	#define OFFSETWORD_B	0x198
	#define OFFSETWORD_C	0x168
	#define OFFSETWORD_Cs	0x350
	#define OFFSETWORD_D	0x1B4
#endif

//0b 0001 1000 1101
#define DECODE_INPUT_POLYNOMIAL		0x18D
//0b 0000 1101 1100
#define DECODE_OUTPUT_POLYNOMIAL	0xDC

//representing 0b0000 0000 1101 1100
#define SYNC_POLYNOMIAL	0x05B9

const char *INPUT_FILENAME = 	"decodedaten.txt";
const char *OUTPUT_FILENAME = 	"RDSdecoded.txt";


/***********************************Structs and misc***********************************/
enum EndOfBlock {NO_END, A, B, C, Cs, D};
enum DecodeResultType {PI_CODE, RT_CHAR, IRRELEVANT};

union DecodeActResult
{
	uint16_t piCode;
	char *radioTextChars;
};

struct DecodeResult
{
	enum DecodeResultType type;
	union DecodeActResult actResult;
};

struct EndOfBlockPlausible
{
	enum EndOfBlock endOfBlock;
	//states whether the end of a block is plausible regarding the last detected block
	bool historyPlausible;
	//a negative drift indicates that a block was discovered too early
	//a positive drift indicates that a block was discovered too late
	int16_t drift;
	//states whether the current block synchronization was assumed
	bool assume;
};

//indicates whether the RDS detection is currently in sync
static bool insync = false;
static char radioText[TEXT_LENGTH];
static uint8_t textSegmentAddrCode;

/***********************************Prototypes***********************************/
struct EndOfBlockPlausible CheckEndOfBlock(uint16_t syndrome, uint16_t offset_word);
void Decode(uint32_t block, enum EndOfBlock endOfBlock, struct DecodeResult *result);
void GetChar(uint16_t block, char characters[2]);


void main()
{
	char line[LINE_SIZE];
	uint8_t character;
	uint64_t shift_register_26bit = 0;
	uint16_t shift_register_10bit = 0;
	const uint16_t syncpolynom = SYNC_POLYNOMIAL;
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
			if(feof(fInput))
			{
				printf("End of file has been reached\n");
				return;
			}
			else
			{
				printf("\nError with fgets()\n");
				exit(1);
			}
		}
		//read next bit
		if(line[0]=='0')
			character=0;
		else if(line[0]=='1')
			character=1;

		//Block Synchronization (read ANNEX C in the specification)

		shift_register_26bit <<= 1;
		if(character==1)
			shift_register_26bit |= 0x1; 

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
			message_input_bit = (shift_register_26bit >> (25-i)) & 0x1;
			message_input_bit ^= shift_register_10bit >> 9;
			if(message_input_bit == 0x1)
			{
				shift_register_10bit |= 0x1;
				shift_register_10bit ^= syncpolynom;
			}
			shift_register_10bit <<= 1;
			//bitwise AND with 0b0000 0100 0000 0000
			if(shift_register_10bit & 0x400)
				data_out |= (1<<i);
			//bitwise AND with 0b0000 0011 1111 1110
			shift_register_10bit &= 0x3FE;
		}
		//d)
		for(int i=16; i<26; i++)
		{
			offset_word_input_bit = (shift_register_26bit >> (25-i)) & 0x1;
			if(offset_word_input_bit ^ ((shift_register_10bit >> i) & 0x1))
				data_out |= (1<<i);
		}
		syndrome = data_out >> 16;
		//bitwise AND with 0b0000 0011 1111 1111
		offset_word = shift_register_26bit &= 0x3FF;
		endOfBlock = CheckEndOfBlock(syndrome, offset_word);


		uint32_t currentBlock;
		uint16_t decodedBlock;
		//was a block end detected?
		if(endOfBlock.historyPlausible)
		{
			//if we had to assume a synchronization pulse, then it most likely would have happened
			//endOfBlock.drift cycles ago
			if(endOfBlock.assume)
				currentBlock = (shift_register_26bit >> endOfBlock.drift) & 0x3FFFFFF;
			else
				currentBlock = shift_register_26bit & 0x3FFFFFF;

			//read ANNEX B in the specification for details
			struct DecodeResult result;
			Decode(currentBlock, endOfBlock.endOfBlock, &result);

			if(result.type == PI_CODE)
			{
				fprintf(fOutput, "PI Code: %X\n", result.actResult.piCode);
			}
			else if(result.type == RT_CHAR)
			{
				fprintf(fOutput, "Radio Text: %s\n", radioText);
			}
		}

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
	static bool assume = false;

	endOfBlock.historyPlausible = false;
	endOfBlock.endOfBlock = NO_END;
	endOfBlock.assume = false;

	printf("insync: ");
	printf(insync ? "true" : "false");
	printf("\n");

	if(syndrome == SYNDROM_A)
	{
		//block A detected
		if(offset_word == OFFSETWORD_A)
			endOfBlock.endOfBlock = A;
	}
	else if(syndrome == SYNDROM_B)
	{
		//block B detected
		if(offset_word == OFFSETWORD_B)
			endOfBlock.endOfBlock = B;
	}
	else if(syndrome == SYNDROM_C)
	{
		//block C detected
		if(offset_word == OFFSETWORD_C)
			endOfBlock.endOfBlock = C;
	}
	else if(syndrome == SYNDROM_Cs)
	{
		//block C' detected
		if(offset_word == OFFSETWORD_Cs)
			endOfBlock.endOfBlock = Cs;
	}
	else if(syndrome == SYNDROM_D)
	{
		//block D detected
		if(offset_word == OFFSETWORD_D)
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
		//if we are within a certain tolerance
		if(endOfBlock.drift < PLAUSIBLE_TOLERANCE)
		{
			//if a block end has been detected and deemed valid
			if(endOfBlock.endOfBlock != NO_END && endOfBlock.historyPlausible == true)
			{
				count = 0;
				lastBlock = endOfBlock.endOfBlock;
				assume = false;
			}
			//if no block or the wrong block end (regarding the history) has been detected we keep on going
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
			assume = true;
			endOfBlock.assume = true;

			//assume a clock synchronization happened "drift" cycles ago
			count = endOfBlock.drift;
			switch(lastBlock)
			{
			case A:
				endOfBlock.endOfBlock = B;
				break;
			case B:
				//this of course could also be Cs, but we have to assume something
				endOfBlock.endOfBlock = C;
				break;
			case C:
				endOfBlock.endOfBlock = D;
				break;
			case Cs:
				endOfBlock.endOfBlock = D;
				break;
			case D:
				endOfBlock.endOfBlock = A;
				break;
			}
			lastBlock = endOfBlock.endOfBlock;
			endOfBlock.historyPlausible = true;
		}
	}
	//if the block detection is not insync then we look for the next "A" block
	else
	{
		if(endOfBlock.endOfBlock == A)
		{
			insync = true;
			lastBlock = endOfBlock.endOfBlock;
			count = 0;
			//the drif is 0, since there is no predecessor
			endOfBlock.drift = 0;

			//since we are not in sync there is no relevant history
			endOfBlock.historyPlausible = true;
		}
		else
			count++;
	}

	return endOfBlock;
}

/**********************************************************************
*---------------------------------------------------------------------*
***********************************************************************/

//ANNEX B.2.2 (circuit implementation)
/**
 * @brief Performs error correction and 
 */
void Decode(uint32_t block, enum EndOfBlock endOfBlock, struct DecodeResult *result)
{
	uint16_t offsetWord;
	uint16_t output = 0x0;
	//a)
	uint16_t syndromReg_10bit = 0x0;
	uint16_t bufferReg_16bit = 0x0;
	uint16_t checkWord = 0x0;
	uint8_t norOutput = 0x0;
	uint8_t andOutput = 0x0;

	static uint8_t groupTypeCode;
	static char characters[2];		//only static so that it can be passed on outside the function


	result->type = IRRELEVANT;
	result->actResult.radioTextChars = NULL;

	switch(endOfBlock)
	{
	case A:
		offsetWord = OFFSETWORD_A;
		break;
	case B:
		offsetWord = OFFSETWORD_B;
		break;
	case C:
		offsetWord = OFFSETWORD_C;
		break;
	case Cs:
		offsetWord = OFFSETWORD_Cs;
		break;
	case D:
		offsetWord = OFFSETWORD_D;
		break;
	case NO_END:
		printf("Decode was called for an invalid block\nCode line: %d\n", __LINE__);
		exit(EXIT_FAILURE);
		break;
	default:
		printf("Error, control should never enter this section\nCode line: %d\n", __LINE__);
		exit(EXIT_FAILURE);
		break;
	}

//	//b) f.
//	//the 16 information bits are fed into the syndrome and buffer register
//	uint8_t inputBit = 0x0;
//	uint8_t syndromOutBit= 0x0;
//
//	bufferReg_16bit = (block >> 10) & 0xFFFF;
//	checkWord = block & 0x3FF;
//	
//	for(int z = 0; z < 26; z++)
//	{
//		//select next input bit
//		inputBit = (block >> (25-z)) & 0x1;
//		//c)
//		//The 10 checkbits are fed into the the syndrome register and the
//		//appropriate offset word is subtracted (via the mod 2 adder)
//		if(z >= 16)
//			inputBit ^= (offsetWord >> (25-z)) & 0x1;
//
//		//mask out the current last bit of the syndrom register
//		syndromOutBit = (syndromReg_10bit >> 9) & 0x1;
//
//		//perform the appropriate polynomial divisions
//		if(inputBit)
//		{
//			syndromReg_10bit ^= DECODE_INPUT_POLYNOMIAL;
//		}
//		if(syndromOutBit)
//		{
//			syndromReg_10bit ^= DECODE_OUTPUT_POLYNOMIAL;
//		}
//
//		//shift the syndrom register
//		syndromReg_10bit <<= 1;
//
//		//calculate the next input bit for the syndrom register
//		if(inputBit ^ syndromOutBit)
//			syndromReg_10bit |= 0x1;
//	}
//
//	//d)
//	//clock the 16 information bits in the buffer register to the output
//	//and rotate the content of the syndrome register
//	//note that there is no input
//	for(int z = 0; z < 16; z++)
//	{
//		//mask the current last bit of the syndrom register
//		syndromOutBit = (syndromReg_10bit >> 9) & 0x1;
//
//		//perform the appropriate polynomial divisions
//		if(syndromOutBit)
//		{
//			syndromReg_10bit ^= DECODE_OUTPUT_POLYNOMIAL;
//		}
//
//		//NOR gate
//		norOutput = syndromReg_10bit & 0x1;
//		norOutput |= (syndromReg_10bit >> 1) & 0x1;
//		norOutput |= (syndromReg_10bit >> 2) & 0x1;
//		norOutput |= (syndromReg_10bit >> 3) & 0x1;
//		norOutput |= (syndromReg_10bit >> 4) & 0x1;
//		norOutput = ~norOutput;
//
//		//AND gate
//		andOutput = norOutput & syndromOutBit;
//
//		//shift the syndrom register
//		syndromReg_10bit <<= 1;
//
//		output <<= 1;
//		//do a mod 2 addition with the current buffer register bit
//		//and the output of the logical AND unit
//		if(andOutput ^ ((bufferReg_16bit >> (15-z)) & 0x1))
//			output |= 0x1;
//	}
//
//	//f)
//	//standard not clear!
//	//TODO

output = (block >> 16) & 0xFFFF;

/********************Start of actual decoding process********************/

	if(endOfBlock == A)
	{
		result->type = PI_CODE;
		result->actResult.piCode = output;
	}

	if(endOfBlock == B)
	{
		//the upper 5 bits contain the group type code
		groupTypeCode = (output >> 11) & 0x1F;
		
		//0x4 corresponds with group type 2A
		//0x5 corresponds with group type 2B
		if(groupTypeCode == 0x4 || groupTypeCode == 0x5)
			textSegmentAddrCode = output & 0xF;

	}

	//if the current block contains RT (radio text)
	if( ((groupTypeCode == 0x4) && (endOfBlock == C || endOfBlock == D)) ||
		((groupTypeCode == 0x5) && (endOfBlock == D)))
	{
		GetChar(output, characters);
		result->type = RT_CHAR;
		result->actResult.radioTextChars = characters;
		
		if(groupTypeCode == 0x4 && endOfBlock == C)
		{
			radioText[textSegmentAddrCode*4] = characters[0];
			radioText[textSegmentAddrCode*4 + 1] = characters[1];
			radioText[textSegmentAddrCode*4 + 2] = '\0';
		}
		else if(groupTypeCode == 0x4 && endOfBlock == D)
		{
			radioText[textSegmentAddrCode*4 + 2] = characters[0];
			radioText[textSegmentAddrCode*4 + 3] = characters[1];
			radioText[textSegmentAddrCode*4 + 4] = '\0';
		}
		else if(groupTypeCode == 0x5 && endOfBlock == D)
		{
			radioText[textSegmentAddrCode*2] = characters[0];
			radioText[textSegmentAddrCode*2 + 1] = characters[1];
			radioText[textSegmentAddrCode*2 + 2] = '\0';
		}
	}

}


/**
 * @brief Obtains a character from the given block
 * @detail Should be called only for blocks, which actually contain the RT (radio text)
 */
void GetChar(uint16_t block, char characters[2])
{
	characters[0] = (char)((block >> 8) & 0xFF);
	characters[1] = (char)(block & 0xFF);
	return;
}

//PrintError(const char *message, unsigned int lineNumber)
//{
//	
//	printf(message
//}
