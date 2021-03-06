#include <stdio.h>
#include <stdint.h>
#include <string.h>

#define RADIO_TEXT_LENGTH 64
#define PROGRAM_NAME_LENGTH 8

extern uint8_t actName;

extern char name[2][PROGRAM_NAME_LENGTH + 1];
extern char text[RADIO_TEXT_LENGTH + 1];

void DecodeData(uint16_t *blockData, uint8_t *blockOK);
