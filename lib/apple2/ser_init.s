        .export     ser_init
        .export     _ser_init

		.import		init_ssc
		.import		ser_settings
;
; ser_init: search serial slot and returns slot no.
;
.proc	_ser_init
		jmp		ser_init
.endproc
;
.proc ser_init
		jsr		ser_settings
		bne		:+				; found ssc,  find network device
		rts
:
		jsr		init_ssc
		rts
.endproc
