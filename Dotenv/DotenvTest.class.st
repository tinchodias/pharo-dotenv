Class {
	#name : #DotenvTest,
	#superclass : #TestCase,
	#instVars : [
		'dotenvFileReference',
		'dotenv'
	],
	#category : #Dotenv
}

{ #category : #running }
DotenvTest >> dotenvWrite: aString [
	"Helper method to write contents in the testing dotenv file."	

	dotenvFileReference writeStreamDo: [ :stream | stream nextPutAll: aString ]
]

{ #category : #running }
DotenvTest >> setUp [
	super setUp.
	
	"Create a memory file and set up the Dotenv instance."
	dotenvFileReference := (FileSystem memory / '.env') ensureCreateFile.
	dotenv := Dotenv new
		path: dotenvFileReference;
		yourself.

]

{ #category : #running }
DotenvTest >> tearDown [
	super tearDown.
	
	OSPlatform current environment unsetEnv: self variableNameForTesting.

]

{ #category : #tests }
DotenvTest >> testBasic [
	self dotenvWrite: 'BASIC=basic'.

	self assert: dotenv variablesDictionary size equals: 1.
	self assert: (dotenv variablesDictionary at: 'BASIC') equals: 'basic'.
]

{ #category : #tests }
DotenvTest >> testBlanks [
	self dotenvWrite: '

		VAR = var      '.

	self assert: dotenv variablesDictionary size equals: 1.
	self assert: (dotenv variablesDictionary at: 'VAR') equals: 'var'.
]

{ #category : #tests }
DotenvTest >> testConfigCreatesTheEnvironmentVariableWhenItDoesntExist [
	| key value |
	key := self variableNameForTesting.
	value := DateAndTime now asString.
	self dotenvWrite: ('{1}={2}' format: {key. value}).

	self deny: (OSPlatform current environment includesKey: key).
	
	dotenv config.

	self assert: (OSPlatform current environment at: key) equals: value.
	
]

{ #category : #tests }
DotenvTest >> testConfigPreservesTheEnvironmentVariableWhenItDoesExist [
	| key newValue oldValue |
	key := self variableNameForTesting.
	newValue := DateAndTime now asString.
	self dotenvWrite: ('{1}={2}' format: {key. newValue}).

	oldValue := 'an existing value'.
	OSPlatform current environment at: key put: oldValue.
	self assert: (OSPlatform current environment includesKey: key).
	
	dotenv config.

	self assert: (OSPlatform current environment at: key) equals: oldValue.
	
]

{ #category : #tests }
DotenvTest >> testDoubleQuote [
	self dotenvWrite: 'DOUBLE_QUOTE="quoted"'.
	
	self assert: dotenv variablesDictionary size equals: 1.
	self assert: (dotenv variablesDictionary at: 'DOUBLE_QUOTE') equals: 'quoted'.
]

{ #category : #tests }
DotenvTest >> testEmpty [
	self dotenvWrite: 'EMPTY='.

	self assert: dotenv variablesDictionary size equals: 1.
	self assert: (dotenv variablesDictionary at: 'EMPTY') equals: ''.
]

{ #category : #tests }
DotenvTest >> testEmptyFile [
	self dotenvWrite: ''.
	
	self assert: dotenv variablesDictionary isEmpty
]

{ #category : #tests }
DotenvTest >> testMultipleVariables [
	self dotenvWrite: '
		VAR1=var1
		VAR2=var2
'.

	self assert: dotenv variablesDictionary size equals: 2.
	self assert: (dotenv variablesDictionary at: 'VAR1') equals: 'var1'.
	self assert: (dotenv variablesDictionary at: 'VAR2') equals: 'var2'.
]

{ #category : #tests }
DotenvTest >> testNewLine [
	self dotenvWrite: 'DOUBLE_QUOTE="new\nline"'.

	self assert: dotenv variablesDictionary size equals: 1.
	self
		assert: (dotenv variablesDictionary at: 'DOUBLE_QUOTE')
		equals: 'new
line' withUnixLineEndings
]

{ #category : #tests }
DotenvTest >> testSingleQuote [
	self dotenvWrite: 'SINGLE_QUOTE=''quoted'''.

	self assert: dotenv variablesDictionary size equals: 1.
	self assert: (dotenv variablesDictionary at: 'SINGLE_QUOTE') equals: 'quoted'.
]

{ #category : #running }
DotenvTest >> variableNameForTesting [
	^ 'PHARO_DOTENV_TEST_VARIABLE'
]
