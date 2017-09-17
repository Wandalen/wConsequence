'use strict';

if( typeof module !== 'undefined' )
require( 'wConsequence' );


function corespondent1(err, val)
{
  console.log( 'corespondent1 value: ' + val );
}

var con = wConsequence();
con.thenSealed( {}, corespondent1,[] );

con.give( 'foo' );
