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

		var value = {
			hello: "world"
		};

		storage.set( value );

		assert( objectEquals( value, storage.get() ) );
		
	}


	public void function test_that_delete_works() {

		var value = {
			hello: "world"
		};

		storage.set( value );
		storage.delete();

		try {

			storage.get();

			fail( "get() was supposed to throw an error." );

		} catch ( tinytest error ) {

			rethrow;
			
		} catch ( any error ) {

			// We are expecing this error - the key did not exist.

		}

	}

}