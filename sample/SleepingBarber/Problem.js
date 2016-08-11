/**
 * @file This sample demonstrates simulation of visiting barber shop by clients.
 */

if( typeof module !== 'undefined' )
{
  var _ = require( 'wTools' );
  /* require( 'wConsequence' ); */
  require( '../../staging/abase/syn/Consequence.s' );
}

var clientsList =  // list of clients
[
  { name : 'Jon', arrivedTime : 500 },
  { name : 'Alfred', arrivedTime : 5000 },
  { name : 'Jane', arrivedTime : 5000 },
  { name : 'Derek', arrivedTime : 1500 },
  { name : 'Bob', arrivedTime : 4500 },
  { name : 'Sean', arrivedTime : 6500 },
  { name : 'Martin', arrivedTime : 2500 },
  { name : 'Joe', arrivedTime : 7000 },
];

//

/**
 * Used to simulate clients visiting hairdresser
 * @param {wConsequence} con - this parameter represent sequence of clients that go to barber shop
 * @returns {wConsequence}
 */

function clientsGenerator()
{
  var i = 0,
    len = clientsList.length;

  for( ; i < len; i++ )
  {
    var client = { name : clientsList[ i ].name };
    var time = _.timeNow();
    setTimeout(( function( client, time )
    {
      /* sending clients to shop */
      this.barberShopArrive( client, time );
    }).bind( this, client, time ), clientsList[ i ].arrivedTime );
  }
}

//

/* initializing */

/* listening for client appending in shop */

function barberShopArrive( client, time )
{
  /* clients arrived to barber shop */
  console.log( 'new client is coming : ' + client.name + _.timeSpent( ' ',time ) );

};

var Self =
{
  clientsGenerator : clientsGenerator,
  barberShopArrive : barberShopArrive,
}

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
  if( !module.parent )
    Self.clientsGenerator();
}