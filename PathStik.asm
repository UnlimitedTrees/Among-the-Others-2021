; -----------------------------------------------------------------------------
; Replace the player's "Speed To Pos" calls for standing and spinning with
; A call to this routine to move across a diagonal line one unit at a time,
; testing and adjusting for path collision all along the way, instead of moving
; directly to the new position and testing/adjusting afterward
; (This method is very slow)
; -----------------------------------------------------------------------------
Sonic_Path_Move:

		tst.b	$23(a0)
		bne	Sonic_Path_Move_UseFineMotion
		jsr	SpeedToPos
		jmp Sonic_AnglePos

Sonic_Path_Move_UseFineMotion:

		move.b	#0,$23(a0)
		jsr		Sonic_FloorPos_GetSide

		moveq.l	#0,d0			; Clear d0
		move.w	$10(a0),d0	; Copy Horizontal velocity
		ext.l		d0				; Sign extend the value to a long
		moveq.l	#0,d1			; Clear d1
		move.w	$12(a0),d1	; Copy Vertical velocity
		ext.l		d1				; Sign extend the value to a long

		move.l	#$80000,d2	; This value represents one pixel unit of movement (load for horizontal)
		move.l	#$80000,d3	; This value represents one pixel unit of movement (load for vertical)
		tst.l		d0				; Test whether horizontal velocity is positive or negative
		bpl		Sonic_Path_Move_PositiveHorizontal
		neg.l		d0				; If negative, make it positive (absolute value)
		neg.l		d2				; And make the accumulator value negative
Sonic_Path_Move_PositiveHorizontal:
		tst.l		d1				; Test whether vertical velocity is positive or negative
		bpl		Sonic_Path_Move_PositiveVertical
		neg.l		d1				; If negative, make it positive (absolute value)
		neg.l		d3				; And make the accumulator value negative
Sonic_Path_Move_PositiveVertical:

		move.l	d0,d4			; Keep a backup of the absolute value of the horizontal velocity
		move.l	d1,d5			; Keep a backup of the absolute value of the vertical velocity
		moveq.l	#0,d6			; Clear the secondary direction accumulator

		cmp.l		d0,d1			; Test whether there is more horizontal velocity than vertical, or more vertical than horizontal
		bcs		Sonic_Path_Move_GoHorizontalPre
		cmpi.l	#$800,d1		
		bcs		Sonic_Path_Move_End_2
		bra		Sonic_Path_Move_GoVertical_2

Sonic_Path_Move_GoVertical:

		movem.l	d0-d6,-(sp)
		jsr	(a5)
		movem.l	(sp)+,d0-d6

		cmpi.l	#$800,d1		; Test if there are still whole pixels left for vertical movement
		bcs		Sonic_Path_Move_End
		
Sonic_Path_Move_GoVertical_2

		add.l		d3,$C(a0)	; Move the player vertically in the appropriate direction by one pixel
		sub.l		#$800,d1		; Subtract one whole pixel from the Y velocity counter

		add.l		d4,d6			; Add the absolute value of X velocity to the accumulator
		cmp.l		d6,d5			; Compare it to the absolute value of Y velocity
		bcs		Sonic_Path_Move_GoVertical	;If the accumulator has not reached the Y velocity value, there is no X movement this pixel. Repeat the loop for remaining Y movement

		add.l		d2,$8(a0)	; Move the player horizontally in the appropriate direction by one pixel
		sub.l		d5,d6			; Subtract absolute value Y velocity from the accumulator, leaving anything above that value in place
		sub.l		#$800,d0		; Subtract one whole pixel from the X velocity counter

		bra		Sonic_Path_Move_GoVertical	;Repeat the loop for remaining Y movement
		
Sonic_Path_Move_GoHorizontalPre:
		cmpi.l	#$800,d1		
		bcs		Sonic_Path_Move_End_2
		bra		Sonic_Path_Move_GoHorizontal_2

Sonic_Path_Move_GoHorizontal:

		movem.l	d0-d6,-(sp)
		jsr	(a5)
		movem.l	(sp)+,d0-d6

		cmpi.l	#$800,d0		; Test if there are still whole pixels left for horizontal movement
		bcs		Sonic_Path_Move_End
		
Sonic_Path_Move_GoHorizontal_2:

		add.l		d2,$8(a0)	; Move the player horizontally in the appropriate direction by one pixel
		sub.l		#$800,d0		; Subtract one whole pixel from the X velocity counter

		add.l		d5,d6			; Add the absolute value of Y velocity to the accumulator
		cmp.l		d6,d4			; Compare it to the absolute value of X velocity
		bcs		Sonic_Path_Move_GoHorizontal	;If the accumulator has not reached the X velocity value, there is no Y movement this pixel. Repeat the loop for remaining X movement

		add.l		d3,$C(a0)	; Move the player vertically in the appropriate direction by one pixel
		sub.l		d4,d6			; Subtract absolute value X velocity from the accumulator, leaving anything above that value in place
		sub.l		#$800,d1		; Subtract one whole pixel from the Y velocity counter

		bra		Sonic_Path_Move_GoHorizontal	;Repeat the loop for remaining X movement

Sonic_Path_Move_End:

		movem.l	d0-d6,-(sp)
		jsr	Sonic_AnglePos	; Obtain the correct angle before the final movement, so Sonic will check for solidity in the right direction in the call below
		movem.l	(sp)+,d0-d6
		
Sonic_Path_Move_End_2:

		lsl.l		#8,d0			; Multiply remaining X velocity by $100
		tst.l		d2				; Test whether horizontal velocity was positive or negative
		bpl		Sonic_Path_Move_End_PositiveHorizontal
		neg.l		d0
Sonic_Path_Move_End_PositiveHorizontal:
		add.l		d0,$8(a0)	; Add to X position
		lsl.l		#8,d1			; Multiply remaining Y velocity by $100
		tst.l		d3				; Test whether vertical velocity was positive or negative
		bpl		Sonic_Path_Move_End_PositiveVertical
		neg.l		d1
Sonic_Path_Move_End_PositiveVertical:
		add.l		d1,$C(a0)	; Add to Y position

		jsr	Sonic_AnglePos

		rts



; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's angle & position as he walks along the floor
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_FloorPos_GetSide:
		btst	#3,$22(a0)								;Check the Ride-on flag
		beq.s	Sonic_FloorPos_GetSide_NotRideOn
		lea	(Sonic_FloorPos_Return).l,a5		;If the player is standing on a sprite rather than the level, don't do height adjustment
		moveq	#0,d0
		move.b	d0,($FFFFF768).w
		move.b	d0,($FFFFF76A).w
Sonic_FloorPos_Return:
		rts

Sonic_FloorPos_GetSide_NotRideOn:
		moveq	#3,d0
		move.b	d0,($FFFFF768).w
		move.b	d0,($FFFFF76A).w
		move.b	$25(a0),d0
		addi.b	#$20,d0
		bpl.s	Sonic_FloorPos_1E286
		move.b	$25(a0),d0
		bpl.s	Sonic_FloorPos_1E280
		subq.b	#1,d0

Sonic_FloorPos_1E280:
		addi.b	#$20,d0
		bra.s	Sonic_FloorPos_1E292
		
; ===========================================================================

Sonic_FloorPos_1E286:
		move.b	$25(a0),d0
		bpl.s	Sonic_FloorPos_1E28E
		addq.b	#1,d0

Sonic_FloorPos_1E28E:
		addi.b	#$1F,d0

Sonic_FloorPos_1E292:
		andi.b	#$C0,d0
		cmpi.b	#$40,d0
		beq.w	Sonic_FloorPos_SetWalkVertL
		cmpi.b	#$80,d0
		beq.w	Sonic_FloorPos_SetWalkCeiling
		cmpi.b	#$C0,d0
		beq.w	Sonic_FloorPos_SetWalkVertR
		lea	(Sonic_StickyWalkFloor).l,a5
		rts
Sonic_FloorPos_SetWalkVertL
		lea	(Sonic_StickyWalkVertL).l,a5
		rts
Sonic_FloorPos_SetWalkCeiling:
		lea	(Sonic_StickyWalkCeiling).l,a5
		rts
Sonic_FloorPos_SetWalkVertR:
		lea	(Sonic_StickyWalkVertR).l,a5
		rts

Sonic_StickyWalkFloor:
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	$17(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	($FFFFF768).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$0,d5
		move.b	($FFFFFF4A).w,d5
		jsr		FindFloor
		move.w	d1,-(sp)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	$17(a0),d0
		ext.w	d0
		neg.w	d0
		add.w	d0,d3
		lea	($FFFFF76A).w,a4
		jsr		FindFloor
		move.w	(sp)+,d0
		bsr.w	Sonic_StickyAngle
		tst.w	d1
		beq.s	StickyLocret_146BE
		bpl.s	StickyLoc_146C0
		cmpi.w	#-$E,d1
		blt.s	StickyLocret_146E6
		add.w	d1,$C(a0)

StickyLocret_146BE:
		rts
; ===========================================================================

StickyLoc_146C0:
		cmpi.w	#$E,d1
		bgt.s	StickyLoc_146CC

StickyLoc_146C6:
		add.w	d1,$C(a0)
		rts
; ===========================================================================

StickyLoc_146CC:
		tst.b	$38(a0)
		bne.s	StickyLoc_146C6
		bset	#1,$22(a0)
		bclr	#5,$22(a0)
		move.b	#1,$1D(a0)
		rts
; ===========================================================================

StickyLocret_146E6:
		rts
; End of function Sonic_AnglePos

; ===========================================================================
		move.l	8(a0),d2
		move.w	$10(a0),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d2
		move.l	d2,8(a0)
		move.w	#$38,d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d3,$C(a0)
		rts
; ===========================================================================

StickyLocret_1470A:
		rts
; ===========================================================================
		move.l	$C(a0),d3
		move.w	$12(a0),d0
		subi.w	#$38,d0
		move.w	d0,$12(a0)
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d3,$C(a0)
		rts
		rts
; ===========================================================================
		move.l	8(a0),d2
		move.l	$C(a0),d3
		move.w	$10(a0),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d2
		move.w	$12(a0),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d2,8(a0)
		move.l	d3,$C(a0)
		rts

; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's angle as he walks along the floor
; ---------------------------------------------------------------------------

Sonic_StickyAngle:				; XREF: Sonic_AnglePos; et al ;New Angle Routine for better path sticking
		cmp.w	d0,d1
		ble.s	StickyLoc_1475E
		move.w	d0,d1

StickyLoc_1475E:
		rts
; End of function Sonic_StickyAngle

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk up a vertical slope/wall to	his right
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_StickyWalkVertR:			; XREF: Sonic_AnglePos
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$17(a0),d0
		ext.w	d0
		neg.w	d0
		add.w	d0,d2
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	($FFFFF768).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$0,d5
		move.b	($FFFFFF4A).w,d5
		jsr		FindWall
		move.w	d1,-(sp)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$17(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	($FFFFF76A).w,a4
		jsr		FindWall
		move.w	(sp)+,d0
		bsr.w	Sonic_StickyAngle
		tst.w	d1
		beq.s	StickyLocret_147F0
		bpl.s	StickyLoc_147F2
		cmpi.w	#-$E,d1
		blt.w	StickyLocret_1470A
		add.w	d1,8(a0)

StickyLocret_147F0:
		rts
; ===========================================================================

StickyLoc_147F2:
		cmpi.w	#$E,d1
		bgt.s	StickyLoc_147FE

StickyLoc_147F8:
		add.w	d1,8(a0)
		rts
; ===========================================================================

StickyLoc_147FE:
		tst.b	$38(a0)
		bne.s	StickyLoc_147F8
		bset	#1,$22(a0)
		bclr	#5,$22(a0)
		move.b	#1,$1D(a0)
		rts
; End of function Sonic_StickyWalkVertR

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk upside-down
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_StickyWalkCeiling:			; XREF: Sonic_AnglePos
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	$17(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	($FFFFF768).w,a4
		movea.w	#-$10,a3
		move.w	#$1000,d6
		moveq	#$0,d5
		move.b	($FFFFFF4A).w,d5
		jsr		FindFloor
		move.w	d1,-(sp)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	$17(a0),d0
		ext.w	d0
		sub.w	d0,d3
		lea	($FFFFF76A).w,a4
		jsr		FindFloor
		move.w	(sp)+,d0
		bsr.w	Sonic_StickyAngle
		tst.w	d1
		beq.s	StickyLocret_14892
		bpl.s	StickyLoc_14894
		cmpi.w	#-$E,d1
		blt.w	StickyLocret_146E6
		sub.w	d1,$C(a0)

StickyLocret_14892:
		rts
; ===========================================================================

StickyLoc_14894:
		cmpi.w	#$E,d1
		bgt.s	StickyLoc_148A0

StickyLoc_1489A:
		sub.w	d1,$C(a0)
		rts
; ===========================================================================

StickyLoc_148A0:
		tst.b	$38(a0)
		bne.s	StickyLoc_1489A
		bset	#1,$22(a0)
		bclr	#5,$22(a0)
		move.b	#1,$1D(a0)
		rts
; End of function Sonic_StickyWalkCeiling

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk up a vertical slope/wall to	his left
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_StickyWalkVertL:			; XREF: Sonic_AnglePos
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$17(a0),d0
		ext.w	d0
		sub.w	d0,d2
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	($FFFFF768).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6
		moveq	#$0,d5
		move.b	($FFFFFF4A).w,d5
		jsr		FindWall
		move.w	d1,-(sp)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$17(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	($FFFFF76A).w,a4
		jsr		FindWall
		move.w	(sp)+,d0
		bsr.w	Sonic_StickyAngle
		tst.w	d1
		beq.s	StickyLocret_14934
		bpl.s	StickyLoc_14936
		cmpi.w	#-$E,d1
		blt.w	StickyLocret_1470A
		sub.w	d1,8(a0)

StickyLocret_14934:
		rts
; ===========================================================================

StickyLoc_14936:
		cmpi.w	#$E,d1
		bgt.s	StickyLoc_14942

StickyLoc_1493C:
		sub.w	d1,8(a0)
		rts
; ===========================================================================

StickyLoc_14942:
		tst.b	$38(a0)
		bne.s	StickyLoc_1493C
		bset	#1,$22(a0)
		bclr	#5,$22(a0)
		move.b	#1,$1D(a0)
		rts
; End of function Sonic_StickyWalkVertL
