/*
 Dining Philosophers problem

  * Problem statement:
    - Five silent philosophers sit at a round table with bowls of spaghetti. Forks are placed between each pair of
    adjacent philosophers.

    - Each philosopher must alternately think and eat. However, a philosopher can only eat spaghetti when he has both
    left and right forks. Each fork can be held by only one philosopher and so a philosopher can use the fork only if
    it is not being used by another philosopher. After he finishes eating, he needs to put down both forks so they become
    available to others. A philosopher can take the fork on his right or the one on his left as they become available,
    but cannot start eating before getting both of them.

    - Eating is not limited by the remaining amounts of spaghetti or stomach space;
    an infinite supply and an infinite demand are assumed.

    - The problem is how to design a discipline of behavior such that no philosopher will starve; i.e., each can forever
    continue to alternate between eating and thinking, assuming that no philosopher can know when others may want to eat
    or think.

    source: https://en.wikipedia.org/wiki/Dining_philosophers_problem
 */

if( typeof module !== 'undefined' )
{
  var _ = require( 'wTools' );
  /* require( 'wConsequence' ); */
  require( '../staging/abase/syn/Consequence.s' );
}

var philosophers =
  [
    { name : 'p1', delay: 560 },
    { name : 'p2', delay: 750 },
    { name : 'p3', delay: 160 },
    { name : 'p4', delay: 560 },
    { name : 'p5', delay: 340 },
  ];

//

function simulateHungryEvent()
{
  var i = 0,
    len = philosophers.length;

  for( ; i < len; i++ )
  {
    var philosopher = philosophers[ i ];
    setTimeout(( function( philosopher )
    {
      /* sending clients to shop */
      informAboutHungry( philosopher );
    }).bind( null, philosopher ), philosopher.delay );
  }
}

//
var time = _.timeNow();

function informAboutHungry( philosopher )
{

  console.log( 'philosopher want to eat : ' + philosopher.name + _.timeSpent( ' ',time ) );

};

/* send clients to barber shop. */

simulateHungryEvent();