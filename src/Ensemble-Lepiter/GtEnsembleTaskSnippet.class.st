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

{ #category : 'accessing' }
GtEnsembleTaskSnippet >> createLinkedTask [
	"Create a GtEnsembleTask in the page's project, linked to this snippet."
	| proj newTask |
	proj := self linkedProject.
	proj ifNil: [ ^ nil ].
	newTask := GtEnsembleTask new.
	newTask title: (title ifNil: [ 'Untitled' ]).
	newTask status: (status ifNil: [ 'Backlog' ]).
	newTask priority: priority.
	newTask notes: taskNotes.
	newTask snippet: self.
	self task: newTask.
	proj addTask: newTask.
	^ newTask
]

{ #category : 'gt-views' }
GtEnsembleTaskSnippet >> gtEditFor: aView [
	<gtView>
	| linkedTask |
	linkedTask := self linkedTask.
	linkedTask ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Edit';
		priority: 2;
		object: [ linkedTask ];
		view: #gtMagritteFor:
]

{ #category : 'initialization' }
GtEnsembleTaskSnippet >> initialize [
	super initialize.
	status := 'Backlog'.
	tagNames := #().
	taskNotes := ''
]

{ #category : 'accessing' }
GtEnsembleTaskSnippet >> linkedProject [
	"Return the GtEnsembleProject that owns this snippet's page, if any."
	| page proj |
	page := self page.
	page ifNil: [ ^ nil ].
	proj := GtEnsembleBoard current projects 
		detect: [ :p | p page == page ] 
		ifNone: [ nil ].
	^ proj
]

{ #category : 'accessing' }
GtEnsembleTaskSnippet >> linkedTask [
	"Return the linked GtEnsembleTask if one exists.
	 Primary: direct back-ref (set during loadProjectTasks:into:).
	 Fallback: scan the board for any task whose snippet uid matches ours."
	task ifNotNil: [ ^ task ].
	^ GtEnsembleBoard current allTasks items
		detect: [ :t | 
			t snippet notNil and: [ t snippet uid = self uid ] ]
		ifNone: [ nil ]
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
