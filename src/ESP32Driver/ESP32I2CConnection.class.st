Class {
	#name : #ESP32I2CConnection,
	#superclass : #Object,
	#instVars : [
		'i2cAddress',
		'driver'
	],
	#category : #ESP32Driver
}

{ #category : #'initialize-release' }
ESP32I2CConnection >> close [
	driver closeI2C: i2cAddress 
]

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

{ #category : #reading }
ESP32I2CConnection >> i2cRead: count [
	"read count bytes from the device"
	| answer |
	answer := (driver sendCommandWait: 'I2CRead' params: { i2cAddress . count }).
	^(answer at: 2) base64Decoded
]

{ #category : #reading }
ESP32I2CConnection >> i2cReadAt: aRegister count: aNumber [
	"read value of register with address aRegister (8 bits)"
	"return a byte array"
	| answer|
	answer := driver sendCommandWait: 'I2CReadAt' params: { i2cAddress . aRegister . aNumber }.
	^(answer at: 2) base64Decoded
]

{ #category : #writing }
ESP32I2CConnection >> i2cWrite: aByteArray [
	"write the bytearray to the i2c device. If you want to write to a register
	simply prepend the register address (7 bits) to the bytearray"
	driver sendCommand: 'I2CWrite' params: { i2cAddress . aByteArray base64Encoded  }
]

{ #category : #reading }
ESP32I2CConnection >> readByte [
	"return a single byte"
	^(self i2cRead: 1) at: 1
]

{ #category : #reading }
ESP32I2CConnection >> readByteAt: aRegister [
	"return a single byte"
	^(self i2cReadAt: aRegister count: 1) at: 1
]

{ #category : #reading }
ESP32I2CConnection >> readDatablock: count at: aRegister [
	"return a byte array"
	^(self i2cReadAt: aRegister count: count) 
]

{ #category : #reading }
ESP32I2CConnection >> readWordAt: aRegister [
	"return word, little endian"
	^(self i2cReadAt: aRegister count: 2) unsignedShortAt: 1
]

{ #category : #reading }
ESP32I2CConnection >> readWordBigEndianAt: aRegister [
	"return a weord in bigendian interpretation"
	^(self i2cReadAt: aRegister count: 2) unsignedShortAt: 1 bigEndian: true
]

{ #category : #reading }
ESP32I2CConnection >> writeByte: aByte [
	self i2cWrite: (ByteArray with: aByte)
]

{ #category : #reading }
ESP32I2CConnection >> writeByteAt: aRegister data: aByte [
	self i2cWrite: (ByteArray with: aRegister with: aByte)
]

{ #category : #writing }
ESP32I2CConnection >> writeDataBlock: aByteArray at: aRegister [
	self i2cWrite: (ByteArray with: aRegister), aByteArray
]

{ #category : #accessing }
ESP32I2CConnection >> writeWordAt: aRegister data: aWord [
	self i2cWrite: (ByteArray with: aRegister with: (aWord \\ 256) with: (aWord // 256))
]

{ #category : #accessing }
ESP32I2CConnection >> writeWordBigEndianAt: aRegister data: aWord [
	self i2cWrite: (ByteArray with: aRegister with: (aWord // 256) with: (aWord \\ 256))
]
