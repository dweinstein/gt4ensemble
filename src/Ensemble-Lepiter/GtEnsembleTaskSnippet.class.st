Class {
	#name : 'GtEnsembleTaskSnippet',
	#superclass : 'LeSnippet',
	#instVars : [
		'title',
		'status',
		'tagNames',
		'priority',
		'taskNotes',
		'task'
	],
	#category : 'Ensemble-Lepiter',
	#package : 'Ensemble-Lepiter'
}

{ #category : 'accessing' }
GtEnsembleTaskSnippet class >> contextMenuItemSpecification [
	<leSnippetSpecification>
	^ LeContextMenuItemSpecification new
		snippetClass: self;
		title: self description
]

{ #category : 'accessing' }
GtEnsembleTaskSnippet class >> description [
	^ 'Ensemble Task'
]

{ #category : 'accessing' }
GtEnsembleTaskSnippet class >> empty [
	^ self new
]

{ #category : 'serialization' }
GtEnsembleTaskSnippet class >> leJsonV4AttributeMapping [
	^ super leJsonV4AttributeMapping
		add: #title -> #title;
		add: #status -> #status;
		add: #tagNames -> #tagNames;
		add: #priority -> #priority;
		add: #taskNotes -> #taskNotes;
		yourself
]

{ #category : 'serialization' }
GtEnsembleTaskSnippet class >> leJsonV4Name [
	^ 'ensembleTaskSnippet'
]

{ #category : 'visiting' }
GtEnsembleTaskSnippet >> acceptVisitor: aVisitor [
	^ aVisitor visitEnsembleTaskSnippet: self
]

{ #category : 'accessing' }
GtEnsembleTaskSnippet >> asSnippetViewModel [
	^ GtEnsembleTaskSnippetViewModel new snippetModel: self
]

{ #category : 'accessing' }
GtEnsembleTaskSnippet >> contentAsString [
	^ title ifNil: [ '' ]
]

{ #category : 'initialization' }
GtEnsembleTaskSnippet >> initialize [
	super initialize.
	status := 'Backlog'.
	tagNames := #().
	taskNotes := ''
]

{ #category : 'export' }
GtEnsembleTaskSnippet >> markdownOn: aStream level: anInteger [
	aStream
		nextPutAll: '- [';
		nextPutAll: (status ifNil: [ 'Backlog' ]);
		nextPutAll: '] ';
		nextPutAll: (title ifNil: [ '' ]).
	(tagNames notNil and: [ tagNames notEmpty ]) ifTrue: [
		tagNames do: [ :t | aStream nextPutAll: ' #'; nextPutAll: t ] ]
]

{ #category : 'accessing' }
GtEnsembleTaskSnippet >> priority [
	^ priority
]

{ #category : 'accessing' }
GtEnsembleTaskSnippet >> priority: aValue [
	priority := aValue.
	self updateEditTimeAndEmail.
	self announceContentChangedBy: self.
	task ifNotNil: [ task syncFromSnippet ]
]

{ #category : 'accessing' }
GtEnsembleTaskSnippet >> status [
	^ status
]

{ #category : 'accessing' }
GtEnsembleTaskSnippet >> status: aString [
	status := aString.
	self updateEditTimeAndEmail.
	self announceContentChangedBy: self.
	task ifNotNil: [ task syncFromSnippet ]
]

{ #category : 'accessing' }
GtEnsembleTaskSnippet >> statusColor [
	status = 'Backlog' ifTrue: [ ^ Color fromHexString: '95a5a6' ].
	status = 'Todo' ifTrue: [ ^ Color fromHexString: '3498db' ].
	status = 'In Progress' ifTrue: [ ^ Color fromHexString: 'f39c12' ].
	status = 'Done' ifTrue: [ ^ Color fromHexString: '27ae60' ].
	status = 'Cancelled' ifTrue: [ ^ Color fromHexString: 'bdc3c7' ].
	^ Color gray
]

{ #category : 'printing' }
GtEnsembleTaskSnippet >> storeOn: aStream [
	aStream
		nextPut: $(;
		nextPutAll: self className;
		nextPutAll: ' new title: '.
	(title ifNil: [ '' ]) storeOn: aStream.
	aStream nextPutAll: '; status: '.
	(status ifNil: [ 'Backlog' ]) storeOn: aStream.
	aStream nextPutAll: '; priority: '.
	priority storeOn: aStream.
	aStream nextPutAll: '; taskNotes: '.
	(taskNotes ifNil: [ '' ]) storeOn: aStream.
	aStream nextPutAll: '; tagNames: '.
	(tagNames ifNil: [ #() ]) storeOn: aStream.
	aStream nextPut: $)
]

{ #category : 'accessing' }
GtEnsembleTaskSnippet >> tagNames [
	^ tagNames
]

{ #category : 'accessing' }
GtEnsembleTaskSnippet >> tagNames: anArray [
	tagNames := anArray.
	self updateEditTimeAndEmail.
	self announceContentChangedBy: self.
	task ifNotNil: [ task syncFromSnippet ]
]

{ #category : 'accessing' }
GtEnsembleTaskSnippet >> task [
	^ task
]

{ #category : 'accessing' }
GtEnsembleTaskSnippet >> task: aTask [
	task := aTask
]

{ #category : 'accessing' }
GtEnsembleTaskSnippet >> taskNotes [
	^ taskNotes
]

{ #category : 'accessing' }
GtEnsembleTaskSnippet >> taskNotes: aString [
	taskNotes := aString.
	self updateEditTimeAndEmail.
	self announceContentChangedBy: self.
	task ifNotNil: [ task syncFromSnippet ]
]

{ #category : 'accessing' }
GtEnsembleTaskSnippet >> title [
	^ title
]

{ #category : 'accessing' }
GtEnsembleTaskSnippet >> title: aString [
	title := aString.
	self updateEditTimeAndEmail.
	self announceContentChangedBy: self.
	task ifNotNil: [ task syncFromSnippet ]
]
