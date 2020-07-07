let _ = require( 'wTools' );
require( 'wConsequence' );

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
error log...

from error
from then2
*/
