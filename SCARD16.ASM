.386p

;drajwer :) do blastera i innych kompatybilnych
;na razie obluga tylko na przerwaniach sorry!!
;this is version 1.0 ;)
;

dsp_reset       equ 06h ;DSP Reset Port, Write Only
dsp_read        equ 0Ah ;DSP Read Data Port, Read Only
dsp_write       equ 0Ch ;DSP Write Data or Command, Write
write_status    equ 0Ch ;DSP Write Buffer Status (bit 7), Read
data_avail      equ 0Eh ;DSP Data Available Status Bit 7), Read Only


;commands for DSP
direct_mode       equ 010h
turn_on           equ 0D1h
turn_off          equ 0D3h
get_dsp_version   equ 0E1h

;mixer registers
data_reset      equ 00h
voice_vol       equ 04h
master_vol      equ 22h
cd_vol_lr       equ 28h

;commands for driver
fdport    equ  01h
stmvol    equ  22h
stcdvol   equ  28h
spkonoff  equ 0d0h
gtdspver  equ 0e1h

;known function in my snddrv16
;
;word findport();               01h
;void setmvol(vol,mask);        22h,bx,cx
;void setcdvol(vol,mask);       28h,bx,cx
;void speaker(on/off);          0d0h,ah(0/1)
;void dspversion(where);        0e1h,di
;void initplayer();             00h
;void playsmp(numb);            02h,bx,cx seg:offset
;
;!!!not in documantation!!!
;
;void reset_dsp(port);          0ffh,bx
;void get_port(port);           0feh,bx
;void set_port(port);           0fdh,bx


;commands for player
;00h - play       !ver.1.0
;80h - stop       !ver.1.0
;10h - new sample is master  !ver.1.0
;f0h - continous playing     !ver.1.0
;11h - add two samples and play them both  !ver.1.0

;20h - fade out (4 bit stepping)   !i don't know
;30h - fade in  (4 bit stepping)   !i don't know
;

;**************************************************************************;
snddata16       SEGMENT PUBLIC USE16 'DATA16'

base_port       dw 00h  ;base port for SB
dma_chnl        db 00h  ;for use in future
irq_numb        db 00h  ;like above
speak_flag      db 00h  ;0,1
mstr_vo         db 00h  ;left:right
cd_vol          db 00h  ;left:right
dsp_ver         dw 00h  ;version
left_to_play    dw 00h  ;sorry I'm so lazy
current         db 00h  ;number of current sample
lenght          dw 00h  ;lenght of current sample
command         db 00h  ;command for player
segm_smp        dw 00h  ;segment of current sample
offs_smp        dw 00h  ;offset of current sample
page_adr        db 00h  ;page, for use in future
lsb_addr        db 00h  ;lsb of offset data, like above
msb_addr        db 00h  ;msb...............,like above above
seg_snd_buf     dw 00h  ;segment of soundbuffer
ofs_snd_buf     dw 00h  ;offset of soundbuffer
null            db 0ffh ;null, with not

snddata16       ENDS

soundbuffer     SEGMENT USE16 'DATA16'

             db 0 dup(65535)

soundbuffer     ENDS


player  SEGMENT PUBLIC USE16 'CODE16'

        stc
        ret

player  ENDS


code    SEGMENT PUBLIC USE32 'CODE'

snddrv32:

        stc             ;it's not working like for now
        ret

code    ENDS
