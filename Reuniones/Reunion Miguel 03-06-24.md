## Nos reunimos con Miguel para intentar resolver dudas de las especificaciones y requerimientos del proyecto.
## También para mostrarle el diagrama a ver si le gusta

Otra justificación importante del uso del inverter de corriente en vez del de tensión es que se usan inductores que tienen una vida útil mayor que los capacitores. Entonces podríamos decir que un requerimiento justamente es este de aca abajo, así queda bastante justificado el uso de un inverter de corriente.

Se busca una confiabilidad mayor que la que se tiene con capacitores electrolíticos.

## Hay que medir la tensión del motor

Se puede realimentar de los sensores de efecto Hall sino.

Esto es para que la fase de la corriente que se meta se corrobore con la de la tensión. Es una especie de motor sincrónico. Hay que mantener un desfasaje constante (no recuerda Miguel como se calcula este desfasaje, depende del LR del motor).

Vos al motor le das potencia activa y reactiva. La potencia activa es torque. La reactiva es el desfasaje que necesita que es un LR(Entonces es cte y lo que vas variando es únicamente la potencia activa). A partir de acá sacas los datos de la corriente, el módulo y cuanto se desfasa de la tensión.

En el inverter de tensión tenés que poner una tensión, desfasada como para el de corriente, pero que además se relacione con la resistencia que haya en el motor (que sale de un observador de estados que estime a futuro). Esto es lo que complica una banda al control del motor con el inverter de tensión.

## FPGAs

Respecto de la FPGA, podemos hablar con Andrés Densky. Es el jefe de diseño digital en NovoSpace y la descoce con FPGAs.

Si calculamos que con la FPGA necesitamos 10 patitas. Conviene comprar una de 12 patitas. Osea de patitas tenemos que calcularle un 20% de reserva.