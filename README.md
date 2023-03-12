# toit-pharo (WIP)
This repo contains a driver for communication between Pharo and a Toit daemon program running on an ESP32 microprocessor.

Communication is through MQTT, used in a synchronous way; the driver sends commands and waits for a response message. The driver supports digital i/o analog i/o and I2C.

First the program daemon.toit needs to be running on the ESP32. Then you can write in a Playground
```Smalltalk
esp := ESP32Driver new brokerIP: 'mqtt://192.168.1.233''; deviceName: 'test1'; setup.
esp beDigitalOutputOnPin: 2.  "the on board LED"
esp digitalValue: 1 intoPin: 2. "turn the LED on"
```
In PharoOfThingsSimplified (github.com/robvanlopik/Pots) there is also a driver that uses this one, so you can use the ESP32 as a PotsController.

Some limitations/todo's:
- you will have to modify daemon.toit if your ESP32 is not on a 30  pins baord, to adapt the address of the MQTT broker, to change the name of the ESP-device. I intend to use toit's asset mechanism for this.
- you need the Toit environment to load daemon.toit. There should be a file that can be directly installed on the ESP32. Doable, but not a priority.
- daemon.toit is not written in an OO fashion, but it is extremely simple. It also doesn't use the container model of Toit. That will have to change to address the following:
- although we use asynchronous technology, the system is completely synchronous. When we want to allow out-of-band events (like state changes of gpio pins), we will have to change the design, probably along the lines of the picod system.

## Installing daemon.toit
You will need to flash the ESP32 with the toit tools, at least Jaguar. You don't need Visual Studio Code.
In short:
- download and install Jaguar
- install toit's mqtt package: ```jag pkg ???```
- flash the device with the jaguar firmware: ```jag flash```
- edit the file daemon.toit, at least modify the line ```host := "192.168.1.233"```to reflect your MQTT broker
- flash daemon.toit to the device: ```jag run daemon.toit``` or ```jag container install daemon.toit```

