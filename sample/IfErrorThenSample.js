
if( typeof module !== 'undefined' )
{
  require( 'wTools' );
  // require( 'wConsequence' );
  require( '../staging/abase/syn/Consequence.s' );
}

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
}

/**/

console.log( 'case 1' );

var con1 = new wConsequence();

con1.ifErrorThen( gotHandler3 ).got( gotHandler1 ).got( gotHandler2 );
con1.give( 1 ).give( 4 );

console.log( 'case 2' );

var con1 = new wConsequence();

con1.give( 1 ).give( 4 );
con1.ifErrorThen( gotHandler3 ).got( gotHandler1 ).got( gotHandler2 );

/**/

var con2 = new wConsequence();

con2.giveWithError( 'error msg', 8 ).give( 14 );

con2.ifErrorThen( gotHandler3 ).got( gotHandler1 );