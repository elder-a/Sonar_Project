// Purpose:   To capture the pulse form a US sensor 
// Date:      2017 01 06
// Author:    Andrew Elder 
#include <avr/io.h>

#define trig PB1
#define echo PB0 //input capture
//ICR1 is input capture reg 
//(ICR1L) and then the high byte (ICR1H)
#define BAUD9600 103 //sets correct baud rate 

.global setup
setup: 
//declare pins to output 
//setup the serial monitor 
//setup the ultsonic sensor 
sbi _SFR_IO_ADDR(DDRB), DDB1  //sets PB1 to output (not tested)

  ldi r25,BAUD9600 >> 8       //Serial monitor setup 
  ldi r24,BAUD9600            
  call initUART               

  call printLn
  ldi r25, 239
  call printByte
  
ret

.global loop
loop:
//main code will consist of trigger routine (below)
//then input capture stuff
//then send to serial monitor 
//then repeat 

/*   
  digitalWrite(Trig_pin, LOW);
  delayMicroseconds(2);
  digitalWrite(Trig_pin, HIGH);
  delayMicroseconds(10); //setup for reciving a signal
    
  digitalWrite(Trig_pin, LOW); //uses pulse o echo pin to capture
    
  duration = pulseIn(Echo_pin,HIGH); //what is the pulse in funciton
*/
rjmp loop      





