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

let conseuqence = new _.Consequence();
Dns.resolve4( uri, conseuqence );
conseuqence.thenGive( ( addresses ) => console.log( `Ips of ${uri} are ${JSON.stringify( addresses )}` ) );

/*

Consequence `conseuqence` is replacement of callback. It is temporary container for `addresses`.
Consequence `conseuqence` will get error if `Dons.resolve4` will fail.

*/

/* aaa Artem : done. use it for tutorial */
