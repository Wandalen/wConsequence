
require( 'wTools' );
require( 'wConsequence' );

/* 
  Task :
  Implement timeout for long-time routine.
*/


/* Solution without consequence */

function longTimeRoutine()
{ 
  var done = false;
  var timeOut = setTimeout( function()
  {
    timeOut = null;
    if( !done )
    throw 'Timeout';
  }, 1500 );

  setTimeout( function()
  {
    if( timeOut )
    {
      clearTimeout( timeOut );
      console.log( 'Done' );
    }
  }, 3000 );
}

longTimeRoutine();

// /* Solution 1 */

// function longTimeRoutine()
// { 
//   var longTimeRun = new wConsequence();
//   longTimeRun.give();
//   longTimeRun.timeOutThen( 3000, () => console.log( 'Done!' ) );
//   longTimeRun.eitherThenSplit( wTools.timeOutError( 1500 ) )
//   return longTimeRun;
// }

// longTimeRoutine();


// /* Solution 2 */

// function runner( routine, timeout )
// { 
//   var runner = new wConsequence();
//   runner.eitherThenSplit([ routine(), wTools.timeOutError( timeout ) ]);
//   return runner;
// }

// function routine()
// {
//   var longTimeRun = new wConsequence();
//   longTimeRun.give();
//   longTimeRun.timeOutThen( 3000, () => console.log( 'Done!' ) );
//   return longTimeRun;
// }

// runner( routine, 1500 );


