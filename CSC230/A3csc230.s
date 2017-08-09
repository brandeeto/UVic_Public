@ CSC230 -- Template for Treadmill program
	
@@@@ This program simulates the operation of a treadmill
@@@@ with control buttons for speed and setup buttons for
@@@@ user customization. Full specifications are documented separately.

@ Author:  Nigel Horspool and Micaela Serra
@ Modified by: Brandon Harvey V00784918

@@@ VERSION 9: pc address error maybe??
@@@				when pressing off key


	@ swi codes for using the Embest board
	.equ    SWI_SETSEG8, 		0x200		@display on 8 Segment
	.equ    SWI_SETLED, 		0x201		@LEDs on/off
	.equ    SWI_CheckBlack, 	0x202		@check press Black button
	.equ    SWI_CheckBlue, 		0x203		@check press Blue button
	.equ    SWI_DRAW_STRING, 	0x204		@display a string on LCD
	.equ    SWI_DRAW_INT, 		0x205		@display an int on LCD  
	.equ    SWI_CLEAR_DISPLAY, 	0x206		@clear LCD
	.equ    SWI_DRAW_CHAR, 		0x207		@display a char on LCD
	.equ    SWI_CLEAR_LINE, 	0x208		@clear a line on LCD
        
	.equ    SWI_EXIT, 		0x11		@terminate program
	.equ    SWI_GetTicks, 	0x6d		@get current time 

	.equ	SWI_PrStr,  0x69	@print a string: debug only, not needed
	.equ	Stdout,		1		@output mode for Stdout: debug only, not needed

	@ patterns for 8 segment display
	.equ    StoppedState,  0x8A
	.equ    RunningState,  0xC3
	.equ    PausingState,  0xC7
	.equ    PausedState,   0xD7
	.equ    EmergencyPattern, 0xAB
        
	@b it patterns for LED lights
	.equ    LEFT_LED, 	0x02
	.equ    RIGHT_LED, 	0x01
	.equ    BOTH_LED, 	0x03
	.equ    NO_LED, 	0x00
        
	@ bit patterns for black buttons
	.equ    LEFT_BLACK_BUTTON, 	0x02
	.equ    RIGHT_BLACK_BUTTON, 0x01

	@ bit patterns for blue keys
	.equ    StartKey, 		1<<0
	.equ    ResetKey, 		1<<1
	.equ    SpeedDown2Key, 	1<<4
	.equ    SpeedDown1Key, 	1<<5
	.equ    SpeedUp1Key, 	1<<6
	.equ    SpeedUp2Key, 	1<<7
	.equ    WeightDown2Key,	1<<8
	.equ    WeightDown1Key, 1<<9
	.equ    WeightUp1Key, 	1<<10
	.equ    WeightUp2Key, 	1<<11
	.equ    SwitchOffKey, 	1<<15

	.equ    UpdateInterval, 1000			@ can be changed
	.equ	HalfInterval,	500			@ for Emergency and Switch Off
	.equ	Top15bitRange,	0x00007fff	@(2^15) -1 = 32,767
	.equ    EmbestTimerMask,0x7fff   	@ 15 bit mask for timer values
	

	@ Default values used for initialization
	.equ	MinWeight, 	50	@ min weight = 50 lbs
	.equ	MaxWeight, 	350	@ max weight = 350 lbs
	.equ	DfltWeight, 100	@ default weight = 100 lbs
	.equ	MaxSpeed, 	150	@ max speed = 15.0 lbs
	.equ	DfltTarget, 20	@ default target speed = 2.0 mph
 
	.text           
	.global _start

@===== The entry point of the program
_start:
	bl	Redraw          @ display the default LCD screen
	bl	Treadmill		@ enter the whole treadmill cycle
	bl	ExitClear		@ clear all and exit
	swi	SWI_EXIT


@=====Treadmill()
@   Inputs:  none
@   Results:  none
@   Description:
@		The function simulates the operation of a treadmill.  It responds to
@     	inputs on the black buttons and blue keys.  It updates the LED lights,
@     	the 8-segment display and the LCD screen.
@		It returns to main when the SwitchOffKey has been pressed
@		either from the Stopped state or from the Pause state.

@ THIS IS A DUMMY VERSION OF THE FUNCTION.  IT SIMPLY STAYS STUCK IN ITS
@ STOPPED STATE UNTIL ANY BLUE KEY IS PRESSED. IT THEN PRINTS A MESSAGE
@ FOR THE KEY OR EXITS.

Treadmill:
	stmfd	sp!, {r0-r12,lr}

Stopped:			
					@INTERIM VERSION: only checks for blue/black keys
					@ and prints dummy message for testing logic
					@It does NOT check for invalid keys
	@ display the Stopped pattern on 8-seg and LEDs off
	mov	r0,#StoppedState
	swi SWI_SETSEG8
	mov	r0,	#NO_LED
	swi	SWI_SETLED
CheckActionStopped:
	swi	SWI_CheckBlack
	cmp	r0,#RIGHT_BLACK_BUTTON	@ EMERGENCY key?
	bleq	EmergencyState	
	
	swi	SWI_CheckBlue
	cmp	r0, #0
	beq	CheckActionStopped	@ no blue key pressed
		
	cmp	r0,#ResetKey		@ was it Reset key?
	beq	ResetKeyPressed
	cmp	r0,#SwitchOffKey	@turn off?
	beq	ExitTreadmill
	cmp	r0,#StartKey		@start running?
	bne	CheckWSkeys			@if not, keep checking
	ldr	r1,=TargetSpeed		@if Start, get speed
	ldr	r1,[r1]
	cmp	r1,#0				@if speed =0, cannot run
	beq	CheckActionStopped	@  and wait for more blue keys
	bal	Running				@else go to Running State

CheckWSkeys:			@must be either weight or speed keys
	ldr	r1,=Weight				
	bl	TestWeightKeys		@TestWeightKeys(r0:keypress;r1:&Weight);
	@@ if weight key had been pressed then go back to polling
	@@ else check Speed key (this check to be implemented)
	ldr	r1,=TargetSpeed
	bl	TestTargetKeys		@TestTargetkeys(r0:keypress;r1:&TargetSpeed);	
	bal	CheckActionStopped	@  and wait for more blue keys for testing?	

ResetKeyPressed:
	bl	Reset			@Reset(); reset all values to default data
	@@@ interim message for testing only
	mov	r0,#Stdout			@print to stdout
	ldr	r1,=tempreset		@ CUSTOMIZE
	swi	SWI_PrStr
	bal	CheckActionStopped	@  and wait for more blue keys
	
Running:
	@@@ interim message for testing only -- probably subroutine?
	mov	r0,#Stdout			@print to stdout
	ldr	r1,=temprunning		@ CUSTOMIZE
	swi	SWI_PrStr
	mov	r0,	#LEFT_LED
	swi	SWI_SETLED
	mov	r0,#RunningState
	swi SWI_SETSEG8
	ldr r5,=LEFT_LED
	
WaitAndPoll:
	ldr     r7, =EmbestTimerMask	@mask for 15 bit timer
	ldr		r10,=UpdateInterval			@interval to update time
WaitAndPollMain:
	swi		SWI_GetTicks
	and		r0,r0,r7
	ldr 	r1, =Time0
	str		r0, [r1]			@ store get ticks into Time0			
WaitAndPollLoop:
	
	swi     SWI_CheckBlack
	cmp     r0, #LEFT_BLACK_BUTTON	@ end of simulation
	beq    	Pausing
	cmp     r0, #RIGHT_BLACK_BUTTON	@ emergency manual shutdown
	beq     EmergencyCommencing
	
	swi		SWI_CheckBlue			@ Check if speed/off button pushed
	cmp r0,#SpeedUp1Key
	BLeq TestTargetKeys2
	cmp r0,#SpeedUp2Key
	BLeq TestTargetKeys2
	cmp r0,#SpeedDown1Key
	BLeq TestTargetKeys2
	cmp r0,#SpeedDown2Key
	BLeq TestTargetKeys2
	cmp r0,#SwitchOffKey
	beq ExitTreadmill
	
	ldr	r11,=ActualSpeed
	ldr	r12,=TargetSpeed
	ldr r11,[r11]
	ldr r12,[r12]
	add r12,r12,r11
	cmp r12,#0
	beq Stopped
				
	@ else here no events detected, keep checking time passing
	swi     SWI_GetTicks			@get time T1
	and		r0,r0,r7				@T1 in 15 bits
	mov		r2,r0					@r2 is T1
	ldr     r3, =Time0
	ldr     r1, [r3]				@ r1 is T0
	cmp		r2,r1					@ is T1>T0?
	bge		WaitSimpletime
	sub		r9,r7,r1				@ elapsed TIME= 32,676 - T0
	add		r9,r9,r2				@    + T1
	bal		WaitCheckInterval
WaitSimpletime:
	sub		r9,r2,r1				@ elapsed TIME = T1-T0
WaitCheckInterval:
	cmp		r9,r10					@is TIME < update period?
	blt		WaitAndPollLoop
	@ enough time passed without events, need to update outputs
	str     r0, [r3]        		@ update Time0	
	cmp		r5,#LEFT_LED
	Beq		TurnRightOn
	cmp		r5,#RIGHT_LED
	Beq		TurnLeftOn
SKIP:
	BL		UpdateTimeEtc			@ update all the variables, time, energy, distance
	BL		AccelDecel
	bal		WaitAndPollMain				@ then keep polling till event

TurnRightOn:
	stmfd	sp!, {r0}
	mov r0,	#NO_LED
	swi	SWI_SETLED	
	mov r0,	#RIGHT_LED
	swi SWI_SETLED
	mov r5,	#RIGHT_LED
	ldmfd	sp!, {r0}
	bal	SKIP
	
TurnLeftOn:
	stmfd	sp!, {r0}
	mov r0,	#NO_LED
	swi	SWI_SETLED	
	mov r0,	#LEFT_LED
	swi	SWI_SETLED
	mov r5,	#LEFT_LED
	ldmfd	sp!, {r0}
	bal SKIP
	
Pausing:
	stmfd	sp!, {r0-r12}
	mov	r0,#PausingState
	swi SWI_SETSEG8
	bal	led_flash
led_leftOn:
	swi	SWI_PrStr
	mov	r0,#LEFT_LED
	swi	SWI_SETLED
	bal 	loop2
led_rightOn:
	swi	SWI_PrStr
	mov	r0,#RIGHT_LED
	swi	SWI_SETLED
	bal	loop2

led_flash:
	ldr	r5,=Time
	ldr	r5,[r5]
	movs	r5, r5, ASR#1
	bcc	led_leftOn
	bcs	led_rightOn
loop2:
	ldr 	r1,=ActualSpeed
	ldr 	r1, [r1]
	ldr 	r3,=TargetSpeed
	ldr 	r3, [r3]
	mov 	r2,#0
	cmp 	r1,r2
	BEQ 	prepaused
	cmp 	r3, r1
	bgt 	Decrease1
Decrease1:
	mov 	r2, r1
	sub 	r2, r2, #1
	ldr 	r1,=ActualSpeed
	str 	r2, [r1]
	bal 	done
	
done:
	swi     SWI_CheckBlack
	cmp     r0, #RIGHT_BLACK_BUTTON	@ emergency manual shutdown
	beq     EmergencyCommencing
	
	swi	SWI_CheckBlue		
	cmp	r0,#StartKey
	beq	Running	
	
	bl ShowActual
	bl Wait
	ldr	r1,=Time
	ldr	r2,=Distance
	ldr	r3,=ActualSpeed
	ldr	r4,=Weight
	ldr	r5,=Energy
	bl UpdateTimeEtc
	bal led_flash

prepaused:
	ldmfd	sp!, {r0-r12}
Paused:
	bl ShowActual
	mov	r0,#BOTH_LED
	swi	SWI_SETLED
	mov	r0,#PausedState
	swi 	SWI_SETSEG8
	
	swi     SWI_CheckBlack
	cmp     r0, #RIGHT_BLACK_BUTTON	@ emergency manual shutdown
	beq     EmergencyCommencing
	
	
	swi	SWI_CheckBlue			@ Speed button pushed
	cmp 	r0,#SpeedUp1Key
	BLeq 	TestTargetKeys2
	cmp 	r0,#SpeedUp2Key
	BLeq 	TestTargetKeys2
	cmp 	r0,#SpeedDown1Key
	BLeq 	TestTargetKeys2
	cmp 	r0,#SpeedDown2Key
	BLeq 	TestTargetKeys2
	cmp	r0,#StartKey
	bne	CheckWSkeys		@if not, keep checking
	
	bal	Paused
	
@===== void AccelDecel(weight)
@   Inputs:  none
@   Results: Changed Speed
@   Description:
@      accelerates or decelerates 
AccelDecel:
	stmfd	sp!, {r0-r12,lr}
	
	ldr r1,=ActualSpeed
	ldr r1, [r1]
	ldr r3,=TargetSpeed
	ldr r3, [r3]
	cmp r1, r3
	blt Increase
	cmp r1,r3
	bgt Decrease
	bal DONE
Increase:
	mov r2, r1
	add r2, r2, #1
	ldr r1,=ActualSpeed
	str r2, [r1]
	bal DONE
Decrease:
	mov r2, r1
	sub r2, r2, #1
	ldr r1,=ActualSpeed
	str r2, [r1]
	bal DONE
	
DONE:
	bl ShowActual
	ldmfd	sp!, {r0-r12,pc}
	
	

ExitTreadmill:			@ return to Main for proper exit
	bl ExitClear
	ldmfd	sp!, {r0-r12,pc}

@===== TestWeightKeys( r0: blue key status; r1:&Weight )
@   Inputs:
@      	r0: the result from a call to swi 0x203 (check blue keys)
@		r1: address of variable Weight
@   Results: r0=0 if a weight key had been pressed and dealt with, 
@			r0= original key press otherwise
@   Side-effects:
@      updates to global variable Weight, and call to ShowWeight
@   Description:
@      Tests if keys to change the weight up or down have been pressed;
@      if so, the Weight variable is changed and the new value displayed
@		else nothing is done
@	WeightDown2Key ==> -10 lbs
@	WeightDown1Key ==> -5 lbs
@	WeightUp2Key ==> +10 lbs
@	WeightUp1Key ==> +5 lbs
TestWeightKeys:
	stmfd	sp!, {r1-r3,lr}
	
	cmp r0,#WeightUp1Key	@ was it a weight up 5 key?
	beq	WeightUp1KeyPressed
	cmp r0,#WeightUp2Key	@ was it a weight up 10 key?
	beq WeightUp2KeyPressed
	cmp r0,#WeightDown2Key	@ was it a weight down 10 key?
	beq WeightDown2KeyPressed
	cmp r0,#WeightDown1Key	@ was it a weight down 5 key?
	beq WeightDown1KeyPressed
	
	bal TestTargetKeys	
		
WeightDown1KeyPressed:
	ldr r1,=Weight
	ldr r2,[r1]
	add r2,r2,#-5
	str r2,[r1]
	
	ldr r3,=MinWeight
	cmp r2,r3
	blt DoneTestWeightKeysMin
	
	bl Update
	bal	CheckActionStopped	@  and wait for more blue keys
	
WeightDown2KeyPressed:
	ldr r1,=Weight
	ldr r2,[r1]
	add r2,r2,#-10
	str r2,[r1]
	
	ldr r3,=MinWeight
	cmp r2,r3
	blt DoneTestWeightKeysMin
	
	bl Update
	bal	CheckActionStopped	@  and wait for more blue keys 
	
WeightUp2KeyPressed:
	ldr r1,=Weight
	ldr r2,[r1]
	add r2,r2,#10
	str r2,[r1]
	
	ldr r3,=MaxWeight
	cmp r2,r3
	bgt DoneTestWeightKeysMax
	
	bl Update
	bal	CheckActionStopped	@  and wait for more blue keys 
	
WeightUp1KeyPressed:
	ldr r1,=Weight
	ldr r2,[r1]
	add r2,r2,#5
	str r2,[r1]
	ldr r3,=MaxWeight
	cmp r2,r3
	bgt DoneTestWeightKeysMax

	bl Update
	bal	CheckActionStopped	@  and wait for more blue keys 
	
DoneTestWeightKeysMax:
	str r3,[r1]
	bl Update
	mov r0,#0
	ldmfd	sp!, {r1-r3,pc}
	
DoneTestWeightKeysMin:
	str r3,[r1]
	bl Update
	mov r0,#0
	ldmfd	sp!, {r1-r3,pc}


@===== TestTargetKeys( r0: blue key status; r1: &TargetSpeed )
@   Inputs:
@      	r0: the result from a call to swi 0x203 (check blue keys)
@		r1: address of variable TargetSpeed
@   Results: r0=0 if a speed key had been pressed and dealt with, 
@			r0= original key press otherwise
@   Side-effects:
@      updates the global variable TargetSpeed, and calls to ShowTarget
@   Description:
@      Tests if keys to change the target speed up or down have been pressed;
@      if so, the TargetSpeed variable is changed and the new value displayed
@		else nothing is done
@	SpeedDown2Key ==> -0.5 miles
@	SpeedDown1Key ==> -0.1 miles
@	SpeedUp2Key ==> +0.5 miles
@	SpeedUp1Key ==> +0.1 miles
TestTargetKeys:
	stmfd	sp!, {r1-r3,lr}
		
	cmp r0,#SpeedUp1Key
	beq SpeedUp1KeyPressed
	cmp r0,#SpeedUp2Key
	beq SpeedUp2KeyPressed
	cmp r0,#SpeedDown1Key
	beq SpeedDown1KeyPressed
	cmp r0,#SpeedDown2Key
	beq SpeedDown2KeyPressed
	
	bal CheckActionStopped		@ if none of these conditions are satisfied 
	
SpeedUp2KeyPressed:
	ldr r1,=TargetSpeed
	ldr r2,[r1]
	add r2,r2,#5
	str r2,[r1]
	ldr r3,=MaxSpeed
	cmp r2,r3
	bgt DoneTestTargetKeysMax
	bl Update
	bal	CheckActionStopped	@  and wait for more blue keys
	
SpeedUp1KeyPressed:
	ldr r1,=TargetSpeed
	ldr r2,[r1]
	add r2,r2,#1
	str r2,[r1]
	ldr r3,=MaxSpeed
	cmp r2,r3
	bgt DoneTestTargetKeysMax
	bl Update
	bal	CheckActionStopped	@  and wait for more blue keys
	
SpeedDown2KeyPressed:
	ldr r1,=TargetSpeed
	ldr r2,[r1]
	add r2,r2,#-5
	str r2,[r1]
	ldr r3,=0
	cmp r2,r3
	blt DoneTestTargetKeysMin
	bl Update
	bal	CheckActionStopped	@  and wait for more blue keys
	
SpeedDown1KeyPressed:
	ldr r1,=TargetSpeed
	ldr r2,[r1]
	add r2,r2,#-1
	str r2,[r1]
	ldr r3,=0
	cmp r2,r3
	blt DoneTestTargetKeysMin
	bl Update
	bal	CheckActionStopped	@  and wait for more blue keys
	
DoneTestTargetKeysMax:
	str r3,[r1]
	bl Update
	mov r0,#0
	ldmfd	sp!, {r1-r3,pc}
	
DoneTestTargetKeysMin:
	str r3,[r1]
	bl Update
	mov r0,#0
	ldmfd	sp!, {r1-r3,pc}

@===== TestTargetKeys2( r0: blue key status; r1: &TargetSpeed )
@   Inputs:
@      	r0: the result from a call to swi 0x203 (check blue keys)
@		r1: address of variable TargetSpeed
@   Results: r0=0 if a speed key had been pressed and dealt with, 
@			r0= original key press otherwise
@   Side-effects:
@      updates the global variable TargetSpeed, and calls to ShowTarget
@   Description:
@      Tests if keys to change the target speed up or down have been pressed;
@      if so, the TargetSpeed variable is changed and the new value displayed
@		else nothing is done
@	SpeedDown2Key ==> -0.5 miles
@	SpeedDown1Key ==> -0.1 miles
@	SpeedUp2Key ==> +0.5 miles
@	SpeedUp1Key ==> +0.1 miles
TestTargetKeys2:
	stmfd	sp!, {r1-r3,lr}
		
	cmp r0,#SpeedUp1Key
	beq SpeedUp1KeyPressed2
	cmp r0,#SpeedUp2Key
	beq SpeedUp2KeyPressed2
	cmp r0,#SpeedDown1Key
	beq SpeedDown1KeyPressed2
	cmp r0,#SpeedDown2Key
	beq SpeedDown2KeyPressed2
		
SpeedUp2KeyPressed2:
	ldr r1,=TargetSpeed
	ldr r2,[r1]
	add r2,r2,#5
	str r2,[r1]
	ldr r3,=MaxSpeed
	cmp r2,r3
	bgt DoneTestTargetKeysMax2
	bl Update
	ldmfd	sp!, {r1-r3,pc}			@  return back to where you came from (Running State)
	
SpeedUp1KeyPressed2:
	ldr r1,=TargetSpeed
	ldr r2,[r1]
	add r2,r2,#1
	str r2,[r1]
	ldr r3,=MaxSpeed
	cmp r2,r3
	bgt DoneTestTargetKeysMax2
	bl Update
	ldmfd	sp!, {r1-r3,pc}			@  return back to where you came from (Running State)
	
SpeedDown2KeyPressed2:
	ldr r1,=TargetSpeed
	ldr r2,[r1]
	add r2,r2,#-5
	str r2,[r1]
	ldr r3,=0
	cmp r2,r3
	blt DoneTestTargetKeysMin2
	bl Update
	ldmfd	sp!, {r1-r3,pc}			@  return back to where you came from (Running State)
	
SpeedDown1KeyPressed2:
	ldr r1,=TargetSpeed
	ldr r2,[r1]
	add r2,r2,#-1
	str r2,[r1]
	ldr r3,=0
	cmp r2,r3
	blt DoneTestTargetKeysMin2
	bl Update
	ldmfd	sp!, {r1-r3,pc}			@  return back to where you came from (Running State)
	
DoneTestTargetKeysMax2:
	str r3,[r1]
	bl Update
	mov r0,#0
	ldmfd	sp!, {r1-r3,pc}
	
DoneTestTargetKeysMin2:
	str r3,[r1]
	bl Update
	mov r0,#0
	ldmfd	sp!, {r1-r3,pc}
	
@===== void UpdateTimeEtc(&Time,&Distance,&ActualSpeed,&Weight,&Energy))
@   Inputs:  	R1:&Time;  R2:&Distance; R3:&ActualSpeed;
@				R4:&Weight; R5:&Energy
@   Results: none
@   Side-Effects:
@      Updates to the Time, Distance and Energy variables.
@   Description:
@      This function must be called every time Interval while the treadmill belt
@      is moving. It causes the Time variable to be incremented, and the
@      Distance and Energy variables to be updated.  The new values are displayed.
UpdateTimeEtc:
	stmfd	sp!, {r0-r8,lr}
		ldr r2,=Distance
        ldr	r6,[r2]				@ r6=Distance
		ldr r3,=ActualSpeed
        ldr	r7,[r3]				@ r7=ActualSpeed
        add	r8,r7,r7,lsl #1		@ r8=ActualSpeed*3
        add	r6,r6,r8			@ Distance += 3*ActualSpeed
        str	r6,[r2]        		@ store updated Distance
		ldr r1,=Time
        ldr	r6,[r1]				@ r6=Time
        add	r6,r6,#1			@ Time++
        str	r6,[r1]				@ store updated Time
		ldr r6,=Weight
        ldr	r6,[r6]				@ r6=Weight
        mul	r8,r6,r7			@ r8=Weight*ActualSpeed
        mov	r8,r8,lsl #2		@ r8=4*Weight*ActualSpeed==>new energy
		ldr r5,=Energy
        ldr	r6,[r5]				@ r6=Energy
        add	r6,r6,r8			@ Energy += 4*ActualSpeed*Weight
        str	r6,[r5]        		@ store updatedEnergy
        @ display new values
        ldr	r0,[r1]				@ r0=Time
        ldr	r1,[r2]				@ r1=Distance
        ldr	r2,[r5]				@ r2=Energy
        bl	ShowTimeDistEnergy	@ShowTimeDistEnergy(r0:Time;r1:Distance;R2:Energy)      
        ldmfd	sp!, {r0-r8,pc}

@ =====void Redraw()
@   Inputs:  none
@   Results: none
@   Description:
@      Redraws the initial state of the LCD screen and displays the default
@      values for all state variables.
Redraw:
	stmfd	sp!, {r0-r3,lr}
	mov	r1, #0			@ r1 = next line number to display
	mov	r0, #0			@ r0 = column number for displayed strings
	ldr	r3, =TextLines	@ r4 references first element of array
RS1:	
	ldr	r2, [r3], #4	@draw all lines with XX fields
    swi	SWI_DRAW_STRING
	add	r1, r1, #1
	cmp	r1, #NumTextLines
	blt	RS1
	bl	Reset			@Reset(); reset all values to default data
	ldmfd	sp!, {r0-r3,pc}

@ =====
	
@ =====void Update()
@   Inputs:  none
@   Results: none
@   Description:
@		redraws the items on the LCD.
@		All variables are globally accessible (EXCEPTION to rule).
Update:
	stmfd	sp!, {r0-r3,lr}
	ldr	r0,=Weight
	ldr r0,[r0]
	bl	ShowWeight		@display Weight
	ldr	r0, =TargetSpeed
	ldr r0,[r0]
	bl	ShowTarget		@display Target Speed
	ldr	r0, =ActualSpeed
	ldr r0,[r0]
	bl	ShowActual		@display Speed
	ldr r0, =Time
	ldr r0,[r0]
	ldr	r1, =Distance
	ldr r1,[r1]
	ldr	r2, =Energy
	ldr r2,[r2]
    bl  ShowTimeDistEnergy		@display Time, Distance, Energy
	ldmfd	sp!, {r0-r3,pc}	
	
@ =====void Reset()
@   Inputs:  none
@   Results: none
@   Description:
@		Stores the default values in variables Weight and TargetSpeed; 
@		initializes Time, Distance, ActualSpeed, and Energy to zero;
@		redraws the items on the LCD.
@		All variables are globally accessible (EXCEPTION to rule).
Reset:
	stmfd	sp!, {r0-r3,lr}
	ldr	r0,=DfltWeight
	ldr	r1,=Weight
	str	r0,[r1]			@store default Weight in variable
	bl	ShowWeight		@display Weight
	ldr	r0, =DfltTarget
	ldr	r1, =TargetSpeed
	str	r0, [r1]		@store default Target Speed in variable
	bl	ShowTarget		@display Target Speed
	mov	r0, #0  
	ldr	r1, =ActualSpeed
	str	r0,[r1]			@store default Speed in variable
	bl	ShowActual		@display Speed
	mov	r0,#0		
	ldr r1, =Time
	str	r0, [r1]		@store default Time in variable
	mov	r1,#0
	ldr	r2, =Distance
	str	r1, [r2]		@store default Distance in variable
	mov	r2,#0
	ldr	r3, =Energy
	str	r2, [r3]		@store default Energy in variable
    bl  ShowTimeDistEnergy		@display Time, Distance, Energy
	ldmfd	sp!, {r0-r3,pc}
	
@===== void ExitClear()
@   Inputs:  none
@   Results: none
@   Description:
@      Clear the board and display the last message
ExitClear:	
	stmfd	sp!, {r0-r2,lr}
	mov	r0, #0
	swi	SWI_SETSEG8
	mov	r0, #NO_LED
	swi	SWI_SETLED
	mov	r0, #5
	mov	r1, #7

UpdatingExit:
	ldr r2,=ActualSpeed
	ldr r2,[r2]			@ Actual Speed
	cmp r2,#1
	ble LastExit
	mov r3, r2
	sub r3, r3, #1
	ldr r2,=ActualSpeed
	str r3,[r2]
	bal Donesies
	
LastExit:
	mov r3,r2
	sub r3,r3,r3
	ldr r2,=ActualSpeed
	str r3,[r2]
	
Donesies:
	ldr r10,=HalfInterval
	bl Wait
	bl ShowActual
	bl UpdateTimeEtc
	ldr r2,=ActualSpeed
	ldr r2,[r2]
	cmp r2,#0
	bne UpdatingExit

	swi	SWI_CLEAR_DISPLAY
	ldr	r2, =Goodbye
	swi	SWI_DRAW_STRING  @ display goodbye message on line 7
	ldmfd	sp!, {r0-r2,pc}

	
@===== void ShowWeight(weight)
@   Inputs:  r0 with weight
@   Results: none
@   Description:
@      Displays the value of given Weight in the LCD screen
ShowWeight:
	stmfd	sp!, {r0-r2,lr}
	mov	r1, #0
	mov	r2, #6
	bl	Int2Ascii	@ r0=Int2Ascii(number:r0;scale:r1;width:r2);
	mov	r2, r0
	mov	r0, #16		@display in correct position
	mov	r1, #2
    swi     SWI_DRAW_STRING
	ldmfd	sp!, {r0-r2,pc}

@ =====void ShowTarget(TargetSpeed)
@   Inputs:  R0
@   Results: none
@   Description:
@      Displays the value of given TargetSpeed in the LCD screen
ShowTarget:
	stmfd	sp!, {r0-r2,lr}
	mov	r1, #1
	mov	r2, #6
	bl	Int2Ascii	@ r0=Int2Ascii(number:r0;scale:r1;width:r2);
	mov	r2, r0
	mov	r0, #16		@display in correct position
	mov	r1, #3
    swi     SWI_DRAW_STRING
	ldmfd	sp!, {r0-r2,pc}
	
@===== void ShowActual(Speed)
@   Inputs:  R0
@   Results: none
@   Description:
@      Displays the value of the given ActualSpeed in the LCD screen
ShowActual:
	stmfd	sp!, {r0-r2,lr}
	ldr r0,=ActualSpeed
	ldr r0,[r0]
	mov	r1, #1
	mov	r2, #6
	bl	Int2Ascii	@ r0=Int2Ascii(number:r0;scale:r1;width:r2);
	mov	r2, r0
	mov	r0, #16		@display in correct position
	mov	r1, #4
    swi	SWI_DRAW_STRING
	ldmfd	sp!, {r0-r2,pc}

@===== void ShowTimeDistEnergy(Time;Distance;Energy)
@   Inputs:  r0:Time; r1:Distance; r2:Energy
@   Results: none
@   Description:
@      Displays the values of the Time, Distance and Energy variables in the LCD screen
ShowTimeDistEnergy:
	stmfd	sp!, {r0-r4,lr}
	mov	r3,r1		@r3=Distance
	mov	r4,r2		@r4=Energy
	mov	r1, #0		@r0 has Time to draw (in seconds, no decimal)
	mov	r2, #10
	bl	Int2Ascii	@ r0=Int2Ascii(number:r0;scale:r1;width:r2);
	mov	r2, r0
	mov	r0, #12		@display in correct position
	mov	r1, #5
    swi	SWI_DRAW_STRING
	mov	r0,r3		@r0 has Distance to draw
	mov	r1, #6
	mov	r2, #10
	bl	Int2Ascii	@ r0=Int2Ascii(number:r0;scale:r1;width:r2);
	mov	r2, r0
	mov	r0, #12		@display in correct position
	mov	r1, #6
	swi	SWI_DRAW_STRING
	mov	r0,r4		@r0 has Energy to draw
	mov	r1, #6
	mov	r2, #10		@display in correct position
	bl	Int2Ascii	@ r0=Int2Ascii(number:r0;scale:r1;width:r2);
	mov	r2, r0
	mov	r0, #12		@display in correct position
	mov	r1, #7
	swi	SWI_DRAW_STRING
	ldmfd	sp!, {r0-r4,pc}

@=====	int:r0 = Int2Ascii(number,scale factor,width )
@   Inputs:
@       r0: a number to convert to an ASCII string
@       r1: a scale factor used as a power of 10
@		r2: the minimum string length to return for the result
@   Results:
@       r0: the address of a null terminated ASCII string
@   Example:
@       A call such as Int2Ascii(1234, 2, 7) will return the
@       address of the ASCII string "  12.34".
@   Description:
@       Only unsigned (non-negative) numbers are converted.
@       No decimal point is inserted into the result if the scale factor
@       is zero.  At least one digit will be generated before the
@       decimal point.
@	The ASCII string is extended with spaces (on the left) so that
@       its length is at least as great as the width parameter.
@       The result string is held in a static buffer; a subsequent call
@       will overwite the previously returned result.
@	The width cannot exceed 15.
Int2Ascii:
	stmfd	sp!, {r1-r7,lr}
	ldr	r7, =Buffer
	ldr	r3, =Pow10
	mov	r4, #9					@ max power of 10 handled = 9
	sub	r1, r1, #1
IA1:	
	cmp		r4, r1
	beq		IA2             		@ jump if number needs a zero before the point
	ldr		r5, [r3, r4, lsl #2]    @ load next power of 10
	cmp		r0, r5
	bge		IA4		@ jump if number bigger or equal to the power of 10
	subs	r4, r4, #1
	bge		IA1
	mov		r6, #'0'        	@ the number is zero, store as the value
	strb	r6, [r7], #1
	bal		IA6
IA2:	
	mov		r6, #'0'
	strb	r6, [r7], #1    	@ store a significant zero
IA3:	
	cmp		r4, r1
	moveq	r6, #'.'
	streqb	r6, [r7], #1    	@ store a decimal point
IA4:	
	mov		r6, #'0'        	@ initialize current digit to 0
	ldr		r5, [r3, r4, lsl #2]
IA5:	
	subs	r0, r0, r5
	addge	r6, r6, #1      	@ increment the digit?
	bge		IA5             	@ repeat if we didn't overshoot
    add     r0, r0, r5      	@ correct the overshoot
    strb	r6, [r7], #1    	@ store the digit
	subs	r4, r4, #1      	@ decrement the power of 10
	bge		IA3
IA6:	
	ldr		r0, =Buffer
    add		r1, r0, r2      	@ desired string end
	cmp		r1, r7
	ble		IA9             	@ jump if string is long enough
    mov		r5, r7
    mov		r7, r1
IA7:    
	ldrb    r6, [r5, #-1]!
	strb	r6, [r1, #-1]!  	@ move next char right
    cmp		r5, r0
	bgt     IA7             	@ jump if more chars to shift over
	mov		r6, #' '
IA8:    
	strb    r6, [r1, #-1]!  	@ insert space at front
	cmp     r1, r0
	bgt     IA8             	@ jump if more spoces to insert
IA9:	
	mov		r6, #0
	strb	r6, [r7]        	@ store terminating null byte
	ldmfd	sp!, {r1-r7,pc}

EmergencyCommencing:
	mov	r0,#EmergencyPattern	@8-segment pattern 			
	swi SWI_SETSEG8
	mov	r8,#EmergencyPattern
	mov r0,#NO_LED
	swi	SWI_SETLED
	mov r5,#NO_LED
EMWaitAndPoll:
	ldr     r7, =EmbestTimerMask	@mask for 15 bit timer
	ldr		r10,=UpdateInterval		@interval to update time
EMWaitAndPollMain:
	swi		SWI_GetTicks
	and		r0,r0,r7
	ldr 	r1, =Time0
	str		r0, [r1]			@ store get ticks into Time0			
EMWaitAndPollLoop:
	swi     SWI_GetTicks			@get time T1
	and		r0,r0,r7				@T1 in 15 bits
	mov		r2,r0					@r2 is T1
	ldr     r3, =Time0
	ldr     r1, [r3]				@ r1 is T0
	cmp		r2,r1					@ is T1>T0?
	bge		EMWaitSimpletime
	sub		r9,r7,r1				@ elapsed TIME= 32,676 - T0
	add		r9,r9,r2				@    + T1
	bal		EMWaitCheckInterval
EMWaitSimpletime:
	sub		r9,r2,r1				@ elapsed TIME = T1-T0
EMWaitCheckInterval:
	cmp		r9,r10					@is TIME < update period?
	blt		EMWaitAndPollLoop
	
	@ enough time passed without events, need to update outputs
	str     r0, [r3]        		@ update Time0	
	cmp		r5,#BOTH_LED
	Beq		EMNoLED
	cmp		r5,#NO_LED
	Beq		EMBothLED

SKIP2:
	cmp	r8,#EmergencyPattern
	beq EMPatternOff
	
	mov	r0,#EmergencyPattern
	swi SWI_SETSEG8
	mov	r8,#EmergencyPattern
	bal SKIP3

EMPatternOff:
	mov	r0,#0	@8-segment pattern 			
	swi SWI_SETSEG8
	mov r8,#0

SKIP3:	
	ldr r4,=ActualSpeed
	ldr r4,[r4]				@ R4 now holds actual speed
	cmp r4,#0				@ If equals zero
	beq EmergencyState
	cmp r4,#5
	ble EmergDecrease
	mov r6, r4
	sub r6, r6, #5			@Subtract Speed by 5
	ldr r4,=ActualSpeed
	str r6,[r4]
	BL	ShowActual
	BL	UpdateTimeEtc			@ update all the variables, time, energy, distance
	bal	EMWaitAndPollLoop
	
EmergDecrease:
	mov r6, r4
	sub r6,r6,r6
	ldr r4,=ActualSpeed		@ Subtract by actual speed to get to zero
	str r6, [r4]
	bal EMWaitAndPollLoop

	
EMBothLED:
	stmfd	sp!, {r0}
	mov r0,	#BOTH_LED
	swi	SWI_SETLED	
	mov r5,	#BOTH_LED
	ldmfd	sp!, {r0}
	bal	SKIP2
	
EMNoLED:
	stmfd	sp!, {r0}
	mov r0,	#NO_LED
	swi	SWI_SETLED	
	mov r5,	#NO_LED
	ldmfd	sp!, {r0}
	bal SKIP2


@===== void EmergencyState()
@   Inputs:  none
@   Results:  none
@   Description:
@     	The function sets the configuration for
@		the blinking LCD lines in case of emergency.
@		NO return to main, infinite loop: only way
@		to exit program is to quit externally.
@@@@ CODE STILL TO BE DONE: SLOW DOWN FROM ACTUAL SPEED
@@@@ TO 0, BY 0.5 MPH DECREMENTS, EVERY 1/2 INTERVAL
@@@@ THEN DO THE FINAL SCREEN EXIT
EmergencyState:
	stmfd	sp!, {r0,lr}
EmLoop:
	mov	r0, #NO_LED			@LEDs both on/off flashing together
	swi	SWI_SETLED
	mov	r0,#EmergencyPattern	@8-segment pattern 			
	swi SWI_SETSEG8		
	swi	SWI_CLEAR_DISPLAY
	ldr	r10,=HalfInterval	@pause for 1/2 interval
	Bl	Wait				@void Wait(Delay:r10)
	mov	r0, #BOTH_LED		@LEDs both on/off flashing together
	swi	SWI_SETLED
	mov	r0, #0				@8-segment pattern all off 
	swi SWI_SETSEG8		
	mov	r0, #0				@column
	mov	r1, #7				@row
	ldr	r2, =EmergencyMessage
	swi	SWI_DRAW_STRING 
	ldr	r10,=HalfInterval	@pause for 1/2 interval
	Bl	Wait				@void Wait(Delay:r10)
	bal	EmLoop
	ldmfd	sp!, {r0,pc}
	
@ ==== void Wait(Delay:r10) 
@   Inputs:  R10 = delay in milliseconds
@   Results: none
@   Description:
@      Wait for r10 milliseconds using a 15-bit timer 
Wait:
	stmfd	sp!, {r0-r2,r7-r10,lr}
	ldr     r7, =EmbestTimerMask
	swi     SWI_GetTicks		@get time T1
	and		r1,r0,r7			@T1 in 15 bits
WaitLoop:
	swi 	SWI_GetTicks		@get time T2
	and		r2,r0,r7			@T2 in 15 bits
	cmp		r2,r1				@ is T2>T1?
	bge		simpletimeW
	sub		r9,r7,r1			@ elapsed TIME= 32,676 - T1
	add		r9,r9,r2			@    + T2
	bal		CheckIntervalW
simpletimeW:
	sub		r9,r2,r1		@ elapsed TIME = T2-T1
CheckIntervalW:
	cmp		r9,r10				@is TIME < desired interval?
	blt		WaitLoop
WaitDone:
	ldmfd	sp!, {r0-r2,r7-r10,pc}
	
@@@@@@@@@@@@=========================
	.data
    .equ NumTextLines, 14
TextLines:
	.word	line0, 0, line2, line3, line4, line5
	.word	line6, line7, 0, line9, line10
	.word	line11, line12, line13
line0:	.asciz	"Treadmill -- Brandon Harvey, V00784918"
line2:	.asciz	"Weight:         XXX     lbs"
line3:	.asciz	"Target speed:   XXX     mph"
line4:	.asciz	"Actual speed:   XXX     mph"
line5:  .asciz  "Time:           XXX     seconds"
line6:	.asciz	"Distance:   XXXXXXXX    miles"
line7:	.asciz	"Energy:     XXXXXXXX    Calories"
line9:	.asciz	"Buttons:       Pause, STOP!"
line10:	.asciz	"Keys:    Start, Reset, --,    --"
line11:	.asciz	"         Sp -2, Sp -1, Sp +1, Sp +2"
line12:	.asciz	"         Wt -2, Wt -1, Wt +1, Wt +2"
line13:	.asciz	"         --,    --,    --,    Off"

Goodbye:
	.asciz	"*** Treadmill program ended ***"
EmergencyMessage:
	.asciz	"***TREADMILL EMERGENCY - GO TO MANUAL***"
	.align

Weight:
	.word	100
TargetSpeed:
	.word	20
ActualSpeed:
       	.word	0
Time:
        .word   0
Distance:
	.word	0
Energy:
	.word	0
Time0:
        .word   4
LEDState:
        .word   0

        @ Powers of 10 array, used by Int2Ascii function
Pow10:	.word	1, 10, 100, 1000, 10000, 100000
	.word	1000000, 10000000, 100000000, 1000000000
        @ Result buffer used by Int2Ascii function
Buffer:	.space	16
temprunning:	.asciz	"Running state\n"
tempreset:	.asciz	"Reset key\n"
tempother:	.asciz	"Weight or Speed keys\n"
	.end

