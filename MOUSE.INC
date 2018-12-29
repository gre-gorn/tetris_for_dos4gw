
;Procedury obslugi myszy
;
mouse_info      STRUCT

no_of_keys      dw 0
visible         db 0
x_pos           dw 0
y_pos           dw 0
left            db 0
right           db 0
how_many_clicks dw 0
last_col        dw 0
last_row        dw 0
maxx            dw 0
maxy            dw 0
minx            dw 0
miny            dw 0
activex         dw 0
activey         dw 0
mask_tab        dw 32 dup(0)
x_impulses      dw 0
y_impulses      dw 0
new_adress      dd 0
new_mask        dw 0
about_which     dw 0

mouse_info      ENDS

data segment public 'data'

        db 'mouse data'
        
mouse   mouse_info<>

data ends

code segment public 'code'

;inicjuj myche
;

ALIGN 4

minit_mouse     PROC

        mov eax,00h
        int 33h
        cmp ax,0
        jnz minit_ok
        stc
        ret

minit_ok:

        mov mouse.no_of_keys,bx
        shl mouse.no_of_keys,1
        clc
        ret

minit_mouse     ENDP

;pokaz kursor (tryby <= 13h, i pochodne)
;

ALIGN 4

mshow_mouse_cur PROC

        mov eax,01h
        int 33h
        xor mouse.visible,1
        ret

mshow_mouse_cur ENDP

;schowaj kursorek
;

ALIGN 4

mhide_mouse_cur PROC

        mov eax,02h
        int 33h
        xor mouse.visible,1
        ret

mhide_mouse_cur ENDP

;odczytaj polozenie i stan przyciskow
;

ALIGN 4

mstatus_mouse   PROC

        mov eax,03h
        int 33h
        shr bx,1
        setc mouse.left
        shr bx,1
        setc mouse.right
        mov mouse.x_pos,cx
        mov mouse.y_pos,dx
        ret

mstatus_mouse   ENDP

;ustaw myszke na (x,y)
;w zmiennych x_pos,y_pos nowa pozycja kursora

ALIGN 4

mset_mouse_xy   PROC

        mov eax,04h
        mov cx,mouse.x_pos
        mov dx,mouse.y_pos
        int 33h
        ret

mset_mouse_xy   ENDP

;odczytaj informacje o nacisnieciu przyciswkow
;

ALIGN 4

mget_key_push   PROC

        mov eax,05h
        mov bx,mouse.about_which        ;ktory klawisz
        int 33h
        shr ax,1
        setc mouse.left
        shr ax,1
        setc mouse.right
        mov mouse.how_many_clicks,bx
        mov mouse.last_col,cx
        mov mouse.last_row,dx
        ret

mget_key_push   ENDP

;informacje o zwolnieniu przyciskow
;

ALIGN 4

mget_key_leave  PROC

        mov eax,06h
        mov bx,mouse.about_which        ;ktory klawisz
        int 33h
        shr ax,1
        setc mouse.left
        shr ax,1
        setc mouse.right
        mov mouse.how_many_clicks,bx
        mov mouse.last_col,cx
        mov mouse.last_row,dx
        ret

mget_key_leave  ENDP

;ustawienie zakresu poziomego dla kursora
;w minx i maxx zakres

ALIGN 4

mset_horizontal PROC

        mov eax,07h
        mov cx,mouse.minx
        mov dx,mouse.maxx
        int 33h
        ret

mset_horizontal ENDP

;ustawienie zakresu pionowego dla kursora
;w miny i maxy zakres

ALIGN 4

mset_vertical   PROC

        mov eax,08h
        mov cx,mouse.miny
        mov dx,mouse.maxy
        int 33h
        ret

mset_vertical   ENDP

;zdefiniowanie kusrsora graficznego
;

ALIGN 4

mdef_mouse_cur  PROC

        mov eax,09h
        mov bx,mouse.activex
        mov cx,mouse.activey
        mov edx,offset mouse.mask_tab
        int 33h
        ret

mdef_mouse_cur  ENDP

;odczytanie przesuniecia kursora
;

ALIGN 4

mget_moves      PROC

        mov eax,0bh
        int 33h
        mov mouse.x_impulses,cx
        mov mouse.y_impulses,dx
        ret

mget_moves      ENDP


;ustawienie maski i adresu procedury
;obslugi przerwania
;

ALIGN 4

mset_mask_adr   PROC

        push cs
        pop es
        mov eax,0ch
        mov cx,mouse.new_mask
        mov edx,mouse.new_adress
        int 33h
        ret

mset_mask_adr   ENDP

code ends
