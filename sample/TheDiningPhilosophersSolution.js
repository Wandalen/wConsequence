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
      console.log( 'philosopher ' + c.philosopher.name + ' wants to eat at ' + _.timeSpent( ' ',c.time ) );
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

//

function tryToEat(c)
{
  // draft
  //var eventSequence = wConsequence();

  var name = c.philosopher.name;

  //eventSequence.and( [ leftFork, rightFork ] ).then_(

  forkFor( name,0 )
  .and( forkFor( name,1 ) )
  .then_( function()
  {

    console.log( 'p' + c.philosopher.name + ' started eating.' );
    console.log( forkFor( name,0 ).toStr() );
    console.log( forkFor( name,1 ).toStr() );

  })
  .thenTimeOut( c.philosopher.duration,function()
  {

    console.log( 'p' + c.philosopher.name + ' stopped eating.' );

  });

/*
  function()
  {
    takeFork( name,0 );
    takeFork( name,1 );
    console.log( 'p' + c.philosopher.name + ' started eating.' );
  }).thenTimeOut( c.philosopher.duration,function()
  {

    console.log( 'p' + c.philosopher.name + ' stopped eating.' );
    putFork( name,0 );
    putFork( name,1 );

  }).give();
*/

}

//

function forkFor( name,right )
{
  var i = right ? name % 5 : name - 1;

  i = right;

  var fork = forks[ i ];
  console.log( 'p' + name + ' interested in ' + ( right ? 'right' : 'left' ) + ' fork' + ( i+1 ) );
  return fork;
}

//

function eat(  )
{
  return true;
}
