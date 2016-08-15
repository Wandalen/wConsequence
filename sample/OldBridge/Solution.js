if( typeof module !== 'undefined' )
{
  var _ = require( 'wTools' );
  /* require( 'wConsequence' ); */
  require( '../../staging/abase/syn/Consequence.s' );
  var Problem = require( './Problem.js' );
}

var waitQueue = {
  '0': [],
  '1': []
};

Problem.arriveBridge = function( car )
{
  if( this.carsOnBridge.length === 0 ||
    ( this.carsOnBridge.length < 3 && this.carsOnBridge[ 0 ].direction === car.direction ) )
  {
    this.goCrossBridge( car );
  }
  else
  {
    waitQueue[ car.direction ].push( car );
  }

};

Problem.goCrossBridge = function(car)
{
  this.carsOnBridge.push(car);
  console.log( ' > car #' + car.name + ' crossing bridge with direction ' + car.direction);
  console.log( ' now on bridge: ' );
  for( var i = 0, l = this.carsOnBridge.length; i < l; i++)
    console.log( '    car #' +  this.carsOnBridge[ i ].name + ' direction:  ' + this.carsOnBridge[ i ].direction );
  setTimeout( this.exitBridge.bind( this, car ), car.duration );
};

Problem.exitBridge = function( car )
{
  _.arrayRemoveOnce( this.carsOnBridge, car);
  console.log( ' < car #' + car.name + ' exit from bridge ' );
  if( waitQueue[ car.direction ].length > 0 )
  {
    var newCar = waitQueue[ car.direction ].shift()
    this.goCrossBridge( newCar );
  }
  else if( this.carsOnBridge.length === 0 && waitQueue[ 1 - car.direction ].length > 1 )
  {
    var l = Math.min( waitQueue[ 1 - car.direction ].length, 3 );
    while( l-- )
    {
      var newCar = waitQueue[ 1 - car.direction ].shift();
      this.goCrossBridge( newCar );
    }
  }
}

Problem.carsArrive();