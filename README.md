
# Rollout For ColdFusion

by [Ben Nadel][bennadel] (on [Google+][googleplus])

This is my ColdFusion "port" of the Ruby gem, [Rollout][rollout], developed by the team 
over at [FetLife][fetlife]. Rollout is a feature flag library that helps you gradually roll 
features out to your user base using percentages, groups, and explicit user identifiers.
This is not an exact port of the code but, rather, a library that drew inspiration from
the Rollout gem.

Internally, my version of Rollout is optimized for bulk reads. All of the data is stored
in a single key which contains serialized JSON (JavaScript Object Notation) data. I chose
to use this internal architecture because I'd rather go over the wire fewer times and 
pull back more data each time. This also keeps the storage API extremely simple and easy
to implement:

## Storage API

Because the library stores all feature data a single JSON value, the storage mechanism
doesn't have to deal with "keys" - it just deals with a single Struct value. The actual
serialization of the data is deferred to the storage mechanism so that we can use storage
that is not necessarily document oriented.

* __delete__() - Deletes the persisted value.
* __get__() - Returns the persisted value.
* __set__( value ) - Persists the given value.

If you are using the Jedis / Redis storage, the Redis key is defined as part of the storage
instance, not the Rollout library.

## Instantiation

To use Rollout, you have to instantiate it with a storage implementation. This library 
comes with an In-Memory implementation, which can be used for testing:

```cfc
var storage = new lib.storage.InMemoryStorage();

var rollout = new lib.Rollout( storage );
```

But, you'll definitely want to use the Jedis / Redis implementation so your feature 
configurations actually persist across pages:

```cfc
var jedisPoolConfig = createObject( "java", "redis.clients.jedis.JedisPoolConfig" ).init();
var jedisPool = createObject( "java", "redis.clients.jedis.JedisPool" ).init( jedisPoolConfig, javaCast( "string", "localhost" ) );
var storage = new lib.storage.JedisStorage( jedisPool, "rollout-features" );

var rollout = new lib.Rollout( storage );
```

## Usage

The primary gesture in a feature rollout is to check to see whether or not a given feature 
is activated. This can be done based on percentages, groups, and user identifiers. When 
checked on its own, a feature is only considered to be "active" if it is being rolled-out
to 100% of the users. When checked in the context of a user (and optional groups), a feature
can be partially active.

The following list represents the Rollout API broken down by use-case.

### Activating Features

When activating a feature, understand that percentage rollout acts _independently_ from the
explicit user and group activation. Meaning, a feature can be rolled out to 0% of users but
_still be active_ for explicit users and groups.

* __activateFeature__( featureName )
* __activateFeatureForGroup__( featureName, groupName )
* __activateFeatureForPercentage__( featureName, percentage )
* __activateFeatureForUser__( featureName, userIdentifier )
* __activateFeatureForUsers__( featureName, userIdentifiers )
* __ensureFeature__( featureName )

### Deactivating Features

* __clearFeatures__()
* __deactivateFeature__( featureName )
* __deactivateFeatureForGroup__( featureName, groupName )
* __deactivateFeatureForPercentage__( featureName )
* __deactivateFeatureForUser__( featureName, userIdentifier )
* __deleteFeature__( featureName )

### Getting Features And Feature States

My implementation of Rollout is optimized for `getFeatureStatesForUser()`. This will pull
back all of the feature configuration for the given user in a single internal request. When
making this request, you have the _option_ to pass in a collection of groups. If the collection
is an array, the values indicate the groups that the user is a members of:

```cfc
var featureStates = rollout.getFeatureStatesForUser(
	user.id,
	[ "managers", "admins" ]
);
```

If the collection is a struct, the keys of the struct represent the group names and the 
struct values indicate whether or not the user is a member of that group. This approach allows
the group membership to be calculated as part of the method invocation:

```cfc
var featureStates = rollout.getFeatureStatesForUser(
	user.id,
	{
		managers: user.permissions.isManager,
		admins: user.permissions.isAdmin
	}
);
```

* __getFeature__( required string featureName )
* __getFeatureNames__()
* __getFeatureStates__()
* __getFeatureStatesForGroup__( groupName )
* __getFeatureStatesForUser__( userIdentifier [, groups ] )
* __getFeatures__()

### Checking Single Feature State

* __isFeatureActive__( featureName )
* __isFeatureActiveForGroup__( featureName, groupName )
* __isFeatureActiveForUser__( featureName, userIdentifier [, groups ] )

## Demo

I have included a Jedis storage demo that helps to illustrates how several of the features
in Rollout work. This demo assumes that Redis is running on `localhost`.


[bennadel]: http://www.bennadel.com
[googleplus]: https://plus.google.com/108976367067760160494?rel=author
[rollout]: https://github.com/fetlife/rollout
[fetlife]: https://github.com/fetlife