
if( typeof module !== 'undefined' )
require( 'wTools' );

var _ = wTools;

var con = new wConsequence();

con.got( function( err,data )
{

  console.log( 'got :',data );

});

con.give( 'some data' );
