let _ = require( 'wTools' );
require( 'wConsequence' );
let Dns = require( 'dns' );

let uri = 'google.com';

/* with callback */

Dns.resolve4( uri, ( err, addresses ) =>
{
  if( err ) console.log( err );
  console.log( `Ips of ${uri} are ${JSON.stringify( addresses )}` );
} );

/* with consequence */

let con = new _.Consequence();
Dns.resolve4( uri, con );
con.deasync();
console.log( `Ips of ${uri} are ${JSON.stringify( con.sync() )}` );

/*

Deasync suspend execution till consequence get resource or error.
Method `sync` unwrap consequence, effectively it looks like conversion to the original type.
In case of error call `sync()` will throw the error synchronously.

*/

/* aaa Artem : done. use it for tutorial */
