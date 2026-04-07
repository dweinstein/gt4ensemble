Class {
	#name : 'BaselineOfGt4Ensemble',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfGt4Ensemble',
	#package : 'BaselineOfGt4Ensemble'
}

{ #category : 'loading' }
BaselineOfGt4Ensemble class >> loadLepiter [
	IceRepository registry  
		detect: [ :aRepository |
			aRepository name = 'gt4ensemble' ]
		ifFound: [ :aRepository | 
			| defaultDatabase currentProperties |
			defaultDatabase := LeDatabasesRegistry defaultLogicalDatabase.
			currentProperties := defaultDatabase properties.
			currentProperties addRegisteredDirectory: aRepository repositoryDirectory / 'lepiter'.
			defaultDatabase reload ]
		ifNone: [
			self inform: 'Repository not found.' ]
]

{ #category : 'baselines' }
BaselineOfGt4Ensemble >> baseline: spec [
	<baseline>
	^ spec for: #common do: [
		spec package: 'Gt4Ensemble'.
		spec package: 'Ensemble-Examples'.
		spec package: 'Ensemble-Lepiter'.
		spec package: 'Ensemble-Model'.
		spec package: 'Ensemble-UI'.
		spec postLoadDoIt: #postLoad.
	]
]

{ #category : 'loading' }
BaselineOfGt4Ensemble >> postLoad [
	"Reset the Lepiter JSON mapper so ensemble snippet types are recognized,
	then rehydrate any LeUnknownSnippet instances that were loaded before
	the Ensemble package was available."
	GtEnsembleBoard reloadSnippetMappings
]
