require( 'wTools' );
require( 'wConsequence' );

/* Solution - using same approach, but now time.outThen runs our delayed task */

function taskWithDelay( delay, task )
{
  var con = new _.Consequence();
  con.take();
  con.time.outThen( delay, task );
  return con;
}

taskWithDelay( 1000, function()
{
   console.log( 'Message with delay' );
})

console.log( 'Message without delay' ); 