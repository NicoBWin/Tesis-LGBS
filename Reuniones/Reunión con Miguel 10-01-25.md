## Preguntas para Miguel

- Ver el tema de los inductores de Mark, como se conectan respecto de como los pensó, y que creemos que nosotros los estamos haciendo mal.

Se habló de esto.

- Preguntar si para tener una frecuencia de switching de 250KHz de los transistores es necesario que la frecuencia de la triangular sea de 250KHz

La frecuencia de la triangular tiene que ser varias veces menor que la de actualización de los transistores porque justamente eso va a definir la cantidad de puntos de muestreo que haya de las señales. A la simulación de Matlab le falta justamente eso, discretizar la actualización de los transistores, esa es la razón por la que funciona tan bien. Por otro lado la frecuencia del motor no va a andar muy por arriba de los 50Hz asi que se puede decir con certeza que el mf no va a ser un problema si la frecuencia de la triangular de la modulación está masomenos por los 25KHz.