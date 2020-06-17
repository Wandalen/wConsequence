/* qqq : implement */
let _;

if( typeof module !== 'undefined' )
{
  _ = require( 'wTools' );
  require( 'wConsequence' );
}

let hydTotal = 100;
let oxTotal = 50;
const formedMolecules = [];

const waitingHyd = [];
const waitingOx = [];

let hyd = new _.Consequence();
let ox = new _.Consequence();

formedMolecules.push( [ Hydrogen(), Hydrogen(), Oxygen() ] );

//

function addHyd()
{
  waitingHyd.push( 'h' );
}

//

function addOx()
{
  waitingOx.push( 'o' );
}

//

function run( h, o )
{
  for( let i = 0; i < h; i++ )
  _.time.out( _.intRandom( [ 0, 10000 ] ), addHyd );

  for( let i = 0; i < o; i++ )
  _.time.out( _.intRandom( [ 0, 10000 ] ), addOx );
}

//

function Hydrogen()
{
  hyd.deasync();
  return hyd.sync();
}

//

function Oxygen()
{
  ox.deasync();
  return ox.sync();
}
