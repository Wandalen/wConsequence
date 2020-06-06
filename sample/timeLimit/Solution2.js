
var _ = require( 'wTools' );
require( 'wConsequence' );

/*
  Task :
  Implement timeout for long-time routine.
*/

function routine()
{
  return _.time.out( 3000, () => 'Done!' );
}

/* Solution with eitherGot */

var consequence = new _.Consequence().take();
consequence.eitherGot([ routine(),_.time.outError( 1500 ) ]);
consequence.got( ( err,arg ) => err ? _.errLog( err ) : console.log( arg ) );

console.log( 'Expected error is comming' );
