Class {
	#name : 'GtEnsembleProjectGroup',
	#superclass : 'Object',
	#traits : 'TGtGroupWithItems',
	#classTraits : 'TGtGroupWithItems classTrait',
	#category : 'Ensemble-Model',
	#package : 'Ensemble-Model'
}

{ #category : 'views' }
GtEnsembleProjectGroup >> gtProjectsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Projects';
		priority: 1;
		items: [ self items ];
		column: 'Status' text: [ :p | p status ] width: 100;
		column: 'Name' text: [ :p | p name ];
		column: 'Tasks' text: [ :p | p taskCount asString ] width: 60;
		column: 'Active' text: [ :p | p activeTaskCount asString ] width: 60
]
