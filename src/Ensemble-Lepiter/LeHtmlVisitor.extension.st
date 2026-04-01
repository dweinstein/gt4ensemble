Extension { #name : 'LeHtmlVisitor' }

{ #category : '*Ensemble-Lepiter' }
LeHtmlVisitor >> visitEnsembleBoardSnippet: aSnippet [
	| renderer |
	renderer := GtEnsembleHtmlRenderer new context: context.
	context html
		tag: #div
		attributes: (self classesFor: aSnippet withClasses: 'snippet ensemble-board-snippet')
		do: [ renderer renderBoardSnippet: aSnippet ].
	^ self visitContent: aSnippet
]

{ #category : '*Ensemble-Lepiter' }
LeHtmlVisitor >> visitEnsembleProjectSnippet: aSnippet [
	| renderer |
	renderer := GtEnsembleHtmlRenderer new context: context.
	context html
		tag: #div
		attributes: (self classesFor: aSnippet withClasses: 'snippet ensemble-project-snippet')
		do: [ renderer renderProjectSnippet: aSnippet ].
	^ self visitContent: aSnippet
]

{ #category : '*Ensemble-Lepiter' }
LeHtmlVisitor >> visitEnsembleTaskSnippet: aSnippet [
	| renderer |
	renderer := GtEnsembleHtmlRenderer new context: context.
	context html
		tag: #div
		attributes: (self classesFor: aSnippet withClasses: 'snippet ensemble-task-snippet')
		do: [ renderer renderTaskSnippet: aSnippet ].
	^ self visitContent: aSnippet
]
