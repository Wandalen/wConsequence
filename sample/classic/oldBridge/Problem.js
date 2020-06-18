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
}

var carsArriveList =
  [
    { direction : 1, delay : 500, duration : 1500 },
    { direction : 1, delay : 1000, duration : 1000 },
    { direction : 0, delay : 1000, duration : 500 },
    { direction : 1, delay : 2000, duration : 1500 },
    { direction : 0, delay : 2500, duration : 1000 },
    { direction : 0, delay : 3000, duration : 500 },
    { direction : 1, delay : 3000, duration : 1500 },
    { direction : 1, delay : 4000, duration : 1500 },
    { direction : 0, delay : 4500, duration : 1000 },
    { direction : 0, delay : 5000, duration : 1500 },
    { direction : 0, delay : 5000, duration : 1500 },
    { direction : 1, delay : 6000, duration : 1500 },
  ];

var carsOnBridge = [];

function carsArrive()
{
  var i = 0;
  var len = carsArriveList.length;
  var time = _.time.now();


  for( ; i < len; i++ )
  {
    var car = carsArriveList[ i ];
    car.name = i;

    setTimeout( ( function( car )
    {
      console.log( ' car #' + car.name + ' arrive at ' + _.time.spent( ' ', time ) );
      this.arriveBridge( car );
    }).bind( this, car ), carsArriveList[ i ].delay );
  }
}

function arriveBridge( car )
{
  carsOnBridge.push(car);

  var l = carsOnBridge.length;
  if( carsOnBridge.length > 3 )
  {
    console.log( 'max car limit exceeded, bridge COLLAPSED' );
    process.exit();
  }
  while( l-- )
  {
    if( carsOnBridge[ l ].direction !== car.direction )
    {
      console.log( 'cars CRASHED' );
      process.exit();
    }
  }
  setTimeout( this.exitBridge.bind(this, car ), car.duration );
}

function exitBridge( car )
{
  _.arrayRemoveOnce( this.carsOnBridge, car);
  console.log( 'car #' + car.name + 'exit from bridge' );
}

var Self =
{
  carsArrive,
  arriveBridge,
  exitBridge,
  carsOnBridge
};

//

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
  if( !module.parent )
    Self.carsArrive();
}

/* aaa Artem : done. rewrite */
