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
  informAboutHungry :
  {
    value : function( c )
    {
      console.log( '>>' );
      console.log( 'philosopher want to eat : ' + c.philosopher.name + _.timeSpent( ' ',c.time ) );
      tryToEat( c );
    }
  }
} );

var theDiningPhilosophersProblem = new STheDiningPhilosophersProblem();
theDiningPhilosophersProblem.simulateHungryEvent();

var forks =
[
  wConsequence().give(),
  wConsequence().give(),
  wConsequence().give(),
  wConsequence().give(),
  wConsequence().give(),
];

function tryToEat(c)
{
  // draft
  var name = c.philosopher.name;
  takeFork(forks[ name - 1 ] );
  takeFork(forks[ name % 5 ] );
  eat( c.philosopher.duration );

  putFork(forks[ name - 1 ] );
  putFork(forks[ name % 5 ] );

}

function takeFork(fork) {
  return fork.got();
}

function putFork(fork) {
  return fork.give();
}

function eat( duration ) {}
