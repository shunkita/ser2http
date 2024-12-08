		.export		findssc

        .include    "macros.inc"
        .include    "zp.inc"

		.import		prbyte
		.import		crout

;---------------------------------------------------------
; findssc
;---------------------------------------------------------
.proc	findssc
		mwa     #$c700, ptr1
		ldx		#$07
@loopin:
        ; test Cn05, Cn07, Cn0B, Cn0C match expected values.
        ldy     #$05
        lda     (ptr1), y
        cmp     #$38					; cn05 = #$38 ?
        bne     @next_slot
        ldy     #$07
        lda     (ptr1), y
        cmp     #$18					; cn07 = #$18 ?
        bne     @next_slot
        ldy     #$0b
        lda     (ptr1), y
        cmp     #$01                   ; cn0b = #$01 ?
        bne     @next_slot
        ldy     #$0c
        lda     (ptr1), y
        cmp     #$31			       ; cn0c = #$31 ?
        beq     @exit

@next_slot:
        dec     ptr1+1
		dex		
		cpx		#$00
		beq		@exit
        bne     @loopin
@exit:
		lda		ptr1+1
		and		#$0f					; slot # is in Acc
		rts
.endproc
