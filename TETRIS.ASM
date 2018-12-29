;Tetris ver 1.0
;Oczywiœcie tryb FLAT
;Mo¿e dzwiêki
;Mo¿e nawet Animki...!!!Huuurraaaa
;Tryb na pewno 13h
;

.486p
.model flat

       assume cs:code,ds:data,ss:_stack

time_info       STRUCT

hh      db 0
mm      db 0
sc      db 0
hd      db 0

time_info       ENDS

block_info      STRUCT

x_pos        dd 0
             dd 0
y_pos        dd 0
             dd 0
orientation  dw 0
             dw 0
which        db 0
             db 0
ccolor       db 0
             db 0
ncolor       db 0
             db 0
next         db 0
             db 0
szer         db 0
             db 0

block_info      ENDS

game_info       STRUCT

name    db 0
        db 'europa$$$'
        db 0
level   db 0
        db 0    ;w BCD
next    db 0
        db 0    ;1=widac,0=nie widac
score   dd 0
        dd 0    ;w BCD
lines   dd 0
        dd 0
blocks  dd 0
        dd 0

game_info       ENDS

shapes_of       STRUCT
;          xx,yy,xx,yy,xx,yy,xx,yy
Linia   db 00,00,01,00,02,00,03,00
Kwadrat db 00,00,01,00,00,01,01,01
Lskret  db 00,00,01,00,01,01,02,01
Rskret  db 02,00,01,00,01,01,00,01
Tshape  db 00,00,01,00,02,00,01,01
Relka   db 00,00,01,00,02,00,02,01
Lelka   db 00,00,01,00,02,00,00,01
        db 00,00,00,00,00,00,00,00

        db 00,00,00,01,00,02,00,03
        db 00,00,01,00,00,01,01,01
        db 01,00,00,01,01,01,00,02
        db 00,00,00,01,01,01,01,02
        db 01,00,00,01,01,01,01,02
        db 01,00,01,01,01,02,00,02
        db 00,00,01,00,01,01,01,02
        db 00,00,00,00,00,00,00,00

        db 00,00,01,00,02,00,03,00      ;Linia
        db 00,00,01,00,00,01,01,01      ;Kwadrat
        db 00,00,01,00,01,01,02,01      ;Lskret
        db 02,00,01,00,01,01,00,01      ;Rskret
        db 01,00,00,01,01,01,02,01      ;Tshape
        db 00,00,00,01,01,01,02,01      ;Relka
        db 00,01,01,01,02,01,02,00      ;Lelka
        db 00,00,00,00,00,00,00,00      ;null

        db 00,00,00,01,00,02,00,03      ;linia
        db 00,00,01,00,00,01,01,01      ;kwadrat
        db 01,00,00,01,01,01,00,02      ;lskret
        db 00,00,00,01,01,01,01,02      ;rskret
        db 00,00,00,01,00,02,01,01      ;tshape
        db 01,00,00,00,00,01,00,02      ;relka
        db 00,00,00,01,00,02,01,02      ;lelka
        db 00,00,00,00,00,00,00,00      ;null

shapes_of       ENDS

info_button     STRUCT

function        dd 0

fnt_buf         dd 0
fnt_col         db 0
tlenght         dw 0

xmin            dw 0
ymin            dw 0
xmax            dw 0
ymax            dw 0

mouse_click     db 0
status          db 0
c_button        db 0
c1              db 0
c2              db 0

caption         db 30 dup(0)

info_button     ENDS


fonts_lg        equ 4096
datas_lg        equ 0
music_lg        equ 0
sound_lg        equ 0
graph_lg        equ 65078
newl            equ 0dh
endl            equ 0ah
left_arrow      equ 4bh ;scancode
right_arrow     equ 4dh
up_arrow        equ 48h
down_arrow      equ 50h

        include macra.inc
        include file.inc        ;funkcje obslugi plikow
        include fuse.inc        ;ja wiem co to jest
        include mouse.inc       ;a tutaj obsluga mychy
        include gp320.inc       ;grafika
        include text.inc        ;funkcje tekstowe

code    segment  public 'code'

ALIGN 4

begin:
        jmp short main

        db 'WATCOM...What did you think about?'

main:

        jmp heeereee

;pusta funkcja
;

ALIGN 4

f_null  PROC

        ret

f_null  ENDP

;tutaj procedurka oczekujaca na ponowne klikniecie myszka
;lub jakiegokolwiek klawisza
;

f_pause PROC

        get_image 0,0,320,200,bufor
        wsync
        interlace 000,000,000,320,200
        mov ecx,600

f_pause_l0:

        wsync
        loop f_pause_l0

        wait_fmkey                      ;czekaj na wcisniecie klawisza
        wsync
        put_image 0,0,320,200,bufor
        mov ecx,200

f_pause_l1:

        wsync
        loop f_pause_l1

        ret

f_pause ENDP

;to jest fcja dla klawisza About
;

ALIGN 4

f_about PROC

;dialog x1,y1,szer,wys,c_gnd,c1,c2,which,f_buf,f_adr,bufor

 get_image 000,000,320,200,bufor
 interlace 000,000,000,320,200
 wsync
 dialog 009,009,301,181,028,026,030,button6,fonts_buf,f_dialog,graph_buf
 mhide_cur
 wsync
 put_image 000,000,320,200,bufor
 mshow_cur

        ret

f_about ENDP

;tu jest funkcja dialog dla klawisza About

ALIGN 4

f_dialog        PROC

;s_button _x1,_y1,sze,wys,cb,c1,c2,prz,ktorykl,jego_nazwa,_czcionka,fc,funkcja

 s_button 0144,160,032,020,045,042,047,000,button6,b_ok,fonts_buf,242,f_null
 button button6,0

        wsync
        print_13 018,016,015,000,fonts_buf,info
        wsync
        print_13 100,008,015,000,fonts_buf,przecinek

        wait_fmkey
        wsync
        button button6,1

        mov ecx,1000

f_dialog_l1:

        wsync
        loop f_dialog_l1

        ret

f_dialog        ENDP


;tutaj funkcja dla klawisza exit
;

ALIGN 4

f_exit  PROC

;s_button _x1,_y1,sze,wys,cb,c1,c2,prz,ktorykl,jego_nazwa,_czcionka,fc,funkcja

        mov ax,mouse.x_pos
        mov word ptr x_help,ax
        mov bx,mouse.y_pos
        mov word ptr y_help,bx

 s_button 032,090,240,020,45,42,47,000,button6,r_w_t_exit,fonts_buf,49,f_null


        get_image 000,000,320,200,graph_buf

        interlace 000,000,000,320,200
        mhide_cur
        wsync
        button button6,0

f_exit_l0:

        wsync
        wait_fkey

        cmp al,1bh      ;czy Esc
        jz f_exit_not
        cmp al,newl     ;czy Enter
        jnz f_exit_l3   ;nie
        jz e_quit

f_exit_l3:

        cmp al,'Y'
        jz e_quit
        cmp al,'y'
        jz e_quit
        cmp al,'N'
        jz f_exit_not
        cmp al,'n'
        jnz f_exit_l0

f_exit_not:

 s_button 032,090,240,020,45,42,47,000,button6,msg_exit2,fonts_buf,49,f_null
        wsync
        button button6,1
        mov ecx,3000

f_exit_l7:

        wsync
        loop f_exit_l7

        mov ax,word ptr x_help
        mov bx,word ptr y_help
        mshow_cur_xy ax,bx
        wsync
        put_image 000,000,320,200,graph_buf
        mshow_cur

        ret

e_quit:

 s_button 032,090,240,020,45,42,47,000,button6,msg_exit,fonts_buf,49,f_null
        wsync
        button button6,1
        mov ecx,5500

f_exit_l6:

        wsync
        loop f_exit_l6
        clr_buf
        jmp quit

f_exit  ENDP

;funkcja ktora zostanie wykonana
;po nacisnieciu klawisza 'Load' (Button1)
;
;

ALIGN 4

f_file  PROC

        wsync

;pokaz okineko
get_mstat
mov ax,mouse.y_pos
mov bx,mouse.x_pos
push ax
push bx

wsync
dialog 007,000,162,192,028,026,030,button6,fonts_buf+4096,f_file2,bufor

pop bx
pop ax
mov mouse.x_pos,bx
mov mouse.y_pos,ax
mshow_cur_xy bx,ax


        jmp show_all_blocks

f_file  ENDP

f_file2 PROC

        pusha
;s_button _x1,_y1,sze,wys,cb,c1,c2,prz,ktorykl,jego_nazwa,_czcionka,fc,funkcja

s_button 16,008,144,018,245,247,249,0,button7,bname7,fonts_buf+4096,242,f_save
s_button 16,032,144,018,245,247,249,0,button8,bname8,fonts_buf+4096,242,f_load
s_button 16,062,144,018,0,249,247,000,button6,bnull,fonts_buf,0,f_null

button button7,0
button button8,0
button button6,0

draw_boxx 016,057,161,061,242
draw_boxx 016,082,161,086,242

        print_13 028,090,230,000,fonts_buf,sorry_msg

        ;ustaw zakresy dla myszki
        mset_ver 012,083
        mset_hor 020,151
        mshow_cur

        mov ecx,600

f_bbb0:

        wsync
        loop f_bbb0

mshow_cur_xy 081,000
mov mouse.right,0
mov mouse.left,0

        clr_buf

file_0:

        push ds
        pop es
        get_mstat
        mov al,mouse.left
        mov byte ptr klawisz2,al
        wsync
        get_mstat

        cmp mouse.right,1
        jnz file_11
        jmp file_exit

file_11:

        mov ah,0bh
        int 21h
        cmp al,0ffh
        jnz file_2
        mov ah,10h
        int 16h
        cmp al,0dh      ;czy to Enter
        jz make_ok
        cmp al,'q'
        jz quit
        cmp al,'Q'
        jz quit
        jmp file_exit

file_2:

        mov al,mouse.left
        cmp al,1
        jnz file_0
        cmp al,klawisz2
        jnz make_ok
        jmp file_0

make_ok:

        mov ax,mouse.y_pos
        inc ax
        cmp ax,button7.ymin
        jl file_0
        cmp ax,button7.ymax
        jg file_1           ;next button
        cmp button7.status,0
        jnz file_0
        ;hited button
        mhide_cur
        mov button7.fnt_col,015
        wsync
        button button7,1
        mshow_cur
        jmp file_0

file_1:

        cmp ax,button8.ymin
        jl file_0
        cmp ax,button8.ymax
        jg file_3           ;next button
        cmp button8.status,0
        jnz file_0
        ;hited button
        mhide_cur
        mov button8.fnt_col,015
        wsync
        button button8,1
        mshow_cur
        jmp file_0

file_3:

        dec ax
        cmp ax,56
        jl file_0
        cmp ax,59
        jg file_4

        mhide_cur
        wsync
        draw_boxx 016,057,161,061,230
        mov ax,mouse.y_pos
        mov bx,mouse.x_pos
        push ax
        push bx

file_31:

        get_mstat
        cmp mouse.left,1
        jz file_31
        draw_boxx 016,057,161,061,242
        pop bx
        pop ax
        mov mouse.x_pos,bx
        mov mouse.y_pos,ax
        mshow_cur_xy bx,ax
        mshow_cur
        jmp file_0

file_4:

        cmp ax,81
        jl file_0
        cmp ax,84
        jg file_0

        mhide_cur
        wsync
        draw_boxx 016,082,161,086,230
        mov ax,mouse.y_pos
        mov bx,mouse.x_pos
        push ax
        push bx

file_41:

        get_mstat
        cmp mouse.left,1
        jz file_41
        draw_boxx 016,082,161,086,242
        pop bx
        pop ax
        mov mouse.x_pos,bx
        mov mouse.y_pos,ax
        mshow_cur_xy bx,ax
        mshow_cur
        jmp file_0

file_exit:

mhide_cur
mhide_cur

        mset_ver 012,083
        mset_hor 020,151

        ;ustaw zakresy dla myszki
        mset_ver 044,138
        mset_hor 204,303

        popa
        ret

f_file2 ENDP

;obluga zapisu pliku
;
;

f_save  PROC

        pushad

        mhide_cur
        mov cl,8
        mov ah,040
        mov edi,offset save_file
        mov esi,offset fonts_buf+4096
        mov bx,018
        shl ebx,16
        mov bx,064
        call input_txt
        cmp eax,1bh
        je  f_save_end

        mov edi,offset cur_path+1
        mov esi,offset save_file
        mov ecx,8

f_save_1:

        mov al,[esi]
        cmp al,'$'
        jz f_save_2
        cmp al,'_'
        jz f_save_2
        mov [edi],al
        inc esi
        inc edi
        loop f_save_1
        jmp f_save_3

f_save_2:

        mov al,' '
        mov [edi],al
        inc esi
        inc edi
        loop f_save_2

f_save_3:

        ;utworz nowy plik
        make_f cur_path,0
        mov ax,file.error_status
        shr ax,1
        jc error_msg
        ;zapisz informacje
        write_f file.current_id_handle,infos_lg-1,gameinfos
        mov ax,file.error_status
        shr ax,1
        jc error_msg
        ;zamknij dostêp do pliku
        close_f file.current_id_handle
        mov ax,file.error_status
        shr ax,1
        jc error_msg

f_save_end:

        call show_mesage
        mov button7.fnt_col,242
        wsync
        button button7,0
        mov byte ptr mouse.left,0
        mov ecx,600

f_save0:

        wsync
        loop f_save0

        mshow_cur

        popad
        ret

f_save  ENDP

;procedura wyswietlajaca blad
;

error_msg       PROC

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
        call draw_box_320

        mov edi,offset error_msg2
        mov esi,font_offset
        mov bx,input_x
        mov ah,0
        shl ebx,16
        mov al,037
        mov bx,input_y
        call draw_text

        mov button7.fnt_col,242
        wsync
        button button7,0
        mov button8.fnt_col,242
        wsync
        button button8,0
        mov byte ptr mouse.left,0

        mshow_cur

        popad
        popad

        ret

error_msg       ENDP

;odczyt pliku
;
;

f_load  PROC

        pushad
        pushad

        mov eax,0
        mov edi,offset studnia
        add edi,10

        mov ecx,120
        rep stosb

        popad

        mhide_cur
        mov cl,8
        mov ah,040
        mov edi,offset save_file
        mov esi,offset fonts_buf+4096
        mov bx,018
        shl ebx,16
        mov bx,064
        call input_txt
        cmp eax,1bh
        je  f_load_end

        mov edi,offset cur_path+1
        mov esi,offset save_file
        mov ecx,8

f_load_1:

        mov al,[esi]
        cmp al,'$'
        jz f_load_2
        cmp al,'_'
        jz f_load_2
        mov [edi],al
        inc esi
        inc edi
        loop f_load_1
        jmp f_load_3

f_load_2:

        mov al,' '
        mov [edi],al
        inc esi
        inc edi
        loop f_load_2

f_load_3:


        ;utworz nowy plik
        open_f cur_path+1,0
        mov ax,file.error_status
        shr ax,1
        jc error_msg
        ;zapisz informacje
        read_f file.current_id_handle,infos_lg-1,gameinfos
        mov ax,file.error_status
        shr ax,1
        jc error_msg
        ;zamknij dostêp do pliku
        close_f file.current_id_handle
        mov ax,file.error_status
        shr ax,1
        jc error_msg
        mov edi,offset save_file
        mov al,'_'
        mov [edi+9],al

f_load_end:

        call show_mesage
        mov button8.fnt_col,242
        wsync
        button button8,0
        mov byte ptr mouse.left,0
        mov ecx,600

f_load0:

        wsync
        loop f_load0

        draw_boxx 200,006,312,036,0
        cmp byte ptr game_i.next,0
        jz f_load_exit
        call show_next

f_load_exit:

        call show_infos
        wsync
        mshow_cur

        popad
        ret

f_load  ENDP


ALIGN 4

show_mesage     PROC

        pushad

        push ax
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
        call draw_box_320

        mov edi,offset msg_done
        pop ax
        cmp ax,1bh
        jne show_msg_1
        mov edi,offset msg_resign

show_msg_1:

        mov esi,font_offset
        mov bx,input_x
        mov ah,0
        shl ebx,16
        mov al,041
        mov bx,input_y
        call draw_text

        popad
        ret

show_mesage     ENDP

ALIGN 4

;obluga dla klawisza 'Options'
;

f_options  PROC

        wsync
;dialog x1,y1,szer,wys,c_gnd,c1,c2,which,f_buf,f_adr,bufor

 dialog 007,000,162,192,028,026,030,button6,fonts_buf+4096,f_opti,graph_buf

        ret

f_options  ENDP

f_opti  PROC

;s_button _x1,_y1,sze,wys,cb,c1,c2,prz,ktorykl,jego_nazwa,_czcionka,fc,funkcja

s_button 62,38,58,18,0,247,247,000,button6,bnull,fonts_buf,0,f_name

        button button6,0
        wsync
        print_13 016,004,015,000,fonts_buf,o_music
        print_13 092,004,015,000,fonts_buf,o_sound
        print_13 016,024,015,000,fonts_buf,o_level
        mov eax,0
        mov al,game_i.level
        print_13 064,024,042,000,fonts_buf,dec_data+6
        print_13 016,040,015,000,fonts_buf,o_name
        print_13 064,040,042,000,fonts_buf,game_i
        print_13 056,056,015,000,fonts_buf,o_sbset
        print_13 016,102,015,000,fonts_buf,o_info
        mov eax,0
        mov ax,port
        call show_hex
        print_13 096,056,042,000,fonts_buf,hex_data+5


        get_mstat
        mov al,mouse.left
        mov byte ptr klawisz2,al
        mov ax,mouse.x_pos
        push ax
        mov bx,mouse.y_pos
        push bx
        ;ustaw nowe zakresy
        mset_ver 012,083
        mset_hor 020,151
        mshow_cur
        mshow_cur
        clr_buf

f_opti_i:

        cmp word ptr music,0
        je f_opti_0

        print_13 064,004,042,000,fonts_buf,o_on
        jmp f_opti_1

f_opti_0:

        print_13 064,004,045,000,fonts_buf,o_off

f_opti_1:

        cmp word ptr sound,0
        je f_opti_2

        print_13 140,004,042,000,fonts_buf,o_on
        jmp f_opti_3

f_opti_2:

        print_13 140,004,045,000,fonts_buf,o_off

f_opti_3:

        wsync
        get_mstat
        cmp mouse.right,1
        je f_opti_exit
        mov al,mouse.left
        cmp al,0
        je f_opti_31
        cmp al,klawisz2
        je f_opti_31
        jne f_opti_35

f_opti_31:

        mov byte ptr klawisz2,al
        mov ah,0bh
        int 21h
        cmp al,0ffh
        jne f_opti_3
        mov ah,10h
        int 16h
        cmp al,0dh      ;czy to Enter
        je f_opti_35
        cmp al,'q'
        jz quit
        cmp al,'Q'
        jz quit
        cmp al,1ah      ;czy
        jne f_opti_exit
        xor word ptr music,1
        xor word ptr sound,1
        jmp f_opti_3

f_opti_35:

        mov ax,mouse.y_pos
        inc ax
        cmp ax,button6.ymin
        jl f_opti_3
        cmp ax,button6.ymax
        jg f_opti_3

        mhide_cur
        mov button6.c1,07
        mov button6.c2,07
        button button6,1
        mshow_cur
        jmp f_opti_i

f_opti_exit:

        mhide_cur
        ;ustaw zakresy dla myszki
        mset_ver 044,138
        mset_hor 204,303
        pop ax
        mov mouse.y_pos,ax
        pop bx
        mov mouse.x_pos,bx
        mshow_cur

        ret

f_opti  ENDP


f_name  PROC

        pushad
        mov al,current_dl
        push ax

        mov cx,5
        mov al,'$'
        push ds
        pop es
        mov edi,offset game_i
        repne scasb
        mov ax,6
        sub al,cl
        mov byte ptr current_dl,al
        mov cl,6        ;ile znakow
        mov ah,042      ;kolor
        mov edi,offset game_i           ;skad
        mov esi,offset fonts_buf        ;jakim fontem
        mov bx,064
        shl ebx,16
        mov bx,040
        call input_txt
        xor ecx,ecx
        mov cl,current_dl
        mov al,[edi+ecx]
        cmp al,'_'
        jne f_name_0
        mov al,'$'

f_name_0:

        mov byte ptr [edi+ecx],al
        mov button6.c1,247
        mov button6.c2,247
        button button6,0
        print_13 064,040,042,000,fonts_buf,game_i
        call show_infos
        get_mstat
        mov al,mouse.left
        mov byte ptr klawisz2,al
        pop ax
        mov byte ptr current_dl,al
        popad
        ret

f_name  ENDP

ALIGN 4

;tytaj wyciskam wcisniete klawisze!!
;

all_keys_off    PROC

        mov button1.fnt_col,242
        mov button2.fnt_col,242
        mov button3.fnt_col,242
        mov button4.fnt_col,242
        mov button5.fnt_col,242

        cmp button1.status,0
        jz check_but2

        mhide_cur
        wsync
        button button1,0
        mshow_cur
        jmp key_not_p2

check_but2:

        cmp button2.status,0
        jz check_but3

        mhide_cur
        wsync
        button button2,0
        mshow_cur
        jmp key_not_p2

check_but3:

        cmp button3.status,0
        jz check_but4

        mhide_cur
        wsync
        button button3,0
        mshow_cur
        jmp key_not_p2

check_but4:

        cmp button4.status,0
        jz check_but5

        mhide_cur
        wsync
        button button4,0
        mshow_cur
        jmp key_not_p2

check_but5:

        cmp button5.status,0
        jz key_not_p2

        mhide_cur
        wsync
        button button5,0
        mshow_cur

key_not_p2:

        ret

all_keys_off    ENDP


ALIGN 4

;sprawdz ktory przycisk nalezy uaktywnic
;

check_which_key PROC

        mov ax,mouse.y_pos
        inc ax
        cmp ax,button1.ymin
        jl key_not_p1

        cmp ax,button1.ymax
        jg next_button2

        cmp button1.status,0
        jnz key_not_p1

        mov button1.fnt_col,015

        mhide_cur
        wsync
        button button1,1
        mshow_cur
        jmp key_not_p1

next_button2:

        cmp ax,button2.ymin
        jg b2_not_pushed2

        cmp button1.status,0
        jz not_pushed1

        mov button1.fnt_col,242
        wsync
        button button1,0
        jmp key_not_p1

not_pushed1:

        cmp button2.status,0
        jz key_not_p1

        mov button2.fnt_col,242
        mhide_cur
        wsync
        button button2,0
        mshow_cur
        jmp key_not_p1

b2_not_pushed2:

        cmp ax,button2.ymax
        jg next_button3

        cmp button2.status,0
        jnz key_not_p1

        mov button2.fnt_col,015

        mhide_cur
        wsync
        button button2,1
        mshow_cur
        jmp key_not_p1

next_button3:

        cmp ax,button3.ymin
        jg b3_not_pushed3

        cmp button2.status,0
        jz not_pushed3

        mov button2.fnt_col,242
        wsync
        button button2,0
        jmp key_not_p1

not_pushed3:

        cmp button3.status,0
        jz key_not_p1

        mov button3.fnt_col,242
        mhide_cur
        wsync
        button button3,0
        mshow_cur
        jmp key_not_p1

b3_not_pushed3:

        cmp ax,button3.ymax
        jg next_button4

        cmp button3.status,0
        jnz key_not_p1

        mov button3.fnt_col,015

        mhide_cur
        wsync
        button button3,1
        mshow_cur
        jmp key_not_p1

next_button4:

        cmp ax,button4.ymin
        jg b4_not_pushed4

        cmp button3.status,0
        jz not_pushed4

        mov button3.fnt_col,242
        wsync
        button button3,0
        jmp key_not_p1

not_pushed4:

        cmp button4.status,0
        jz key_not_p1

        mov button4.fnt_col,242
        mhide_cur
        wsync
        button button4,0
        mshow_cur
        jmp key_not_p1

b4_not_pushed4:

        cmp ax,button4.ymax
        jg next_button5

        cmp button4.status,0
        jnz key_not_p1

        mov button4.fnt_col,015

        mhide_cur
        wsync
        button button4,1
        mshow_cur
        jmp key_not_p1

next_button5:

        cmp ax,button5.ymin
        jg b5_not_pushed5

        cmp button4.status,0
        jz not_pushed5

        mov button4.fnt_col,242
        wsync
        button button4,0
        jmp key_not_p1

not_pushed5:

        cmp button5.status,0
        jz key_not_p1

        mov button5.fnt_col,242
        mhide_cur
        wsync
        button button5,0
        mshow_cur
        jmp key_not_p1

b5_not_pushed5:

        cmp ax,button5.ymax
        jg key_not_p1

        cmp button5.status,0
        jnz key_not_p1

        mov button5.fnt_col,015

        mhide_cur
        wsync
        button button5,1
        mshow_cur

key_not_p1:

        jmp all_keys_off
        ret

check_which_key ENDP


ALIGN 4

;ustaw wszystko na nowo!!!
;

new_game        PROC

        pushad

        ;czysc mala studnie
        push ds
        pop es
        mov eax,0
        mov edi,offset studnia
        add edi,10


        mov ecx,120
        rep stosb

        call show_all_blocks

        mov word ptr game_over,0
        mov word ptr active.y_pos,1
        mov word ptr active.x_pos,4
        mov word ptr old_x_pos,4
        mov word ptr active.orientation,0
        mov word ptr old_orientation,0
        mov word ptr busy_flag,1
        mov dword ptr horiz_flag,1

        wsync
        rand8 20,time2
        inc al
        inc al
        mov byte ptr active.ccolor,al

        wsync
        rand8 18,time2
        inc al
        inc al
        mov byte ptr active.ncolor,al

        wsync
        mov eax,0
        rand8 6,time2                    ;wylicz pierwszy
        inc al
        mov byte ptr active.which,al

        wsync
        rand8 6,time2                    ;wylicz nastepny
        inc al
        mov byte ptr active.next,al

        mov dword ptr game_i.score,0    ;wyzeruj punktacje
        mov dword ptr game_i.lines,0    ;wyzeruj liczbe pelnych linii
        mov dword ptr game_i.blocks,0   ;wyzeruj liczbe spadnietych blokow

        mov word ptr newgame,1
        mov ax,levelh
        mov word ptr speed,ax

        popad

        ret

new_game        ENDP


ALIGN 4

;losuj nowy klocek
;

make_next       PROC

        mov eax,0

        mov word ptr at_down,0
        mov word ptr active.orientation,0
        mov word ptr busy_flag,1
        mov dword ptr horiz_flag,1
        mov word ptr active.x_pos,4
        mov word ptr old_x_pos,4
        mov word ptr active.y_pos,1

        mov al,active.ncolor
        mov byte ptr active.ccolor,al

        rand8 22,time2
        inc al
        inc al
        mov byte ptr active.ncolor,al   ;kolor dla next

        rand8 6,time2
        inc al
        mov bl,active.next
        mov byte ptr active.next,al
        mov byte ptr active.which,bl

        mov ax,levelh
        mov word ptr speed,ax

        ret


make_next       ENDP

;************************************************************************;
;procedury oblugujace calosc zasad tetrisa!!!!!
;************************************************************************;


ALIGN 4

;a teraz to wszystko pokaz na ekranie
;

show_all_blocks PROC

        wsync
        mov esi,offset studnia  ;gdzie jest mala studnia
        add esi,10              ;y+1
        mov ecx,0               ;wsp.y1

show_all_b0:

        mov eax,0
        mov ebx,0               ;wsp.x1

show_all_b1:

        pushad

        mov ah,[esi]            ;pobierz element
        shl ebx,4
        shl ecx,4
        add ebx,8
        mov x_help,bx
        mov y_help,cx
        add bx,15
        add cx,15
        mov x1_help,bx
        mov y1_help,cx
        mov dh,ah
        mov dl,ah
        cmp ah,0
        jnz show_all_gut
        inc dl
        inc dl
        dec dh
        dec dh

show_all_gut:

        dec dl
        dec dl
        inc dh
        inc dh
        mov color1,dl
        mov color2,dh
        mov color3,ah
        block_2

        popad

show_all_b2:

        inc esi
        inc ebx
        cmp ebx,10
        jl show_all_b1

        inc ecx
        cmp ecx,12
        jl show_all_b0

        ret

show_all_blocks ENDP


ALIGN 4
;narysuj w malej studni

draw_in_little  PROC

        pushad

        mov eax,0
        mov esi,offset elements         ;tutaj offset do tablicy

        mov al,active.which             ;ktory to element?
        dec al
        shl al,3                        ;wyznacz element
        add esi,eax
        mov ax,active.orientation       ;jaki obrot elementu
        shl eax,6                       ;eax*64
        add esi,eax

        mov eax,0
        mov ecx,4

run_in_s1:

        mov ebx,0
        mov edi,offset studnia          ;tutaj offset do tablicy
        mov bl,[esi]                    ;pobierz wsp.X
        add di,word ptr active.x_pos    ;dodaj polozenie na osi X
        add edi,ebx                     ;dodaj wsp.X
        inc esi
        mov bl,[esi]                    ;pobierz wsp.Y
        add bx,word ptr active.y_pos    ;dodaj polozenie na osi Y
        shl bx,3                        ;pomoz przez 8
        mov eax,ebx
        shr bx,2                        ;a tutaj przez dwa (razem *10)
        add eax,ebx
        add edi,eax
        mov dl,active.ccolor
        mov [edi],dl                    ;umiesc na poz.X,Y klocek
        inc esi
        dec ecx
        jnz run_in_s1

        popad
        ret

draw_in_little  ENDP

ALIGN 4
;skasuj na starej pozycji

clear_on_old    PROC

        pushad

        mov eax,0
        mov esi,offset elements         ;tutaj offset do tablicy

        mov al,active.which             ;ktory to element?
        dec al
        shl al,3                        ;wyznacz element
        add esi,eax
        mov ax,old_orientation       ;jaki obrot elementu
        shl eax,6                       ;eax*64
        add esi,eax

        mov eax,0
        mov ecx,4

clr_on_o0:

        mov ebx,0
        mov edi,offset studnia          ;tutaj offset do tablicy
        mov bl,[esi]                    ;pobierz wsp.X
        add di,word ptr old_x_pos       ;dodaj polozenie na osi X
        add edi,ebx                     ;dodaj wsp.X
        inc esi
        mov bl,[esi]                    ;pobierz wsp.Y
        add bx,word ptr active.y_pos    ;dodaj polozenie na osi Y
        dec bx
        shl bx,3                        ;pomoz przez 8
        mov eax,ebx
        shr bx,2                        ;a tutaj przez dwa (razem *10)
        add eax,ebx
        add edi,eax
        mov dl,0                        ;kolor=0,kasuj element
        mov [edi],dl
        inc esi
        dec ecx
        jnz clr_on_o0

        popad

        ret

clear_on_old    ENDP

ALIGN 4

;procedura najwazniejsza dla klockow
;wykonaj wsio w malej studni
;

run_in_studnia  PROC

        pushad
        mov eax,down_flag
        shr eax,1               ;czy o jeden nizej
        jnc run_in_no           ;to ta sama linia

        ;sprawdz czy cos jest na nowej pozycji
        call clear_on_old       ;skasuj na starej
        call check_it
        mov dword ptr down_flag,0
        mov word ptr no_of_usd_blck,0
        jmp run_in_sb

run_in_no:

        ;sprawdz czy cos jest na nowej pozycji

        inc word ptr active.y_pos
        call clear_on_old
        dec word ptr active.y_pos

        call check_it
        mov word ptr no_of_usd_blck,0

        ;wyrysuj w malej studni

run_in_sb:

        cmp word ptr game_over,0
        jnz run_in_exit

        call draw_in_little

run_in_exit:

        mov ax,active.x_pos
        mov word ptr old_x_pos,ax
        mov bx,active.orientation
        mov word ptr old_orientation,bx

        popad
        ret

run_in_studnia  ENDP

;Sprawdz czy jest zajeta nowa pozycja
;

check_it        PROC

        pushad

        mov eax,0
        mov esi,offset elements         ;tutaj offset do tablicy

        mov al,active.which             ;ktory to element?
        dec al
        shl al,3                        ;wyznacz element
        add esi,eax
        mov ax,active.orientation       ;jaki obrot elementu
        shl eax,6                       ;eax*64
        add esi,eax

        mov eax,0
        mov ecx,4
        mov edx,eax

chk_it_s2:

        mov ebx,0
        mov edi,offset studnia          ;tutaj offset do tablicy
        mov bl,[esi]                    ;pobierz wsp.X
        add di,word ptr active.x_pos    ;dodaj polozenie na osi X
        add edi,ebx                     ;dodaj wsp.X
        inc esi
        mov bl,[esi]                    ;pobierz wsp.Y
        add bx,word ptr active.y_pos    ;dodaj polozenie na osi Y
        shl bx,3                        ;pomoz przez 8
        mov eax,ebx
        shr bx,2                        ;a tutaj przez dwa (razem *10)
        add eax,ebx
        add edi,eax
        mov dl,[edi]
        cmp dl,0                        ;sprawdz czy cos jest na poz.X,Y
        jz chk_it_ok_s2                 ;jest pusty

        inc word ptr no_of_usd_blck

chk_it_ok_s2:

        inc esi
        dec ecx
        jnz chk_it_s2

        mov ax,no_of_usd_blck
        cmp ax,0
        jz chk_it_exit

        cmp word ptr active.y_pos,1
        jg chk_it_continue

        mov word ptr newgame,0
        mov word ptr game_over,1
        jmp chk_it_exit

chk_it_continue:

        mov eax,down_flag
        shr eax,1
        jnc chk_it_ok1_s2

        dec word ptr active.y_pos

chk_it_ok1_s2:

        mov ax,old_x_pos
        cmp ax,active.x_pos
        jz chk_it_ok1_s3

        mov word ptr active.x_pos,ax
        inc word ptr busy_flag

        mov eax,down_flag
        shr eax,1
        jnc chk_it_ok1_s4

        mov word ptr busy_flag,1
        jmp chk_it_ok1_s4

chk_it_ok1_s3:

        mov bx,old_orientation
        cmp bx,active.orientation
        jz chk_it_ok1_s4

        mov word ptr active.orientation,bx
        inc word ptr busy_flag

chk_it_ok1_s4:

        dec word ptr busy_flag
        mov ax,busy_flag        ;musi byc dwa razy zajete
        jns chk_it_exit         ;zeby zatrzymac klocek

        mov eax,1
        mov word ptr at_down,ax  ;daj znac ze na dole
        mov word ptr busy_flag,ax

chk_it_exit:

        popad
        ret

check_it        ENDP

;poszukaj calej linii, potem je skasuj efektownie????

search_for_line PROC

        pushad

        mov edi,offset studnia
        add edi,10
        push edi
        pop esi
        add edi,119
        mov ebx,10

s_f_next:

        mov word ptr no_of_usd_blck,0

s_f_l0:

        mov ecx,10

s_f_l1:

        mov al,[edi]
        cmp al,0
        jz s_f_l2
        inc word ptr no_of_usd_blck

s_f_l2:

        dec edi
        loop s_f_l1
        dec ebx
        js s_f_end_it
        cmp word ptr no_of_usd_blck,10   ;czy cala linia?
        jl s_f_next

        call obsun_calosc
        cmp edi,esi
        jg s_f_next

s_f_end_it:

        mov word ptr no_of_usd_blck,0
        popad
        ret

search_for_line ENDP

obsun_calosc    PROC

        push edi

obsun_0:

        mov al,[edi]
        mov [edi+10],al
        dec edi
        cmp edi,esi
        jg obsun_0

        inc word ptr skasowana
        inc dword ptr game_i.lines

        pop edi
        ret

obsun_calosc    ENDP

;in:   edx,eax     wartosci BCD ktore nalezy dodac
;out:  eax         wynik dodawania
;uzywam ecx jako licznika
;       ebx jako rejestru tmp
;zawartosc eax jest niszczona
;
;only 3 bytes   (24bits, maybe in future will be 32bits)
;

bcd_add PROC

        mov dword ptr bcd_add_help,0
        push edx
        push ecx
        push ebx
        mov ecx,3

bcd_add_0:

        add al,dl
        daa
        jnc bcd_add_1
        add ah,01h              ;dodaj 1 do starszej polowki bo CF=1

bcd_add_1:

        mov bl,al
        shl ebx,8
        shr eax,8
        shr edx,8
        loop bcd_add_0

        mov eax,ebx
        bswap eax

        pop ebx
        pop ecx
        pop edx
        ret

bcd_add_help    dd 0

bcd_add ENDP

;zrzuc na sam dol klocek
; myslalem ze to bedzie bardziej skomplikowane
;

push_it_down    PROC

        pusha

push_it_0:


        call run_in_studnia
        cmp word ptr at_down,0
        jne push_it_1
        stc
        setc down_flag
        inc word ptr active.y_pos
        jmp push_it_0

push_it_1:

        popa
        ret

push_it_down    ENDP


;procedura pokazujaca nastepny element
;
;
show_next       PROC

        pushad

        mov eax,0
        mov esi,offset elements
        mov al,active.next             ;ktory to element?
        dec al
        shl al,3                        ;wyznacz element
        add esi,eax                     ;orientation = 0

        mov ecx,4

show_nxt_0:

        mov eax,0
        mov al,[esi]            ;wsp.X
        shl al,3
        add ax,244
        mov x_help,ax
        add ax,7
        mov x1_help,ax
        inc esi
        mov eax,0
        mov al,[esi]            ;wsp.Y
        shl al,3
        add ax,13
        mov y_help,ax
        add ax,8
        mov y1_help,ax
        mov al,active.ncolor
        mov color3,al
        dec al
        mov color2,al
        inc al
        inc al
        mov color1,al

        push esi
        push ecx
        call show_little
        pop ecx
        pop esi
        inc esi
        loop show_nxt_0

        popad
        ret

show_next       ENDP

show_little     PROC

        block_2
        ret

show_little     ENDP


show_infos      PROC

        ;wyswietl game infos
        wsync
        put_image 248,155,64,64,under_counts
        mov eax,game_i.score
        call show_dec
        print_13 248,154,015,000,fonts_buf,dec_data+2
        mov eax,0
        mov al,game_i.level
        call show_dec
        print_13 248,170,015,000,fonts_buf,dec_data+6
        print_13 248,182,015,000,fonts_buf,game_i
        ret

show_infos      ENDP


read_files      PROC

        open_f title_bmp,00h                    ;otwórz tytu³
        read_f file.current_id_handle,graph_lg,graph_buf ;wczytaj obrazek do bufora
        close_f file.current_id_handle          ;zamknij dostêp do pliku

        ;wczytaj fonty
        open_f font1_fnt,00h
        read_f file.current_id_handle,fonts_lg,fonts_buf
        close_f file.current_id_handle

        open_f font2_fnt,00h
        read_f file.current_id_handle,fonts_lg,fonts_buf+4096
        close_f file.current_id_handle

        ret

read_files      ENDP


title_page      PROC

        set_pal_256 graph_buf+54                 ;ustaw paletê
        show_bmp_low graph_buf+54+1024           ;poka¿ rysunek

;        fadein 63

        ;wypisz wtepne informacje

        x=100
        y=18

;        print_13 x+000,y+000,009,000,fonts_buf,my_name
;        print_13 x+004,y+020,009,000,fonts_buf,my_firm
;        print_13 x+008,y+040,009,000,fonts_buf,str_date
;        print_13 x+004,y+060,009,000,fonts_buf,end_date
;        print_13 x-080,y+090,009,000,fonts_buf,my_rights
;        print_13 x+082,y-008,009,000,fonts_buf,przecinek

        wait_fmkey              ;czekaj na jakis klawisz

        ret

title_page      ENDP


init_buttons    PROC

        x=200
         ;inicjuj przyciski
 s_button x,042,112,018,245,247,249,0,button1,bname1,fonts_buf+4096,242,f_file
 s_button x,064,112,018,245,247,249,0,button2,bname2,fonts_buf+4096,242,f_options
 s_button x,086,112,018,245,247,249,0,button3,bname3,fonts_buf+4096,242,f_pause
 s_button x,108,112,018,245,247,249,0,button4,bname4,fonts_buf+4096,242,f_about
 s_button x,130,112,018,245,247,249,0,button5,bname5,fonts_buf+4096,242,f_exit
 s_button 006,000,163,192,000,249,247,0,button6,bnull,fonts_buf,000,f_null

        wsync
        button button1,0
        button button2,0
        button button3,0
        button button4,0
        button button5,0
        button button6,0

        ret

init_buttons    ENDP


init_game       PROC

        mov byte ptr current_dl,8
        mov word ptr music,0
        mov word ptr sound,0
        mov word ptr timef,1
        mov ax,19
        mov word ptr levelh,ax
        mov byte ptr game_i.next,0
        mov byte ptr game_i.next,1
        call new_game
        jmp show_next

init_game       ENDP

;Poczatek oblugi karty dzwiekowej
;

reset_dsp       PROC

        pusha

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


check_port      PROC

        pusha
        mov dx,0200h    ;base port
        mov [port],dx

check_next_port:

        push ds
        pop es
        mov dx,ds:port
        mov bx,10h      ;base offset
        add dx,bx       ;za pierwszym razem 210h,potem 220h itd
        mov ds:port,dx
        cmp dx,0260h
        jg cport_error
        call reset_dsp
        jc check_next_port

        popa
        ret

cport_error:

        mov ax,0
        mov ds:port,ax

        clc
        popa
        ret

check_port      ENDP


;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!;
;*********************************************************************;
;tu zaczyna sie glowny program                                        ;
;*********************************************************************;
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!;

heeereee:

;        przeinicjuj zegar z 18.2 na wyzsza czestotliwosc

        set_timer 0001h        ;yeahh!! this is faster than light

        push ds
        pop ax
        mov es,ax

        get_vect_rm 1bh,old_1b

;tutaj robie sobie siupy z Ctrl+Break
        get_vect_rm 2dh,old_vect

;znajdz port SB

        call check_port

;this mean that i haven't hooked this vector
;        set_vect_rm 1bh,old_vect

        set_mode_std 13h

        ;inicjuj myszke
        minit

        ;czytaj tytul i czcionki
        call read_files

;tutaj nalezy wygasic w jednym kroku { fadeout 1 }
;wejscie z fadingiem

        call title_page

;tu zaczyna sie graaaa!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!11

        open_f games_bmp,00h                    ;otwórz tytu³
        read_f file.current_id_handle,graph_lg,graph_buf ;wczytaj obrazek do bufora
        close_f file.current_id_handle          ;zamknij dostêp do pliku


        set_pal_256 graph_buf+54                 ;ustaw paletê
        show_bmp_low graph_buf+54+1024           ;poka¿ rysunek

        ;ustaw zakresy dla myszki
        mset_ver 044,138
        mset_hor 204,303

        call init_buttons

        ;wypisz tekst testowy
        print_13 200,154,003,000,fonts_buf,testing

        ;wypisz 'TETRIS'
        print_13 180,053,030,000,fonts_buf+4096,tetris_nm
        print_13 179,052,018,000,fonts_buf+4096,tetris_nm

        draw_boxx 009,000,168,24,0
        s_button 200,006,112,030,000,249,247,0,button6,bnull,fonts_buf,000,f_null

        button button6,0

        ;pokaz kursor myszki
        mshow_cur_xy 0,0

        call init_game

        get_image 248,155,64,64,under_counts

;glowna petla

main_0:

        clr_buf
        get_mstat
        mov al,mouse.left
        mov klawisz2,al

        get_time time
        mov help3,dl

main_1:

        get_time time           ;czekaj az tyknie sobie zegarek
        cmp help3,dl
        jz main_1

        ;tutaj bedzie aktualizacja grafiki

        cmp word ptr newgame,0        ;czy nowa gra zaczeta?
        jz check_clock                ;jeszcze nie

main_3:

        call run_in_studnia             ;wykonaj operacje w studni
        cmp word ptr game_over,0
        jnz main_ja_gut

        call show_all_blocks            ;teraz rzuc to na ekran

        dec word ptr speed             ;zmiejsz ilosc wywolan
        mov ax,word ptr speed
        jns main_ja_gut ;check_clock

        mov ax,levelh
        mov word ptr speed,ax                   ;ustaw na nowo licznik

        inc word ptr active.y_pos      ;obsun o jeden klocek
        stc
        setc down_flag

main_ja_gut:

        cmp word ptr at_down,0          ;czy klocek na samym dole?
        jz check_clock                  ;nie nie spadl na dno

        mov word ptr skasowana,0
        call search_for_line
        call search_for_line
        call search_for_line
        call search_for_line

        cmp dword ptr game_i.lines,10
        jle you_can_go                ;old level
        mov dword ptr game_i.lines,0
        dec word ptr levelh
        mov edx,0
        mov eax,1
        mov dl,game_i.level
        call bcd_add
        mov byte ptr game_i.level,al

you_can_go:

        mov ebx,0
        mov eax,05h
        mov ecx,0
        mov esi,offset score_tab        ;teblica przelicznika
        mov bx,levelh                   ;leveli
        shl ebx,3
        add esi,ebx
        mov edi,offset help_tab         ;pomocnicza do pobierania punktow
        mov cx,skasowana
        mov bl,[edi+ecx]
        shl bx,1
        add esi,ebx
        cmp cx,1
        jl main_ja_gut0
        mov ax,[esi]
        cmp cx,2
        jl main_ja_gut0
        mov ax,[esi]
        cmp cx,3
        jl main_ja_gut0
        mov ax,[esi]
        cmp cx,4
        jl main_ja_gut0
        mov ax,[esi]

main_ja_gut0:

        mov edx,game_i.score
        call bcd_add     ;24bits
        mov dword ptr game_i.score,eax
        mov word ptr skasowana,0
        call make_next                  ;wylosuj nastepny klocek
                                        ;a poprzedni przepisz jako bierzacy

        cmp game_i.next,0               ;czy wyswietlic podpowiedz
        jz main_3                       ;nie!
        draw_boxx 200,006,312,036,0
        call show_next

check_clock:

        cmp word ptr timef,0
        jz check_hited_keys

        call show_infos

check_hited_keys:

        mov ah,0bh
        int 21h
        cmp al,0ffh
        jnz main_not_pressed       ;nie wcisnieto klawisza

        ;tutaj sprawdze czy to sa klawisze strzalek

        mov dx,60h
        in al,dx
        cmp al,left_arrow       ;czy strzalka w lewo
        jnz next1

        ;z takich fragmentow zrobic procedury wolane przez call oczywizda
        mov ax,active.x_pos
        mov old_x_pos,ax
        dec word ptr active.x_pos
        mov ax,active.x_pos
        jns main_0

        inc word ptr active.x_pos       ;zwieksz aby bylo = 0
        inc ax
        mov old_x_pos,ax                ;=0
        jmp main_0

next1:

        cmp al,right_arrow      ;czy strzalka w prawo
        jnz next2

        mov ecx,0
        mov cl,active.which
        mov edx,0
        dec cl
        shl cx,2                ;*4
        mov dx,active.orientation
        add cx,dx
        mov edi,offset block_lg
        add edi,ecx

        mov ax,active.x_pos
        mov old_x_pos,ax
        inc word ptr active.x_pos
        mov ax,active.x_pos
        add al,[edi]
        cmp ax,10
        jle main_0
        dec word ptr active.x_pos
        sub al,[edi]
        dec ax
        mov old_x_pos,ax
        jmp main_0

next2:

        cmp al,up_arrow         ;czy strzalka do gory
        jnz next36

        mov ax,active.orientation
        mov word ptr old_orientation,ax
        inc word ptr active.orientation
        mov ax,active.orientation
        cmp ax,4
        jc next35
        dec ax
        mov word ptr old_orientation,ax
        mov ax,0
        mov word ptr active.orientation,ax

next35:

        push ax

        mov ecx,0
        mov cl,active.which
        mov edx,0
        dec cl
        shl cx,2                ;*4
        mov dx,active.orientation
        add cx,dx
        mov edi,offset block_lg
        add edi,ecx
        mov ax,active.x_pos
        add al,[edi]
        cmp ax,11
        jc next3

        mov ax,old_orientation
        mov word ptr active.orientation,ax

next3:

        pop ax

next36:

        cmp al,down_arrow
        jz next4
        jnz main_pressed

next4:

        call push_it_down      ;zrzuc na sam dol
        jmp main_0

main_not_pressed:

        get_mstat
        mov al,mouse.left
        cmp al,0
        je main_2
        cmp al,klawisz2
        jne its_left

main_2:

        call all_keys_off
        jmp main_0

main_pressed:

        cmp al,44h      ;czy to F10
        jz quit
        cmp al,3eh      ;czy to F4?
        jnz main_p1
        mshow_cur_xy 512,095
        jmp its_left

main_p1:

        cmp al,3dh      ;czy to F3
        jnz main_p2
        call new_game
        jmp main_0

main_p2:

        cmp al,3bh      ;czy to F1
        jnz main_p3
        mshow_cur_xy 512,051
        jmp its_left

main_p3:

        cmp al,3ch      ;czy to F2
        jnz main_p4
        mshow_cur_xy 512,073
        jmp its_left

main_p4:

        cmp al,58h      ;czy to F12
        jnz main_p5
        mshow_cur_xy 512,117
        jmp its_left

main_p5:

        cmp al,3fh      ;czy to F5?
        jne main_p6

        xor game_i.next,1
        draw_boxx 200,006,312,036,0
        cmp game_i.next,0
        jz main_0
        call show_next
        jmp main_0

main_p6:

        mov ah,10h
        int 16h
        cmp al,1bh      ;czy to Esc?
        jz quit_01      ;Tak ,wyjdz
        cmp al,0dh      ;czy to Enter? scancode=1ch(ascii=0dh)
        jz its_left
        cmp al,'q'
        jz quit
        cmp al,'Q'
        jz quit
        cmp al,'*'
        jnz main_0

        xor game_i.next,1
        draw_boxx 200,006,312,036,0
        cmp game_i.next,0
        jz main_0
        call show_next
        jmp main_0

quit_01:

        mshow_cur_xy 512,139
        get_mstat

its_left:

        mov byte ptr mouse.left,1
        call check_which_key
        clr_buf
        jmp main_0

quit:

        mhide_cur

        set_mode_std 03h      ;wrzuc tryb 03h

;        set_vect_rm 1bh,old_1b  ;oddaj stare przerwanie

;przywroc zegark

        set_timer 65535

        mov ax,4c00h            ;wyjdz do systemu
        int 21h


code ends


data    segment 'data'

;zmienne pomocnicze

dos_seg         dw 0
pmode_sel       dw 0

old_vect        dw 0
                dw 0
old_1b          dw 0
                dw 0

help_tab        db 000h,003h,002h,001h,000h
score_tab       dw 695h,395h,295h,245h,685h,385h,285h,235h
                dw 675h,375h,275h,225h,665h,365h,265h,215h
                dw 655h,355h,255h,205h,645h,345h,245h,195h
                dw 635h,335h,235h,185h,625h,325h,225h,175h
                dw 615h,315h,215h,165h,605h,305h,205h,155h
                dw 595h,295h,195h,145h,585h,285h,185h,135h
                dw 575h,275h,175h,125h,565h,265h,165h,115h
                dw 555h,255h,155h,105h,545h,245h,145h,095h
                dw 535h,235h,135h,085h,525h,225h,125h,075h
                dw 515h,215h,115h,065h,505h,205h,105h,055h

;                  y  x  dla orientation=0,1,2,3
block_lg        db 04,01,04,01 ;linia
                db 02,02,02,02 ;kwadrat
                db 03,02,03,02 ;lskret
                db 03,02,03,02 ;rskret
                db 03,02,03,02 ;tshape
                db 03,02,03,02 ;relka
                db 03,02,03,02 ;lelka

;dane o grze

gameinfos:

version         db '1.02'
save_file       db 'filename$ '
color1          db 0
color2          db 0
color3          db 0
help4           db 0
help3           db 0
klawisz         db 0
klawisz2        db 0
x_help          dw 0
y_help          dw 0
x1_help         dw 0
y1_help         dw 0
skasowana       dw 0
highscores      db '...','------','000000',newl,endl
                db '...','------','000000',newl,endl
                db '...','------','000000',newl,endl
                db '...','------','000000',newl,endl
                db '...','------','000000',newl,endl
                db '...','------','000000',newl,endl
                db '...','------','000000',newl,endl
                db '...','------','000000',newl,endl
                db '...','------','000000',newl,endl
                db '...','------','000000$'
w_score         dd 0
                db '$'
down_flag       dd 0
busy_flag       dw 0
no_of_usd_blck  dw 0
horiz_flag      dd 0
game_over       dw 0
current_dl      db 0
old_orientation dw 0
old_x_pos       dw 0
levelh          dw 0
speed           dw 0
music           dw 0            ;flaga dla muzyki
sound           dw 0            ;flaga dla dzwiekow
timef           dw 0            ;flaga dla czasu
at_down         dw 0
newgame         dw 0
which_game      dd 0            ;w BCD
elements        shapes_of<>
active          block_info<>
game_i          game_info<>
time            time_info<>
error_flg       dw 0
                dw 0
error_cod       dw 0
                dw 0
studnia         db 255,255,255,255,255,255,255,255,255,255
                db 000,000,000,000,000,000,000,000,000,000
                db 000,000,000,000,000,000,000,000,000,000
                db 000,000,000,000,000,000,000,000,000,000
                db 000,000,000,000,000,000,000,000,000,000
                db 000,000,000,000,000,000,000,000,000,000
                db 000,000,000,000,000,000,000,000,000,000
                db 000,000,000,000,000,000,000,000,000,000
                db 000,000,000,000,000,000,000,000,000,000
                db 000,000,000,000,000,000,000,000,000,000
                db 000,000,000,000,000,000,000,000,000,000
                db 000,000,000,000,000,000,000,000,000,000
                db 000,000,000,000,000,000,000,000,000,000
                db 255,255,255,255,255,255,255,255,255,255 ;aby mozna bylo
                                                           ;sprawdzic
time2           time_info<>
port            dw 0,0
                db '$oooo'
msg_done        db 'Done!!$'

infos_lg        equ $-gameinfos

;komunikaty

msg_exit        db 'Leaving best tetris...$'
msg_exit2       db 'This is right decision..$'
r_w_t_exit      db 'Really want to exit (y/n)?$'
error_msg2      db 'Error!$'
msg_resign      db 'Stopped!$'

info            db 'Grzegorz Gornisiewicz',newl,endl
                db 'Imagine Graphics',newl,endl
                db 'Copyright by Grzegorz Gornisiewicz',newl,endl
                db '04 august 1998',newl,newl,endl
                db 'F3 - new game | F4 - pause in game',newl,endl
                db 'Esc - exit?   | Q  - exit to system',newl,endl
                db 24,25,26,27,' - moving blocks',newl,endl
                db 'Tetris ver. 1.02',newl,endl             ;û=251
                db '$'

options         db 'Music               Sound',newl,endl
                db 'Your Name           Next block',newl,endl
                db 'Level               Time',newl,endl
                db '$'

my_name    db 'Grzegorz Gornisiewicz$'
my_firm    db 'Imagine Graphics$'
my_rights  db 'Copyright by Grzegorz Gornisiewicz$'
end_date   db '03 sierpnia 1998$'
str_date   db '03 lipca 1998$'
przecinek  db ',$'

o_info  db 'N/A=NOT AVAILABLE',newl,endl
        db '..TIME WAS GONE..',newl,endl
        db 'In version 1.5',newl,endl
        db 'sound and music',newl,endl
        db 'will be include',newl,endl
        db 'but not DMA....',newl,endl,'$'

testing         db 'Score:',newl,endl,'Level:',endl,newl,'Name :$'
tetris_nm       db 'T',newl,endl
                db 'E',newl,endl
                db 'T',newl,endl
                db 'R',newl,endl
                db 'I',newl,endl
                db 'S$'

sorry_msg       db newl,endl
                db 'In this version',newl,endl
                db 'file directory ',newl,endl
                db 'is  unavailable',newl,endl
                db '    sorry!!$'

;nazwy plikow oraz sciezki

cur_path        db '\filename.svt',0
title_bmp       db 'title.bmp',0
games_bmp       db 'games.bmp',0
font1_fnt       db 'font1.fnt',0
font2_fnt       db 'font2.fnt',0

datas_fname     db 'datas.dat',0
music_fname     db 'music.dat',0
sound_fname     db 'sound.dat',0


;zmienne , bufory itp.

button1 info_button<>
button2 info_button<>
button3 info_button<>
button4 info_button<>
button5 info_button<>
button6 info_button<>
button7 info_button<>
button8 info_button<>

tblock  db '$'
bnull   db '$'
bcont   db 'Continue$'
b_ok    db 'Ok$'
bname1  db 'File$'
bname2  db 'Options$'
bname3  db 'Pause$'
bname4  db 'About$'
bname5  db 'Exit$'
bname7  db 'Save$'
bname8  db 'Load$'

o_on            db 'N/A$'
o_off           db 'N/A$'
o_music         db 'music:$'
o_sound         db 'sound:$'
o_level         db 'level:$'
o_name          db 'name :$'
o_sbset         db 'port:',newl,endl
                db 'irq :N/A',newl,endl
                db 'dma :N/A',newl,endl,'$'

fonts_buf       db 4096*2 dup(0)
graph_buf       db 65078 dup(0)
bufor           db 64000 dup(0)
under_counts    db 8192 dup(0)

data ends

_stack segment stack 'stack'

        db 2048 dup(0)

_stack ends

        end begin
