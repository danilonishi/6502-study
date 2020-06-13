; common.h
; version 0.1, 07/JUNE/2020


; NTSC_START
; Default frame initalization by NTSC standards
			MAC NTSC_START
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
				; 37 scanlines of VBLANK to prepare for drawing
				REPEAT 37
					sta WSYNC
				REPEND
				lda #0
				sta VBLANK
			ENDM
			
; NTSC_END
; Default frame closure by NTSC standards
			MAC NTSC_END
				; Insert one VBLANK
				lda #2
				sta VBLANK
				; 30 scanlines at the end
				REPEAT 30
					sta WSYNC
				REPEND
				
			ENDM