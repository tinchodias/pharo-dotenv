"
This is a partial port of the nodejs ""dotenv"" module.

Link:
https://www.npmjs.com/package/dotenv
"
Class {
	#name : #Dotenv,
	#superclass : #Object,
	#instVars : [
		'path'
	],
	#category : #Dotenv
}

{ #category : #applying }
Dotenv >> config [
	| initial |
	initial := self environmentVariablesDictionary.
	self variablesDictionary
		keysAndValuesDo: [ :key :value | 
			(initial includesKey: key)
				ifFalse: [ self environmentVariablesAt: key put: value ] ]
]

{ #category : #'applying - private' }
Dotenv >> environmentVariablesAt: key put: value [
	^ OSPlatform current environment setEnv: key value: value
]

{ #category : #'applying - private' }
Dotenv >> environmentVariablesDictionary [
	^ OSPlatform current environment asDictionary
]

{ #category : #'parsing - private' }
Dotenv >> parsedValue: aString [
	| result |
	result := aString trim.

	((result beginsWith: '''') and: [ result endsWith: '''' ])
		ifTrue: [ ^ result allButFirst allButLast ].

	((result beginsWith: '"') and: [ result endsWith: '"' ])
		ifTrue: [ ^ Character lf join: (result allButFirst allButLast splitOn: '\n') ].
		
	^result
]

{ #category : #accessing }
Dotenv >> path [
	^ path ifNil: [ path := '.env' asPath ]
]

{ #category : #accessing }
Dotenv >> path: aPath [ 
	path := aPath
]

{ #category : #accessing }
Dotenv >> variablesDictionary [
	self path exists
		ifFalse: [ ^ Dictionary new ].
	^ self path contents lines
		inject: Dictionary new
		into: [ :dict :each | 
			| lineStream key value |
			lineStream := each readStream.
			key := (lineStream upTo: $=) trimBoth.
			key ifNotEmpty: [ 
				"Skip if empty"
				value := self parsedValue: lineStream upToEnd trimBoth.
				dict
					at: key put: value;
					yourself ].
			dict ]
]
