Class {
	#name : 'GtEnsembleProjectSnippet',
	#superclass : 'LeSnippet',
	#instVars : [
		'projectDirectory',
		'projectDescription',
		'projectStatus',
		'projectName',
		'project'
	],
	#category : 'Ensemble-Lepiter',
	#package : 'Ensemble-Lepiter'
}

{ #category : 'accessing' }
GtEnsembleProjectSnippet class >> contextMenuItemSpecification [
	<leSnippetSpecification>
	^ LeContextMenuItemSpecification new
		snippetClass: self;
		title: self description
]

{ #category : 'accessing' }
GtEnsembleProjectSnippet class >> description [
	^ 'Ensemble Project'
]

{ #category : 'accessing' }
GtEnsembleProjectSnippet class >> empty [
	^ self new
]

{ #category : 'serialization' }
GtEnsembleProjectSnippet class >> leJsonV4AttributeMapping [
	^ super leJsonV4AttributeMapping
		add: #projectName -> #projectName;
		add: #projectDirectory -> #projectDirectory;
		add: #projectDescription -> #projectDescription;
		add: #projectStatus -> #projectStatus;
		yourself
]

{ #category : 'serialization' }
GtEnsembleProjectSnippet class >> leJsonV4Name [
	^ 'ensembleProjectSnippet'
]

{ #category : 'visiting' }
GtEnsembleProjectSnippet >> acceptVisitor: aVisitor [
	^ aVisitor visitEnsembleProjectSnippet: self
]

{ #category : 'accessing' }
GtEnsembleProjectSnippet >> asSnippetViewModel [
	^ GtEnsembleProjectSnippetViewModel new snippetModel: self
]

{ #category : 'accessing' }
GtEnsembleProjectSnippet >> contentAsString [
	^ projectDescription ifNil: [ '' ]
]

{ #category : 'accessing' }
GtEnsembleProjectSnippet >> createLinkedProject [
	"Create a GtEnsembleProject backed by this snippet's page."
	| page proj dir |
	page := self page.
	page ifNil: [ ^ nil ].
	dir := projectDirectory isNil or: [ projectDirectory isEmpty ].
	dir := dir ifTrue: [ nil ] ifFalse: [ 
		(projectDirectory beginsWith: '~/')
			ifTrue: [ (FileLocator home / (projectDirectory allButFirst: 2)) pathString ]
			ifFalse: [ projectDirectory ] ].
	proj := GtEnsembleBoard current
		addProjectNamed: self projectName
		directory: dir
		description: (projectDescription ifEmpty: [ nil ])
		status: (projectStatus ifNil: [ 'Backlog' ]).
	proj page: page.
	GtEnsembleBoard current saveProject: proj.
	^ proj
]

{ #category : 'initialization' }
GtEnsembleProjectSnippet >> initialize [
	super initialize.
	projectStatus := 'Backlog'.
	projectDirectory := ''.
	projectDescription := ''
]

{ #category : 'accessing' }
GtEnsembleProjectSnippet >> linkedProject [
	"Return the linked GtEnsembleProject.
	 Primary: direct back-ref (set during loadProjectMetadata:into:).
	 Fallback: match by page (project whose page is our page)."
	| page |
	project ifNotNil: [ ^ project ].
	page := self page.
	page ifNil: [ ^ nil ].
	^ GtEnsembleBoard current projects
		detect: [ :p | p page == page ]
		ifNone: [ nil ]
]

{ #category : 'export' }
GtEnsembleProjectSnippet >> markdownOn: aStream level: anInteger [
	aStream
		nextPutAll: '[';
		nextPutAll: (projectStatus ifNil: [ 'Backlog' ]);
		nextPutAll: '] ';
		nextPutAll: (projectDescription ifNil: [ '' ]);
		nextPutAll: ' (';
		nextPutAll: (projectDirectory ifNil: [ '' ]);
		nextPut: $)
]

{ #category : 'accessing' }
GtEnsembleProjectSnippet >> project [
	^ project
]

{ #category : 'accessing' }
GtEnsembleProjectSnippet >> project: aProject [
	project := aProject
]

{ #category : 'accessing' }
GtEnsembleProjectSnippet >> projectDescription [
	^ projectDescription
]

{ #category : 'accessing' }
GtEnsembleProjectSnippet >> projectDescription: aString [
	projectDescription := aString.
	self updateEditTimeAndEmail.
	self announceContentChangedBy: self.
	project ifNotNil: [ project syncFromSnippet ]
]

{ #category : 'accessing' }
GtEnsembleProjectSnippet >> projectDirectory [
	^ projectDirectory
]

{ #category : 'accessing' }
GtEnsembleProjectSnippet >> projectDirectory: aString [
	projectDirectory := aString.
	self updateEditTimeAndEmail.
	self announceContentChangedBy: self.
	project ifNotNil: [ project syncFromSnippet ]
]

{ #category : 'accessing' }
GtEnsembleProjectSnippet >> projectName [
	^ projectName ifNil: [ self page ifNotNil: [ :p | p title ] ]
]

{ #category : 'accessing' }
GtEnsembleProjectSnippet >> projectName: aString [
	projectName := aString.
	self updateEditTimeAndEmail.
	self announceContentChangedBy: self.
	project ifNotNil: [ project syncFromSnippet ]
]

{ #category : 'accessing' }
GtEnsembleProjectSnippet >> projectStatus [
	^ projectStatus
]

{ #category : 'accessing' }
GtEnsembleProjectSnippet >> projectStatus: aString [
	projectStatus := aString.
	self updateEditTimeAndEmail.
	self announceContentChangedBy: self.
	project ifNotNil: [ project syncFromSnippet ]
]

{ #category : 'accessing' }
GtEnsembleProjectSnippet >> statusColor [
	projectStatus = 'Backlog' ifTrue: [ ^ Color fromHexString: '95a5a6' ].
	projectStatus = 'Todo' ifTrue: [ ^ Color fromHexString: '3498db' ].
	projectStatus = 'In Progress' ifTrue: [ ^ Color fromHexString: 'f39c12' ].
	projectStatus = 'Done' ifTrue: [ ^ Color fromHexString: '27ae60' ].
	projectStatus = 'Cancelled' ifTrue: [ ^ Color fromHexString: 'bdc3c7' ].
	^ Color gray
]

{ #category : 'printing' }
GtEnsembleProjectSnippet >> storeOn: aStream [
	aStream
		nextPut: $(;
		nextPutAll: self className;
		nextPutAll: ' new projectName: '.
	(self projectName ifNil: [ '' ]) storeOn: aStream.
	aStream nextPutAll: '; projectStatus: '.
	(projectStatus ifNil: [ 'Backlog' ]) storeOn: aStream.
	aStream nextPutAll: '; projectDescription: '.
	(projectDescription ifNil: [ '' ]) storeOn: aStream.
	aStream nextPutAll: '; projectDirectory: '.
	(projectDirectory ifNil: [ '' ]) storeOn: aStream.
	aStream nextPut: $)
]
