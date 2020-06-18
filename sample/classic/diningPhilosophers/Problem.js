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

    source : https://en.wikipedia.org/wiki/Dining_philosophers_problem
*/
let _;

if( typeof module !== 'undefined' )
{
  _ = require( 'wTools' ); /* qqq : rid off all `var` */
}

let philosophers =
[
  { name : 1, delay : 1000, duration : 5000 },
  { name : 3, delay : 2000, duration : 4000 },
  { name : 2, delay : 2000, duration : 4000 },
  { name : 1, delay : 2500, duration : 2000 },

  { name : 1, delay : 11000, duration : 5000 },
  { name : 2, delay : 12000, duration : 4000 },
  { name : 1, delay : 12500, duration : 2000 },

  { name : 3, delay : 23000, duration : 8000 },
  { name : 4, delay : 21000, duration : 5000 },
  { name : 5, delay : 23000, duration : 4000 },
  { name : 1, delay : 27000, duration : 5000 },
  { name : 2, delay : 28000, duration : 7000 },
  { name : 3, delay : 24000, duration : 3000 },
  { name : 4, delay : 29000, duration : 1000 },
  { name : 5, delay : 26000, duration : 8000 },
  { name : 1, delay : 30000, duration : 2000 },
  { name : 2, delay : 31000, duration : 4000 },
  { name : 3, delay : 26000, duration : 5000 },
  { name : 4, delay : 43000, duration : 5000 },
  { name : 5, delay : 45000, duration : 1000 },

];

//

function simulateHungryEvent()
{
  let i = 0;
  let len = philosophers.length;
  let time = _.time.now();

  for( ; i < len; i++ )
  {
    let philosopher = philosophers[ i ];
    setTimeout(( function( philosopher )
    {
      let context = {};
      context.time = time;
      context.philosopher = philosopher;
      this.informAboutHungry( context );
    }).bind( this, philosopher ), philosopher.delay );
  }
}

//

function informAboutHungry( c )
{

  console.log( 'P' + c.philosopher.name + ' wants to eat at ' + _.time.spent( '', c.time ) ); /* qqq : rewrite how _.time.spent is used. use sleepingBarber as example */

}

//

let Self =
{
  informAboutHungry,
  simulateHungryEvent,
}

//

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
  if( !module.parent )
    Self.simulateHungryEvent();
}

/* qqq : rewrite */
