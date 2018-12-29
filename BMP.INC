bmp_file_header STRUCT

bfType          dw 0
bfSize          dd 0
bfReserved1     dw 0
bfReserved2     dw 0
bfOffBits       dd 0

bmp_file_header ENDS

bmp_info_header STRUCT

biSize          dd 0
biWidth         dd 0
biHeight        dd 0
biPlanes        dw 0
biBitCount      dw 0
biCompression   dd 0
biSizeImage     dd 0
biXPelsPerMeter dd 0
biYPelsPerMeter dd 0
biClrUsed       dd 0
biClrImport     dd 0

bmp_info_header ENDS

nagl_pliku      bmp_file_header<>
nagl_rysunku    bmp_info_header<>
