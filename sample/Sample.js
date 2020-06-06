
if( typeof module !== 'undefined' )
require( 'wConsequence' );
var _ = wTools;
var con = new _.Consequence();

con.got( function( err, arg )
{

  console.log( 'Got :', arg );
  /* log 'Got : Some arg' */

});

con.take( 'Some arg' );
