;Procedury do grafiki:
;          show_bmp_320(from)                - wyswietl BMP'a 320x200x256k
;          set_pal_ergb(from)                - ustaw palete RGB 4 bajtowa
;          fill_scr_320(color)               - wypelnij ekran kolorem
;          show_pal_320                      - pokaz palete w 256 kolumnach
;          draw_box_320(x1,y1,x2,y2,color)   - narysuj wypelniony prostokat
;          draw_text(x1,y1,from,font,color)  - wypisz tekst na x1,y1
;          get_image_320(x1,y1,x2,y2,where)  - zapamietej obszar ekranu
;          second_line(color)                - rysuje co druga linie kolorem
;          input_txt(x,y,where,font,color)   - wprowadz tekst na pozycji x,y
;

Input_Status_Register_One       equ     03dah
Adress_Write_Mode_Register      equ     03c8h
Data_Register                   equ     03c9h


data segment public 'data'

                db 'gp320 data'
help1           dd 0,0
x1              dw 0,0
y1              dw 0,0
x2              dw 0,0
y2              dw 0,0
t_x1            dw 0,0
t_y1            dw 0,0
font_offset     dd 0,0
text_offset     dd 0,0
input_x         dw 0,0
input_y         dw 0,0
input_color     db 0,0
input_ile       db 0,0
current_edi     dd 0,0

help1_ofs       dd 0
help2_ofs       dd 0
tcolor          db 0
transparent     db 0
tmp_char        db 128 dup(0)   ;jeden duzy znak 8x16

data ends

code segment public 'code'

;Optymalizowane dla Pentium Processors TM
;
;pozniej zrobic
;        fadingi (in&out)
;        przeplywy barw (from&to)
;        w tryb mono
;        BMP w okienku
;        Animki w okienku
;        animki na fullscreen
;        texty fontami
;

;Procedura przepisujaca z bufora na ekran jeden znak
;

ALIGN 4

show_char_xy    PROC

        pushad          ;zachowaj rejestry
        pushfd

        mov eax,0
        mov ecx,0

        ;wyznacz miejsce w ktorym rysowac
        mov ax,t_y1
        mov cx,t_y1
        shl eax,8
        mov ecx,eax
        shr eax,2
        add eax,ecx
        mov edi,0a0000h
        add di,t_x1             ;mamy poczatek
        add edi,eax
        ;teraz przepisz
        mov esi,offset tmp_char ;skad
        inc esi
        mov ecx,16              ;tyle linii

show_char_l0:

        mov ebx,8               ;tyle kolumn

show_char_l1:

        mov al,[esi]
        cmp al,transparent       ;czy to nie jest kolor przezroczysty?
        je show_char_l2         ;jest przezroczysty,pomin

        mov [edi],al            ;normalny,postaw punkt

show_char_l2:

        inc esi
        inc edi

        dec ebx
        jnz show_char_l1        ;to jeszcze nie koniec

        add edi,312
        dec ecx
        jnz show_char_l0        ;jeszcze jedna linia?

        add t_x1,8

        mov eax,0
        mov edi,offset tmp_char
        mov ecx,32
        rep stosd
        popfd
        popad                   ;odtworz rejestry
        ret

show_char_xy    ENDP

;Procedura wypisujaca tekst odpowiednim fontem w kolorze color
;w EDI adres tekstu do wyswietlenia
;w ESI adres fontow
;w AL kolor
;w AH kolor przezroczysty
;w EBX x1,y1

ALIGN 4

draw_text       PROC

        mov help1_ofs,esi

        mov t_y1,bx             ;zachowaj x1,y1
        shr ebx,16
        mov t_x1,bx

        mov transparent,ah
        mov tcolor,al

        ;zacznij konwersje znaku
        mov bp,t_x1

draw_text_l0:

        mov esi,offset tmp_char ;jeden znak bufor
        mov help2_ofs,esi

        mov edx,0               ;zeruj na potem
        mov dl,[edi]            ;pobierz pierwsza litere
        cmp dl,endl             ;czy to koniec linii
        jne draw_t_l0           ;nie , nie koniec linii
        mov t_x1,bp
        inc edi
        jmp draw_text_l0

draw_t_l0:

        cmp dl,newl             ;czy to nowa linia
        jne draw_t_l1
        inc edi
        add t_y1,15
        jmp draw_text_l0

draw_t_l1:

        cmp dl,'$'
        jne draw_text_l1        ;jeszcze nie koniec

        ret

draw_text_l1:

        mov ebx,0               ;ile linii sprawdzane dalej
        shl edx,4               ;DL*16 adres litery
        mov esi,help1_ofs
        mov help1,esi
        add help1,edx           ;offset znaku w tablicy fontow

draw_text_l2:

        mov esi,help1            ;gdzie sa fonty
        add esi,ebx              ;dodaj linie
        mov al,[esi]    ;ESI+(DL*16)
                                ;no to mam kolejna linie

        mov ecx,8              ;ile kolumn

draw_text_l3:

        mov ah,tcolor
        inc help2_ofs
        mov esi,help2_ofs

        shl al,1               ;next pixel
        jc draw_text_l4        ;jest ustawiony

        mov ah,transparent

draw_text_l4:

        mov [esi],ah            ;ustawiony

        dec ecx
        jnz draw_text_l3        ;jeszcze nie 8 kolumna

        inc ebx
        cmp ebx,16
        jb draw_text_l2        ;jeszcze nie 16 linia

        call show_char_xy       ;wypisz go na ekran
        inc edi
        jmp draw_text_l0        ;nastepny znak

draw_text       ENDP

;Procedura wypelniajaca ekran 320x200x256k kolorem w AL
;w trybie flat oczywiscie
;

ALIGN 4

fill_scr_320    PROC

        mov ah,al               ;zacznij rozszezanie na EAX
        push ax
        mov edx,0
        shl eax,16
        pop dx
        add eax,edx             ;roszezylismy do czterech bajtow
        mov edi,0a0000h         ;adres ekranu
        mov ecx,16000           ;bo uzywam stosd (czyli 4bajty)

fill_scr_l0:                    ;wypelnij

        mov [edi],eax
        add edi,4
        dec ecx
        jnz fill_scr_l0

        ret

fill_scr_320    ENDP

;Procedura wyswietlajaca obrazek na ekranie w trybie 13h
;W ESI offset danych

ALIGN 4

show_bmp_320    PROC

        mov edi,0a0000h         ;adres ekranu
        add edi,64000-320       ;adres ostatniej linii
        mov edx,200             ;16000*4=64000

lopek:

        mov ecx,80              ;dlugosc linii w dword

        repz movsd              ;przepisz na ekran

        sub edi,640
        dec edx
        cmp edx,0
        jnz lopek

        ret

show_bmp_320    ENDP

;pokaz palete na ekranie
;

show_pal_320    PROC

        mov ecx,0
        mov al,0                ;od koloru 0
        add edi,0a0000h         ;gdzie
        mov cl,255             ;ile kolumn

show_pal_l0:

        mov [edi],al
        inc al
        inc edi
        loop show_pal_l0

        ret

show_pal_320 ENDP


;Procedura ustawiajaca palete eRGB 256 kolorow
;W EDI offset palety
;ergb oznacza 4bajty w tablicy na kolor (RGB i jeden pusty)
;

ALIGN 4

set_pal_ergb    PROC

        mov ecx,255
        mov ebx,0

        mov dx,Adress_Write_Mode_Register
        mov al,bl
        out dx,al
        mov dx,Data_Register

mooo:
        mov al,[edi+2]
        shr al,2
        out dx,al
        mov al,[edi+1]
        shr al,2
        out dx,al
        mov al,[edi]
        shr al,2
        out dx,al
        inc bl
        add edi,4
        loop mooo

        ret

set_pal_ergb    ENDP

;Procedura rysujaca
;wypelniony prostokat
;w AL kolor
;w EBX wspolrzedne ebx<=x1 <=y1
;w ECX wspolrzedne ecx<=x2 <=y2
;
ALIGN 4

draw_box_320    PROC

        pushad

        mov ah,al               ;zacznij rozszezanie na EAX

        push ax

        mov edx,0
        shl eax,16

        pop dx

        add eax,edx             ;roszezylismy do czterech bajtow

        push eax                ;zachowaj na potem
        push ebx

        mov y1,bx               ;zapamietaj y1
        shr ebx,16
        mov x1,bx               ;tutaj zachowaj x1

        mov y2,cx               ;zapamietaj y2
        shr ecx,16
        mov x2,cx               ;a tutaj x2

        ;oblicz adres gornego rogu

        pop ebx

        and ebx,0000ffffh       ;tylko mlodsza polowka (czyli y1)
        sub edx,edx             ;zeruj dla poprawnego mnozenia
        mov eax,ebx             ;eax=y1
        shl eax,8
        mov ecx,eax             ;dlugosc linii
        shr eax,2
        add eax,ecx
        mov ebx,0               ;zeruj
        mov bx,x1               ;pobierz x1
        mov edi,0a0000h         ;adres ekranu
        add ax,bx               ;dodaj x1

        ;obliczylismy poczatek

        add edi,eax             ;dodaj wyliczona wspolrzedna

        ;oblicz szerokosc pudelka

        mov edx,0               ;na wszelkij sluczaj
        mov eax,edx
        mov ebx,edx

        mov ax,x2               ;pobierz x2
        mov bx,x1               ;pobierz x1
        sub ax,bx               ;wykonaj x2-x1
        mov ecx,0               ;zeruj ecx
        mov cx,ax               ;to co w ax do cx

        mov eax,0
        mov ebx,0
        mov ax,y2
        mov bx,y1
        sub eax,ebx             ;wykonaj y2-y1
        mov ebx,eax             ;mam ilosc linii

        ;wypelnij obszar

        pop eax                 ;pobierz zapamietany kolor

        mov edx,ecx             ;zachowaj dlugosc linii

draw_box_l0:

        mov ecx,edx             ;dlugosc linii
        rep stosb               ;rysuj linie
        sub edi,edx
        add edi,320             ;dalej
        dec ebx                 ;zmniejsz ilosc linii
        jnz draw_box_l0

        popad
        ret

draw_box_320    ENDP

;Procedura zapamietujaca obrazek (x1,y1,x2,y2)
;w EDI adres gdzie nalezy umiescic dane
;w EBX wspolrzedne ebx<=x1 <=y1
;w ECX wspolrzedne ecx<=x2 <=y2
;

ALIGN 4

get_image_320   PROC

        push ebx                ;zachowaj na potem

        mov y1,bx               ;zapamietaj y1
        mov y2,cx               ;zapamietaj y2
        shr ebx,16
        shr ecx,16
        mov x1,bx               ;tutaj zachowaj x1
        mov x2,cx               ;a tutaj x2

        ;oblicz adres lewego gornego rogu

        pop ebx

        and ebx,0000ffffh       ;tylko mlodsza polowka (czyli y1)
        mov eax,ebx             ;eax=y1
        shl eax,8
        mov ecx,eax             ;dlugosc linii
        shr eax,2
        add eax,ecx
        mov ebx,0               ;zeruj
        mov bx,x1               ;pobierz x1
        mov esi,0a0000h         ;adres ekranu
        add ax,bx               ;dodaj x1

        ;obliczylismy poczatek

        add esi,eax             ;dodaj wyliczona wspolrzedna

        ;oblicz szerokosc obrazu

        mov eax,0               ;na wszelkij sluczaj
        mov ebx,eax

        mov ax,x2               ;pobierz x2
        mov bx,x1               ;pobierz x1
        sub ax,bx               ;wykonaj x2-x1
        mov ecx,0               ;zeruj ecx
        mov cx,ax               ;to co w ax do cx

        mov eax,0
        mov ebx,0
        mov ax,y2
        mov bx,y1
        sub eax,ebx             ;wykonaj y2-y1
        mov ebx,eax             ;mam ilosc linii

        ;wypelnij obszar

        mov edx,ecx             ;zachowaj dlugosc linii

get_image_l0:

        mov ecx,edx             ;dlugosc linii
        rep movsb               ;zapamietuj obrazek
        sub esi,edx
        add esi,320             ;dalej
        dec ebx                 ;zmniejsz ilosc linii
        jnz get_image_l0

        ret

get_image_320   ENDP

;Procedura odtwarzajaca obrazek (x1,y1,x2,y2)
;w ESI adres skad pobierac dane
;w EBX wspolrzedne ebx<=x1 <=y1
;w ECX wspolrzedne ecx<=x2 <=y2
;
ALIGN 4

put_image_320   PROC

        cld
        push ebx                ;zachowaj na potem

        mov y1,bx               ;zapamietaj y1
        mov y2,cx               ;zapamietaj y2
        shr ebx,16
        shr ecx,16
        mov x1,bx               ;tutaj zachowaj x1
        mov x2,cx               ;a tutaj x2

        ;oblicz adres lewego gornego rogu

        pop ebx

        and ebx,0000ffffh       ;tylko mlodsza polowka (czyli y1)
        sub edx,edx             ;zeruj dla poprawnego mnozenia
        mov eax,ebx             ;eax=y1
        shl eax,8
        mov ecx,eax             ;dlugosc linii
        shr eax,2
        add eax,ecx
        mov ebx,0               ;zeruj
        mov bx,x1               ;pobierz x1
        mov edi,0a0000h         ;adres ekranu
        add ax,bx               ;dodaj x1

        ;obliczylismy poczatek

        add edi,eax             ;dodaj wyliczona wspolrzedna

        ;oblicz szerokosc obrazu

        mov edx,0               ;na wszelkij sluczaj
        mov eax,edx
        mov ebx,edx

        mov ax,x2               ;pobierz x2
        mov bx,x1               ;pobierz x1
        sub ax,bx               ;wykonaj x2-x1
        mov ecx,0               ;zeruj ecx
        mov cx,ax               ;to co w ax do cx

        mov eax,0
        mov ebx,0
        mov ax,y2
        mov bx,y1
        sub eax,ebx             ;wykonaj y2-y1
        mov ebx,eax             ;mam ilosc linii

        ;wypelnij obszar

        mov edx,ecx             ;zachowaj dlugosc linii

put_image_l0:

        mov ecx,edx             ;dlugosc linii
        rep movsb               ;przepisuj obrazek
        sub edi,edx
        add edi,320             ;dalej
        dec ebx                 ;zmniejsz ilosc linii
        jnz put_image_l0

        ret

put_image_320   ENDP

;Procedura wypelniajaca ekran 320x200x256k kolorem w AL
;co druga linie
;w trybie flat oczywiscie
;w DX ilosc linii do wyswietlenia
;w BX dlugosc linii
;w ECX x1,y1

ALIGN 4

second_line     PROC

        push eax

        shr bx,1                ;podziel rzez dwa
        mov x_help,bx           ;zapamietaj

        ;oblicz poczatek wyswietlania
        mov eax,0
        mov ax,cx             ;ax=y1
        shr ecx,16            ;cx=x1
        shl eax,8
        mov ebx,eax             ;dlugosc linii
        shr eax,2
        add eax,ebx
        mov edi,0a0000h         ;adres ekranu
        add edi,eax             ;dodaj (y1*320)
        add edi,ecx             ;dodaj x1

        pop eax

        mov ebx,0
        shr edx,1
        mov bx,x_help
        shl ebx,1

sec_line_l0:

        mov ecx,0
        mov cx,x_help

sec_line_l1:

        mov [edi],al
        add edi,2
        loop sec_line_l1

        add edi,320
        mov ecx,ebx             ;pobierz dlugosc linii
        sub edi,ebx
        rep stosb
        add edi,320
        sub edi,ebx

        dec edx
        jnz sec_line_l0

        ret

second_line     ENDP

;*************************************************************;
;w EBX = x,y
;w EDI = gdzie umieszczac znaki
;w CL  = ile znakow
;w AH  = kolor
;w ESI = adres fontow

ALIGN 4

input_txt       PROC

        pushad

        pushad
        get_mstat
        mov al,mouse.left
        mov byte ptr klawisz2,al
        wsync
        popad

        mov dword ptr font_offset,esi
        mov byte ptr input_ile,cl
        mov dword ptr text_offset,edi
        mov byte ptr input_color,ah
        mov word ptr input_y,bx
        shr ebx,16
        mov word ptr input_x,bx

        mov dl,current_dl
        xor dh,dh
        add di,dx       ;na koniec tekstu
        jmp input_4

input_0:

        get_mstat
        mov al,mouse.left
        cmp al,1
        jnz input_01
        cmp al,klawisz2
        jnz input01

input_01:

        mov byte ptr klawisz2,al
        mov ah,0bh
        int 21h
        cmp al,0ffh
        jnz input_0
        mov ah,10h
        int 16h
        cmp al,1bh
        je input_exit_esc
        cmp al,0dh     ;czy to ENTER?
        jne input_1

input01:

        xor edx,edx
        mov al,'$'
        mov edi,text_offset
        mov dl,current_dl
        cmp dl,0
        je input_0

        mov [edi+edx+1],al
        jmp input_exit

input_1:

        cmp al,''
        jne input_2

        mov al,'_'
        mov dl,current_dl
        dec dl
        jns input_3
        inc dl
        jmp input_3

input_2:

        cmp al,'A'
        jl input_4
        cmp al,'z'
        jg input_4
        cmp al,'Z'
        jg input_22
        add al,32

input_22:

        cmp al,'a'
        jl input_4

        mov dl,current_dl
        inc dl
        cmp byte ptr input_ile,dl
        jge input_3
        dec dl

input_3:


        mov byte ptr current_dl,dl
        xor edx,edx
        mov dl,current_dl
        mov edi,text_offset

        cmp al,'_'
        jne input_33
        inc dl

input_33:

        add edi,edx
        dec edi
        mov [edi],al
        mov al,'$'
        mov [edi+1],al
        mov al,' '
        mov [edi+2],al

input_4:

        pushad
        pushad

        mov bx,input_x
        shl ebx,16
        mov bx,input_y
        xor ch,ch
        xor dx,dx
        mov cl,input_ile
        mov eax,8
        mul cl
        mov cx,input_x
        add cx,ax
        shl ecx,16
        mov cx,input_y
        add cx,16
        mov al,0
        wsync
        call draw_box_320

        popad

        mov edi,text_offset
        mov esi,font_offset
        mov bx,input_x
        mov ah,0
        shl ebx,16
        mov al,input_color
        mov bx,input_y
        call draw_text
        popad
        jmp input_0

input_exit:

        popad
        ret

input_exit_esc:

        popad
        mov eax,1bh
        ret


input_txt       ENDP

code ends