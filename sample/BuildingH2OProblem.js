/*
 * Create a monitor with methods Hydrogen() and Oxygen(), which wait until a water molecule can be formed and then return.
 * Don’t worry about explicitly creating the water molecule; just wait until two hydrogen threads and one oxygen thread
 * can be grouped together. For example, if two threads call Hydrogen, and then a third thread calls Oxygen, the third
 * thread should wake up the first two threads and they should then all return.
 *
 * source: https://inst.eecs.berkeley.edu/~cs162/sp10/hand-outs/synch-problems.html
 */

if( typeof module !== 'undefined' )
{
  var _ = require( 'wTools' );
}

var elementsAppendList =
[
  { element: 'H', delay: 500 },
  { element: 'H', delay: 1000 },
  { element: 'H', delay: 1500 },
  { element: 'O', delay: 2000 },
  { element: 'O', delay: 2500 },
  { element: 'H', delay: 3000 },
  { element: '0', delay: 3500 },
  { element: 'H', delay: 4000 },
  { element: 'H', delay: 4500 },
  { element: '0', delay: 5000 },
  { element: 'H', delay: 5500 },
  { element: 'H', delay: 6000 },
];

var waitingH = 0,
    waitingO = 0,
    molecule = 0;

function appendElement()
{

  var i = 0,
    len = elementsAppendList.length,
    time = _.timeNow();


  for( ; i < len; i++ )
  {
    var element = elementsAppendList[ i ].element;

    setTimeout( ( function( element )
    {
      console.log( ' element append ' + element + ' at ' + _.timeSpent( ' ',time ) );
      if( element === 'O' )
      {
        oxygen()
      }
      else if ( element === 'H' )
      {
        hydrogen()
      }
    }).bind( this, element ),  elementsAppendList[ i ].delay );
  }
}

function oxygen() {
  waitingH++;
  createWaterMolecule();
}

function hydrogen() {
  waitingO++;
  createWaterMolecule();
}

function createWaterMolecule() {
  if( waitingO >= 1 && waitingH >= 2 ) {
    molecule++;
    console.log( 'water molecule # ' + molecule + ' creating' );
  }
}

var Self =
{
  appendElement : appendElement,
  createWaterMolecule : createWaterMolecule,
  oxygen : oxygen,
  hydrogen : hydrogen,
};

//

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
  if( !module.parent )
    Self.appendElement();
}