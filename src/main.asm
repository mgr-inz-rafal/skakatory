; First two frames in main memory
            org SCR_MEM_1		
            ins "frames/f0.bin"
            org SCR_MEM_2
            ins "frames/f1.bin"

            icl 'src\atari.inc'
            icl 'src\macros.asm'

FRAME_COUNT         equ 104
SCR_MEM_1           equ $4150
SCR_MEM_1_P2        equ $5000
SCR_MEM_2           equ $6150
SCR_MEM_2_P2        equ $7000
@TAB_MEM_BANKS      equ $0600

.zpvar          P1_Y_TABLE             .word
.zpvar          P1_X_TABLE             .word
.zpvar          P2_Y_TABLE             .word
.zpvar          P2_X_TABLE             .word
.zpvar          P1_SCORE               .byte
.zpvar          P1_SCORE_H             .byte ; 'H' is for hundred
.zpvar          P1_H_PAINTED           .byte
.zpvar          P2_SCORE               .byte
.zpvar          P2_SCORE_H             .byte ; 'H' is for hundred
.zpvar          P2_H_PAINTED           .byte
.zpvar          P1_INVUL               .byte
.zpvar          P1_VISIBLE             .byte
.zpvar          P2_INVUL               .byte
.zpvar          P2_VISIBLE             .byte
.zpvar          P1_DRAWING_Y_OFFSET    .byte
.zpvar          P2_DRAWING_Y_OFFSET    .byte
.zpvar          P1_CPU                 .byte
.zpvar          P2_CPU                 .byte
.zpvar          STRIG_0_SOURCE         .word
.zpvar          STRIG_1_SOURCE         .word
.zpvar          STRIG0_CPU             .word
.zpvar          STRIG1_CPU             .word
.zpvar          STRIG0_CPU_HOLD        .byte
.zpvar          STRIG1_CPU_HOLD        .byte
.zpvar          TMP                    .word

.zpvar          P1_INVUL_COUNTER       .byte
.zpvar          P2_INVUL_COUNTER       .byte
INVUL_COOLDOWN              equ 5

.zpvar          P1_INVUL_DISABLE_COUNTER .byte
.zpvar          P2_INVUL_DISABLE_COUNTER .byte
INVUL_ROTATIONS             equ 4

.zpvar          SCORE_JUST_INCREASED   .byte
SCORE_INCREASE_COOLDOWN     equ 4

//  0 -  51   - slower rotation (52 frames)
// 52 -  85   - faster rotation (34 frames)
// 86 - 103   - fastest rotation (18 frames)
.zpvar          CURRENT_FRAME          .byte
.zpvar          P1_X                   .byte 
.zpvar          P1_Y                   .byte
.zpvar          P2_X                   .byte 
.zpvar          P2_Y                   .byte
P1_X_POSITION    equ $50
P2_X_POSITION    equ $aa

.zpvar          DYING_JUMP_COUNTER_1   .byte
.zpvar          DYING_JUMP_COUNTER_2   .byte
DYING_JUMP_COOLDOWN         equ 2
DYING_JUMP_COOLDOWN_FAST    equ 1

.zpvar          JUMP_COUNTER_1         .byte
.zpvar          JUMP_COUNTER_2         .byte
.zpvar          JUMP_INTERRUPTED_1     .byte
.zpvar          JUMP_INTERRUPTED_2     .byte
JUMP_FRAME_COUNT     equ 46
JUMP_FRAME_ADVANCE   equ 1
JUMP_INTERRUPT_RATIO equ 6
JUMP_HOLD_DISRUPTION equ 6

.zpvar          DYING_POS_X_P1         .byte
.zpvar          DYING_POS_X_P2         .byte

.zpvar          P1_STATE               .byte
.zpvar          P2_STATE               .byte
PS_IDLE             equ 0
PS_JUMP             equ 1
PS_DYING            equ 2
PS_BURIED           equ 3

; Each level maps to these parameters that control
; the speed of background rotation
; 1) Number of frames to skip before advancing to next rotator position
; 2) First animation frame
; 3) Last animation frame
.zpvar          CURRENT_GAME_LEVEL          .byte
LAST_GAME_LEVEL     equ 12

.zpvar          CURRENT_ROTATION_COOLDOWN   .byte
.zpvar          CURRENT_ROTATIONS           .byte
.zpvar          FIRST_FRAME                 .byte
.zpvar          LAST_FRAME                  .byte

//------------------------------------------------
// Memory detection
//------------------------------------------------
            org $600
INIT_00
MAX_BANKS = 64		; maksymalna liczba banków pamięci
	LDA $7FFF	; bajt z pamięci podstawowej
	STA TEMP

        LDX #MAX_BANKS-1

_s1     LDA dBANK,X
        STA PORTB

        LDA $7FFF
        STA dSAFE,X

        DEX
        BPL _s1


        LDX #MAX_BANKS-1

_s2     LDA dBANK,X
        STA PORTB

        STA $7FFF

        DEX
        BPL _s2


	LDA #$FF
	STA PORTB

	STA $7FFF

	STA @TAB_MEM_BANKS		; pierwszy wpis w @TAB_MEM_BANKS = $FF

	LDY #0

        LDX #MAX_BANKS-1

LOP	LDA dBANK,X
        STA PORTB

        CMP $7FFF
        BNE SKP

	STA @TAB_MEM_BANKS+1,Y
        INY
SKP
        DEX
        BPL LOP


        LDX #MAX_BANKS-1

_r3     LDA dBANK,X
        STA PORTB

        LDA dSAFE,X
        STA $7FFF

        DEX
        BPL _r3


        LDA #$FF
        STA PORTB

	LDA #0		; przywracamy starą zawartość komórki pamięci spod adresu $7FFF w pamięci podstawowej
TEMP	EQU *-1
	STA $7FFF

	TYA		; w regA liczba odnalezionych banków dodatkowej pamięci

	rts

dBANK   DTA B($E3),B($C3),B($A3),B($83),B($63),B($43),B($23),B($03)
        DTA B($E7),B($C7),B($A7),B($87),B($67),B($47),B($27),B($07)
        DTA B($EB),B($CB),B($AB),B($8B),B($6B),B($4B),B($2B),B($0B)
        DTA B($EF),B($CF),B($AF),B($8F),B($6F),B($4F),B($2F),B($0F)

        DTA B($ED),B($CD),B($AD),B($8D),B($6D),B($4D),B($2D),B($0D)
        DTA B($E9),B($C9),B($A9),B($89),B($69),B($49),B($29),B($09)
        DTA B($E5),B($C5),B($A5),B($85),B($65),B($45),B($25),B($05)
        DTA B($E1),B($C1),B($A1),B($81),B($61),B($41),B($21),B($01)

dSAFE	.ds MAX_BANKS

            org $2000

; --------- DLI & PMG data --------------------------
.align $1000
PMG_BASE
SCENE_DISPLAY_LIST
DLIST_GAME
:3          dta b($70)
DLIST_MEM_TOP
            dta b($4e)
DLIST_ADDR_TOP
            dta a($0000)
:93         dta b($0e)
DLIST_MEM_BOTTOM
            dta b($4e)
DLIST_ADDR_BOTTOM
            dta a($0000)
:97         dta b($0e)
            dta b($42),a(STATUS_BAR_BUFFER)
            dta b($41),a(DLIST_GAME)
DL_MAIN_AREA
            dta b('J')
            dta b('E')
            dta b('B')
            dta b('A')
            dta b('C')
            dta b(' ')
            dta b('P')
            dta b('I')
            dta b('S')
            dta b(%00000100)
            dta b(%00000100)
            dta b(%00000100)
            dta b(%00000100)
            dta b(%00000100)
            dta b(%00000100)
            dta b(%00000100)
            dta b(%00000100)
            dta b(%00000100)
            dta b($40)
            dta b(%00000010)
            dta b(%00000010)
            dta b(%00000010)
            dta b(%00000010)
            dta b($41), a(SCENE_DISPLAY_LIST)

:$800       dta b(0)
PMG_M0      equ PMG_BASE+$300
PMG_P0      equ PMG_BASE+$400
PMG_P1      equ PMG_BASE+$500
PMG_P2      equ PMG_BASE+$600
PMG_P3      equ PMG_BASE+$700
PMG_END     equ PMG_BASE+$800

//------------------------------------------------
// Main program start
//------------------------------------------------
PROGRAM_START_FIRST_PART
            jsr GAME_ENGINE_INIT
            jsr GAME_STATE_INIT

            ldx <DLIST_GAME
            ldy >DLIST_GAME
            stx SDLSTL
            sty SDLSTL+1

GAME_LOOP
            jsr SYNCHRO
            jsr RESTART_TICK
            lda #$ff
            sta CH
            jsr AI_TICK
            jsr PLAYER_TICK
            jsr JOIN_PLAYER_TICK

            ldx CURRENT_FRAME
            jsr SHOW_FRAME

            jsr CHECK_SCORE
            jsr CHECK_COLLISIONS

            ldy #0
            lda (STRIG_0_SOURCE),y
            bne @+
            START_JUMP 1
@           ldx #0
            lda (STRIG_1_SOURCE,x)
            bne @+
            START_JUMP 2
@           jmp GAME_LOOP

AI_TICK     AI_PLAYER_TICK 1 0
            AI_PLAYER_TICK 2 1
            RELEASE_AI_KEY 1 0
            RELEASE_AI_KEY 2 1
            rts

JOIN_PLAYER_TICK
            lda P1_CPU
            beq JPT_1
            lda STRIG0
            bne JPT_1
            dec P1_CPU
            lda #<STRIG0
            sta STRIG_0_SOURCE
            lda #>STRIG0
            sta STRIG_0_SOURCE+1
            jsr PAINT_AI_INDICATORS
            rts
JPT_1       lda P2_CPU
            beq JPT_2
            lda STRIG1
            bne JPT_2
            dec P2_CPU
            lda #<STRIG1
            sta STRIG_1_SOURCE
            lda #>STRIG1
            sta STRIG_1_SOURCE+1
            jsr PAINT_AI_INDICATORS
JPT_2       rts

RESTART_TICK
            lda CH
            cmp #28
            beq RT_1

            #if .byte P1_STATE <> #PS_BURIED .or .byte P2_STATE <> #PS_BURIED
                rts
            #end
            lda CONSOL
            cmp #6
            bne RT_X

RT_1        jsr GAME_STATE_INIT

RT_X        rts

; A=1 - yes
; A=0 - no
SHOULD_UPDATE_SCORE
            lda SCORE_JUST_INCREASED
            cmp #0
            beq SUS_0
            dec SCORE_JUST_INCREASED
            lda #0
            rts
SUS_0       lda #1
            rts

CHECK_SCORE
            jsr SHOULD_UPDATE_SCORE
            beq CS_X
            #if .byte CURRENT_FRAME = #0+3 .or .byte CURRENT_FRAME = #52+3 .or .byte CURRENT_FRAME = #86+3
                jmp CS_1
            #end
CS_X        rts
CS_1        jsr ADVANCE_SCORES
            jsr PAINT_POINTS
            ldx #SCORE_INCREASE_COOLDOWN
            stx SCORE_JUST_INCREASED
            rts

ENABLE_INVUL
            jsr ADVANCE_SCORES
            lda #1
            sta P1_INVUL
            sta P2_INVUL
            lda #INVUL_COOLDOWN
            sta P1_INVUL_COUNTER
            sta P2_INVUL_COUNTER
            ldx CURRENT_GAME_LEVEL
            lda INVUL_ROTATIONS_PER_LEVEL,x
            sta P1_INVUL_DISABLE_COUNTER
            sta P2_INVUL_DISABLE_COUNTER
            rts

DISABLE_INVUL
            DISABLE_PLAYER_INVUL 1
            DISABLE_PLAYER_INVUL 2
            rts

ADVANCE_SCORES
            ADVANCE_PLAYER_SCORES 1
            ADVANCE_PLAYER_SCORES 2
            rts

PLAYER_TICK
            PLAYER_PLAYER_TICK 1
            PLAYER_PLAYER_TICK 2
            rts

CLEAR_PLAYERS
            CLEAR_PLAYER 1
            CLEAR_PLAYER 2
            rts

CHECK_COLLISIONS
            CHECK_PLAYER_COLLISIONS 1
            CHECK_PLAYER_COLLISIONS 2
            rts

BACKGROUND_TICK
            dec CURRENT_ROTATION_COOLDOWN
            bne BT_X ; Still not a good time to advance the rotation
            inc CURRENT_FRAME
            jsr INIT_LEVEL_PARAMS
            lda CURRENT_FRAME
            ldy CURRENT_GAME_LEVEL
            cmp LAST_FRAME_PER_LEVEL,y
            bne BT_X
            ldy CURRENT_GAME_LEVEL
            lda FIRST_FRAME_PER_LEVEL,y
            sta CURRENT_FRAME
            dec CURRENT_ROTATIONS
            bne BT_X
            ; Advance to next level
            lda CURRENT_GAME_LEVEL
            cmp #LAST_GAME_LEVEL-1
            beq BT_X
            jsr ADVANCE_LEVEL
BT_X        rts

ADVANCE_LEVEL
            jsr ENABLE_INVUL
            inc CURRENT_GAME_LEVEL
            jsr INIT_LEVEL_PARAMS
            ldy CURRENT_GAME_LEVEL
            lda ROTATIONS_PER_LEVEL,y
            sta CURRENT_ROTATIONS
            rts

PAINT_PLAYERS
; Paint left player
            ldy P1_Y
            lda (P1_Y_TABLE),y
            sec
            sbc P1_DRAWING_Y_OFFSET
            tay
            ldx #0
@           lda PLAYER_DATA_00,x
            sta PMG_P0,y
            lda PLAYER_DATA_01,x
            sta PMG_P1,y
            iny
            inx
            cpx #20
            bne @-
; Paint right player
            ldy P2_Y
            lda (P2_Y_TABLE),y
            sec
            sbc P2_DRAWING_Y_OFFSET
            tay
            ldx #0
@           lda PLAYER_DATA_02,x
            sta PMG_P2,y
            lda PLAYER_DATA_03,x
            sta PMG_P3,y
            iny
            inx
            cpx #20
            bne @-
            rts

; Left player sprites
PLAYER_DATA_00
            dta $18,$3C,$3C,$3C,$3C,$38,$18,$00,$7F,$59,$59,$99,$98,$18,$3C,$52,$52,$42,$42,$C3
PLAYER_DATA_01
            dta $C3,$81,$00,$00,$00,$00,$00,$00,$00,$18,$3C,$3C,$18,$18,$00,$00,$00,$00,$42,$E7
; Right player sprites
PLAYER_DATA_02
            dta $00,$00,$00,$00,$00,$00,$18,$7E,$5A,$9A,$19,$18,$18,$3C,$7C,$7E,$7E,$24,$24,$66
PLAYER_DATA_03
            dta $3C,$2C,$3C,$34,$3C,$3C,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$24,$24,$66

GAME_ENGINE_INIT
            ; Enable sprites
            lda #>PMG_BASE
            sta PMBASE
            lda #%00100001
            sta GPRIOR
            lda #%00000011
            sta GRACTL
            lda SDMCTL
            ora #%00011100
            sta SDMCTL

            ; Init VBI
            ldy <VBI_ROUTINE
            ldx >VBI_ROUTINE
            lda #7
            jsr SETVBV

            rts
        
INIT_PLAYERS
            lda #P1_X_POSITION
            sta P1_X
            lda #P2_X_POSITION
            sta P2_X
            lda #0
            sta P1_Y
            sta P2_Y
            lda #$1f
            sta PCOLR0
            lda #$af
            sta PCOLR1
            lda #$3f
            sta PCOLR2
            lda #$a6
            sta PCOLR3
            lda #PS_IDLE
            sta P1_STATE
            sta P2_STATE
            lda P1_X
            sta HPOSP0
            sta HPOSP1
            lda P2_X
            sta HPOSP2
            sta HPOSP3
            rts

; Number of frames in X
WAIT_FRAMES
            cpx #0
            beq @+
            jsr SYNCHRO
            dex
            jmp WAIT_FRAMES
@           rts

SYNCHRO
            lda PAL
            beq SYN_0
            lda #120	; NTSC
            jmp SYN_1
SYN_0       lda #145	; PAL
SYN_1       cmp VCOUNT
            bne SYN_1
            rts

INIT_LEVEL_PARAMS
            ldy CURRENT_GAME_LEVEL
            lda ROTATION_COOLDOWN_TAB,y
            sta CURRENT_ROTATION_COOLDOWN
            rts

GAME_STATE_INIT
            lda #1
            sta P1_VISIBLE
            sta P2_VISIBLE
            sta P1_CPU
            sta P2_CPU
            sta STRIG0_CPU
            sta STRIG1_CPU
            lda #<STRIG0_CPU
            sta STRIG_0_SOURCE
            lda #>STRIG0_CPU
            sta STRIG_0_SOURCE+1
            lda #<STRIG1_CPU
            sta STRIG_1_SOURCE
            lda #>STRIG1_CPU
            sta STRIG_1_SOURCE+1
            lda #0
            sta STRIG0_CPU_HOLD
            sta STRIG1_CPU_HOLD
            sta P1_DRAWING_Y_OFFSET
            sta P2_DRAWING_Y_OFFSET
            sta SCORE_JUST_INCREASED
            sta CURRENT_GAME_LEVEL
            sta P1_SCORE
            sta P2_SCORE
            sta P1_SCORE_H
            sta P2_SCORE_H
            sta P1_INVUL
            sta P2_INVUL
            tay
            lda FIRST_FRAME_PER_LEVEL,y
            sta FIRST_FRAME
            lda LAST_FRAME_PER_LEVEL,y
            sta LAST_FRAME
            jsr INIT_LEVEL_PARAMS
            ldy CURRENT_GAME_LEVEL
            lda ROTATIONS_PER_LEVEL,y
            sta CURRENT_ROTATIONS
            ldy FIRST_FRAME
            iny
            iny
            iny
            iny
            sty CURRENT_FRAME
            ldy #0
            lda @TAB_MEM_BANKS,y
            sta PORTB
            mwa #JUMP_HEIGHT_TABLE P1_Y_TABLE
            mwa #JUMP_HEIGHT_TABLE P2_Y_TABLE
            jsr CLEAR_STATUS_BAR
            jsr PAINT_POINTS
            jsr PAINT_AI_INDICATORS
            jsr INIT_PLAYERS
            jsr PAINT_PLAYERS
            rts           

CLEAR_STATUS_BAR
            lda #0
            ldx #39
@           sta STATUS_BAR_BUFFER,x
            dex
            bne @-
            sta STATUS_BAR_BUFFER,x
            rts

PAINT_AI_INDICATORS
            ldy #4
            lda P1_CPU
            beq PAI_1
            jsr PRINT_CPU
            jmp PAI_2
PAI_1       PRINT_PL 1
PAI_2       ldy #31
            lda P2_CPU
            beq PAI_3
            jsr PRINT_CPU
            jmp PAI_4
PAI_3       PRINT_PL 2
PAI_4       rts          

PRINT_CPU
            lda #"["*
            sta STATUS_BAR_BUFFER,y
            iny
            lda #"C"*
            sta STATUS_BAR_BUFFER,y
            iny
            lda #"P"*
            sta STATUS_BAR_BUFFER,y
            iny
            lda #"U"*
            sta STATUS_BAR_BUFFER,y
            iny
            lda #"]"*
            sta STATUS_BAR_BUFFER,y
            rts

PRINT_PL1
            lda #"["*
            sta STATUS_BAR_BUFFER,y
            iny
            lda #"P"*
            sta STATUS_BAR_BUFFER,y
            iny
            lda #" "*
            sta STATUS_BAR_BUFFER,y
            iny
            lda #"1"*
            sta STATUS_BAR_BUFFER,y
            iny
            lda #"]"*
            sta STATUS_BAR_BUFFER,y
            rts

PRINT_PL2
            lda #"["*
            sta STATUS_BAR_BUFFER,y
            iny
            lda #"P"*
            sta STATUS_BAR_BUFFER,y
            iny
            lda #" "*
            sta STATUS_BAR_BUFFER,y
            iny
            lda #"2"*
            sta STATUS_BAR_BUFFER,y
            iny
            lda #"]"*
            sta STATUS_BAR_BUFFER,y
            rts

PAINT_POINTS
            ; Note: These two cannot be deduped, since the
            ; implementation is different
            jsr PAINT_POINTS_LEFT
            jsr PAINT_POINTS_RIGHT

PAINT_POINTS_LEFT
            lda #0
            sta P1_H_PAINTED
            ldy #0
            lda P1_SCORE_H
            beq PP_1
            inc P1_H_PAINTED
            clc
            adc #16
            sta STATUS_BAR_BUFFER,y
            iny
PP_1        lda P1_SCORE
            and #%11110000
            lsr
            lsr
            lsr
            lsr
            ldx P1_H_PAINTED
            cpx #1
            beq PP_3
            cmp #0
            beq PP_2
PP_3        clc
            adc #16
            sta STATUS_BAR_BUFFER,y
            iny
PP_2        lda P1_SCORE
            and #%00001111
            clc
            adc #16
            sta STATUS_BAR_BUFFER,y
            rts

PAINT_POINTS_RIGHT
            lda #0
            sta P2_H_PAINTED
            ldy #39
            lda P2_SCORE
            and #%00001111
            clc
            adc #16
            sta STATUS_BAR_BUFFER,y
            lda P2_SCORE_H
            beq PPR_1
            clc
            adc #16
            dey
            dey
            sta STATUS_BAR_BUFFER,y
            inc P2_H_PAINTED
PPR_1       lda P2_SCORE
            and #%11110000
            lsr
            lsr
            lsr
            lsr
            beq PPR_2
PPR_3       clc
            adc #16
            ldy #38
            sta STATUS_BAR_BUFFER,y
            rts
PPR_2       ldx P2_H_PAINTED
            cpx #0
            bne PPR_3
            rts

; Frame number in X
SHOW_FRAME
; Pick correct ext ram bank
            txa
            pha
            lsr
            tay
            lda @TAB_MEM_BANKS,y
            sta PORTB
            pla

; Pick correct frame from ext ram bank
            txa
            and %00000001
            bne SF_FIRST
		    mwa #SCR_MEM_1      DLIST_ADDR_TOP
		    mwa #SCR_MEM_1_P2   DLIST_ADDR_BOTTOM
            jmp SF_X
SF_FIRST
		    mwa #SCR_MEM_2      DLIST_ADDR_TOP
		    mwa #SCR_MEM_2_P2   DLIST_ADDR_BOTTOM
SF_X        rts             

VBI_ROUTINE
            jsr BACKGROUND_TICK
            jmp XITVBV
            
PROGRAM_END_FIRST_PART      ; Can't cross $4000

; Call mem detect proc
            ini INIT_00

            org $8000
STATUS_BAR_BUFFER
:40         dta b('A')
            icl 'src\data.asm'

DATA_END

//------------------------------------------------
// Loading data into extram
//------------------------------------------------
.rept FRAME_COUNT/2-1, #+1, #*2+2, #*2+3

; Frames 3..FRAME_COUNT into ext ram banks
            org $6A0
INIT_:1
            ldy #:1
            lda @TAB_MEM_BANKS,y
            sta PORTB
            rts

            ini INIT_:1
            org SCR_MEM_1		
            ins "frames/f:2.bin"
            org SCR_MEM_2
            ins "frames/f:3.bin"
.endr

            run PROGRAM_START_FIRST_PART
           
