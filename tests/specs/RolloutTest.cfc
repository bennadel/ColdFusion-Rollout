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

		assert( rollout.isActive( "foo" ) == false );		
		assert( rollout.isActiveForUser( "foo", "myUser" ) == false );		
		assert( rollout.isActiveForGroup( "foo", "myGroup" ) == false );

		assert( structIsEmpty( rollout.featureStates() ) );	
		assert( structIsEmpty( rollout.featureStatesForUser( "myUser" ) ) );	
		assert( structIsEmpty( rollout.featureStatesForGroup( "myGroup" ) ) );
		assert( ! arrayLen( rollout.features() ) );

	}


	public void function test_that_feature_works() {

		rollout.activate( "canView" );
		rollout.deactivate( "canEdit" );

		assert( rollout.isActive( "canView" ) );
		assert( rollout.isActiveForUser( "canView", "myUser" ) );
		assert( rollout.isActiveForGroup( "canView", "myGroup" ) );
		assert( ! rollout.isActive( "canEdit" ) );
		assert( ! rollout.isActiveForUser( "canEdit", "myUser" ) );
		assert( ! rollout.isActiveForGroup( "canEdit", "myGroup" ) );

		rollout.activate( "canEdit" );
		rollout.deactivate( "canView" );

		assert( rollout.isActive( "canEdit" ) );
		assert( rollout.isActiveForUser( "canEdit", "myUser" ) );
		assert( rollout.isActiveForGroup( "canEdit", "myGroup" ) );
		assert( ! rollout.isActive( "canView" ) );
		assert( ! rollout.isActiveForUser( "canView", "myUser" ) );
		assert( ! rollout.isActiveForGroup( "canView", "myGroup" ) );

	}


	public void function test_that_feature_names_work() {

		rollout.activate( "canView" );
		rollout.activate( "canEdit" );
		rollout.deactivate( "canDelete" );

		var features = rollout.features();

		assert( 
			arrayContains( features, "canView" ) &&
			arrayContains( features, "canEdit" ) &&
			arrayContains( features, "canDelete" )
		);

		var stateSets = [
			rollout.featureStates(),
			rollout.featureStatesForUser( "myUser" ),
			rollout.featureStatesForGroup( "myGroup" )
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

		rollout.activateGroup( "canView", "myGroup" );

		assert( ! rollout.isActiveForUser( "canView", 1 ) );
		assert( rollout.isActiveForUser( "canView", 1, [ "myGroup" ] ) );
		assert( rollout.isActiveForUser( "canView", 1, { "myGroup": true } ) );
		assert( ! rollout.isActiveForUser( "canView", 1, { "myGroup": false } ) );
		assert( ! rollout.isActiveForUser( "canView", 1, { "otherGroup": true } ) );

	}


	public void function test_that_groups_work() {

		rollout.activateGroup( "canView", "all" );
		rollout.activateGroup( "canDelete", "admins" );

		assert( rollout.isActiveForGroup( "canView", "all" ) );
		assert( ! rollout.isActiveForGroup( "canView", "admins" ) );

		rollout.deactivateGroup( "canDelete", "all" );

		assert( ! rollout.isActiveForGroup( "canDelete", "all" ) );
		assert( rollout.isActiveForGroup( "canDelete", "admins" ) );

		rollout.deactivateGroup( "canDelete", "admins" );

		assert( ! rollout.isActiveForGroup( "canDelete", "all" ) );
		assert( ! rollout.isActiveForGroup( "canDelete", "admins" ) );

	}


	public void function test_that_percentage_works() {

		rollout.activatePercentage( "canView", 0 );

		var count = 0;

		for ( var i = 1 ; i <= 100 ; i++ ) {

			if ( rollout.isActiveForUser( "canView", "user-#i#" ) ) {

				count++;

			}

		}

		assert( count == 0 );


		rollout.activatePercentage( "canView", 100 );

		var count = 0;

		for ( var i = 1 ; i <= 100 ; i++ ) {

			if ( rollout.isActiveForUser( "canView", "user-#i#" ) ) {

				count++;

			}

		}

		assert( count == 100 );


		rollout.activatePercentage( "canView", 50 );

		var count = 0;

		for ( var i = 1 ; i <= 100 ; i++ ) {

			if ( rollout.isActiveForUser( "canView", "user-#i#" ) ) {

				count++;

			}

		}

		assert( ( count > 40 ) && ( count < 70 ) );


		rollout.activatePercentage( "canDelete", 100 );

		assert( rollout.isActiveForUser( "canDelete", "myUser" ) );

		rollout.deactivatePercentage( "canDelete" );
		
		assert( ! rollout.isActiveForUser( "canDelete", "myUser" ) );
		
	}


	public void function test_that_user_works() {

		rollout.activateUser( "canView", "myUser" );
		rollout.deactivateUser( "canDelete", "myUser" );

		assert( rollout.isActiveForUser( "canView", "myUser" ) );
		assert( ! rollout.isActiveForUser( "canEdit", "myUser" ) );
		assert( ! rollout.isActiveForUser( "canDelete", "myUser" ) );

		var states = rollout.featureStatesForUser( "myUser" );

		assert(
			( states.canView == true ) &&
			( states.canDelete == false )
		);

	}


	public void function test_that_clear_and_delete_work() {

		rollout.activate( "canView" );
		rollout.activate( "canEdit" );

		assert( rollout.isActive( "canView" ) );
		assert( rollout.isActive( "canEdit" ) );
		assert( arrayLen( rollout.features() ) == 2 );

		rollout.delete( "canEdit" );

		assert( rollout.isActive( "canView" ) );
		assert( ! rollout.isActive( "canEdit" ) );
		assert( arrayLen( rollout.features() ) == 1 );

		rollout.clear();

		assert( ! rollout.isActive( "canView" ) );
		assert( ! rollout.isActive( "canEdit" ) );
		assert( arrayLen( rollout.features() ) == 0 );

	}


	public void function test_that_multi_users_works() {

		rollout.activateUsers( "canView", [ "userA", "userB" ] );

		assert( rollout.isActiveForUser( "canView", "userA" ) );
		assert( rollout.isActiveForUser( "canView", "userB" ) );
		assert( ! rollout.isActiveForUser( "canView", "userC" ) );

	}


	public void function test_that_identifiers_are_case_sensitive() {

		rollout.activateUser( "canView", "myUser" );
		rollout.activateGroup( "canView", "myGroup" );

		assert( rollout.isActiveForUser( "canView", "myUser" ) );
		assert( ! rollout.isActiveForUser( "canView", "MYUSER" ) );
		assert( rollout.isActiveForGroup( "canView", "myGroup" ) );
		assert( ! rollout.isActiveForGroup( "canView", "MYGROUP" ) );

	}

}