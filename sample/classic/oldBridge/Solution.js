/* qqq : implement */

let _;

if( typeof module !== 'undefined' )
{
  _ = require( 'wTools' );
  require( 'wConsequence' );
}

const MAX_CARS_NUM = 3;
const carsOnBridge = [];
const bridge = new _.Consequence({ capacity : 0 });

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
  _.time.out( carsList[ i ].arrivedTime, () => carArrive( carsList[ i ] ) );
}

//

function carArrive( car )
{
  console.log( `Car ${car.arrivedTime}` );
}

//

function ArriveBridge( direction )
{

}

function ExitBridge()
{

}
