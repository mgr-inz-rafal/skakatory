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
            jne PT%%1_X
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
            dec DYING_JUMP_COUNTER_%%1
            jne DT%%1_X
            INIT_DYING_COOLDOWN %%1
            ldy DYING_POS_X_P%%1
            lda (P%%1_X_TABLE),y
            cmp #$ff
            beq DT%%1_0
            CLEAR_PLAYER %%1
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
            CLEAR_PLAYER %%1
            lda #PS_BURIED
            sta P%%1_STATE
DT%%1_X     
.endm

.macro INIT_DYING_COOLDOWN P12
            #if .byte CURRENT_GAME_LEVEL = #0 .or .byte CURRENT_GAME_LEVEL = #1 .or .byte CURRENT_GAME_LEVEL = #2 .or .byte CURRENT_GAME_LEVEL = #4 
                lda #DYING_JUMP_COOLDOWN
                sta DYING_JUMP_COUNTER_%%1
                jmp IDC%%1_X
            #end
            lda #DYING_JUMP_COOLDOWN_FAST
            sta DYING_JUMP_COUNTER_%%1
IDC%%1_X
.endm

.macro CLEAR_PLAYER P12
            ldy P%%1_Y
            lda (P%%1_Y_TABLE),y
            sec
            sbc P%%1_DRAWING_Y_OFFSET
            tay
            ldx #0
@           lda #0
            .if :1 = 1
                sta PMG_P0,y
                sta PMG_P1,y
            .endif
            .if :1 = 2
                sta PMG_P2,y
                sta PMG_P3,y
            .endif
            iny
            inx
            cpx #20
            bne @-
.endm

.macro START_JUMP P12
            lda P%%1_STATE
            cmp #PS_IDLE
            bne SJ%%1_X    ; Only idle can jump
            lda #0
            sta JUMP_INTERRUPTED_%%1
            lda #JUMP_FRAME_ADVANCE
            sta JUMP_COUNTER_%%1
            lda #PS_JUMP
            sta P%%1_STATE
SJ%%1_X
.endm

; Death animation depends on the speed of the rotator
; There are 3 death speeds, they are assigned
; to game levels in the following way:
;
; Level | Animation (S-Slow, M-medium, F-fase)
;-------------------
;   1   |     S
;   2   |     S
;   3   |     S
;   4   |     M
;   5   |     S
;   6   |     M
;   7   |     M
;   8   |     F
;   9   |     M
;  10   |     M
;  11   |     F
;  12   |     F
.macro INIT_DYING P12
            CLEAR_PLAYER %%1
            INIT_DYING_PAINT_OFFSET %%1
            lda #PS_DYING
            sta P%%1_STATE
            lda #0
            sta DYING_POS_X_P%%1
            sta P%%1_Y
            lda #1
            sta DYING_JUMP_COUNTER_%%1
            #if .byte CURRENT_GAME_LEVEL = #0 .or .byte CURRENT_GAME_LEVEL = #1 .or .byte CURRENT_GAME_LEVEL = #2 .or .byte CURRENT_GAME_LEVEL = #4 
                mwa #LEFT_KILL_Y_SPEED_1 P%%1_Y_TABLE
                .if :1 = 1
                    mwa #LEFT_KILL_X_SPEED_1 P%%1_X_TABLE
                .endif
                .if :1 = 2
                    mwa #RIGHT_KILL_X_SPEED_1 P%%1_X_TABLE
                .endif
                jmp ID%%1_X
            #end
            #if .byte CURRENT_GAME_LEVEL = #3 .or .byte CURRENT_GAME_LEVEL = #5 .or .byte CURRENT_GAME_LEVEL = #6 .or .byte CURRENT_GAME_LEVEL = #8  .or .byte CURRENT_GAME_LEVEL = #9 
                mwa #LEFT_KILL_Y_SPEED_2 P%%1_Y_TABLE
                .if :1 = 1
                    mwa #LEFT_KILL_X_SPEED_2 P%%1_X_TABLE
                .endif
                .if :1 = 2
                    mwa #RIGHT_KILL_X_SPEED_2 P%%1_X_TABLE
                .endif
                jmp ID%%1_X
            #end
            #if .byte CURRENT_GAME_LEVEL = #7 .or .byte CURRENT_GAME_LEVEL = #10 .or .byte CURRENT_GAME_LEVEL = #11
                mwa #LEFT_KILL_Y_SPEED_3 P%%1_Y_TABLE
                .if :1 = 1
                    mwa #LEFT_KILL_X_SPEED_3 P%%1_X_TABLE
                .endif
                .if :1 = 2
                    mwa #RIGHT_KILL_X_SPEED_3 P%%1_X_TABLE
                .endif
                jmp ID%%1_X
            #end
ID%%1_X
.endm

.macro INIT_DYING_PAINT_OFFSET P12
            ldy #0
            lda (P2_Y_TABLE),y
            ldy P%%1_Y
            sec
            sbc (P2_Y_TABLE),y
            sta P%%1_DRAWING_Y_OFFSET
.endm

.macro CHECK_PLAYER_COLLISIONS P12
            lda P%%1_INVUL
            jne CC%%1_X
            #if .byte P%%1_STATE = #PS_DYING .or .byte P%%1_Y > #6
                jmp CC%%1_X
            #end
            ldy CURRENT_GAME_LEVEL
            lda HIT_FRAMES_0,y
            cmp CURRENT_FRAME
            beq CC_%%1KILLD
            lda HIT_FRAMES_1,y
            cmp CURRENT_FRAME
            beq CC_%%1KILLD
            lda HIT_FRAMES_2,y
            cmp CURRENT_FRAME
            beq CC_%%1KILLD
            jmp CC%%1_X
CC_%%1KILLD INIT_DYING %%1
CC%%1_X
.endm