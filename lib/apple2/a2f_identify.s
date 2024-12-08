.export		a2f_identify
.export		_identify
.import		_detect_iigs

.include	"ser_settings.inc"

.import		prbyte
.import		crout

IDBYTE1 := $fbb3
IDBYTE2 := $fb1e
IDBYTE3 := $fbc0
IDBYTE4 := $fbbe
.proc		_identify
		jsr	a2f_identify
		jsr	prbyte
		jsr	crout
		rts
.endproc

;
; a2f_identify       identify machine type of apple 2 family. 
;                    result returns in Accumlator
;
.proc		a2f_identify
	
		jsr	_detect_iigs		; returns 1 if running on IIGS, otherwise 0
		beq	t_eight_bit
		lda	#TYPE_IIGS
		rts
t_eight_bit:
		bit	$c082
		lda IDBYTE1
   		cmp #$06                ; IIe or IIc/IIc+ 
   		bne t_other
    	lda IDBYTE3 
	    cmp #$00                ; IIc? 
   		bne t_IIe 
                            	; IIc/IIc+
		lda	#TYPE_IIC
		jmp	exit	
t_IIe:
		lda	#TYPE_IIE
		jmp	exit
t_other:
		lda	#TYPE_II
exit:
		bit	$c080
		rts
.endproc
