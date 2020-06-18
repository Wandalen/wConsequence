/* aaa Artem : done. implement */
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

const startTime = _.time.now();
const con = new _.Consequence({ capacity : 0 });

run( 1 );

//

function run( k )
{
  console.log( `Сycle ${k}:` );
  for( let i = 0; i < philosophers.length; i++ )
  {
    const ph = philosophers[ i ];
    _.time.out( ph.id === 1 || ph.id === 3 ? ph.getHungry * k : ph.getHungry, () => getHungry( ph ) );
  }

  if( k === 1 )
  _.time.out( 20000, () => run( 2 ) );
}

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
  const busyFokrs = forks.filter( ( fork ) => !fork.isAvailable ).map( ( fork ) => fork.id );
  const eatingPh = philosophers.filter( ( ph ) => ph.isEating ).map( ( ph ) => ph.id );
  const waitingPh = philosophers.filter( ( ph ) => ph.isHungry ).map( ( ph ) => ph.id );
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
