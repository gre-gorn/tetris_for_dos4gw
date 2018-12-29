;Program do inicjacji karty dzwiekowej
;
;

.286
.model small

        assume cs:code,ds:data,ss:_stack

_stack segment stack use16 'stack'

        db 1024 dup(0)

_stack ends

data    segment public use16 'data'

dma_inf struc

lsb_adr         db 0
msb_adr         db 0
page_adr        db 0
lsb_ile         db 0
msb_ile         db 0

dma_inf ends


port            dw 0            ;in file SB port
active_int      db 0            ;in file DMA
tmp             db 0            ;in file IRQ number

dmainfo dma_inf<>
tmp2            db 0
which_dma       db 0

handle          dw 0
old_mask        db 0
old_mask2       db 0

old_int_tab     dw 0,0
                dw 0,0
                dw 0,0
                dw 0,0
                dw 0,0
                dw 0,0
                dw 0,0
                dw 0,0
                dw 0,0
                dw 0,0
                dw 0,0
                dw 0,0
                ;  0   1   2   3
dma_ports_tab   db 87h,83h,81h,82h
fname           db 'test.wav',0
sndcfg          db 'sound.cfg',0
new_line        db 0dh,0ah,'$'

hex_data        db '0000',0dh,0ah,'$'

_error          db 0dh,0ah,'Your Sound Card does',27h
                db 'nt work properly or is not installed.',0ah,'$'

_present        db 0dh,0ah,'Ok. Your Sound Hardware is working'
                db ', you can sleep now.',0dh,0ah,'$'

f_err           db 'Something went wrong with your hard disk!',0dh,0ah
                db 'Maybe there was',27h,'nt a file?',0dh,0ah,'$'

int_no          db 'There were problems with detection IRQ!!!',0dh,0ah,'$'
dma_no          db 'There were problems with detection DMA!!!',0dh,0ah,'$'

testing_irqs    db 'Searching IRQ number.....$'
testing_sb_port db 'Searching for SB port....$'
testing_dma     db 'Testing DMA Channels.....$'

data ends

code segment public use16 'code'

zero_dsp        MACRO

        call reset_dsp

        ENDM

wait_dsp        MACRO

        mov dx,[port]
        add dx,0ch
        in al,dx
        or al,al
        js $-3

        ENDM

my_lds  MACRO

        mov ax,seg data
        mov ds,ax
        push ds
        pop es

        ENDM

delay   MACRO times

        mov cx,times
        call wsync
        loop $-3

        ENDM

load_file       MACRO ile

        call f_open
        push bx
        mov cx,ile
        call f_read
        pop bx
        call f_close

        ENDM

print   MACRO from

        my_lds
        mov dx,offset from
        mov ah,09h
        int 21h

        ENDM

;obsluga przerwan wywolanych prze DMA's
;

new_int PROC

new_int_02:

        pusha
        mov al,02h      ;daj znac ze to jest to
        jmp obsluga

new_int_03:

        pusha
        mov al,03h      ;daj znac ze to jest to
        jmp obsluga


new_int_05:

        pusha
        mov al,05h      ;daj znac ze to jest to
        jmp obsluga

new_int_07:

        pusha
        mov al,07h      ;daj znac ze to jest to
        jmp obsluga


new_int_0a:

        pusha
        mov al,0ah      ;daj znac ze to jest to


obsluga:

        mov dx,seg data
        mov ds,dx
        mov ds:active_int,al
        mov ah,al

        mov dx,ds:port
        add dx,0eh
        in al,dx

        mov dx,20h
        cmp ah,07h
        jl obsl0
        add dx,80h

obsl0:

        mov al,20h      ;send an EOI
        out dx,al

        popa
        iret            ;no bo przerwanie

new_int ENDP



;w AL=numer przerwania
;w si offset danych

get_vect        PROC

        pusha
        push si
        mov ah,35h
        int 21h
        pop si
        xor ax,ax
        mov al,[tmp2]   ;oto wektor
        sub al,02h      ;odejmij
        shl ax,2
        add si,ax
        mov dx,seg data
        mov ds,dx
        mov ds:[si],bx
        mov bx,es
        mov ds:[si+2],bx

        popa
        ret

get_vect        ENDP

set_vect        PROC

        pusha
        mov ds,dx       ;tutaj segment
        mov dx,bx       ;tutaj offset
        mov ah,25h
        int 21h
        popa

        ret

set_vect        ENDP

f_error PROC

        mov ax,seg f_err
        mov ds,ax
        mov dx,offset f_err
        mov ah,09h
        int 21h
        mov ax,4c00h
        int 21h

f_error ENDP


f_open  PROC

        mov ah,3dh
        mov dx,seg fname
        mov ds,dx
        mov al,0                ;do oczytu
        mov dx,offset fname
        int 21h
        jc f_error
        mov bx,ax               ;przekaz uchwyt do BX
        ret

f_open  ENDP

f_read  PROC

        mov ah,3fh
        mov dx,seg f_bufor
        mov ds,dx
        mov dx,offset f_bufor
        int 21h
        jc f_error
        ret

f_read ENDP

f_write  PROC

        mov ah,40h
        mov dx,seg data
        mov ds,dx
        mov dx,offset data
        int 21h
        jc f_error
        ret

f_write ENDP

f_close PROC

        mov ah,3eh
        int 21h
        jc f_error
        ret

f_close ENDP

f_new_file      PROC

        pusha

        mov dx,seg sndcfg
        mov cx,0      ;bez atrybutow
        mov ds,dx
        mov ah,3ch
        mov dx,offset sndcfg
        int 21h
        jnc f_nf_0
        jmp f_error

f_nf_0:

        mov bx,ax
        my_lds
        mov [handle],bx
        popa

        ret

f_new_file      ENDP

;w al numer przerwania
;w si offset danych do przechowania starego wektora
;w bx offset procedury oblugi

get_set_ints    PROC

        pusha
        mov [tmp2],al
        cmp al,07h      ;czy mniejsze = 7?
        jle gsi0        ;tak!
        add al,61h      ;nie

gsi0:

        add al,08h
        ;zapamietaj przerwanie
        call get_vect

        ;ustaw teraz przerwanie
        mov dx,cs
        call set_vect
        my_lds
        mov cl,[tmp2]
        call mask_irqs

        popa
        ret

get_set_ints    ENDP

;w al numer przerwania
;w si offset tablicy

oddaj_irqs      PROC

        pusha

        mov dl,al
        mov ch,al
        my_lds
        mov al,dl

        cmp al,07h
        jle oi0
        add al,61h

oi0:

        add al,08h

        ;ustaw teraz stare przerwanie
        xor dh,dh
        sub dl,02h
        shl dx,2        ;adres w mojej tablicy
        add si,dx

        mov dx,[si+2] ;seg
        mov bx,[si]   ;offset
        call set_vect
        mov cl,ch       ;ktore irq
        call clear_irqs

        popa
        ret


oddaj_irqs      ENDP

wsync   PROC

        mov dx,03dah

wsync1:

        in al,dx
        test al,8
        je wsync1

        ret


wsync   ENDP

mask_irqs       PROC

        pusha
        cli

        mov bx,01h
        shl bx,cl
        not bx
        mov dx,21h

        cmp cl,07h ;ktore przerwanie?
        jle mi0

        add dx,80h
        mov bl,bh

mi0:

        in al,dx
        and al,bl
        out dx,al

        sti
        popa
        ret

mask_irqs       ENDP

clear_irqs       PROC

        pusha
        my_lds
        mov ch,[old_mask]
        cli
        mov dx,21h
        mov bx,01h
        shl bx,cl

        cmp cl,07h
        jle ci0

        add dx,80h
        mov bl,[old_mask2]
        mov [old_mask],bl
        mov bl,bh

ci0:

        in al,dx
        or al,bl
        and al,[old_mask]
        out dx,al

        my_lds
        mov [old_mask],ch
        sti
        popa
        ret

clear_irqs       ENDP

reset_dsp       PROC

        pusha

        my_lds
        mov dx,[port]
        add dx,06h
        mov al,1
        out dx,al

        delay 50

        mov dx,[port]
        add dx,06h
        mov al,0
        out dx,al

        delay 100

        mov dx,[port]
        add dx,0eh
        in al,dx
        mov dx,[port]
        add dx,0ah
        mov cx,100

reset_dsp0:

        in al,dx
        cmp al,0aah
        jz good
        loop reset_dsp0

        popa
        stc
        ret

good:

        popa
        clc
        ret

reset_dsp       ENDP

make_irqs       PROC

        pusha

        ;zapamietaj stare maski przerwan
        in al,21h
        mov [old_mask],al
        in al,0a1h
        mov [old_mask2],al

        ;zrob porzadek z przerwaniami
        mov al,02h
        mov si,offset old_int_tab
        mov bx,offset new_int_02
        call get_set_ints

        mov al,03h
        mov si,offset old_int_tab
        mov bx,offset new_int_03
        call get_set_ints

        mov al,05h
        mov si,offset old_int_tab
        mov bx,offset new_int_05
        call get_set_ints

        mov al,07h
        mov si,offset old_int_tab
        mov bx,offset new_int_07
        call get_set_ints

        mov al,0ah
        mov si,offset old_int_tab
        mov bx,offset new_int_0a
        call get_set_ints

        ;a teraz sound card
        ;czy mozna zapisac?

        zero_dsp
        wait_dsp

        mov al,0f2h             ;zadaj przerwania
        out dx,al

        ;zaczekaj az zrobi sie przerwanie
        delay 200

        my_lds
        mov al,[active_int]
        mov [tmp],al
        zero_dsp

        ;zrob porzadek z przerwaniami
        mov al,02h
        mov si,offset old_int_tab
        call oddaj_irqs

        mov al,03h
        mov si,offset old_int_tab
        call oddaj_irqs

        mov al,05h
        mov si,offset old_int_tab
        call oddaj_irqs

        mov al,07h
        mov si,offset old_int_tab
        call oddaj_irqs

        mov al,0ah
        mov si,offset old_int_tab
        call oddaj_irqs

        popa
        ret

make_irqs  ENDP

dma_0_1_3     PROC

        pusha
        my_lds
        mov al,0
        mov [dmainfo.lsb_adr],al
        mov [dmainfo.msb_adr],al
        mov [dmainfo.page_adr],al
        mov [dmainfo.msb_ile],al
        inc al
        mov [dmainfo.lsb_ile],al

        cmp [active_int],0
        jnz dma_start
        mov al,0ffh
        mov [which_dma],al
        jmp dma_checked

dma_start:

        in al,021h
        mov [old_mask],al
        in al,0a1h
        mov [old_mask2],al

        mov al,[tmp]    ;ktore to przerwanie
        mov si,offset old_int_tab
        mov bx,offset new_int_02
        cmp al,08h
        jb dma_gut
        mov bx,offset new_int_0a

dma_gut:

        call get_set_ints
        my_lds
        mov [active_int],0      ;wyzeruj
        mov al,01h
        mov [which_dma],al
        call test_dma
        my_lds
        cmp [active_int],0
        jnz dma_checked    ;ok!!! its working
        mov al,03h
        mov [which_dma],al
        call test_dma
        my_lds
        cmp [active_int],0
        jnz dma_checked
        mov al,00h
        mov [which_dma],al
        call test_dma
        cmp [active_int],0
        jnz dma_checked
        mov al,0ffh
        mov [which_dma],al

dma_checked:

        my_lds
        mov al,[which_dma]
        mov [active_int],al
        mov al,[tmp]
        mov si,offset old_int_tab
        call oddaj_irqs

        popa
        ret

dma_0_1_3     ENDP


test_dma        PROC

        call set_dma
        call blaster_dma

        ;zaczekaj az zrobi sie przerwanie
        delay 4

        zero_dsp
        wait_dsp
        mov al,0d0h     ;stop dma
        out dx,al

        ;blokuj dma
        my_lds
        mov al,[which_dma]
        add al,04h
        out 0ah,al

        ret

test_dma        ENDP


set_dma PROC

        pusha

        mov ah,al
        add al,04h      ;co znaczy ze trzeba ustawic maske
        out 0ah,al      ;a teraz do portu z tym
        ;clear
        mov al,0
        out 0ch,al

        ;adres danych
        mov ch,ah     ;zapamietaj ktore dma
        xor dh,dh
        mov dl,ah
        shl dx,1     ;razy dwa
        mov al,ds:dmainfo.lsb_adr
        out dx,al
        mov al,ds:dmainfo.msb_adr
        out dx,al
        push dx
        push ax
        my_lds
        pop ax
        shr ax,8    ;ah=>al
        mov si,ax
        add si,offset dma_ports_tab
        mov dx,[si]   ;do ktorego teraz portu wyslac
        mov al,ds:dmainfo.page_adr
        out dx,al

        ;ile przeslac?
        pop dx
        inc dx
        mov al,ds:dmainfo.lsb_ile
        out dx,al
        mov al,ds:dmainfo.msb_ile
        out dx,al

        ;playback
        mov al,48h
        add al,ch       ;dodaj numer kanalu
        out 0bh,al

        ;aktywuj dma
        mov al,ch    ;ktory to kanal?
        out 0ah,al

        popa
        ret

set_dma ENDP

blaster_dma     PROC

        pusha
        zero_dsp
        my_lds
        mov dx,[port]
        add dx,0ch
        mov al,40h
        out dx,al
        wait_dsp        ;                             Hz
        mov al,83h      ;time constant  256-(1000000/8000)=83h
        out dx,al
        wait_dsp
        mov al,14h      ;range of 4KHz to 23KHz of 8bit transfer
        out dx,al
        wait_dsp
        mov al,ds:dmainfo.lsb_ile
        dec al
        out dx,al               ;ile bedzie przeslanych -1
        wait_dsp
        mov al,ds:dmainfo.msb_ile
        out dx,al
        wait_dsp

        mov al,0d4h
        out dx,al

        popa
        ret

blaster_dma     ENDP

check_port      PROC

        pusha
        mov dx,0200h    ;base port
        mov [port],dx

check_next_port:

        my_lds
        mov dx,ds:port
        mov bx,10h      ;base offset
        add dx,bx       ;za pierwszym razem 210h,potem 220h itd
        mov ds:port,dx
        cmp dx,0260h
        jg cport_error
        zero_dsp
        jc check_next_port

        popa
        ret

cport_error:

        clc
        popa
        ret

check_port      ENDP

;Procedura przeliczajaca na szesnastkowy
;W EAX liczba do przeliczenia
;

make_hex        PROC

        mov cx,4
        mov di,offset hex_data
        add di,3

show_hex_l0:

        call put_hex
        shr ax,4
        loop show_hex_l0

        ret

put_hex:

        push ax

        and al,00001111b
        cmp al,09h              ;czy > 9
        jle put_hex_l0          ;nie
        add al,'A'-'0'-10       ;tak ,dodaj roznice 'A'-'0'

put_hex_l0:

        add al,'0'
        mov [di],al
        dec di

        pop ax

        ret


make_hex        ENDP

;zapisz konfiguracje
save_cfg        PROC

        call f_new_file
        push bx
        mov cx,4
        call f_write
        pop bx
        call f_close
        ret

save_cfg        ENDP

;in:   dx:ax seg:offset
;out:  dh=page          (dl destroyed)
;      ax=offset
;

make_page       PROC

        push bx

        mov bl,dh
        shr bl,4  ;isolate page number
        shl dx,4  ;absolute addres
        add ax,dx
        adc bl,0  ;complete addition ,
        mov dh,bl

        pop bx  ;DH:AX  page offset addres
        ret

make_page       ENDP

;***************************************************************************;

begin:

        ;wczytaj plik z danymi

        load_file 13430

        my_lds
        print testing_sb_port
        call check_port         ;znajdz port blastera
        jnc good3               ;jesli jest to szukaj dalej

        mov ax,seg _error
        mov ds,ax
        mov dx,offset _error
        mov ah,09h
        int 21h

        mov ax,4c00h
        int 21h


good3:

        ;wyswietl ze jest
        mov ax,[port]
        call make_hex
        print hex_data+1
        print testing_irqs
        call make_irqs
        jnc good4

        my_lds
        mov al,0
        mov [tmp],al
        jmp good5

good4:

        mov al,[tmp]
        xor ah,ah
        call make_hex
        print hex_data+1

        print testing_dma
        call dma_0_1_3
        jnc good5
        my_lds
        mov al,0
        mov [active_int],al

good5:

        mov al,[active_int]
        xor ah,ah
        call make_hex
        print hex_data+1

quit2dos:

        call save_cfg           ;zapisz ustawienia

        mov ax,4c00h
        int 21h

code ends

bufor   segment public 'bufor'

f_bufor db 0

bufor   ends

        end begin