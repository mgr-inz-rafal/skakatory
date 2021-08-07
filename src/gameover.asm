PAINT_GAME_OVER
            jsr CLEAR_SPRITE_DATA
            rts

CLEAR_SPRITE_DATA
            ldy #0
            mwa #PMG_M0 XTMP
CSD_0       lda #0
            sta (XTMP),y
            adw XTMP #1
            lda XTMP+1
            cmp #>PMG_END
            bne CSD_0
            rts