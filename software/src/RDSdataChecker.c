#include "RDSdataChecker.h"

uint8_t updateTextFlag = 0;
int dataOKCount = 0;

char name[2][PROGRAM_NAME_LENGTH + 1];
char text[RADIO_TEXT_LENGTH + 1];
static uint8_t nameChgd[2][2];
uint8_t actName;
static uint16_t textChgd;
static char pi_code[5];

static uint8_t dirtyName = 1;
static uint8_t dirtyText = 1;

/**
* @brief decodes the found 4 blocks. The method tries to find Name, Text and PI Code of the radio station
* @detail	blockData 
*        	the method checks if block data two is OK. If so something of the data
*		can be decoded. The first block allways contains the PI Code so this 
*         	block can be ignored if it is faulty. The third and the fourth block
*		are also describing data like the letters of the text so one of them
*		can also be ignored if faulty.
*
*		radio name
*        	some radiostations are sending two different 
*          	lines for their name. To present the data fast
*          	2 registers are used to represent the lines and  
*          	quickly change between them if the first letter  
*          	of the second one is found. A line is taken as  
*          	found if the line's letters are received twice  
*          	in a row. While the rows are not "confirmed"  
*          	the lines can be wrong until the letters are received twice.
*          	EXAMPLE: ("HITRADIO" "  OE 3  ")
*			first Line:  "HIOE 3  "
*         	second Line: "  OE 3  "
*			third Line : "  OE 3  "  line confirmed 
*             	                                 (line1 is not changing any more)
*			fourth Line: "HITRADIO"
*          	fifth Line:  "HITRADIO"	 line confirmed 
*              	                         (line2 is also confirmed and keeps HITRADIO)
*
*		radio Text
*		the radio text is saved into a register if the resetText flag occours or a
*  	letter is not the same like before the whole text line gets reset.
* @param blockData	is the data of the found blocks. If a block is faulty this section of the array stays zero
* @param blockOK		indicates whether a block is OK (1) or faulty (0)
*/
void DecodeData(uint16_t *blockData, uint8_t *blockOK)
{
	uint8_t groupTypeCode = 0;
	uint8_t version = 0;
	uint8_t textSegment = 0;
  uint8_t otherName = (actName + 1) & 0x1; //Modulo 2
	//uint8_t trafficInfo = 0;
	//uint8_t programType = 0;


	if(blockOK[1] != 1)
		return;

	if(blockOK[0] == 1)
	{
		//If the first block is ok the PI Code can be decoded (converted to ASCII)
		//note that the codes are binary coded hex numbers!
		pi_code[0] = (blockData[0]>>12) + 48;
		if(pi_code[0] > 57)
			pi_code[0] += 7;
		
		pi_code[1] = ((blockData[0]>>8)&0xF) + 48;
		if(pi_code[1] > 57)
			pi_code[1] += 7;

		pi_code[2] = ((blockData[0]>>4)&0xF) + 48;
		if(pi_code[2] > 57)
			pi_code[2] += 7;

		pi_code[3] = ((blockData[0])&0xF) + 48;
		if(pi_code[3] > 57)
			pi_code[3] += 7;
	}

	groupTypeCode = (blockData[1]>>12);
	version = (blockData[1]>>11)&0x01;
	//trafficInfo = (block_data[1]>>10)&0x01;
	//programType = (block_data[1]>>5)&0x1F;


	//Group 0 A or B (does not matter in this case), since we only need the name of the program
	if(groupTypeCode == 0)
	{
		//Basic tuning and Switching information
		textSegment = (blockData[1] & 0x03);
		if(blockOK[3] == 1)
		{		
			//The name is changed if distinct letters are received. Is the name already confirmed (letter is received twice in a row) than the register is changed. If not the letter gets overwritten.
			if(((nameChgd[actName][1])&(1<<(textSegment))) > 0 && (name[actName][(textSegment<<1)] != (blockData[3]>>8) || name[actName][(textSegment<<1)+1] != (blockData[3]&0xFF)))
			{
				if(((nameChgd[otherName][1])&(1<<(textSegment))) == 0 || (name[otherName][(textSegment<<1)] == (blockData[3]>>8) && name[otherName][(textSegment<<1)+1] == (blockData[3]&0xFF)))
				 {
					actName = (actName + 1) & 0x1;	//modulo 2
				 }
			}
		
			//if the last letter is the same like the actual the letter is marked as confirmed
			if(((nameChgd[actName][0])&(1<<(textSegment))) > 0 && (name[actName][(textSegment<<1)] == (blockData[3]>>8) || name[actName][(textSegment<<1)+1] == (blockData[3]&0xFF)))
			{
				nameChgd[actName][1] |= (1<<(textSegment));
			}
		  	else
		  	{
				//if the letter occurred the first time it is marked as found
				nameChgd[actName][0] |= (1<<(textSegment));
		  	}
			name[actName][(textSegment<<1)] = (blockData[3]>>8);
			name[actName][(textSegment<<1)+1] = (blockData[3]&0xFF);

			dirtyName=1;
		}
	}
	//Group type 2A and 2B
	else if(groupTypeCode == 2)
	{
		//Decoding the radio text
		if(updateTextFlag != ((blockData[1]>>4)&0x01))
		{
			updateTextFlag = ((blockData[1]>>4)&0x01);
			memset(text, ' ', sizeof(text)-1);
		}
		textSegment = (blockData[1] & 0x0F);

		if(version == 0) //Version A
		{
			if(blockOK[2] == 1)
			{
				//Resetting the data buffer if a letter is different from the old one or a reset occurred
				if((textChgd&(1<<(textSegment<<1))) > 0 && (text[(textSegment<<2)] != (blockData[2]>>8) || text[(textSegment<<2)+1] != (blockData[2]&0xFF)))
				{
					memset(text, ' ', sizeof(text)-1);
					textChgd=0;
				}

				textChgd |= (1<<(textSegment<<1));
				text[(textSegment<<2)] = (blockData[2]>>8);
				text[(textSegment<<2)+1] = (blockData[2]&0xFF);
				dirtyText=1;
			}
			if(blockOK[3] == 1)
			{
				//Resetting the data buffer if a letter is different to the old one or a reset occurred
				if((textChgd&(1<<((textSegment<<1)+1))) > 0 && (text[(textSegment<<2) + 2] != (blockData[3]>>8) || text[(textSegment<<2) + 3] != (blockData[3]&0xFF)))
				{
					memset(text, ' ', sizeof(text)-1);
					textChgd=0;
				}
				textChgd |= (1<<((textSegment<<1)+1));
				text[(textSegment<<2)+2] = (blockData[3]>>8);
				text[(textSegment<<2)+3] = (blockData[3]&0xFF);
				dirtyText=1;
			}
		}
		else //Version B
		{

			if(blockOK[3] == 1)
			{
				//Resetting the data buffer if a letter is different to the old one or a reset occurred
				if((textChgd&(1<<(textSegment))) > 0 && (text[(textSegment<<1)] != (blockData[3]>>8) || text[(textSegment<<1)+1] != (blockData[3]&0xFF)))
				{
					memset(text, ' ', sizeof(text)-1);
					textChgd=0;
				}

				textChgd |= (1<<textSegment);
				text[textSegment<<1] = (blockData[3]>>8);
				text[(textSegment<<1)+1] = (blockData[3]&0xFF);
				dirtyText=1;
			}
		}
	}
}
