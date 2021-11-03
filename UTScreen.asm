; ===========================================================================
; ---------------------------------------------------------------------------
; SSRG Splash Screen
; ---------------------------------------------------------------------------

SSRGScreen:
		moveq	#$FFFFFFE4,d0				; set music ID to "stop music"
		jsr	PlaySound_Special			; play ID
		jsr	ClearPLC				; clear pattern load cues list
		jsr	Pal_FadeFrom				; fade palettes out
		jsr	ClearScreen				; clear the plane mappings
		lea	($FFFFD000).w,a1			; load object ram address to a1
		moveq	#$00,d0					; clear d0
		move.w	#$01FF,d1				; set repeat times

SRG_ClearObjects:
		cmpi.b	#6,($FFFFFE57).w ; do you have all 6 emeralds?
		beq.w	HiddenScreen	; if yes, branch
		move.l	d0,(a1)+
		dbf	d1,SRG_ClearObjects ; fill object RAM ($D000-$EFFF) with	$0

		move.l	#$40000000,($C00004).l
		lea	(Nem_UTScreen).l,a0 ; load Japanese credits
		bsr.w	NemDec
;		move.l	#$54C00000,($C00004).l
;		lea	(Nem_CreditText).l,a0 ;	load alphabet
;		bsr.w	NemDec
		lea	($FF0000).l,a1
		lea	(Eni_UTScreen).l,a0 ; load mappings for	Japanese credits
		move.w	#0,d0
		bsr.w	EniDec
		lea	($FF0000).l,a1
		move.l	#$40000003,d0
		moveq	#$27,d1
		moveq	#$1B,d2
		bsr.w	ShowVDPGraphics
		lea	($FFFFFB80).w,a1
		moveq	#0,d0
		move.w	#$1F,d1

TitlePee_ClrPallet:
		move.l	d0,(a1)+
		dbf	d1,TitlePee_ClrPallet ; fill pallet with 0	(black)

		moveq	#3,d0		; load Sonic's pallet
		bsr.w	PalLoad1
;		move.b	#$8A,($FFFFD080).w ; load "SONIC TEAM PRESENTS"	object
;		jsr	ObjectsLoad
;		jsr	BuildSprites
		jsr	Pal_FadeTo				; fade palettes in
		moveq	#$00,d0					; clear d0
		move.l	d0,($FFFF7800).l			; reset SSRG timer/flags
		move.l	d0,($FFFF7804).l			; ''
		move.l	d0,($FFFF7808).l			; ''

; ---------------------------------------------------------------------------
; SSRG Splash Screen main loop
; ---------------------------------------------------------------------------

;SSRGScreen_Loop:
;		move.b	#$04,($FFFFF62A).w			; set V-Blank routine to run
;		jsr	DelayProgram				; hult til V-Blank begins
;		addq.w	#$01,($FFFF7800).l			; increase timer
;		lea	($FFFFD000).w,a0			; load "S" object ram
;		bsr	ObjectLetters				; run "S"
;		lea	$40(a0),a0				; load "S" object ram
;		bsr	ObjectLetters				; run "S"
;		lea	$40(a0),a0				; load "R" object ram
;		bsr	ObjectLetters				; run "R"
;		lea	$40(a0),a0				; load "G" object ram
;		bsr	ObjectLetters				; run "G"
;		lea	$40(a0),a0				; load Square object ram
;		bsr	ObjectSquare				; run Square
;		lea	($FFFFD140).w,a0			; load Neon Sonic object ram
;		bsr	ObjectSonicNeon				; run Neon Sonic
;		bsr	SRG_ScrollFG				; scroll the FG plane correctly
;		bsr	SRG_DrawFG				; draw the FG plane correctly
;		jsr	BuildSprites				; present all object sprites on screen
;		tst.b	($FFFFF605).w				; has player 1 pressed start button?
;		bmi	SSRGScreen_Finish			; if so, branch
;		cmpi.w	#$0200,($FFFF7800).l			; has timer finished?
;		blt	SSRGScreen_Loop				; if not, loop
SuperMegaPoo:
;		moveq   #$FFFFFF9A,d0
;		bsr.w	PlaySample ; play "SEGA"	sound
		move.b	#$14,($FFFFF62A).w
		bsr.w	DelayProgram
		move.w	#$6C,($FFFFF614).w

SSRG_WaitEnd:
		move.b	#2,($FFFFF62A).w
		bsr.w	DelayProgram
		tst.w	($FFFFF614).w
		beq.s	SSRGScreen_Finish
		andi.b	#$80,($FFFFF605).w ; is	Start button pressed?
		beq.s	SSRG_WaitEnd	; if not, branch

SSRGScreen_Finish:
		clr.b	($FFFFFFF9).w	; clear multiple character flag
		move.b	#$04,($FFFFF600).w			; set the screen mode to Title Screen
		rts						; return
; ===========================================================================
HiddenScreen:
		move.l	d0,(a1)+
		dbf	d1,HiddenScreen ; fill object RAM ($D000-$EFFF) with	$0

		move.l	#$40000000,($C00004).l
		lea	(Nem_HiddenScreen).l,a0 ; load Japanese credits
		bsr.w	NemDec
;		move.l	#$54C00000,($C00004).l
;		lea	(Nem_CreditText).l,a0 ;	load alphabet
;		bsr.w	NemDec
		lea	($FF0000).l,a1
		lea	(Eni_HiddenScreen).l,a0 ; load mappings for	Japanese credits
		move.w	#0,d0
		bsr.w	EniDec
		lea	($FF0000).l,a1
		move.l	#$40000003,d0
		moveq	#$27,d1
		moveq	#$1B,d2
		bsr.w	ShowVDPGraphics
		lea	($FFFFFB80).w,a1
		moveq	#0,d0
		move.w	#$1F,d1
		jmp	TitlePee_ClrPallet