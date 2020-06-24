/*
 * An old bridge has only one lane and can only hold at most 3 cars at a time without risking collapse. Create a monitor
 * with methods ArriveBridge(int direction) and ExitBridge() that controls traffic so that at any taken time, there are
 * at most 3 cars on the bridge, and all of them are going the same direction. A car calls ArriveBridge when it arrives
 * at the bridge and wants to go in the specified direction (0 or 1); ArriveBridge should not return until the car is
 * allowed to get on the bridge. A car calls ExitBridge when it gets off the bridge, potentially allowing other cars to
 * get on. Don't worry about starving cars trying to go in one direction; just make sure cars are always on the bridge
 * when they can be.
 *
 * source: https://inst.eecs.berkeley.edu/~cs162/sp10/hand-outs/synch-problems.html
 */
let _;

if( typeof module !== 'undefined' )
{
  _ = require( 'wTools' );
  require( 'wConsequence' );
}

const startTime = _.time.now();

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

//

let Self =
{
  run,
  ArriveBridge,
};

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
  if( !module.parent )
    Self.run();
}

//

function run()
{
  for( let i = 0; i < carsList.length; i++ )
  _.time.out( carsList[ i ].arrivedTime, () => this.ArriveBridge( carsList[ i ] ) );
}

//

function ArriveBridge( car )
{
  /* a car arrived to the bridge */
  console.log( `+ car №${car.number} is coming, dir:${car.direction}, time: ${_.time.spent( startTime )}` );
}

/*  aaa Artem : done. rewrite */

/* */

// let carsArriveList =
//   [
//     { direction : 1, delay : 500, duration : 1500 },
//     { direction : 1, delay : 1000, duration : 1000 },
//     { direction : 0, delay : 1000, duration : 500 },
//     { direction : 1, delay : 2000, duration : 1500 },
//     { direction : 0, delay : 2500, duration : 1000 },
//     { direction : 0, delay : 3000, duration : 500 },
//     { direction : 1, delay : 3000, duration : 1500 },
//     { direction : 1, delay : 4000, duration : 1500 },
//     { direction : 0, delay : 4500, duration : 1000 },
//     { direction : 0, delay : 5000, duration : 1500 },
//     { direction : 0, delay : 5000, duration : 1500 },
//     { direction : 1, delay : 6000, duration : 1500 },
//   ];

// let carsOnBridge = [];

// function carsArrive()
// {
//   let i = 0;
//   let len = carsArriveList.length;
//   let time = _.time.now();


//   for( ; i < len; i++ )
//   {
//     let car = carsArriveList[ i ];
//     car.name = i;

//     setTimeout( ( function( car )
//     {
//       console.log( ' car #' + car.name + ' arrive at ' + _.time.spent( ' ', time ) );
//       this.arriveBridge( car );
//     }).bind( this, car ), carsArriveList[ i ].delay );
//   }
// }

// function arriveBridge( car )
// {
//   carsOnBridge.push(car);

//   let l = carsOnBridge.length;
//   if( carsOnBridge.length > 3 )
//   {
//     console.log( 'max car limit exceeded, bridge COLLAPSED' );
//     process.exit();
//   }
//   while( l-- )
//   {
//     if( carsOnBridge[ l ].direction !== car.direction )
//     {
//       console.log( 'cars CRASHED' );
//       process.exit();
//     }
//   }
//   setTimeout( this.exitBridge.bind( this, car ), car.duration );
// }

// function exitBridge( car )
// {
//   _.arrayRemoveOnce( this.carsOnBridge, car );
//   console.log( 'car #' + car.name + 'exit from bridge' );
// }

// let Self =
// {
//   carsArrive,
//   arriveBridge,
//   exitBridge,
//   carsOnBridge
// };

// //

// if( typeof module !== 'undefined' )
// {
//   module[ 'exports' ] = Self;
//   if( !module.parent )
//     Self.carsArrive();
// }
