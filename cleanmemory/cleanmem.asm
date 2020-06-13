	processor 6502
	seg code
	org $F000		; define the code originat $F000

Start:
	sei				; disable interrupts
	cld				; clear the decimal mode or disable the BCD math mode
	ldx #$FF		; loads X register with $FF
	txs				; transfer the X register to stack pointer
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clear the Zero Rage region ($00 to $FF)
; Meaning the entire TIA register space and also RAM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	lda #0			; Acc = 0
	ldx #$FF		; X = $FF
	sta $FF			; Store 0 into address $FF
MemLoop:
	dex				; X--
	sta $0,X		; Store A into address $0+X
	bne MemLoop		; GoTo MemLoop if zFlag != 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	org $FFFC
	.word Start		; reset vector at $FFFC (where program starts)
	.word Start		; interrupt vector at $FFFE (unused)