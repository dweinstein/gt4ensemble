Class {
	#name : 'GtEnsembleHtmlRenderer',
	#superclass : 'Object',
	#instVars : [
		'context'
	],
	#category : 'Ensemble-Lepiter',
	#package : 'Ensemble-Lepiter'
}

{ #category : 'accessing' }
GtEnsembleHtmlRenderer >> context [
	^ context
]

{ #category : 'accessing' }
GtEnsembleHtmlRenderer >> context: anLeHtmlContext [
	context := anLeHtmlContext
]

{ #category : 'private' }
GtEnsembleHtmlRenderer >> html [
	^ context html
]

{ #category : 'rendering - board' }
GtEnsembleHtmlRenderer >> renderBoardColumnHeader: statusName count: count [
	self html
		tag: #div
		attributes: #('style' 'padding:6px 8px; font-size:0.8em; font-weight:600; color:#555; display:flex; justify-content:space-between')
		do: [
			self html tag: #span attributes: #() with: statusName.
			self html
				tag: #span
				attributes: #('style' 'color:#999')
				with: count printString ]
]

{ #category : 'rendering - board' }
GtEnsembleHtmlRenderer >> renderBoardGrid: proj [
	"Render a full Kanban-style grid. Not used by default — available for future use."
	| byStatus |
	byStatus := proj tasksByStatus.
	self html
		tag: #div
		attributes: #('style' 'display:grid; grid-template-columns:repeat(5, 1fr); gap:8px; margin:4px 0')
		do: [
			GtEnsembleTask statuses do: [ :s |
				| tasks color |
				tasks := byStatus at: s ifAbsent: [ #() ].
				color := self statusColorFor: s.
				self html
					tag: #div
					attributes: {'style'. 'background:#fafafa; border:1px solid #e8e8e8; border-radius:4px; min-height:80px; border-top:3px solid #' , color}
					do: [
						self renderBoardColumnHeader: s count: tasks size.
						tasks do: [ :t | self renderBoardTaskCard: t ] ] ] ]
]

{ #category : 'rendering' }
GtEnsembleHtmlRenderer >> renderBoardSnippet: aSnippet [
	| proj |
	proj := [ aSnippet project ] on: Error do: [ :e | nil ].
	self html
		tag: #div
		attributes: #('style' 'padding:8px 12px; margin:4px 0; background:#f5f5f5; border:1px solid #e0e0e0; border-radius:4px')
		do: [
			self html
				tag: #div
				attributes: #('style' 'font-weight:600; margin-bottom:6px')
				with: 'Board: ' , (aSnippet projectName ifNil: [ '(auto)' ]).
			proj ifNotNil: [
				self renderBoardSummary: proj ] ]
]

{ #category : 'rendering - board' }
GtEnsembleHtmlRenderer >> renderBoardSummary: proj [
	| byStatus |
	byStatus := proj tasksByStatus.
	self html
		tag: #div
		attributes: #('style' 'display:flex; gap:12px; flex-wrap:wrap')
		do: [
			GtEnsembleTask statuses do: [ :s |
				| count |
				count := (byStatus at: s ifAbsent: [ #() ]) size.
				self html
					tag: #span
					attributes: #('style' 'font-size:0.85em; color:#666')
					with: s , ': ' , count printString ] ]
]

{ #category : 'rendering - board' }
GtEnsembleHtmlRenderer >> renderBoardTaskCard: aTask [
	self html
		tag: #div
		attributes: #('style' 'margin:4px 6px; padding:6px 8px; background:white; border:1px solid #e0e0e0; border-radius:3px; font-size:0.85em')
		do: [
			self html
				tag: #div
				attributes: #('style' 'font-weight:500')
				with: aTask title.
			aTask tags isNotEmpty ifTrue: [
				self html
					tag: #div
					attributes: #('style' 'margin-top:3px; display:flex; gap:3px; flex-wrap:wrap')
					do: [
						aTask tags do: [ :tag |
							self renderTagPill: tag name ] ] ] ]
]

{ #category : 'rendering' }
GtEnsembleHtmlRenderer >> renderProjectSnippet: aSnippet [
	| statusColor statusLabel desc |
	statusLabel := aSnippet projectStatus ifNil: [ 'Backlog' ].
	statusColor := aSnippet statusColor asHexString.
	desc := aSnippet projectDescription.
	self html
		tag: #div
		attributes: {'style'.
				'border-left:4px solid #' , statusColor , '; padding:8px 12px; margin:4px 0; background:#fafafa; border-radius:4px'}
		do: [
			self html
				tag: #div
				attributes: #('style' 'display:flex; align-items:center; gap:8px; margin-bottom:4px')
				do: [
					self renderStatusDot: statusColor size: 10.
					self html
						tag: #span
						attributes: #('style' 'font-weight:600; font-size:1.05em')
						with: (aSnippet projectName ifNil: [ 'Untitled Project' ]).
					self html
						tag: #span
						attributes: #('style' 'color:#888; font-size:0.85em')
						with: statusLabel ].
			(desc isNotNil and: [ desc isNotEmpty ])
				ifTrue: [
					self html
						tag: #p
						attributes: #('style' 'margin:4px 0 2px 0; color:#444')
						with: desc ]
				ifFalse: [
					self html
						tag: #p
						attributes: #('style' 'margin:4px 0 2px 0; color:#aaa; font-style:italic')
						with: 'No description' ].
			(aSnippet projectDirectory isNotNil and: [ aSnippet projectDirectory isNotEmpty ])
				ifTrue: [
					self html
						tag: #code
						attributes: #('style' 'font-size:0.8em; color:#999')
						with: aSnippet projectDirectory ] ]
]

{ #category : 'private' }
GtEnsembleHtmlRenderer >> renderStatusDot: colorHex size: pixels [
	self html
		tag: #span
		attributes: {'style'.
				'display:inline-block; width:' , pixels printString , 'px; height:' , pixels printString , 'px; border-radius:50%; background:#' , colorHex}
		with: ''
]

{ #category : 'private' }
GtEnsembleHtmlRenderer >> renderTagPill: aString [
	self html
		tag: #span
		attributes: #('style' 'display:inline-block; background:#e8e8e8; color:#555; font-size:0.75em; padding:1px 6px; border-radius:8px')
		with: aString
]

{ #category : 'rendering' }
GtEnsembleHtmlRenderer >> renderTaskSnippet: aSnippet [
	| statusColor statusLabel |
	statusLabel := aSnippet status ifNil: [ 'Backlog' ].
	statusColor := aSnippet statusColor asHexString.
	self html
		tag: #div
		attributes: {'style'.
				'border-left:3px solid #' , statusColor , '; padding:6px 10px; margin:4px 0; background:#fafafa; border-radius:3px'}
		do: [
			self html
				tag: #div
				attributes: #('style' 'display:flex; align-items:center; gap:8px; flex-wrap:wrap')
				do: [
					self renderStatusDot: statusColor size: 8.
					self html
						tag: #span
						attributes: #('style' 'font-weight:600')
						with: (aSnippet title ifNil: [ 'Untitled Task' ]).
					self html
						tag: #span
						attributes: #('style' 'color:#888; font-size:0.85em')
						with: statusLabel.
					(aSnippet tagNames isNotNil and: [ aSnippet tagNames isNotEmpty ])
						ifTrue: [
							aSnippet tagNames do: [ :t |
								self renderTagPill: t ] ] ].
			(aSnippet taskNotes isNotNil and: [ aSnippet taskNotes isNotEmpty ])
				ifTrue: [
					self html
						tag: #p
						attributes: #('style' 'margin:4px 0 0 0; color:#555; font-size:0.9em')
						with: aSnippet taskNotes ] ]
]

{ #category : 'private' }
GtEnsembleHtmlRenderer >> statusColorFor: aStatusString [
	aStatusString = 'Backlog' ifTrue: [ ^ '95a5a6' ].
	aStatusString = 'Todo' ifTrue: [ ^ '3498db' ].
	aStatusString = 'In Progress' ifTrue: [ ^ 'f39c12' ].
	aStatusString = 'Done' ifTrue: [ ^ '27ae60' ].
	aStatusString = 'Cancelled' ifTrue: [ ^ 'bdc3c7' ].
	^ '999999'
]
