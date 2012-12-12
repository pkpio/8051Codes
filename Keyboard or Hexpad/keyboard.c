#include <at89c5131.h>
#include <math.h>
#define keyboard P3
#define LED P1

void anyKey(){
	keyboard = 15;
	if(keyboard!=15){ LED = 1;}
	else{ LED = 0;}
}

void theKey(){
	int temp;
	int keyTemp;
	
	keyboard = 0x0f;
	keyTemp = (~keyboard)&0x0f;
	switch(keyTemp){
		case 1:
			temp = 0; goto rowCheck;
		case 2:
			temp = 4; goto rowCheck;
		case 4:
			temp = 8; goto rowCheck;
		case 8:
			temp = 12; goto rowCheck;
		default:
			temp = 0; goto storeKey;
	}
	
	rowCheck:
	keyboard = 0xf0;
	keyTemp = ((~keyboard)&0xf0)/16;
	switch(keyTemp){
		case 1:
			temp += 0; goto storeKey;
		case 2:
			temp += 1; goto storeKey;
		case 4:
			temp += 2; goto storeKey;
		case 8:
			temp += 3; goto storeKey;
		default:
			temp = 0; goto storeKey;
	}
	
	storeKey:
	LED = temp*16;
}

void main(void){
	while(1){
		theKey();
	}
}