
; ===============================================================
; Mega PCM Driver Include File
; (c) 2012, Vladikcomper
; ===============================================================

; ---------------------------------------------------------------
; Variables used in DAC table
; ---------------------------------------------------------------

; flags
panLR	= $C0
panL	= $80
panR	= $40
pcm	= 0
dpcm	= 4
loop	= 2
pri	= 1

; ---------------------------------------------------------------
; Macros
; ---------------------------------------------------------------

z80word macro Value
	dc.w	((\Value)&$FF)<<8|((\Value)&$FF00)>>8
	endm

DAC_Entry macro Pitch,Offset,Flags
	dc.b	\Flags			; 00h	- Flags
	dc.b	\Pitch			; 01h	- Pitch
	dc.b	(\Offset>>15)&$FF	; 02h	- Start Bank
	dc.b	(\Offset\_End>>15)&$FF	; 03h	- End Bank
	z80word	(\Offset)|$8000		; 04h	- Start Offset (in Start bank)
	z80word	(\Offset\_End-1)|$8000	; 06h	- End Offset (in End bank)
	endm
	
IncludeDAC macro Name,Extension
\Name:
	if strcmp('\extension','wav')
		incbin	'dac/\Name\.\Extension\',$3A
	else
		incbin	'dac/\Name\.\Extension\'
	endc
\Name\_End:
	endm

; ---------------------------------------------------------------
; Driver's code
; ---------------------------------------------------------------

MegaPCM:
	incbin	'MegaPCM.z80'

; ---------------------------------------------------------------
; DAC Samples Table
; ---------------------------------------------------------------

	DAC_Entry	$08, Kick, dpcm			; $81	- Kick
	DAC_Entry	$08, Snare, dpcm		; $82	- Snare
	DAC_Entry	$1B, Timpani, dpcm		; $83	- Timpani
	DAC_Entry	$08, Clap, dpcm		; $84	- Clap
	DAC_Entry	$08, Cymbal, dpcm	; $85	- Cymbal
	DAC_Entry	$08, Ride_Cymbal, dpcm	; $86	- Ride Cymbal
	dc.l	0,0					; $87	- <Free>
	DAC_Entry	$12, Timpani, dpcm		; $88	- Hi-Timpani
	DAC_Entry	$15, Timpani, dpcm		; $89	- Mid-Timpani
	DAC_Entry	$1B, Timpani, dpcm		; $8A	- Mid-Low-Timpani
	DAC_Entry	$1D, Timpani, dpcm		; $8B	- Low-Timpani
	DAC_Entry	$0E, Go, dpcm	; $8C	- GO! Sound
	DAC_Entry	$03, PizzaTime, pcm+pri+loop		; $9F	- Pizza Time
	dc.l	0,0					; $8E	- <Free>
	dc.l	0,0					; $8F	- <Free>
	dc.l	0,0					; $90	- <Free>
	dc.l	0,0					; $91	- <Free>
	dc.l	0,0					; $92	- <Free>
	dc.l	0,0					; $93	- <Free>
	dc.l	0,0					; $94	- <Free>
	dc.l	0,0					; $95	- <Free>
	dc.l	0,0					; $96	- <Free>
	dc.l	0,0					; $97	- <Free>
	dc.l	0,0					; $98	- <Free>
	dc.l	0,0					; $99	- <Free>
	DAC_Entry	$07, PINGAS, pcm+pri	; $9A	- PINGAS
	DAC_Entry   $0B, PEPSIMAN, pcm+pri            ; $9B   - 'Pepsiman' voice (sega sound)
	DAC_Entry	$07, OhNo, pcm+pri            ; $9C	- Hurt sound
	DAC_Entry	$07, wakemeup, pcm+pri+loop          ; $9D - Hidden song (Kids Bop - Bring Me To life)
	DAC_Entry	$07, knuckles, pcm+pri+loop			 ; $9E	- Hidden song (Knuckles from K.N.U.C.K.L.E.S)

MegaPCM_End:

; ---------------------------------------------------------------
; DAC Samples Files
; ---------------------------------------------------------------

	IncludeDAC	Kick, bin
	IncludeDAC	Snare, bin
	IncludeDAC	Timpani, bin
	IncludeDAC	Clap, bin
	IncludeDAC	Cymbal, bin
	IncludeDAC	Ride_Cymbal, bin
	IncludeDAC Go, bin
	IncludeDAC  PEPSIMAN,wav
	IncludeDAC  OhNo,wav
	IncludeDAC	wakemeup,wav
	IncludeDAC	knuckles,wav
	IncludeDAC	PINGAS,wav	
	IncludeDAC	PizzaTime,wav
	even

