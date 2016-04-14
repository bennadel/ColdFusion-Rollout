component
	extends = "TestCase"
	output = false
	hint = "I test the InMemoryStroage component."
	{

	public void function setup() {

		jedisPoolConfig = createObject( "java", "redis.clients.jedis.JedisPoolConfig" ).init();
		jedisPool = createObject( "java", "redis.clients.jedis.JedisPool" ).init( jedisPoolConfig, javaCast( "string", "localhost" ) );

		storage = new lib.storage.JedisStorage( jedisPool, "features:" );

	}


	public void function afterTests() {

		jedisPool.destroy();

	}


	// ---
	// PUBLIC METHODS.
	// ---


	public void function test_that_set_get_works() {

		storage.set( "hello", "world" );

		assert( storage.get( "hello" ) == "world" );
		
	}


	public void function test_that_keys_are_case_sensitive() {

		storage.set( "hello", "world" );

		try {

			storage.get( "HELLO" );

			fail( "get() was supposed to throw an error." );

		} catch ( tinytest error ) {

			rethrow;
			
		} catch ( any error ) {

			// We are expecing this error - the key did not exist.

		}

	}


	public void function test_that_delete_works() {

		storage.set( "hello", "world" );
		storage.delete( "hello" );

		try {

			storage.get( "hello" );

			fail( "get() was supposed to throw an error." );

		} catch ( tinytest error ) {

			rethrow;
			
		} catch ( any error ) {

			// We are expecing this error - the key did not exist.

		}

	}

}