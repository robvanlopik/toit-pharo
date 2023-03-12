Class {
	#name : #BaselineOfESP32Driver,
	#superclass : #BaselineOf,
	#category : #BaselineOfESP32Driver
}

{ #category : #baselines }
BaselineOfESP32Driver >> baseline: spec [

	<baseline>
	spec for: #common do: [ 
			self declareMQTTon: spec. 
			spec package: 'ESP32Driver' with: [  spec requires: #('MQTT') ] ]
]

{ #category : #baseline }
BaselineOfESP32Driver >> declareMQTTon: spec [

	spec
		baseline: 'MQTT'
		with: [  spec repository: 'github://svenvc/mqtt/repository' ]
]
