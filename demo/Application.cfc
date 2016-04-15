component
	output = false
	hint = "I define the application settings and event handlers."
	{

	// Define the application settings.
	this.name = hash( getCurrentTemplatePath() );
	this.applicationTimeout = createTimeSpan( 0, 0, 10, 0 );

	// Calculate our directory paths.
	this.demoDirectory = getDirectoryFromPath( getCurrentTemplatePath() );
	this.projectDirectory = ( this.demoDirectory & "../" );

	// Setup our component mappings.
	this.mappings[ "/lib" ] = ( this.projectDirectory & "lib/" );
	this.mappings[ "/jars" ] = ( this.projectDirectory & "jars/" );

	// Load the Jedis JAR files so we can use the Jedis storage for the demo.
	this.javaSettings = {
		loadPaths: [ 
			( this.mappings[ "/jars" ] & "commons-pool2-2.0.jar" ),
			( this.mappings[ "/jars" ] & "jedis-2.8.1.jar" ) 
		]
	};


	/**
	* I initialize the application.
	* 
	* @output false
	*/
	public boolean function onApplicationStart() {

		// For the demo, we're going to store the features in Redis so that we can see
		// the features persists across page refreshes.
		var jedisPoolConfig = createObject( "java", "redis.clients.jedis.JedisPoolConfig" ).init();
		var jedisPool = createObject( "java", "redis.clients.jedis.JedisPool" ).init( jedisPoolConfig, javaCast( "string", "localhost" ) );
		var storage = new lib.storage.JedisStorage( jedisPool, "demo:features" );

		// Setup our rollout service.
		application.rollout = new lib.Rollout( storage );


		// Setup our demo users. We're going to create a set that contains a set of 
		// men and a set of women so that we can demonstrate targeting based on gender
		// groups - just makes the demo a little more feature-rich.
		application.users = [];

		var id = 0;
		
		for ( var gender in [ "M", "F" ] ) {

			for ( var i = 1 ; i <= 30 ; i++ ) {

				arrayAppend(
					application.users,
					{
						id: ++id,
						name: "User #gender#-#id#",
						gender: gender
					}
				);

			}

		}

		return( true );

	}


	/**
	* I initialize the request.
	* 
	* @output false
	*/
	public boolean function onRequestStart() {

		// If the INIT url variable is present, re-initialize the app.
		if ( structKeyExists( url, "init" ) ) {

			applicationStop();
			return( false );

		}

		return( true );

	}

}