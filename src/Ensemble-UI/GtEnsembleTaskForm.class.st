Class {
	#name : 'GtEnsembleTaskForm',
	#superclass : 'Object',
	#instVars : [
		'taskTitle',
		'taskProject',
		'availableProjects',
		'onAccept'
	],
	#category : 'Ensemble-UI',
	#package : 'Ensemble-UI'
}

{ #category : 'instance creation' }
GtEnsembleTaskForm class >> forProject: aProject [
	^ self new taskProject: aProject
]

{ #category : 'actions' }
GtEnsembleTaskForm >> createTask [
	"Create the task and add to the project.
	 Persistence is handled by GtEnsembleProject>>#addTask:."
	^ taskProject addTaskNamed: taskTitle trimBoth
]

{ #category : 'initialization' }
GtEnsembleTaskForm >> initialize [
	taskTitle := ''.
	availableProjects := GtEnsembleBoard current projects asArray
]

{ #category : 'magritte' }
GtEnsembleTaskForm >> magritteAcceptAction [
	<magritteActionDescription>
	^ super magritteAcceptAction
		label: 'Create';
		onSuccessCallback: (GtMagritteCallback new
			action: [ :aModel :aButton :aMemento :aDescription |
				| task |
				aMemento commit.
				task := self createTask.
				onAccept ifNotNil: [ onAccept value: task ] ]);
		beEnabledOnValidOverallStatus
]

{ #category : 'accessing' }
GtEnsembleTaskForm >> onAccept: aBlock [
	onAccept := aBlock
]

{ #category : 'magritte' }
GtEnsembleTaskForm >> projectDescription [
	<magritteDescription>
	^ MASingleOptionDescription new
		label: 'Project';
		priority: 2;
		accessor: #taskProject;
		options: availableProjects;
		display: [ :p | p name ];
		labelAptitude: [ BrGlamorousLabelAptitude new glamorousFormLabelStyle ];
		addCondition: [ :v | v notNil ] labelled: 'Project is required';
		beRequired
]

{ #category : 'accessing' }
GtEnsembleTaskForm >> taskProject [
	^ taskProject
]

{ #category : 'accessing' }
GtEnsembleTaskForm >> taskProject: aProject [
	taskProject := aProject
]

{ #category : 'accessing' }
GtEnsembleTaskForm >> taskTitle [
	^ taskTitle
]

{ #category : 'accessing' }
GtEnsembleTaskForm >> taskTitle: aString [
	taskTitle := aString
]

{ #category : 'magritte' }
GtEnsembleTaskForm >> titleDescription [
	<magritteDescription>
	^ MAStringDescription new
		label: 'Title';
		priority: 1;
		accessor: #taskTitle;
		labelAptitude: [ BrGlamorousLabelAptitude new glamorousFormLabelStyle ];
		addCondition: [ :v | v trimBoth isNotEmpty ] labelled: 'Title is required';
		beRequired
]
