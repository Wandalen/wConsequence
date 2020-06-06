'use strict';

if( typeof module !== 'undefined' )
require( 'wConsequence' );


function corespondent1(err, val)
{
  console.log( 'corespondent1 value: ' + val );
}

var con = _.Consequence();
con.thenSealed( {}, corespondent1,[] );

con.take( 'foo' );
