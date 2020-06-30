let _ = require( 'wTools' );
require( 'wConsequence' );

let Dns = require( 'dns' );

const con = new _.Consequence();

Dns.resolve4( 'google.com', con )

con.then( ( res ) =>
{
  console.log( res );
  return null
})

// con.deasync();
// console.log(con.sync());
