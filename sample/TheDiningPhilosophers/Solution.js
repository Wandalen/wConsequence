/**
 * @file This sample demonstrates using wConsequence for synchronization the several asynchronous process by example of
 * sleeping barber problem. In this example appending clients in barber shop and servicing them by barber are
 * asynchronous.
 */

if( typeof module !== 'undefined' )
{
  var _ = require( 'wTools' );
  /* require( 'wConsequence' ); */
  require( '../../staging/abase/syn/Consequence.s' );
  var TheDiningPhilosophersProblem = require( './TheDiningPhilosophersProblem.js' );
}

//

TheDiningPhilosophersProblem.informAboutHungry = function( c )
{

  var name = c.philosopher.name;

  console.log( '' );
  console.log( 'P' + c.philosopher.name + ' wants to eat at ' + _.timeSpent( '',c.time ) );

  tryToEat( c );

}

//

var forks =
[
  wConsequence({ name : 'F1' }).give(),
  wConsequence({ name : 'F2' }).give(),
  wConsequence({ name : 'F3' }).give(),
  wConsequence({ name : 'F4' }).give(),
  wConsequence({ name : 'F5' }).give(),
];

//

function tryToEat( c )
{

  var name = c.philosopher.name;
  var forks = [ forkFor( name,0 ),forkFor( name,1 ) ];
  var con = wConsequence().give();

  con.andGet( forks )
  .thenDo( function eating()
  {

    console.log( 'P' + c.philosopher.name + ' got both forks and started eating at ' + _.timeSpent( '',c.time ) );

  })
  .thenTimeOut( c.philosopher.duration,function satisfied()
  {

    console.log( 'P' + c.philosopher.name + ' stopped eating at ' + _.timeSpent( '',c.time ) );
    wConsequence.give( forks,null );

  });

}

//

function forkFor( name,right )
{
  var i = right ? name % 5 : name - 1;
  var fork = forks[ i ];
  console.log( 'P' + name + ' interested in ' + ( right ? 'right' : 'left' ) + ' fork' + ( i+1 ) );
  return fork;
}

//

var Self =
{
  forks : forks,
  tryToEat : tryToEat,
  forkFor : forkFor,
}

//

TheDiningPhilosophersProblem.simulateHungryEvent();
