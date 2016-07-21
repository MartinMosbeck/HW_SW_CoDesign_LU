#include "RDSdecoder.h"
#include <math.h>

#define NUMBER_OF_BLOCKS	4
#define BLOCK_LENGTH 		26

#define MAX_DEVIATION 		1

//represents the currently stored RDS data bits
uint32_t input = 0;
uint16_t H[26] = { 512,256,128,64,32,16,8,4,2,1,732,366,183,647,927,787,853,886,443,513,988,494,247,679,911,795 };

uint16_t compare[4] = { 0x3D8, 0x3D4, 0x25C, 0x258};
uint16_t block_data[4] = {0,0,0,0};
uint8_t block_ok[4] = {0,0,0,0};
uint8_t packetsLost = 0;
uint8_t isSync = 0;
uint16_t syncCount = 0;
uint8_t expectedBlock = 0;
uint8_t found25 = 0;
int decodeCount = 0;

/**
* @brief	returns the number of decoded packets
* @return 	the number of decoded packets
*/
int get_decoded_counter(void)
{
	return decodeCount;
}

/**
* @brief checks the crc sum of the given block and returns the blocknumber
* @param expectedBlock	currently not used. Is thought to be used for 
*                     	checking the CRC code with error correcting.
* @param foundData    	the input data to check
* @return	the found block or zero if nothing is found
*/
uint8_t checkBlock(uint8_t expectedBlock, uint16_t *data);

/**
 * @brief Successively calls addBit for a byte block
 */
void addByte(uint8_t byte)
{
	int z;
	for(z = 0; z < 8; z++)
	{
		addBit((uint8_t) ((byte>>(7-z)) & 0x1));
	}
}

/**
* @brief 	Adds a bit to a 26bit input variable and checks 
*        	it for new data blocks
* @detail 	After 2 blocks are found the input stream is marked 
*         	as sync. If it is marked as synce only every n*26 
*         	bits are checked for new blocks. Additionally every 
*          	n*26-1 and every n*27+1 block is also checked to 
*          	avoid a desync if bits are lost. 
* @param bit	the input bit to add to the data stream
* @return 	returns the number of the found block
*/
uint8_t addBit(uint8_t bit)
{
	int block = 0;
	uint16_t data = 0;
	//add the bit to the input
	input = (input<<1);
	if(bit==1)
		input |= 0x01;


	syncCount++;
	if(isSync == 1)
	{
		uint8_t streamOffset = syncCount;	
		//Calculating the current stream counter modulo 26 
		//avoiding the modulo operation
		while(streamOffset >= 26)
			streamOffset -= 26;
		
		//calculating the expected blocknumber 
		//avoiding the modulo operation
		if(syncCount > 13 && syncCount < 39)
		{
			expectedBlock = 1;
		}
		else if(syncCount < 65)
		{
			expectedBlock = 2;		
		}
		else if(syncCount < 91)
		{
			expectedBlock = 3;		
		}
		else 
		{
			expectedBlock = 4;
		}


		if(streamOffset == 25)
		{
		//Checks the synced stream for data if the offset to the 
		//last stream modulo 26 is 25 to avoid getting desynced 
		//if a bit was lost
			block = checkBlock(0,&data);

			if(block == expectedBlock)
			{
				block_data[expectedBlock-1]=(data);
				found25 = 1;
			}
		}
		if(streamOffset == 0)
		{
		//Checks the synced stream for data. If nothing is found
		//and a block is found one count before the last data is
		//used and de syncCount is incremented to save that one
		//bit was lost.
			block = checkBlock(expectedBlock,&data);

			if(block == expectedBlock)
			{
				block_ok[expectedBlock-1]=1;
				block_data[expectedBlock-1]=(data);
			}
			else if(found25 == 1)
			{
				block_ok[expectedBlock-1]=1;
				syncCount++;
			}
			else
			{
				block_ok[expectedBlock-1]=0;
			}
			found25 = 0;
		}
		if(streamOffset == 1)
		{
		//if nothing was found the last two counts and the expected block is 
		//found one count after the right data position the new data is set
		//and the dataCounter is decreased by one to correct the additional
		//bit
			block = checkBlock(0,&data);

			if(block == expectedBlock && block_ok[expectedBlock-1]==0)
			{
				block_ok[expectedBlock-1]=1;
				block_data[expectedBlock-1]=(data);
				syncCount--;
			}
		}

		if(syncCount > 104 + MAX_DEVIATION || block_ok[3] == 1)
		{
		//if the syncCount is 104 means, that 4 blocks are found. 
			if(block_ok[0] == 0 && block_ok[1] == 0 && block_ok[2] == 0 && block_ok[3] == 0)
			{
				packetsLost++;
			}
			else if(block_ok[1] == 1)
			{
				decodeCount++;
				packetsLost=0;
				DecodeData(block_data, block_ok);
			}

			if(packetsLost > 1)
			{
				isSync = 0;
				expectedBlock = 0;
			}

			syncCount -= 104;
			block_ok[0] = 0;
		 	block_ok[1] = 0;
		 	block_ok[2] = 0;
		 	block_ok[3] = 0;
		}
	}
	else	//IF not SYNC
	{
		block = checkBlock(expectedBlock,&data);
		if(block != 0)
		{
			if(expectedBlock == 0)
			{
				//first Packet found
				syncCount = 0;
				expectedBlock = ((block) & 0x3) + 1;	//(Modulo 4) + 1
				if(block != 4)
				{
			 		block_ok[block - 1] = 1;
					block_data[block - 1] = (data);
				}
			}
			else if(expectedBlock == block)
			{
				if(syncCount == 26)
				{
					isSync = 1;
					//calculating the actual count for synchronous operation in the next cycle	
					syncCount = 26 * (block);
					expectedBlock = ((block) & 0x3) + 1;    //(Modulo 4) + 1
					packetsLost = 0;

			 		block_ok[block - 1] = 1;
					block_data[block - 1] = (data);
				}

			}

			//Set found packets....
		}
		else if(syncCount > 26)	//Block equal zero
		{
			syncCount = 0;
			expectedBlock = 0;
		 	block_ok[0] = 0;
		 	block_ok[1] = 0;
		 	block_ok[2] = 0;
		 	block_ok[3] = 0;
		}
	}




	return block;
}

/**
* @brief checks the crc sum of the given block and returns the blocknumber
* @param expectedBlock	currently not used. Is thought to be used for 
*                     	checking the CRC code with error correcting.
* @param foundData    	the input data to check
* @return	the found block or zero if nothing is found
*/
uint8_t checkBlock(uint8_t expectedBlock, uint16_t* foundData)
{
	uint8_t first = 1;
	uint32_t crc = 0;
	int i = 0;
	uint16_t data = 0;
	data = input>>10;

	for(i = 0; i < BLOCK_LENGTH; i++)
	{
		if(((input>>(BLOCK_LENGTH-1-i))&0x01) == 1)
		{
			if(first == 1)
				crc = H[i];
			else
				crc = (crc ^ H[i]);

			first = 0;
		}
	}

	i = 0;
	for(i = 0; i < NUMBER_OF_BLOCKS; i++)
	{
		if(compare[i] == crc)
		{
			*foundData = data;
			return i+1;
		}
	}

	return 0;
}
