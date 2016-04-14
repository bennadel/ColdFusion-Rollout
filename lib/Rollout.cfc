component
	output = false
	hint = "I implement the Rollout gem for ColdFusion, providing a feature flag library."
	{

	/**
	* I initialize the Rollout library with the given storage gateway.
	* 
	* @storage I am the feature persistence mechanism.
	* @output false
	*/
	public any function init( required any storage ) {

		// I am the JSON persistence mechanism. I implement a simple key-value store
		// interface for string data.
		variables.storage = storage;

		// I am the key at which the feature set JSON data will be stored.
		variables.featureSetStorageKey = "rollout-features";

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	/**
	* I activate the given feature for all users.
	* 
	* @featureName I am the feature being activated.
	* @output false
	*/
	public void function activate( required string featureName ) {

		activatePercentage( featureName, 100 );

	}


	/**
	* I activate the given feature for the given group (which can be associated with a 
	* user when feature activation is being checked for a specific user).
	* 
	* @featureName I am the feature being activated.
	* @groupName I am the group for which the feature is being activated.
	* @output false
	*/
	public void function activateGroup(
		required string featureName,
		required string groupName
		) {

		testFeatureName( featureName );
		testGroupName( groupName );

		var featureSet = getFeatureSetData( featureName );
		var feature = featureSet[ featureName ];

		if ( ! arrayContains( feature.groups, groupName ) ) {

			arrayAppend( feature.groups, groupName );

		}

		saveFeatureSetData( featureSet );

	}


	/**
	* I activate the given feature for the given percentage of users.
	* 
	* @featureName I am the feature being activated.
	* @percentage I am the percentage of users for which the feature is being activated.
	* @output false
	*/
	public void function activatePercentage(
		required string featureName,
		required numeric percentage
		) {

		testFeatureName( featureName );
		testPercentage( percentage );

		var featureSet = getFeatureSetData( featureName );
		var feature = featureSet[ featureName ];

		feature.percentage = percentage;

		saveFeatureSetData( featureSet );

	}


	/**
	* I activate the given feature for the given user.
	* 
	* @featureName I am the feature being activated.
	* @userIdentifier I am the user for which the feature is being activated.
	* @output false
	*/
	public void function activateUser(
		required string featureName,
		required string userIdentifier
		) {

		testFeatureName( featureName );
		testUserIdentifier( userIdentifier );

		var featureSet = getFeatureSetData( featureName );
		var feature = featureSet[ featureName ];

		if ( ! arrayContains( feature.users, userIdentifier ) ) {

			arrayAppend( feature.users, userIdentifier );
			
		}
			
		saveFeatureSetData( featureSet );

	}


	/**
	* I activate the given feature for the given set of users.
	* 
	* NOTE: This is just a convenience method for calling the activateUser() multiple
	* times (once for each identifier in the set).
	* 
	* @featureName I am the feature being activated.
	* @userIdentifiers I am the set of users for which the feature is being activated.
	* @output false
	*/
	public void function activateUsers(
		required string featureName,
		required array userIdentifiers
		) {

		for ( var userIdentifier in userIdentifiers ) {

			activateUser( featureName, userIdentifier );

		}

	}


	/**
	* I delete all of the stored feature data.
	* 
	* @output false
	*/
	public void function clear() {

		deleteFeatureSetData();

	}


	/**
	* I deactivate the given feature for all users and groups.
	* 
	* @featureName I am the feature being deactivated.
	* @output false
	*/
	public void function deactivate( required string featureName ) {

		testFeatureName( featureName );

		var featureSet = getFeatureSetData( featureName );
		var feature = featureSet[ featureName ];

		feature.percentage = 0;
		feature.users = [];
		feature.groups = [];

		saveFeatureSetData( featureSet );

	}


	/**
	* I deactivate the given feature for the given group.
	* 
	* @featureName I am the feature being deactivated.
	* @groupName I am the group for which the feature is being deactivated.
	* @output false
	*/
	public void function deactivateGroup(
		required string featureName,
		required string groupName
		) {

		testFeatureName( featureName );
		testGroupName( groupName );

		var featureSet = getFeatureSetData( featureName );
		var feature = featureSet[ featureName ];

		if ( arrayContains( feature.groups, groupName ) ) {

			arrayDelete( feature.groups, groupName );

		}
		
		saveFeatureSetData( featureSet );

	}


	/**
	* I deactivate the percentage-based rollout of the given feature.
	* 
	* NOTE: This will leave the explicit user and group targeting in tact.
	* 
	* @featureName I am the feature being deactivated.
	* @output false
	*/
	public void function deactivatePercentage( required string featureName ) {

		activatePercentage( featureName, 0 );

	}


	/**
	* I deactivate the given feature for the given user.
	* 
	* @featureName I am the feature being deactivated.
	* @userIdentifier I am the user for which the feature is being deactivated.
	* @output false
	*/
	public void function deactivateUser(
		required string featureName,
		required string userIdentifier
		) {

		testFeatureName( featureName );
		testUserIdentifier( userIdentifier );

		var featureSet = getFeatureSetData( featureName );
		var feature = featureSet[ featureName ];

		if ( arrayContains( feature.users, userIdentifier ) ) {

			arrayDelete( feature.users, userIdentifier );

		}
			
		saveFeatureSetData( featureSet );

	}


	/**
	* I delete the given feature.
	* 
	* @featureName I am the feature being deleted.
	* @output false
	*/
	public void function delete( required string featureName ) {

		var featureSet = getFeatureSetData();

		structDelete( featureSet, featureName );

		saveFeatureSetData( featureSet );

	}


	/**
	* I return the collection of known feature names.
	* 
	* @output false
	*/
	public array function features() {

		var featureSet = getFeatureSetData();
		var featureNames = [];

		// NOTE: We are using the embedded names (within each feature), rather than the
		// collection of keys on the feature-set object in order to ensure the most 
		// accurate "key casing".
		for ( var featureName in featureSet ) {

			arrayAppend( featureNames, featureSet[ featureName ].name );

		}

		return( featureNames );

	}


	/**
	* I return a struct of features in which each key represents the feature name and 
	* each value determine whether that feature is active based on percentage rollout.
	* 
	* NOTE: A feature is considered active when its percentage is set to 100.
	* 
	* @output false
	*/
	public struct function featureStates() {

		var featureSet = getFeatureSetData();
		var states = {};

		for ( var featureName in featureSet ) {

			var feature = featureSet[ featureName ];

			// NOTE: We are using the embedded names (within each feature), rather than
			// the collection of keys on the feature-set object in order to ensure the 
			// most accurate "key casing".
			states[ feature.name ] = ( feature.percentage == 100 );

		}

		return( states );

	}


	/**
	* I return a struct of features in which each key represents the feature name and 
	* each value determine whether that feature is active for the given group.
	* 
	* @groupName I am the group for which the feature states are being checked.
	* @output false
	*/
	public struct function featureStatesForGroup( required string groupName ) {

		var featureSet = getFeatureSetData();
		var states = {};

		for ( var featureName in featureSet ) {

			var feature = featureSet[ featureName ];

			// Check to see if the feature is being rolled out all users.
			if ( feature.percentage == 100 ) {

				states[ feature.name ] = true;
				continue; // To next feature.

			}

			// NOTE: We are using the embedded names (within each feature), rather than
			// the collection of keys on the feature-set object in order to ensure the 
			// most accurate "key casing".
			states[ feature.name ] = arrayContains( feature.groups, groupName );

		}

		return( states );

	}


	/**
	* I return a struct of features in which each key represents the feature name and 
	* each value determine whether that feature is active for the given user.
	* 
	* @userIdentifier I am the user for which the feature states are being checked.
	* @groups I am the optional groups (array | struct) associated with the given user.
	* @output false
	*/
	public struct function featureStatesForUser( 
		required string userIdentifier,
		any groups = []
		) {

		var featureSet = getFeatureSetData();
		var states = {};

		for ( var featureName in featureSet ) {

			var feature = featureSet[ featureName ];

			// Default the state of the feature to false.
			// --
			// NOTE: We are using the embedded names (within each feature), rather than
			// the collection of keys on the feature-set object in order to ensure the 
			// most accurate "key casing".
			states[ feature.name ] = false;

			// Check to see if the feature is being rolled out to a percentage of the user-
			// base in which this user is included.
			if ( 
				feature.percentage && 
				( getBucketForUserIdentifier( userIdentifier ) <= feature.percentage ) 
				) {

				states[ feature.name ] = true;
				continue; // To next feature.

			}

			// Check to see if the feature is explicitly enabled for this user.
			if ( arrayContains( feature.users, userIdentifier ) ) {

				states[ feature.name ] = true;
				continue; // To next feature.

			}

			// Check to see if the feature is active for any of the provided groups.
			for ( var groupName in groups ) {

				// If the collection of groups is a struct, make sure that the value 
				// indicates group inclusion before checking activation.
				if ( isStruct( groups ) && ! groups[ groupName ] ) {

					continue; // To next group.

				}

				if ( arrayContains( feature.groups, groupName ) ) {

					states[ feature.name ] = true;
					break; // Out of group-loop.

				}

			}

		}

		return( states );

	}


	/**
	* I determine if the given feature if fully activated. This is only true if the 
	* rollout of the given feature is at 100 percent.
	* 
	* @featureName I am the name of the feature being checked.
	* @output false
	*/
	public boolean function isActive( required string featureName ) {

		var states = featureStates();

		return( structKeyExists( states, featureName ) && states[ featureName ] );

	}


	/**
	* I determine if the given feature is active for the given group.
	* 
	* @featureName I am the feature being checked.
	* @groupName I am the group for which the feature is being checked.
	* @output false
	*/
	public boolean function isActiveForGroup(
		required string featureName,
		required string groupName
		) {

		var states = featureStatesForGroup( groupName );

		return( structKeyExists( states, featureName ) && states[ featureName ] );

	}


	/**
	* I determine if the given feature is active for the given user.
	* 
	* When checking the feature status for a given user,  you can pass in an optional
	* collection of groups. This can be an array of group names:
	* 
	* groups: [ "admins", "employees" ]
	* 
	* ... or it can be a struct in which the keys are group names and the values are 
	* boolean flags that indicate whether or not the user is part of that group:
	* 
	* groups: {
	* "admins": false,
	* "employees": true
	* }
	* 
	* CAUTION: The groups names are case-sensitive! So, be sure to quote your struct keys
	* if you are passing in a struct.
	* 
	* @featureName I am the feature being checked.
	* @userIdentifier I am the user for which the feature is being checked.
	* @groups I am the collection of groups that the user is part of.
	* @output false
	*/
	public boolean function isActiveForUser(
		required string featureName,
		required string userIdentifier,
		any groups = []
		) {

		var states = featureStatesForUser( userIdentifier, groups );

		return( structKeyExists( states, featureName ) && states[ featureName ] );

	}


	/**
	* I test whether or not the given featureName is a valid value. If it is valid, I
	* return quietly; however, if it is invalid, I throw an error.
	* 
	* @featureName I am the value being tested.
	* @output false
	*/
	public void function testFeatureName( required string featureName ) {

		if ( 
			! len( featureName ) ||
			( featureName != trim( featureName ) )
			) {

			throw(
				type = "InvalidArgument",
				message = "FeatureName is invalid.",
				detail = "The given featureName [#FeatureName#] must be a non-empty string without leading or trailing white-space."
			);

		}

	}


	/**
	* I test whether or not the given groupName is a valid value. If it is valid, I
	* return quietly; however, if it is invalid, I throw an error.
	* 
	* @groupName I am the value being tested.
	* @output false
	*/
	public void function testGroupName( required string groupName ) {

		if ( 
			! len( groupName ) ||
			( groupName != trim( groupName ) )
			) {

			throw(
				type = "InvalidArgument",
				message = "GroupName is invalid.",
				detail = "The given groupName [#groupName#] must be a non-empty string without leading or trailing white-space."
			);

		}

	}


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
	* I test whether or not the given userIdentifier is a valid value. If it is valid, I
	* return quietly; however, if it is invalid, I throw an error.
	* 
	* @userIdentifier I am the value being tested.
	* @output false
	*/
	public void function testUserIdentifier( required string userIdentifier ) {

		if ( 
			! len( userIdentifier ) ||
			( userIdentifier != trim( userIdentifier ) )
			) {

			throw(
				type = "InvalidArgument",
				message = "UserIdentifier is invalid.",
				detail = "The given userIdentifier [#userIdentifier#] must be a non-empty string without leading or trailing white-space."
			);

		}

	}


	// ---
	// PRIVATE METHODS.
	// ---


	/**
	* I delete the collection of features.
	* 
	* @output false
	*/
	private void function deleteFeatureSetData() {

		storage.delete( featureSetStorageKey );

	}


	/**
	* I get the bucket (1-100) to which the given user identifier is assigned. The same 
	* user identifier will always be assigned to the same bucket, which can subsequently
	* be mapped to a percentage.
	* 
	* @userIdentifier I the user identifier for which we are calculating the bucket.
	* @output false
	*/
	private numeric function getBucketForUserIdentifier( required string userIdentifier ) {

		// The checksum algorithm interface returns a LONG value, which we cannot use
		// with the normal modulus operator. As such, we have to fallback to using the
		// BigInteger to perform the modulus operation.
		var BigInteger = createObject( "java", "java.math.BigInteger" );

		// Generate our BigInteger operands.
		var checksum = BigInteger.valueOf( javaCast( "long", getChecksum( userIdentifier ) ) );
		var bucketCount = BigInteger.valueOf( javaCast( "int", 100 ) );

		return( checksum.mod( bucketCount ) + 1 );

	}


	/**
	* I generate a numeric checksum for the given string input.
	* 
	* @input I am the value for which we are generating a checksum.
	* @output false
	*/
	private numeric function getChecksum( required string input ) {

		var checksum = createObject( "java", "java.util.zip.CRC32" ).init();

		checksum.update( charsetDecode( input, "utf-8" ) );
		
		return( checksum.getValue() );

	}


	/**
	* I return the collection of features. If an optional featureName is provided, it 
	* will be ensured in the resultant collection before it is returned.
	* 
	* @featureName I am the optional feature being ensured in the resultant data.
	* @output false
	*/
	private struct function getFeatureSetData( string featureName = "" ) {

		try {

			var featureSet = deserializeJson( storage.get( featureSetStorageKey ) );

		} catch ( any error ) {

			var featureSet = {};

		}

		if ( len( featureName ) && ! structKeyExists( featureSet, featureName ) ) {

			featureSet[ featureName ] = {
				name: featureName,
				percentage: 0,
				users: [],
				groups: []
			};

		}

		return( featureSet );

	}


	/**
	* I save the given collection of features.
	* 
	* @featureSet I am the collection of features being saved.
	* @output false
	*/
	private void function saveFeatureSetData( required struct featureSet ) {

		storage.set( featureSetStorageKey, serializeJson( featureSet ) );

	}

}