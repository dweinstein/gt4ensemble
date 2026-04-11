Class {
	#name : 'GtEnsembleTaskSnippetElement',
	#superclass : 'LeSnippetElement',
	#instVars : [
		'contentElement'
	],
	#category : 'Ensemble-Lepiter',
	#package : 'Ensemble-Lepiter'
}

{ #category : 'building' }
GtEnsembleTaskSnippetElement >> buildAccentStripeFor: model [
	| stripe |
	stripe := BlElement new.
	stripe constraintsDo: [ :c |
		c horizontal exact: 3.
		c vertical matchParent ].
	stripe background: model statusColor.
	stripe geometry: (BlRoundedRectangleGeometry cornerRadius: 2).
	^ stripe
]

{ #category : 'building' }
GtEnsembleTaskSnippetElement >> buildAddTagButtonFor: tags model: model [
	^ BrButton new
		label: '+';
		aptitude: BrGlamorousButtonWithLabelAptitude new
			+ (BrGlamorousButtonRectangularAptitude new cornerRadius: 3)
			+ (BrGlamorousWithDropdownAptitude
				handle: [ BrButton new
					label: '+';
					aptitude: BrGlamorousButtonWithLabelAptitude new
						+ (BrGlamorousButtonRectangularAptitude new cornerRadius: 3) ]
				content: [ | list availableTags |
					availableTags := GtEnsembleTag all
						reject: [ :t | tags notNil and: [ tags includes: t name ] ].
					list := BrSimpleList new.
					list fitContent.
					list vFitContentLimited.
					list stencil: [ :aTag :index |
						BrButton new
							label: aTag name;
							aptitude: BrGlamorousButtonWithLabelAptitude new;
							action: [ :aButton |
								model tagNames: ((tags ifNil: [ #() ]) copyWith: aTag name).
								aButton fireEvent: BrDropdownHideWish new.
								self updateContent ] ].
					list items: availableTags.
					list ]);
		margin: (BlInsets left: 2)
]

{ #category : 'building' }
GtEnsembleTaskSnippetElement >> buildStatusDropdownFor: model [
	^ BrButton new
		label: (model status ifNil: [ 'Backlog' ]);
		aptitude: BrGlamorousButtonWithLabelAptitude new
			+ (BrGlamorousButtonRectangularAptitude new cornerRadius: 3)
			+ (BrGlamorousWithDropdownAptitude
				handle: [ BrButton new
					label: (model status ifNil: [ 'Backlog' ]);
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
								model status: aStatus.
								btn fireEvent: BrDropdownHideWish new.
								self updateContent ] ].
					list items: GtEnsembleTask statuses.
					list ])
]

{ #category : 'building' }
GtEnsembleTaskSnippetElement >> buildTagChipFor: tagName tags: tags model: model [
	| tagColor predefined tagButton |
	predefined := GtEnsembleTag all detect: [ :t | t name = tagName ] ifNone: [ nil ].
	tagColor := predefined ifNotNil: [ :t | t color ] ifNil: [ Color gray ].
	tagButton := BrButton new
		label: tagName;
		aptitude: BrGlamorousButtonWithLabelAptitude new
			+ (BrGlamorousButtonRectangularAptitude new cornerRadius: 3).
	tagButton action: [ :btn |
		model tagNames: (tags copyWithout: tagName).
		self updateContent ].
	tagButton background: (tagColor alpha: 0.1).
	tagButton margin: (BlInsets right: 4).
	^ tagButton
]

{ #category : 'building' }
GtEnsembleTaskSnippetElement >> buildTagsRowFor: model [
	| tags tagsRow |
	tags := model tagNames.
	tagsRow := BrHorizontalPane new hMatchParent; vFitContent; alignCenterLeft.
	tagsRow margin: (BlInsets top: 2).
	(tags notNil and: [ tags notEmpty ]) ifTrue: [
		tags do: [ :tagName |
			tagsRow addChild: (self buildTagChipFor: tagName tags: tags model: model) ] ].
	tagsRow addChild: (self buildAddTagButtonFor: tags model: model).
	^ tagsRow
]

{ #category : 'building' }
GtEnsembleTaskSnippetElement >> buildTopRowFor: model [
	| topRow statusButton titleEditor linkedTask actionButton |
	topRow := BrHorizontalPane new
		hMatchParent;
		vFitContent;
		alignCenterLeft.
	
	statusButton := self buildStatusDropdownFor: model.
	statusButton margin: (BlInsets right: 6).
	statusButton constraintsDo: [ :c | c linear vertical alignCenter ].
	topRow addChild: statusButton.
	
	titleEditor := BrEditableLabel new
		aptitude: BrGlamorousEditableLabelAptitude new;
		text: (model title ifNil: [ 'Untitled' ]);
		hMatchParent;
		when: BrEditorAcceptWish do: [ :aWish |
			model title: aWish text asString.
			self updateContent ].
	topRow addChild: titleEditor.
	
	linkedTask := model linkedTask.
	linkedTask ifNil: [
		model linkedProject ifNotNil: [
			actionButton := BrButton new
				aptitude: BrGlamorousButtonWithLabelAptitude + BrGlamorousButtonRectangularAptitude;
				label: 'Create task';
				action: [ :btn | 
					model createLinkedTask.
					self updateContent ].
			topRow addChild: actionButton ] ].
	
	^ topRow
]

{ #category : 'initialization' }
GtEnsembleTaskSnippetElement >> initialize [
	super initialize.
	self hMatchParent.
	self vFitContent.
	contentElement := BrHorizontalPane new
		hMatchParent;
		vFitContent;
		padding: (BlInsets all: 4)
]

{ #category : 'hooks' }
GtEnsembleTaskSnippetElement >> onSnippetContentChanged: anAnnouncement [
	self enqueueTask: (BlTaskAction new action: [ self updateContent ])
]

{ #category : 'hooks' }
GtEnsembleTaskSnippetElement >> onSnippetViewModelChanged [
	super onSnippetViewModelChanged.
	self updateContent
]

{ #category : 'accessing' }
GtEnsembleTaskSnippetElement >> snippetContent [
	^ contentElement
]

{ #category : 'accessing' }
GtEnsembleTaskSnippetElement >> snippetToolbar [
	^ nil
]

{ #category : 'hooks' }
GtEnsembleTaskSnippetElement >> subscribeToSnippetViewModel [
	super subscribeToSnippetViewModel.
	self snippetViewModel snippetModel weak
		when: LeSnippetContentChanged
		send: #onSnippetContentChanged:
		to: self
]

{ #category : 'hooks' }
GtEnsembleTaskSnippetElement >> unsubscribeFromSnippetViewModel [
	super unsubscribeFromSnippetViewModel.
	self snippetViewModel snippetModel unsubscribe: self
]

{ #category : 'updating' }
GtEnsembleTaskSnippetElement >> updateContent [
	| model content |
	contentElement removeChildren.
	model := self snippetViewModel snippetModel.
	
	contentElement addChild: (self buildAccentStripeFor: model).
	
	content := BrVerticalPane new
		hMatchParent;
		vFitContent;
		padding: (BlInsets left: 8 right: 4).
	content addChild: (self buildTopRowFor: model).
	content addChild: (self buildTagsRowFor: model).
	contentElement addChild: content
]
