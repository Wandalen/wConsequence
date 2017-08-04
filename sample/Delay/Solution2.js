require( 'wTools' );
require( 'wConsequence' );

/* Solution - routine that returns consequence that gives message with delay */

function delay( delay )
{
  var con = new wConsequence();
  setTimeout( () => { con.give() }, delay );
  return con;
}

delay( 1000 )
.got( function()
{
  console.log( 'Message with delay' );  
});

console.log( 'Message without delay' );  