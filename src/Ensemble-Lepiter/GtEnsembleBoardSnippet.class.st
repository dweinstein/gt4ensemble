Class {
	#name : 'GtEnsembleBoardSnippet',
	#superclass : 'LeSnippet',
	#instVars : [
		'projectName',
		'boardHeight',
		'boardType'
	],
	#category : 'Ensemble-Lepiter',
	#package : 'Ensemble-Lepiter'
}

{ #category : 'accessing' }
GtEnsembleBoardSnippet class >> contextMenuItemSpecification [
	<leSnippetSpecification>
	^ LeContextMenuItemSpecification new
		snippetClass: self;
		title: self description
]

{ #category : 'accessing' }
GtEnsembleBoardSnippet class >> description [
	^ 'Ensemble Board'
]

{ #category : 'accessing' }
GtEnsembleBoardSnippet class >> empty [
	^ self new
]

{ #category : 'serialization' }
GtEnsembleBoardSnippet class >> leJsonV4AttributeMapping [
	^ super leJsonV4AttributeMapping
		add: #projectName -> #projectName;
		add: #boardHeight -> #boardHeight;
		yourself
]

{ #category : 'serialization' }
GtEnsembleBoardSnippet class >> leJsonV4Name [
	^ 'ensembleBoardSnippet'
]

{ #category : 'visiting' }
GtEnsembleBoardSnippet >> acceptVisitor: aVisitor [
	^ aVisitor visitEnsembleBoardSnippet: self
]

{ #category : 'accessing' }
GtEnsembleBoardSnippet >> asSnippetViewModel [
	^ GtEnsembleBoardSnippetViewModel new snippetModel: self
]

{ #category : 'accessing' }
GtEnsembleBoardSnippet >> boardHeight [
	^ boardHeight ifNil: [ 400 ]
]

{ #category : 'accessing' }
GtEnsembleBoardSnippet >> boardHeight: anInteger [
	boardHeight := anInteger.
	self notifyAnnouncement: (LeSnippetContentChanged new source: self; snippet: self)
]

{ #category : 'accessing' }
GtEnsembleBoardSnippet >> boardType [
	^ boardType ifNil: [ 'task' ]
]

{ #category : 'accessing' }
GtEnsembleBoardSnippet >> boardType: aString [
	boardType := aString
]

{ #category : 'accessing' }
GtEnsembleBoardSnippet >> contentAsString [
	^ 'Board: ', (self projectName ifNil: [ '(auto)' ])
]

{ #category : 'initialization' }
GtEnsembleBoardSnippet >> initialize [
	super initialize.
	boardHeight := 400.
	boardType := 'task'
]

{ #category : 'testing' }
GtEnsembleBoardSnippet >> isProjectBoard [
	^ self boardType = 'project'
]

{ #category : 'testing' }
GtEnsembleBoardSnippet >> isTaskBoard [
	^ self boardType = 'task'
]

{ #category : 'export' }
GtEnsembleBoardSnippet >> markdownOn: aStream level: anInteger [
	aStream
		nextPutAll: '<!-- Ensemble Board: ';
		nextPutAll: (self projectName ifNil: [ 'auto' ]);
		nextPutAll: ' -->'
]

{ #category : 'accessing' }
GtEnsembleBoardSnippet >> project [
	"Resolve the GtEnsembleProject from the board"
	^ GtEnsembleBoard current projectNamed: self projectName
]

{ #category : 'accessing' }
GtEnsembleBoardSnippet >> projectName [
	"If no explicit project name set, infer from page title"
	^ projectName ifNil: [ self page ifNotNil: [ :p | p title ] ]
]

{ #category : 'accessing' }
GtEnsembleBoardSnippet >> projectName: aString [
	projectName := aString.
	self notifyAnnouncement: (LeSnippetContentChanged new source: self; snippet: self)
]

{ #category : 'accessing' }
GtEnsembleBoardSnippet >> storeOn: aStream [
	aStream
		nextPut: $(;
		nextPutAll: self className;
		nextPutAll: ' new boardHeight: '.
	(boardHeight ifNil: [ 400 ]) storeOn: aStream.
	aStream nextPutAll: '; boardType: '.
	self boardType storeOn: aStream.
	projectName ifNotNil: [
		aStream nextPutAll: '; projectName: '.
		projectName storeOn: aStream ].
	aStream nextPut: $)
]
