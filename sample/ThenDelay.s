let _ = require( 'wTools' );
require( 'wConsequence' );

/* cases */

var t = _.time.out( 2000, function()
{

  console.log( 'case1' );
  var con = new _.Consequence({ capacity : 0 });

  con.thenDelay( 1000 )
  .thenGive( gotHandler1 )
  .thenGive( gotHandler2 );

  con.take( 90 )
  .take( 1 );

})

/* correspondents */

function gotHandler1( value )
{
  console.log( 'handler 1 : ' + value );
  value++;
  return value;
}

function gotHandler2( value )
{
  console.log( 'handler 2 : ' + value );
  value++;
  return value;
}

/**/

// t.thenDelay( 2000, function()
// {

//   console.log( 'case2' );
//   var con = new _.Consequence();

//   con.thenDelay( 1000, gotHandler1 ).got( gotHandler2 );

//   con.take( 90 );

// });

// /**/

// t.thenDelay( 2000, function()
// {

//   console.log( 'case3' );
//   var con = new _.Consequence();

//   con.take( 90 );

//   con.thenDelay( 1000, gotHandler1 ).got( gotHandler2 );

// });

// /**/

// t.thenDelay( 2000, function()
// {

//   console.log( 'case4' );

//   var con = new _.Consequence();
//   var con2 = new _.Consequence();

//   debugger;

//   con.take( 90 );
//   con.thenDelay( 1000, con2 ).got( gotHandler1 );
//   con2.then( gotHandler2 );

//   _.time.out( 1500, function()
//   {

//     console.log( 'con :\n' + con.toStr() );
//     console.log( 'con2 :\n' + con2.toStr() );

//   });

//   debugger;

// });

/* qqq : simplify */
