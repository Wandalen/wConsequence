/* aaa Artem : done. implement */
let _;

if( typeof module !== 'undefined' )
{
  _ = require( 'wTools' );
  require( 'wConsequence' );
}

let hydTotal = 20;
let oxTotal = 10;
const formedMolecules = [];
const startTime = _.time.now();

const waitingAtoms = { hyd : 0, ox : 0 }

let hyd = new _.Consequence();
let ox = new _.Consequence();
let con = new _.Consequence().take( null );

run( hydTotal, oxTotal );

let l = hydTotal / 2 < oxTotal ? hydTotal / 2 : oxTotal;
for( let i = 0; i < l; i++ )
con.then( () =>
{
  formedMolecules.push( [ Hydrogen(), Hydrogen(), Oxygen() ] );
  console.log( `+ new molecule was formed - ${status()}` );
  console.log();
  hyd = new _.Consequence();
  ox = new _.Consequence();
  return null;
} );

//

function status()
{
  return `time: ${_.time.spent( startTime )}, molecules: ${formedMolecules.length}, hydrogen: ${waitingAtoms.hyd}, oxygen: ${waitingAtoms.ox}`;
}

//

function formMolecule()
{
  hyd.take( 'h' );
  ox.take( 'o' );

  waitingAtoms.hyd -= 2;
  waitingAtoms.ox -= 1;
}

//

function run( h, o )
{
  for( let i = 1; i <= h; i++ )
  _.time.out( 1250 * i, addHyd );

  for( let i = 1; i <= o; i++ )
  _.time.out( 1750 * i, addOx );
}

//

function addHyd()
{
  waitingAtoms.hyd += 1;
  console.log( `+ hydrogen - ${status()}` );

  if( waitingAtoms.hyd >= 2 && waitingAtoms.ox )
  formMolecule();
}

//

function addOx()
{
  waitingAtoms.ox += 1;
  console.log( `+ oxygen - ${status()}` );

  if( waitingAtoms.hyd >= 2 )
  formMolecule();
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
