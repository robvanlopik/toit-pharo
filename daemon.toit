// daemon program to access all GPIO functions (including i2c)
// used with Pharo ESP32DRiver
// github.com/robvanlopik/pharo-toit
// author: Rob van Lopik
// license: MIT
// first version 0.1 : march 2023

import gpio
import gpio.pwm
import gpio.adc show Adc
import gpio.dac show Dac
import i2c

import net
import mqtt
import encoding.json
import encoding.base64
import device
VERSION ::= "0.1"

// --- data that should come from assets
ClientName := "test1"
Host := "test.mosquitto.org"
Port := 1883
// leave out 1 and 3 because used for uart -- jag monitor
PinList := 
  [2,4,5,12,13,14,15,16,17,18,19,21,22,23,25,26,27,32,33,34,35,36,39]
OutputList := 
  [2,4,5,12,13,14,15,16,17,18,19,21,22,23,25,26,27,32,33]
ADCList := [32,33,34,35,36,39]
DACList := [25,26]
I2CList := [21,22]
SDA ::= 21
SCL ::= 22
// --- end of variable data

PWMGenerator := ?
I2CBus := ?
TopicPrefix := "pots/$ClientName"
ClientID := "$device.name"
// 
Pins := {:}
I2CDevices := {:}
//
Messenger := ?
// routes map. dispatch processing to routines named executXXX
RouteMap ::= {
    "$TopicPrefix/Version": :: | topic data |
      executeVersion topic data,
    "$TopicPrefix/DI": :: | topic data |
      executeDI topic data,
    "$TopicPrefix/DO": :: | topic data |
      executeDO topic data,
    "$TopicPrefix/PWM": :: | topic data |
      executePWM topic data,  
    "$TopicPrefix/AO": :: | topic data |
      executeAO topic data,
    "$TopicPrefix/AI": :: | topic data |
      executeAI topic data,
    "$TopicPrefix/Mode": :: | topic data |
      executeMode topic data,
    "$TopicPrefix/PinList": :: | topic data |
      executePinList topic data,
    "$TopicPrefix/OutputList": :: | topic data |
      executeOutList topic data,
    "$TopicPrefix/ADCList": :: | topic data |
      executeADCList topic data,
    "$TopicPrefix/DACList": :: | topic data |
      executeDACList topic data,
    "$TopicPrefix/I2CList": :: | topic data |
      executeI2CList topic data,
    "$TopicPrefix/I2COpen": :: | topic data |
      executeI2COpen topic data ,
    "$TopicPrefix/I2Close" : :: | topic data |
      executeI2CClose topic data,
    "$TopicPrefix/I2CWrite": :: | topic data |
      executeI2CWrite topic data,
    "$TopicPrefix/I2CRead": :: | topic data |
      executeI2CRead topic data,
    "$TopicPrefix/I2CReadAt": :: | topic data |
      executeI2CReadAt topic data,
    }  

main:
  // prepare the PINS set all to digital input
  PinList.do:
    Pins[it] = (gpio.Pin it --input=true)
  PWMGenerator = pwm.Pwm --frequency=400
  //setup MQTT
  transport := mqtt.TcpTransport net.open --host=Host
  print "starting client"
  Messenger = mqtt.Client --transport=transport --routes=RouteMap
  print "Connected to MQTT Broker @ $Host:$Port"
  Messenger.start --client_id=ClientID
  print "client $ClientID started"

// functions to execute commands
executeVersion topic data:
  print "version requested"
  Messenger.publish "$topic/Result" (json.encode VERSION)
executeDI topic data:
  params := json.decode data
  pinNr := params[0]
  Messenger.publish "$topic/Result" (json.encode [pinNr, Pins[pinNr].get])
executeDO topic data:
  print "DO ($data.to_string)"
  params :=  json.decode data
  Pins[params[0]].set params[1]
executePWM topic data:
  print "PWM $data"
  params:= json.decode data
  pinNr := params[0]
  Pins[pinNr].set_duty_factor params[1]/100.0
executeAO topic data:
  print "AO ($data.to_string)"
  params :=  json.decode data
  Pins[params[0]].set (params[1] * 1.0)
executeAI topic data:
  params := json.decode data
  pinNr := params[0]
  Messenger.publish "$topic/Result" (json.encode [pinNr, Pins[pinNr].get])

executeMode topic data:
  print "change mode: $(data.to_string)"
  params := json.decode data
  pinNr := params[0]
  mode := params[1]
  Pins[pinNr].close
  if mode == "DO":
    Pins[pinNr] = (gpio.Pin pinNr --output)
  else if mode == "DI":
    Pins[pinNr] = (gpio.Pin pinNr --input)
  else if mode == "AO":
    Pins[pinNr] = (Dac (gpio.Pin pinNr))
  else if mode == "AI":
    Pins[pinNr] = (Adc (gpio.Pin pinNr))
  else if mode == "PWM":
    Pins[pinNr] = (PWMGenerator.start (gpio.Pin pinNr))
executePinList topic data:
  Messenger.publish "$topic/Result" (json.encode PinList)
executeOutList topic data:
  Messenger.publish "$topic/Result" (json.encode OutputList)
executeADCList topic data:
  Messenger.publish "$topic/Result" (json.encode ADCList)
executeDACList topic data:
  Messenger.publish "$topic/Result" (json.encode DACList)
executeI2CList topic data:
  Messenger.publish "$topic/Result" (json.encode I2CList)
executeI2COpen topic data:
  address := json.decode data
  if I2CDevices.is_empty :
    Pins[SDA].close
    Pins[SCL].close
    I2CBus = i2c.Bus 
      --sda=gpio.Pin SDA
      --scl=gpio.Pin SCL
  I2CDevices[address] = I2CBus.device address
executeI2CClose topic data:
  params := json.decode data
  address := params[0]
  I2CDevices[address].remove 
  if I2CDevices.is_empty : I2CBus.close
executeI2CWrite topic data: 
  params := json.decode data
  address := params[0]
  bytes := base64.decode params[1]
  print "address: $address - data $bytes"
  I2CDevices[address].write bytes
executeI2CRead topic data:
  params := json.decode data
  address := params[0]
  count := params[1]
  result := I2CDevices[address].read count
  Messenger.publish "$topic/Result" (json.encode [address, base64.encode result])
executeI2CReadAt topic data:
  params := json.decode data
  address := params[0]
  reg :=  params[1]
  count := params[2]
  result := I2CDevices[address].read_reg reg count
  Messenger.publish "$topic/Result" (json.encode [address, base64.encode result])


