#include <stdio.h>
#include <stdint.h>
#include <string.h>

#define BUFFER_SIZE		1024
#define LINE_SIZE		10

const char *INPUT_FILENAME = 	"decodedaten.txt";
const char *OUTPUT_FILENAME = 	"RDSdecoded.txt";

void main(){
	char line[10];
	uint8_t character;
	uint32_t shift_register_26bit = 0;
	uint16_t shift_register_10bit = 0;
	const uint16_t crcpolynom=0b0000 0101 1011 1001;
	//A,B,C,CStrich,D
	const uint16_t offsetword[5]={0b00 1111 1100, 0b01 1001 1000,
		0b01 0110 1000, 0b11 0101 0000,
		0b01 1011 0100};
	const uint16_t syndrome[5]={0b11 1101 1000, 0b11 1101 0100,
		0b10 0101 1100, 0b11 1100 1100,
		0b10 0101 1000};

	char path[BUFFER_SIZE];
	FILE fInput = NULL, fOutput = NULL;

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
		//b)
		for(int i=0; i<16; i++){
			//shift data xored with the 10th bit in the 10bit shift register
			message_input_bit = (shift_register_26bit >> i) & 0x1;
			message_input_bit ^= shift_register_10bit >> 9;
			if(message_input_bit == 1)
				shift_register_10bit |= 0x1;
			shift_register_10bit ^= crcpolynom;
			shift_register_10bit <<= 1;
			if(shift_register_10bit & 0b0000 0100 0000 0000)
				data_out |= (1<<i);
			shift_register_10bit &= 0b0000 0011 1111 1110;	//alternatively 0b0000 0011 1111 1111
		}
		//d)
		for(int i=16; i<26; i++)
		{
			offset_word_input_bit = (shift_register_26bit >> i) & 0x1;
			if(offset_word_input_bit ^ ((shift_register_10bit >> (10-(i-16))) & 0x1))
				data_out |= (1<<i);
		}
		for(int i=0; i<5; i++){
			if(
					}

					//Check welches Checkwort==welcher Block das war


					//CRC

					//Decoden

					}
					}
