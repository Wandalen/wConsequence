/* qqq : implement */

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
  { number : 1, arrivedTime : 500, direction : 1, movingTime : 1000 },
  { number : 2, arrivedTime : 1500, direction : 1, movingTime : 1200 },
  { number : 3, arrivedTime : 1250, direction : 0, movingTime : 850 },
  { number : 4, arrivedTime : 3500, direction : 0, movingTime : 1050 },
  { number : 5, arrivedTime : 5000, direction : 1, movingTime : 1500 },
  { number : 6, arrivedTime : 2200, direction : 0, movingTime : 750 },
  { number : 7, arrivedTime : 5000, direction : 0, movingTime : 1000 },
  { number : 8, arrivedTime : 4700, direction : 1, movingTime : 950 },
  { number : 9, arrivedTime : 7800, direction : 0, movingTime : 1050 },
  { number : 10, arrivedTime : 6500, direction : 1, movingTime : 800 },
  { number : 11, arrivedTime : 3700, direction : 0, movingTime : 1200 },
  { number : 12, arrivedTime : 4200, direction : 1, movingTime : 950 },
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
  return `time:${_.time.spent( startTime )}, bridge:${carsOnBridge.length === MAX_CARS_NUM ? 'busy' : 'available'}, on bridge now:${carsOnBridge.length}, waiting cars dir0:${waitingCars[ 0 ].length}, waiting cars dir1:${waitingCars[ 1 ].length}`;
}

//

function startMoving( car )
{
  console.log( `the car №${car.number} starts to move: ${status()}` );
  debugger;
  return _.time.out( car.movingTime, () => ExitBridge( car ) ).then( nextCar() )
}

//

function nextCar()
{
  if( carsOnBridge.length )
  {
    let direction = carsOnBridge[ 0 ].direction;

    if( waitingCars[ direction ].length )
      return startMoving( waitingCars[ direction ].shift() ).then( nextCar() );
    else
      return null;
  }
  else
  {
    let next = waitingCars[ 0 ].shift() || waitingCars[ 1 ].shift();

    if( next )
      return startMoving( next ).then( nextCar() );
    else
      return null;
  }
}

//

function ArriveBridge( car )
{
  console.log( `+ the car №${car.number} is coming: ${status()}` );

  if( bridge.resourcesCount() )
  {
    bridge.then( () => startMoving( car ) )
    bridge.then( () => nextCar() )
  }
  else
  {
    console.log( `the bridge is loaded, the car №${car.number} is waiting: ${status()}` );
    waitingCars[ car.direction ].push( car );
  }
}

//

function ExitBridge( car )
{
  _.arrayRemoveOnce( carsOnBridge, car );
  console.log( `- the car №${car.number} leaves bridge: ${status()}` );
}
