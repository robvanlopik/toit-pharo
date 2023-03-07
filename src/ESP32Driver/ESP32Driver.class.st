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

{ #category : #accessing }
ESP32Driver >> brokerIP [

	^ brokerIP
]

{ #category : #accessing }
ESP32Driver >> brokerIP: anObject [

	brokerIP := anObject
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

{ #category : #accessing }
ESP32Driver >> mqttClient [

	^ mqttClient
]

{ #category : #accessing }
ESP32Driver >> mqttClient: anObject [

	mqttClient := anObject
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
