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
const waitingCarsDir0 = [];
const waitingCarsDir1 = [];
const bridge = new _.Consequence({ capacity : 0 }).take( null );

const carsList =
[
  { arrivedTime : 500, direction : 1, movingTime : 1500 },
  { arrivedTime : 1500, direction : 1, movingTime : 1500 },
  { arrivedTime : 1250, direction : 0, movingTime : 1500 },
  { arrivedTime : 3500, direction : 0, movingTime : 1500 },
  { arrivedTime : 5000, direction : 1, movingTime : 1500 },
  { arrivedTime : 2200, direction : 0, movingTime : 1500 },
  { arrivedTime : 5000, direction : 0, movingTime : 1500 },
  { arrivedTime : 4700, direction : 1, movingTime : 1500 },
  { arrivedTime : 7800, direction : 0, movingTime : 1500 },
  { arrivedTime : 6500, direction : 1, movingTime : 1500 },
  { arrivedTime : 3700, direction : 0, movingTime : 1500 },
  { arrivedTime : 4200, direction : 1, movingTime : 1500 },
];

run();

//

function run()
{
  for( let i = 0; i < carsList.length; i++ )
  _.time.out( carsList[ i ].arrivedTime, () => carArrive( carsList[ i ], i + 1 ) );
}

//

function status()
{
  return `time:${_.time.spent( startTime )}, bridge:${carsOnBridge.length === MAX_CARS_NUM ? 'busy' : 'available'}, on bridge now:${carsOnBridge.length}, waiting cars dir0:${waitingCarsDir0.length}, waiting cars dir1:${waitingCarsDir1.length}`;
}

//

function carArrive( car, idx )
{
  console.log( ` + a car ${idx} is coming: ${status()}` );

  ArriveBridge( car.direction );
}

//

function ArriveBridge( direction )
{
  const waitingCar = new _.Consequence();

  if( carsOnBridge.length )
  {
    if( carsOnBridge[ 0 ].direction === direction )
    {
      if( carsOnBridge.length === MAX_CARS_NUM )
      {

      }
      else
      {

      }
    }
    else
  }

  waitingCar.deasync();
  return waitingCar.sync();
}

function ExitBridge()
{

}
