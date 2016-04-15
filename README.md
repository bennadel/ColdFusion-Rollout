
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
doesn't have to deal with "keys" - it just deals with a value.

* delete() - Deletes the persisted JSON value.
* get() - Returns the persisted JSON value.
* set( jsonData ) - Persists the given JSON value.

If you are using the Jedis / Redis storage, the Redis key is defined as part of the storage
instance, not the Rollout library.

## Instantiation

To use Rollout, you have to instantiate it with a storage implementation. This library 
comes with an In-Memory implementation, which can be used for testing:

```cfm
var storage = new lib.storage.InMemoryStorage();

var rollout = new lib.Rollout( storage );
```

But, you'll definitely want to use the Jedis / Redis implementation so your feature 
configurations actually persist across pages:

```cfm
var jedisPoolConfig = createObject( "java", "redis.clients.jedis.JedisPoolConfig" ).init();
var jedisPool = createObject( "java", "redis.clients.jedis.JedisPool" ).init( jedisPoolConfig, javaCast( "string", "localhost" ) );
var storage = new lib.storage.JedisStorage( jedisPool, "rollout-features" );

var rollout = new lib.Rollout( storage );
```

## Usage

.... coming soon.


[bennadel]: http://www.bennadel.com
[googleplus]: https://plus.google.com/108976367067760160494?rel=author
[rollout]: https://github.com/fetlife/rollout
[fetlife]: https://github.com/fetlife