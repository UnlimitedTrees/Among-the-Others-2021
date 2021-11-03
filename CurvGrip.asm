; =========================================================================================

; ============ THE CODE BELOW WAS DONE BY STEALTH!!! HE IS AWESOME ========================

; ===========================================================================
; ---------------------------------------------------------------------------
; CurveGrip - While colliding with player, flags player to use "fine collision"
;             to better "trace" the path, and limits max speed to prevent the
;             player from overshooting the hotspot transition area without
;             obtaining a new angle and falling off
; ---------------------------------------------------------------------------

CurveGrip:	; object 8D
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	CurveGrip_Index(pc,d0.w),d1
		jmp	CurveGrip_Index(pc,d1.w)
; ===========================================================================
CurveGrip_Index:
		dc.w CurveGrip_Main-CurveGrip_Index
		dc.w CurveGrip_Action-CurveGrip_Index
; ===========================================================================
CurveGrip_Sizes:
		dc.b	$20
		dc.b	$30
		dc.b	$40
		dc.b	$50
; ===========================================================================
CurveGrip_Main:

		addq.b	#2,$24(a0)
		move.b	$28(a0),d0
		move.b	CurveGrip_Sizes(pc,d0.w),$38(a0)

CurveGrip_Action:
		moveq	#0,d2
		move.b	$38(a0),d2
		move.w	d2,d3
		add.w	d3,d3
		lea	($FFFFD000).w,a1		;Handle Sonic first
		bsr	CurveGrip_MovePlayer	;Test for collision and speed, cap speed and set flags
		bra.w	CurveGrip_ChkDel

CurveGrip_MovePlayer:
		move.w	8(a1),d0
		sub.w	$8(a0),d0
		add.w	d2,d0
		cmp.w	d3,d0
		bcc.s	CurveGrip_CheckNegativeVel_Return
		move.w	$C(a1),d1
		sub.w	$C(a0),d1
		add.w	d2,d1
		cmp.w	d3,d1
		bcc.s	CurveGrip_CheckNegativeVel_Return

		move.b	#1,$23(a1)

		move.w	$14(a1),d0
		bpl.s	CurveGrip_CheckPositiveVel

		cmpi.w	#-$1200,d0
		bge.s	CurveGrip_CheckNegativeVel_Return
		move.w	#-$1200,$14(a1)

CurveGrip_CheckNegativeVel_Return:
		rts
; ===========================================================================

CurveGrip_CheckPositiveVel:
		cmpi.w	#$1200,d0
		ble.s	CurveGrip_CheckPositiveVel_Return
		move.w	#$1200,$14(a1)

CurveGrip_CheckPositiveVel_Return:
		rts
; ===========================================================================

CurveGrip_ChkDel:
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	CurveGrip_Delete
		rts
; ===========================================================================

CurveGrip_Delete:
		jmp	DeleteObject
; ===========================================================================

; ============ THE CODE ABOVE WAS DONE BY STEALTH!!! HE IS AWESOME ========================

; ==============================================================================