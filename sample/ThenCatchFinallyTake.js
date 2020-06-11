require( 'wConsequence' );
let _ = wTools;
let con = new _.Consequence();

con.then( ( arg ) => arg + '1' );
con.catch( ( err ) => 'catch : was error' );
con.finally( ( err, arg ) => err ? 'finally : was error' : arg + '3' );
console.log( con );
/* log : Consequence:: 0 / 3 */

con.take( 'arg' );
console.log( con.argumentsGet() );
/* log : [ 'arg13' ] */
console.log( con );
/* log : Consequence:: 1 / 0 */

/* qqq : add comments, add log output */
/* aaa Artem : done. make tutorial from this */
