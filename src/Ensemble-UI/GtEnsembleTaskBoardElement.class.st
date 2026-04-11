Class {
	#name : 'GtEnsembleTaskBoardElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'board',
		'project'
	],
	#category : 'Ensemble-UI',
	#package : 'Ensemble-UI'
}

{ #category : 'examples' }
GtEnsembleTaskBoardElement class >> example [
	<gtExample>
	^ self forAllTasks: GtEnsembleBoard current allTasks items
]

{ #category : 'instance creation' }
GtEnsembleTaskBoardElement class >> forAllTasks: aCollection [
	^ self new forAllTasks: aCollection
]

{ #category : 'instance creation' }
GtEnsembleTaskBoardElement class >> forTasks: aCollection project: aProject [
	^ self new forTasks: aCollection project: aProject
]

{ #category : 'building' }
GtEnsembleTaskBoardElement >> buildAddButton [
	^ BrButton new
		aptitude: BrGlamorousButtonWithIconAptitude
			+ (BrGlamorousWithExplicitDropdownAptitude
				handle: [
					BrButton new
						aptitude: BrGlamorousButtonWithIconAptitude - BrGlamorousButtonExteriorAptitude;
						icon: BrGlamorousVectorIcons add;
						label: 'Add task' ]
				content: [ :aDropdown | self buildTaskFormFor: aDropdown ]);
		icon: BrGlamorousVectorIcons add;
		label: 'Add task'
]

{ #category : 'building' }
GtEnsembleTaskBoardElement >> buildTaskFormFor: aDropdown [
	| form element |
	form := project
		ifNotNil: [ GtEnsembleTaskForm forProject: project ]
		ifNil: [ GtEnsembleTaskForm new ].
	element := form asGtMagritteViewModel asElement.
	form onAccept: [ :task |
		element enqueueTask: (BlTaskAction new action: [
			element fireEvent: BrDropdownHideWish new.
			element phlow spawnObject: task ]) ].
	element hExact: 400.
	element vFitContent.
	element padding: (BlInsets all: 10).
	^ element
]

{ #category : 'building' }
GtEnsembleTaskBoardElement >> buildToolbar [
	^ BrHorizontalPane new
		hMatchParent;
		vFitContent;
		alignCenterRight;
		padding: (BlInsets top: 2 right: 8 bottom: 0 left: 0);
		addChild: self buildAddButton
]

{ #category : 'initialization' }
GtEnsembleTaskBoardElement >> forAllTasks: aCollection [
	"All tasks across projects - no single project context"
	project := nil.
	board := GtEnsembleBoardElement forTasks: aCollection.
	self addChild: self buildToolbar.
	self addChild: board
]

{ #category : 'initialization' }
GtEnsembleTaskBoardElement >> forTasks: aCollection project: aProject [
	project := aProject.
	board := GtEnsembleBoardElement forTasks: aCollection.
	self addChild: self buildToolbar.
	self addChild: board
]

{ #category : 'initialization' }
GtEnsembleTaskBoardElement >> initialize [
	super initialize.
	self matchParent
]

{ #category : 'lifecycle' }
GtEnsembleTaskBoardElement >> onAddedToSceneGraph [
	super onAddedToSceneGraph.
	GtEnsembleBoard current announcer weak
		when: GtEnsembleBoardUpdated
		send: #requestRebuildBoard
		to: self
]

{ #category : 'lifecycle' }
GtEnsembleTaskBoardElement >> onRemovedFromSceneGraph [
	GtEnsembleBoard current announcer unsubscribe: self.
	super onRemovedFromSceneGraph
]

{ #category : 'updating' }
GtEnsembleTaskBoardElement >> rebuildBoard [
	| tasks newBoard |
	tasks := project
		ifNotNil: [ project tasks ]
		ifNil: [ GtEnsembleBoard current allTasks items ].
	newBoard := GtEnsembleBoardElement forTasks: tasks.
	self replaceChild: board with: newBoard.
	board := newBoard
]

{ #category : 'building' }
GtEnsembleTaskBoardElement >> requestRebuildBoard [
	"Enqueue a rebuild on the UI thread."
	self enqueueTask: (BlTaskAction new action: [ self rebuildBoard ])
]
