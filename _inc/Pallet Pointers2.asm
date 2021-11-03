; ---------------------------------------------------------------------------
; Pallet pointers 2
; ---------------------------------------------------------------------------
	dc.l Pal_SegaBG		; pallet address
	dc.w $FB00		; RAM address
	dc.w $1F		; (pallet length / 2) - 1
	dc.l Pal_Title	; 0
	dc.w $FB00
	dc.w $1F
	dc.l Pal_LevelSel ; 1
	dc.w $FB00
	dc.w $1F
	dc.l Pal_Sonic2 ; 2
	dc.w $FB00
	dc.w 7
	dc.l Pal_GHZ2 ; 3
	dc.w $FB20
	dc.w $17
	dc.l Pal_LZ2 ; 4
	dc.w $FB20
	dc.w $17
	dc.l Pal_MZ2 ; 5
	dc.w $FB20
	dc.w $17
	dc.l Pal_SLZ2 ; 5
	dc.w $FB20
	dc.w $17
	dc.l Pal_SYZ2 ; 6
	dc.w $FB20
	dc.w $17
	dc.l Pal_SBZ1 ; 7
	dc.w $FB20
	dc.w $17
	dc.l Pal_Special ; 8 
	dc.w $FB00
	dc.w $1F
	dc.l Pal_LZWater2 ; 9
	dc.w $FB00
	dc.w $1F
	dc.l Pal_SBZ3 ; A
	dc.w $FB20
	dc.w $17
	dc.l Pal_SBZ3Water ; B
	dc.w $FB00
	dc.w $1F
	dc.l Pal_SBZ2 ; C
	dc.w $FB20
	dc.w $17
	dc.l Pal_LZSonWater2 ; D
	dc.w $FB00
	dc.w 7
	dc.l Pal_SBZ3SonWat ; E
	dc.w $FB00
	dc.w 7
	dc.l Pal_SpeResult ; F
	dc.w $FB00
	dc.w $1F
	dc.l Pal_SpeContinue ; 10
	dc.w $FB00
	dc.w $F
	dc.l Pal_Ending ; 11
	dc.w $FB00
	dc.w $1F
	dc.l Pal_EPZ2
	dc.w $FB20
	dc.w $17
	dc.l Pal_INZ2
	dc.w $FB20
	dc.w $17