## Preguntas para Miguel para mañana
	
* Que transistores nos ofrece para switchear en la fuente de corriente?

Los que tenemos se nos prenden fuego. Necesitamos algo que se banque switchear a 50KHz a 100KHz, y que se banque 10A y 100V. Que se pueda disparar con 15V.

MOS Que usaron para el karting: Van a averiguar que hay en stock.
Disipador en un SMD: Se complica la parte mecatrónica. Se puede poner un pad en el cobre pero acá se complica.
Poner una especie de resistencia térmica que básicamente te disipa la potencia es otra opción.

https://www.mouser.com/new/vishay/vishay-thjp-thermawick-chips/?srsltid=AfmBOoqb2OIifjFx-fEcPzql0X2eX-a--i6zALBkW3nyMClfqqrAUWIg

Si no podemos ir a por el aluminio como disipador, pero entonces tendríamos que usar una esponjita porque sino hay quilombo con que se calientan de forma dispar.

Lo mejor igual es comprar unos transistores con un orden menos de resistencia de canal. Ya resuelve las cosas mucho más fácil. Es medio una pinga el MOS que tenemos. Además no precisamos tantos MOS.

IRFS4227 -> Parece que vamos por este...

* Que núcleo usar para los transformadores del ADC. O si nos conviene usar algún trafo del labo.

El ADC integrado tiene una tensión máxima de 3.6V, ponele 150V.
La corriente que va a circular es mínima, ponele 10mA.

Un transformador no podemos usar por las variadas frecuencias que vamos a usar para controlar el motor.
Mandar las señales aisladas digitales, con aisladores digitales, eso es lo que propone Pablo. El tema es que hay que hacer
una alimentación aislada para el motor, por el tema de que están flotantes.

Es un quilombito, habría que hacer otra placa inclusive.

Ya fue vamos por los sensores de efecto Hall y dejamos el lugar en todo caso para que se lea la FEM en el futuro su llegase a hacer falta.