#include <stdio.h>
#include <stdint.h>

void main(){
  char zeile[14];
  uint8_t zeichen;
  while (fgets(zeile, sizeof(zeile), stdin)) {
	//Nächstes Zeichen wird eingelesen
	if(zeile[0]=='0'){
	    zeichen=0;
	}else if(zeile[0]=='1'){
		zeichen=1;
	}
	
	//Synchrofinden
	
	
	//CRC
	
	//Decoden
	
  }
}