/* qqq : implement */
let _;

if( typeof module !== 'undefined' )
{
  _ = require( 'wTools' );
  require( 'wConsequence' );
}

const fork1 = { id : 1, isAvailable : true }
const fork2 = { id : 2, isAvailable : true }
const fork3 = { id : 3, isAvailable : true }
const fork4 = { id : 4, isAvailable : true }
const fork5 = { id : 5, isAvailable : true }

const forks = [ fork1, fork2, fork3, fork4, fork5 ];

const philosophers =
[
  { // will eat
    id : 1,
    name : 'Plato',
    isEating : false,
    leftFork : fork5,
    rightFork : fork1,
    getHungry : 2500,
    eatingTime : 5000
  },
  {
    id : 2,
    name : 'Aristotle',
    isEating : false,
    leftFork : fork1,
    rightFork : fork2,
    getHungry : 4500,
    eatingTime : 5000
  },
  { // will eat
    id : 3,
    name : 'Heraclitus',
    isEating : false,
    leftFork : fork2,
    rightFork : fork3,
    getHungry : 6500,
    eatingTime : 5000
  },
  {
    id : 4,
    name : 'Diogenes',
    isEating : false,
    leftFork : fork3,
    rightFork : fork4,
    getHungry : 5000,
    eatingTime : 5000
  },
  {
    id : 5,
    name : 'Cicero',
    isEating : false,
    leftFork : fork4,
    rightFork : fork5,
    getHungry : 3500,
    eatingTime : 5000
  }
];

const startTime = _.time.now();
const con = new _.Consequence().take( null );

run( 1 );

//

function run( k )
{
  for( let i = 0; i < philosophers.length; i++ )
  {
    const ph = philosophers[ i ];
    _.time.out( ph.id === 1 || ph.id === 3 ? ph.getHungry * k : ph.getHungry, () => getHungry( ph ) );
  }

  // if( k === 1 )
  // _.time.out( 30000, () => run( 2 ) )
}

//

function getHungry( ph )
{
  console.log( `+ ph_${ph.id} is hungry - ${status()}` );

  // if( ph.leftFork.isAvailable && ph.rightFork.isAvailable )
  // {
  //   con.then( () => startEating( ph ) )
  // }
}

//

function status()
{
  const busyFokrs = forks.filter( ( fork ) => !fork.isAvailable ).map( ( fork ) => fork.id );
  const eatingPh = philosophers.filter( ( ph ) => ph.isEating ).map( ( ph ) => ph.id );
  return `time: ${_.time.spent( startTime )}, busyFokrs: ${busyFokrs}, eatingPh: ${eatingPh}`;
}

//

function startEating( ph )
{
  ph.leftFork.isAvailable = false;
  ph.rightFork.isAvailable = false;
  console.log( `` );
}

//

function stopEating( ph )
{

}

//

// function checkLeftSide( ph )
// {

// }

//

// function checkRightSide( ph )
// {

// }
