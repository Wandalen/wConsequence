
if( typeof module !== 'undefined' )
require( 'wConsequence' );

/* correspondents */

function gotHandler1( error, value )
{
  console.log( 'handler 1 : ' + value );
  value++;
  return value;
}

function gotHandler2( error, value )
{
  debugger;
  console.log( 'handler 2 : ' + value );
  value++;
  return value;
}

function gotHandler3( error, value )
{
  console.log( 'handler 3 err : ' + error );
  console.log( 'handler 3 val : ' + value );
  value++;
  return value;
}

/* cases */

console.log( 'case 1' );

var con1 = new _.Consequence();

con1.take( 1 ).take( 4 );

con1.tap( gotHandler1 );
con1.got( gotHandler2 );
con1.got( gotHandler3 );

/* should be same */

console.log( 'case 2' );

var con1 = new _.Consequence();

con1.tap( gotHandler1 );
con1.got( gotHandler2 );
con1.got( gotHandler3 );

con1.take( 1 ).take( 4 );

/* qqq : simplify */
