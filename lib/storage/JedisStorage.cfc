component
	output = false
	hint = "I implement a Jedis storage gateway for Redis."
	{

	/**
	* I initialize the Jedis storage gateway with the given connection pool. As with all
	* of the storage gateways in this library, the keys are case-sensitive.
	* 
	* @output false
	*/
	public any function init( 
		required any jedisPool,
		required string keyPrefix
		) {

		variables.jedisPool = arguments.jedisPool;
		variables.keyPrefix = arguments.keyPrefix;

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

		getResource(
			function( redis ) {

				return( redis.del( javaCast( "string", normalize( key ) ) ) );
				
			}
		);

	}


	/**
	* I get the value stored at the given key. If the given key does not exist, 
	* a NotFound error is thrown.
	* 
	* @key I am the key being retrieved from the storage.
	* @output false 
	*/
	public string function get( required string key ) {

		var value = getResource(
			function( redis ) {

				return( redis.get( javaCast( "string", normalize( key ) ) ) );
				
			}
		);

		if ( isNull( value ) ) {

			throw( 
				type = "NotFound",
				message = "The given key did not exist in the storage mechanism.",
				detail = "The key [#key#] did not exist in the cache.",
				extendedInfo = "Normalized key: [#normalize( key )#]"
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

		getResource(
			function( redis ) {

				redis.set( javaCast( "string", normalize( key ) ), javaCast( "string", value ) );
				
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


	/**
	* I normalize the key for use in the Redis store.
	* 
	* @key I am the key being normalized.
	* @output false
	*/
	private string function normalize( required string key ) {

		return( keyPrefix & key );

	}

}