Class {
	#name : 'GtEnsembleSession',
	#superclass : 'Object',
	#instVars : [
		'path',
		'lastModified',
		'tool'
	],
	#category : 'Ensemble-Model',
	#package : 'Ensemble-Model'
}

{ #category : 'views' }
GtEnsembleSession >> gtDetailsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Details';
		priority: 1;
		items: [ {
			'Tool' -> self toolName.
			'Path' -> (path ifNil: [ '' ] ifNotNil: [ :p | p pathString ]).
			'Last Modified' -> (lastModified ifNil: [ '' ] ifNotNil: [ :d | d asString ]).
		} ];
		column: 'Property' text: [ :assoc | assoc key ] width: 100;
		column: 'Value' text: [ :assoc | assoc value ]
]

{ #category : 'printing' }
GtEnsembleSession >> gtDisplayOn: aStream [
	aStream nextPutAll: self toolName.
	aStream nextPutAll: ' — '.
	lastModified
		ifNotNil: [ :lm |
			aStream nextPutAll: lm asDate printString.
			aStream nextPutAll: ' '.
			aStream nextPutAll: lm asTime print24 ]
		ifNil: [ aStream nextPutAll: 'unknown date' ]
]

{ #category : 'accessing' }
GtEnsembleSession >> isClaudeCode [
	^ tool = #claudeCode
]

{ #category : 'accessing' }
GtEnsembleSession >> isCodex [
	^ tool = #codex
]

{ #category : 'accessing' }
GtEnsembleSession >> lastModified [
	^ lastModified
]

{ #category : 'accessing' }
GtEnsembleSession >> lastModified: aDateAndTime [
	lastModified := aDateAndTime
]

{ #category : 'accessing' }
GtEnsembleSession >> path [
	^ path
]

{ #category : 'accessing' }
GtEnsembleSession >> path: aFileReference [
	path := aFileReference
]

{ #category : 'printing' }
GtEnsembleSession >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: '('.
	aStream nextPutAll: self toolName.
	aStream nextPutAll: ' @ '.
	lastModified ifNotNil: [ :lm | lm printOn: aStream ].
	aStream nextPut: $)
]

{ #category : 'accessing' }
GtEnsembleSession >> tool [
	^ tool
]

{ #category : 'accessing' }
GtEnsembleSession >> tool: aSymbol [
	tool := aSymbol
]

{ #category : 'accessing' }
GtEnsembleSession >> toolName [
	tool = #claudeCode ifTrue: [ ^ 'Claude Code' ].
	tool = #codex ifTrue: [ ^ 'Codex' ].
	^ tool printString
]
