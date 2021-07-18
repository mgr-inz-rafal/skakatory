            mva #0 IN_GAME
            jsr CLEAR_PLAYERS_PMG
            jsr TITLE_MAIN

@           jsr SYNCHRO
            dec QUOTE_COLOR_COUNTER
            lda QUOTE_COLOR_COUNTER
            bne TIT_1
            #if .byte QUOTE_COLOR < #QUOTE_TARGET_COLOR
                inc QUOTE_COLOR
            #end
            lda #QUOTE_COLOR_COOLDOWN
            sta QUOTE_COLOR_COUNTER

TIT_1       lda STRIG0
            sta ATRACT
            bne @-
            jsr FADE_OUT_TITLE_SCREEN
            jmp PROGRAM_START_FIRST_PART

CLEAR_PLAYERS_PMG
            ldy #0
            lda #0
@           sta PMG_P0,y
            sta PMG_P1,y
            sta PMG_P2,y
            sta PMG_P3,y
            iny
            bne @-
            rts            

DLI_ROUTINE_TITLE
            pha
            lda VCOUNT
            cmp #$17
            bne @+
            lda >NAMES_FONT
            sta CHBASE
            pla
            rti
@           lda >QUOTE_FONT
            sta CHBASE
            lda QUOTE_COLOR
            sta COLPF1
            pla
            rti

CLEAR_TITLE_SCREEN
            ldy #0
            mwa #SCR_MEM_MENU XTMP
CTS_0       tya
            sta (XTMP),y
            inw XTMP
            #if .word XTMP = #SCR_MEM_MENU+1160
                rts
            #end
            jmp CTS_0

TITLE_MAIN
            lda #%00100001
            sta GPRIOR
            lda #QUOTE_COLOR_COOLDOWN
            sta QUOTE_COLOR_COUNTER
            lda #0
            sta QUOTE_COLOR
			lda <DLI_ROUTINE_TITLE
			sta VDSLST
			lda >DLI_ROUTINE_TITLE
			sta VDSLST+1
			lda #192
			sta NMIEN

            ldy #0
            lda @TAB_MEM_BANKS,y
            sta PORTB

            ldx <DLIST_TITLE_SCREEN
            ldy >DLIST_TITLE_SCREEN
            stx SDLSTL
            sty SDLSTL+1
	        lda >NAMES_FONT
            sta CHBAS

            lda #0
            sta CLR2
            lda #$f
            sta CLR1
            sta CLR0

            jsr CLEAR_TITLE_SCREEN
            jsr SETUP_RANDOM_NAME
            jsr PRINT_NAME
            jsr SETUP_RANDOM_NAME_BABSKIE
            jsr PRINT_NAME
            jsr ENABLE_ANTIC
            jsr PRINT_AMPERSAND
            jsr PRINT_QUOTATION
            lda #$ff
            sta CH
            rts        

FADE_NAME_ROW
            lda #0
            ldy #0

            mwa #MENU_FADE_TABLE XTMP
FOTS_2      lda RANDOM
            sta (XTMP),y
            iny
            cpy #20
            bne FOTS_2 

FOTS_3      mwa XTMP2 XTMP
            ldy #0
FOTS_1      jsr ADVANCE_FADE_CHARACTER
            sta (XTMP),y
            iny
            cpy #20
            bne FOTS_1

            jsr IS_NAME_FADED
            cmp #1
            bne FOTS_3

;CHUJ        jmp CHUJ
            rts

FADE_OUT_TITLE_SCREEN
            mwa #SCR_MEM_MENU XTMP2
            jsr FADE_NAME_ROW
            mwa #SCR_MEM_MENU+(24*(320/8)+20) XTMP2
            jsr FADE_NAME_ROW
            jsr DELETE_AMPERSAND
            jsr HIDE_QUOTE
            ldx #66
            jsr WAIT_FRAMES
            rts

HIDE_QUOTE
            ldy #QUOTE_TARGET_COLOR
HQ_1        dec QUOTE_COLOR
            ldx #12
            jsr WAIT_FRAMES
            dey
            cpy #0
            bne HQ_1
            rts

IS_NAME_FADED
            mwa XTMP2 XTMP
            lda #0
            ldy #0
INF_1       lda (XTMP),y
            cmp #0
            bne INF_2
            iny
            cpy #20
            bne INF_1
            lda #1
            rts      
INF_2       lda #0
            rts      

ADVANCE_FADE_CHARACTER
            jsr DECREASE_FADE_TIMER
            beq LFC_8
            mwa XTMP2 XTMP
            lda (XTMP),y
            rts

LFC_8       mwa XTMP2 XTMP
            lda (XTMP),y

            cmp #FADE_START_CHAR
            bne LFC_1
            lda #FADE_NEXT_CHAR_1
            rts

LFC_1       cmp #FADE_NEXT_CHAR_1
            bne LFC_2
            lda #FADE_NEXT_CHAR_2
            rts

LFC_2       cmp #FADE_NEXT_CHAR_2
            bne LFC_3
            lda #FADE_NEXT_CHAR_3
            rts

LFC_3       cmp #FADE_NEXT_CHAR_3
            bne LFC_4
            lda #FADE_NEXT_CHAR_4
            rts

LFC_4       cmp #FADE_NEXT_CHAR_4
            bne LFC_5
            lda #FADE_NEXT_CHAR_5
            rts

LFC_5       cmp #FADE_NEXT_CHAR_5
            bne LFC_6
            lda #0
            rts

LFC_6       cmp #0
            bne LFC_7
            rts

LFC_7       lda #FADE_START_CHAR
            rts

DECREASE_FADE_TIMER
            mwa #MENU_FADE_TABLE XTMP
            lda (XTMP),y
            tax
            dex
            txa
            sta (XTMP),y
            cmp #0
            bne DFT_1
            mwa #MENU_FADE_TABLE XTMP
            lda #FADE_SPEED
            sta (XTMP),y
            lda #0
DFT_1       rts

PRINT_QUOTATION
            lda RANDOM
            and #%00000011

            cmp #0
            bne PQ_2
            mwa #QUOTATION_1 XTMP
            jmp PQ_5

PQ_2        cmp #1
            bne PQ_3
            mwa #QUOTATION_2 XTMP
            jmp PQ_5

PQ_3        cmp #2
            bne PQ_4
            mwa #QUOTATION_3 XTMP
            jmp PQ_5

PQ_4        mwa #QUOTATION_4 XTMP

PQ_5        ldx #40*4
            mwa #SCR_MEM_MENU+1000 XTMP2
            ldy #0
PQ_1        lda (XTMP),y
            sta (XTMP2),y
            inw XTMP
            inw XTMP2
            dex
            bne PQ_1
            rts

PRINT_AMPERSAND
            lda #0
            sta XTMP2+1
PA_0        ldy XTMP2+1
            lda AMPERSAND_PIXELS_X,y
            tax
            lda AMPERSAND_PIXELS_Y,y
            tay
            jsr PUT_PIXEL
            jsr SYNCHRO
            jsr SYNCHRO
            inc XTMP2+1
            lda XTMP2+1
            cmp #AMPERSAND_PIXEL_COUNT
            bne PA_0
            rts

DELETE_AMPERSAND
            lda #AMPERSAND_PIXEL_COUNT-1
            sta XTMP2+1
DA_0        ldy XTMP2+1
            lda AMPERSAND_PIXELS_X,y
            tax
            lda AMPERSAND_PIXELS_Y,y
            tay
            jsr PUT_PIXEL
            jsr SYNCHRO
            dec XTMP2+1
            lda XTMP2+1
            cmp #$ff
            bne DA_0
            rts

PICK_NUMBER_FROM_1_TO_250
            lda RANDOM
            sta XTMP
            #if .byte XTMP < #1 .or .byte XTMP > #250
                jmp PICK_NUMBER_FROM_1_TO_250
            #end
            lda XTMP
            tay
            rts

; Output:
; X = 1: Names from   0 to 250
; X = 0: Names from 251 to 500
; Y = Name offset
; For example:
; X=0, Y=15 - Pick 15th name from first part (15)
; X=1, Y=17 - Pick 17th name from second part (268)
PICK_RANDOM_NAME_INDEX
            lda RANDOM
            and #%00000001
            tax
            jsr PICK_NUMBER_FROM_1_TO_250
            rts

SETUP_RANDOM_NAME
            jsr PICK_RANDOM_NAME_INDEX
            mwa #$4000 XTMP
            cpx #0
            bne SRN_2
            adw XTMP #MAX_NAME_LEN*250
SRN_2       dey
            cpy #0
            beq SRN_1
            adw XTMP #MAX_NAME_LEN
            jmp SRN_2
SRN_1       mwa #SCR_MEM_MENU XTMP2
            rts

SETUP_RANDOM_NAME_BABSKIE
            jsr PICK_RANDOM_NAME_INDEX
            mwa #$4000+(NAMES_PER_SEX*MAX_NAME_LEN) XTMP
            cpx #0
            bne SRNB_2
            adw XTMP #MAX_NAME_LEN*250
SRNB_2      dey
            cpy #0
            beq SRNB_1
            adw XTMP #MAX_NAME_LEN
            jmp SRNB_2
SRNB_1      mwa #SCR_MEM_MENU+(24*(320/8)+20) XTMP2
            rts

PRINT_NAME
            ldx #MAX_NAME_LEN
            ldy #NAMES_BANK
            lda @TAB_MEM_BANKS,y
            sta PORTB

            ldy #0
PN_1        lda (XTMP),y
            #if .byte @ > #90
                sec
                sbc #32
            #end
            sta (XTMP2),y

            dex
            beq PN_X

            inw XTMP
            inw XTMP2
            jmp PN_1

PN_X        rts

PUT_PIXEL
            txa
            pha

            lda PIXEL_X_TABLE_OFFSET,x
            tax

            pla
            pha

PPX_2       cpx #0
            beq PPX_1
            sec
            sbc #8
            dex
            jmp PPX_2

PPX_1       sta XTMP2 ; Which bit

            pla
            tax

            mwa PIXEL_Y_TABLE,y XTMP

            clc
            lda XTMP
            adc PIXEL_X_TABLE_OFFSET,x
            sta XTMP
            lda XTMP+1
            adc #0
            sta XTMP+1

            inw XTMP
            inw XTMP
            ldy #0
            lda (XTMP),y
            ldy XTMP2
            eor PIXEL_X_BIT_TABLE,y
            ldy #0
            sta (XTMP),y

            rts
