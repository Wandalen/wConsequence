let _ = require( 'wTools' );
require( 'wConsequence' );

var con = new _.Consequence();

con.error( _.errAttend( 'my error' ) );

// .resourcesGet() returns an array of resources
console.log( con.resourcesGet().length ); // logs: 1

console.log( con.resourcesGet()[ 0 ] );
/* logs:
[Object: null prototype] {
  error: error log... ,
  argument: undefined
}
*/
