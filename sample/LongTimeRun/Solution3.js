
var _ = require( 'wTools' );
require( 'wConsequence' );

/*
  Task :
  Implement timeout for long-time routine.
*/

/* Solution 3 */

function routine()
{
  var con = new wConsequence();
  con.give().timeOutThen( 13000, () => console.log( 'Done!' ) );
  return con;
}

var consequence = new wConsequence().give();
// debugger;
// var a = [ routine(),_.timeOutError( 1500 ) ];
debugger;
consequence.eitherGot([ routine(),_.timeOutError( 1500 ) ]);

console.log( 'Expected error is comming' );
