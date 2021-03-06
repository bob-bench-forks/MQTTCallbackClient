tests
testAutoReconnect
	client 
		afterEachCycleBlock: [ :queue | self addToResultsAndSignal: #cycle ];
		reopen: [ :response :mqttClient :command | self addToResults: #reconnect ]
		error: [ :exception :mqttClient :command | 
			self addToResults: #reconnectionError. self addToResults: exception ]
		suspend: [ :duration :time :command | 
			self addToResults: #suspend.
			duration > 0 seconds ifTrue: [
				ShouldNotImplement signal: 'Should not happen' ] ].
	self assertSemaphore: 0.
	self deny: client isConnected.
	self deny: client isActive.
	client
		ping: [ self addToResults: #ping ] 
		error: [ :exception :mqttClient :command |  
			self addToResults: #pingError. self addToResults: exception className ].
	self assertSemaphore: 3.
	self assert: client size equals: 0.
	self 
		assert: results asArray 
		equals: #(pingError ConnectionClosed cycle suspend reconnect cycle cycle).
	self assert: client isConnected.
	self deny: client isActive.