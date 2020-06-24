require( 'wTools' );
require( 'wConsequence' );

/* Solution - using same approach, but now timeOutThen runs our delayed task */

function taskWithDelay( delay, task )
{
  var con = new wConsequence();
  con.give();
  con.timeOutThen( delay, task );
  return con;
}

taskWithDelay( 1000, function()
{
  console.log( 'Message with delay' );
})

console.log( 'Message without delay' ); 