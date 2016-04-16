component
	output = false
	hint = "I implement a Jedis storage gateway for Redis."
	{

	/**
	* I initialize the Jedis storage gateway with the given connection pool.
	* 
	* @output false
	*/
	public any function init( 
		required any jedisPool,
		required string key
		) {

		// Store the injected properties.
		variables.jedisPool = arguments.jedisPool;
		variables.key = arguments.key;

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	/**
	* I delete the stored value.
	* 
	* @output false 
	*/
	public void function delete() {

		getResource(
			function( redis ) {

				redis.del( javaCast( "string", key ) );
				
			}
		);

	}


	/**
	* I get the stored value. If no value is stored, a NotFound error is thrown.
	* 
	* @output false 
	*/
	public struct function get() {

		var value = getResource(
			function( redis ) {

				return( redis.get( javaCast( "string", key ) ) );
				
			}
		);

		if ( isNull( value ) || ! len( value ) ) {

			throw( 
				type = "NotFound",
				message = "No value has been stored.",
				detail = "The Redis key [#key#] does not exist or is empty."
			);

		}

		return( deserializeJson( value ) );

	}


	/**
	* I persist the given value to the store.
	* 
	* @value I am the value being stored.
	* @output false 
	*/
	public void function set( required struct value ) {

		getResource(
			function( redis ) {

				redis.set( javaCast( "string", key ), javaCast( "string", serializeJson( value ) ) );
				
			}
		);

	}


	// ---
	// PRIVATE METHODS.
	// ---


	/**
	* I retrieve a resource from the Jedis connection pool and then pass it to the given
	* callback. The result of the callback invocation is passed back.
	* 
	* @callback I am the closure to be invoked with the redis resource.
	* @output false
	*/
	private any function getResource( required function callback ) {

		var redis = jedisPool.getResource();

		try {

			return( callback( redis ) );

		} catch ( any error ) {

			if ( structKeyExists( local, "redis" ) && isConnectionError( error ) ) {

				jedisPool.returnBrokenResource( redis );

				// Delete the reference so it won't get used in the Finally block.
				structDelete( local, "redis" );

			}

			rethrow; 

		} finally {

			if ( structKeyExists( local, "redis" ) ) {

				jedisPool.returnResource( redis );

			}

		}

	}


	/**
	* I determine if the given error is a Jedis connection error (for a broken resource).
	* 
	* @error I am the error being checked.
	* @output false
	*/
	private boolean function isConnectionError( required any error ) {

		return( error.type == "redis.clients.jedis.exceptions.JedisConnectionException" );

	}

}