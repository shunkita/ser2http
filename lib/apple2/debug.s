		.export	prbyte
		.export	crout
		.export	cout
		.export	sbyte
;
.proc prbyte
prbyte:
        bit $c082
        jsr $fdda
        bit $c080
        rts
.endproc

.proc crout
crout:
        bit $c082
        jsr $fd8e
        bit $c080
        rts
.endproc

.proc cout
cout:
        bit $c082
		ora #$80
        jsr $fded
        bit $c080
        rts
.endproc
.data
sbyte:	.res	1
