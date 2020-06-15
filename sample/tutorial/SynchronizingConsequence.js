require( 'wConsequence' );
let _ = wTools;

var con = new _.Consequence({ capacity : 0 });

function isEven( number, showResult )
{
  number % 2 ? showResult( _.errAttend( 'Number is not even!' ) ) : showResult( 'Іs even' );
}

isEven( 14, con );

console.log( con.sync() ); // logs: Іs even

var con = new _.Consequence();

isEven( 11, con )

console.log( con.sync() ); // logs error: Number is not even! and error log...
