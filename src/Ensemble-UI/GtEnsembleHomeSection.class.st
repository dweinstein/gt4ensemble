Class {
	#name : 'GtEnsembleHomeSection',
	#superclass : 'GtHomeMultiCardSection',
	#category : 'Ensemble-UI',
	#package : 'Ensemble-UI'
}

{ #category : 'helpers' }
GtEnsembleHomeSection >> addShowOnHoverResizersTo: anElement [
	anElement
		addAptitude: (BrGlamorousWithHorizontalResizerAptitude new
			beRight;
			resizerDo: [ :aResizer |
				anElement addAptitude: (BrLazyStyleCommonAptitude new
					default: [ :aStyle | aStyle do: [ :w | aResizer visibility: BlVisibility hidden ] ];
					hovered: [ :aStyle |
						aStyle
							do: [ :w | aResizer visibility: BlVisibility visible ]
							after: [ :w | aResizer visibility: BlVisibility hidden ] ]) ]);
		addAptitude: (BrGlamorousWithVerticalResizerAptitude new
			beBottom;
			resizerDo: [ :aResizer |
				anElement addAptitude: (BrLazyStyleCommonAptitude new
					default: [ :aStyle | aStyle do: [ :w | aResizer visibility: BlVisibility hidden ] ];
					hovered: [ :aStyle |
						aStyle
							do: [ :w | aResizer visibility: BlVisibility visible ]
							after: [ :w | aResizer visibility: BlVisibility hidden ] ]) ])
]

{ #category : 'helpers' }
GtEnsembleHomeSection >> buildCardContainer: card [
	| container |
	container := BrVerticalPane new.
	container
		hExact: 200;
		vExact: 150;
		background: Color white;
		aptitude: BrShadowAptitude new beLarge
			+ (BrGlamorousButtonExteriorAptitude new
				backgroundPaint: Color white;
				borderPaint: Color transparent)
			+ (GtPhlowBrowseDefinitionAptitude new definition: [ card definingMethod ]);
		padding: (BlInsets all: 15);
		margin: (BlInsets
			top: self spaceGap
			left: 2 * self spaceGap
			bottom: 2 * self spaceGap
			right: 2 * self spaceGap).
	^ container
]

{ #category : 'helpers' }
GtEnsembleHomeSection >> buildCardSubtitleLabel: aString [
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new foreground: Color gray; fontSize: 12);
		text: aString
]

{ #category : 'helpers' }
GtEnsembleHomeSection >> buildCardTitleLabel: aString [
	^ BrLabel new
		beLargeSize;
		padding: (BlInsets bottom: 5);
		aptitude: BrGlamorousLabelAptitude new bold;
		text: aString
]

{ #category : 'api' }
GtEnsembleHomeSection >> ensembleBoardCard [
	<gtSectionCard>
	<gtExample>
	<noTest>
	| card |
	card := GtHomeCard explicit.
	^ card
		title: 'Ensemble';
		description: 'Project organizer';
		priority: 1;
		stencil: [
			| board container statsLabel updater |
			board := GtEnsembleBoard current.
			statsLabel := BrLabel new
				aptitude: (BrGlamorousLabelAptitude new foreground: (Color fromHexString: '3498db'); fontSize: 12);
				padding: (BlInsets top: 8).
			container := self buildCardContainer: card.
			self addShowOnHoverResizersTo: container.
			container
				when: BlClickEvent do: [ :anEvent |
					anEvent consumed: true.
					container phlow spawnOrShowObject: board ].
			container addChild: (self buildCardTitleLabel: 'Ensemble') preventMeAndChildrenMouseEvents.
			container addChild: (self buildCardSubtitleLabel: 'Project & task organizer') preventMeAndChildrenMouseEvents.
			container addChild: statsLabel preventMeAndChildrenMouseEvents.
			
			updater := BrElementUpdater new
				element: container
				selector: #yourself;
				action: [ statsLabel text: board summaryString ].
			board announcer weak
				when: GtEnsembleBoardUpdated send: #requestUpdate to: updater.
			updater requestUpdate.
			
			container ]
]

{ #category : 'sections' }
GtEnsembleHomeSection >> ensembleKanbanCard [
	<gtSectionCard>
	<gtExample>
	<noTest>
	| card |
	card := GtHomeCard explicit.
	^ card
		title: 'Ensemble Projects';
		description: 'Project board';
		priority: 2;
		stencil: [
			| element |
			element := GtEnsembleKanbanCardElement new.
			element
				background: element theme default contentBackground;
				addAptitude: BrShadowAptitude new beLarge;
				addAptitude: (GtPhlowBrowseDefinitionAptitude new
					definition: [ GtEnsembleHomeSection >> #ensembleKanbanCard ]).
			self addShowOnHoverResizersTo: element.
			element
				hExact: 900;
				vExact: 400;
				padding: (BlInsets all: 5);
				margin: (BlInsets
					top: self spaceGap
					left: 2 * self spaceGap
					bottom: 2 * self spaceGap
					right: 2 * self spaceGap).
			element ]
]

{ #category : 'accessing' }
GtEnsembleHomeSection >> sectionTitle [
	^ 'Ensemble'
]
