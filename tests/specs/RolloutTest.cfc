component
	extends = "TestCase"
	output = false
	hint = "I test the JSON Web Tokens component."
	{

	public void function setup() {

		rollout = new lib.Rollout( new lib.storage.InMemoryStorage() );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	public void function test_that_empty_works() {

		assert( rollout.isFeatureActive( "foo" ) == false );		
		assert( rollout.isFeatureActiveForUser( "foo", "myUser" ) == false );		
		assert( rollout.isFeatureActiveForGroup( "foo", "myGroup" ) == false );

		assert( structIsEmpty( rollout.getFeatureStates() ) );	
		assert( structIsEmpty( rollout.getFeatureStatesForUser( "myUser" ) ) );	
		assert( structIsEmpty( rollout.getFeatureStatesForGroup( "myGroup" ) ) );
		assert( ! arrayLen( rollout.getFeatureNames() ) );

	}


	public void function test_that_feature_works() {

		rollout.activateFeature( "canView" );
		rollout.deactivateFeature( "canEdit" );

		assert( rollout.isFeatureActive( "canView" ) );
		assert( rollout.isFeatureActiveForUser( "canView", "myUser" ) );
		assert( rollout.isFeatureActiveForGroup( "canView", "myGroup" ) );
		assert( ! rollout.isFeatureActive( "canEdit" ) );
		assert( ! rollout.isFeatureActiveForUser( "canEdit", "myUser" ) );
		assert( ! rollout.isFeatureActiveForGroup( "canEdit", "myGroup" ) );

		var feature = rollout.getFeature( "canView" );

		assert( feature.name == "canView" );
		assert( feature.percentage == 100 );

		var feature = rollout.getFeature( "canEdit" );

		assert( feature.name == "canEdit" );
		assert( feature.percentage == 0 );


		rollout.activateFeature( "canEdit" );
		rollout.deactivateFeature( "canView" );

		assert( rollout.isFeatureActive( "canEdit" ) );
		assert( rollout.isFeatureActiveForUser( "canEdit", "myUser" ) );
		assert( rollout.isFeatureActiveForGroup( "canEdit", "myGroup" ) );
		assert( ! rollout.isFeatureActive( "canView" ) );
		assert( ! rollout.isFeatureActiveForUser( "canView", "myUser" ) );
		assert( ! rollout.isFeatureActiveForGroup( "canView", "myGroup" ) );

		var feature = rollout.getFeature( "canEdit" );

		assert( feature.name == "canEdit" );
		assert( feature.percentage == 100 );

		var feature = rollout.getFeature( "canView" );

		assert( feature.name == "canView" );
		assert( feature.percentage == 0 );

	}


	public void function test_that_feature_names_work() {

		rollout.activateFeature( "canView" );
		rollout.activateFeature( "canEdit" );
		rollout.deactivateFeature( "canDelete" );

		var features = rollout.getFeatureNames();

		assert( 
			arrayContains( features, "canView" ) &&
			arrayContains( features, "canEdit" ) &&
			arrayContains( features, "canDelete" )
		);

		var stateSets = [
			rollout.getFeatureStates(),
			rollout.getFeatureStatesForUser( "myUser" ),
			rollout.getFeatureStatesForGroup( "myGroup" )
		];

		for ( var states in stateSets ) {

			assert( 
				( states.canView == true ) &&
				( states.canEdit == true ) &&
				( states.canDelete == false )
			);

		}

	}


	public void function test_that_user_groups_work() {

		rollout.activateFeatureForGroup( "canView", "myGroup" );

		assert( ! rollout.isFeatureActiveForUser( "canView", 1 ) );
		assert( rollout.isFeatureActiveForUser( "canView", 1, [ "myGroup" ] ) );
		assert( rollout.isFeatureActiveForUser( "canView", 1, { "myGroup": true } ) );
		assert( ! rollout.isFeatureActiveForUser( "canView", 1, { "myGroup": false } ) );
		assert( ! rollout.isFeatureActiveForUser( "canView", 1, { "otherGroup": true } ) );

	}


	public void function test_that_groups_work() {

		rollout.activateFeatureForGroup( "canView", "all" );
		rollout.activateFeatureForGroup( "canDelete", "admins" );

		assert( rollout.isFeatureActiveForGroup( "canView", "all" ) );
		assert( ! rollout.isFeatureActiveForGroup( "canView", "admins" ) );

		rollout.deactivateFeatureForGroup( "canDelete", "all" );

		assert( ! rollout.isFeatureActiveForGroup( "canDelete", "all" ) );
		assert( rollout.isFeatureActiveForGroup( "canDelete", "admins" ) );

		rollout.deactivateFeatureForGroup( "canDelete", "admins" );

		assert( ! rollout.isFeatureActiveForGroup( "canDelete", "all" ) );
		assert( ! rollout.isFeatureActiveForGroup( "canDelete", "admins" ) );

	}


	public void function test_that_percentage_works() {

		rollout.activateFeatureForPercentage( "canView", 0 );

		var count = 0;

		for ( var i = 1 ; i <= 100 ; i++ ) {

			if ( rollout.isFeatureActiveForUser( "canView", "user-#i#" ) ) {

				count++;

			}

		}

		assert( count == 0 );


		rollout.activateFeatureForPercentage( "canView", 100 );

		var count = 0;

		for ( var i = 1 ; i <= 100 ; i++ ) {

			if ( rollout.isFeatureActiveForUser( "canView", "user-#i#" ) ) {

				count++;

			}

		}

		assert( count == 100 );


		rollout.activateFeatureForPercentage( "canView", 50 );

		var count = 0;

		for ( var i = 1 ; i <= 100 ; i++ ) {

			if ( rollout.isFeatureActiveForUser( "canView", "user-#i#" ) ) {

				count++;

			}

		}

		assert( ( count > 40 ) && ( count < 70 ) );


		rollout.activateFeatureForPercentage( "canDelete", 100 );

		assert( rollout.isFeatureActiveForUser( "canDelete", "myUser" ) );

		rollout.deactivateFeatureForPercentage( "canDelete" );
		
		assert( ! rollout.isFeatureActiveForUser( "canDelete", "myUser" ) );
		
	}


	public void function test_that_user_works() {

		rollout.activateFeatureForUser( "canView", "myUser" );
		rollout.deactivateFeatureForUser( "canDelete", "myUser" );

		assert( rollout.isFeatureActiveForUser( "canView", "myUser" ) );
		assert( ! rollout.isFeatureActiveForUser( "canEdit", "myUser" ) );
		assert( ! rollout.isFeatureActiveForUser( "canDelete", "myUser" ) );

		var states = rollout.getFeatureStatesForUser( "myUser" );

		assert(
			( states.canView == true ) &&
			( states.canDelete == false )
		);

	}


	public void function test_that_clear_and_delete_work() {

		rollout.activateFeature( "canView" );
		rollout.activateFeature( "canEdit" );

		assert( rollout.isFeatureActive( "canView" ) );
		assert( rollout.isFeatureActive( "canEdit" ) );
		assert( arrayLen( rollout.getFeatureNames() ) == 2 );

		rollout.deleteFeature( "canEdit" );

		assert( rollout.isFeatureActive( "canView" ) );
		assert( ! rollout.isFeatureActive( "canEdit" ) );
		assert( arrayLen( rollout.getFeatureNames() ) == 1 );

		rollout.clearFeatures();

		assert( ! rollout.isFeatureActive( "canView" ) );
		assert( ! rollout.isFeatureActive( "canEdit" ) );
		assert( arrayLen( rollout.getFeatureNames() ) == 0 );

	}


	public void function test_that_multi_users_works() {

		rollout.activateFeatureForUsers( "canView", [ "userA", "userB" ] );

		assert( rollout.isFeatureActiveForUser( "canView", "userA" ) );
		assert( rollout.isFeatureActiveForUser( "canView", "userB" ) );
		assert( ! rollout.isFeatureActiveForUser( "canView", "userC" ) );

	}


	public void function test_that_ensure_creates_feature() {

		var featureNames = rollout.getFeatureNames();

		assert( ! arrayContains( featureNames, "canView" ) );
		assert( ! arrayContains( featureNames, "canEdit" ) );

		rollout.ensureFeature( "canView" );
		rollout.ensureFeature( "canEdit" );

		var featureNames = rollout.getFeatureNames();

		assert( arrayContains( featureNames, "canView" ) );
		assert( arrayContains( featureNames, "canEdit" ) );

	}

}