Class {
	#name : 'GtEnsembleTag',
	#superclass : 'Object',
	#instVars : [
		'name',
		'color'
	],
	#category : 'Ensemble-Model',
	#package : 'Ensemble-Model'
}

{ #category : 'predefined' }
GtEnsembleTag class >> all [
	"Return all predefined tags"
	^ { self research. self implementation. self bug. self blocked. self spike }
]

{ #category : 'predefined' }
GtEnsembleTag class >> blocked [
	^ self name: 'blocked' color: (Color fromHexString: 'e67e22')
]

{ #category : 'predefined' }
GtEnsembleTag class >> bug [
	^ self name: 'bug' color: (Color fromHexString: 'e74c3c')
]

{ #category : 'predefined' }
GtEnsembleTag class >> implementation [
	^ self name: 'implementation' color: (Color fromHexString: '27ae60')
]

{ #category : 'instance creation' }
GtEnsembleTag class >> name: aString color: aColor [
	^ self new
		name: aString;
		color: aColor;
		yourself
]

{ #category : 'predefined' }
GtEnsembleTag class >> research [
	^ self name: 'research' color: (Color fromHexString: '3498db')
]

{ #category : 'predefined' }
GtEnsembleTag class >> spike [
	^ self name: 'spike' color: (Color fromHexString: '9b59b6')
]

{ #category : 'comparing' }
GtEnsembleTag >> = anObject [
	self class = anObject class ifFalse: [ ^ false ].
	^ self name = anObject name
]

{ #category : 'accessing' }
GtEnsembleTag >> color [
	^ color
]

{ #category : 'accessing' }
GtEnsembleTag >> color: aColor [
	color := aColor
]

{ #category : 'views' }
GtEnsembleTag >> gtDetailsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Details';
		priority: 1;
		items: [ {
			'Name' -> (name ifNil: [ '' ]).
			'Color' -> (color ifNil: [ '' ] ifNotNil: [ :c | c asHexString ]).
		} ];
		column: 'Property' text: [ :assoc | assoc key ] width: 100;
		column: 'Value' text: [ :assoc | assoc value ]
]

{ #category : 'printing' }
GtEnsembleTag >> gtDisplayOn: aStream [
	aStream nextPutAll: (name ifNil: [ 'unnamed' ])
]

{ #category : 'gt - extensions' }
GtEnsembleTag >> gtTasksFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Tasks';
		priority: 2;
		items: [ GtEnsembleBoard current tasksByTag: self name ];
		column: 'Status' text: [ :t | t status ] width: 100;
		column: 'Task' text: [ :t | t title ];
		column: 'Project' text: [ :t | t project ifNotNil: #name ifNil: [ '' ] ] width: 120
]

{ #category : 'comparing' }
GtEnsembleTag >> hash [
	^ self name hash
]

{ #category : 'accessing' }
GtEnsembleTag >> name [
	^ name
]

{ #category : 'accessing' }
GtEnsembleTag >> name: aString [
	name := aString
]

{ #category : 'printing' }
GtEnsembleTag >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: '(';
		nextPutAll: (name ifNil: [ 'unnamed' ]);
		nextPut: $)
]
