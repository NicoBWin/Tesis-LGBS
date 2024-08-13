## Reunión Miguel Cossutta - 31/05

### Justificaciones

- En algun futuro vamos a tener super inductores. (Y va a servir más, osea se va a ver mas lo que estamos haciendo)
- La vida util del capa es mucho menor al del inductor
- Los inverters de tensión fallan a circuito cerrada o corto. El que hacemos nosotros no. 
- El tiempo medio entre falla viene dado por los capa y el conversor de corriente es mucho mejor en eso (Los inductores son dificil de romper)

- Topologia 1: La que conocemos (inductores desacoplados) -> En principio vamos con esta
  
- Topologia 2: Inductores acoplados -> Esto lo tendría que hacer Mark Kurvers, veremos que pasa en Agosto.
Tenemos que entregarle unas ecuaciones de ripple de los inductores, supongo que para Junio.

### Frec. de trabajo

- Discutieron de si 150KHz o 250KHz. Va a ser 250KHz la frecuencia de la triangular (la modulación)
- 250 KHz -> Suponiendo 8b necesitamos un clock de 2 MHz. Hay que pensar como nos comunicamos con los switches. CRC? 

- SPI -> Tiene que ser diferencial, algo confiable. Por el ruido que hay en el ambiente
- La SPI que implementó Pablo en la FPGA tenia ~25 MHz.
- Solución cavernicola con un shift register. Se puede hacer considerar algo un poco mejor usando una CPLD.
- La facil es un shiftRegister para el control de los MOS con una lógica discreta para evitar estados prohibidos
  
- La idea es una FPGA que mande los mensajes y por HW se prenden cada módulo
- Todo se alimenta con Flyback

- De cada módulo habría que leer las corrientes -> Miguel dice las 2. Pablo dice 1. (la corriente en las bobinas)
- El valor de esta corriente se transmite con algo... (Ej: un ADC)

AVERIGUAR: CPLD o miniFPGA

#### Conclusión
Agus se comió todas las galletitas... ;)
