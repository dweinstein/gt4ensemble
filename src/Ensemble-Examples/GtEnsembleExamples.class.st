Class {
	#name : 'GtEnsembleExamples',
	#superclass : 'Object',
	#category : 'Ensemble-Examples',
	#package : 'Ensemble-Examples'
}

{ #category : 'examples' }
GtEnsembleExamples >> exampleBoard [
	<gtExample>
	| board |
	board := GtEnsembleBoard newEmpty.
	board addProject: self exampleProject.
	board addProject: self exampleProjectCloudflare.
	board addProject: self exampleProjectMicrosoft.
	self assert: board projects size equals: 3.
	self assert: board allTasks size equals: 8.
	self assert: board inProgressTaskCount equals: 2.
	^ board
]

{ #category : 'examples' }
GtEnsembleExamples >> exampleBoardElement [
	<gtExample>
	| board element |
	board := self exampleBoard.
	element := GtEnsembleTaskBoardElement forAllTasks: board allTasks items.
	self assert: element notNil.
	^ element
]

{ #category : 'examples' }
GtEnsembleExamples >> exampleCardElement [
	<gtExample>
	| task card |
	task := self exampleTask.
	card := GtEnsembleCardElement for: task.
	self assert: card notNil.
	^ card
]

{ #category : 'examples' }
GtEnsembleExamples >> exampleCompactCardElement [
	<gtExample>
	| task card |
	task := self exampleTask.
	card := GtEnsembleCardElement compactFor: task.
	self assert: card notNil.
	^ card
]

{ #category : 'examples' }
GtEnsembleExamples >> exampleProject [
	<gtExample>
	| proj |
	proj := GtEnsembleProject
		name: 'Frida Integration'
		directory: '/Users/user/personal/gt/gt4frida'
		description: 'Dynamic instrumentation via JSLink'.
	proj status: 'In Progress'.
	proj addTaskNamed: 'Build CFG viewer'.
	proj tasks first status: 'In Progress'.
	proj tasks first addTag: GtEnsembleTag implementation.
	proj addTaskNamed: 'Add memory dump support'.
	proj tasks second addTag: GtEnsembleTag research.
	proj addTaskNamed: 'JSLink bridge setup'.
	proj tasks third status: 'Done'.
	proj tasks third addTag: GtEnsembleTag implementation.
	self assert: proj tasks size equals: 3.
	self assert: proj tasksDoing size equals: 1.
	self assert: proj tasksDone size equals: 1.
	^ proj
]

{ #category : 'examples' }
GtEnsembleExamples >> exampleProjectCloudflare [
	<gtExample>
	| proj |
	proj := GtEnsembleProject
		name: 'GT Cloudflare'
		directory: '/Users/user/personal/gt/gt4cloudflare'
		description: 'Cloudflare API client for GT'.
	proj status: 'Todo'.
	proj addTaskNamed: 'Browser rendering integration'.
	proj tasks first status: 'Todo'.
	proj tasks first addTag: GtEnsembleTag spike.
	proj addTaskNamed: 'Workers API client'.
	proj tasks second addTag: GtEnsembleTag implementation.
	self assert: proj tasks size equals: 2.
	^ proj
]

{ #category : 'examples' }
GtEnsembleExamples >> exampleProjectMicrosoft [
	<gtExample>
	| proj |
	proj := GtEnsembleProject
		name: 'GT Microsoft'
		directory: '/Users/user/personal/gt/gt4microsoft'
		description: 'Microsoft Graph API client'.
	proj status: 'Backlog'.
	proj addTaskNamed: 'OAuth token refresh'.
	proj tasks first addTag: GtEnsembleTag bug.
	proj tasks first status: 'In Progress'.
	proj addTaskNamed: 'Calendar sync'.
	proj tasks second addTag: GtEnsembleTag research.
	proj addTaskNamed: 'OneNote integration'.
	proj tasks third addTag: GtEnsembleTag research.
	proj tasks third status: 'Done'.
	^ proj
]

{ #category : 'examples' }
GtEnsembleExamples >> exampleProjectsBoardElement [
	<gtExample>
	| board element |
	board := self exampleBoard.
	element := GtEnsembleProjectBoardElement forProjects: board projects.
	self assert: element notNil.
	^ element
]

{ #category : 'examples' }
GtEnsembleExamples >> exampleSession [
	<gtExample>
	| session |
	session := GtEnsembleSession new.
	session path: FileLocator home / '.claude' / 'projects' / '-Users-user-personal-gt'.
	session lastModified: DateAndTime now.
	session tool: #claudeCode.
	self assert: session isClaudeCode.
	self assert: session toolName equals: 'Claude Code'.
	^ session
]

{ #category : 'examples' }
GtEnsembleExamples >> exampleTag [
	<gtExample>
	| tag |
	tag := GtEnsembleTag name: 'research' color: (Color fromHexString: '3498db').
	self assert: tag name equals: 'research'.
	self assert: tag color notNil.
	^ tag
]

{ #category : 'examples' }
GtEnsembleExamples >> exampleTagSyncFromSnippet [
	<gtExample>
	| task snippet |
	snippet := GtEnsembleTaskSnippet new.
	snippet title: 'Sync test'.
	snippet status: 'Todo'.
	snippet tagNames: #('research').
	task := GtEnsembleTask new.
	task snippet: snippet.
	snippet task: task.
	"Change tags via snippet"
	snippet tagNames: #('bug' 'spike').
	self assert: (task tags collect: #name) asArray equals: #('bug' 'spike').
	"Change notes via task - tags should not revert"
	task notes: 'updated'.
	self assert: snippet tagNames asArray equals: #('bug' 'spike').
	^ task
]

{ #category : 'examples' }
GtEnsembleExamples >> exampleTask [
	<gtExample>
	| task |
	task := GtEnsembleTask title: 'Build CFG viewer'.
	self assert: task title equals: 'Build CFG viewer'.
	self assert: task status equals: 'Backlog'.
	self assert: task tags isEmpty.
	task status: 'In Progress'.
	task addTag: GtEnsembleTag implementation.
	self assert: task status equals: 'In Progress'.
	self assert: task tags size equals: 1.
	^ task
]

{ #category : 'examples' }
GtEnsembleExamples >> exampleTaskSnippet [
	<gtExample>
	| snippet |
	snippet := GtEnsembleTaskSnippet new.
	snippet title: 'Test task'.
	snippet status: 'In Progress'.
	snippet tagNames: #('research' 'implementation').
	snippet priority: 1.
	snippet taskNotes: 'Some notes about this task'.
	self assert: snippet title equals: 'Test task'.
	self assert: snippet status equals: 'In Progress'.
	self assert: snippet tagNames size equals: 2.
	self assert: snippet contentAsString equals: 'Test task'.
	^ snippet
]

{ #category : 'examples' }
GtEnsembleExamples >> exampleTaskSnippetStoreOnRoundTrip [
	<gtExample>
	| snippet restored |
	snippet := GtEnsembleTaskSnippet new.
	snippet title: 'Round-trip test'.
	snippet status: 'In Progress'.
	snippet priority: 5.
	snippet taskNotes: 'Important notes'.
	snippet tagNames: #('research' 'bug').
	restored := Smalltalk compiler evaluate: snippet storeString.
	self assert: restored title equals: 'Round-trip test'.
	self assert: restored status equals: 'In Progress'.
	self assert: restored priority equals: 5.
	self assert: restored taskNotes equals: 'Important notes'.
	self assert: restored tagNames equals: #('research' 'bug').
	^ restored
]
