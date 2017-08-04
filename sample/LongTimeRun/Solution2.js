
var _ = require( 'wTools' );
require( 'wConsequence' );

/*
  Task :
  Implement timeout for long-time routine.
*/

/* Solution with eitherGot */

function routine()
{
  var con = new wConsequence();
  con.give().timeOutThen( 5000, () => 'Done!' );
  return con;
}

var consequence = new wConsequence().give();
consequence.eitherGot([ routine(),_.timeOutError( 1500 ) ]);
consequence.got( ( err,arg ) => console.log( err,arg ) );

console.log( 'Expected error is comming' );
