require( 'wConsequence' );
let _ = wTools;
let con = new _.Consequence();

con.then( ( arg ) => arg + '1' );
// con.catch( ( err ) => 'catch : was error' );
con.catch( ( err ) => { throw _.errAttend( 'catch : was error' ) } );
con.finally( ( err, arg ) => err ? 'finally : was error' : arg + '3' );
console.log( con );
/* log : Consequence:: 0 / 3 */

con.error( _.errAttend( 'Error!' ) );
console.log( con.argumentsGet() );
/* log : [ 'catch : was error' ] */

/* qqq : add comments, add log output */
/* qqq : make tutorial from this */
