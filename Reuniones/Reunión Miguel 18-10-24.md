# Tema conectores

De última Miguel dice que hacemos 2 agujeros en la placa y agarramos el conector con el precinto. O sino pistola de calor.

Los conectores tipo verdes del karting? Esos dicen que anduvieron bien

# Lista de componentes

En el grupo pasaron tornillos para poner en el PCB y conectores para la placa. (el que usa Miguel es el que los cables se ajustan atornillando.)

En el medio entre la salida de cada placa de expansion y el motor tiene que haber un capacitor para acoplar la salida a la red.

Idealmente probamos primero con una resistencia y después ponemos el capa para acoplar, y la PCB nos facilita esto.

# Puente H

No se puede usar bootstrap, porque no disparas tan seguido al capacitor de abajo.

La idea del puente H es que solo se apaga para frenar, porque cuando está prendido la corriente la regulan los módulos.

Por lo que entendí vamos a poner varios en paralelo.

# Tema frecuencias de los inductores

Mark está laburando

# Tema protecciones

No hace falta que la placa tenga protecciones, porque esto anda o explota.

Además técnicamente se rompen solo 2 MOSFETs (una rama) de cada módulo porque cuando se rompen se ponen en corto y circula la corriente ahi.

# Tema diodos

Vamos a usar los ES3G que ya hay 500 en el pañol para los módulos.

# 2 Inverters

Necesitamos 2 inverters para mover al motor.

Que verga haremos xd.
