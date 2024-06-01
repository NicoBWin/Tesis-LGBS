## Reunión Miguel Cossutta - 31/05

### Justificaciones

- En algun futuro vamos a tener super inductores
- La vida util del capa es mucho mejor al del inductor
- Los convertidores fallan a circuito cerrada o corto
- El tiempo medio entre falla viene dado por los capa y en el conversor de corriente es mucho mejor en eso (Los inductores son dificil de romper)


- Topologia 1: La que conocemos
- Topologia 2: Inductores acoplados

### Frec. de trabajo
- 150 KHz pero quieren 250 KHz
- 250 KHz -> Suponiendo 8b necesitamos un clock de 2 MHz

- SPI -> Tiene que ser diferencial o algo confiable
- La SPI de pablo tenia ~25 MHz
- Solucion cavernicola con un shift register

- La idea es una FPGA que mande los mensajes y por HW se prenden cada módulo

- Se alimenta con Flyback

- De cada módulo habría que leer las corrientes -> No se usa una 
- La facil es un shiftRegister para el control de los MOS con una lógica discreta para evitar estados prohibidos

- ShiftRegister con diferencial single ended con un enable
AVERIGUAR: CPLD o miniFPGA

#### Conclusión
Agus se comió todas las galletitas... ;)