Class {
	#name : 'GtEnsembleProject',
	#superclass : 'Object',
	#instVars : [
		'name',
		'directory',
		'description',
		'status',
		'tasks',
		'createdAt',
		'updatedAt',
		'page',
		'syncing'
	],
	#category : 'Ensemble-Model',
	#package : 'Ensemble-Model'
}

{ #category : 'instance creation' }
GtEnsembleProject class >> name: aString directory: aPath description: aDesc [
	^ self new
		name: aString;
		directory: aPath;
		description: aDesc;
		yourself
]

{ #category : 'instance creation' }
GtEnsembleProject class >> name: aString directory: aPath description: aDesc status: aStatus [
	^ self new
		name: aString;
		directory: aPath;
		description: aDesc;
		status: aStatus;
		yourself
]

{ #category : 'accessing' }
GtEnsembleProject class >> statuses [
	^ #('Backlog' 'Todo' 'In Progress' 'Done' 'Cancelled')
]

{ #category : 'tasks' }
GtEnsembleProject >> activeTaskCount [
	^ (tasks select: [ :t | t isActive ]) size
]

{ #category : 'tasks' }
GtEnsembleProject >> addTask: aTask [
	tasks add: aTask.
	aTask project: self.
	self touch.
	GtEnsembleBoard current announcer announce: GtEnsembleBoardUpdated new.
	^ aTask
]

{ #category : 'tasks' }
GtEnsembleProject >> addTaskNamed: aString [
	^ self addTask: (GtEnsembleTask title: aString)
]

{ #category : 'accessing' }
GtEnsembleProject >> createdAt [
	^ createdAt
]

{ #category : 'accessing' }
GtEnsembleProject >> databaseName [
	"Return the Lepiter database name for this project's page, or empty string."
	^ self page 
		ifNotNil: [ :p | p database ifNotNil: [ :d | d databaseName ] ifNil: [ '' ] ]
		ifNil: [ '' ]
]

{ #category : 'accessing' }
GtEnsembleProject >> description [
	^ description
]

{ #category : 'accessing' }
GtEnsembleProject >> description: aString [
	description := aString.
	self touch.
	self syncToSnippet
]

{ #category : 'magritte-descriptions' }
GtEnsembleProject >> descriptionDescription [
	<magritteDescription>
	^ MAMemoDescription new
		label: 'Description';
		priority: 4;
		accessor: #description;
		labelAptitude: [ BrGlamorousLabelAptitude new glamorousFormLabelStyle ]
]

{ #category : 'accessing' }
GtEnsembleProject >> directory [
	^ directory
]

{ #category : 'accessing' }
GtEnsembleProject >> directory: aFileReference [
	directory := aFileReference ifNotNil: [ aFileReference asFileReference ].
	self touch.
	self syncToSnippet
]

{ #category : 'magritte-descriptions' }
GtEnsembleProject >> directoryDescription [
	<magritteDescription>
	^ MAStringDescription new
		label: 'Directory';
		priority: 3;
		accessor: #directoryString;
		labelAptitude: [ BrGlamorousLabelAptitude new glamorousFormLabelStyle ]
]

{ #category : 'accessing' }
GtEnsembleProject >> directoryString [
	^ directory ifNil: [ '' ] ifNotNil: [ :d | d pathString ]
]

{ #category : 'accessing' }
GtEnsembleProject >> directoryString: aString [
	| trimmed |
	trimmed := aString trimBoth.
	trimmed isEmpty 
		ifTrue: [ self directory: nil ]
		ifFalse: [ 
			(trimmed beginsWith: '~/')
				ifTrue: [ self directory: (FileLocator home / (trimmed allButFirst: 2)) ]
				ifFalse: [ self directory: trimmed asFileReference ] ]
]

{ #category : 'gt - extensions' }
GtEnsembleProject >> gtBoardFor: aView [
	<gtView>
	^ aView explicit
		title: 'Task board';
		priority: 1;
		stencil: [ GtEnsembleTaskBoardElement forTasks: self tasks project: self ]
]

{ #category : 'gt-actions' }
GtEnsembleProject >> gtDeleteActionFor: anAction [
	<gtAction>
	^ anAction dropdown
		tooltip: 'Remove project from board (keeps Lepiter page)';
		priority: 50;
		icon: BrGlamorousVectorIcons remove;
		content: [ :aDropdown |
			| confirm |
			confirm := BrVerticalPane new fitContent.
			confirm padding: (BlInsets all: 10).
			confirm addChild: (BrLabel new
				text: ('Remove "' , (name ifNil: [ '?' ]) , '" from board?' , String cr,
					'The Lepiter page will be kept intact.');
				aptitude: BrGlamorousLabelAptitude new;
				margin: (BlInsets bottom: 8)).
			confirm addChild: (BrButton new
				label: 'Remove';
				aptitude: BrGlamorousButtonWithLabelAptitude new;
				action: [ :btn |
					GtEnsembleBoard current deleteProject: self.
					aDropdown fireEvent: BrDropdownHideWish new.
					btn phlow spawnObject: GtEnsembleBoard current ]).
			confirm ]
]

{ #category : 'gt - extensions' }
GtEnsembleProject >> gtDescriptionFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Description';
		priority: 3;
		aptitude: [ BrGlamorousRegularEditorAptitude ];
		text: [ description ifNil: [ '' ] ];
		actionButtonIcon: BrGlamorousVectorIcons accept
			tooltip: 'Save'
			action: [ :aButton |
				aButton parent parent parent parent
					allChildrenBreadthFirstDetect: [ :el | el isKindOf: BrEditor ]
					ifFound: [ :anEditor |
						| text |
						text := anEditor text asString trimBoth.
						self description: (text ifEmpty: [ nil ]) ]
					ifNone: [ ] ]
]

{ #category : 'gt - extensions' }
GtEnsembleProject >> gtDetailsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Details';
		priority: 4;
		items: [ {
			'Name' -> (name ifNil: [ '' ]).
			'Status' -> (status ifNil: [ '' ]).
			'Description' -> (description ifNil: [ '' ]).
			'Directory' -> (directory ifNil: [ '' ] ifNotNil: [ :d | d pathString ]).
			'Tasks' -> tasks size asString.
			'Created' -> (createdAt ifNil: [ '' ] ifNotNil: [ :d | d asString ]).
			'Updated' -> (updatedAt ifNil: [ '' ] ifNotNil: [ :d | d asString ]).
		} ];
		column: 'Property' text: [ :assoc | assoc key ] width: 100;
		column: 'Value' text: [ :assoc | assoc value ]
]

{ #category : 'views' }
GtEnsembleProject >> gtDirectoryFor: aView [
	<gtView>
	directory ifNil: [ ^ aView empty ].
	directory exists ifFalse: [ ^ aView empty ].
	^ aView forward
		title: 'Directory';
		priority: 10;
		object: [ directory ];
		view: #gtItemsFor:
]

{ #category : 'printing' }
GtEnsembleProject >> gtDisplayOn: aStream [
	aStream nextPutAll: (name ifNil: [ 'Unnamed project' ])
]

{ #category : 'views' }
GtEnsembleProject >> gtRepositoryFor: aView [
	<gtView>
	self hasRepository ifFalse: [ ^ aView empty ].
	^ aView forward
		title: 'Repository';
		priority: 11;
		object: [ self icebergRepository ];
		view: #gtRepositoryDirectoryFor:
]

{ #category : 'views' }
GtEnsembleProject >> gtSessionsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Sessions';
		priority: 12;
		items: [ self sessions ];
		column: 'Tool' text: [ :s | s toolName ] width: 100;
		column: 'Last Modified' text: [ :s | s lastModified ifNil: [ '' ] ifNotNil: [ :d | d asString ] ]
]

{ #category : 'views' }
GtEnsembleProject >> gtTasksFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Tasks';
		priority: 1;
		items: [ self tasks ];
		column: 'Status' text: [ :t | t status ] width: 100;
		column: 'Task' text: [ :t | t title ];
		column: 'Tags' text: [ :t | ', ' join: (t tags collect: [ :tg | tg name ]) ] width: 120;
		column: 'Priority' text: [ :t | t priority ifNil: [ '' ] ifNotNil: [ :p | p asString ] ] width: 60
]

{ #category : 'git' }
GtEnsembleProject >> hasRepository [
	^ self icebergRepository notNil
]

{ #category : 'git' }
GtEnsembleProject >> icebergRepository [
	"Find Iceberg repository for this project directory"
	directory ifNil: [ ^ nil ].
	^ IceRepository registry
		detect: [ :r | r location notNil and: [ r location resolve = directory resolve ] ]
		ifNone: [ nil ]
]

{ #category : 'sessions' }
GtEnsembleProject >> inferToolFor: aDirectory [
	"Infer whether a session directory is Claude Code or Codex"
	(aDirectory / 'sessions-index.json') exists ifTrue: [ ^ #claudeCode ].
	(aDirectory children anySatisfy: [ :f | f isDirectory ]) ifTrue: [ ^ #claudeCode ].
	^ #unknown
]

{ #category : 'initialization' }
GtEnsembleProject >> initialize [
	super initialize.
	status := 'Backlog'.
	tasks := GtEnsembleTaskGroup new.
	createdAt := DateAndTime now.
	updatedAt := DateAndTime now
]

{ #category : 'status' }
GtEnsembleProject >> isActive [
	^ #('Todo' 'In Progress') includes: status
]

{ #category : 'status' }
GtEnsembleProject >> isDone [
	^ status = 'Done'
]

{ #category : 'testing' }
GtEnsembleProject >> isSyncing [
	^ syncing ifNil: [ false ]
]

{ #category : 'accessing' }
GtEnsembleProject >> name [
	^ name
]

{ #category : 'accessing' }
GtEnsembleProject >> name: aString [
	name := aString.
	self touch
]

{ #category : 'magritte-descriptions' }
GtEnsembleProject >> nameDescription [
	<magritteDescription>
	^ MAStringDescription new
		label: 'Name';
		priority: 1;
		accessor: #name;
		labelAptitude: [ BrGlamorousLabelAptitude new glamorousFormLabelStyle ];
		beRequired
]

{ #category : 'accessing' }
GtEnsembleProject >> page [
	^ page
]

{ #category : 'accessing' }
GtEnsembleProject >> page: aPage [
	page := aPage
]

{ #category : 'printing' }
GtEnsembleProject >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: (name ifNil: [ 'unnamed' ]);
		nextPutAll: ' [';
		nextPutAll: (status ifNil: [ '?' ]).
	tasks ifNotNil: [ 
		tasks size > 0 ifTrue: [
			aStream
				nextPutAll: ', ';
				print: tasks size;
				nextPutAll: ' task';
				nextPutAll: (tasks size = 1 ifTrue: [ '' ] ifFalse: [ 's' ]) ] ].
	aStream
		nextPut: $];
		nextPut: $)
]

{ #category : 'accessing' }
GtEnsembleProject >> projectSnippet [
	"Return the GtEnsembleProjectSnippet from the linked page"
	page ifNil: [ ^ nil ].
	^ page children 
		detect: [ :s | s isKindOf: GtEnsembleProjectSnippet ] 
		ifFound: [ :s | s ]
		ifNone: [ nil ]
]

{ #category : 'tasks' }
GtEnsembleProject >> removeTask: aTask [
	tasks remove: aTask ifAbsent: [].
	aTask project: nil.
	self touch.
	GtEnsembleBoard current announcer announce: GtEnsembleBoardUpdated new
]

{ #category : 'sessions' }
GtEnsembleProject >> sessions [
	"Find Claude Code / Codex sessions for this project directory.
	Matches exact directory and immediate parent directory sessions."
	| sessionsDir projectEncoded parentEncoded results |
	directory ifNil: [ ^ #() ].
	sessionsDir := FileLocator home / '.claude' / 'projects'.
	sessionsDir exists ifFalse: [ ^ #() ].
	projectEncoded := directory pathString copyReplaceAll: '/' with: '-'.
	parentEncoded := directory parent pathString copyReplaceAll: '/' with: '-'.
	results := OrderedCollection new.
	sessionsDir children do: [ :d |
		d isDirectory ifTrue: [
			(d basename = projectEncoded or: [ d basename = parentEncoded ]) ifTrue: [
				results add: (GtEnsembleSession new
					path: d;
					lastModified: d entry modificationTime;
					tool: (self inferToolFor: d);
					yourself) ] ] ].
	^ results sorted: [ :a :b | a lastModified > b lastModified ]
]

{ #category : 'accessing' }
GtEnsembleProject >> status [
	^ status
]

{ #category : 'accessing' }
GtEnsembleProject >> status: aString [
	status := aString.
	self touch.
	self syncToSnippet.
	GtEnsembleBoard current announcer announce: GtEnsembleBoardUpdated new
]

{ #category : 'status' }
GtEnsembleProject >> statusColor [
	^ GtEnsembleTask new status: status; statusColor
]

{ #category : 'magritte-descriptions' }
GtEnsembleProject >> statusDescription [
	<magritteDescription>
	^ MASingleOptionDescription new
		label: 'Status';
		priority: 2;
		accessor: #status;
		options: self class statuses;
		labelAptitude: [ BrGlamorousLabelAptitude new glamorousFormLabelStyle ];
		beRequired
]

{ #category : 'syncing' }
GtEnsembleProject >> syncFromSnippet [
	"Pull state from the linked project snippet without triggering sync-back"
	| snippet |
	snippet := self projectSnippet.
	snippet ifNil: [ ^ self ].
	self isSyncing ifTrue: [ ^ self ].
	syncing := true.
	[ directory := (snippet projectDirectory ifEmpty: [ nil ]) ifNotNil: [ :d | d asFileReference ].
	  description := snippet projectDescription ifEmpty: [ nil ].
	  status := snippet projectStatus ifNil: [ 'Backlog' ].
	  self touch
	] ensure: [ syncing := false ]
]

{ #category : 'syncing' }
GtEnsembleProject >> syncToSnippet [
	"Push project state to the linked project snippet"
	| snippet |
	self isSyncing ifTrue: [ ^ self ].
	snippet := self projectSnippet.
	snippet ifNil: [ ^ self ].
	syncing := true.
	[ snippet projectDirectory: (directory ifNil: [ '' ] ifNotNil: [ :d | d pathString ]).
	  snippet projectDescription: (description ifNil: [ '' ]).
	  snippet projectStatus: (status ifNil: [ 'Backlog' ])
	] ensure: [ syncing := false ]
]

{ #category : 'tasks' }
GtEnsembleProject >> taskCount [
	^ tasks size
]

{ #category : 'accessing' }
GtEnsembleProject >> tasks [
	^ tasks
]

{ #category : 'tasks' }
GtEnsembleProject >> tasksByStatus [
	^ tasks groupedBy: [ :t | t status ]
]

{ #category : 'tasks' }
GtEnsembleProject >> tasksDoing [
	^ tasks select: [ :t | t status = 'In Progress' ]
]

{ #category : 'tasks' }
GtEnsembleProject >> tasksDone [
	^ tasks select: [ :t | t isDone ]
]

{ #category : 'private' }
GtEnsembleProject >> touch [
	updatedAt := DateAndTime now
]

{ #category : 'accessing' }
GtEnsembleProject >> updatedAt [
	^ updatedAt
]
