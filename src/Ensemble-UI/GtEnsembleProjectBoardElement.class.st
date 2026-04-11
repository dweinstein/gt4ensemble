Class {
	#name : 'GtEnsembleProjectBoardElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'board'
	],
	#category : 'Ensemble-UI',
	#package : 'Ensemble-UI'
}

{ #category : 'examples' }
GtEnsembleProjectBoardElement class >> example [
	<gtExample>
	^ self forProjects: GtEnsembleBoard current projects
]

{ #category : 'instance creation' }
GtEnsembleProjectBoardElement class >> forProjects: aCollection [
	^ self new forProjects: aCollection
]

{ #category : 'building' }
GtEnsembleProjectBoardElement >> buildAddButton [
	^ BrButton new
		aptitude: BrGlamorousButtonWithIconAptitude
			+ (BrGlamorousWithExplicitDropdownAptitude
				handle: [
					BrButton new
						aptitude: BrGlamorousButtonWithIconAptitude - BrGlamorousButtonExteriorAptitude;
						icon: BrGlamorousVectorIcons add;
						label: 'Add project' ]
				content: [ :aDropdown | self buildProjectFormFor: aDropdown ]);
		icon: BrGlamorousVectorIcons add;
		label: 'Add project'
]

{ #category : 'building' }
GtEnsembleProjectBoardElement >> buildProjectFormFor: aDropdown [
	| form element |
	form := GtEnsembleProjectForm new.
	element := form asGtMagritteViewModel asElement.
	form onAccept: [ :proj |
		element enqueueTask: (BlTaskAction new action: [
			element fireEvent: BrDropdownHideWish new.
			element phlow spawnObject: proj ]) ].
	element hExact: 400.
	element vFitContent.
	element padding: (BlInsets all: 10).
	^ element
]

{ #category : 'building' }
GtEnsembleProjectBoardElement >> buildToolbar [
	^ BrHorizontalPane new
		hMatchParent;
		vFitContent;
		alignCenterRight;
		padding: (BlInsets top: 2 right: 8 bottom: 0 left: 0);
		addChild: self buildAddButton
]

{ #category : 'initialization' }
GtEnsembleProjectBoardElement >> forProjects: aCollection [
	board := GtEnsembleBoardElement forProjects: aCollection.
	self addChild: self buildToolbar.
	self addChild: board
]

{ #category : 'initialization' }
GtEnsembleProjectBoardElement >> initialize [
	super initialize.
	self matchParent
]

{ #category : 'lifecycle' }
GtEnsembleProjectBoardElement >> onAddedToSceneGraph [
	super onAddedToSceneGraph.
	GtEnsembleBoard current announcer weak
		when: GtEnsembleBoardUpdated
		send: #requestRebuildBoard
		to: self
]

{ #category : 'lifecycle' }
GtEnsembleProjectBoardElement >> onRemovedFromSceneGraph [
	GtEnsembleBoard current announcer unsubscribe: self.
	super onRemovedFromSceneGraph
]

{ #category : 'updating' }
GtEnsembleProjectBoardElement >> rebuildBoard [
	| newBoard |
	newBoard := GtEnsembleBoardElement forProjects: GtEnsembleBoard current projects.
	self replaceChild: board with: newBoard.
	board := newBoard
]

{ #category : 'building' }
GtEnsembleProjectBoardElement >> requestRebuildBoard [
	"Enqueue a rebuild on the UI thread."
	self enqueueTask: (BlTaskAction new action: [ self rebuildBoard ])
]
