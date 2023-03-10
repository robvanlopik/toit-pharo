"
Class: ESP32Driver
                                                                                                    
I interact with a daemon, written in the Toit programming language, running on an ESP32.
I communicate of TCP/IP using the MQTT protocol.

To start: 
```smalltalk
driver := ESP32Driver new;
	deviceName: 'test1'; ""should be different for different boards""
	brokerIP: 'mqtt://192.168.1.233' ;
	setup
	```
mqttClient:		<Object>

Implementation Points
"
Class {
	#name : #ESP32Driver,
	#superclass : #Object,
	#instVars : [
		'deviceName',
		'brokerIP',
		'mqttClient'
	],
	#category : #ESP32Driver
}

{ #category : #utilties }
ESP32Driver >> adcList [
	^self sendCommandWait: 'ADCList' params: #()
]

{ #category : #'analog io' }
ESP32Driver >> analogValue: aValue intoPin: pinNr [
	 ^self sendCommand: 'AO' params: { pinNr . aValue}
]

{ #category : #'analog io' }
ESP32Driver >> analogValuefromPin: pinNr [
	 ^self sendCommandWait: 'AI' params: { pinNr }
]

{ #category : #'analog io' }
ESP32Driver >> beAnalogInputOnPin: pinNr [
	self sendCommand: 'Mode' params: { pinNr .'AI' }
]

{ #category : #'analog io' }
ESP32Driver >> beAnalogOutputOnPin: pinNr [
	self sendCommand: 'Mode' params: { pinNr . 'AO' }
]

{ #category : #'digital io' }
ESP32Driver >> beDigitalInputOnPin: pinNr [
	self sendCommand: 'Mode' params: { pinNr . 'DI' }
]

{ #category : #'digital io' }
ESP32Driver >> beDigitalOutputOnPin: pinNr [
	self sendCommand: 'Mode' params: { pinNr .'DO' }
]

{ #category : #pwm }
ESP32Driver >> bePWMOutputOnPin: pinNr [
	self sendCommand: 'Mode' params: { pinNr . 'PWM' }
]

{ #category : #accessing }
ESP32Driver >> brokerIP [

	^ brokerIP
]

{ #category : #accessing }
ESP32Driver >> brokerIP: anObject [

	brokerIP := anObject
]

{ #category : #utilties }
ESP32Driver >> dacList [
	^self sendCommandWait: 'DACList' params: #()
]

{ #category : #accessing }
ESP32Driver >> deviceName [

	^ deviceName
]

{ #category : #accessing }
ESP32Driver >> deviceName: anObject [

	deviceName := anObject
]

{ #category : #'digital io' }
ESP32Driver >> digitalValue: oneOrZero intoPin: pinNr [
	self sendCommand: 'DO' params: { pinNr . oneOrZero }
]

{ #category : #'digital io' }
ESP32Driver >> digitalValuefromPin: pinNr [
	^self sendCommandWait: 'DI' params: { pinNr }
]

{ #category : #utilties }
ESP32Driver >> i2cList [
	^self sendCommandWait: 'I2CList' params: #()
]

{ #category : #accessing }
ESP32Driver >> mqttClient [

	^ mqttClient
]

{ #category : #accessing }
ESP32Driver >> mqttClient: anObject [

	mqttClient := anObject
]

{ #category : #utilties }
ESP32Driver >> outputList [
	^self sendCommandWait: 'OutputList' params: #()
]

{ #category : #utilties }
ESP32Driver >> pinList [
	^self sendCommandWait: 'PinList' params: #()
]

{ #category : #initialization }
ESP32Driver >> providePinInfo [
	"This is called after setup and returns a pinDict dictionary"
	"the id is the index and the value is a fully filled out PotsActivePin"
	"the ESP32 has no altId's and all pins can be DI, what is also their defaul state"
	| pinDict allIds|

	pinDict := Dictionary new.
	allIds := self pinList.
	allIds do: [ :id | pinDict at: id put:
		(PotsActivePin new
		id: id;
		currentRole: (PotsDigitalInputRole new driver: self)) ]
]

{ #category : #pwm }
ESP32Driver >> pwmValue: percentage intoPin: pinNr [
	^self sendCommand: 'PWM' params: { pinNr . percentage}
]

{ #category : #utilties }
ESP32Driver >> sendCommand: code params: paramList [
	"append command code to topic and send paramlist json encoded as payload"
	| topic payload |
	topic := 'pots/', deviceName, '/', code.
	payload := (STONJSON toString: paramList) asByteArray .
	mqttClient sendMessage: payload toTopic: topic
]

{ #category : #utilties }
ESP32Driver >> sendCommandWait: code params: paramList [
	"append command code to topic and send paramlist json encoded as payload"
	| topic payload answer |
	topic := 'pots/', deviceName, '/', code.
	payload := (STONJSON toString: paramList) asByteArray .
	mqttClient sendMessage: payload toTopic: topic.
	"wait for an answer"
	answer := mqttClient readMessage.
	"to do check topic"
	^STONJSON fromString: ( answer message asString)
]

{ #category : #initialization }
ESP32Driver >> setup [
	"create the MQTT client"
	mqttClient := MQTTClient url: brokerIP.
	mqttClient open.
	mqttClient subscribeToTopic: 'pots/', deviceName, '/+/Result'
]
