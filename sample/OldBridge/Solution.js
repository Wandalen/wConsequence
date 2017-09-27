if( typeof module !== 'undefined' )
{
  var _ = require( 'wTools' );
  /* require( 'wConsequence' ); */
  require( '../../staging/dwtools/abase/oclass/Consequence.s' );
  var Problem = require( './Problem.js' );
}

var waitQueue = {
  '0': wConsequence(),
  '1': wConsequence()
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
    waitQueue[ car.direction ].give( car );
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
  if( waitQueue[ car.direction ].messagesGet().length > 0 )
  {
    waitQueue[ car.direction ].got( ( function(err, newCar)
    {
      this.goCrossBridge( newCar );
    } ).bind(this) );
  }
  else if( this.carsOnBridge.length === 0 && waitQueue[ 1 - car.direction ].messagesGet().length > 1 )
  {
    var l = Math.min( waitQueue[ 1 - car.direction ].messagesGet().length, 3 );
    while( l-- )
    {
      var newCar = waitQueue[ 1 - car.direction ].got( ( function(err, newCar)
      {
        this.goCrossBridge( newCar );
      } ).bind(this));
    }
  }
}

Problem.carsArrive();