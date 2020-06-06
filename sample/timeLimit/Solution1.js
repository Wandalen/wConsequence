
require( 'wTools' );
require( 'wConsequence' );

/*
  Task :
  Implement timeout for long-time routine.
*/

/* Solution without consequence */

function routine( onDone )
{
  setTimeout( onDone, 3000 );
}

function runner( time.out, routine )
{
  var isDone = false;

  var timer = setTimeout( function()
  {
    timer = null;
    if( !isDone )
    throw 'Timeout';
  }, time.out );

  routine( function()
  {
    if( timer )
    {
      isDone = true;
      clearTimeout( timer );
      console.log( 'Done' );
    }
  });

}

console.log( 'Expected error is comming' );

runner( 3000, routine );
