let _ = require( 'wTools' );
require( 'wConsequence' );

var con = new _.Consequence();

// The `capacity` option indicates the maximum number of resources in the resource queue at a time, by default 1
// if `capacity` : 0 - not limited
var con = new _.Consequence({ capacity : 0 });

// .take(resource) - pass resource to the queue
con.take( 'my resource1' );
con.take( 'my resource2' );

console.log( con ); // Consequence:: 2 / 0

// .then(callback), thenGive(callback) - pass competitor to the queue
con.then( ( arg ) =>
{
  console.log( 'then: ', arg ); // then:  my resource1
  return 'new arg from then';
} );

con.thenGive( ( arg ) => console.log( 'thenGive: ', arg ) ); // thenGive:  my resource2

console.log( con ); // Consequence:: 1 / 0
