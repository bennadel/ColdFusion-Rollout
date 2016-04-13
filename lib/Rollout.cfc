component
	output = false
	hint = "I implement the Rollout gem for ColdFusion, providing a feature flag library."
	{

	/**
	* I initialize the Rollout library with the given storage gateway.
	* 
	* 
	*/
	public any function init( required any storage ) {

		variables.storage = storage;

		variables.featureSetKey = "__features__";

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

		var feature = getFeature( featureName );

		if ( ! arrayContains( feature.groups, groupName ) ) {

			arrayAppend( feature.groups, groupName );
			
			saveFeature( feature );

		}
			
		ensureFeatureInFeatureSet( feature );

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

		var feature = getFeature( featureName );

		feature.percentage = percentage;

		saveFeature( feature );
		ensureFeatureInFeatureSet( feature );

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

		var feature = getFeature( featureName );

		if ( ! arrayContains( feature.users, userIdentifier ) ) {

			arrayAppend( feature.users, userIdentifier );
			
			saveFeature( feature );

		}
			
		ensureFeatureInFeatureSet( feature );

	}


	/**
	* I activate the given feature for the given set of users.
	* 
	* NOTE: This is just a convienience method for calling the activateUser() multiple
	* times (once for eac identifier in the set).
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

		// Delete all of the features.
		for ( var featureName in getFeatureSet() ) {

			storage.delete( normalizeKey( featureName ) );

		}

		// Delete the feature set.
		storage.delete( normalizeKey( featureSetKey ) );

	}


	/**
	* I deactive the given feature for all users and groups.
	* 
	* @featureName I am the feature being deactivated.
	* @output false
	*/
	public void function deactivate( required string featureName ) {

		testFeatureName( featureName );

		var feature = getFeature( featureName );

		feature.percentage = 0;
		feature.users = [];
		feature.groups = [];

		saveFeature( feature );
		ensureFeatureInFeatureSet( feature );

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

		var feature = getFeature( featureName );

		if ( arrayContains( feature.group, groupName ) ) {

			arrayDelete( feature.group, groupName );

			saveFeature( feature );

		}
		
		ensureFeatureInFeatureSet( feature );

	}


	/**
	* I deactivate the percentage-based rollout of the given feature.
	* 
	* NOTE: This will leave the explicit user and group targeting.
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

		var feature = getFeature( featureName );

		if ( arrayContains( feature.users, userIdentifier ) ) {

			arrayDelete( feature.users, userIdentifier );

			saveFeature( feature );

		}
			
		ensureFeatureInFeatureSet( feature );

	}


	/**
	* I delete the given feature.
	* 
	* @featureName I am the feature being deleted.
	* @output false
	*/
	public void function delete( required string featureName ) {

		var featureSet = getFeatureSet();

		if ( arrayContains( featureSet, featureName ) ) {

			arrayDelete( featureSet, featureName );

			saveFeatureSet( featureSet );
			storage.delete( normalizeKey( featureName ) );

		}

	}


	/**
	* I return the collection of known feature names.
	* 
	* @output false
	*/
	public array function features() {

		return( getFeatureSet() );

	}


	/**
	* I return a struct of features in which each key represents the feature name and 
	* each value determine whether that feature is active based on percentage rollout.
	* 
	* NOTE: A feature is considered active when perentage is set to 100.
	* 
	* @output false
	*/
	public struct function featureStates() {

		var states = {};

		for ( var featureName in getFeatureSet() ) {

			states[ featureName ] = isActive( featureName );

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

		var states = {};

		for ( var featureName in getFeatureSet() ) {

			states[ featureName ] = isActiveForUser( featureName, userIdentifier, groups );

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

		var feature = getFeature( featureName );

		return( feature.percentage == 100 );

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

		var feature = getFeature( featureName );

		return( arrayContains( feature.groups, groupName ) );

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

		var feature = getFeature( featureName );

		// Check to see if the feature is being rolled out to a percentage of the user-
		// base in which this user is included.
		if ( 
			feature.percentage && 
			( getBucketForUserIdentifier( userIdentifier ) <= feature.percentage ) 
			) {

			return( true );

		}

		// If the user is explicitly marked as active, that takes presedence.
		if ( arrayContains( feature.users, userIdentifier ) ) {

			return( true );

		}

		// Check to see if the feature is active for any of the provided groups.
		for ( var groupName in groups ) {

			// If the collection of groups is a struct, make sure that the value 
			// indicates group inclusion before checking activation.
			if ( isStruct( groups ) && ! groups[ groupName ] ) {

				continue;

			}

			if ( arrayContains( feature.groups, groupName ) ) {

				return( true );

			}

		}

		// If we made it this far, the feature is not active for the user, neither 
		// explicitly, nor as part of a group.
		return( false );

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
	* I ensure that the given feature is defined within the current feature set. 
	* 
	* @feature I am the feature being ensured within the feature set.
	* @output false
	*/
	private void function ensureFeatureInFeatureSet( required struct feature ) {

		var featureSet = getFeatureSet();

		// If the currently persisted feature set does not contain the given feature, 
		// this is a new feature we have to add to the set.
		if ( ! arrayContains( featureSet, feature.name ) ) {

			arrayAppend( featureSet, feature.name );

			saveFeatureSet( featureSet );

		}

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
		var checksum = BigInteger.valueOf( javaCast( "long", getChecksum( identifier ) ) );
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

		checksum.update( charsetDecode( userIdentifier, "utf-8" ) );
		
		return( checksum.getValue() );

	}


	/**
	* I return the feature with the given name. If the feature doesn't exist, a new
	* feature is returned.
	* 
	* @featureName I am the name of the feature being retreived.
	* @output false
	*/
	private struct function getFeature( required string featureName ) {

		try {

			var feature = deserializeJson( storage.get( normalizeKey( featureName ) ) );

		} catch ( any error ) {

			var feature = {
				name: featureName,
				percentage: 0,
				users: [],
				groups: []
			};

		}

		return( feature );

	}


	/**
	* I return the collection of feature names.
	* 
	* @output false
	*/
	private array function getFeatureSet() {

		try {

			var featureSet = deserializeJson( storage.get( normalizeKey( featureSetKey ) ) );

		} catch ( any error ) {

			var featureSet = [];

		}

		return( featureSet );

	}


	/**
	* I normalize the given key for use in the storage mechanism.
	* 
	* @key I am the key being normalized for storage.
	* @output false
	*/
	private string function normalizeKey( required string key ) {

		return( "feature:" & key );

	}


	/**
	* I save the given feature configuration.
	* 
	* @feature I am the feature being saved.
	* @output false
	*/
	private void function saveFeature( required struct feature ) {

		storage.set( normalizeKey( featureName ), serializeJson( feature ) );

	}


	/**
	* I save the given featureSet.
	* 
	* @featureSet I am the feature being saved.
	* @output false
	*/
	private void function saveFeatureSet( required array featureSet ) {

		storage.set( normalizeKey( featureSetKey ), serializeJson( featureSet ) );

	}

}