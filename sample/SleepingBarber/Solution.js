/**
 * @file This sample demonstrates using wConsequence for synchronization the several asynchronous process by example of
 * sleeping barber problem. In this example appending clients in barber shop and servicing them by barber are
 * asynchronous.
 */

if( typeof module !== 'undefined' )
{
  var _ = require( 'wTools' );
  /* require( 'wConsequence' ); */
  require( '../../staging/dwtools/abase/oclass/Consequence.s' );
  var Problem = require( './Problem.js' );
}

/**
 * Class barber simulate work barber in barber shop.
 * @class Barber
 */

var DURATION_OF_WORK_RANGE = [ 500, 3000 ],
BARBER_NUM_SITS = 3,
SLEEP = 0,
WORK = 1;

var barber = {},
    waitingRoom = wConsequence();

barber.state = SLEEP;

function cutClient(err, client) // barber ready for work
{
  barber.state = WORK;
  console.log( `begins haircut client ${client.name}` );
  _.timeOut( _getDelay() ).got( function()
  {
    console.log( `client ${client.name} cutted` );

    if( waitingRoom.messagesGet().length > 0 )
    {
      waitingRoom.got( cutClient );
    }
    else
      barber.state = SLEEP;
  } );
}

function _getDelay()
{
  var max = DURATION_OF_WORK_RANGE[ 0 ],
    min = DURATION_OF_WORK_RANGE[ 1 ];
  return Math.floor( Math.random() * ( max - min + 1 ) ) + min;
}

Problem.barberShopArrive = function( client, time )
{
  /* clients arrived to barber shop */
  console.log( 'new client is coming : ' + client.name + _.timeSpent( ' ',time ) );
  if ( barber.state === SLEEP )  /* if no client and barber sleep, client wakes him */
  {
    cutClient( null, client );
  }
  else if( waitingRoom.messagesGet().length < BARBER_NUM_SITS ) /* else client try to place client in queue */
  {
    waitingRoom.give( client );
  }
  else
  {
    console.log( `all seats in waiting room are occupied, so client ${client.name} leave shop` );
  }
};

Problem.clientsGenerator();
