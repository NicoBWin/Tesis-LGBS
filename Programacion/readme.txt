Pasos para programar:

1) pip install apio (solo si no esta el .env)
2) Configurar el Makefile para indicar el top.v y el top_tb.v
3) Correr apio install oss-cad-suite para instalar las tools.
    Nota: En windows tuve que hacer apio install -p 'XXX' oss-cad-suite
    donde 'XXX':
        Warning: full platform does not match: windows_amd64 <-- En mi caso
         Trying OS name: windows

En cada directorio donde querramos trabajar:

4) Correr apio init -b upduino3
5) Correr apio verify
6) Correr apio build
7) Correr apio upload