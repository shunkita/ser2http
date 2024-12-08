	.autoimport	on
	.debuginfo	off
	.importzp	ptr1
	.macpack	longbranch

	.export		_recv_response
	.export		_ser_error
	.export		_dlen
	.export		_recv_status

	.import		ser_get


_ser_error:
	.byte	$00
ch:			
	.byte	$00
; recv buffer address
buf:
	.res	2
datalen:
_dlen:
	.word	$00,$00
recvcnt:
	.word	$00,$00
_recv_status:	.res	1

; ---------------------------------------------------------------
; char __near__ recv_response (char *buf)
; input: data buffer pointer 
; discard first 3bytes
; [0]=id [1,2]=len 
; return: 
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_recv_response: near
	sta		buf
	stx		buf+1
	jmp		recv_res


recv_res:
	lda		#<ch
	sta		ptr1
	lda		#>ch
	sta		ptr1+1
;						 recv header
:
	jsr     ser_get
	bcs		:-			; no data try again
	cmp		#$02		; ID BYTE ?
	beq		:+			; OK next
	jmp		err_exit1	; no, invalid data,  exit
:
	jsr     ser_get		
	bcc		:+			; OK next        
	jmp		err_exit0	; no data error
:
	sta		datalen		; save lo-byte
						;
	jsr     ser_get
	bcc		:+			; OK next        
	jmp		err_exit0	; no data error
:
	sta		datalen+1	; save high-byte
						;

;	jsr     ser_get		; body   ???
;	bcc		:+			; OK next        
;	jmp		err_exit0	; no data error
;:
;	sta		_recv_status
	
;	recv payload
;
	lda		#0			; reset receive counter
	sta		recvcnt+1
;	lda		#2
;	sta		recvcnt		; already receive sequence number and command code
	sta		recvcnt		; zero
;
	lda		buf
	sta		ptr1
	lda		buf+1
	sta		ptr1+1
;
recv_loop:
	lda		recvcnt
	cmp		datalen
	beq		:+
	bne		recv_next	; not equal receive next data
	brk
:
	lda		recvcnt+1
	cmp		datalen+1
	beq		done		; all received, exit
recv_next:
	jsr		ser_get
	bcc		:+			; OK next        
	jmp		err_exit0	; no data error
:
	ldy		#$00
	sta		(ptr1),y
	inc		ptr1		; advance ptr1
	bne		inc_counter
	inc		ptr1+1
inc_counter:
	inc		recvcnt
	bne		recv_loop	; non zero check for length
	inc		recvcnt+1
	bne		recv_loop
	brk					; not here (high byte = 0)
len_check:
	lda		recvcnt
	cmp		datalen
	beq		next_check
	bne		next_loop	; not equal
	brk
next_check:
	lda		recvcnt+1
	cmp		datalen+1
	beq		done
next_loop:
	brk		; never !
done:
	lda		#0			
 
	rts
;
err_exit4:				; payload could not receive		-4
	sta		_ser_error
	ldx		#$ff
	lda		#$fc
	rts

err_exit0:				; no data  error
	sta		_ser_error
	ldx		#$ff
	lda		#$ff
	rts
err_exit5:				; sequence error
	sta		_ser_error
	ldx		#$ff
	lda		#$f0
	rts
err_exit1:				; id invalid 
	ldx		#$ff
	lda		#$ff
	rts
err_exit2:				; low byte could not receive -2
	sta		_ser_error
	ldx		#$ff
	lda		#$fe
	rts
err_exit3:				; high byte could not receive -3
	sta		_ser_error
	ldx		#$ff
	lda		#$fd
	rts
.endproc
