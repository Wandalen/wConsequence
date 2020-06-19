/**
 * @file This sample demonstrates using wConsequence for synchronization the several asynchronous process by example of
 * sleeping barber problem. In this example appending clients in barber shop and servicing them by barber are
 * asynchronous.
*/

let Problem,
  _;

if( typeof module !== 'undefined' )
{
  _ = require( 'wTools' );
  require( 'wConsequence' );
  Problem = require( './Problem.js' );
}

let DURATION_OF_WORK = { short : 500, average : 1500, long : 3000 }; /* qqq : remove random from samples */
let BARBER_NUM_SITS = 3;
let startTime = _.time.now();
let barber = _.Consequence().take( null );
let waitingRoom = [];

Problem.clientArrive = clientArrive;
Problem.run();

//

function status()
{
  return `  -   time:${_.time.spent( startTime )}  barber:${barber.resourcesCount() ? 'available' : 'busy' } waiting:${ waitingRoom.length } seets:${BARBER_NUM_SITS}`;
}

//

function clientCut( client )
{
  console.log( ` . begins haircut client ${client.name} ${status()}` );
  return _.time.out( DURATION_OF_WORK[ client.hair ] )
  .then( () => console.log( ` - client ${client.name} cutted ${status()}` ) || null );
}

//

function clientNext()
{
  if( !waitingRoom.length )
  return null;
  return clientCut( waitingRoom.pop() ).then( clientNext );
}

//

function clientArrive( client )
{
  /* clients arrived to barber shop */
  console.log( ` + new client is coming ${client.name} ${status()}` );

  if( barber.resourcesCount() )
  {
    barber.then( () => clientCut( client ) );
    barber.then( () => clientNext() );
  }
  else if( waitingRoom.length < BARBER_NUM_SITS )
  {
    waitingRoom.unshift( client );
  }
  else
  {
    console.log( ` - all seats in waiting room are occupied, so client ${client.name} leave shop` );
  }
}
