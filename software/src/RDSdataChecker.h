#include <stdio.h>
#include <stdint.h>

extern char name[2][PROGRAM_NAME_LENGTH + 1];
extern char text[RADIO_TEXT_LENGTH + 1];

#define RADIO_TEXT_LENGTH 64
#define PROGRAM_NAME_LENGTH 8
void DecodeData(uint16_t *blockData, uint8_t *blockOK);
