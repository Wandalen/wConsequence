let _ = require( 'wTools' );
require( 'wConsequence' );

var con = new _.Consequence();

con.thenGive( ( arg ) => console.log( 'thenGive1 is invoked with: ', arg ) );
con.catch( ( arg ) =>
{
  console.log( 'catch is invoked with: ', arg );
  return 'from catch';
} );
con.thenGive( ( arg ) => console.log( 'thenGive2 is invoked with: ', arg ) );

con.error( _.errAttend( 'Error!' ) );
// logs: catch is invoked with:  error log...
// logs: thenGive2 is invoked with:  from catch

console.log( con ); // logs: Consequence:: 0 / 0
