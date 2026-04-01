Class {
	#name : 'GtEnsembleTaskGroup',
	#superclass : 'Object',
	#traits : 'TGtGroupWithItems',
	#classTraits : 'TGtGroupWithItems classTrait',
	#category : 'Ensemble-Model',
	#package : 'Ensemble-Model'
}

{ #category : 'views' }
GtEnsembleTaskGroup >> gtTasksFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Tasks';
		priority: 1;
		items: [ self items ];
		column: 'Status' text: [ :t | t status ] width: 100;
		column: 'Task' text: [ :t | t title ];
		column: 'Project' text: [ :t | t project ifNil: [ '' ] ifNotNil: [ :p | p name ] ] width: 150;
		column: 'Tags' text: [ :t | ', ' join: (t tags collect: [ :tg | tg name ]) ] width: 120
]
