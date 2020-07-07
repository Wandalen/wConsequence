let _ = require( 'wTools' );
require( 'wConsequence' );

// The `capacity` option indicates the maximum number of resources in the resource queue at a time, by default 1
// if `capacity` : 0 - not limited
var con = new _.Consequence({ capacity : 0 });

con.take( 'my resource1' );
con.take( 'my resource2' );
con.error( _.errAttend( 'my error' ) );

// .resourcesGet() returns an array of resources
console.log( con.resourcesGet().length ); // logs: 3

console.log( con.resourcesGet()[ 0 ] ); // logs: [Object: null prototype] { error: undefined, argument: 'my resource1' }
console.log( con.resourcesGet()[ 2 ] ); /* logs:
[Object: null prototype] {
  error: error log... ,
  argument: undefined
}
*/
