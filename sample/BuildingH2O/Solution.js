if( typeof module !== 'undefined' )
{
  var _ = require( 'wTools' );
  /* require( 'wConsequence' ); */
  require( '../../staging/dwtools/abase/oclass/Consequence.s' );
  var H2OProblem = require( './Problem.js' );
}

var waitingH = wConsequence(),
  molecule = 0;

function oxygen()
{
  console.log('oxy');
  waitingH.got();
  waitingH.got( this.createWaterMolecule );
}

function hydrogen()
{
  console.log('hidro');
  waitingH.give();
}

function createWaterMolecule() {
  molecule++;
  console.log( 'water molecule # ' + molecule + ' creating' );
}

//

function H2OSolution()
{
  this.oxygen = oxygen;
  this.hydrogen = hydrogen;
  this.createWaterMolecule = createWaterMolecule;
}



H2OSolution.prototype = H2OProblem;
H2OSolution.prototype.constructor = H2OSolution;
var h2OSolution = new H2OSolution();
h2OSolution.appendElements();