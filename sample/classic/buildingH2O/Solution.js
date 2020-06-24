/**
 * @file This sample demonstrates using wConsequence for synchronization the several asynchronous process by example of
 * 'BuildingH2O'. In this example the appearance of hydrogen and oxygen is asynchronous.
*/

let _,
  Problem;

if( typeof module !== 'undefined' )
{
  _ = require( 'wTools' );
  require( 'wConsequence' );
  Problem = require( './Problem.js' );
}

let hydTotal = 20;
let oxTotal = 10;
const formedMolecules = [];
const startTime = _.time.now();

const waitingAtoms = { hyd : 0, ox : 0 }

let hyd = new _.Consequence();
let ox = new _.Consequence();
let con = new _.Consequence().take( null );

Problem.addHyd = addHyd;
Problem.addOx = addOx;
Problem.run( hydTotal, oxTotal );

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
});

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

/* aaa Artem : done. implement */
