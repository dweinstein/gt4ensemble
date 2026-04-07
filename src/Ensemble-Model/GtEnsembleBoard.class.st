Class {
	#name : 'GtEnsembleBoard',
	#superclass : 'Object',
	#instVars : [
		'projects',
		'tags',
		'announcer'
	],
	#classInstVars : [
		'current'
	],
	#category : 'Ensemble-Model',
	#package : 'Ensemble-Model'
}

{ #category : 'accessing' }
GtEnsembleBoard class >> current [
	^ current ifNil: [ 
		current := self new.
		current loadFromLepiter.
		current ]
]

{ #category : 'instance creation' }
GtEnsembleBoard class >> newEmpty [
	"Create a board without loading from Lepiter - for testing"
	| board |
	board := self basicNew.
	board instVarNamed: 'projects' put: OrderedCollection new.
	board instVarNamed: 'tags' put: GtEnsembleTag all asOrderedCollection.
	^ board
]

{ #category : 'utilities' }
GtEnsembleBoard class >> reloadSnippetMappings [
	"After loading Ensemble into a fresh image, call this to convert
	 any LeUnknownSnippet back into proper ensemble snippet objects.
	 Note: db reload does NOT resolve already-cached unknowns."
	| ensembleTypes |
	LeJsonV4 cleanUniqueInstance.
	ensembleTypes := #('ensembleProjectSnippet' 'ensembleTaskSnippet' 'ensembleBoardSnippet').
	LeDatabasesRegistry default defaultLogicalDatabase databases do: [ :db |
		| unknowns |
		unknowns := OrderedCollection new.
		db pages do: [ :page |
			page allChildrenDepthFirst do: [ :s |
				(s isKindOf: LeUnknownSnippet) ifTrue: [
					(ensembleTypes anySatisfy: [ :t | s jsonString includesSubstring: t ])
						ifTrue: [ unknowns add: { page. s } ] ] ] ].
		unknowns ifNotEmpty: [
			db monitor stopMonitoring.
			unknowns do: [ :pair |
				| page stale fresh |
				page := pair first.
				stale := pair second.
				fresh := LeJsonV4 uniqueInstance deserialize: stale jsonString readStream.
				fresh uid: stale uid.
				page removeSnippet: stale.
				page addSnippet: fresh ].
			db monitor startMonitoring ] ]
]

{ #category : 'accessing' }
GtEnsembleBoard class >> reset [
	current := nil
]

{ #category : 'statistics' }
GtEnsembleBoard >> activeProjectCount [
	^ (projects select: [ :p | p isActive ]) size
]

{ #category : 'queries' }
GtEnsembleBoard >> activeProjects [
	^ GtEnsembleProjectGroup withAll: (projects select: [ :p | p isActive ])
]

{ #category : 'api' }
GtEnsembleBoard >> addProject: aProject [
	projects add: aProject.
	self announcer announce: GtEnsembleBoardUpdated new.
	^ aProject
]

{ #category : 'projects' }
GtEnsembleBoard >> addProjectNamed: aName directory: aDir description: aDesc [
	^ self addProject: (GtEnsembleProject name: aName directory: aDir description: aDesc)
]

{ #category : 'projects' }
GtEnsembleBoard >> addProjectNamed: aName directory: aDir description: aDesc status: aStatus [
	^ self addProject: (GtEnsembleProject name: aName directory: aDir description: aDesc status: aStatus)
]

{ #category : 'tags' }
GtEnsembleBoard >> addTag: aTag [
	(tags anySatisfy: [ :t | t name = aTag name ]) ifFalse: [ tags add: aTag ].
	^ aTag
]

{ #category : 'queries' }
GtEnsembleBoard >> allTasks [
	^ GtEnsembleTaskGroup withAll: (projects flatCollect: [ :p | p tasks ])
]

{ #category : 'queries' }
GtEnsembleBoard >> allTasksInProgress [
	^ GtEnsembleTaskGroup withAll: (self allTasks items select: [ :t | t status = 'In Progress' ])
]

{ #category : 'accessing' }
GtEnsembleBoard >> announcer [
	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : 'projects' }
GtEnsembleBoard >> createProjectNamed: aName directory: aDir description: aDesc [
	^ self createProjectNamed: aName directory: aDir description: aDesc status: 'Backlog'
]

{ #category : 'projects' }
GtEnsembleBoard >> createProjectNamed: aName directory: aDir description: aDesc status: aStatus [
	"Create a new project, add it to the board, and save to Lepiter"
	| proj |
	proj := self addProjectNamed: aName directory: aDir description: aDesc status: aStatus.
	self saveProject: proj.
	^ proj
]

{ #category : 'accessing' }
GtEnsembleBoard >> databases [
	"Return all loaded Lepiter databases"
	^ LeDatabasesRegistry default defaultLogicalDatabase databases
]

{ #category : 'accessing' }
GtEnsembleBoard >> defaultDatabase [
	"Return the default Lepiter database for new projects"
	^ LeDatabasesRegistry default defaultLogicalDatabase databases first
]

{ #category : 'persistence' }
GtEnsembleBoard >> deleteProject: aProject [
	"Remove a project from the board and delete its Lepiter page"
	| page |
	projects remove: aProject ifAbsent: [].
	page := aProject page.
	(page notNil and: [ page database notNil ]) ifTrue: [
		page database removePage: page ].
	self announcer announce: GtEnsembleBoardUpdated new
]

{ #category : 'gt - extensions' }
GtEnsembleBoard >> gtAllTasksFor: aView [
	<gtView>
	^ aView columnedList
		title: 'All tasks';
		priority: 3;
		items: [ self allTasks items ];
		column: 'Status' text: [ :t | t status ] width: 100;
		column: 'Task' text: [ :t | t title ];
		column: 'Project' text: [ :t | t project ifNotNil: #name ifNil: [ '' ] ] width: 120
]

{ #category : 'gt - extensions' }
GtEnsembleBoard >> gtBoardFor: aView [
	<gtView>
	^ aView explicit
		title: 'Task board';
		priority: 2;
		stencil: [ GtEnsembleTaskBoardElement forAllTasks: self allTasks items ]
]

{ #category : 'gt - extensions' }
GtEnsembleBoard >> gtByTagFor: aView [
	<gtView>
	self tags ifEmpty: [ ^ aView empty ].
	^ aView columnedList
		title: 'By tag';
		priority: 4;
		items: [ self tags ];
		column: 'Tag' text: [ :t | t name ] width: 120;
		column: 'Color' stencil: [ :t | 
			BlElement new 
				size: 12@12; 
				geometry: BlCircleGeometry new; 
				background: t color ] width: 40;
		column: 'Tasks' text: [ :t | (self tasksByTag: t name) size asString ] width: 60
]

{ #category : 'printing' }
GtEnsembleBoard >> gtDisplayOn: aStream [
	aStream nextPutAll: 'Ensemble Board — '.
	aStream nextPutAll: self summaryString
]

{ #category : 'gt - extensions' }
GtEnsembleBoard >> gtProjectsBoardFor: aView [
	<gtView>
	^ aView explicit
		title: 'Project board';
		priority: 0;
		stencil: [ GtEnsembleProjectBoardElement forProjects: self projects ]
]

{ #category : 'views' }
GtEnsembleBoard >> gtProjectsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Projects';
		priority: 1;
		items: [ self projects ];
		column: 'Status' text: [ :p | p status ] width: 100;
		column: 'Name' text: [ :p | p name ];
		column: 'Tasks' text: [ :p | p taskCount asString ] width: 60;
		column: 'Active' text: [ :p | p activeTaskCount asString ] width: 60;
		column: 'Directory' text: [ :p | p directory ifNil: [ '' ] ifNotNil: [ :d | d pathString ] ]
]

{ #category : 'statistics' }
GtEnsembleBoard >> inProgressTaskCount [
	^ self allTasksInProgress size
]

{ #category : 'initialization' }
GtEnsembleBoard >> initialize [
	projects := OrderedCollection new.
	tags := GtEnsembleTag all asOrderedCollection
]

{ #category : 'persistence' }
GtEnsembleBoard >> loadFromLepiter [
	"Load all projects from all Lepiter databases"
	projects := OrderedCollection new.
	self databases do: [ :db |
		db pages do: [ :page |
			| taskSnippets hasProjectSnippet |
			taskSnippets := page children select: [ :s | s isKindOf: GtEnsembleTaskSnippet ].
			hasProjectSnippet := page children anySatisfy: [ :s | s isKindOf: GtEnsembleProjectSnippet ].
			(taskSnippets isNotEmpty or: [ hasProjectSnippet ]) ifTrue: [
				| proj |
				proj := self projectFromPage: page taskSnippets: taskSnippets.
				proj ifNotNil: [ projects add: proj ] ] ] ]
]

{ #category : 'persistence' }
GtEnsembleBoard >> loadProjectMetadata: aPage into: proj [
	"Load metadata from project snippet"
	(aPage children isNotEmpty and: [ aPage children first isKindOf: GtEnsembleProjectSnippet ]) ifFalse: [ ^ self ].
	proj page: aPage.
	proj syncFromSnippet
]

{ #category : 'persistence' }
GtEnsembleBoard >> loadProjectTasks: taskSnippets into: proj [
	taskSnippets do: [ :snippet |
		| task |
		task := GtEnsembleTask new.
		task title: snippet title.
		task status: (snippet status ifNil: [ 'Backlog' ]).
		task priority: snippet priority.
		task notes: snippet taskNotes.
		snippet tagNames ifNotNil: [ :names |
			names do: [ :tagName |
				| tag |
				tag := self tagNamed: tagName.
				tag ifNil: [ tag := self addTag: (GtEnsembleTag name: tagName color: Color gray) ].
				task addTag: tag ] ].
		"Establish two-way binding"
		task snippet: snippet.
		snippet task: task.
		proj addTask: task ]
]

{ #category : 'printing' }
GtEnsembleBoard >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: ' ('.
	aStream nextPutAll: self summaryString.
	aStream nextPut: $)
]

{ #category : 'statistics' }
GtEnsembleBoard >> projectCount [
	^ projects size
]

{ #category : 'persistence' }
GtEnsembleBoard >> projectFromPage: aPage taskSnippets: taskSnippets [
	"Build a GtEnsembleProject from a Lepiter page"
	| proj |
	proj := GtEnsembleProject new.
	proj name: aPage title.
	proj page: aPage.
	self loadProjectMetadata: aPage into: proj.
	self loadProjectTasks: taskSnippets into: proj.
	^ proj
]

{ #category : 'projects' }
GtEnsembleBoard >> projectNamed: aString [
	^ projects detect: [ :p | p name = aString ] ifNone: [ nil ]
]

{ #category : 'accessing' }
GtEnsembleBoard >> projects [
	^ projects
]

{ #category : 'queries' }
GtEnsembleBoard >> projectsByStatus [
	^ projects groupedBy: [ :p | p status ]
]

{ #category : 'api' }
GtEnsembleBoard >> removeProject: aProject [
	projects remove: aProject ifAbsent: [].
	self announcer announce: GtEnsembleBoardUpdated new
]

{ #category : 'persistence' }
GtEnsembleBoard >> saveAllProjects [
	"Save all projects to the Lepiter database"
	projects do: [ :p | self saveProject: p ]
]

{ #category : 'persistence' }
GtEnsembleBoard >> saveProject: aProject [
	"Save or update a project in its Lepiter database"
	| db page |
	db := aProject page
		ifNotNil: [ :p | p database ]
		ifNil: [ self defaultDatabase ].
	db ifNil: [ ^ self ].
	
	page := aProject page ifNil: [
		| newPage |
		newPage := LePage named: aProject name.
		db addPage: newPage.
		aProject page: newPage.
		newPage ].
	
	self saveProjectMetadata: aProject toPage: page.
	self saveProjectTasks: aProject toPage: page
]

{ #category : 'persistence' }
GtEnsembleBoard >> saveProjectMetadata: aProject toPage: page [
	| metaSnippet |
	(page children isNotEmpty and: [ page children first isKindOf: GtEnsembleProjectSnippet ])
		ifTrue: [
			metaSnippet := page children first.
			metaSnippet projectName: aProject name.
			metaSnippet projectDirectory: (aProject directory ifNil: [ '' ] ifNotNil: [ :d | d pathString ]).
			metaSnippet projectDescription: (aProject description ifNil: [ '' ]).
			metaSnippet projectStatus: (aProject status ifNil: [ 'Backlog' ]) ]
		ifFalse: [
			metaSnippet := GtEnsembleProjectSnippet new.
			metaSnippet projectName: aProject name.
			metaSnippet projectDirectory: (aProject directory ifNil: [ '' ] ifNotNil: [ :d | d pathString ]).
			metaSnippet projectDescription: (aProject description ifNil: [ '' ]).
			metaSnippet projectStatus: (aProject status ifNil: [ 'Backlog' ]).
			page addSnippet: metaSnippet ]
]

{ #category : 'persistence' }
GtEnsembleBoard >> saveProjectTasks: aProject toPage: page [
	"Remove existing task snippets and re-add from domain model"
	(page children select: [ :s | s isKindOf: GtEnsembleTaskSnippet ]) 
		do: [ :s | page removeSnippet: s ].
	
	aProject tasks do: [ :task |
		| snippet |
		snippet := GtEnsembleTaskSnippet new.
		snippet title: task title.
		snippet status: task status.
		snippet priority: task priority.
		snippet taskNotes: task notes.
		snippet tagNames: (task tags collect: [ :t | t name ]) asArray.
		"Establish two-way binding"
		task snippet: snippet.
		snippet task: task.
		page addSnippet: snippet ]
]

{ #category : 'statistics' }
GtEnsembleBoard >> summaryString [
	^ String streamContents: [ :s |
		s print: self activeProjectCount.
		s nextPutAll: ' active projects, '.
		s print: self inProgressTaskCount.
		s nextPutAll: ' in-progress tasks' ]
]

{ #category : 'tags' }
GtEnsembleBoard >> tagNamed: aString [
	^ tags detect: [ :t | t name = aString ] ifNone: [ nil ]
]

{ #category : 'accessing' }
GtEnsembleBoard >> tags [
	^ tags
]

{ #category : 'queries' }
GtEnsembleBoard >> tasksByStatus [
	^ self allTasks items groupedBy: [ :t | t status ]
]

{ #category : 'queries' }
GtEnsembleBoard >> tasksByTag: aTagName [
	^ GtEnsembleTaskGroup withAll: (self allTasks items select: [ :t | t hasTag: aTagName ])
]

{ #category : 'statistics' }
GtEnsembleBoard >> totalTaskCount [
	^ self allTasks size
]
