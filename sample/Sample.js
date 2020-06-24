require( 'wConsequence' );
let _ = wTools;

let con = new _.Consequence();

// .finallyGive() unlike .finally() should not return anything
con.finallyGive( ( err, arg ) =>
{
  if( err ) console.log( err );
  console.log( 'Got :', arg )
} );
con.take( 'Some arg' );
