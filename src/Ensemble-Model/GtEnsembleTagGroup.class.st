Class {
	#name : 'GtEnsembleTagGroup',
	#superclass : 'Object',
	#traits : 'TGtGroupWithItems',
	#classTraits : 'TGtGroupWithItems classTrait',
	#category : 'Ensemble-Model',
	#package : 'Ensemble-Model'
}

{ #category : 'gt-views' }
GtEnsembleTagGroup >> gtTagsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Tags';
		priority: 1;
		items: [ self items ];
		column: 'Name' text: #name weight: 2;
		column: 'Tasks' text: [ :t | 
			(GtEnsembleBoard current allTasks items count: [ :task | task hasTag: t ]) asString ] width: 80
]
