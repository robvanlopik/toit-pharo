# toit-pharo
This repo is about communication between Pharo and a Toit program running on an ESP32 microprocessor.

The ESP32 side will be a daemon that receives commands through MQTT and returns results, thus exposing all functionality like digiysl i/o, adc, dac pwm and I2C.
The Pharo side will be a driver analogous to the Firmata, PiGPIO and Picod driver already available. In this way Pots (PharoOfThingsSimplified) can also be used with the ESP32 over Wifi
