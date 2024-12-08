		.export	init_ssc
		.export	ser_put
		.export	ser_get
		.export	sscinit
		.export	sscput
		.export	sscget
		.export	put_mask
		.export	get_mask
		.export	PSPEED
		.import	init_addr
		.import	put_addr
		.import	get_addr
		.import	sscslot
		
		.export	_chr
		;DEBUG
		.import	cout
		.import	crout
		.include	"macros.inc"

CHR_ESC := $9b
.proc	init_ssc
		jmp (init_addr)
.endproc
;
; ser_put - Send accumulator out the serial line
;
.proc ser_put
		jmp	(put_addr)
.endproc

; ser_get - Get a character from Super Serial Card (XY unchanged)
;          Carry set on timeout, clear on data (returned in Accumulator)
;
.proc	ser_get
		jmp	(get_addr)
.endproc
;.align	256
;
; sscinit	body of init_ssc
;
.res	2
.proc	sscinit
		ldx	sscslot			; load slot number $n0
		lda #$0B			; COMMAND: NO PARITY, RTS ON,
		sta	$c08a,x
		ldy PSPEED			; CONTROL: 8 DATA BITS, 1 STOP
		lda BPSCTRL,Y		; BIT, BAUD RATE DEPENDS ON
		sta	$c08b,x
		rts
.endproc
;
; sscput    body of ser_put
;
.proc	sscput
		pha				; Push A onto the stack
loopin:
		ldx	sscslot
		lda	$c089,x	; get status register 
MOD5:	and put_mask	; Mask for DSR #$10(must ignore for Laser 128)
		cmp #$10
		bne	loopin	; if output register is full, then loop 
		pla			; pull A data
		sta	$c088,x	; put character
		rts
.endproc
;
; sscget    body of ser_get
;
.proc	sscget
		lda #$00
		sta Timer
		sta Timer+1
		ldx	sscslot
SSCGetLoop:
		bit $C0E0	; Attempt to slow accelerators down by referencing slot 6 ($C080 + $60)
		lda	$c089,x	; get status bits
		and get_mask
		cmp #$8
		beq get_byte	; Byte exists; go get it
		lda $C000		; Check for escape once in a while
		cmp #CHR_ESC	; Escape = abort
		beq abend
		inc Timer
		bne SSCGetLoop	; Timer non-zero, loop
		inc Timer+1
		bne SSCGetLoop	; Timer non-zero, loop
		sec				; timeout then set carry
		rts				; Timeout	
get_byte:
		lda	$c088,x		; Get character
		sta	_chr
		clc
		rts
abend:
		rts
.endproc

.data
; Constants for BPSCTRL offsets
BPS192K		= $00	; 19200 BPS
BPS1152K	= $01	; 115200 BPS
put_mask:	.byte		$10
get_mask:	.byte		$10
_chr:		.res		1
Timer:		.addr $0000		; Used by serial drivers for timing
BPSCTRL:	.byte $1F,$10	; 19200, 115200 - offsets must match constants BPS* above.
PSPEED:		.byte BPS192K	; Comms speed (19200)
;PSPEED:		.byte BPS1152K	; Comms speed (115200)
