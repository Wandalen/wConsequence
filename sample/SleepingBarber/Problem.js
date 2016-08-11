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

function clientsGenerator( con )
{
  var i = 0,
    len = clientsList.length;

  for( ; i < len; i++ )
  {
    var client = { name : clientsList[ i ].name };
    setTimeout(( function( client )
    {
      /* sending clients to shop */
      con.give( client );
    }).bind( null, client ), clientsList[ i ].arrivedTime );
  }

  return con;
}

//

/* initializing */

var clientSequence = wConsequence();
var time = _.timeNow();

/* listening for client appending in shop */

clientSequence.persist( ( err, client ) =>
{

  if( err )
  throw _.errLog( err );

  /* clients arrived to barber shop */
  console.log( 'new client is coming : ' + client.name + _.timeSpent( ' ',time ) );

});

/* send clients to barber shop. */

clientsGenerator( clientSequence );
