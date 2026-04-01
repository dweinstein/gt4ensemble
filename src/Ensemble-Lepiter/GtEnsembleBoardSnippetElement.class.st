Class {
	#name : 'GtEnsembleBoardSnippetElement',
	#superclass : 'LeSnippetElement',
	#instVars : [
		'contentElement'
	],
	#category : 'Ensemble-Lepiter',
	#package : 'Ensemble-Lepiter'
}

{ #category : 'initialization' }
GtEnsembleBoardSnippetElement >> initialize [
	super initialize.
	self hMatchParent.
	self vFitContent.
	contentElement := BrVerticalPane new
		hMatchParent;
		vFitContent
]

{ #category : 'hooks' }
GtEnsembleBoardSnippetElement >> onSiblingSnippetChanged: anAnnouncement [
	"A sibling snippet changed - refresh if it was a task snippet"
	(anAnnouncement snippet isKindOf: GtEnsembleTaskSnippet) ifFalse: [ ^ self ].
	self enqueueTask: (BlTaskAction new action: [ self updateContent ])
]

{ #category : 'hooks' }
GtEnsembleBoardSnippetElement >> onSnippetContentChanged: anAnnouncement [
	self enqueueTask: (BlTaskAction new action: [ self updateContent ])
]

{ #category : 'hooks' }
GtEnsembleBoardSnippetElement >> onSnippetViewModelChanged [
	super onSnippetViewModelChanged.
	self updateContent
]

{ #category : 'accessing' }
GtEnsembleBoardSnippetElement >> snippetContent [
	^ contentElement
]

{ #category : 'accessing' }
GtEnsembleBoardSnippetElement >> snippetToolbar [
	^ nil
]

{ #category : 'hooks' }
GtEnsembleBoardSnippetElement >> subscribeToSnippetViewModel [
	super subscribeToSnippetViewModel.
	self snippetViewModel snippetModel weak
		when: LeSnippetContentChanged
		send: #onSnippetContentChanged:
		to: self.
	"Subscribe to sibling task snippet changes via the page"
	self snippetViewModel snippetModel page ifNotNil: [ :aPage |
		aPage weak
			when: LeSnippetContentChanged
			send: #onSiblingSnippetChanged:
			to: self ]
]

{ #category : 'hooks' }
GtEnsembleBoardSnippetElement >> unsubscribeFromSnippetViewModel [
	super unsubscribeFromSnippetViewModel.
	self snippetViewModel snippetModel unsubscribe: self.
	self snippetViewModel snippetModel page ifNotNil: [ :aPage |
		aPage unsubscribe: self ]
]

{ #category : 'updating' }
GtEnsembleBoardSnippetElement >> updateContent [
	| model boardElement |
	contentElement removeChildren.
	model := self snippetViewModel snippetModel.
	
	model isProjectBoard ifTrue: [
		boardElement := GtEnsembleProjectBoardElement forProjects: GtEnsembleBoard current projects.
		boardElement constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical exact: model boardHeight ].
		contentElement addChild: boardElement.
		^ self ].
	
	"Task board - scoped to project if projectName set, otherwise all tasks"
	model projectName ifNil: [
		boardElement := GtEnsembleTaskBoardElement forAllTasks: GtEnsembleBoard current allTasks items.
		boardElement constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical exact: model boardHeight ].
		contentElement addChild: boardElement.
		^ self ].
	
	model project ifNil: [
		contentElement addChild: (BrLabel new
			text: (('No project found: ', model projectName) asRopedText 
				foreground: Color gray;
				fontSize: 12);
			aptitude: BrGlamorousLabelAptitude new;
			padding: (BlInsets all: 12)).
		^ self ].
	
	boardElement := GtEnsembleTaskBoardElement forTasks: model project tasks project: model project.
	boardElement constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical exact: model boardHeight ].
	contentElement addChild: boardElement
]
