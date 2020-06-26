/**
 * @file This sample demonstrates using wConsequence for synchronization the several asynchronous process by example of
 * 'Old Bridge' problem. In this example arriving cars to the bridge and crossing it by them is asynchronous.
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
const MAX_CARS_NUM = 3;
const carsOnBridge = [];
const waitingCars = { 0 : [], 1 : [] }
const bridge = new _.Consequence({ capacity : 0 }).take( null );
Problem.ArriveBridge = ArriveBridge;
Problem.run();

//

function status()
{
  return `time:${_.time.spent( startTime )}, bridge:${carsOnBridge.length === MAX_CARS_NUM ? 'busy' : 'available'}, on bridge:${carsOnBridge.length}, direction:${carsOnBridge.length ? carsOnBridge[ 0 ].direction : 'any' }, waiting dir0: ${waitingCars[ 0 ].length}, waiting dir1: ${waitingCars[ 1 ].length}`;
}

//

function startMoving( car )
{
  carsOnBridge.push( car );
  console.log( `car №${car.number} starts to move: ${status()}` );
  return _.time.out( car.movingTime ).then( () => ExitBridge( car ) || null )
  .then( () => nextCar( car.direction ) );
}

//

function ArriveBridge( car )
{
  console.log();
  console.log( `+ car №${car.number} is coming, dir:${car.direction} - ${status()}` );

  if( bridge.resourcesCount() )
  {
    bridge.then( () => startMoving( car ) );
  }
  else if( carsOnBridge.length < 3 )
  {
    if( car.direction === carsOnBridge[ 0 ].direction )
    {
      startMoving( car );
    }
    else
    {
      waitingCars[ car.direction ].push( car );
      console.log( `direction on the bridge is opposite, the car №${car.number} is waiting: ${status()}` );
    }
  }
  else
  {
    waitingCars[ car.direction ].push( car );
    console.log( `the bridge is busy, car №${car.number} is waiting: ${status()}` );
  }
}

//

function nextCar( previousCarDirection )
{
  if( carsOnBridge.length )
  {
    let direction = carsOnBridge[ 0 ].direction;

    if( waitingCars[ direction ].length )
    {
      let next = waitingCars[ direction ].shift();
      return startMoving( next ).then( () => nextCar( next.direction ) );
    }
    else
      return null;
  }
  else
  {
    /* `previousCarDirection` allows cars to move in a direction different from those that have just finished moving.
    This makes passing the bridge alternating and more honest. */
    if( previousCarDirection === 0 )
    {
      if( waitingCars[ 1 ].length )
      {
        while( waitingCars[ 1 ].length )
        {
          let next = waitingCars[ 1 ].shift();

          if( !waitingCars[ 1 ].length )
          return startMoving( next );

          bridge.take( null );
          bridge.then( () => startMoving( next ) );
        }
      }
      else
      {
        return null;
      }
    }
    else
    {
      if( waitingCars[ 0 ].length )
      {
        while( waitingCars[ 0 ].length )
        {
          let next = waitingCars[ 0 ].shift();

          if( !waitingCars[ 0 ].length )
          return startMoving( next );

          bridge.take( null );
          bridge.then( () => startMoving( next ) );
        }
      }
      else
      {
        return null;
      }
    }
  }
}

//

function ExitBridge( car )
{
  _.arrayRemoveOnce( carsOnBridge, car );
  console.log( `- car №${car.number} leaves bridge: ${status()}` );
}

/* aaa Artem : done. implement */
