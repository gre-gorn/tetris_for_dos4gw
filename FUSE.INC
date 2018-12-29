;Musi byc wlaczony do asemblacji plik FILE.INC
;priorytety:
;           0 - nie wykonuj
;           1 - wykonuj
;
; postac struktury:
;                   u_fopen       - format db
;                   u_fread       - ---------
;                   u_fwrite      - ---------
;                   u_fclose      - ---------
;                   u_fname       - wskaznik do nazwy , dd
;                   u_fmode       - tryb otwarcia , dd
;                   u_fhow_much   - ile danych , dd
;                   u_fmem_offs   - offset gdzie dane , dd

;.486p
;.model flat

file_use        STRUCT

u_fopen         db 0
u_fread         db 0
u_fwrite        db 0
u_fclose        db 0
u_fname         dd 0
u_fmode         dd 0
u_fhow_much     dd 0
u_fmem_offs     dd 0
u_id_handle     dd 0

file_use        ENDS

code segment public 'code'

;Procedura bledu i powrotu do DOS
;

align 4

ret_dos_err     PROC

        push ds
        pop es
        mov ecx,file.current_error      ;ktory to blad?
        dec ecx                         ;aby poprawnie znalezc
                                        ;ilosc '$' -1
        mov edi,offset error_table_txt  ;gdzie jest tablica bledow
        dec edi

rde1:                                   ;szukaj komunikatu o nr. ecx

        inc edi
        mov al,[edi]
        cmp al,'$'
        jnz rde1
        dec ecx
        jecxz rde1

;        mov eax,03h    ;wywolaj tryb tekstowy 03h
;        int 10h
                        ;znalazlem
        inc edi         ;wyswietlaj komunikat
        mov ah,09h
        mov edx,edi
        int 21h

        mov ah,4ch
        mov al,byte ptr file.current_error
        int 21h                            ;wyjdz do systemu

        ret    ;na wszelkij sluczaj

ret_dos_err     ENDP

;Procedura wywolujaca funkcje I/O na plikach
;w/g priorytetu

align 4

f_use   PROC

        xor cl,ch               ;zeruj smieci
        mov cl,fuse.u_fopen     ;czy otworzyc plik
        jcxz f_use_n1           ;nie otwieraj
        mov edx,fuse.u_fname    ;tak otworz
        mov eax,fuse.u_fmode    ;sposob otwarcia

        call f_open
        mov cx,file.error_status ;czy blad?
        jcxz f_use_n1            ;nie idz dalej
        jmp ret_dos_err          ;wolaj blad i wyjdz do DOS'u

f_use_n1:

        mov cl,fuse.u_fread         ;czy mam odczytac?
        jz f_use_n2              ;nie,nic nie czytaj

        mov ebx,fuse.u_id_handle    ;tak,czytaj
        mov edx,fuse.u_fmem_offs    ;gdzie wczytac
        mov ecx,fuse.u_fhow_much    ;ile wczytac
        call f_read
        mov fuse.u_id_handle,eax    ;jesli bedzie poprawne znamy uchwyt
                                    ;bedzie potrzebny jesli dalej nastapi
                                    ;zapis lub odczyt danych
                                    ;badz zamkniecie pliku

        mov cx,file.error_status    ;czy blad?
        jcxz f_use_n2               ;nie, idz dalej
        jmp ret_dos_err             ;wolaj blad i wyjdz do DOS'u

f_use_n2:

        mov cl,fuse.u_fwrite        ;czy mam zapisac?
        jz f_use_n3                 ;nie,nic nie zapisuj

        mov ebx,fuse.u_id_handle    ;tak,zapisuj
        mov edx,fuse.u_fmem_offs    ;skad pobrac
        mov ecx,fuse.u_fhow_much    ;ile zapisac
        call f_write
        mov cx,file.error_status    ;czy blad?
        jz f_use_n3                 ;nie, idz dalej
        jmp ret_dos_err             ;wolaj blad i wyjdz do DOS'u

f_use_n3:

        mov cl,fuse.u_fclose         ;czy mam zamknac
        jcxz short f_use_end               ;nie nie zamykaj
        mov ebx,fuse.u_id_handle     ;tak,zamknij
        call f_close
        mov cx,file.error_status     ;czy blad
        jcxz f_use_end               ;nie, idz dalej
        jmp ret_dos_err              ;wroc do DOS z komunikatem o bledzie

f_use_end:

        ret

f_use   ENDP

code    ends

data segment public 'data'

        db 'fuse data'
        
fuse    file_use<>

error_table_txt:

        include errors.inc

data ends