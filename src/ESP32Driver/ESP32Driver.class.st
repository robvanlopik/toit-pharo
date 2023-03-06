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

{ #category : #'as yet unclassified' }
ESP32Driver >> beAnalogInputOnPin: pinNr [
	self sendCommand: 'Mode' params: { 'AI' . pinNr }
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
	mqttClient := MQTTClient url: brokerIP
]
