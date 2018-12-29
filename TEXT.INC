;Procedury do wyswietlania tekstu
; w trybach tekstowych
;wyswietl dziesietnie
;         szesnastkowo
;         (?)binarnie
;wyswietl tekst
;musza byc zdefiniowane: newl & endl

data segment public 'data'

                db 'text data'
bin_data        db '00000000000000000000000000000000$'
hex_data        db '00000000$'
dec_data        db '00000000$'

data  ends

code  segment public 'code'

;Procedura wyswietlajaca binarnie
;W EAX to co do przeliczenia
;

ALIGN 4

show_bin        PROC

        mov edi,offset bin_data
        add edi,31
        mov ecx,32

show_bin_l0:

        shr eax,1
        setc [edi]
        add byte ptr [edi],'0'
        dec edi
        loop show_bin_l0

        ret

show_bin        ENDP

;Procedura przeliczajaca na szesnastkowy
;W EAX liczba do przeliczenia
;

ALIGN 4

show_hex        PROC

        mov ecx,8
        mov edi,offset hex_data
        add edi,7

show_hex_l0:

        call put_hex
        shr eax,4
        loop show_hex_l0

        ret

put_hex:

        push eax

        and al,00001111b
        cmp al,09h              ;czy > 9
        jle put_hex_l0          ;nie
        add al,'A'-'0'-10       ;tak ,dodaj roznice 'A'-'0'

put_hex_l0:

        add al,'0'
        mov [edi],al
        dec edi

        pop eax

        ret


show_hex        ENDP


;Procedura przeliczajaca
;to co w EAX w postaci BCD na tekst
;

ALIGN 4

show_dec        PROC

        mov edx,eax
        mov ecx,8
        mov edi,offset dec_data
        add edi,7

show_dec_l0:

        mov eax,edx
        and al,00001111b
        add al,'0'
        mov [edi],al
        dec edi
        shr edx,4

        loop show_dec_l0

        ret

show_dec        ENDP

code ends
