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

console.log( con.competitorsGet().length ); // logs: 0

/* */

var con = new _.Consequence();

con.thenGive( ( resource ) => console.log( resource ) );
console.log( con.competitorsGet()[ 0 ] ); // logs: { a lot of properties... }

con.competitorsGet()[ 0 ][ 'competitorRoutine' ]( 'from competitorRoutine prop' ); // logs: from competitorRoutine prop
con.take( 'my resource' ); // logs: my resource

/* */

var con = new _.Consequence();

// con.thenGive( ( resource ) => console.log( resource ) );

// if there is at least one competitor in the queue, the process will not stop, the consequence will be waiting for the resource
console.log( con.competitorsGet().length ); // logs: 1

// con.take( 'my resource' );
