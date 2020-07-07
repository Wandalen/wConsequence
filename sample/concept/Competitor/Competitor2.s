let _ = require( 'wTools' );
require( 'wConsequence' );

var con = new _.Consequence();

con.thenGive( ( resource ) => console.log( resource ) );
console.log( con.competitorsGet().length ); // logs: 1

con.competitorsGet()[ 0 ][ 'competitorRoutine' ]( 'from competitorRoutine prop' ); // logs: from competitorRoutine prop
con.take( 'my resource' ); // logs: my resource
