    #include <p12f629.inc>
processor p12f629

; ---------------------------------------------------------------------
;   32X 50/60Hz automatic slave switch
;
;   Copyright (C) 2012 by Maximilian Rehkopf (ikari_01) <otakon@gmx.net>
;   Idea by n00b
;
;   This program is designed to run on a PIC12F629 or compatible micro
;   controller. It determines the frequency of the VSync signal on pin 5
;   and switches the output level of pin 6 accordingly (50Hz = 0V; 60Hz = 5V).
;
;   This program is released to the public domain; it is the wish of the
;   author that the original attributions stated above remain unchanged.
;
; ---------------------------------------------------------------------
;
;   pin configuration: (cartridge pin) [key CIC pin]
;
;                       ,---_---.
;                   +5V |1     8| GND
;                    nc |2     7| nc
;                    nc |3     6| 50/60Hz switch out
;                    nc |4     5| Vsync in (TTL)
;                       `-------'
;   Vsync can be taken from cartridge slot pin B13 or CN4 pin 15.
;   No sync separator required.

; -----------------------------------------------------------------------
    __CONFIG _INTRC_OSC_CLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _BODEN_OFF & _CP_OFF & _CPD_OFF

; -----------------------------------------------------------------------
; code memory
	org	h'0000'
	goto	init
isr
	org	h'0004'		; ISR always located at 0x0004
	btfss	INTCON, INTF	; only react on external interrupts
	goto	skip
	bcf	INTCON, INTF	; clear interrupt cause
	movf	TMR0, w
	sublw	h'47'		; timer threshold (71 steps ~= 55Hz)
	btfss	STATUS, C	; if borrow: TMR0 was larger -> 50Hz
	goto	set50
	bsf	GPIO, 1		; ELSE set output to HIGH = 60Hz
	goto	cont
set50
	bcf	GPIO, 1		;   -> set output to LOW = 50Hz
	goto	cont
cont
	clrf	TMR0		; clear timer counter
	bcf	INTCON, T0IF
skip
	retfie

init
	banksel	OSCCAL		; set OSCCAL from dedicated location
	call	h'3ff'
	movwf	OSCCAL
	banksel GPIO
	clrf	GPIO    	; set all pins low
	movlw	b'00000111'	; GPIO2..0 are digital I/O (not connected to comparator)
	movwf	CMCON
	banksel	TRISIO
	movlw	b'00111101'	; GP5=in GP4=in GP3=in GP2=in GP1=out GP0=in
	movwf	TRISIO
	movlw	b'10000111'	; no pullups; int on falling edge; TMR0 src=CLK;
				; TMR0 edge=rising, Prescaler=>TIMER0, PS rate=1:256
	movwf	OPTION_REG
	banksel GPIO
	clrf	TMR0		; reset timer
	movlw	b'10010000'	; global interrupt enable + external interrupt enable
	movwf	INTCON
idle
	goto	idle		; wait loop; ISR takes care of the rest

	end
