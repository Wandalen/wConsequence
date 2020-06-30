let _ = require( 'wTools' );
require( 'wConsequence' );

var con = new _.Consequence();

// .take() passes the resource to the queue.
con.take( 'my resource1' );
console.log( con.resourcesGet().length ); // logs: 1

con.then( ( argument ) =>
{
  console.log( argument ); // logs: my resource1
  return 'from then';
} )

// right after the resource appears in the queue, the callback function that was passed
// to .thenGive()is invoked with this resource as a parameter
con.thenGive( ( argument ) => console.log( argument ) ); // logs: from then
console.log( con.resourcesGet().length ); // logs: 0
