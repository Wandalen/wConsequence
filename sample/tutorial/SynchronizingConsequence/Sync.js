let _ = require( 'wTools' );
require( 'wConsequence' );

/* custom synchronous function with callback */

function isEven( number, showResult )
{
  number % 2 ? showResult( _.errAttend( 'Number is not even!' ) ) : showResult( null, 'Іs even' );
}

/* with callback */

isEven( 14, ( err, result ) =>
{
  if( err )
    console.log( err );
  else
    console.log( result ); // logs: Іs even
});

/* with consequence */

var con = new _.Consequence();
isEven( 14, con );
console.log( con.sync() ); // logs: Іs even

var con = new _.Consequence();
isEven( 11, con )
console.log( con.sync() ); // logs error: Number is not even! and error log...

/*
Method `sync` unwrap consequence, effectively it looks like conversion to the original type.
In case of error call `sync()` will throw the error synchronously.
*/

/* aaa Artem : done. not found such, wrote my own. does not work ( demonstratively ) because of asynchronicity. please find synchronous nodejs routine with the same callback signature */
/* aaa Artem : done. use it for tutorial */
