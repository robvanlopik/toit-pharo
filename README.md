# toit-pharo (WIP)
This repo contains a driver for communication between Pharo and a Toit daemon program running on an ESP32 microprocessor.

Communication is through MQTT, used in a synchronous way; the driver sends commands and waits for a response message. The driver supports digital i/o, analog i/o, PWM and I2C. (Servo in the making)

First the program daemon.toit needs to be running on the ESP32. Then you can write in a Playground:
```Smalltalk
esp := ESP32Driver new brokerIP: 'mqtt://192.168.1.233'; deviceName: 'test1'; setup.
esp beDigitalOutputOnPin: 2.  "the on board LED"
esp digitalValue: 1 intoPin: 2. "turn the LED on"
```
In PharoOfThingsSimplified (https://github.com/robvanlopik/Pots) there is also a driver that uses this one, so you can use the ESP32 as a PotsController.
## Message structure
Topics are structured as follows:
```pots/deviceName/Command```
where deviceName is used to distinguish between different devices and command is one of: (Version, Mode, DI, DO, AI, AO, PWM, I2COprn, I2CClose, I2CWrite, I2CRead, I2CReadAt, PinList, OutputList, DACList, ADCList, I2CList).
The message (payload) is a JSON-encoded array of parameters. Byte arrays (used in I2C operations) are base64 encoded.
Responses from the daemon have topic ```pots/deviceName/+/Result```, where the + stands for the command name. The message contains the answer in an array (JSON encoded) that usually has as first element e.g. a pin number or i2c address.

## Some limitations/todo's:
- you will have to modify daemon.toit if your ESP32 is not on a 30  pins board, to adapt the address of the MQTT broker, to change the name of the ESP-device. I intend to use toit's asset mechanism for this.
- you need the Toit environment to load daemon.toit. There should be a file that can be directly installed on the ESP32. Doable, but not a priority.
- daemon.toit is not written in an OO fashion, but it is extremely simple. It also doesn't use the container model of Toit. 
- although we use asynchronous technology, the system is completely synchronous. When we want to allow out-of-band events (like state changes of gpio pins), we will have to change the design, probably along the lines of the picod system.
- there is NO security, but it would be simple to add username/password authenitcation or TLS data transport.
- there is NO error handling in the daemon, it will simply exit when it gets wrong input (e.g. non existing pin numbers, i/o operations to a pin that is not in that mode, etc. It may be useful to connect the device with USB to your computer and run ```jag monitor``` in a separate command shell, so you can read Toit's error messages. Used in conjunction with Pots, errors should not occur.
- you need daccess to a MQQT broker. You may be able to use test.mosquitto.org, but whem you happen to have a Raspbeery Pi (any) around, it is easy to install your own (see e.g. https://randomnerdtutorials.com/how-to-install-mosquitto-broker-on-raspberry-pi/)

## Installing daemon.toit
You will need to flash the ESP32 with the toit tools, at least Jaguar. You don't need Visual Studio Code.
In short:
- download and install Jaguar (https://github.com/toitlang/jaguar)
- install toit's mqtt package: ```jag pkg ???```
- flash the device with the jaguar firmware: ```jag flash```
- edit the file daemon.toit, at least modify the line ```host := "192.168.1.233"```to reflect your MQTT broker
- flash daemon.toit to the device: ```jag run daemon.toit``` or ```jag container install daemon.toit```
## Installling the driver
``` smalltalk
Metacello new
  baseline: 'ESP32Driver';
    repository: 'github://robvanlopik/toit-pharo:main';
    load.
```
This will also load the MQTT package by Sven Van Caekenberghe.

