component
	output = false
	hint = "I implement an in-memory storage gateway."
	{

	/**
	* I initialize the in-memory storage gateway.
	* 
	* @output false
	*/
	public any function init() {

		// Internally, we are storing the value as a string. We don't technically need
		// to do this; but, since other persistence mechanisms will be using a string
		// internally - this will help keep the various approaches (and any quirks 
		// related to serialization) consistent across all persistence mechanisms.
		storedValue = "";

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

		storedValue = "";

	}


	/**
	* I get the stored value. If no value is stored, a NotFound error is thrown.
	* 
	* @output false 
	*/
	public struct function get() {

		if ( ! len( storedValue ) ) {

			throw( 
				type = "NotFound",
				message = "No value has been stored."
			);

		}

		return( deserializeJson( storedValue ) );

	}


	/**
	* I persist the given value to the store.
	* 
	* @value I am the value being stored.
	* @output false 
	*/
	public void function set( required struct value ) {

		storedValue = serializeJson( value );

	}

}