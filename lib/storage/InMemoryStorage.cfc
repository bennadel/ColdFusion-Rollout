component
	output = false
	hint = "I implement an in-memory storage gateway."
	{

	/**
	* I initialize the in-memory storage gateway. As with all of the storage gateways
	* in this library, the keys are case-sensitive.
	* 
	* @output false
	*/
	public any function init() {

		// Not all storage gateways will be case-insensitive for key values. As such, 
		// we have to use a case-sensitive mechanism as the lowest common denominator.
		cache = createObject( "java", "java.util.HashMap" ).init();

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	/**
	* I delete the value stored at the given key.
	* 
	* @key I am the key being deleted from the storage.
	* @output false 
	*/
	public void function delete( required string key ) {

		cache.remove( javaCast( "string", key ) );

	}


	/**
	* I get the value stored at the given key. If the given key does not exist, 
	* a NotFound error is thrown.
	* 
	* @key I am the key being retrieved from the storage.
	* @output false 
	*/
	public string function get( required string key ) {

		var value = cache.get( javaCast( "string", key ) );

		if ( isNull( value ) ) {

			throw( 
				type = "NotFound",
				message = "The given key did not exist in the storage mechanism.",
				detail = "The key [#key#] did not exist in the cache."
			);

		}

		return( value );

	}


	/**
	* I store the given value at the given key. 
	* 
	* @key I am the key being set.
	* @value I am the value being stored.
	* @output false 
	*/
	public void function set(
		required string key,
		required string value
		) {

		cache.put( javaCast( "string", key ), javaCast( "string", value ) );

	}

}