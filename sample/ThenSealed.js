'use strict';
if( typeof module !== 'undefined' )
{
  require( 'wTools' );
  // require( 'wConsequence' );
  require( '../staging/abase/syn/Consequence.s' );
}


function corespondent1(err, val)
{
  console.log( 'corespondent1 value: ' + val );
};

var con = wConsequence();
con.thenSealed( {}, corespondent1 );

con.give( 'foo' );
