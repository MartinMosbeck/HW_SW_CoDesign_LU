#ifndef RDS_DECODER_
#define RDS_DECODER_

#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "RDSdataChecker.h"

/**
 * @brief Successively calls addBit for a byte block
 */
void addByte(uint8_t byte);

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
uint8_t addBit(uint8_t bit);
/**
* @brief 	returns the name of the radio station found
* @return 	the name of the radio station found. 
*/
char* getName();
/**
* @brief 	returns the text of the radio station
* @return 	the text of the radio stations
*/
char* getText();
/**
* @brief 	returns the PI Code of the radio station
* @return 	the PI Code of the radio station
*/
char* getPICode();
/**
* @brief 	returns true if name or text is changed
* @return 	true if name or text is changed
*/
uint8_t newDataAvailable();

/**
* @brief	returns the number of decoded packets
* @return 	the number of decoded packets
*/
int get_decoded_counter(void);

#endif 
