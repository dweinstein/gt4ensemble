Class {
	#name : 'GtEnsembleProjectSnippetElement',
	#superclass : 'LeSnippetElement',
	#instVars : [
		'contentElement'
	],
	#category : 'Ensemble-Lepiter',
	#package : 'Ensemble-Lepiter'
}

{ #category : 'building' }
GtEnsembleProjectSnippetElement >> buildDescriptionRow [
	| model descText row editor |
	model := self snippetViewModel snippetModel.
	descText := model projectDescription.
	(descText isNil or: [ descText isEmpty ]) ifTrue: [ descText := 'click to add description' ].
	
	row := BrHorizontalPane new hMatchParent; vFitContent; alignCenterLeft.
	row margin: (BlInsets top: 4).
	row addChild: (BrLabel new
		text: ('Desc: ' asRopedText foreground: (Color fromHexString: '999999'));
		aptitude: (BrGlamorousLabelAptitude new fontSize: 11)).
	editor := BrEditableLabel new
		aptitude: BrGlamorousEditableLabelAptitude new;
		text: descText;
		hMatchParent;
		when: BrEditorAcceptWish do: [ :aWish |
			model projectDescription: aWish text asString ].
	row addChild: editor.
	^ row
]

{ #category : 'building' }
GtEnsembleProjectSnippetElement >> buildDirectoryRow [
	| model dirText row editor |
	model := self snippetViewModel snippetModel.
	dirText := model projectDirectory.
	(dirText isNil or: [ dirText isEmpty ]) ifTrue: [ dirText := 'click to set directory' ].
	
	row := BrHorizontalPane new hMatchParent; vFitContent; alignCenterLeft.
	row margin: (BlInsets top: 2).
	row addChild: (BrLabel new
		text: ('Dir: ' asRopedText foreground: (Color fromHexString: '999999'));
		aptitude: (BrGlamorousLabelAptitude new fontSize: 11)).
	editor := BrEditableLabel new
		aptitude: BrGlamorousEditableLabelAptitude new;
		text: dirText;
		hMatchParent;
		when: BrEditorAcceptWish do: [ :aWish |
			model projectDirectory: aWish text asString ].
	row addChild: editor.
	^ row
]

{ #category : 'building' }
GtEnsembleProjectSnippetElement >> buildHeaderRow [
	| model header statusButton nameLabel actionButton dirButton linkedProject |
	model := self snippetViewModel snippetModel.
	
	header := BrHorizontalPane new hMatchParent; vFitContent; alignCenterLeft.
	
	statusButton := self buildStatusDropdownFor: model.
	statusButton margin: (BlInsets right: 6).
	header addChild: statusButton.
	
	nameLabel := BrLabel new
		text: ((model page ifNil: [ 'Project' ] ifNotNil: [ :p | p title ]) asRopedText bold; fontSize: 13);
		aptitude: BrGlamorousLabelAptitude new.
	nameLabel hMatchParent.
	header addChild: nameLabel.
	
	linkedProject := model linkedProject.
	actionButton := linkedProject
		ifNotNil: [ 
			BrButton new
				aptitude: BrGlamorousButtonWithIconAptitude new;
				icon: BrGlamorousVectorIcons inspect;
				label: 'Open project board';
				action: [ :btn |
					btn phlow spawnTool: (GtInspectorTool 
						forObject: linkedProject 
						viewSelector: #gtBoardFor:) ] ]
		ifNil: [
			BrButton new
				aptitude: BrGlamorousButtonWithLabelAptitude + BrGlamorousButtonRectangularAptitude;
				label: 'Create project';
				action: [ :btn | 
					model createLinkedProject.
					self updateContent ] ].
	header addChild: actionButton.
	
	dirButton := BrButton new
		aptitude: BrGlamorousButtonWithIconAptitude new;
		icon: BrGlamorousVectorIcons folder;
		label: 'Open directory';
		action: [ :btn |
			| dir |
			dir := model projectDirectory.
			(dir isNotNil and: [ dir isNotEmpty ]) ifTrue: [
				btn phlow spawnObject: dir asFileReference ] ].
	header addChild: dirButton.
	^ header
]

{ #category : 'building' }
GtEnsembleProjectSnippetElement >> buildStatusDropdownFor: model [
	^ BrButton new
		label: (model projectStatus ifNil: [ 'Backlog' ]);
		aptitude: BrGlamorousButtonWithLabelAptitude new
			+ (BrGlamorousButtonRectangularAptitude new cornerRadius: 3)
			+ (BrGlamorousWithDropdownAptitude
				handle: [ BrButton new
					label: (model projectStatus ifNil: [ 'Backlog' ]);
					aptitude: BrGlamorousButtonWithLabelAptitude new
						+ (BrGlamorousButtonRectangularAptitude new cornerRadius: 3) ]
				content: [ | list |
					list := BrSimpleList new.
					list fitContent.
					list vFitContentLimited.
					list stencil: [ :aStatus :index |
						BrButton new
							label: aStatus;
							aptitude: BrGlamorousButtonWithLabelAptitude new;
							action: [ :btn |
								model projectStatus: aStatus.
								btn fireEvent: BrDropdownHideWish new.
								self updateContent ] ].
					list items: GtEnsembleTask statuses.
					list ])
]

{ #category : 'initialization' }
GtEnsembleProjectSnippetElement >> initialize [
	super initialize.
	self hMatchParent.
	self vFitContent.
	contentElement := BrVerticalPane new
		hMatchParent;
		vFitContent;
		padding: (BlInsets all: 8)
]

{ #category : 'hooks' }
GtEnsembleProjectSnippetElement >> onSnippetContentChanged: anAnnouncement [
	self enqueueTask: (BlTaskAction new action: [ self updateContent ])
]

{ #category : 'hooks' }
GtEnsembleProjectSnippetElement >> onSnippetViewModelChanged [
	super onSnippetViewModelChanged.
	self updateContent
]

{ #category : 'accessing' }
GtEnsembleProjectSnippetElement >> snippetContent [
	^ contentElement
]

{ #category : 'accessing' }
GtEnsembleProjectSnippetElement >> snippetToolbar [
	^ nil
]

{ #category : 'hooks' }
GtEnsembleProjectSnippetElement >> subscribeToSnippetViewModel [
	super subscribeToSnippetViewModel.
	self snippetViewModel snippetModel weak
		when: LeSnippetContentChanged
		send: #onSnippetContentChanged:
		to: self
]

{ #category : 'hooks' }
GtEnsembleProjectSnippetElement >> unsubscribeFromSnippetViewModel [
	super unsubscribeFromSnippetViewModel.
	self snippetViewModel snippetModel unsubscribe: self
]

{ #category : 'updating' }
GtEnsembleProjectSnippetElement >> updateContent [
	contentElement removeChildren.
	contentElement addChild: self buildHeaderRow.
	contentElement addChild: self buildDescriptionRow.
	contentElement addChild: self buildDirectoryRow
]
