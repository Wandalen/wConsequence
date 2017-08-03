
require( 'wTools' );
require( 'wConsequence' );

/* 
  Task :
  Implement timeout for long-time routine.
*/


/* Solution without consequence */

function runner( timeOut, routine )
{ 
  var isDone = false;
  var timer = setTimeout( function()
  {
    timer = null;
    if( !isDone )
    throw 'Timeout';
  }, timeOut );

  routine( function()
  {
    if( timer )
    { 
      isDone = true;
      clearTimeout( timer );
      console.log( 'Done' );
    }
  })
}

function routine( onDone )
{
  setTimeout( onDone, 3000 );
}

runner( 3000, routine );
