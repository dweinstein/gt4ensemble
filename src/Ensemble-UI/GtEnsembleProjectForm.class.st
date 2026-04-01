Class {
	#name : 'GtEnsembleProjectForm',
	#superclass : 'Object',
	#instVars : [
		'projectName',
		'projectDirectory',
		'projectDescription',
		'projectDatabase',
		'onAccept'
	],
	#category : 'Ensemble-UI',
	#package : 'Ensemble-UI'
}

{ #category : 'actions' }
GtEnsembleProjectForm >> createProject [
	"Create the project from form data and add to the board"
	| dir desc page proj |
	dir := projectDirectory trimBoth ifEmpty: [ nil ].
	dir ifNotNil: [
		(dir beginsWith: '~/') ifTrue: [
			dir := (FileLocator home / (dir allButFirst: 2)) pathString ] ].
	desc := projectDescription trimBoth ifEmpty: [ nil ].
	
	page := LePage named: projectName trimBoth.
	projectDatabase addPage: page.
	
	proj := GtEnsembleBoard current
		addProjectNamed: projectName trimBoth
		directory: dir
		description: desc
		status: 'Backlog'.
	proj page: page.
	GtEnsembleBoard current saveProject: proj.
	^ proj
]

{ #category : 'magritte' }
GtEnsembleProjectForm >> databaseDescription [
	<magritteDescription>
	^ MASingleOptionDescription new
		label: 'Database';
		priority: 4;
		accessor: #projectDatabase;
		options: GtEnsembleBoard current databases asArray;
		display: [ :db | db databaseName ];
		labelAptitude: [ BrGlamorousLabelAptitude new glamorousFormLabelStyle ];
		addCondition: [ :v | v notNil ] labelled: 'Database is required';
		beRequired
]

{ #category : 'magritte' }
GtEnsembleProjectForm >> descriptionDescription [
	<magritteDescription>
	^ MAStringDescription new
		label: 'Description';
		priority: 3;
		accessor: #projectDescription;
		labelAptitude: [ BrGlamorousLabelAptitude new glamorousFormLabelStyle ]
]

{ #category : 'magritte' }
GtEnsembleProjectForm >> directoryDescription [
	<magritteDescription>
	^ MAStringDescription new
		label: 'Directory';
		priority: 2;
		accessor: #projectDirectory;
		labelAptitude: [ BrGlamorousLabelAptitude new glamorousFormLabelStyle ]
]

{ #category : 'initialization' }
GtEnsembleProjectForm >> initialize [
	projectName := ''.
	projectDirectory := '~/personal/gt'.
	projectDescription := ''.
	projectDatabase := GtEnsembleBoard current defaultDatabase
]

{ #category : 'magritte' }
GtEnsembleProjectForm >> magritteAcceptAction [
	<magritteActionDescription>
	^ super magritteAcceptAction
		label: 'Create';
		onSuccessCallback: (GtMagritteCallback new
			action: [ :aModel :aButton :aMemento :aDescription |
				| proj |
				aMemento commit.
				proj := self createProject.
				onAccept ifNotNil: [ onAccept value: proj ] ]);
		beEnabledOnValidOverallStatus
]

{ #category : 'magritte' }
GtEnsembleProjectForm >> nameDescription [
	<magritteDescription>
	^ MAStringDescription new
		label: 'Name';
		priority: 1;
		accessor: #projectName;
		labelAptitude: [ BrGlamorousLabelAptitude new glamorousFormLabelStyle ];
		addCondition: [ :v | v trimBoth isNotEmpty ] labelled: 'Name is required';
		beRequired
]

{ #category : 'accessing' }
GtEnsembleProjectForm >> onAccept: aBlock [
	onAccept := aBlock
]

{ #category : 'accessing' }
GtEnsembleProjectForm >> onCreated: aBlock [
	onCreated := aBlock
]

{ #category : 'accessing' }
GtEnsembleProjectForm >> projectDatabase [
	^ projectDatabase
]

{ #category : 'accessing' }
GtEnsembleProjectForm >> projectDatabase: aDatabase [
	projectDatabase := aDatabase
]

{ #category : 'accessing' }
GtEnsembleProjectForm >> projectDescription [
	^ projectDescription
]

{ #category : 'accessing' }
GtEnsembleProjectForm >> projectDescription: aString [
	projectDescription := aString
]

{ #category : 'accessing' }
GtEnsembleProjectForm >> projectDirectory [
	^ projectDirectory
]

{ #category : 'accessing' }
GtEnsembleProjectForm >> projectDirectory: aString [
	projectDirectory := aString
]

{ #category : 'accessing' }
GtEnsembleProjectForm >> projectName [
	^ projectName
]

{ #category : 'accessing' }
GtEnsembleProjectForm >> projectName: aString [
	projectName := aString
]
