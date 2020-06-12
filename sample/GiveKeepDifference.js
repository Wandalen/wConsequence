require( 'wConsequence' );
let _ = wTools;
let con = new _.Consequence({ capacity : 2 });

con.take( 'a' );
con.take( 'b' );
console.log( con );
/* log : Consequence:: 2 / 0 */

console.log( con.argumentsGet() );
/* log : [ 'a', 'b' ] */

con.then( ( arg ) => arg + '2' );
console.log( con.argumentsGet() );
/* log : [ 'b', 'a2' ] */

con.thenKeep( ( arg ) => arg + '3' );
console.log( con.argumentsGet() );
/* log : [ 'a2', 'b3' ] */

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

/* qqq : add comments, add log output */
/* qqq : make tutorial from this */
