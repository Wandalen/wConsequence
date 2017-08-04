/* 
  Task :
  Implement delay routine to run code with provided delay.
*/

/* Solution without consequence */

function runWithDelay( delay, routine )
{
  setTimeout( routine, delay );
}

function routine()
{
    console.log( 'Message with delay' );
}

runWithDelay( 1000, routine );
console.log( 'Message without delay' );