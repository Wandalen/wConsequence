
var _ = require( 'wTools' );
require( 'wConsequence' );

/*
  Task :
  Implement timeout for long-time routine.
*/

function routine()
{
  return _.timeOut( 3000, () => 'Done!' );
}

/* Solution with eitherGot */

var consequence = new wConsequence().give();
consequence.eitherGot([ routine(),_.timeOutError( 1500 ) ]);
consequence.got( ( err,arg ) => err ? _.errLog( err ) : console.log( arg ) );

console.log( 'Expected error is comming' );
