component
	output = false
	hint = "I represent a feature being rolled-out in an application."
	{

	/**
	* I initialize the reature for the given users and groups.
	* 
	* @output false
	*/
	public any function init(
		required string featureName,
		required numeric percentage,
		required array users,
		required array groups
		) {

		testFeatureName( arguments.featureName );
		testPercentage( arguments.percentage );
		arrayEach( users, testUserIdentifier );
		
		variables.featureName = arguments.featureName;
		variables.percentage = arguments.percentage;
		variables.users = arguments.users;
		variables.groups = arguments.groups;

		variables.userIndex = reflect( arguments.users );
		variables.groupIndex = reflect( arguments.groups );

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	


	/**
	* I test whether or not the given percentage is a valid value. If it is valid, I 
	* return quietly; however, if it is invalid, I throw an error.
	* 
	* @percentage I am the value being tested.
	* @output false
	*/
	public void function testPercentage( required numeric percentage ) {

		if ( 
			( percentage < 0 ) || 
			( percentage > 100 ) ||
			( percentage != ceiling( percentage ) )
			) {

			throw(
				type = "InvalidArgument",
				message = "Percentage is invalid.",
				detail = "The given percentage [#percentage#] must be an integer between 0 and 100."
			);

		}

	}


	/**
	* I test whether or not the given featureName is a valid value. If it is valid, I
	* return quietly; however, if it is invalid, I throw an error.
	* 
	* @featureName I am the value being tested.
	* @output false
	*/
	public void function testFeatureName( required string featureName ) {

		if ( ! len( featureName ) ) {

			throw(
				type = "InvalidArgument",
				message = "FeatureName is invalid.",
				detail = "The given featureName [#FeatureName#] must be a non-empty string."
			);

		}

	}


	/**
	* I test whether or not the given userIdentifier is a valid value. If it is valid, I
	* return quietly; however, if it is invalid, I throw an error.
	* 
	* @userIdentifier I am the value being tested.
	* @output false
	*/
	public void function testUserIdentifier( required string userIdentifier ) {

		if ( ! len( userIdentifier ) ) {

			throw(
				type = "InvalidArgument",
				message = "UserIdentifier is invalid.",
				detail = "The given userIdentifier [#userIdentifier#] must be a non-empty string."
			);

		}

	}


	// ---
	// PRIVATE METHODS.
	// ---


	/**
	* I take the given array of values and create a struct in which the values are 
	* reflected as keys that point to the values.
	* 
	* @values I am the array of simple values being reflected.
	* @output false
	*/
	private struct function reflect( required array values ) {

		var reflectedValues = {};

		for ( var value in values ) {

			reflectedValues[ value ] = value;

		}

		return( reflectedValues );

	}

}