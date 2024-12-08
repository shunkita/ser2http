		.export	zccinit
		.export	zccget
		.export	zccput
		.import	PSPEED

;
; zccp - Send accumulator out the SCC serial port
;
.proc	zccput
		sta TEMPA
		stx TEMPX

ZSEND:
		lda GSCMDB		; rr0

		tax
		and #%00000100		; test bit 2 (hardware handshaking)
		beq ZSEND
		txa
		and #%00100000		; test bit 5 (ready to send?)
		beq ZSEND

EXIT0:
		lda TEMPA		; get char to send
		sta GSDATAB		; send the character

EXIT:
		ldx TEMPX
		lda TEMPA
 		rts

TEMPA:	.byte	1
TEMPX:	.byte	1
.endproc

;
; zccg - Get a character from the SCC serial port (XY unchanged)
;
.proc	zccget
		lda GSCMDB	; DUMMY READ TO RESET 8530 POINTER TO 0
		lda #$00
		sta Timer
		sta Timer+1
SCCGetLoop:
		bit $C0E0	; Attempt to slow accelerators down by referencing slot 6 ($C080 + $60)
		lda GSCMDB	; READ 8530 READ REGISTER 0
		and #$01        ; BIT 0 MEANS RX CHAR AVAILABLE
		cmp #$01
		beq pullIt	; THERE'S A CHAR IN THE 8530 RX BUFFER
;	lda $C000	; Check for escape once in a while
;	cmp #CHR_ESC	; Escape = abort
;	bne @TimerInc
;	sec
;	rts
@TimerInc:
		inc Timer	; No character; poke at a crude timer
		bne SCCGetLoop	; Timer non-zero, loop
		inc Timer+1
		bne SCCGetLoop	; Timer non-zero, loop
		sec		; Timeout; bail
		rts	

pullIt:
		lda #$01	;  SET 'POINTER' TO rr1
		sta GSCMDB  
		lda GSCMDB	;  READ THE 8530 READ REGISTER 1
		and #$20	;  CHECK FOR bit 5=RX OVERRUN
		beq itsOK
		ldx #$30	; Clear Receive overrun
		stx GSCMDB
		ldx #$00
		stx GSCMDB

itsOK:
		lda #$08	;  WE WANT TO READ rr8
		sta GSCMDB	;  SET 'POINTER' TO rr8
		lda GSCMDB	;  READ rr8
		clc
		rts

SCCGetLoop2:
		bit $C0E0	; Attempt to slow accelerators down by referencing slot 6 ($C080 + $60)
		lda GSCMDB	; READ 8530 READ REGISTER 0
		and #$01        ; BIT 0 MEANS RX CHAR AVAILABLE
		cmp #$01
		beq pullIt	; THERE'S A CHAR IN THE 8530 RX BUFFER
		inc Timer	; No character; poke at a crude timer
		bne SCCGetLoop2	; Timer non-zero, loop
		inc Timer+1
		bne SCCGetLoop2	; Timer non-zero, loop
		sec		; Timeout; bail
		rts	
.endproc
;
; zccinit - initialize the Modem Port
; (Channel B is modem port, A is printer port)
;
.proc	zccinit
		sei
	
		lda GSCMDB	;hit rr0 once to sync up
	
		ldx #9		;wr9
		lda #RESETB	;load constant to reset Ch B
					;for Ch A, use RESETCHA
		stx GSCMDB
		sta GSCMDB
		nop			;SCC needs 11 pclck to recover
	
		ldx #3		;wr3
		lda #%11000000	;8 data bits, receiver disabled
		stx GSCMDB	;could be 7 or 6 or 5 data bits
		sta GSCMDB	;for 8 bits, bits 7,6 = 1,1
	
		ldx #5		;wr5
		lda %01100010	;DTR enabled 0=/HIGH, 8 data bits
		stx GSCMDB	;no BRK, xmit disabled, no SDLC
		sta GSCMDB	;RTS ;MUST; be disabled, no crc
	
		ldx #14		;wr14
		lda #%00000000	;null cmd, no loopback
		stx GSCMDB	;no echo, /DTR follows wr5
		sta GSCMDB	;BRG source is XTAL or RTxC
	
		lda PSPEED		
		cmp #BPS1152K	; 115200 baud?
		beq GOFAST		; Yes, go fast
	
		ldx #4			;wr4
		lda #%01000100	;X16 clock mode,
		stx GSCMDB	;1 stop bit, no parity
		sta GSCMDB	;could be 1.5 or 2 stop bits
				;1.5 set bits 3,2 to 1,0
				;2   set bits 3,2 to 1,1
	
		ldx #11	;wr11
		lda #WR11BBRG	;load constant to write
		stx GSCMDB
		sta GSCMDB
	
		jsr TIMECON	;set up wr12 and wr13
					;to set baud rate to 19200/BPS192K, the only other option.
	
	; Enables
		ora #%00000001	;enable baud rate gen
		ldx #14		;wr14
		stx GSCMDB
		sta GSCMDB	;write value
		jmp INITCOMMON

GOFAST:
		ldx #4		;wr4
		lda #%10000100	;X32 clock mode,
		stx GSCMDB	;1 stop bit, no parity
		sta GSCMDB	;could be 1.5 or 2 stop bits
				;1.5 set bits 3,2 to 1,0
				;2   set bits 3,2 to 1,1
	
		ldx #11		;wr11
		lda #WR11BXTAL	;load constant to write
		stx GSCMDB
		sta GSCMDB

INITCOMMON:
		lda #%11000001	;8 data bits, Rx enable
		ldx #3
		stx GSCMDB
		sta GSCMDB	;write value
	
		lda #%01101010	;DTR enabled; Tx enable
		ldx #5
		stx GSCMDB
		sta GSCMDB	;write value

; Enable Interrupts

		ldx #15		;wr15

; The next line is commented out. This driver wants
; interrupts when GPi changes state, ie. the user
; on the BBS may have hung up. You can write a 0
; to this register if you don't need any external
; status interrupts. Then in the IRQIN routine you
; won't need handling for overruns; they won't be
; latched. See the Zilog Tech Ref. for details.

; LDA #%00100000 ;allow ext. int. on CTS/HSKi

		lda #%00000000	;allow ext. int. on DCD/GPi
	
		stx GSCMDB
		sta GSCMDB
	
		ldx #0
		lda #%00010000	;reset ext. stat. ints.
		stx GSCMDB
		sta GSCMDB	;write it twice
	
		stx GSCMDB
		sta GSCMDB
	
		ldx #1		;wr1
		lda #%00000000	;Wait Request disabled
		stx GSCMDB	;allow IRQs on Rx all & ext. stat
		sta GSCMDB	;No transmit interrupts (b1)
	
		lda GSCMDB	; READ TO RESET channelB POINTER TO 0
		lda #$09
		sta GSCMDB	; SET 'POINTER' TO wr9
		lda #$00
		sta GSCMDB	; Anti BluRry's syndrome medication 
	
		cli
		rts		;we're done!


; TIMECON: Set time constant bytes in wr12 & wr13
; (In other words, set the baud rate.)

TIMECON:
		lda #12
		sta GSCMDB
		lda BAUDL	;load time constant low
		sta GSCMDB
	
		lda #13
		sta GSCMDB
		lda BAUDH	;load time constant high
		sta GSCMDB
		rts

; Table of values for different baud rates. There is
; a low byte and a high byte table.

BAUDL:	.byte	4	;19200

BAUDH:	.byte	0	;19200

; For reference, all the possible values:
;BAUDL:	.byte	126	;300 bps (1)
;	.byte	94	;1200 (2)
;	.byte	46	;2400 (3)
;	.byte	22	;4800 (4)
;	.byte	10	;9600 (5)
;	.byte	4	;19200 (6)
;	.byte	1	;38400 (7)
;	.byte	0	;57600 (8)
;
;BAUDH:	.byte	1	;300 bps (1)
;	.byte	0	;1200 (2)
;	.byte	0	;2400 (3)
;	.byte	0	;4800 (4)
;	.byte	0	;9600 (5)
;	.byte	0	;19200 (6)
;	.byte	0	;38400 (7)
;	.byte	0	;57600 (8)
.endproc

.data
BPS192K		= $00	; 19200 BPS
BPS1152K	= $01	; 115200 BPS
Timer:		.addr $0000	; Used by serial drivers for timing
;PSPEED:		.byte BPS192K	; Comms speed (19200)
;---------------------------------------------------------
; Apple IIgs SCC Z8530 registers and constants
;---------------------------------------------------------

GSCMDB	=	$C038
GSDATAB	=	$C03A

GSCMDA	=	$C039
GSDATAA	=	$C03B

RESETA	=	%11010001	; constant to reset Channel A
RESETB	=	%01010001	; constant to reset Channel B
WR11A	=	%11010000	; init wr11 in Ch A
WR11BXTAL	=	%00000000	; init wr11 in Ch B - use external clock
WR11BBRG	=	%01010000	; init wr11 in Ch B - use baud rate generator
