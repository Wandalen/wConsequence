/**
 * @file This sample demonstrates using wConsequence for synchronization the several asynchronous process by example of
 * sleeping barber problem. In this example appending clients in barber shop and servicing them by barber are
 * asynchronous.
 */

if( typeof module !== 'undefined' )
{
  var _ = require( 'wTools' );
  /* require( 'wConsequence' ); */
  require( '../staging/abase/syn/Consequence.s' );
  var TheDiningPhilosophersProblem = require( './TheDiningPhilosophersProblem.js' );
}

var con = new wConsequence();

function STheDiningPhilosophersProblem () {};

STheDiningPhilosophersProblem.prototype = Object.create( TheDiningPhilosophersProblem, {
  informAboutHungry:
  {
    value: function( c ) {
      console.log( '=>>' );
      console.log( 'philosopher want to eat : ' + c.philosopher.name + _.timeSpent( ' ',c.time ) );
      con.give(c);
    }
  }
} );

var theDiningPhilosophersProblem = new STheDiningPhilosophersProblem();
theDiningPhilosophersProblem.simulateHungryEvent();

var forks = [
  { name : 1, status : 'free' },
  { name : 2, status : 'free' },
  { name : 3, status : 'free' },
  { name : 4, status : 'free' },
  { name : 5, status : 'free' },
];

