let _ = require( 'wTools' );
require( 'wConsequence' );

var con = new _.Consequence();

con.thenGive( ( resource ) => console.log( resource ) );

// if there is at least one competitor in the queue, the process will not stop, the consequence will be waiting for the resource
console.log( con.competitorsGet().length ); // logs: 1

var startTime = _.time.now();
_.time.out( 5000 ).then( () =>
{
  con.take( 'my resource' );
  console.log( `Time spented waiting for resource : ${_.time.spent( startTime )}` );
  return null;
});
