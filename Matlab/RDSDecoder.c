#include <stdio.h>
#include <stdint.h>

void main(){
  char zeile[14];
  uint8_t zeichen;
  uint32_t shift_register_26bit;
  uint16_t shift_register_10bit;
  const uint16_t crcpolynom=0b0000 0001 1011 1001;
  //A,B,C,CStrich,D
  const uint16_t offsetword[5]={0b00 1111 1100, 0b01 1001 1000,
								0b01 0110 1000, 0b11 0101 0000,
								0b01 1011 0100};
  const uint16_t syndrome[5]={0b11 1101 1000, 0b11 1101 0100,
							  0b10 0101 1100, 0b11 1100 1100,
							  0b10 0101 1000};
  while (fgets(zeile, sizeof(zeile), stdin)) {
	//Nächstes Zeichen wird eingelesen
	if(zeile[0]=='0'){
	    zeichen=0;
	}else if(zeile[0]=='1'){
		zeichen=1;
	}
	
	//Synchrofinden
	shift_register_26bit >>= shift_register_26bit;
	if(zeichen==1){
		shift_register_26bit |=  (1<<25); 
	}
	
	//a)
	shift_register_10bit=0;
	uint8_t messageInputBit;
	//b)
	for(int i=0; i<16; i++){
		messageInputBit |= (shift_register_26bit >> (25-i) ) & 0x1;
		messageInputBit ^= shift_register_10bit >> 9;
		shift_register_10bit ^= crcpolynom;
		shift_register_10bit <<= 1;
		shift_register_10bit &= 0b0000 0011 1111 1111;
	}
	//d)
	for(int i=0; i<10; i++){
		
	}
	for(int i=0; i<5; i++){
		if(
	}
	
	//Check welches Checkwort==welcher Block das war
	
	
	//CRC
	
	//Decoden
	
  }
}