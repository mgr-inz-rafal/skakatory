FIRST_CHAR_XPOS     equ 256/2-5*8-1

ENTER_GAMEOVER
            lda GAME_OVER
            bne EG_1        ; Gameover already entered
            lda #1
            sta GAME_OVER
            lda #0
            sta SIZEP0
            sta SIZEP1
            sta SIZEP2
            sta SIZEP3
            jsr PAINT_GAME_OVER
EG_1        rts

PAINT_GAME_OVER
            jsr CLEAR_SPRITE_DATA
            jsr WRITE_GAMEOVER_LETTERS
            rts

CLEAR_SPRITE_DATA
            ldy #0
            mwa #PMG_S_M0 XTMP
CSD_0       lda #0
            sta (XTMP),y
            adw XTMP #1
            lda XTMP+1
            cmp #>PMG_S_END
            bne CSD_0
            rts

WRITE_GAMEOVER_LETTERS
            ; Sprite 0, letters: "K...E. ..Y"
            ldy #0
WGL_1       lda GAME_OVER_PMG_0,y
            cmp #$ff
            beq WGL_0
            sta PMG_S_P0+30,y
            iny
            jmp WGL_1
WGL_0       ; Sprite 1, letters: ".O...C ..."
            ldy #0
WGL_3       lda GAME_OVER_PMG_1,y
            cmp #$ff
            beq WGL_2
            sta PMG_S_P1+32,y
            iny
            jmp WGL_3
WGL_2       ; Sprite 2, letters: "..N... G.."
            ldy #0
WGL_5       lda GAME_OVER_PMG_2,y
            cmp #$ff
            beq WGL_4
            sta PMG_S_P2+34,y
            iny
            jmp WGL_5
WGL_4       ; Sprite 3, letters: "...I.. .R."
            ldy #0
WGL_7       lda GAME_OVER_PMG_3,y
            cmp #$ff
            beq WGL_6
            sta PMG_S_P3+36,y
            iny
            jmp WGL_7
WGL_6       rts
