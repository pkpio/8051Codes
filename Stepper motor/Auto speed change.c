#include <at89c5131.h>
#define stepper P0
#define LED P1
#define NO_OF_STATES 4
#define MIN_DELAY 5 //In 10's of milliseconds between two states when at max speed
char STATES_ARRAY[NO_OF_STATES] = {0x01, 0x02, 0x04, 0x08};
char nextState = 0;
char speed = 0;
bit speedDirection = 1;
bit rotateDir=1;
char timerDelay = 0;

void timerInterrupt()interrupt 1{
	if(timerDelay == 20){
		if(speedDirection){
			if(speed<6){ speed++;}
			else { speedDirection =0; speed++;}
		}
		else {
			if(speed>1) { speed--;}
			else {speedDirection =1; speed--; rotateDir = ~rotateDir;}
		}
		
		timerDelay = 0;
	} else{
		timerDelay++;
	}
}

void delay(int delayTime){
	int i,j;
	for(i=0;i<delayTime;i++){
		for(j=0;j<255;j++){}
	}
}

void rotateMotor(char speed){
	if(rotateDir){
		if (nextState > (NO_OF_STATES - 1)){	nextState = 0;}		
		stepper = STATES_ARRAY[nextState];
		LED = STATES_ARRAY[nextState]*16; //Just for testing
		delay(MIN_DELAY*10*(8-speed));
		nextState++;
	}else{
		if (nextState < 0){	nextState = NO_OF_STATES-1;}		
		stepper = STATES_ARRAY[nextState];
		LED = STATES_ARRAY[nextState]*16; //Just for testing
		delay(MIN_DELAY*10*(8-speed));
		nextState--;
	}
}

void main(void) {
	//Setting the timer 0 for interrupts
	EA = 1;
	ET0 = 1;
	IT0 = 1;
	TMOD = 1;
	TCON = 1;
	TR0 = 1;
	while(1){
		rotateMotor(speed);
	}
}