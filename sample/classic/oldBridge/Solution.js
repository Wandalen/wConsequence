/* aaa Artem : done. implement */

let _;

if( typeof module !== 'undefined' )
{
  _ = require( 'wTools' );
  require( 'wConsequence' );
}

const startTime = _.time.now();
const MAX_CARS_NUM = 3;
const carsOnBridge = [];
const waitingCars = { 0 : [], 1 : [] }
const bridge = new _.Consequence({ capacity : 0 }).take( null );

const carsList =
[
  { number : 1, arrivedTime : 1000, direction : 1, movingTime : 10000 },
  { number : 2, arrivedTime : 2000, direction : 0, movingTime : 10000 },
  { number : 3, arrivedTime : 2500, direction : 1, movingTime : 10000 },
  { number : 4, arrivedTime : 3500, direction : 0, movingTime : 10000 },
  { number : 5, arrivedTime : 5000, direction : 0, movingTime : 10000 },
  { number : 6, arrivedTime : 5000, direction : 1, movingTime : 10000 },
  { number : 7, arrivedTime : 10000, direction : 1, movingTime : 10000 },
  { number : 8, arrivedTime : 23000, direction : 1, movingTime : 10000 },
  { number : 9, arrivedTime : 25000, direction : 0, movingTime : 10000 },
  { number : 11, arrivedTime : 27000, direction : 0, movingTime : 10000 },
  { number : 10, arrivedTime : 28000, direction : 1, movingTime : 10000 },
  { number : 12, arrivedTime : 30000, direction : 0, movingTime : 10000 },
];

run();

//

function run()
{
  for( let i = 0; i < carsList.length; i++ )
  _.time.out( carsList[ i ].arrivedTime, () => ArriveBridge( carsList[ i ] ) );
}

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

function ExitBridge( car )
{
  _.arrayRemoveOnce( carsOnBridge, car );
  console.log( `- car №${car.number} leaves bridge: ${status()}` );
}
