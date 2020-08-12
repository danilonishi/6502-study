	processor 6502		; Target Atari 2600 -- 6502 processor
	
	include "vcs.h"		; Memory Address mapped to labels for convenience
	include "macro.h"	; Macros for convencience
	include "common.h"	; My custom macros

; Ram Segment
	seg.u Variables
	org $80
P0Height	byte		; Player Sprite Height
PlayerYPos	byte		; byte PlayerYPos;
PlayerXPos	byte		; byte PlayerXPos;
Direction	equ	0		;
Speed		equ 1		; Y Movement Speed

; Rom Segment
	seg code			; initialization segment
	org $F000			; rom origin
	
Reset:
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Variable Setup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	ldx #$00			; Black
	stx COLUBK			; Black Background
	
	lda #180			; 180
	sta PlayerYPos		; PlayerYPos = 180
	
	lda #50				; 50
	sta PlayerXPos		; PlayerXPos = 50
	
	lda #9				; 9
	sta P0Height		; P0Height = 9
	
;===================================================
	
StartFrame:
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; NTSC VBLANK START
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Initialize frame by storing 0010 into VBLANK and VSYNC to address frame initialization
	lda #2
	sta VBLANK
	sta VSYNC
	; 3 scanlines of frame initialization required
	REPEAT 3
		sta WSYNC
	REPEND
	lda #0
	sta VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Player X Position
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	lda PlayerXPos		; Load x position into accumulator
	and #%01111111		; Forces always positive
	
	sta WSYNC			; strobe scanline
	sta HMCLR			; Clear horizontal values
	
	sec					; Set carry flag before substraction
DivideLoop:
	sbc #15				; Subtract 15 (frame count)
	bcs DivideLoop		; Loop while > 0
	
	eor #7				; XOR to get remainder between -8 and 7, result in acc
	REPEAT 4			; Left-Shift bits 4 times because the
		asl				; TIA reads the first 4 bits to adjust the offset
	REPEND
	
	sta HMP0			; Set fine position
	sta RESP0			; Strobe 15-step approximate position
	sta WSYNC			; wait
	sta HMOVE			; write the fine position offset
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; NTSC VBLANK END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; 37 scanlines of VBLANK to prepare for drawing
	REPEAT 37
		sta WSYNC
	REPEND
	lda #0
	sta VBLANK

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Game Code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	ldx #192
Scanline:

	txa					; transfer x to a
	sec					; set carry flag (always set before subtraction)
	sbc PlayerYPos		; Subtract sprite y coordinate from the acc (sbc = subtract with carry)
	cmp P0Height		; compare acc with player height
	bcc LoadBitmap		; if in bounds, draw apple (bcc = branch if carry is clear)
	lda #0				; otherwise set acc to 0

LoadBitmap:
	
	tay					; transfer acc to y
	lda P0Bitmap,Y		; load bitmap slice
	sta GRP0			; set player 0 graphics
	
	lda P0Color,Y		; load color from lookup table
	sta COLUP0			; write into color buffer
	
	
	
	sta WSYNC			;
	
	dex
	bne Scanline
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; NTSC Overscan
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	lda #2
	sta VBLANK		; Insert one VBLANK
	
	dec PlayerXPos,X
	dec PlayerYPos,X
	
	

	REPEAT 30		
		sta WSYNC	; 30 scanlines at the end
	REPEND
				
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; After Frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	bcc	ResetYPos
	jmp StartFrame
ResetYPos:
	lda #192
	sta PlayerYPos
	
	jmp StartFrame		; go back to the beginning of the frame
	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Look-up Tables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Upside-down apple
P0Bitmap:
	byte #%00000000		; this transparent line is to deactivate the bitmap
	byte #%00101000
	byte #%01110100
	byte #%11111010
	byte #%11111010
	byte #%11111010
	byte #%11111110
	byte #%01101100
	byte #%00110000
	
P0Color:
	byte #$00
	byte #$40
	byte #$40
	byte #$40
	byte #$40
	byte #$42
	byte #$42
	byte #$44
	byte #$D2


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill ROM size to exactly 4kb
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	org $FFFC			; Jump to reset pointer
	.word Reset			; add word (byte) to reset vector
	.word Reset			; add garbage to complete $FFFF (unused but necessary)