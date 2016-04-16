component
	extends = "TestCase"
	output = false
	hint = "I test the InMemoryStroage component."
	{

	public void function setup() {

		storage = new lib.storage.InMemoryStorage();

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