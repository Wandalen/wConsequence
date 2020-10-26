require( 'wTools' );
require( 'wConsequence' );

/* Solution - using same approach, but now thenDelay runs our delayed task */

function taskWithDelay( delay, task )
{
  var con = new wConsequence();
  con.thenDelay( delay ).then( () => task() || null );
  con.take( task );
  return con;
}

taskWithDelay( 1000, function()
{
  console.log( 'Message with delay' );
})

console.log( 'Message without delay' );
