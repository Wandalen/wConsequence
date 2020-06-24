let _ = require( 'wTools' );
require( 'wConsequence' );

var con = new _.Consequence();

con.error( _.errAttend( 'my error' ) );

// .resourcesGet() returns an array of resources
console.log( con.resourcesGet().length ); // logs: 1

console.log( con.resourcesGet()[ 0 ] );
/* logs:
[Object: null prototype] {
  error:  = Message of error#1
      my error

   = Beautified calls stack
      ...

   = Throws stack
      ...
  ,
  argument: undefined
}
*/

/* */

var con = new _.Consequence();

// the passed resource-error will not be processed by competitors that go before .catch() in the queue
con.then( ( arg ) =>
{
  console.log( arg );
  return 'from then1';
} );

// competitor that processes resource-error should return something
con.catch( ( err ) =>
{
  console.log( err );
  return 'from error';
} );

// next competitor after .catch() gets return value
con.then( ( arg ) =>
{
  console.log( arg );
  return 'from then2';
} );

con.thenGive( ( arg ) => console.log( arg ) );

con.error( _.errAttend( 'my error' ) );
/* logs:
 = Message of error#2
    my error

 = Beautified calls stack
    ...

 = Throws stack
    ...

from error
from then2
*/
