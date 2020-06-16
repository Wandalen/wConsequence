require( 'wConsequence' );
let _ = wTools;

// The `capacity` option indicates the maximum number of resources in the resource queue at a time, by default 1
// if `capacity` : 0 - not limited
var con = new _.Consequence({ capacity : 2 });

con.take( 'a' );
con.take( 'b' );

console.log( con );
/* log : Consequence:: 2 / 0 */

console.log( con.argumentsGet() );
/* log : [ 'a', 'b' ] */

// competitors with `Keep` suffix or without - take and delete resource from queue,
// but after processing - return resource to the queue, but not to the previous place but to the beginning of the queue
con.then( ( arg ) => arg + '2' );
console.log( con.argumentsGet() );
/* log : [ 'b', 'a2' ] */

con.thenKeep( ( arg ) => arg + '3' );
console.log( con.argumentsGet() );
/* log : [ 'a2', 'b3' ] */

// competitors with `Give` suffix take and delete resource from queue,
// but after processing - don't return resource to the queue
con.thenGive( ( arg ) => arg + '4' );
console.log( con.argumentsGet() );
/* log : [ 'b3' ] */

con.thenGive( ( arg ) => console.log( arg ) );
/* log : 'b3' */

console.log( con.argumentsGet() );
/* log : [] */

// /* alternatively */
//
// con.thenKeep( ( arg ) => console.log( arg ) || null );
// /* log : 'b3' */
// console.log( con.argumentsGet() );
// /* log : error */
/* qqq : explain this in details */

/* aaa Artem : done. add comments, add log output */
/* aaa Artem : done. make tutorial from this */
