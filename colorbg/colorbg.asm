	processor 6502		; Target Atari 2600 -- 6502 processor
	
	include "vcs.h"		; Memory Address mapped to labels for convenience
	include "macro.h"	; Macros for convencience
	include "common.h"	; My custom macros

	SEG.U Variables
	org $80
FRC 	ds 1	; Frame Counter
UPC 	ds 1	; Background Update Counter
BGV 	ds 1	; Background Value
PFV 	ds 1	; Playfield Value
BGO 	ds 1	; Background Scanline Offset
PFO 	ds 1	; Playfield Scanline Offset

	seg code			; initialization segment
	org $F000			; rom origin
	
START:

	CLEAN_START			; Clear Memory macro
	ldy #4
	sty UPC
	
FrameStart:
	
	NTSC_START			; Ready to draw frame
	
	ldy UPC
	dey
	sty UPC
	
	bne Decoy
	ldy #4
	sty UPC
	ldy BGV
	iny
	sty BGV
	ldy PFV
	dey
	sty PFV
	jmp Run
Decoy:
	REPEAT 8
	nop
	REPEND
	jmp Run
Run:
	
	
	; Rainbow Reset
	
	
	;ldy #0
	;sty BGO
	;sty PFO
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Drawing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	
	;ldx #$80			; write background color into register x
	;sty COLUBK			; store background color into TIA buffer
	
	; Playfield Settings
	;lda #$0E			; store color into acc
	;sta COLUPF			; write acc into playfield color
	lda #%00000001		; store value into acc
	sta CTRLPF			; write Acc into playfield Settings
	
	lda #0
	ldx #0
	stx PF0
	stx PF1
	stx PF2
	REPEAT 7
		
		ldy BGV,BGO
		sty COLUBK
		ldy BGO
		iny
		sty BGO
		
		ldy PFV,PFO
		sty COLUPF
		ldy PFO
		dey
		sty PFO
		
		lda #0
		sta WSYNC		
	REPEND
	
	ldx #%11100000
	stx PF0
	ldx #%11111111
	stx PF1
	stx PF2
	
	REPEAT 7
		lda #0
		sta WSYNC
	REPEND
	
	ldx #%01100000
	stx PF0
	ldx #0
	stx PF1
	ldx #%01100000
	stx PF2
	REPEAT 164
		lda #0
		sta WSYNC
	REPEND
	
	ldx #%11100000
	stx PF0
	ldx #%11111111
	stx PF1
	stx PF2
	REPEAT 7
		lda #0
		sta WSYNC
	REPEND
	
	lda #0
	ldx #0
	stx PF0
	stx PF1
	stx PF2
	REPEAT 7
		sta WSYNC
	REPEND
	
	NTSC_END
	
	jmp FrameStart		; go back to the beginning of the frame
	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill ROM size to exactly 4kb
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	org $FFFC			; Jump to reset pointer
	.word START			; add word (byte) to reset vector
	.word START			; add garbage to complete $FFFF (unused but necessary)