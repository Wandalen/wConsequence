/* qqq : implement */
let _;

if( typeof module !== 'undefined' )
{
  _ = require( 'wTools' );
  require( 'wConsequence' );
}

const startTime = _.time.now();
const con = new _.Consequence().take( null );
const waitingH = [];
const waitingE = [];
let passOnBoard = [];
const riverCrossingTime = 10000;
let crossingRiver = false;

const passengers =
[
  { id : 1, fraction : 'employee', arrival : 1000 },
  { id : 2, fraction : 'hacker', arrival : 1500 },
  { id : 3, fraction : 'employee', arrival : 2500 },
  { id : 4, fraction : 'employee', arrival : 3500 },

  { id : 5, fraction : 'hacker', arrival : 5500 },
  { id : 6, fraction : 'employee', arrival : 6500 },
  { id : 7, fraction : 'hacker', arrival : 8000 },
  { id : 8, fraction : 'employee', arrival : 9500 },

  { id : 9, fraction : 'hacker', arrival : 10500 },
  { id : 10, fraction : 'employee', arrival : 12000 },
  { id : 11, fraction : 'hacker', arrival : 13500 },
  { id : 12, fraction : 'hacker', arrival : 15000 },

  { id : 13, fraction : 'hacker', arrival : 16500 },
  { id : 14, fraction : 'employee', arrival : 17500 },
  { id : 15, fraction : 'employee', arrival : 18000 },
  { id : 16, fraction : 'hacker', arrival : 19500 },
]

run();

//

function run()
{
  for( let i = 0; i < passengers.length; i++ )
  _.time.out( passengers[ i ].arrival, () => passengerArrives( passengers[ i ] ) );
}

//

function status()
{
  const h = passOnBoard.filter( ( p ) => p.fraction === 'hacker' );
  const e = passOnBoard.filter( ( p ) => p.fraction === 'employee' );
  return `${_.time.spent( startTime )}, boatCrossesRiver: ${crossingRiver}, onBoard: h:${h.length} e:${e.length}, waitingH: ${waitingH.length}, waitingE: ${waitingE.length}`;
}

//

function nextBoat()
{
  crossingRiver = false;
  passOnBoard = [];
  console.log( `boat finished crossing the river, new landing is starting - ${status()}` );

  if( !waitingH.length && !waitingE.length )
  return null;

  // if( waitingH.length >= 2 && waitingE >= 2 )
  // {
  //   passOnBoard.push( ... waitingH.splice( 0, 2 ), ... waitingE.splice( 0, 2 ) );
  //   return rowBoat();
  // }
  // else if( waitingH.length >= 4 )
  // {
  //   passOnBoard.push( ... waitingH.splice( 0, 4 ) );
  //   return rowBoat();
  // }
  // else if( waitingE.length >= 4 )
  // {
  //   passOnBoard.push( ... waitingE.splice( 0, 4 ) );
  //   return rowBoat();
  // }
  // else
  // {
  //   passOnBoard.push( waitingH )
  // }
}

//

function passengerArrives( p )
{
  console.log( `+ pass_${p.id} ${p.fraction} arrived - ${status()}` );

  p.fraction === 'hacker' ? hackerArrives( p ) : employeeArrives( p );
}

//

function boardBoat( p )
{
  passOnBoard.push( p );
  console.log( `  pass_${p.id} ${p.fraction} boarded - ${status()}` );
}

//

function rowBoat()
{
  crossingRiver = true;
  console.log( `- boat starts to cross the river - ${status}` );
  return _.time.out( riverCrossingTime ).then( nextBoat );
}

//

function hackerArrives( h )
{
  if( crossingRiver || waitingH.length )
  {
    waitingH.push( h );
  }
  else
  {
    boardBoat( h );
    if( passOnBoard.length === 4 )
    con.then( () => rowBoat );
  }
}

//

function employeeArrives( e )
{
  if( crossingRiver || waitingE.length )
  {
    waitingH.push( e );
  }
  else
  {
    boardBoat( e );
    if( passOnBoard.length === 4 )
    con.then( () => rowBoat );
  }
}
