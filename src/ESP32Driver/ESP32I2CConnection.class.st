Class {
	#name : #ESP32I2CConnection,
	#superclass : #Object,
	#instVars : [
		'i2cAddress',
		'driver'
	],
	#category : #ESP32Driver
}

{ #category : #accessing }
ESP32I2CConnection >> driver [

	^ driver
]

{ #category : #accessing }
ESP32I2CConnection >> driver: anObject [

	driver := anObject
]

{ #category : #accessing }
ESP32I2CConnection >> i2cAddress [

	^ i2cAddress
]

{ #category : #accessing }
ESP32I2CConnection >> i2cAddress: anObject [

	i2cAddress := anObject
]

{ #category : #writing }
ESP32I2CConnection >> i2cRead: count [
	"read count bytes from the device"
	^(driver sendCommandWait: 'I2CRead' params: { i2cAddress . count })
]

{ #category : #accessing }
ESP32I2CConnection >> i2cReadAt: aRegister count: aNumber [
	"read value of register with address aRegister (8 bits)"
	^(driver sendCommandWait: 'I2CReadAt' params: { i2cAddress . aRegister . aNumber })
]

{ #category : #writing }
ESP32I2CConnection >> i2cWrite: aByteArray [
	"write the bytearray to the i2c device. If you want to write to a register
	simply prepend the register address (7 bits) to the bytearray"
	driver sendCommand: 'I2CWrite' params: { i2cAddress . aByteArray base64Encoded  }
]
