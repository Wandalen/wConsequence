let _ = require( 'wTools' );
require( 'wConsequence' );

var con = new _.Consequence();

con.then( ( arg ) =>
{
  console.log( 'then: ', arg );
  return 'new arg from then';
} );

con.thenGive( ( arg ) => console.log( 'thenGive: ', arg ) );

console.log( con ); // Consequence:: 0 / 2

con.take( 'my resource1' ); // then:  my resource1
con.take( 'my resource2' ); // thenGive:  new arg from then

console.log( con ); // Consequence:: 1 / 0
