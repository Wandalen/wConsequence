if( typeof module !== 'undefined' )
var _ = require( '..' );

let con = someRoutine();
con.then( () =>
{
  console.log( 'then:', got )
  return null();
})

return con;

/* */

function someRoutine()
{
  let con = new _.Consequence();
  con.finallyKeep( end );

  let competitor = con.competitorHas( end );
  competitor.procedure.end();

  return con;

  function end( err, got )
  {
    console.log( 'end:', got )
    return got;
  }
}