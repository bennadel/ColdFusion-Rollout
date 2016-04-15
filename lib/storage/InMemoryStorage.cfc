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
	public string function get() {

		if ( ! len( storedValue ) ) {

			throw( 
				type = "NotFound",
				message = "No value has been stored."
			);

		}

		return( storedValue );

	}


	/**
	* I persist the given value to the store.
	* 
	* @value I am the value being stored.
	* @output false 
	*/
	public void function set( required string value ) {

		storedValue = value;

	}

}