let _ = require( 'wTools' );
require( 'wConsequence' );
let Dns = require( 'dns' );
let uri = 'google.com';

/* with callback */

// Dns.resolve4( uri, ( err, addresses ) =>
// {
//   console.log( `Ips of ${uri} are ${JSON.stringify( addresses )}` );
// });

/* with consequence */

let consequence = new _.Consequence();

console.log( consequence );

Dns.resolve4( uri, consequence );

console.log( consequence );

consequence.thenGive( ( addresses ) => console.log( `Ips of ${uri} are ${JSON.stringify( addresses )}` ) );

console.log( consequence );

// consequence.deasync();
//
// console.log( consequence );
//
// console.log( `Ips of ${uri} are ${JSON.stringify( consequence.sync() )}` );
//
// console.log( consequence );
