let _ = require( 'wTools' );
require( 'wConsequence' );

var con = new _.Consequence();

console.log( con ); // Consequence:: 0 / 0

/* */

// The `capacity` option indicates the maximum number of resources in the resource queue at a time, by default 1
// if `capacity` : 0 - not limited
var con = new _.Consequence({ capacity : 0 });

con.take( 'my resource1' );
con.take( 'my resource2' );

console.log( con ); // Consequence:: 2 / 0

con.then( ( arg ) =>
{
  console.log( 'then: ', arg ); // then:  my resource1
  return 'new arg from then';
} );

con.thenGive( ( arg ) => console.log( 'thenGive: ', arg ) ); // thenGive:  my resource2

console.log( con ); // Consequence:: 1 / 0

/* */

var con = new _.Consequence();

con.then( ( arg ) =>
{
  console.log( 'then logs: ', arg );
  return 'new arg from then';
} );

con.thenGive( ( arg ) => console.log( 'thenGive logs: ', arg ) );

console.log( con ); // Consequence:: 0 / 2

con.take( 'my resource1' ); // logs: my resource1
con.take( 'my resource2' ); // logs: new arg from then

console.log( con ); // Consequence:: 1 / 0
