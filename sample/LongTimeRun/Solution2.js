
require( 'wTools' );
require( 'wConsequence' );

/*
  Task :
  Implement timeout for long-time routine.
*/

/* Solution with conseuqence */

longTimeRun.give();
longTimeRun.timeOutThen( 3000, () => console.log( 'Done!' ) );
longTimeRun.eitherThenSplit( wTools.timeOutError( 1500 ) )

console.log( 'Expected error is comming' );
