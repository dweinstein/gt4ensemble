Class {
	#name : 'GtEnsembleKanbanCardElement',
	#superclass : 'BrVerticalPane',
	#category : 'Ensemble-UI',
	#package : 'Ensemble-UI'
}

{ #category : 'examples' }
GtEnsembleKanbanCardElement class >> example [
	<gtExample>
	^ self new
		hExact: 900;
		vExact: 400;
		padding: (BlInsets all: 5)
]

{ #category : 'initialization' }
GtEnsembleKanbanCardElement >> initialize [
	super initialize.
	self matchParent.
	self addChild: (GtEnsembleProjectBoardElement forProjects: GtEnsembleBoard current projects)
]
