
require( 'wTools' );
require( 'wConsequence' );

/* 
  Task :
  Implement timeout for long-time routine.
*/

/* Solution 3 */

function runner( routine, timeout )
{ 
  var runner = new wConsequence();
  runner.eitherThenSplit([ routine(), wTools.timeOutError( timeout ) ]);
  return runner;
}

function routine()
{
  var longTimeRun = new wConsequence();
  longTimeRun.give();
  longTimeRun.timeOutThen( 3000, () => console.log( 'Done!' ) );
  return longTimeRun;
}

runner( routine, 1500 );
