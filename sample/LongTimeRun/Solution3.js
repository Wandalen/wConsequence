
var _ = require( 'wTools' );
require( 'wConsequence' );

/*
  Task :
  Implement timeout for long-time routine.
*/

/* Solution with eitherGot, without cancel */

function routine()
{
  var con = new wConsequence();
  con.give().timeOutThen( 15000, () => 'Done!' );
  return con;
}

var routineFromConsequence = routine();

var consequence = new wConsequence().give();
consequence.eitherGot([ routineFromConsequence,_.timeOutError( 1500 ) ]);
consequence.got( function( err,arg )
{
  console.log( err,arg );
  routineFromConsequence.cancel();
});

console.log( 'Expected error is comming' );
