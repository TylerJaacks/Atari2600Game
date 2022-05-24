        PROCESSOR 6502

        INCLUDE "vcs.h"
        INCLUDE "macros.h"

; ----------------------------------------
; Constants
; ----------------------------------------
        SCREEN_SIZE = 192

        ; Size = Size * 2
        COURT_SIZE  = 182

; ----------------------------------------
; Variables
; ----------------------------------------
        SEG.U VARIABLES
        ORG $80

        ; Player 0 position.
        p0_x ds 1
        p0_y ds 1

        ; Player 1 position.
        p1_x ds 1
        p1_y ds 1

        ; Player 0 draw area.
        p0_draw ds 1

        ; Player 1 draw area.
        p1_draw ds 1

        ; Player 0 pointer.
        p0_ptr ds.w 1
        p1_ptr ds.w 1

; ----------------------------------------
; Code
; ----------------------------------------
        SEG CODE
        ORG $F000

; ----------------------------------------
; Moves the Sprite to a given location.
; ----------------------------------------
; A = Destination
; X = Sprite
; ----------------------------------------
PositionObject:
        sec
        sta WSYNC

DivideLoop:
        sbc #15
        bcs DivideLoop

        eor #7
        asl
        asl
        asl
        asl
        
        sta.wx HMP0,X
        sta RESP0,X
        ; rts

; ----------------------------------------
; Reset
; ----------------------------------------
Reset:
        ldx #$40
        stx COLUBK


; ----------------------------------------
; Start of NTSC Frame
; ----------------------------------------
StartOfFrame:
        lda #0
        sta VBLANK

        lda #2
        sta VSYNC

; ----------------------------------------
; Vertical Sync
; ----------------------------------------
        ldy #3

VerticalSync:
        sta WSYNC
        dey
        bne VerticalSync

        lda #0
        sta VSYNC

; ----------------------------------------
; Vertical Blank
; ----------------------------------------
        ldy #36

VerticalBlank:        
        sta WSYNC
        dey
        bne VerticalBlank

        ; Player 0 Draw Data
        lda #(COURT_SIZE + PLAYER_HEIGHT)
        sec
        sbc p0_y
        sta p0_draw
        ; Player 0 Pointer
        lda #<(PLAYER_SPRTTE + PLAYER_HEIGHT - 1)
        sec
        sbc p0_y
        sta p0_ptr
        lda #>(PLAYER_SPRTTE + PLAYER_HEIGHT - 1)
        sbc #0
        sta p0_ptr + 1
        ; Player 1 Draw Data
        lda #(COURT_SIZE + PLAYER_HEIGHT)
        sec
        sbc p1_y+1
        sta p1_draw
        ; Player 1 Pointer
        lda #<(PLAYER_SPRTTE + PLAYER_HEIGHT - 1)
        sec
        sbc p1_y_1 + 1
        sta p1_ptr
        lda #>(PLAYER_SPRTTE + PLAYER_HEIGHT - 1)
        sbc #0
        sta p1_ptr + 1

        sta WSYNC

; ----------------------------------------
; Court
;
; 192 scanlines of Picture
; ----------------------------------------
        ldy #COURT_SIZE
Court:
        dey
        STA WSYNC
        bne Court

        lda #%01000010
        ; End of Screen, now entering blanking.
        sta VBLANK


; ----------------------------------------
; Overscan
; ----------------------------------------
        ldy #SCREEN_SIZE
Overscan:
        sta WSYNC
        dey
        bne Overscan 



        jmp StartOfFrame

        ORG $FFFA

PLAYER_SPRTTE:
        .byte %11111111
        .byte %11000011
        .byte %11000011
        .byte %11000011
        .byte %11111111

PLAYER_HEIGHT = * - PLAYER_SPRTTE
        
        ; NMI vector.
        .word Reset 
        ; RESET vector.
        .word Reset
        ; IRQ vector.
        .word Reset

        END