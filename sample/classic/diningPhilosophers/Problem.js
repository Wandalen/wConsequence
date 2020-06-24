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
  _ = require( 'wTools' );
  require( 'wConsequence' );
}

const startTime = _.time.now();

const fork1 = { id : 1, isAvailable : true }
const fork2 = { id : 2, isAvailable : true }
const fork3 = { id : 3, isAvailable : true }
const fork4 = { id : 4, isAvailable : true }
const fork5 = { id : 5, isAvailable : true }

const forks = [ fork1, fork2, fork3, fork4, fork5 ];

const philosophers =
[
  {
    id : 1,
    name : 'Plato',
    isEating : false,
    isHungry : false,
    leftFork : fork5,
    rightFork : fork1,
    leftHand : null,
    rightHand : null,
    getHungry : 2500,
    eatingTime : 5000
  },
  {
    id : 2,
    name : 'Aristotle',
    isEating : false,
    isHungry : false,
    leftFork : fork1,
    rightFork : fork2,
    leftHand : null,
    rightHand : null,
    getHungry : 4500,
    eatingTime : 5000
  },
  {
    id : 3,
    name : 'Heraclitus',
    isEating : false,
    isHungry : false,
    leftFork : fork2,
    rightFork : fork3,
    leftHand : null,
    rightHand : null,
    getHungry : 6500,
    eatingTime : 5000
  },
  {
    id : 4,
    name : 'Diogenes',
    isEating : false,
    isHungry : false,
    leftFork : fork3,
    rightFork : fork4,
    leftHand : null,
    rightHand : null,
    getHungry : 5000,
    eatingTime : 5000
  },
  {
    id : 5,
    name : 'Cicero',
    isEating : false,
    isHungry : false,
    leftFork : fork4,
    rightFork : fork5,
    leftHand : null,
    rightHand : null,
    getHungry : 3500,
    eatingTime : 5000
  }
];

//

let Self =
{
  run,
  getHungry,
  forks,
  philosophers
}

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
  if( !module.parent )
  Self.run( 1 );
}

//

function run( k )
{
  console.log( `Сycle ${k}:` );
  for( let i = 0; i < philosophers.length; i++ )
  {
    const ph = philosophers[ i ];
    _.time.out( ph.id === 1 || ph.id === 3 ? ph.getHungry * k : ph.getHungry, () => this.getHungry( ph ) );
  }

  if( k === 1 )
  _.time.out( 20000, () => this.run( 2 ) );
}

//

function getHungry( ph )
{
  /* a philosopher is hungry */
  console.log( `+ ph_${ph.id} is hungry - ${_.time.spent( startTime )}` );
}

/* aaa Artem : done. rewrite */

/* */

// let _;

// if( typeof module !== 'undefined' )
// {
//   _ = require( 'wTools' ); /* aaa Artem : done. rid off all `var` */
// }

// let philosophers =
// [
//   { name : 1, delay : 1000, duration : 5000 },
//   { name : 3, delay : 2000, duration : 4000 },
//   { name : 2, delay : 2000, duration : 4000 },
//   { name : 1, delay : 2500, duration : 2000 },

//   { name : 1, delay : 11000, duration : 5000 },
//   { name : 2, delay : 12000, duration : 4000 },
//   { name : 1, delay : 12500, duration : 2000 },

//   { name : 3, delay : 23000, duration : 8000 },
//   { name : 4, delay : 21000, duration : 5000 },
//   { name : 5, delay : 23000, duration : 4000 },
//   { name : 1, delay : 27000, duration : 5000 },
//   { name : 2, delay : 28000, duration : 7000 },
//   { name : 3, delay : 24000, duration : 3000 },
//   { name : 4, delay : 29000, duration : 1000 },
//   { name : 5, delay : 26000, duration : 8000 },
//   { name : 1, delay : 30000, duration : 2000 },
//   { name : 2, delay : 31000, duration : 4000 },
//   { name : 3, delay : 26000, duration : 5000 },
//   { name : 4, delay : 43000, duration : 5000 },
//   { name : 5, delay : 45000, duration : 1000 },

// ];

// //

// function simulateHungryEvent()
// {
//   let i = 0;
//   let len = philosophers.length;
//   let time = _.time.now();

//   for( ; i < len; i++ )
//   {
//     let philosopher = philosophers[ i ];
//     setTimeout(( function( philosopher )
//     {
//       let context = {};
//       context.time = time;
//       context.philosopher = philosopher;
//       this.informAboutHungry( context );
//     }).bind( this, philosopher ), philosopher.delay );
//   }
// }

// //

// function informAboutHungry( c )
// {

//   console.log( 'P' + c.philosopher.name + ' wants to eat at ' + _.time.spent( '', c.time ) ); /* qqq : rewrite how _.time.spent is used. use sleepingBarber as example */

// }

// //

// let Self =
// {
//   informAboutHungry,
//   simulateHungryEvent,
// }

// //

// if( typeof module !== 'undefined' )
// {
//   module[ 'exports' ] = Self;
//   if( !module.parent )
//     Self.simulateHungryEvent();
// }
