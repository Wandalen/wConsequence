
if( typeof module !== 'undefined' )
{
  require( 'wTools' );
  // require( 'wConsequence' );
  require('/home/ostash/work/nodejs/wConsequence/staging/abase/syn/Consequence.s')
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
  console.log( 'handler 3: ' + value );
}

var con1 = new wConsequence();
con1.give(1).give(4);

con1.inform( gotHandler1 );
con1.got( gotHandler2 );
con1.got( gotHandler3 );








