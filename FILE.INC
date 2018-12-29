;Wstepna optymalizacja kodu dla PENTIUM TM
;W programie glownym zdefiniowac zmienna file file_info<>
;
;tu beda procedury do pracy z plikami w trybie flat
;takie jak:
;   !  f_open(path,mode)                    otworz plik
;   !  f_close(id_handle)                   zamknij plik
;      f_read_eof(id_nadle)                 czytaj az do eof
;   !  f_read(id_handle,how_much)           czytaj okreslona ilosc
;   !  f_write(id_handle,how_much)          zapisuj okreslona ilosc
;   !  f_set_posision(id_handle,where)      ustaw pozycje w pliku
;   !  f_reset(id_handle)                   ustaw pozycje na zero
;   !  f_goto_end(id_handle)                skocz na koniec pliku
;      f_goto_var(id_handle,plus_minus)     skocz do przodu/tylu o plus_minus
;   !  f_r_name(path,path)                  zmien nazwe
;   !  f_make(path)                         utworz nowy plik
;   !  f_kill(path)                         skasuj plik
;
;zmienne systemowe:
;
;       current_fname_buf       - bufor na nazwe pliku (lub sciezke) dlug<=128
;       error_status            - flaga bledu (0 lub 1)
;       current_error           - aktualny blad
;       current_mode_io         - aktualny tryb owarcia
;       current_id_handle       - oznacza aktualny uchwyt pliku
;       current_path            - oznacza aktualna sciezke
;       current_position        - oznacza aktualna pozycje w pliku
;       current_buffer          - oznacza aktualna pozycje bufora I/O (offset)
;       current_lbuffer         - oznacza aktualna wielkosc bufora opercji I/O
;       current_fname           - aktualna nazwa pliku
;       current_data_rw         - ilosc danych zapisanych/odczytanych
;       disk_status             - tablica dysku
;                               free_space      - wolna przestrzen
;                               current_name    - nazwa dysku (litera)
;
;       last_operation          - ostatnio wykonywana operacja
;                               (rd,wr,op,cl,fr,ge,gv,sp,re)
;                               rd - read
;                               wr - write
;                               op - open
;                               cl - close
;                               fr - reset
;                               ge - goto end
;                               gv - goto plus_minus
;                               sp - set position
;                               rs - reset position
;                               re - read until eof
;                               mk - make file
;                               kl - kill file
;                               rm - rename file
;                               no - nie bylo operacji do tej pory
;                               zmienna typu dd
;                               wyglad na poczatku dd nono
;                               przesuniecie o 16 bitow daje np. dd noop
;                               czyli wykonano open a poprzednio nie bylo nic
;.486p
;.model flat

code  segment public 'code'

file_info       STRUCT

error_status         dw 0
current_fname_buf    dd 0       ;wskaznik do bufora
current_error        dd 0
current_mode_io      dw 0
current_id_handle    dd 0
current_path         dd 0       ;wskaznik do bufora
current_position     dd 0
current_buffer       dd 0       ;wskaznik
current_lbuffer      dd 0
current_fname        dd 0       ;wskaznik
current_data_rw      dd 0
disk_status          dw 0
free_space           dd 0
current_name         db 'C'
last_operation       dd 'nono'

file_info       ENDS

;Procedura inicjujaca zmienne systemowe

ALIGN 4

init_var_sys    PROC

        stc
        ret

init_var_sys    ENDP

;Procedura owierajaca plik
;W EDX offset sciezki dostepu
;W AL tryb otwarcia
; na wyjsciu zmienne systemowe zaktualizowane

ALIGN 4

f_open  PROC

        setc file.error_status
        mov file.current_error,0
        xor ah,ah
        mov file.current_mode_io,ax
        mov ah,3dh
        int 21h
        jnc f_open_ok

        setc file.error_status
        mov file.current_error,eax

f_open_ok:

        mov ebx,file.last_operation
        mov file.current_id_handle,eax
        shl ebx,16
        mov file.current_position,0
        mov bx,'op'
        mov file.last_operation,ebx
        clc
        ret

f_open  ENDP

;Procdura zamykajaca plik
;W EBX uchwyt pliku

ALIGN 4

f_close PROC

        setc file.error_status          ;zeruj flage bledu
        mov file.current_error,0        ;zeruj blad
        mov ah,3eh
        mov file.current_id_handle,ebx  ;uaktualnij uchwyt pliku
        int 21h
        jnc f_close_ok

        setc file.error_status
        mov file.current_error,eax

f_close_ok:

        mov ebx,file.last_operation
        mov file.current_position,0
        shl ebx,16
        mov bx,'cl'
        mov file.last_operation,ebx
        clc
        ret

f_close ENDP


;Procedura tworzaca plik
;w EDX = adres sciezki
;w ECX = atrybut

ALIGN 4

f_make  PROC

        mov file.current_error,0        ;zeby nie bylo
        mov al,[edx]
        setc file.error_status          ;skasuj flage bledu tyz
        cmp al,'\'                      ;czy to aktualny katalog?
        jnz f_make_ok                   ;nie, jest cala sciezka

                                        ;przepisz do bufora sciezki!!!!
;        mov edx,file.current

f_make_ok:

        inc edx
        mov ah,3ch
        int 21h                         ;utworz nowy plik
        jnc f_make_no_err               ;nie ma bledu,ok

        setc file.error_status          ;ustaw flage
        mov file.current_error,eax      ;zachowaj kod bledu

f_make_no_err:

        mov ebx,file.last_operation
        mov file.current_id_handle,eax
        shl ebx,16
        mov file.current_position,0
        mov bx,'mk'
        mov file.last_operation,ebx
        clc
        ret

f_make  ENDP

;Procedura zapisujaca dane do uprzednio otwartego pliku
;W EBX uchwyt pliku
;W ECX ilosc bajtow do zapisu
;W EDX adres danych do zapisu
;

ALIGN 4

f_write PROC

        setc file.error_status          ;zeruj flage bledu
        mov file.current_error,0        ;zeruj blad
        mov ah,40h
        mov file.current_id_handle,ebx  ;uaktualnij uchwyt pliku
        int 21h
        jnc f_write_ok

        setc file.error_status          ;ustaw flage bledu
        mov file.current_error,eax

f_write_ok:

        mov ebx,file.last_operation
        mov file.current_data_rw,eax
        shl ebx,16
        add file.current_position,eax
        mov bx,'wr'
        mov file.last_operation,ebx
        clc
        ret


f_write ENDP


;Procedura odczytujaca dane z uprzednio otwartego pliku
;W EBX uchwyt pliku
;W ECX ilosc bajtow do odczytu
;W EDX adres danych do odczytu
;

ALIGN 4

f_read  PROC

        setc file.error_status          ;zeruj flage bledu
        mov file.current_error,0        ;zeruj blad
        mov ah,3fh
        mov file.current_id_handle,ebx  ;uaktualnij uchwyt pliku
        int 21h
        jnc f_read_ok

        setc file.error_status          ;ustaw flage bledu
        mov file.current_error,eax

f_read_ok:

        mov ebx,file.last_operation
        mov file.current_data_rw,eax
        shl ebx,16
        add file.current_position,eax
        mov bx,'rd'
        mov file.last_operation,ebx
        clc
        ret

f_read  ENDP

;Procedura czytajaca az do konca pliku
;W EBX uchwyt pliku
;W EDX offset miejsca docelowego
;

ALIGN 4

f_read_eof  PROC

        setc file.error_status          ;zeruj flage bledu
        mov file.current_error,0        ;zeruj blad
        mov ah,42h                      ;pobierz dlugosc pliku
        mov file.current_id_handle,ebx  ;uaktualnij uchwyt pliku
        mov al,2
        mov ecx,0
        mov edx,0
        int 21h
        push edx
        push ecx

;        3fh
        jnc f_read_eof_ok

        setc file.error_status          ;ustaw flage bledu
        mov file.current_error,eax

f_read_eof_ok:

        mov ebx,file.last_operation
        mov file.current_data_rw,eax
        shl ebx,16
        add file.current_position,eax
        mov bx,'re'
        mov file.last_operation,ebx
        clc
        ret

f_read_eof  ENDP

;Procedura resetujaca wskaznik pliku
;W EBX uchwyt pliku
;

ALIGN 4

f_reset PROC

        setc file.error_status          ;bez flagi bledu
        mov file.current_error,0        ;bez bledu
        mov file.current_id_handle,ebx  ;uaktualnij uchwyt pliku
        mov eax,0                       ;oznacza wzgledem poczatku pliku
        mov ecx,0                       ;zerowanie licznikow
        mov edx,0
        mov ah,42h
        int 21h                         ;resetuj
        jnc f_reset_ok

        setc file.error_status          ;flaga w gore
        mov file.current_error,eax      ;numerek i juz

f_reset_ok:

        mov ebx,file.last_operation
        mov file.current_position,0
        shl ebx,16
        mov file.current_data_rw,0
        mov bx,'rs'
        mov file.last_operation,ebx
        clc
        ret

f_reset  ENDP

;Procedura przesuwajaca wskaznik pliku
;W ECX:EDX o ile przesunac ,ECX to licznik blokow 64kb
;wlasciwie ma byc to cx:dx
;W EBX uchwyt
;

ALIGN 4

f_set_position  PROC

        mov file.current_id_handle,ebx
        setc file.error_status
        mov file.current_error,0
        mov al,0                        ;wzgledem poczatku
        int 21h
        jnc f_set_pos_ok

        setc file.error_status
        mov file.current_error,eax

f_set_pos_ok:

        mov ebx,file.last_operation
        mov word ptr file.current_position+3,ax
        shl ebx,16
        mov ecx,edx
        xor edx,edx
        mov bx,'sp'
        mov eax,10000h
        mul cx
        add file.current_position,eax
        mov file.last_operation,ebx
        clc
        ret

f_set_position  ENDP

;Procedura kasujaca plik
;W EDX offset bufora
;jesli edx==0 to uzywam current_fname_buf

ALIGN 4

f_kill  PROC

        cmp edx,0                       ;czy jest inny bufor?
        jnz f_kill_ok                   ;tak,jest inny

        mov edx,file.current_fname_buf  ;nie,uzyj domyslnego

f_kill_ok:

        setc file.error_status
        mov file.current_error,0
        mov ah,41h
        int 21h
        jnc f_kill_ok1

        setc file.error_status
        mov file.current_error,eax

f_kill_ok1:

        mov ebx,file.last_operation
        mov file.current_id_handle,0
        shl ebx,16
        mov file.current_position,0
        mov bx,'kl'
        mov file.current_data_rw,0
        mov file.last_operation,ebx
        clc
        ret

f_kill  ENDP

;Procedura skaczaca na koniec pliku
;W ebx uchwyt pliku
;

ALIGN 4

f_goto_end      PROC

        mov file.current_id_handle,ebx  ;aktualizuj uchwyt
        mov al,02h                      ;na koniec pliku
        mov ecx,0                       ;zerowe liczniki
        mov edx,0
        int 21h                         ;wykonaj
        jnc f_goto_end_ok               ;jakis blad?

        setc file.error_status          ;tak,cos nie tak
        mov file.current_error,eax

f_goto_end_ok:

        mov ebx,file.last_operation
        mov word ptr file.current_position+2,ax
        shl ebx,16
        add file.current_position,edx
        mov bx,'ge'
        mov file.current_data_rw,0
        mov file.last_operation,ebx
        clc
        ret

f_goto_end      ENDP


;Procedura zamieniajaca nazwe pliku
;W EDX offset starej nazwy (ASCIIZ)
;W EDI offset nowej nazwy
;wymagana nowa nazwa
;jesli EDX==0 to pobieram domyslna
;

ALIGN 4

f_r_name        PROC

        cmp edx,0                       ;czy stara nazwa jest?
        jnz f_r_name_ok                 ;tak jest

        mov edx,file.current_fname_buf  ;nie,pobierz domyslna

f_r_name_ok:

        setc file.error_status          ;wyzeruj bledy
        mov file.current_error,0
        mov ah,56h
        int 21h
        jnc f_r_name_ok1                ;jakies bledy

        setc file.error_status          ;tak,ustaw flage
        mov file.current_error,eax      ;zapamietaj numer bledu

f_r_name_ok1:

        mov ebx,file.last_operation     ;ustaw ostnia operacje
        mov file.current_position,0     ;i kilka innych rzeczy
        shl ebx,16
        mov file.current_data_rw,0
        mov bx,'rm'
        mov file.current_id_handle,0
        mov file.last_operation,ebx
        clc                             ;skasuj jesli byl ustawiony
        ret

f_r_name        ENDP

;f_read_eof
;f_goto_var

code  ends

data  segment public 'data'

        db 'file data'
file    file_info<>

data  ends

