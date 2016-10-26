
if( typeof module !== 'undefined' )
{
  var _ = require( 'wTools' );
  /* require( 'wConsequence' ); */
  require( '../staging/abase/syn/Consequence.s' );
}

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

var t = _.timeOut( 2000, function()
{

  console.log( 'case1' );
  var con = new wConsequence();

  con.thenTimeOut( 1000, gotHandler1 ).got( gotHandler2 );

  con.give( 90 ).give( 1 );

})

/**/

t.thenTimeOut( 2000, function()
{

  console.log( 'case2' );
  var con = new wConsequence();

  con.thenTimeOut( 1000, gotHandler1 ).got( gotHandler2 );

  con.give( 90 );

});

/**/

t.thenTimeOut( 2000, function()
{

  console.log( 'case3' );
  var con = new wConsequence();

  con.give( 90 );

  con.thenTimeOut( 1000, gotHandler1 ).got( gotHandler2 );

});

/**/

t.thenTimeOut( 2000, function()
{

  console.log( 'case4' );

  var con = new wConsequence();
  var con2 = new wConsequence();

  debugger;

  con.give( 90 );
  con.thenTimeOut( 1000, con2 ).got( gotHandler1 );
  con2.thenDo( gotHandler2 );

  _.timeOut( 1500, function()
  {

    console.log( 'con :\n' + con.toStr() );
    console.log( 'con2 :\n' + con2.toStr() );

  });

  debugger;

});
