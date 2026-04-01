Class {
	#name : 'GtEnsembleTask',
	#superclass : 'Object',
	#instVars : [
		'title',
		'status',
		'tags',
		'priority',
		'notes',
		'createdAt',
		'updatedAt',
		'project',
		'snippet',
		'syncing'
	],
	#category : 'Ensemble-Model',
	#package : 'Ensemble-Model'
}

{ #category : 'constants' }
GtEnsembleTask class >> statuses [
	^ #('Backlog' 'Todo' 'In Progress' 'Done' 'Cancelled')
]

{ #category : 'instance creation' }
GtEnsembleTask class >> title: aString [
	^ self new title: aString; yourself
]

{ #category : 'instance creation' }
GtEnsembleTask class >> title: aString status: aStatusString [
	^ self new title: aString; status: aStatusString; yourself
]

{ #category : 'tags' }
GtEnsembleTask >> addTag: aTag [
	(tags includes: aTag) ifFalse: [ tags add: aTag ].
	self touch
]

{ #category : 'accessing' }
GtEnsembleTask >> createdAt [
	^ createdAt
]

{ #category : 'gt - extensions' }
GtEnsembleTask >> gtAddTagActionFor: anAction [
	<gtAction>
	^ anAction dropdown
		tooltip: 'Add tag';
		priority: 5;
		icon: BrGlamorousVectorIcons add;
		content: [ :aDropdown |
			| list availableTags |
			availableTags := GtEnsembleBoard current tags reject: [ :t | self hasTag: t ].
			list := BrSimpleList new
				itemStencil: [ BrButton new aptitude: BrGlamorousButtonRectangularAptitude + BrGlamorousButtonLabelAptitude ];
				itemDataBinder: [ :btn :tag |
					btn label: tag name.
					btn action: [ 
						self addTag: tag.
						aDropdown enqueueTask: (BlTaskAction new action: [
							aDropdown fireEvent: BrDropdownHideWish new.
							aDropdown phlow spawnObject: self ]) ] ];
				items: availableTags;
				hExact: 200;
				vFitContentLimited.
			list padding: (BlInsets all: 8).
			list ]
]

{ #category : 'views' }
GtEnsembleTask >> gtDetailsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Details';
		priority: 1;
		items: [ {
			'Title' -> (title ifNil: [ '' ]).
			'Status' -> (status ifNil: [ '' ]).
			'Tags' -> (', ' join: (tags collect: [ :t | t name ])).
			'Priority' -> (priority ifNil: [ '' ] ifNotNil: [ :p | p asString ]).
			'Project' -> (project ifNil: [ '' ] ifNotNil: [ :p | p name ]).
			'Created' -> (createdAt ifNil: [ '' ] ifNotNil: [ :d | d asString ]).
			'Updated' -> (updatedAt ifNil: [ '' ] ifNotNil: [ :d | d asString ]).
		} ];
		column: 'Property' text: [ :assoc | assoc key ] width: 100;
		column: 'Value' text: [ :assoc | assoc value ]
]

{ #category : 'printing' }
GtEnsembleTask >> gtDisplayOn: aStream [
	aStream nextPutAll: (title ifNil: [ 'Untitled task' ])
]

{ #category : 'views' }
GtEnsembleTask >> gtNotesFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Notes';
		priority: 2;
		text: [ notes ifNil: [ '' ] ]
]

{ #category : 'views' }
GtEnsembleTask >> gtProjectFor: aView [
	<gtView>
	project ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Project';
		priority: 10;
		object: [ project ];
		view: #gtTasksFor:
]

{ #category : 'gt - extensions' }
GtEnsembleTask >> gtTagsFor: aView [
	<gtView>
	tags ifEmpty: [ ^ aView empty ].
	^ aView columnedList
		title: 'Tags';
		priority: 4;
		items: [ tags ];
		column: 'Color' stencil: [ :t |
			BlElement new
				size: 12@12;
				geometry: BlCircleGeometry new;
				background: t color ] width: 40;
		column: 'Name' text: [ :t | t name ]
]

{ #category : 'tags' }
GtEnsembleTask >> hasTag: aTagOrName [
	^ tags anySatisfy: [ :t | t name = (aTagOrName isString ifTrue: [ aTagOrName ] ifFalse: [ aTagOrName name ]) ]
]

{ #category : 'initialization' }
GtEnsembleTask >> initialize [
	super initialize.
	status := 'Backlog'.
	tags := OrderedCollection new.
	createdAt := DateAndTime now.
	updatedAt := DateAndTime now
]

{ #category : 'status' }
GtEnsembleTask >> isActive [
	^ #('Todo' 'In Progress') includes: status
]

{ #category : 'status' }
GtEnsembleTask >> isDone [
	^ status = 'Done'
]

{ #category : 'syncing' }
GtEnsembleTask >> isSyncing [
	^ syncing ifNil: [ false ]
]

{ #category : 'status' }
GtEnsembleTask >> moveToBacklog [
	self status: 'Backlog'
]

{ #category : 'status' }
GtEnsembleTask >> moveToCancelled [
	self status: 'Cancelled'
]

{ #category : 'status' }
GtEnsembleTask >> moveToDone [
	self status: 'Done'
]

{ #category : 'status' }
GtEnsembleTask >> moveToInProgress [
	self status: 'In Progress'
]

{ #category : 'status' }
GtEnsembleTask >> moveToTodo [
	self status: 'Todo'
]

{ #category : 'accessing' }
GtEnsembleTask >> name [
	^ title
]

{ #category : 'accessing' }
GtEnsembleTask >> notes [
	^ notes
]

{ #category : 'accessing' }
GtEnsembleTask >> notes: aString [
	notes := aString.
	self touch.
	self syncToSnippet
]

{ #category : 'printing' }
GtEnsembleTask >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: '('.
	aStream nextPutAll: (title ifNil: [ 'untitled' ]).
	aStream nextPutAll: ' ['.
	aStream nextPutAll: (status ifNil: [ '?' ]).
	aStream nextPutAll: '])'
]

{ #category : 'accessing' }
GtEnsembleTask >> priority [
	^ priority
]

{ #category : 'accessing' }
GtEnsembleTask >> priority: anInteger [
	priority := anInteger.
	self touch.
	self syncToSnippet
]

{ #category : 'accessing' }
GtEnsembleTask >> project [
	^ project
]

{ #category : 'accessing' }
GtEnsembleTask >> project: aProject [
	project := aProject
]

{ #category : 'tags' }
GtEnsembleTask >> removeTag: aTag [
	tags remove: aTag ifAbsent: [].
	self touch
]

{ #category : 'accessing' }
GtEnsembleTask >> snippet [
	^ snippet
]

{ #category : 'accessing' }
GtEnsembleTask >> snippet: aSnippet [
	snippet := aSnippet
]

{ #category : 'accessing' }
GtEnsembleTask >> status [
	^ status
]

{ #category : 'api' }
GtEnsembleTask >> status: aString [
	status := aString.
	self touch.
	self syncToSnippet.
	GtEnsembleBoard current announcer announce: GtEnsembleBoardUpdated new
]

{ #category : 'status' }
GtEnsembleTask >> statusColor [
	status = 'Backlog' ifTrue: [ ^ Color fromHexString: '95a5a6' ].
	status = 'Todo' ifTrue: [ ^ Color fromHexString: '3498db' ].
	status = 'In Progress' ifTrue: [ ^ Color fromHexString: 'f39c12' ].
	status = 'Done' ifTrue: [ ^ Color fromHexString: '27ae60' ].
	status = 'Cancelled' ifTrue: [ ^ Color fromHexString: 'bdc3c7' ].
	^ Color gray
]

{ #category : 'syncing' }
GtEnsembleTask >> syncFromSnippet [
	"Pull state from the linked snippet into this domain object"
	snippet ifNil: [ ^ self ].
	self isSyncing ifTrue: [ ^ self ].
	syncing := true.
	[ title := snippet title.
	  status := snippet status ifNil: [ 'Backlog' ].
	  priority := snippet priority.
	  notes := snippet taskNotes.
	  self syncTagsFromSnippet.
	  self touch
	] ensure: [ syncing := false ]
]

{ #category : 'syncing' }
GtEnsembleTask >> syncTagsFromSnippet [
	"Resolve tag names from snippet into tag objects"
	| board newTags |
	snippet tagNames ifNil: [ tags := OrderedCollection new. ^ self ].
	board := GtEnsembleBoard current.
	newTags := OrderedCollection new.
	snippet tagNames do: [ :tagName |
		| tag |
		tag := board tagNamed: tagName.
		tag ifNil: [ tag := board addTag: (GtEnsembleTag name: tagName color: Color gray) ].
		newTags add: tag ].
	tags := newTags
]

{ #category : 'syncing' }
GtEnsembleTask >> syncToSnippet [
	"Push domain object state to the linked snippet"
	snippet ifNil: [ ^ self ].
	self isSyncing ifTrue: [ ^ self ].
	syncing := true.
	[ snippet title: title.
	  snippet status: status.
	  snippet priority: priority.
	  snippet taskNotes: notes.
	  snippet tagNames: (tags collect: [ :t | t name ]) asArray
	] ensure: [ syncing := false ]
]

{ #category : 'accessing' }
GtEnsembleTask >> tags [
	^ tags
]

{ #category : 'accessing' }
GtEnsembleTask >> tags: aCollection [
	tags := aCollection asOrderedCollection.
	self touch.
	self syncToSnippet
]

{ #category : 'accessing' }
GtEnsembleTask >> title [
	^ title
]

{ #category : 'accessing' }
GtEnsembleTask >> title: aString [
	title := aString.
	self touch.
	self syncToSnippet
]

{ #category : 'private' }
GtEnsembleTask >> touch [
	updatedAt := DateAndTime now
]

{ #category : 'accessing' }
GtEnsembleTask >> updatedAt [
	^ updatedAt
]
