let _ = require( 'wTools' );
require( 'wConsequence' );

var con = new _.Consequence({ capacity : 0 });

con.then( ( arg ) =>
{
  console.log( 'then: ', arg );
  return 'new arg from then';
} );

con.thenGive( ( arg ) => console.log( 'thenGive: ', arg ) );

console.log( con );

con.take( 'my resource1' );
con.take( 'my resource2' );

console.log( con );
console.log( con.sync() );
