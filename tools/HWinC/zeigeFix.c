#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <math.h>//Für pow()

//dafür ist -lm beim compilieren nötig
//==gcc Radiodecoder.c -lm -g -o Radiodecoder
#define ANZ_NACHKOMMA 16//Gesamt 32 bit,d.h. der Rest ist Vorkomma
int main(int argc, char *argv[]){
	uint32_t x=strtol(argv[1],NULL,0);
	float zahl=0;
	int i;
	if(x&0x80000000){//Negative Zahl
		zahl-=pow(2,31-ANZ_NACHKOMMA);
	}
	for(i=0; i<31; i++){
		if(1<<i & x){
			zahl+=pow(2,i-ANZ_NACHKOMMA);
		}
	}
	printf("%3.12f\n",zahl);
	return EXIT_SUCCESS;
}