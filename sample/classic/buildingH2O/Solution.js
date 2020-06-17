/* qqq : implement */
let _;

if( typeof module !== 'undefined' )
{
  _ = require( 'wTools' );
  require( 'wConsequence' );
}

let hydTotal = 100;
let oxTotal = 50;
const molecul = _.Consequence({ capacity : 0 });

run( hydTotal, oxTotal );

//

function run( h, o )
{
  for( let i = 0; i < h; i++ )
  Hydrogen();

  for( let i = 0; i < o; i++ )
  Oxygen();
}

//

function Hydrogen()
{
  return _.time.out( _.intRandom( [ 0, 10000 ] ), () =>
  {
    molecul.take( 'h' );
    molecul.thenGive( ( atom ) =>
    {
      console.log( atom );
    } )
  } )
}

//

function Oxygen()
{
  return _.time.out( _.intRandom( [ 0, 10000 ] ), () =>
  {
    molecul.take( 'o' );
    molecul.thenGive( ( atom ) =>
    {
      console.log( atom );
    } )
  } )
}
