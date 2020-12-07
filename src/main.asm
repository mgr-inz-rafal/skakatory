; First two frames in main memory
            org SCR_MEM_1		
            ins "frames/f0.bin"
            org SCR_MEM_2
            ins "frames/f1.bin"

            icl 'src\atari.inc'

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

//  0 -  51   - slower rotation (52 frames)
// 52 -  85   - faster rotation (34 frames)
// 86 - 103   - fastest rotation (18 frames)
.zpvar          CURRENT_FRAME          .byte
.zpvar          P1_X                   .byte 
.zpvar          P1_Y                   .byte
.zpvar          P2_X                   .byte 
.zpvar          P2_Y                   .byte

.zpvar          DYING_JUMP_COUNTER       .byte
.zpvar          DYING_JUMP_COUNTER_RIGHT .byte
DYING_JUMP_COOLDOWN         equ 2
DYING_JUMP_COOLDOWN_FAST    equ 1

.zpvar          JUMP_COUNTER           .byte
.zpvar          JUMP_COUNTER_RIGHT     .byte
.zpvar          JUMP_INTERRUPTED       .byte
.zpvar          JUMP_INTERRUPTED_RIGHT .byte
JUMP_FRAME_COUNT    equ 46
JUMP_FRAME_ADVANCE  equ 1

.zpvar          DYING_POS_X_P1         .byte
.zpvar          DYING_POS_X_P2         .byte

.zpvar          P1_STATE               .byte
.zpvar          P2_STATE               .byte
PS_IDLE             equ 0
PS_JUMP             equ 1
PS_DYING            equ 2

; Each level maps to these parameters that control
; the speed of background rotation
; 1) Number of frames to skip before advancing to next rotator position
; 2) First animation frame
; 3) Last animation frame
.zpvar          CURRENT_GAME_LEVEL          .byte

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

            jsr PAINT_PLAYERS

GAME_LOOP
            lda CURRENT_GAME_LEVEL
            clc
            adc #16
            sta STATUS_BAR_BUFFER+0

            lda CURRENT_ROTATION_COOLDOWN
            clc
            adc #16
            sta STATUS_BAR_BUFFER+3

            lda CURRENT_ROTATIONS
            clc
            adc #16
            sta STATUS_BAR_BUFFER+5

            jsr SYNCHRO
            jsr PLAYER_TICK
            jsr PLAYER_TICK_RIGHT

            ldx CURRENT_FRAME
            jsr SHOW_FRAME

            ;jsr CHECK_COLLISIONS
            jsr CHECK_COLLISIONS_RIGHT

            lda STRIG0
            bne @+
            jsr START_JUMP
@           lda STRIG1
            bne @+
            jsr START_JUMP_RIGHT
@           jmp GAME_LOOP

START_JUMP
            lda P1_STATE
            cmp #PS_IDLE
            bne SJ_X    ; Only idle can jump
            lda #0
            sta JUMP_INTERRUPTED
            lda #JUMP_FRAME_ADVANCE
            sta JUMP_COUNTER
            lda #PS_JUMP
            sta P1_STATE
SJ_X        rts

START_JUMP_RIGHT
            lda P2_STATE
            cmp #PS_IDLE
            bne SJR_X    ; Only idle can jump
            lda #0
            sta JUMP_INTERRUPTED_RIGHT
            lda #JUMP_FRAME_ADVANCE
            sta JUMP_COUNTER_RIGHT
            lda #PS_JUMP
            sta P2_STATE
SJR_X       rts

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
INIT_DYING
            lda #PS_DYING
            sta P1_STATE
            lda #0
            sta DYING_POS_X_P1
            sta P1_Y
            lda #1
            sta DYING_JUMP_COUNTER
            #if .byte CURRENT_GAME_LEVEL = #0 .or .byte CURRENT_GAME_LEVEL = #1 .or .byte CURRENT_GAME_LEVEL = #2 .or .byte CURRENT_GAME_LEVEL = #4 
                mwa #LEFT_KILL_Y_SPEED_1 P1_Y_TABLE
                mwa #LEFT_KILL_X_SPEED_1 P1_X_TABLE
                rts
            #end
            #if .byte CURRENT_GAME_LEVEL = #3 .or .byte CURRENT_GAME_LEVEL = #5 .or .byte CURRENT_GAME_LEVEL = #6 .or .byte CURRENT_GAME_LEVEL = #8  .or .byte CURRENT_GAME_LEVEL = #9 
                mwa #LEFT_KILL_Y_SPEED_2 P1_Y_TABLE
                mwa #LEFT_KILL_X_SPEED_2 P1_X_TABLE
                rts
            #end
            #if .byte CURRENT_GAME_LEVEL = #7 .or .byte CURRENT_GAME_LEVEL = #10 .or .byte CURRENT_GAME_LEVEL = #11
                mwa #LEFT_KILL_Y_SPEED_3 P1_Y_TABLE
                mwa #LEFT_KILL_X_SPEED_3 P1_X_TABLE
                rts
            #end

INIT_DYING_RIGHT
            lda #PS_DYING
            sta P2_STATE
            lda #0
            sta DYING_POS_X_P2
            sta P2_Y
            lda #1
            sta DYING_JUMP_COUNTER_RIGHT
            #if .byte CURRENT_GAME_LEVEL = #0 .or .byte CURRENT_GAME_LEVEL = #1 .or .byte CURRENT_GAME_LEVEL = #2 .or .byte CURRENT_GAME_LEVEL = #4 
                // TODO: Change tables to "right-hand-side"
                mwa #LEFT_KILL_Y_SPEED_1 P2_Y_TABLE
                mwa #LEFT_KILL_X_SPEED_1 P2_X_TABLE
                rts
            #end
            #if .byte CURRENT_GAME_LEVEL = #3 .or .byte CURRENT_GAME_LEVEL = #5 .or .byte CURRENT_GAME_LEVEL = #6 .or .byte CURRENT_GAME_LEVEL = #8  .or .byte CURRENT_GAME_LEVEL = #9 
                mwa #LEFT_KILL_Y_SPEED_2 P2_Y_TABLE
                mwa #LEFT_KILL_X_SPEED_2 P2_X_TABLE
                rts
            #end
            #if .byte CURRENT_GAME_LEVEL = #7 .or .byte CURRENT_GAME_LEVEL = #10 .or .byte CURRENT_GAME_LEVEL = #11
                mwa #LEFT_KILL_Y_SPEED_3 P2_Y_TABLE
                mwa #LEFT_KILL_X_SPEED_3 P2_X_TABLE
                rts
            #end

CHECK_COLLISIONS
            #if .byte P1_STATE = #PS_DYING .or .byte P1_Y > #6
                rts
            #end
            ldy CURRENT_GAME_LEVEL
            lda HIT_FRAMES_0,y
            cmp CURRENT_FRAME
            beq CC_KILLED
            lda HIT_FRAMES_1,y
            cmp CURRENT_FRAME
            beq CC_KILLED
            lda HIT_FRAMES_2,y
            cmp CURRENT_FRAME
            beq CC_KILLED
            rts
CC_KILLED   jsr INIT_DYING
            rts

CHECK_COLLISIONS_RIGHT
            #if .byte P2_STATE = #PS_DYING .or .byte P2_Y > #6
                rts
            #end
            ldy CURRENT_GAME_LEVEL
            lda HIT_FRAMES_0,y
            cmp CURRENT_FRAME
            beq CCR_KILLED
            lda HIT_FRAMES_1,y
            cmp CURRENT_FRAME
            beq CCR_KILLED
            lda HIT_FRAMES_2,y
            cmp CURRENT_FRAME
            beq CCR_KILLED
            rts
CCR_KILLED  jsr INIT_DYING_RIGHT
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
            inc CURRENT_GAME_LEVEL
            jsr INIT_LEVEL_PARAMS
            ldy CURRENT_GAME_LEVEL
            lda ROTATIONS_PER_LEVEL,y
            sta CURRENT_ROTATIONS
BT_X        rts

PLAYER_TICK
            lda P1_STATE
            cmp #PS_IDLE
            beq PT_X
            cmp #PS_JUMP
            bne @+
            jsr JUMP_TICK
            rts
@           cmp #PS_DYING
            bne @+
            jsr DYING_TICK
            rts
@            
PT_X        rts

PLAYER_TICK_RIGHT
            lda P2_STATE
            cmp #PS_IDLE
            beq PTR_X
            cmp #PS_JUMP
            bne @+
            jsr JUMP_TICK_RIGHT
            rts
@           cmp #PS_DYING
            bne @+
            jsr DYING_TICK_RIGHT
@
PTR_X       rts

INTERRUPT_JUMP
            lda STRIG0
            beq IJ_X ; Button still pressed, do not interrupt
            lda JUMP_INTERRUPTED
            bne IJ_X ; This jump has already been interrupted
            lda #JUMP_FRAME_COUNT-1
            sec
            sbc P1_Y
            sta P1_Y
            lda #1
            sta JUMP_INTERRUPTED
IJ_X        rts

INTERRUPT_JUMP_RIGHT
            lda STRIG1
            beq IJR_X ; Button still pressed, do not interrupt
            lda JUMP_INTERRUPTED_RIGHT
            bne IJR_X ; This jump has already been interrupted
            lda #JUMP_FRAME_COUNT-1
            sec
            sbc P2_Y
            sta P2_Y
            lda #1
            sta JUMP_INTERRUPTED_RIGHT
IJR_X       rts

INIT_DYING_COOLDOWN
            #if .byte CURRENT_GAME_LEVEL = #0 .or .byte CURRENT_GAME_LEVEL = #1 .or .byte CURRENT_GAME_LEVEL = #2 .or .byte CURRENT_GAME_LEVEL = #4 
                lda #DYING_JUMP_COOLDOWN
                sta DYING_JUMP_COUNTER
                rts
            #end
            lda #DYING_JUMP_COOLDOWN_FAST
            sta DYING_JUMP_COUNTER
            rts

INIT_DYING_COOLDOWN_RIGHT
            #if .byte CURRENT_GAME_LEVEL = #0 .or .byte CURRENT_GAME_LEVEL = #1 .or .byte CURRENT_GAME_LEVEL = #2 .or .byte CURRENT_GAME_LEVEL = #4 
                lda #DYING_JUMP_COOLDOWN
                sta DYING_JUMP_COUNTER_RIGHT
                rts
            #end
            lda #DYING_JUMP_COOLDOWN_FAST
            sta DYING_JUMP_COUNTER_RIGHT
            rts

DYING_TICK
            dec DYING_JUMP_COUNTER
            bne DT_X
            jsr INIT_DYING_COOLDOWN
            ldy DYING_POS_X_P1
            lda (P1_X_TABLE),y
            cmp #$ff
            beq DT_0
            jsr CLEAR_PLAYERS
DUPA2            inc P1_Y
            ldy DYING_POS_X_P1
            lda (P1_X_TABLE),y
            inc DYING_POS_X_P1
            sta HPOSP0
            sta HPOSP1
            jsr PAINT_PLAYERS
DT_X        rts
DT_0        lda #0
            sta HPOSP0
            sta HPOSP1
CHUJ        jmp CHUJ
            rts

DYING_TICK_RIGHT
            dec DYING_JUMP_COUNTER_RIGHT
            bne DTR_X
            jsr INIT_DYING_COOLDOWN_RIGHT
            ldy DYING_POS_X_P2
            lda (P2_X_TABLE),y
            cmp #$ff
            beq DTR_0
            jsr CLEAR_PLAYERS
DUPA1       inc P2_Y
            ldy DYING_POS_X_P2
            lda (P2_X_TABLE),y
            inc DYING_POS_X_P2
            sta HPOSP2
            sta HPOSP3
            jsr PAINT_PLAYERS
DTR_X       rts
DTR_0       lda #0
            sta HPOSP2
            sta HPOSP3
CIPA        jmp CIPA
            rts

JUMP_TICK
            dec JUMP_COUNTER
            bne JT_X    ; Do not advance yet
            lda #JUMP_FRAME_ADVANCE
            sta JUMP_COUNTER
            jsr CLEAR_PLAYERS
            inc P1_Y
            jsr PAINT_PLAYERS
            lda P1_Y
            cmp #JUMP_FRAME_COUNT/2
            bne JT_2
            ; We're just started to go down, it's too late to interrupt the jump
            lda #1
            sta JUMP_INTERRUPTED
JT_2        lda P1_Y
            sec
            sbc #JUMP_FRAME_COUNT/4
            bcc JT_1    ; Do not allow to interrupt the jump yet
            jsr INTERRUPT_JUMP
JT_1        lda P1_Y
            cmp #JUMP_FRAME_COUNT-1
            bne JT_X
            ; Finish the jump
            lda #PS_IDLE
            sta P1_STATE
            lda #0
            sta P1_Y
JT_X        rts

JUMP_TICK_RIGHT
            dec JUMP_COUNTER_RIGHT
            bne JTR_X    ; Do not advance yet
            lda #JUMP_FRAME_ADVANCE
            sta JUMP_COUNTER_RIGHT
            jsr CLEAR_PLAYERS
            inc P2_Y
            jsr PAINT_PLAYERS
            lda P2_Y
            cmp #JUMP_FRAME_COUNT/2
            bne JTR_2
            ; We're just started to go down, it's too late to interrupt the jump
            lda #1
            sta JUMP_INTERRUPTED_RIGHT
JTR_2       lda P2_Y
            sec
            sbc #JUMP_FRAME_COUNT/4
            bcc JTR_1    ; Do not allow to interrupt the jump yet
            jsr INTERRUPT_JUMP_RIGHT
JTR_1       lda P2_Y
            cmp #JUMP_FRAME_COUNT-1
            bne JTR_X
            ; Finish the jump
            lda #PS_IDLE
            sta P2_STATE
            lda #0
            sta P2_Y
JTR_X       rts

CLEAR_PLAYERS
            ldy P1_Y
            lda (P1_Y_TABLE),y
            tay
            ldx #0
@           lda #0
            sta PMG_P0,y
            sta PMG_P1,y
            iny
            inx
            cpx #20
            bne @-
            ldy P2_Y
            lda (P2_Y_TABLE),y
            tay
            ldx #0
@           lda #0
            sta PMG_P2,y
            sta PMG_P3,y
            iny
            inx
            cpx #20
            bne @-
            rts

PAINT_PLAYERS
; Paint left player
            ldy P1_Y
            lda (P1_Y_TABLE),y
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

            jsr INIT_PLAYERS
            rts
        
INIT_PLAYERS
            lda #$50
            sta P1_X
            lda #$aa
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
            lda #0
            sta CURRENT_GAME_LEVEL
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
SF_X
            rts             

JUMP_HEIGHT_TABLE
            dta b(156)
            dta b(152)
            dta b(148)
            dta b(144)
            dta b(140)
            dta b(136)
            dta b(133)
            dta b(130)
            dta b(127)
            dta b(124)
            dta b(121)
            dta b(119)
            dta b(117)
            dta b(115)
            dta b(113)
            dta b(112)
            dta b(110)
            dta b(109)
            dta b(108)
            dta b(107)
            dta b(107)
            dta b(106)
            dta b(106)
            dta b(106)
            dta b(106)
            dta b(107)
            dta b(107)
            dta b(108)
            dta b(109)
            dta b(110)
            dta b(112)
            dta b(113)
            dta b(115)
            dta b(117)
            dta b(119)
            dta b(121)
            dta b(124)
            dta b(127)
            dta b(130)
            dta b(133)
            dta b(136)
            dta b(140)
            dta b(144)
            dta b(148)
            dta b(152)
            dta b(156)

VBI_ROUTINE
            jsr BACKGROUND_TICK
            jmp XITVBV

STATUS_BAR_BUFFER
:20         dta b('A')

; Level difficulty parameters
ROTATIONS_PER_LEVEL
            dta b(10)
            dta b(10)
            dta b(10)
            dta b(10)
            dta b(10)
            dta b(10)
            dta b(10)
            dta b(10)
            dta b(10)
            dta b(10)
            dta b(10)
            dta b(10)

ROTATION_COOLDOWN_TAB
            dta b(4)
            dta b(3)
            dta b(2)
            dta b(1)
            dta b(4)
            dta b(3)
            dta b(2)
            dta b(1)
            dta b(4)
            dta b(3)
            dta b(2)
            dta b(1)

FIRST_FRAME_PER_LEVEL
            dta b(0)
            dta b(0)
            dta b(0)
            dta b(0)
            dta b(52)
            dta b(52)
            dta b(52)
            dta b(52)
            dta b(86)
            dta b(86)
            dta b(86)
            dta b(86)

LAST_FRAME_PER_LEVEL
            dta b(52)
            dta b(52)
            dta b(52)
            dta b(52)
            dta b(86)
            dta b(86)
            dta b(86)
            dta b(86)
            dta b(104)
            dta b(104)
            dta b(104)
            dta b(104)

HIT_FRAMES_0
            dta b(51)
            dta b(51)
            dta b(51)
            dta b(51)
            dta b(85)
            dta b(85)
            dta b(85)
            dta b(85)
            dta b(86)
            dta b(86)
            dta b(86)
            dta b(86)

HIT_FRAMES_1
            dta b(00)
            dta b(00)
            dta b(00)
            dta b(00)
            dta b(52)
            dta b(52)
            dta b(52)
            dta b(52)
            dta b(86)
            dta b(86)
            dta b(86)
            dta b(86)

HIT_FRAMES_2
            dta b(01)
            dta b(01)
            dta b(01)
            dta b(01)
            dta b(53)
            dta b(53)
            dta b(53)
            dta b(53)
            dta b(86)
            dta b(86)
            dta b(86)
            dta b(86)

LEFT_KILL_X_SPEED_1
            dta b(081)
            dta b(082)
            dta b(083)
            dta b(084)
            dta b(085)
            dta b(086)
            dta b(087)
            dta b(088)
            dta b(089)
            dta b(090)
            dta b(091)
            dta b(092)
            dta b(093)
            dta b(094)
            dta b(095)
            dta b(096)
            dta b(097)
            dta b(098)
            dta b(099)
            dta b(100)
            dta b(101)
            dta b(102)
            dta b(103)
            dta b(104)
            dta b(105)
            dta b(106)
            dta b(107)
            dta b(108)
            dta b(109)
            dta b(110)
            dta b(111)
            dta b(112)
            dta b($ff)
 
LEFT_KILL_Y_SPEED_1
            dta b(156)
            dta b(154)
            dta b(153)
            dta b(152)
            dta b(151)
            dta b(150)
            dta b(150)
            dta b(149)
            dta b(149)
            dta b(150)
            dta b(150)
            dta b(151)
            dta b(151)
            dta b(152)
            dta b(154)
            dta b(155)
            dta b(157)
            dta b(159)
            dta b(161)
            dta b(163)
            dta b(165)
            dta b(168)
            dta b(171)
            dta b(174)
            dta b(177)
            dta b(181)
            dta b(185)
            dta b(189)
            dta b(193)
            dta b(197)
            dta b(202)
            dta b(207)
            dta b(212)
            
LEFT_KILL_X_SPEED_2
            dta b(081)
            dta b(083)
            dta b(085)
            dta b(086)
            dta b(088)
            dta b(090)
            dta b(091)
            dta b(093)
            dta b(095)
            dta b(097)
            dta b(098)
            dta b(100)
            dta b(102)
            dta b(103)
            dta b(105)
            dta b(107)
            dta b(108)
            dta b(110)
            dta b(112)
            dta b(114)
            dta b(115)
            dta b(117)
            dta b(119)
            dta b(120)
            dta b(122)
            dta b(124)
            dta b(125)
            dta b(127)
            dta b(129)
            dta b(131)
            dta b(132)
            dta b(134)
            dta b(136)
            dta b(137)
            dta b(139)
            dta b(141)
            dta b(142)
            dta b(144)
            dta b(146)
            dta b(148)
            dta b(149)
            dta b(151)
            dta b(153)
            dta b(154)
            dta b(156)
            dta b(158)
            dta b(159)
            dta b(161)
            dta b(163)
            dta b(165)
            dta b(166)
            dta b(168)
            dta b(170)
            dta b(171)
            dta b(173)
            dta b(175)
            dta b($ff)
 
LEFT_KILL_Y_SPEED_2
            dta b(156)
            dta b(154)
            dta b(153)
            dta b(151)
            dta b(150)
            dta b(149)
            dta b(148)
            dta b(147)
            dta b(147)
            dta b(146)
            dta b(145)
            dta b(145)
            dta b(145)
            dta b(145)
            dta b(145)
            dta b(145)
            dta b(145)
            dta b(145)
            dta b(145)
            dta b(146)
            dta b(146)
            dta b(147)
            dta b(148)
            dta b(149)
            dta b(150)
            dta b(151)
            dta b(152)
            dta b(154)
            dta b(155)
            dta b(157)
            dta b(158)
            dta b(160)
            dta b(162)
            dta b(164)
            dta b(166)
            dta b(168)
            dta b(171)
            dta b(173)
            dta b(176)
            dta b(179)
            dta b(181)
            dta b(184)
            dta b(187)
            dta b(190)
            dta b(194)
            dta b(197)
            dta b(200)
            dta b(204)
            dta b(208)
            dta b(211)
            dta b(215)
            dta b(219)
            dta b(223)
            dta b(228)
            dta b(232)
            dta b(236)
            
LEFT_KILL_X_SPEED_3
            dta b(083)
            dta b(086)
            dta b(090)
            dta b(093)
            dta b(097)
            dta b(100)
            dta b(103)
            dta b(107)
            dta b(110)
            dta b(114)
            dta b(117)
            dta b(121)
            dta b(124)
            dta b(127)
            dta b(131)
            dta b(134)
            dta b(138)
            dta b(141)
            dta b(144)
            dta b(148)
            dta b(151)
            dta b(155)
            dta b(158)
            dta b(162)
            dta b(165)
            dta b(168)
            dta b(172)
            dta b(175)
            dta b(179)
            dta b(182)
            dta b(186)
            dta b(189)
            dta b(192)
            dta b(196)
            dta b(199)
            dta b(203)
            dta b(206)
            dta b(209)
            dta b(213)
            dta b(216)
            dta b($ff)
 
LEFT_KILL_Y_SPEED_3
            dta b(156)
            dta b(153)
            dta b(150)
            dta b(148)
            dta b(145)
            dta b(143)
            dta b(141)
            dta b(139)
            dta b(137)
            dta b(135)
            dta b(133)
            dta b(132)
            dta b(130)
            dta b(129)
            dta b(128)
            dta b(127)
            dta b(126)
            dta b(125)
            dta b(124)
            dta b(123)
            dta b(122)
            dta b(122)
            dta b(122)
            dta b(121)
            dta b(121)
            dta b(121)
            dta b(121)
            dta b(121)
            dta b(121)
            dta b(122)
            dta b(122)
            dta b(123)
            dta b(124)
            dta b(124)
            dta b(125)
            dta b(126)
            dta b(128)
            dta b(129)
            dta b(130)
            dta b(132)
            
PROGRAM_END_FIRST_PART      ; Can't cross $4000

; Call mem detect proc
            ini INIT_00

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
           
