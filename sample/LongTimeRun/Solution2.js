
require( 'wTools' );
require( 'wConsequence' );

/* 
  Task :
  Implement timeout for long-time routine.
*/

/* Solution with conseuqence */

// function longTimeRoutine()
// { 
//   var longTimeRun = new wConsequence();
//   longTimeRun.give();
//   longTimeRun.timeOutThen( 3000, () => console.log( 'Done!' ) );
//   longTimeRun.eitherThenSplit( wTools.timeOutError( 1500 ) )
//   return longTimeRun;
// }

// longTimeRoutine();

var watcher = new wConsequence();

function longTimeRoutine()
{ 
  wTools.timeOut( 3000, () => watcher.give( 'Done' ) );
}

function timer()
{ 
  wTools.timeOut( 1500, () => watcher.error( 'Timeout' ) );
}

timer();
longTimeRoutine();

watcher
.got( ( err, got ) =>
{ 
  if( err )
  throw err;
  else 
  console.log( got );
})