            ldy #0
            lda @TAB_MEM_BANKS,y
            sta PORTB

            ldx <DLIST_TITLE_SCREEN
            ldy >DLIST_TITLE_SCREEN
            stx SDLSTL
            sty SDLSTL+1
	        lda >NAMES_FONT
            sta CHBAS

            jsr SETUP_RANDOM_NAME
            jsr PRINT_NAME
            jsr SETUP_RANDOM_NAME_BABSKIE
            jsr PRINT_NAME

CHUJ        jmp CHUJ

SETUP_RANDOM_NAME
            mwa #$4000+12 TMP  ; This need to point to random name, for now, it's the first one
            mwa #$4000 TMP2
            rts

SETUP_RANDOM_NAME_BABSKIE
            mwa #$4000+(NAMES_PER_SEX*MAX_NAME_LEN) TMP  ; This need to point to random name, for now, it's the first one
            mwa #$4000+(24*(320/8)+20) TMP2
            rts

PRINT_NAME
            ldx #MAX_NAME_LEN

PN_1        ldy #NAMES_BANK
            lda @TAB_MEM_BANKS,y
            sta PORTB

            ldy #0
            lda (TMP),y
            pha

            ldy #0
            lda @TAB_MEM_BANKS,y
            sta PORTB

            pla
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