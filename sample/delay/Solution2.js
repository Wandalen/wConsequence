require( 'wTools' );
require( 'wConsequence' );

/* Solution - routine that returns consequence that takes message with delay */

function delay( delay )
{
  var con = new _.Consequence();
  setTimeout( () => { con.take() }, delay );
  return con;
}

delay( 1000 )
.got( function()
{
  console.log( 'Message with delay' );  
});

console.log( 'Message without delay' );  