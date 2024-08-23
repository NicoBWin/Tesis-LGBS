## Reunión Semanal Miguel

#### También está Cossutta

Con el TNY vamos a andar bien.
Da lo mismo realimentar con cualquiera de las salidas.

Miguel dice de poner un transistor bipolar pequeño de montaje superficial entre el optoacoplador y la salida del microprocesador.
Diseñar la salida de la flyback con 18V. Con eso luego despues de las caidas

Respecto de las capas:

Con 4 capas no hay forma que te quede bien.

LVDS tiene que ir en una punta, no hay otra forma. Al lado tiene que haber una masa.
Miguel nos recomienda enfrentar los planos de potencia, que tienen que estar en una punta.
LVDS - Ground - TTL/3.3 - Potencia
El plano de masa no es que se vaya a calentar. La idea es separar la parte de potencia en la flyback, el control y la parte de potencia, y después enfrentar esas partes en el circuito.

#### Cambio en el diseño de la placa

Hacer una placa por módulo. Asi que hay que revisar que cambia con eso. Miguel dice que no hay drama desde el punto de vista del stackeo ni la comunicación, porque es 1A. Respecto de la comunicación no creemos que haya drama desde ningún punto de vista, hay que hacer una especie de conexión con cables.

Miguel nos dice que pongamos directamente una fuente de tensión para alimentar los inductores de los módulos.

Miguel nos recomienda comprar la fuente de alimentación de la FPGA de la placa principal.

####

El control nunca se tiene que apagar antes que la potencia. Si se corta la luz se muere sino la placa. Esto se soluciona con capacitores.

#### FPGA que paso Cossutta

No se cual es el contexto.

https://1bitsquared.com/products/orangecrab

#### Cossutta

No entendí bien porque pero dice que estaría bueno tener un microprocesador y una FPGA. Micro para el control y FPGA para hacer la modulación.
