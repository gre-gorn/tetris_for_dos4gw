code    segment public 'code'

;void wsync()
;void fill_320(color)
;void print_03(what)
;void set_mode_std(mode)
;void show_bmp_low(from)
;void open_f(fname,mode)
;void read_f(handle,how_much,where)
;void close_f(handle)
;void make_f(path,attr)
;void draw_boxx(x1,y1,x2,y2,color)
;void get_image(x1,y1,szer,wys,where)
;void put_image(x1,y1,szer,wys,_from)
;void minit()
;void mshow_cur(x,y)
;void mset_hor(minx,maxx)
;void mset_ver(miny,maxy)
;void mhide_cur()
;void set_pal_256(from)
;void s_button(x1,y1,szer,wys,c_button,c1,c2,click,which,caption,f_buf,f_col,f_adr)
;void block(x1,y1,szer,wys,c_block,c1,c2)
;void button(which,click)
;void print_13(x,y,color,transparent,font,what)
;void get_mstat()
;void dialog(_x1,_y1,_szr,_wys,c_gnd,c_1,c_2,wh,f1_buf,f1_adr,bufor)
;void wait_fkey()
;void interlace(bufor)
;void wait_fmkey()
;void set_mcur_xy x,y
;void clr_buf()
;void get_vect_rm(which,where)
;void set_vect_rm(which,from)
;void get_vect_pm(which,where)
;void set_vect_pm(which,from)
;void get_time(time)
;void set_time(time)
;void make_dec(from)
;void rand(zakres)
;void aloc_dos_mem(bytes,selector,segment)
;void free_dos_mem(selector)
;void set_timer(refresh)

delay   MACRO times
        local loopek
        
        mov cx,times
loopek:
        wsync
        loop loopek

        ENDM
        
set_timer       MACRO refresh

        mov al,00100100b
        out 43h,al
        mov ax,refresh
        out 40h,al
        mov ah,al
        out 40h,al

        ENDM

aloc_dos_mem    MACRO bytes,selector,segment

        mov ax,0100h
        mov bx,bytes
        shr bx,4
        int 31h
        mov word ptr error_cod,ax
        setc error_flg
        mov word ptr segment,ax
        mov word ptr selector,dx

        ENDM


free_dos_mem    MACRO selector

        mov ax,0101h
        mov dx,slector
        int 31h
        mov word ptr error_code,ax
        setc error_flag

        ENDM

block_2 MACRO

        inc word ptr x1_help
        inc word ptr y1_help
        draw_boxx [x_help],[y_help],[x1_help],[y1_help],color1
        inc word ptr x_help
        inc word ptr y_help
        draw_boxx [x_help],[y_help],[x1_help],[y1_help],color2
        dec word ptr x1_help
        dec word ptr y1_help
        draw_boxx [x_help],[y_help],[x1_help],[y1_help],color3

        ENDM



rand8   MACRO zakres8,tm

        get_time tm
        and dl,00111111b
        cmp dl,zakres8
        jb $+019
        and dl,dh
        cmp dl,zakres8
        jbe $+012
        shr dl,2
        cmp dl,zakres8
        jbe $+004
        mov dl,zakres8
        mov al,dl

        ENDM

_make_dec        MACRO from

        mov eax,dword ptr from
        call show_dec

        ENDM


set_time        MACRO t

        mov ah,2dh
        mov ch,t.hh
        mov cl,t.mm
        mov dh,t.sc
        mov dl,t.hd
        int 21h

        ENDM

get_time        MACRO t

        mov ah,2ch
        int 21h
        mov t.hh,ch
        mov t.mm,cl
        mov t.sc,dh
        mov t.hd,dl

        ENDM

set_vect_rm     MACRO which,from

        mov ax,0201h
        mov bx,which
        mov cx,from+2
        mov dx,from
        int 31h

        ENDM

get_vect_rm     MACRO which,where

        mov bx,which
        mov ax,0200h
        int 31h
        mov where,dx
        mov where+2,cx

        ENDM

set_vect_pm     MACRO which,from

        mov ax,0205h
        mov bl,which
        mov cx,word ptr from+4
        mov edx,from
        int 31h

        ENDM

get_vect_pm     MACRO which,where

        mov bl,which
        mov ax,0204h
        int 31h
        mov dword ptr where,edx
        mov word ptr where+4,cx

        ENDM

;czekaj na powrot pionowy plamki

wsync   MACRO

        push ax
        push dx

        mov dx,03dah

        in al,dx
        test al,8
        je $-3

        pop dx
        pop ax

        ENDM

clr_buf MACRO

        mov ah,0ch
        mov al,0ffh
        int 21h

        ENDM

wait_fmkey      MACRO

        clr_buf
        mov ax,mouse.x_pos
        mov bx,mouse.y_pos
        mov x_help,ax
        mov y_help,bx
        mov al,mouse.left
        mov byte ptr klawisz2,al

        get_mstat
        cmp mouse.left,0
        jz $+15
        mov al,byte ptr klawisz2
        cmp mouse.left,al
        jz $-25

        mov ah,0bh
        int 21h
        cmp al,0ffh             ;czy to ten sam klawisz?
        jz $+16                ;nie, zostal wcisniety inny

        get_mstat               ;pobierz status myszy
        cmp mouse.left,0        ;czy wcisnieto klawisz myszy?
        jz $-20                 ;czekaj dalej

        mov mouse.left,0
        mov ax,x_help
        mov bx,y_help
        set_mcur_xy ax,bx
        clr_buf

        ENDM

interlace       MACRO color,x,y,szer,wys

        mov al,color
        mov bx,szer
        mov edx,wys
        mov cx,x
        shl ecx,16
        mov cx,y
        call second_line

        ENDM


is_key  MACRO function

        mov dx,60h
        in al,dx
        cmp al,klawisz          ;czy to ten sam klawisz?
        jnz function            ;tak

        ENDM

wait_fkey       MACRO

        mov dx,60h
        in al,dx
        cmp al,klawisz          ;czy to ten sam klawisz?
        jz $-7                  ;tak

        mov ah,10h
        int 16h                 ;chce miec jego kod ASCII

        ENDM


dialog  MACRO _x1,_y1,_szr,_wys,c_gnd,c_1,c_2,wh,f1_buf,f1_adr,tmp

 get_image _x1,_y1,_szr+1,_wys+1,tmp
 mhide_cur
 s_button _x1,_y1,_szr,_wys,c_gnd,c_1,c_2,0,wh,bnull,f1_buf,0,f1_adr
 wsync
 button wh,0
 call dword ptr cs:[wh.function]
 wsync
 mshow_cur
 wsync
 put_image _x1,_y1,_szr+1,_wys+1,tmp

        ENDM

put_image       MACRO x1,y1,szer,wys,_from

        mov esi,offset _from
        mov bx,x1            ;x1
        mov cx,(x1+szer)     ;x2
        shl ebx,16
        shl ecx,16
        mov bx,y1            ;y1
        mov cx,(y1+wys)      ;y2
        call put_image_320

        ENDM

get_image       MACRO x1,y1,szer,wys,where

        mov edi,offset where
        mov bx,x1       ;x1
        mov cx,(x1+szer)  ;x2
        shl ebx,16
        shl ecx,16
        mov bx,y1       ;y1
        mov cx,(y1+wys)   ;y2
        call get_image_320

        ENDM


get_mstat       MACRO

        call mstatus_mouse

        ENDM


button_caption  MACRO x,y,color,transparent,font,what

        mov al,color
        mov bx,x
        mov ah,transparent
        mov esi,font
        mov edi,offset what
        shl ebx,16
        mov bx,y
        call draw_text

        ENDM

print_13        MACRO x,y,color,transparent,font,what

        mov al,color
        mov bx,x
        mov ah,transparent
        mov esi,offset font
        shl ebx,16
        mov edi,offset what
        mov bx,y
        call draw_text

        ENDM

button  MACRO w,click

        mov  w.status,click

ife click=0

        inc w.xmax
        inc w.ymax
        draw_boxx [w.xmin],[w.ymin],[w.xmax],[w.ymax],[w.c1]
        inc w.xmin
        inc w.ymin
        draw_boxx [w.xmin],[w.ymin],[w.xmax],[w.ymax],[w.c2]
        dec w.xmax
        dec w.ymax
        draw_boxx [w.xmin],[w.ymin],[w.xmax],[w.ymax],[w.c_button]

        ;oblicz srodek przycisku

        push w.xmin
        push w.ymin

        mov cx,w.xmin
        mov ax,w.xmax
        sub ax,cx
        mov cx,w.tlenght        ;dlugosc tekstu
        shl cx,3                ;pomnoz przez 8
        sub ax,cx               ;oblicz wps.x dla tekstu
        shr ax,1                ;wynik podziel przez 2
        add w.xmin,ax
        add w.xmin,4

        mov cx,w.ymin
        mov ax,w.ymax
        sub ax,cx
        mov cx,7                ;polowa wys. tekstu
        shr ax,1                ;podziel przez 2
        sub ax,cx               ;oblicz wsp.y dla tekstu
        add w.ymin,ax

  button_caption [w.xmin],[w.ymin],[w.fnt_col],0,[w.fnt_buf],w.caption

        pop w.ymin
        pop w.xmin

        dec w.ymin
        dec w.xmin

else

        inc w.xmax
        inc w.ymax
        draw_boxx [w.xmin],[w.ymin],[w.xmax],[w.ymax],[w.c2]
        inc w.xmin
        inc w.ymin
        draw_boxx [w.xmin],[w.ymin],[w.xmax],[w.ymax],[w.c1]
        dec w.xmax
        dec w.ymax
        draw_boxx [w.xmin],[w.ymin],[w.xmax],[w.ymax],[w.c_button]

        ;oblicz srodek przycisku

        push w.xmin
        push w.ymin

        mov cx,w.xmin
        mov ax,w.xmax
        sub ax,cx
        mov cx,w.tlenght        ;dlugosc tekstu
        shr ax,1                ;podziel przez 2
        shl cx,2                ;pomnoz przez 4 (polowa tekstu)
        sub ax,cx               ;oblicz wps.x dla tekstu
        add w.xmin,ax
        add w.xmin,4
        inc w.xmin

        mov cx,w.ymin
        mov ax,w.ymax
        sub ax,cx
        mov cx,7                ;polowa wys. tekstu
        shr ax,1                ;podziel przez 2
        sub ax,cx               ;oblicz wsp.y dla tekstu
        add w.ymin,ax
        inc w.ymin

  button_caption [w.xmin],[w.ymin],[w.fnt_col],0,[w.fnt_buf],w.caption

        pop w.ymin
        pop w.xmin

        dec w.ymin
        dec w.xmin

        call dword ptr cs:[w.function]

endif

        ENDM

s_button MACRO x1,y1,szr,wys,c_but,c1_,c2_,click,w,cption,f_buf,f_col,f_adr

        mov w.function,offset f_adr
        mov w.fnt_buf,offset f_buf
        mov w.fnt_col,f_col

        mov edi,offset cption
        mov esi,edi
        mov al,'$'
        mov ecx,29
        repnz scasb

        mov ecx,edi
        sub ecx,esi
        mov w.tlenght,cx
        mov edi,offset w.caption
        rep movsb

        mov w.xmin,x1
        mov w.ymin,y1
        mov w.xmax,x1+szr
        mov w.ymax,y1+wys

        mov w.status,byte ptr click
        mov w.c_button,byte ptr c_but
        mov w.c1,byte ptr c1_
        mov w.c2,byte ptr c2_

        ENDM


block   MACRO x1,y1,szer,wys,c_block,c1,c2,click

ife click=0

        draw_boxx x1,y1,x1+szer+1,y1+wys+1,c1
        draw_boxx x1+1,y1+1,x1+szer+1,y1+wys+1,c2
        draw_boxx x1+1,y1+1,x1+szer,y1+wys,c_block

else

        draw_boxx x1,y1,x1+szer+1,y1+wys+1,c2
        draw_boxx x1+1,y1+1,x1+szer+1,y1+wys+1,c1
        draw_boxx x1+1,y1+1,x1+szer,y1+wys,c_block

endif

        ENDM

mhide_cur MACRO

        call mhide_mouse_cur

        ENDM

mset_ver MACRO _miny,_maxy

        mov mouse.miny,word ptr _miny
        mov mouse.maxy,word ptr _maxy
        call mset_vertical

        ENDM

mset_hor MACRO _minx,_maxx

        mov mouse.minx,word ptr _minx
        shl mouse.minx,1
        mov mouse.maxx,word ptr _maxx
        shl mouse.maxx,1
        call mset_horizontal

        ENDM

set_mcur_xy   MACRO x,y

        mov mouse.x_pos,x
        mov mouse.y_pos,y
        call mset_mouse_xy

        ENDM

mshow_cur_xy MACRO x,y

        mov mouse.x_pos,x
        mov mouse.y_pos,y
        call mset_mouse_xy
        call mshow_mouse_cur

        ENDM

mshow_cur MACRO

        call mshow_mouse_cur

        ENDM

open_f  MACRO fname,mode

        mov edx,offset fname
        mov al,mode
        call f_open

        ENDM

read_f  MACRO handle,how_much,where

        mov ebx,handle
        mov ecx,how_much
        mov edx,offset where
        call f_read

        ENDM

write_f  MACRO handle,how_much,from

        mov ebx,handle
        mov ecx,how_much
        mov edx,offset from
        call f_write

        ENDM

close_f MACRO handle

        mov ebx,handle
        call f_close

        ENDM

make_f  MACRO path,attr

        mov edx,offset path
        mov cx,attr
        call f_make

        ENDM

minit   MACRO

        call minit_mouse

        ENDM

draw_boxx MACRO x1,y1,x2,y2,color

        mov bx,x1
        shl ebx,16
        mov bx,y1

        mov cx,x2
        shl ecx,16
        mov cx,y2
        mov al,color
        call draw_box_320

        ENDM

fill_320 MACRO  color

        mov al,color
        call fill_scr_320

        ENDM

print_03 MACRO what

        mov edx,offset what
        mov ah,09h
        mov al,0
        int 21h

        ENDM

set_mode_std MACRO mode

        mov eax,mode
        int 10h

        ENDM

show_bmp_low    MACRO from

        mov esi,offset from
        call show_bmp_320

        ENDM

set_pal_256 MACRO from

        mov edi,offset from
        call set_pal_ergb

        ENDM

code ends