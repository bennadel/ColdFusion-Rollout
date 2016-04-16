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

		// Store the injected properties.
		variables.storage = storage;

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	/**
	* I activate the given feature for all users (turning the percentage up to 100).
	* 
	* @featureName I am the feature being activated.
	* @output false
	*/
	public void function activateFeature( required string featureName ) {

		activateFeatureForPercentage( featureName, 100 );

	}


	/**
	* I activate the given feature for the given group (which can be associated with a 
	* user when feature activation is being checked for a specific user).
	* 
	* @featureName I am the feature being activated.
	* @groupName I am the group for which the feature is being activated.
	* @output false
	*/
	public void function activateFeatureForGroup(
		required string featureName,
		required string groupName
		) {

		testFeatureName( featureName );
		testGroupName( groupName );

		var featureSet = getFeatureSetData( featureName );
		var feature = featureSet[ featureName ];

		if ( ! arrayContainsSafe( feature.groups, groupName ) ) {

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
	public void function activateFeatureForPercentage(
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
	public void function activateFeatureForUser(
		required string featureName,
		required string userIdentifier
		) {

		testFeatureName( featureName );
		testUserIdentifier( userIdentifier );

		var featureSet = getFeatureSetData( featureName );
		var feature = featureSet[ featureName ];

		if ( ! arrayContainsSafe( feature.users, userIdentifier ) ) {

			arrayAppend( feature.users, userIdentifier );
			
		}
			
		saveFeatureSetData( featureSet );

	}


	/**
	* I activate the given feature for the given set of users.
	* 
	* NOTE: This is just a convenience method for calling the activateFeatureForUser()
	* multiple times (once for each identifier in the set).
	* 
	* @featureName I am the feature being activated.
	* @userIdentifiers I am the set of users for which the feature is being activated.
	* @output false
	*/
	public void function activateFeatureForUsers(
		required string featureName,
		required array userIdentifiers
		) {

		for ( var userIdentifier in userIdentifiers ) {

			activateFeatureForUser( featureName, userIdentifier );

		}

	}


	/**
	* I delete all of the stored feature data.
	* 
	* @output false
	*/
	public void function clearFeatures() {

		deleteFeatureSetData();

	}


	/**
	* I deactivate the given feature for all users and groups.
	* 
	* @featureName I am the feature being deactivated.
	* @output false
	*/
	public void function deactivateFeature( required string featureName ) {

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
	public void function deactivateFeatureForGroup(
		required string featureName,
		required string groupName
		) {

		testFeatureName( featureName );
		testGroupName( groupName );

		var featureSet = getFeatureSetData( featureName );
		var feature = featureSet[ featureName ];

		if ( arrayContainsSafe( feature.groups, groupName ) ) {

			arrayDelete( feature.groups, groupName );

		}
		
		saveFeatureSetData( featureSet );

	}


	/**
	* I deactivate the percentage-based rollout of the given feature.
	* 
	* CAUTION: This will leave the explicit user and group targeting in tact.
	* 
	* @featureName I am the feature being deactivated.
	* @output false
	*/
	public void function deactivateFeatureForPercentage( required string featureName ) {

		activateFeatureForPercentage( featureName, 0 );

	}


	/**
	* I deactivate the given feature for the given user.
	* 
	* @featureName I am the feature being deactivated.
	* @userIdentifier I am the user for which the feature is being deactivated.
	* @output false
	*/
	public void function deactivateFeatureForUser(
		required string featureName,
		required string userIdentifier
		) {

		testFeatureName( featureName );
		testUserIdentifier( userIdentifier );

		var featureSet = getFeatureSetData( featureName );
		var feature = featureSet[ featureName ];

		if ( arrayContainsSafe( feature.users, userIdentifier ) ) {

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
	public void function deleteFeature( required string featureName ) {

		var featureSet = getFeatureSetData();

		structDelete( featureSet, featureName );

		saveFeatureSetData( featureSet );

	}


	/**
	* I ensure that the given feature exists. If it does not, it is created and defaulted
	* to an inactive state.
	* 
	* @output false
	*/
	public void function ensureFeature( required string featureName ) {

		var featureSet = getFeatureSetData();

		if ( ! structKeyExists( featureSet, featureName ) ) {

			saveFeatureSetData( getFeatureSetData( featureName ) );

		}

	}


	/**
	* I get the given feature configuration.
	* 
	* @output false
	*/
	public struct function getFeature( required string featureName ) {

		var featureSet = getFeatureSetData( featureName );

		return( featureSet[ featureName ] );

	}


	/**
	* I return the collection of known feature names.
	* 
	* @output false
	*/
	public array function getFeatureNames() {

		var featureSet = getFeatureSetData();
		var featureNames = [];

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
	public struct function getFeatureStates() {

		var featureSet = getFeatureSetData();
		var states = {};

		for ( var featureName in featureSet ) {

			var feature = featureSet[ featureName ];

			states[ feature.name ] = ( feature.percentage == 100 );

		}

		return( states );

	}


	/**
	* I return a struct of features in which each key represents the feature name and 
	* each value determines whether that feature is active for the given group.
	* 
	* @groupName I am the group for which the feature states are being checked.
	* @output false
	*/
	public struct function getFeatureStatesForGroup( required string groupName ) {

		var featureSet = getFeatureSetData();
		var states = {};

		for ( var featureName in featureSet ) {

			var feature = featureSet[ featureName ];

			// Check to see if the feature is being rolled out all users.
			if ( feature.percentage == 100 ) {

				states[ feature.name ] = true;
				continue; // To next feature.

			}

			states[ feature.name ] = arrayContainsSafe( feature.groups, groupName );

		}

		return( states );

	}


	/**
	* I return a struct of features in which each key represents the feature name and 
	* each value determine whether that feature is active for the given user.
	* 
	* When checking the feature status for a given user, you can pass in an optional
	* collection of groups. This can be an array of group names of which the user is 
	* a member
	* 
	* groups: [ "admins", "employees" ]
	* 
	* ... or, it can be a struct in which the keys are the group names and the values 
	* are boolean flags that indicate whether or not the user is member of that group:
	* 
	* groups: {
	*   "admins": false,
	*   "employees": true
	* }
	* 
	* @userIdentifier I am the user for which the feature states are being checked.
	* @groups I am the optional groups (array | struct) associated with the given user.
	* @output false
	*/
	public struct function getFeatureStatesForUser( 
		required string userIdentifier,
		any groups = []
		) {

		var featureSet = getFeatureSetData();
		var states = {};

		for ( var featureName in featureSet ) {

			var feature = featureSet[ featureName ];

			// Default the state of the feature to false.
			states[ feature.name ] = false;

			// Check to see if the feature is being rolled out to a percentage of the 
			// user-base in which this user is included.
			// --
			// NOTE: We are passing the feature name is a "salt" for the bucket 
			// calculation (in order to help distribute the features a bit more).
			if ( 
				feature.percentage && 
				( getBucketForUserIdentifier( userIdentifier, feature.name ) <= feature.percentage ) 
				) {

				states[ feature.name ] = true;
				continue; // To next feature.

			}

			// Check to see if the feature is explicitly enabled for this user.
			if ( arrayContainsSafe( feature.users, userIdentifier ) ) {

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

				if ( arrayContainsSafe( feature.groups, groupName ) ) {

					states[ feature.name ] = true;
					break; // Out of group-loop.

				}

			}

		}

		return( states );

	}


	/**
	* I return the collection of feature configurations as a struct in which each feature
	* name is a key in the resultant collection.
	* 
	* @output false
	*/
	public struct function getFeatures() {

		var featureSet = getFeatureSetData();
		
		return( featureSet );

	}


	/**
	* I determine if the given feature if fully activated. This is only true if the 
	* rollout of the given feature is at 100 percent.
	* 
	* @featureName I am the name of the feature being checked.
	* @output false
	*/
	public boolean function isFeatureActive( required string featureName ) {

		var states = getFeatureStates();

		return( structKeyExists( states, featureName ) && states[ featureName ] );

	}


	/**
	* I determine if the given feature is active for the given group.
	* 
	* @featureName I am the feature being checked.
	* @groupName I am the group for which the feature is being checked.
	* @output false
	*/
	public boolean function isFeatureActiveForGroup(
		required string featureName,
		required string groupName
		) {

		var states = getFeatureStatesForGroup( groupName );

		return( structKeyExists( states, featureName ) && states[ featureName ] );

	}


	/**
	* I determine if the given feature is active for the given user.
	* 
	* @featureName I am the feature being checked.
	* @userIdentifier I am the user for which the feature is being checked.
	* @groups I am the collection of groups that the user is part of.
	* @output false
	*/
	public boolean function isFeatureActiveForUser(
		required string featureName,
		required string userIdentifier,
		any groups = []
		) {

		var states = getFeatureStatesForUser( userIdentifier, groups );

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
	* I implement a "safe" version of the arrayContainsSafe() method. ColdFusion 10 
	* is lame in how it handles type comparisons in the native arrayContains() function.
	* As such, we have to implement a version that can convert between values a bit
	* more seamlessly.
	* 
	* @value I am the collection of values being searched.
	* @target I am the target value whose existence is being checked.
	* @output false
	*/
	private boolean function arrayContainsSafe(
		required array values,
		required string target
		) {

		for ( var value in values ) {

			if ( value == target ) {

				return( true );

			}

		}

		return( false );

	}


	/**
	* I delete the collection of features.
	* 
	* @output false
	*/
	private void function deleteFeatureSetData() {

		storage.delete();

	}


	/**
	* I get the bucket (1-100) to which the given user identifier is assigned. The same 
	* user identifier will always be assigned to the same bucket, which can subsequently
	* be mapped to a percentage.
	* 
	* @userIdentifier I the user identifier for which we are calculating the bucket.
	* @salt I am the optional salt used to help distribute percentages across users.
	* @output false
	*/
	private numeric function getBucketForUserIdentifier( 
		required string userIdentifier,
		string salt = ""
		) {

		// The checksum algorithm interface returns a LONG value, which we cannot use
		// with the normal modulus operator. As such, we have to fallback to using the
		// BigInteger to perform the modulus operation.
		var BigInteger = createObject( "java", "java.math.BigInteger" );

		// Generate our BigInteger operands.
		var checksum = BigInteger.valueOf( javaCast( "long", getChecksum( userIdentifier & salt ) ) );
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

		var checksum = createObject( "java", "java.util.zip.Adler32" ).init();

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

			var featureSet = storage.get();

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

		storage.set( featureSet );

	}

}
