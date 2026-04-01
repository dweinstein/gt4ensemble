Class {
	#name : 'GtEnsembleCardElement',
	#superclass : 'BrHorizontalPane',
	#instVars : [
		'entity',
		'compact'
	],
	#category : 'Ensemble-UI',
	#package : 'Ensemble-UI'
}

{ #category : 'instance creation' }
GtEnsembleCardElement class >> compactFor: anEntity [
	^ self new entity: anEntity; compact: true; build
]

{ #category : 'instance creation' }
GtEnsembleCardElement class >> for: anEntity [
	^ self new entity: anEntity; compact: false; build
]

{ #category : 'building' }
GtEnsembleCardElement >> accentColor [
	| s |
	s := (entity respondsTo: #status) ifTrue: [ entity status ] ifFalse: [ nil ].
	s ifNil: [ ^ Color gray ].
	s = 'Backlog' ifTrue: [ ^ Color fromHexString: '95a5a6' ].
	s = 'Todo' ifTrue: [ ^ Color fromHexString: '3498db' ].
	s = 'In Progress' ifTrue: [ ^ Color fromHexString: 'f39c12' ].
	s = 'Done' ifTrue: [ ^ Color fromHexString: '27ae60' ].
	s = 'Cancelled' ifTrue: [ ^ Color fromHexString: 'bdc3c7' ].
	^ Color gray
]

{ #category : 'building' }
GtEnsembleCardElement >> build [
	| radius shadowAlpha |
	radius := self isCompact ifTrue: [ 4 ] ifFalse: [ 8 ].
	shadowAlpha := self isCompact ifTrue: [ 0.12 ] ifFalse: [ 0.2 ].
	self hMatchParent; vFitContent.
	self isCompact
		ifTrue: [ self margin: (BlInsets top: 2 bottom: 2) ]
		ifFalse: [ self margin: (BlInsets all: 12) ].
	self background: Color white.
	self geometry: (BlRoundedRectangleGeometry cornerRadius: radius).
	self addAptitude: (BrShadowAptitude new color: (Color gray alpha: shadowAlpha)).
	self addChild: self buildStripe.
	self addChild: self buildContent.
	^ self
]

{ #category : 'building' }
GtEnsembleCardElement >> buildBottomRow [
	| row fontSize |
	fontSize := self isCompact ifTrue: [ 10 ] ifFalse: [ 11 ].
	row := BrHorizontalPane new hMatchParent; vFitContent; alignCenterLeft.
	row margin: (BlInsets top: 2).
	"Tags"
	(entity respondsTo: #tags) ifTrue: [
		entity tags do: [ :tag |
			| tagLabel |
			tagLabel := BrLabel new
				text: (tag name asRopedText foreground: tag color; fontSize: fontSize);
				aptitude: BrGlamorousLabelAptitude new.
			tagLabel background: (tag color alpha: 0.1).
			tagLabel geometry: (BlRoundedRectangleGeometry cornerRadius: 3).
			tagLabel padding: (BlInsets top: 1 left: 4 bottom: 1 right: 4).
			tagLabel margin: (BlInsets right: 4).
			row addChild: tagLabel ] ].
	"Project name (for cross-project views)"
	(entity respondsTo: #project) ifTrue: [
		entity project ifNotNil: [ :proj |
			row addChild: (BrLabel new
				text: (proj name asRopedText foreground: (Color fromHexString: '999999'); fontSize: fontSize);
				aptitude: BrGlamorousLabelAptitude new;
				margin: (BlInsets left: 8)) ] ].
	^ row
]

{ #category : 'building' }
GtEnsembleCardElement >> buildContent [
	| content |
	content := BrVerticalPane new.
	content hMatchParent; vFitContent.
	self isCompact
		ifTrue: [ content padding: (BlInsets top: 4 left: 8 bottom: 4 right: 8) ]
		ifFalse: [ content padding: (BlInsets top: 12 left: 12 bottom: 12 right: 12) ].
	content addChild: self buildTopRow.
	content addChild: self buildName.
	self isCompact ifFalse: [
		self buildExcerpt ifNotNil: [ :el | content addChild: el ] ].
	content addChild: self buildBottomRow.
	^ content
]

{ #category : 'building' }
GtEnsembleCardElement >> buildExcerpt [
	| text |
	(entity respondsTo: #notes) ifFalse: [ ^ nil ].
	text := entity notes.
	(text isNil or: [ text isEmpty ]) ifTrue: [ ^ nil ].
	^ BrLabel new
		text: ((text copyFrom: 1 to: (text size min: 200)) asRopedText
			foreground: (Color fromHexString: '555555');
			fontSize: 12);
		aptitude: BrGlamorousLabelAptitude new;
		margin: (BlInsets top: 4)
]

{ #category : 'building' }
GtEnsembleCardElement >> buildName [
	| text fontSize topMargin |
	fontSize := self isCompact ifTrue: [ 13 ] ifFalse: [ 18 ].
	topMargin := self isCompact ifTrue: [ 2 ] ifFalse: [ 6 ].
	text := (entity name ifNil: [ 'Untitled' ]) asRopedText.
	text fontSize: fontSize.
	text foreground: (Color fromHexString: '1a1a1a').
	^ BrLabel new
		text: text;
		aptitude: BrGlamorousLabelAptitude new;
		margin: (BlInsets top: topMargin)
]

{ #category : 'building' }
GtEnsembleCardElement >> buildStatusBadge [
	| statusName badgeColor text badge fontSize |
	statusName := (entity respondsTo: #status)
		ifTrue: [ entity status ifNil: [ 'Backlog' ] ]
		ifFalse: [ 'Backlog' ].
	badgeColor := self accentColor alpha: 0.15.
	fontSize := self isCompact ifTrue: [ 10 ] ifFalse: [ 11 ].
	text := statusName asRopedText foreground: self accentColor.
	text fontSize: fontSize.
	badge := BrLabel new text: text; aptitude: BrGlamorousLabelAptitude new.
	badge background: badgeColor.
	badge geometry: (BlRoundedRectangleGeometry cornerRadius: 4).
	badge padding: (BlInsets top: 2 left: 6 bottom: 2 right: 6).
	badge margin: (BlInsets right: 6).
	^ badge
]

{ #category : 'building' }
GtEnsembleCardElement >> buildStripe [
	| stripe width cornerSize |
	width := self isCompact ifTrue: [ 3 ] ifFalse: [ 5 ].
	cornerSize := self isCompact ifTrue: [ 4 ] ifFalse: [ 8 ].
	stripe := BlElement new.
	stripe constraintsDo: [ :c |
		c horizontal exact: width.
		c vertical matchParent ].
	stripe background: self accentColor.
	stripe geometry: (BlRoundedRectangleGeometry cornerRadii:
		(BlCornerRadii new topLeft: cornerSize; bottomLeft: cornerSize; topRight: 0; bottomRight: 0; yourself)).
	^ stripe
]

{ #category : 'building' }
GtEnsembleCardElement >> buildTopRow [
	| row |
	row := BrHorizontalPane new hMatchParent; vFitContent; alignCenterLeft.
	row addChild: self buildStatusBadge.
	^ row
]

{ #category : 'accessing' }
GtEnsembleCardElement >> compact: aBoolean [
	compact := aBoolean
]

{ #category : 'accessing' }
GtEnsembleCardElement >> entity [
	^ entity
]

{ #category : 'accessing' }
GtEnsembleCardElement >> entity: anEntity [
	entity := anEntity
]

{ #category : 'accessing' }
GtEnsembleCardElement >> isCompact [
	^ compact ifNil: [ false ]
]
