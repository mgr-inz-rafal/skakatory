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
            jeq PT%%1_INVUL
            cmp #PS_JUMP
            bne PT%%1_1
            JUMP_PLAYER_TICK %%1
            jmp PT%%1_INVUL
PT%%1_1     cmp #PS_DYING
            bne PT%%1_X
            DYING_PLAYER_TICK %%1
            jmp PT%%1_X
PT%%1_INVUL lda P%%1_INVUL
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

.macro JUMP_PLAYER_TICK P12
            dec JUMP_COUNTER_%%1
            bne JT%%1_X    ; Do not advance yet
            lda #JUMP_FRAME_ADVANCE
            sta JUMP_COUNTER_%%1
            jsr CLEAR_PLAYERS
            inc P%%1_Y
            jsr PAINT_PLAYERS
            lda P%%1_Y
            cmp #JUMP_FRAME_COUNT/2
            bne JT%%1_2
            ; We're just started to go down, it's too late to interrupt the jump
            lda #1
            sta JUMP_INTERRUPTED_%%1
JT%%1_2     lda P%%1_Y
            sec
            sbc #JUMP_FRAME_COUNT/4
            bcc JT%%1_1    ; Do not allow to interrupt the jump yet
            INTERRUPT_JUMP %%1
JT%%1_1     lda P%%1_Y
            cmp #JUMP_FRAME_COUNT-1
            bne JT%%1_X
            ; Finish the jump
            lda #PS_IDLE
            sta P%%1_STATE
            lda #0
            sta P%%1_Y
JT%%1_X 
.endm

.macro INTERRUPT_JUMP P12
            .if :1 = 1
                lda STRIG0
            .endif
            .if :1 = 2
                lda STRIG1
            .endif
            beq IJ%%1_X ; Button still pressed, do not interrupt
            lda JUMP_INTERRUPTED_%%1
            bne IJ%%1_X ; This jump has already been interrupted
            lda #JUMP_FRAME_COUNT-1
            sec
            sbc P%%1_Y
            sta P%%1_Y
            lda #1
            sta JUMP_INTERRUPTED_%%1
IJ%%1_X     
.endm

.macro DYING_PLAYER_TICK P12
            .if :1 = 1
                dec DYING_JUMP_COUNTER
            .endif
            .if :1 = 2
                dec DYING_JUMP_COUNTER_RIGHT
            .endif
            bne DT%%1_X
            .if :1 = 1
                jsr INIT_DYING_COOLDOWN
            .endif
            .if :1 = 2
                jsr INIT_DYING_COOLDOWN_RIGHT
            .endif
            ldy DYING_POS_X_P%%1
            lda (P%%1_X_TABLE),y
            cmp #$ff
            beq DT%%1_0
            .if :1 = 1
                jsr CLEAR_PLAYER_LEFT
            .endif
            .if :1 = 2
                jsr CLEAR_PLAYER_RIGHT
            .endif
            inc P%%1_Y
            ldy DYING_POS_X_P%%1
            lda (P%%1_X_TABLE),y
            inc DYING_POS_X_P%%1
            .if :1 = 1
                sta HPOSP0
                sta HPOSP1
            .endif
            .if :1 = 2
                sta HPOSP2
                sta HPOSP3
            .endif
            jsr PAINT_PLAYERS
            jmp DT%%1_X
DT%%1_0     lda #0
            .if :1 = 1
                sta HPOSP0
                sta HPOSP1
            .endif
            .if :1 = 2
                sta HPOSP2
                sta HPOSP3
            .endif
            .if :1 = 1
                jsr CLEAR_PLAYER_LEFT
            .endif
            .if :1 = 2
                jsr CLEAR_PLAYER_RIGHT
            .endif
            lda #PS_BURIED
            sta P%%1_STATE
DT%%1_X     
.endm