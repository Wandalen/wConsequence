require( 'wConsequence' );
let _ = wTools;
let con = new _.Consequence();

// .then remains unused but will be deleted from the competitros queue too
con.then( ( arg ) => arg + '1' );

// competitor .catch handles resource-error that was passed with .error( error object ), should return smth
con.catch( ( err ) => 'catch : was error' );

// competitor .finally can handles both the resource argument and the resource error, should return smth
// since .catch returns not error - .finally recieve it as arg parameter
con.finally( ( err, arg ) => err ? 'finally : was error' : arg + '3' );
console.log( con );
/* log : Consequence:: 0 / 3 */

con.take( 'arg' );
console.log( con.argumentsGet() );
/* log : [ 'arg13' ] */

console.log( con );
/* log : Consequence:: 1 / 0 */

/* aaa Artem : done. add comments, add log output */
/* aaa Artem : done. make tutorial from this */
