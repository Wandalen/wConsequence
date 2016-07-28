/**
 * @file This sample demonstrates simulation of visiting barber shop by clients.
 */

if( typeof module !== 'undefined' )
{
  var _ = require( 'wTools' );
  /* require( 'wConsequence' ); */
  require( '../staging/abase/syn/Consequence.s' );
}


var customersList =  // list of clients
  [
    { name: 'Jon', arrived: 500 },
    { name: 'Alfred', arrived: 5000 },
    { name: 'Jane', arrived: 5000 },
    { name: 'Derek', arrived: 1500 },
    { name: 'Bob', arrived: 4500 },
    { name: 'Sean', arrived: 6500 },
    { name: 'Martin', arrived: 2500 },
    { name: 'Joe', arrived: 7000 },
  ];

/**
 * Used to simulate customers visiting hairdresser
 * @param {wConsequence} con this parameter represent sequence of clients that go to barber shop
 * @returns {wConsequence}
 */

function custromerGenerator( con )
{
  var i = 0,
    len = customersList.length;

  for ( ; i< len; i++ )
  {
    var customer = { name: customersList[ i ].name };
    let delayCon = wConsequence();
    delayCon.thenTimeOut( customersList[ i ].arrived,
      function( err, value )
      {
        // sending customers to shop
        con.give(value)
      } );
    delayCon.give( customer );
  }
  return con;
}

// start process

// initializing
var clientSequence = wConsequence();

// listening for client appending in shop
clientSequence.persist( ( err, client ) =>
{
  if( err ) throw new Error( err );

  // clients arrived to barber shop
  console.log( 'new customer is coming: ' + client.name );
});

// send customers to barber shop.
custromerGenerator( clientSequence );