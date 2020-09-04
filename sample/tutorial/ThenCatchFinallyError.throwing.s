require( 'wConsequence' );
let _ = wTools;
let con = new _.Consequence();

// .then remains unused but will be deleted from the competitros queue too
con.then( ( arg ) => arg + '1' );
console.log( con ); // Consequence:: 0 / 1

// .catch recieves err passed with .error routine, then returns new error object that falls into .finally
con.catch( ( err ) =>
{
  _.errAttend( err );
  throw _.errBrief( 'catch : was error' )
});
console.log( con ); // Consequence:: 0 / 2


// since .catch returns error - .finally recieve it as err parameter
con.finally( ( err, arg ) => err ? 'finally : was error' : arg + '3' );
console.log( con ); // Consequence:: 0 / 3

// _.errAttend( 'Error!' ) - creating a processed error
con.error( _.errAttend( 'Error!' ) );
console.log( con ); // Consequence:: 1 / 0

console.log( con.argumentsGet() ); // [ 'finally : was error' ]

/* aaa : Artem done. add comments, add log output */
/* aaa : Artem done. make tutorial from this */
