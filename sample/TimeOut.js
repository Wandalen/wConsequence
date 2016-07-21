
if( typeof module !== 'undefined' )
{
  require( 'wTools' );
  /* require( 'wConsequence' ); */
  require( '../staging/abase/syn/Consequence.s' );
}

/* correspondents */

function gotHandler1( error, value )
{
  console.log( 'handler 1: ' + value );
  value++;
  return value;
}

function gotHandler2( error, value )
{
  console.log( 'handler 2: ' + value );
}

function gotHandler3( error, value )
{
  console.log( 'handler 3 err: ' + error );
  console.log( 'handler 3 val: ' + value );
  return ++value
}

/* cases */

console.log( 'case1' );
var con = new wConsequence();

con.timeOut( 500, gotHandler1 ).got( gotHandler2 );

con.give( 90 ).give( 1 );

/**/

console.log( 'case2' );
var con = new wConsequence();

con.timeOut( 500, gotHandler1).got( gotHandler2 );

con.give( 90 );
