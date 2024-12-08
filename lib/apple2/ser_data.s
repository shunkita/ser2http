.export		init_addr
.export		put_addr
.export		get_addr
.export		sscslot

.data
;
sscslot:			.byte	$00			; slot number   $n0
init_addr:			.res	2
put_addr:			.res	2
get_addr:			.res	2
