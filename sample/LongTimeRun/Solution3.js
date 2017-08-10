
var _ = require( 'wTools' );
require( 'wConsequence' );

/*
  Task :
  Implement timeout for long-time routine.
*/

function routine()
{
  return _.timeOut( 13000, () => 'Done!' );
}

/* Solution with eitherGot and cancel of routine */

var routineFromConsequence = routine();

var consequence = new wConsequence().give();
consequence.eitherGot([ routineFromConsequence,_.timeOutError( 1500 ) ]);
consequence.got( function( err,arg )
{
  if( err )
  _.errLog( err );
  else
  console.log( arg );
  if( err )
  routineFromConsequence.error( err );
});

console.log( 'Expected error is comming' );
