Class {
	#name : 'GtEnsembleBoardElement',
	#superclass : 'BrHorizontalPane',
	#instVars : [
		'items',
		'bucketBlock',
		'bucketOrder',
		'groupClass'
	],
	#category : 'Ensemble-UI',
	#package : 'Ensemble-UI'
}

{ #category : 'instance creation' }
GtEnsembleBoardElement class >> byStatus: aCollection groupClass: aClass [
	^ self
		items: aCollection
		bucketBy: [ :item | item status ifNil: [ 'Backlog' ] ]
		order: GtEnsembleTask statuses
		groupClass: aClass
]

{ #category : 'instance creation' }
GtEnsembleBoardElement class >> forProjects: aCollection [
	^ self byStatus: aCollection groupClass: GtEnsembleProjectGroup
]

{ #category : 'instance creation' }
GtEnsembleBoardElement class >> forTasks: aCollection [
	^ self byStatus: aCollection groupClass: GtEnsembleTaskGroup
]

{ #category : 'instance creation' }
GtEnsembleBoardElement class >> items: aCollection bucketBy: aBlock order: anArray groupClass: aClass [
	^ self new
		items: aCollection;
		bucketBlock: aBlock;
		bucketOrder: anArray;
		groupClass: aClass;
		build
]

{ #category : 'accessing' }
GtEnsembleBoardElement >> bucketBlock: aBlock [
	bucketBlock := aBlock
]

{ #category : 'accessing' }
GtEnsembleBoardElement >> bucketOrder: anArray [
	bucketOrder := anArray
]

{ #category : 'building' }
GtEnsembleBoardElement >> build [
	| grouped |
	self matchParent.
	self padding: (BlInsets all: 8).
	grouped := items groupedBy: bucketBlock.
	bucketOrder do: [ :aName |
		| columnItems |
		columnItems := grouped at: aName ifAbsent: [ #() ].
		self addChild: (self buildColumnFor: aName items: columnItems) ].
	grouped keysAndValuesDo: [ :aName :columnItems |
		(bucketOrder includes: aName) ifFalse: [
			self addChild: (self buildColumnFor: aName items: columnItems) ] ].
	^ self
]

{ #category : 'building' }
GtEnsembleBoardElement >> buildCardsContainerFor: columnItems status: statusName [
	| cardsContainer |
	cardsContainer := BlElement new
		layout: (BlLinearLayout vertical cellSpacing: 4);
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ];
		padding: (BlInsets all: 2).
	
	columnItems do: [ :each |
		cardsContainer addChild: (self buildDraggableCardFor: each) ].
	
	cardsContainer addEventHandler: (self buildDropHandlerFor: cardsContainer status: statusName).
	^ cardsContainer
]

{ #category : 'building' }
GtEnsembleBoardElement >> buildColumnFor: columnName items: columnItems [
	| column group header cardsContainer |
	group := groupClass withAll: columnItems.
	
	column := BrVerticalPane new.
	column matchParent.
	column margin: (BlInsets all: 4).
	column background: (self columnBackgroundFor: columnName).
	column padding: (BlInsets all: 6).
	column geometry: (BlRoundedRectangleGeometry cornerRadius: 8).
	
	header := self buildHeaderFor: columnName count: columnItems size group: group.
	column addChild: header.
	
	cardsContainer := self buildCardsContainerFor: columnItems status: columnName.
	column addChild: cardsContainer.
	^ column
]

{ #category : 'building' }
GtEnsembleBoardElement >> buildDraggableCardFor: anEntity [
	"Build a compact card element with drag support"
	| card wrapper |
	card := GtEnsembleCardElement compactFor: anEntity.
	card preventMeAndChildrenMouseEvents.
	
	wrapper := BrHorizontalPane new
		hMatchParent;
		vFitContent.
	wrapper addChild: card.
	wrapper addEventHandler: (BlDragHandler new
		liftItem: [ :aSourceElement |
			BlDragItem new
				sourceElement: aSourceElement;
				domainObject: anEntity;
				stencil: [ :aDragItem | 
					| ghost |
					ghost := GtEnsembleCardElement compactFor: aDragItem domainObject.
					ghost constraintsDo: [ :c | c horizontal exact: 200 ].
					ghost background: (Color white alpha: 0.9).
					ghost ] ]).
	wrapper when: BlAboutToBeDroppedEvent do: [ :anEvent |
		anEvent currentTarget removeFromParent ].
	wrapper when: BlClickEvent do: [ :e | 
		e consumed: true.
		wrapper phlow spawnOrShowObject: anEntity ].
	^ wrapper
]

{ #category : 'building' }
GtEnsembleBoardElement >> buildDropHandlerFor: cardsContainer status: statusName [
	^ BlDropHandler new
		acceptDomainObjectsSuchThat: [ :obj | obj respondsTo: #status: ];
		whenDragEnteredDo: [ :anEvent |
			anEvent mayAcceptItems ifTrue: [
				cardsContainer border: (BlBorder builder
					paint: (Color fromHexString: '3498db');
					dashed;
					width: 2;
					build) ] ];
		whenDragOverDo: [ :anEvent |
			self updateDropIndicatorFor: anEvent ];
		whenDragLeftDo: [ :anEvent |
			anEvent currentTarget removeChildNamed: #'drop-location'.
			cardsContainer border: BlBorder empty ];
		whenDroppedDo: [ :anEvent |
			self handleDrop: anEvent on: cardsContainer status: statusName ]
]

{ #category : 'building' }
GtEnsembleBoardElement >> buildHeaderFor: columnName count: count group: aGroup [
	| header titleText countLabel |
	header := BrHorizontalPane new.
	header fitContent.
	header hMatchParent.
	header padding: (BlInsets bottom: 4).
	header when: BlClickEvent do: [ :e | header phlow spawnObject: aGroup ].
	titleText := columnName asRopedText bold.
	header addChild: (BrLabel new
		text: titleText;
		aptitude: (BrGlamorousLabelAptitude new fontSize: 13);
		hMatchParent).
	countLabel := BrLabel new
		text: (count asString asRopedText foreground: Color gray);
		aptitude: (BrGlamorousLabelAptitude new fontSize: 12).
	header addChild: countLabel.
	^ header
]

{ #category : 'building' }
GtEnsembleBoardElement >> columnBackgroundFor: columnName [
	columnName = 'Backlog' ifTrue: [ ^ Color gray alpha: 0.05 ].
	columnName = 'Todo' ifTrue: [ ^ Color blue alpha: 0.08 ].
	columnName = 'In Progress' ifTrue: [ ^ Color orange alpha: 0.1 ].
	columnName = 'Done' ifTrue: [ ^ Color green darker alpha: 0.1 ].
	columnName = 'Cancelled' ifTrue: [ ^ Color gray alpha: 0.05 ].
	^ Color gray alpha: 0.03
]

{ #category : 'accessing' }
GtEnsembleBoardElement >> groupClass: aClass [
	groupClass := aClass
]

{ #category : 'private' }
GtEnsembleBoardElement >> handleDrop: anEvent on: cardsContainer status: statusName [
	| target position insertIndex layoutChildren |
	target := anEvent currentTarget.
	target removeChildNamed: #'drop-location'.
	cardsContainer border: BlBorder empty.
	
	position := anEvent position y.
	layoutChildren := target children accountedByLayout.
	insertIndex := layoutChildren size + 1.
	layoutChildren doWithIndex: [ :child :idx |
		(insertIndex > layoutChildren size and: [
			position < child bounds inParent center y ])
				ifTrue: [ insertIndex := idx ] ].
	
	anEvent items reverseDo: [ :dragItem |
		| entity card |
		entity := dragItem domainObject.
		entity status: statusName.
		card := self buildDraggableCardFor: entity.
		target addChild: card at: (insertIndex min: target children accountedByLayout size + 1) ]
]

{ #category : 'accessing' }
GtEnsembleBoardElement >> items: aCollection [
	items := aCollection
]

{ #category : 'private' }
GtEnsembleBoardElement >> updateDropIndicatorFor: anEvent [
	| target locationElement position childPosition |
	target := anEvent currentTarget.
	locationElement := target
		childWithId: #'drop-location'
		ifFound: [ :el | el ]
		ifNone: [
			| el |
			el := BlElement new
				background: (Color fromHexString: '3498db');
				constraintsDo: [ :c |
					c ignoreByLayout.
					c horizontal matchParent.
					c vertical exact: 2 ].
			target addChild: el as: #'drop-location'.
			el ].
	position := anEvent position y.
	childPosition := target children accountedByLayout
		detect: [ :child | position < child bounds inParent center y ]
		ifFound: [ :child | child bounds inParent top - 3 ]
		ifNone: [ 
			target children accountedByLayout
				ifEmpty: [ 4 ]
				ifNotEmpty: [ :ch | ch last bounds inParent bottom + 3 ] ].
	locationElement relocate: 0 @ childPosition
]
