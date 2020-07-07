/*
 * Create a monitor with methods Hydrogen() and Oxygen(), which wait until a water molecule can be formed and then return.
 * Don’t worry about explicitly creating the water molecule; just wait until two hydrogen threads and one oxygen thread
 * can be grouped together. For example, if two threads call Hydrogen, and then a third thread calls Oxygen, the third
 * thread should wake up the first two threads and they should then all return.
 *
 * source : https://inst.eecs.berkeley.edu/~cs162/sp10/hand-outs/synch-problems.html
*/
let _;

if( typeof module !== 'undefined' )
{
  _ = require( 'wTools' );
  require( 'wConsequence' );
}

const startTime = _.time.now();

//

let Self =
{
  run,
  addHyd,
  addOx
}

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
  if( !module.parent )
  Self.run( 20, 10 );
}

//

function run( h, o )
{
  for( let i = 1; i <= h; i++ )
  _.time.out( 1250 * i, () => this.addHyd() );

  for( let i = 1; i <= o; i++ )
  _.time.out( 1750 * i, () => this.addOx() );
}

//

function addHyd()
{
  /* a new hydrogen atom appears */
  console.log( `+ hydrogen - ${_.time.spent( startTime )}` );
}

//

function addOx()
{
  /* a new oxygen atom appears */
  console.log( `+ oxygen - ${_.time.spent( startTime )}` );
}

/* aaa Artem : done. implement */
