require( 'wConsequence' );
let _ = wTools;
let con = new _.Consequence({ capacity : 0 });

con.then( ( arg ) => arg + '1' );
con.then( ( arg ) => arg + '2' );
con.then( ( arg ) => arg + '3' );
console.log( con.argumentsGet() );
/* log : [] */
console.log( con );
/* log : Consequence:: 0 / 3 */

con.take( 'a' );
console.log( con.argumentsGet() );
/* log : [ 'a123' ] */
console.log( con );
/* log : Consequence:: 2 / 0 */

con.take( 'b' );
console.log( con.argumentsGet() );
/* log : [ 'a', 'b' ] */
console.log( con );
/* log : Consequence:: 2 / 0 */

/* qqq : add comments, add log output */
/* qqq : make tutorial from this */
