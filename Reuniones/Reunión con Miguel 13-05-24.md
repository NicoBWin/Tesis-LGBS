## Reunión Miguel 13-05

#### Tema del concurso de investigación

Nos dan plata para que hagamos algo. No hay premios.
Tenemos que presentar un informe de lo que vamos a hacer. Después presentar un informe de que es lo que hicimos. Con esto podemos financiarnos con el ITBA.

También podría servir por los premios, menciones, étc.

#### Requerimientos

Motor para el cual diseñamos->

El motor es un BLDC, 1Kw, 2Kw pico y 96V.

Podríamos decir que sirve para motores BLDC en general.

En todo controlador de motor, tenes que ponerle sus parámetros. Osea vamos a tener que levantar la curva del motor para poder armar el proyecto y tener que centrarnos en el mismo. Técnicamente igual podría decirse que funciona para cualquier BLDC, haciendo los cambios necesarios.

El motor es de AR Motors, asi que no hay tantos datos en internet. Hay que hacerle ensayos nosotros para sacar las curvas o pedirle los datos a la gente de Río Cuarto (TODO).

- Requerimiento funcional -> Vamos a usar los transistores que compró para hacer los inverters en el labo.

- El inverter debe llegar a 10A por fase máximo.

- Módulos-> Tendríamos que hacer mínimo 5 módulos. Esto es en parte lo complicado porque no hay papers donde hagan más de 3.

- Módulo de 1A, mínimo 5. Así quedó el requerimiento.

- Los 2A son de continua. Por eso no podemos usar los trafos que hicimos en potencia. Miguel dice que podríamos apuntar a hacer módulos de 1A. La idea sería hacer un trafo plano.

Miguel se lo imagina como un stack de 5/6 plaquetitas.
FORMA Debería entrar en menos de 20x10x10cm. Esto va a depender mucho de los núcleos que usemos de todas maneras, si conseguimos hacer trafos planares vamos a estar bien.

- Esta tecnología no existe. Así que no hay limitante de precio.

- Este inverter no es bidireccional. Eso es porque entrega corriente para un solo lado, para hacerlo regenerativo habría que dar vuelta la tensión con un puente H. El cliente no lo pidió, pero vamos a tratar de hacerlo igual.

- Control por torque -> Con que vamos a realimentar para el control. Sensores de corriente en cada bobinado. Cada módulo tiene que tener 2 sensores de corriente y el bobinado principal tiene que tener otro. Esto se hace para garantizar que las corrientes sean continuas y todas iguales, es pare el balance interno del inverter que es lo más díficil de hacer.

- Protección sobretensión de entrada. Y sobrecorriente... (un fusible). Protección para golpes y vibraciones, esos son medio tácitos.

- Tensión y corriente de alimentación: El bus es de 96V máximo. Entre 4 y 8 baterías del karting son lo que van a alimentar el circuito. Esto seria 96V. Por lo que deberían ser 120V máximo de entrada.

- Sería conveniente que tenga tolerancia a fallas. Con un módulo más que se ponga automáticamente cuando se rompa alguno. No es requerimiento del cliente, pero quedaría bien.

- Requerimiento: Los torques que se quieren de cada motor entran por bus CAN. También la realimentación de corriente y esas cosas, el desbalance de corrientes, étc.

- Tácito, tiene que ser modular para poder cambiar la cantidad de módulos.

### Diseño

Una FPGA central que controle todo y se comunique por SPI con las otras FPGA esclavas. Tienen que manejarse todos por paralelo. Por ejemplo con un conversor I2C en paralelo podría ser.

### Consejos

Conseguir una simulación confiable -> Usar LTSpice para los transistores, inductores, capacitores y esas cosas

Lo funcional es mejor hacerlo en MATLAB, en especial porque usando Xilinx se puede sintetizar directo en la FPGA.

Armar los requerimientos del proyecto de forma prolija para presentarlos en la consulta de la tesis el miércoles.

Diseñar bien el PCB para que las inductancias parásitas no jodan.

Hasta cuanto darle a la frecuencia tal que el EMI no joda.

### Información

Miguel no tiene acceso a IEEE.

Armar un grupete de whatsapp. Para que Miguel nos pase cosas

### Tareas

Armar la hojita para entregar al concurso y conseguir la plata

Tratar de pensar todos los componentes que necesitamos para que Miguel haga los pedidos.

Tenemos que calcular los componentes desde la frecuencia de operación para ver que transistores precisamos usar. -> TME

Fabricar las fuentes de disparo de los transistores -> sería una Flyback de 5W.

Preocupante: Calcular que núcleos vamos a precisar para armar los inductores. También calcular los capacitores de filtro de entrada y salida (o pensarlos en el presupuesto).
