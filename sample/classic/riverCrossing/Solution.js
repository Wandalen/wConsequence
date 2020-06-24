/**
 * @file This sample demonstrates using wConsequence for synchronization the several asynchronous process by example of
 * 'River Crossing' problem. In this example, hackers and employees arrive on the back of the river asynchronously.
 */

let _,
  Problem;

if( typeof module !== 'undefined' )
{
  _ = require( 'wTools' );
  require( 'wConsequence' );
  Problem = require( './Problem.js' );
}

const startTime = _.time.now();
const con = new _.Consequence().take( null );
let waitingPass = [];
let passOnBoard = [];
const riverCrossingTime = 10000;
let crossingRiver = false;
Problem.passengerArrives = passengerArrives;
Problem.run();

//

function status()
{
  const h = passOnBoard.filter( ( p ) => p.fraction === 'hacker' );
  const e = passOnBoard.filter( ( p ) => p.fraction === 'employee' );
  return `${_.time.spent( startTime )}, boatCrossesRiver: ${crossingRiver}, onBoard: h:${h.length} e:${e.length}, waitingPass: ${waitingPass.length}`;
}

//

function boardBoat( p )
{
  passOnBoard.push( p );
  console.log( `  pass_${p.id} ${p.fraction} on board - ${status()}` );
}

//

function rowBoat()
{
  crossingRiver = true;
  console.log( `- boat starts to cross the river - ${status()}` );
  return _.time.out( riverCrossingTime ).then( nextBoat );
}

//

function passengerArrives( p )
{
  console.log( `+ pass_${p.id} ${p.fraction} arrived - ${status()}` );

  if( crossingRiver )
  {
    waitingPass.push( p );
    console.log( `there is no boat in the dock, pass_${p.id} should wait - ${status()}` );
  }
  else
  {
    p.fraction === 'hacker' ? hackerArrives( p ) : employeeArrives( p );
  }
}

//

function nextBoat()
{
  crossingRiver = false;
  passOnBoard = [];
  console.log( `- boat finished crossing the river, new landing is starting - ${status()}` );

  if( !waitingPass.length )
  return null;

  const forDeletingIdx = [];

  for( let i = 0; i < waitingPass.length; i++ )
  {
    let nextPass = waitingPass[ i ];
    if( nextPass.fraction === 'hacker' )
    {
      const e = passOnBoard.filter( ( p ) => p.fraction === 'employee' );
      const hB = passOnBoard.filter( ( p ) => p.fraction === 'hacker' );

      if( e.length < 3 && hB.length < 2 )
      {
        boardBoat( nextPass );
        forDeletingIdx.push( i );
      }
    }
    else
    {
      const h = passOnBoard.filter( ( p ) => p.fraction === 'hacker' );
      const eB = passOnBoard.filter( ( p ) => p.fraction === 'employee' );

      if( h.length < 3 && eB.length < 2 )
      {
        boardBoat( nextPass );
        forDeletingIdx.push( i );
      }
    }

    if( passOnBoard.length === 4 )
    break;
  }

  waitingPass = waitingPass.filter( ( p, idx ) =>
  {
    return !forDeletingIdx.includes( idx );
  } )

  if( passOnBoard.length === 4 )
  return rowBoat();
  else
  return null;
}

//

function hackerArrives( h )
{
  const e = passOnBoard.filter( ( p ) => p.fraction === 'employee' );
  const hB = passOnBoard.filter( ( p ) => p.fraction === 'hacker' );

  if( e.length < 3 && hB.length < 2 )
  {
    boardBoat( h );

    if( passOnBoard.length === 4 )
    con.then( () => rowBoat() );
  }
  else
  {
    waitingPass.push( h );
  }
}

//

function employeeArrives( e )
{
  const h = passOnBoard.filter( ( p ) => p.fraction === 'hacker' );
  const eB = passOnBoard.filter( ( p ) => p.fraction === 'employee' );

  if( h.length < 3 && eB.length < 2 )
  {
    boardBoat( e );

    if( passOnBoard.length === 4 )
    con.then( () => rowBoat() );
  }
  else
  {
    waitingPass.push( e );
  }
}

/* aaa Artem : done. implement */
