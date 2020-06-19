let _ = require( 'wTools' );
require( 'wConsequence' );
let Dns = require( 'dns' );

let uri = 'google.com';

/* with callback */

Dns.resolve4( uri, ( err, addresses ) => /* qqq : nodejs routine which is synchronous */
{
  if( err ) console.log( err );
  console.log( `Ips of ${uri} are ${JSON.stringify( addresses )}` );
} );

/* with consequence */

let addresses = new _.Consequence();
Dns.resolve4( uri, addresses );
console.log( `Ips of ${uri} are ${JSON.stringify( addresses.sync() )}` );

/*

Method `sync` unwrap consequence, effectively it looks like conversion to the original type.
In case of error call `sync()` will throw the error synchronously.

*/

/* qqq : does not work ( demonstratively ) because of asynchronicity. please find synchronous nodejs routine with the same callback signature */
/* aaa Artem : done. use it for tutorial */
