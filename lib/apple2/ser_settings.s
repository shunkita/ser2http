        .export ser_settings

		.import	a2f_identify
		.import	findssc
		.import	sscslot
		.import	sscinit
		.import	sscput
		.import	sscget
		.import	zccinit
		.import	zccget
		.import	zccput
		.import	init_addr	
		.import	put_addr
		.import	get_addr
		.import	put_mask
		.import	get_mask

;debug
		.import		prbyte
		.import		cout
		.import		crout

        .include    "macros.inc"
        .include    "ser_settings.inc"

IDBYTE1 := $fbb3
IDBYTE2 := $fb1e
IDBYTE3 := $fbc0
IDBYTE4 := $fbbe
PUTCHECK_IIC := $10
PUTCHECK_IIE := $50
GETCHECK_IIC := $08
GETCHECK_IIE := $68
;
; ser_settings: identify machine type and set communication routine address 
;               etc. and ssc slot number.
;
.proc ser_settings
		mwa		#sscinit, init_addr
		mwa		#sscput, put_addr
		mwa		#sscget, get_addr

		jsr		a2f_identify
		cmp		#TYPE_IIGS
		beq		set_iigs
		cmp		#TYPE_IIE
		beq		set_iie
		cmp		#TYPE_IIC
		beq		set_iic
									; other machine, set IIe
set_iie:
		jsr		findssc
		bne		:+
		sta		sscslot					; not found ssc
		jmp		exit
:
		asl
		asl
		asl
		asl
; 		lda	#$20
		sta		sscslot
		lda		#PUTCHECK_IIE
		sta		put_mask
		lda		#GETCHECK_IIE
		sta		get_mask
		jmp		exit
set_iigs:
		lda		#$20
		sta		sscslot
		mwa		#zccinit, init_addr
		mwa		#zccput, put_addr
		mwa		#zccget, get_addr
		jmp		exit
set_iic:
		lda		#$20
		sta		sscslot
		lda		#PUTCHECK_IIC
		sta		put_mask
		lda		#GETCHECK_IIC
		sta		get_mask
exit:
		lda		sscslot
		rts
.endproc
