require( 'wConsequence' );
let _ = wTools;
let con = new _.Consequence();

// .then remains unused but will be deleted from the competitros queue too
con.then( ( arg ) => arg + '1' );

// .catch recieves err passed with .error routine, then returns new error object that falls into .finally
con.catch( ( err ) => { throw _.errAttend( 'catch : was error' ) } );

// since .catch returns error - .finally recieve it as err parameter
con.finally( ( err, arg ) => err ? 'finally : was error' : arg + '3' );
console.log( con );
/* log : Consequence:: 0 / 3 */

// _.errAttend( 'Error!' ) - creating a processed error
con.error( _.errAttend( 'Error!' ) );

console.log( con.argumentsGet() );
/* log : [ 'catch : was error' ] */

/* aaa : Artem done. add comments, add log output */
/* aaa : Artem done. make tutorial from this */
