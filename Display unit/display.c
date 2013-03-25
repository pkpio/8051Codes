#include <at89c5131.h>
#define RS P0_0				//Command transfer = 0
#define RW P0_1				//WRITE = 0
#define EN P0_2
#define DATA P2

void delay(int delayTime){
	int i,j;
	for(i=0;i<delayTime;i++){
		for(j=0;j<255;j++){}
	}
}

void clearEN(void){
	delay(5);
	EN = 0;
}

void sendCmd(char cmd){
	delay(5);
	EN = 1;
	RS = 0;
	RW = 0;
	DATA = cmd;
	clearEN();
}

void sendLetter(char letter){
	delay(5);
	EN = 1;
	RS = 1;
	RW = 0;
	DATA = letter;
	clearEN();
}

//Only single digit numbers are handled. Breaking digits should be taken care
void sendNumber(int i){
	delay(5);
	EN = 1;
	RS = 1;
	RW = 0;
	DATA = i+30;	//Hex value of ASCII. so add 30h
	clearEN();
}

void initializeDisplay(){
	sendCmd(0x38); //Mode set 					0011 1000
	sendCmd(0x0E); //Display ON					0000 1110
	sendCmd(0x06); //Auto Right cursor	0000 0110
	sendCmd(0x01); //Clear screen				0000 0001
	sendCmd(0x80); //Cursor position		1000 0000
}

void main(){
	EN = 0;
	j = 7;			//For variables demo
	initializeDisplay();
	sendLetter('W');
	sendLetter('e');
	sendLetter('l');
	sendLetter('c');
	sendLetter('o');
	sendLetter('m');
	sendLetter('e');
	sendCmd(0xC0); 		//Change line
	sendLetter('P');
	sendLetter('r');
	sendLetter('a');
	sendLetter('v');
	sendLetter('e');
	sendLetter('e');
	sendLetter('n');
	sendLetter('!');
	
	sendNumber(j);		//Just for variables demo
	
	while(1){}
}
