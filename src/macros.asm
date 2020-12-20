.macro DISABLE_PLAYER_INVUL P12
            lda P%%1_STATE
            cmp #PS_DYING
            beq DI%%1_X
            lda P%%1_STATE
            cmp #PS_BURIED
            beq DI%%1_X
            lda #0
            sta P%%1_INVUL
            lda #P%%1_X_POSITION
            .if :1 = 1
                sta HPOSP0
                sta HPOSP1
            .endif
            .if :1 = 2
                sta HPOSP2
                sta HPOSP3
            .endif
DI%%1_X     
.endm

.macro ADVANCE_PLAYER_SCORES P12
            lda P%%1_INVUL
            bne AS%%1_2
            lda P%%1_STATE
            cmp #PS_BURIED
            beq AS%%1_X
            cmp #PS_DYING
            beq AS%%1_X
            sed
            lda P%%1_SCORE
            clc
            adc #1
            sta P%%1_SCORE
            cld
            cmp #0
            beq AS%%1_1
            jmp AS%%1_X
AS%%1_1     sed
            clc
            lda P%%1_SCORE_H
            adc #1
            sta P%%1_SCORE_H
            jmp AS%%1_X
AS%%1_2     dec P%%1_INVUL_DISABLE_COUNTER
            bne AS%%1_X
            .if :1 = 2
                jsr DISABLE_INVUL
            .endif
AS%%1_X
.endm

.macro PLAYER_PLAYER_TICK P12
            lda P%%1_STATE
            cmp #PS_IDLE
            beq PT_INVUL
            cmp #PS_JUMP
            bne PT%%1_1
            .if :1 = 1
                jsr JUMP_TICK
            .endif
            .if :1 = 2
                jsr JUMP_TICK_RIGHT ; TODO: Fix
            .endif
            jmp PT_INVUL
PT%%1_1     cmp #PS_DYING
            bne PT%%1_X
            .if :1 = 1
                jsr DYING_TICK
            .endif
            .if :1 = 2
                jsr DYING_TICK_RIGHT ; TODO: Fix
            .endif
            jmp PT%%1_X
PT_INVUL    lda P%%1_INVUL
            beq PT%%1_X
            dec P%%1_INVUL_COUNTER
            bne PT%%1_X
            lda #INVUL_COOLDOWN
            sta P%%1_INVUL_COUNTER
            lda P%%1_INVUL
            beq PT%%1_X
            lda P%%1_VISIBLE
            beq PT%%1_2
            dec P%%1_VISIBLE
            lda #$ff
            .if :1 = 1
                sta HPOSP0
                sta HPOSP1
            .endif
            .if :1 = 2
                sta HPOSP2
                sta HPOSP3
            .endif
            jmp PT%%1_X
PT%%1_2        inc P%%1_VISIBLE
            lda #P%%1_X_POSITION
            .if :1 = 1
                sta HPOSP0
                sta HPOSP1
            .endif
            .if :1 = 2
                sta HPOSP2
                sta HPOSP3
            .endif
PT%%1_X
.endm