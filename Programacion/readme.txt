Pasos para programar:

1) pip install apio (solo si no esta el .env)
2) Configurar el Makefile para incluir todos los archivos .v que quieran en SOURCES
3) Correr apio install oss-cad-suite para instalar las tools.
    Nota: En windows tuve que hacer apio install -p 'XXX' oss-cad-suite
    donde 'XXX':
        Warning: full platform does not match: windows_amd64 <-- Era esto en mi caso
         Trying OS name: windows

En cada directorio donde querramos trabajar:

4) Correr apio init -b upduino3
5) Correr apio clean
6) Correr apio verify
7) Correr apio prog
    Nota: Si les aparece ftdi_usb_get_strings failed: -4 (libusb_open() failed) sigan

8) Instalen el driver de ftdi con Zadig desde:
    https://github.com/FPGAwars/libftdi-cross-builder/wiki#driver-installation

Docs para la upduino3:

https://upduino.readthedocs.io/en/latest/index.html
