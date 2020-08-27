require( 'wConsequence' );
let _ = wTools;
let con = new _.Consequence();

// .then remains unused but will be deleted from the competitros queue too
con.then( ( arg ) => arg + '1' );
console.log( con ); // Consequence:: 0 / 1

// competitor .catch handles resource-error that was passed with .error( error object ), should return smth
con.catch( ( err ) =>
{
  _.errAttend( err );
  return 'catch : was error';
});
console.log( con ); // Consequence:: 0 / 2

// competitor .finally can handles both the resource argument and the resource error, should return smth
// since .catch returns not error - .finally recieve it as arg parameter
con.finally( ( err, arg ) => err ? 'finally : was error' : arg + '3' );
console.log( con ); // Consequence:: 0 / 3

con.take( 'arg' );
console.log( con ); // Consequence:: 1 / 0
console.log( con.argumentsGet() ); // [ 'arg13' ]

/* aaa Artem : done. add comments, add log output */
/* aaa Artem : done. make tutorial from this */
