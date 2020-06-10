let _ = require( 'wTools' );
require( 'wConsequence' );

let got = asyncRoutine();

console.log( got );
got.then( ( arg ) => console.log( arg ) || null );

//

function asyncRoutine()
{
  let ready = _.Consequence();

  ready.then( handler1 );
  ready.then( handler2 );
  ready.then( handler3 );

  ready.take( null );

  return ready;
}

function handler1()
{
  return 'abc';
}

function handler2( arg )
{
  return _.time.out( 5000, arg + '2' );
}

function handler3( arg )
{
  return arg + '3'
}
