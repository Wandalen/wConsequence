let _ = require( 'wTools' );
require( 'wConsequence' );

var con = new _.Consequence();

// .competitorsGet() returns an array of competitors
console.log( con.competitorsGet().length ); // logs: 0

con.then( ( resource ) =>
{
  console.log( resource );
  return 'new resource from then';
} );

con.thenGive( ( resource ) => console.log( resource ) );

console.log( con.competitorsGet().length ); // logs: 2

con.take( 'my resource' );
// logs: my resource
// logs: new resource from then

console.log( con.competitorsGet().length ); // logs: 0
