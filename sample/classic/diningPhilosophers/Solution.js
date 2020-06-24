/**
 * @file This sample demonstrates using wConsequence for synchronization the several asynchronous process by example of
 * 'Dining Philosophers' problem. In this example thinking and eating processes are asynchronous.
 */
let _,
  Problem;

if( typeof module !== 'undefined' )
{
  _ = require( 'wTools' );
  require( 'wConsequence' );
  Problem = require( './Problem.js' );
}

const startTime = _.time.now();
const con = new _.Consequence({ capacity : 0 });
Problem.getHungry = getHungry;
Problem.run( 1 );

//

function getHungry( ph )
{
  console.log( `+ ph_${ph.id} is hungry - ${status()}` );
  ph.isHungry = true;

  if( ph.leftFork.isAvailable && ph.rightFork.isAvailable )
  {
    con.take( null );
    con.then( () => startEating( ph ) );
  }
  else
  {
    console.log( `  forks is busy, ph_${ph.id} will try later - ${status()}` );
    _.time.out( 1000, () => tryLater( ph ) );
  }
}

//

function status()
{
  const busyFokrs = Problem.forks.filter( ( fork ) => !fork.isAvailable ).map( ( fork ) => fork.id );
  const eatingPh = Problem.philosophers.filter( ( ph ) => ph.isEating ).map( ( ph ) => ph.id );
  const waitingPh = Problem.philosophers.filter( ( ph ) => ph.isHungry ).map( ( ph ) => ph.id );
  return `time: ${_.time.spent( startTime )}, busyFokrs: ${busyFokrs}, eatingPh: ${eatingPh}, waitingPh: ${waitingPh}`;
}

//

function tryLater( ph )
{
  if( ph.leftFork.isAvailable && ph.rightFork.isAvailable )
  {
    con.take( null );
    con.then( () => startEating( ph ) );
  }
  else
  {
    console.log( `    ph_${ph.id} tries again, forks is busy, ph_${ph.id} will try later - ${status()}` );
    _.time.out( 1000, () => tryLater( ph ) );
  }
}

//

function startEating( ph )
{
  ph.isHungry = false;
  ph.leftFork.isAvailable = false;
  ph.rightFork.isAvailable = false;
  ph.isEating = true;
  console.log( `  ph_${ph.id} starts eating - ${status()}` );
  return _.time.out( ph.eatingTime ).then( () => stopEating( ph ) || null );
}

//

function stopEating( ph )
{
  ph.leftFork.isAvailable = true;
  ph.rightFork.isAvailable = true;
  ph.isEating = false;
  ph.isHungry = false;
  console.log( `- ph_${ph.id} finished eat - ${status()}` );
}

/* aaa Artem : done. implement */
