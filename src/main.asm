; First two frames in main memory
            org SCR_MEM_1		
            ins "frames/f0.bin"
            org SCR_MEM_2
            ins "frames/f1.bin"

            icl 'src\atari.inc'

FRAME_COUNT         equ 60
SCR_MEM_1           equ $4150
SCR_MEM_1_P2        equ $5000
SCR_MEM_2           equ $6150
SCR_MEM_2_P2        equ $7000
@TAB_MEM_BANKS      equ $0600

.zpvar          CURRENT_FRAME         .byte
.zpvar          P1_X                  .byte 
.zpvar          P1_Y                  .byte
.zpvar          OPTIONAL_LIFT_ALLOWED .byte

.zpvar          ROTATION_COUNTER            .byte
.zpvar          CURRENT_ROTATION_COOLDOWN   .byte
INITIAL_ROTATION_COOLDOWN   equ 250

.zpvar          JUMP_COUNTER                .byte
JUMP_FRAME_COUNT            equ 60
JUMP_FRAME_ADVANCE          equ 100

.zpvar          P1_STATE      .byte
PS_IDLE             equ 0
PS_JUMP             equ 1

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
            ;jsr SYNCHRO
            jsr PLAYER_TICK
            JSR BACKGROUND_TICK

            ldx CURRENT_FRAME
            jsr SHOW_FRAME

            lda STRIG0
            bne @+
            jsr START_JUMP
@           jmp GAME_LOOP

START_JUMP
            lda P1_STATE
            cmp #PS_IDLE
            bne SJ_X    ; Only idle can jump
            lda #JUMP_FRAME_ADVANCE
            sta JUMP_COUNTER
            lda #PS_JUMP
            sta P1_STATE
SJ_X        rts

BACKGROUND_TICK
            dec ROTATION_COUNTER
            bne BT_2
            lda CURRENT_ROTATION_COOLDOWN
            sta ROTATION_COUNTER
            inc CURRENT_FRAME
            lda CURRENT_FRAME
            cmp #FRAME_COUNT
            beq BT_1
BT_2        rts
BT_1        lda #0
            sta CURRENT_FRAME            
            dec CURRENT_ROTATION_COOLDOWN
            rts

PLAYER_TICK
            lda P1_STATE
            cmp #PS_IDLE
            beq PT_X
            cmp #PS_JUMP
            bne @+
            jsr JUMP_TICK
@
PT_X        rts

JUMP_TICK
            dec JUMP_COUNTER
            bne JT_X    ; Do not advance yet
            lda #JUMP_FRAME_ADVANCE
            sta JUMP_COUNTER
            jsr CLEAR_PLAYERS
            inc P1_Y
            jsr PAINT_PLAYERS
            lda P1_Y
            cmp #JUMP_FRAME_COUNT-1
            bne JT_X
            ; Finish the jump
            lda #PS_IDLE
            sta P1_STATE
            lda #0
            sta P1_Y
JT_X        rts

CLEAR_PLAYERS
            ldy P1_Y
            lda JUMP_HEIGHT_TABLE,y
            tay
            ldx #0
@           lda #0
            sta PMG_P0,y
            iny
            inx
            cpx #20
            bne @-
            lda P1_X
            sta HPOSP0
            rts

PAINT_PLAYERS
            ldy P1_Y
            lda JUMP_HEIGHT_TABLE,y
            tay
            ldx #0
@           lda PLAYER_DATA,x
            sta PMG_P0,y
            iny
            inx
            cpx #20
            bne @-
            lda P1_X
            sta HPOSP0
            rts

PLAYER_DATA
            dta b($aa)
            dta b($ab)
            dta b($ac)
            dta b($ad)
            dta b($ae)
            dta b($af)
            dta b($ba)
            dta b($bb)
            dta b($bc)
            dta b($bd)
            dta b($aa)
            dta b($ab)
            dta b($ac)
            dta b($ad)
            dta b($ae)
            dta b($af)
            dta b($ba)
            dta b($bb)
            dta b($bc)
            dta b($bd)

GAME_ENGINE_INIT
; --------- Enable sprites                   
            lda #>PMG_BASE
            sta PMBASE
            lda #%00100001
            sta GPRIOR
            lda #%00000011
            sta GRACTL
            lda SDMCTL
            ora #%00011100
            sta SDMCTL

            jsr INIT_PLAYERS
            rts
        
INIT_PLAYERS
            lda #$50
            sta P1_X
            lda #0
            sta P1_Y
            lda #$1f
            sta PCOLR0
            lda #PS_IDLE
            sta P1_STATE
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

GAME_STATE_INIT
            lda #INITIAL_ROTATION_COOLDOWN
            sta ROTATION_COUNTER
            sta CURRENT_ROTATION_COOLDOWN
            lda #0
            sta CURRENT_FRAME
            tay
            lda @TAB_MEM_BANKS,y
            sta PORTB
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
            dta b(153)
            dta b(150)
            dta b(147)
            dta b(144)
            dta b(141)
            dta b(138)
            dta b(135)
            dta b(133)
            dta b(131)
            dta b(128)
            dta b(126)
            dta b(124)
            dta b(122)
            dta b(120)
            dta b(119)
            dta b(117)
            dta b(115)
            dta b(114)
            dta b(113)
            dta b(112)
            dta b(111)
            dta b(110)
            dta b(109)
            dta b(108)
            dta b(107)
            dta b(107)
            dta b(107)
            dta b(106)
            dta b(106)
            dta b(106)
            dta b(106)
            dta b(106)
            dta b(106)
            dta b(107)
            dta b(107)
            dta b(108)
            dta b(109)
            dta b(110)
            dta b(110)
            dta b(112)
            dta b(113)
            dta b(114)
            dta b(115)
            dta b(117)
            dta b(118)
            dta b(120)
            dta b(122)
            dta b(124)
            dta b(126)
            dta b(128)
            dta b(130)
            dta b(133)
            dta b(135)
            dta b(138)
            dta b(141)
            dta b(144)
            dta b(146)
            dta b(150)
            dta b(153)

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
           
