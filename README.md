# toit-pharo
This repo contains a driver for communication between Pharo and a Toit daemon program running on an ESP32 microprocessor.

Communication is through MQTT, used in a synchronous way; the driver sends commands and waits for a response message.

First the program daemon.toit




Some limitations/todo's:
- you will have to modify daemon.toit if your ESP32 is not on a 30  pins baord, to adapt the address of the MQTT broker, to change the name of the ESP-device. I intend to use toit's asset mechanism for this.
- ...

## Installing daemon.toit
You will need to flash the ESP32 with the toit tools, at least Jaguar. You don't need Visual Studio Code.
In short:
- download and install Jaguar
- install toit's mqtt package: ```jag pkg ???```
- flash the device with the jaguar firmware: ```jag flash```
- edit the file daemon.toit, at least modify the line ```host := "192.168.1.233"```to reflect your MQTT broker
- flash daemon.toit to the device: ```jag run daemon.toit``` or jag 

