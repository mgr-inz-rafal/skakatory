            jsr TITLE_INTRO
            jsr TITLE_MAIN

@           lda STRIG0
            bne @-
            jmp PROGRAM_START_FIRST_PART

TITLE_INTRO
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
            pla
            rti

TITLE_MAIN
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

            jsr SETUP_RANDOM_NAME
            jsr PRINT_NAME
            jsr SETUP_RANDOM_NAME_BABSKIE
            jsr PRINT_NAME
            jsr PRINT_QUOTATION
            jsr PRINT_AMPERSAND
            rts        

PRINT_QUOTATION
            lda RANDOM
            and #%00000011

            cmp #0
            bne PQ_2
            mwa #QUOTATION_1 TMP
            jmp PQ_5

PQ_2        cmp #1
            bne PQ_3
            mwa #QUOTATION_2 TMP
            jmp PQ_5

PQ_3        cmp #2
            bne PQ_4
            mwa #QUOTATION_3 TMP
            jmp PQ_5

PQ_4        mwa #QUOTATION_4 TMP

PQ_5        ldx #40*4
            mwa #SCR_MEM_MENU+1000 TMP2
            ldy #0
PQ_1        lda (TMP),y
            sta (TMP2),y
            inw TMP
            inw TMP2
            dex
            bne PQ_1
            rts

PRINT_AMPERSAND
            lda #0
            sta TMP2+1
PA_0        ldy TMP2+1
            lda AMPERSAND_PIXELS_X,y
            tax
            lda AMPERSAND_PIXELS_Y,y
            tay
            jsr PUT_PIXEL
            jsr SYNCHRO
            jsr SYNCHRO
            inc TMP2+1
            lda TMP2+1
            cmp #AMPERSAND_PIXEL_COUNT
            bne PA_0
            rts

PICK_NUMBER_FROM_1_TO_250
            lda RANDOM
            sta TMP
            #if .byte TMP < #1 .or .byte TMP > #250
                jmp PICK_NUMBER_FROM_1_TO_250
            #end
            lda TMP
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
            mwa #$4000 TMP
            cpx #0
            bne SRN_2
            adw TMP #MAX_NAME_LEN*250
SRN_2       dey
            cpy #0
            beq SRN_1
            adw TMP #MAX_NAME_LEN
            jmp SRN_2
SRN_1       mwa #SCR_MEM_MENU TMP2
            rts

SETUP_RANDOM_NAME_BABSKIE
            jsr PICK_RANDOM_NAME_INDEX
            mwa #$4000+(NAMES_PER_SEX*MAX_NAME_LEN) TMP
            cpx #0
            bne SRNB_2
            adw TMP #MAX_NAME_LEN*250
SRNB_2      dey
            cpy #0
            beq SRNB_1
            adw TMP #MAX_NAME_LEN
            jmp SRNB_2
SRNB_1      mwa #SCR_MEM_MENU+(24*(320/8)+20) TMP2
            rts

PRINT_NAME
            ldx #MAX_NAME_LEN
            ldy #NAMES_BANK
            lda @TAB_MEM_BANKS,y
            sta PORTB

            ldy #0
PN_1        lda (TMP),y
            #if .byte @ > #90
                sec
                sbc #32
            #end
            sta (TMP2),y

            dex
            beq PN_X

            inw TMP
            inw TMP2
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

PPX_1       sta TMP2 ; Which bit

            pla
            tax

            mwa PIXEL_Y_TABLE,y TMP

            clc
            lda TMP
            adc PIXEL_X_TABLE_OFFSET,x
            sta TMP
            lda TMP+1
            adc #0
            sta TMP+1

            inw TMP
            inw TMP
            ldy #0
            lda (TMP),y
            ldy TMP2
            ora PIXEL_X_BIT_TABLE,y
            ldy #0
            sta (TMP),y

            rts
