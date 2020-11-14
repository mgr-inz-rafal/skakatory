; First two frames in main memory
            org SCR_MEM_1		
            ins "frames/1.bin"
            org SCR_MEM_2
            ins "frames/2.bin"

            org $2000

            icl 'src\atari.inc'

FRAME_COUNT     equ 6
SCR_MEM_1	    equ	$4150
SCR_MEM_1_P2    equ $5000
SCR_MEM_2	    equ	$6150
SCR_MEM_2_P2    equ $7000
@TAB_MEM_BANKS  equ $0600

.zpvar          CURRENT_FRAME .byte

//------------------------------------------------
// Memory detection
//------------------------------------------------
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

//------------------------------------------------
// Main program start
//------------------------------------------------
PROGRAM_START_FIRST_PART
            jsr GAME_STATE_INIT

		    ldx <DLIST_GAME
		    ldy >DLIST_GAME
		    stx SDLSTL
		    sty SDLSTL+1

GAME_LOOP
            ldx CURRENT_FRAME
            jsr SHOW_FRAME
            ldx #120
            jsr WAIT_FRAMES

            inc CURRENT_FRAME
            lda CURRENT_FRAME
            cmp #FRAME_COUNT
            beq ANIM_AGAIN
            jmp GAME_LOOP

ANIM_AGAIN
            lda #0
            sta CURRENT_FRAME            

            jmp GAME_LOOP
        
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

PROGRAM_END_FIRST_PART      ; Can't cross $4000


//------------------------------------------------
// Loading data into extram
//------------------------------------------------
            ini INIT_00

; Frames 3, 4 into BANK #1
            org $6A0
INIT_01 
            ldy #1
            lda @TAB_MEM_BANKS,y
            sta PORTB
            rts

            ini INIT_01
            org SCR_MEM_1		
            ins "frames/3.bin"
            org SCR_MEM_2
            ins "frames/4.bin"

; Frames 5, 6 into BANK #2
            org $6A0
INIT_02
            ldy #2
            lda @TAB_MEM_BANKS,y
            sta PORTB
            rts

            ini INIT_02
            org SCR_MEM_1		
            ins "frames/5.bin"
            org SCR_MEM_2
            ins "frames/6.bin"

            run PROGRAM_START_FIRST_PART

.align		$400
DLIST_GAME
:3			dta b($70)
DLIST_MEM_TOP
			dta b($4e)
DLIST_ADDR_TOP
			dta a($0000)
:93			dta b($0e)
DLIST_MEM_BOTTOM
			dta b($4e)
DLIST_ADDR_BOTTOM
			dta a($0000)
:97			dta b($0e)
			dta b($41),a(DLIST_GAME)

           
