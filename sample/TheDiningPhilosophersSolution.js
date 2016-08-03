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
  var diningPhilosopers = require( './TheDiningPhilosophersProblem.js' );
}

diningPhilosopers.simulateHungryEvent();
