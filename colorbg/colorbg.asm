	processor 6502		; Target Atari 2600 -- 6502 processor
	
	include "vcs.h"		; Memory Address mapped to labels for convenience
	include "macro.h"	; Macros for convencience
	include "common.h"	; My custom macros

; Ram Segment
	seg.u Variables
	org $80
; byte P0Height
P0Height ds 1	; 1 byte for p0 height
; byte P1Height
P1Height ds 1	; 1 byte for p0 height

; Rom Segment
	seg code			; initialization segment
	org $F000			; rom origin
	
Reset:

	CLEAN_START			; Clear Memory macro
	
	; P0Height = 10
	; P1Height = 10
	lda #10
	sta P0Height
	sta P1Height
	
	ldx #$80
	stx COLUBK
	
	lda #%1111
	sta COLUPF
	
	lda #$48
	sta COLUP0
	
	lda #$C6
	sta COLUP1
	
	ldy #%00000010		; CTRLPF D1 1 = score
	sty CTRLPF
	
StartFrame:

	NTSC_START			; Ready to draw frame
	; >

VisibleScanlines:

	REPEAT 10
		sta WSYNC
	REPEND
	
; SCOREBOARD
	ldy #0
ScoreBoardLoop:
	lda NumberBitmap,Y
	sta PF1
	sta WSYNC
	iny
	cpy #10
	bne ScoreBoardLoop

	lda #0
	sta PF1
	
	REPEAT 50
		sta WSYNC
	REPEND
	
; PLAYER 0
	ldy #0
Player0Loop:
	lda PlayerBitmap,Y
	sta GRP0
	sta WSYNC
	iny
	cpy P0Height
	bne Player0Loop
	lda #0
	sta GRP0

; PLAYER 1
	ldy #0
Player1Loop:
	lda PlayerBitmap,Y
	sta GRP1
	sta WSYNC
	iny
	cpy P1Height
	bne Player1Loop
	lda #0
	sta GRP1

	; 192 - 90
	REPEAT 102
		sta WSYNC
	REPEND














	; <
	NTSC_END
	
	jmp StartFrame		; go back to the beginning of the frame
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	org $FFE8
PlayerBitmap:
	.byte #%01111110	;  ###### 
	.byte #%11111111	; ########
	.byte #%10011001	; #  ##  #
	.byte #%11111111	; ########
	.byte #%11111111	; ########
	.byte #%11111111	; ########
	.byte #%10111101	; # #### #
	.byte #%11000011	; ##    ##
	.byte #%11111111	; ########
	.byte #%01111110	;  ###### 
	
	org $FFF2
NumberBitmap:
	.byte #%00001110	; ###
	.byte #%00001110	; ###
	.byte #%00000010	;   #
	.byte #%00000010	;   #
	.byte #%00001110	; ###
	.byte #%00001110	; ###
	.byte #%00001000	; #  
	.byte #%00001000	; #  
	.byte #%00001110	; ###
	.byte #%00001110	; ###
	
	; Actually looks like this:
	; ##################
	;             ######
	; ##################
	; ######
	; ##################
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill ROM size to exactly 4kb
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	org $FFFC			; Jump to reset pointer
	.word Reset			; add word (byte) to reset vector
	.word Reset			; add garbage to complete $FFFF (unused but necessary)