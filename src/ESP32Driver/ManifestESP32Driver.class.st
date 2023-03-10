"
I interact with a daemon, written in the Toit programming language, running on an ESP32.
I communicate of TCP/IP using the MQTT protocol.

To start: 
```smalltalk
driver := ESP32Driver new;
	deviceName: 'test1'; ""should be different for different boards""
	brokerIP: 'mqtt://192.168.1.233' ;
	setup
	```
		
	
		
"
Class {
	#name : #ManifestESP32Driver,
	#superclass : #PackageManifest,
	#category : #'ESP32Driver-Manifest'
}
