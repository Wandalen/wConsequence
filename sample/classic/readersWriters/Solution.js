/**
 * @file This sample demonstrates using wConsequence for synchronization the several asynchronous process by example of
 * 'Readers-Writers' problem. In this example, attempts to write or read a buffer are asynchronous.
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
let isReading = false;
let isWriting = false;
let activeWriters = 0;
let activeReaders = 0;
let proceduresQueue = [];
Problem.event = event;
Problem.run();

//

function event( o )
{
  console.log( `+ op_${o.id}_${o.type} wants to ${o.action} - ${status()}` );

  if( o.action === 'write' )
  {
    if( !isReading && !isWriting )
    {
      write( o );
    }
    else
    {
      console.log( `  op_${o.id}_${o.type} cannot access the buffer, op_${o.id}_${o.type} will try later - ${status()}` );
      proceduresQueue.push( o );
    }
  }
  else
  {
    if( !isWriting )
    {
      read( o );
    }
    else
    {
      console.log( `  op_${o.id}_${o.type} cannot access the buffer, op_${o.id}_${o.type} will try later - ${status()}` );
      proceduresQueue.push( o );
    }
  }
}

//

function status()
{
  return `${_.time.spent( startTime )}, isWriting: ${isWriting}, isReading: ${isReading}, writeNow: ${activeWriters}, readNow: ${activeReaders}, inQueue: ${proceduresQueue.length}`;
}

//

function write( o )
{
  isWriting = true;
  activeWriters += 1;
  console.log( `  op_${o.id}_${o.type} starts ${o.action} - ${status()}` );
  return _.time.out( o.duration ).then( () =>
  {
    activeWriters -= 1;
    if( !activeWriters )
    isWriting = false;

    console.log( `  op_${o.id}_${o.type} finished ${o.action} - ${status()}` );

    if( !isWriting )
    {
      const proceduresQueueCopy = [ ... proceduresQueue ];
      proceduresQueue = [];
      for( let i = 0; i < proceduresQueueCopy.length; i++ )
      _.time.out( 0, () => event( proceduresQueueCopy[ i ] ) );
    }

    return null;
  } );
}

//

function read( o )
{
  isReading = true;
  activeReaders += 1;
  console.log( `  op_${o.id}_${o.type} starts ${o.action} - ${status()}` );
  return _.time.out( o.duration ).then( () =>
  {
    activeReaders -= 1;
    if( !activeReaders )
    isReading = false;

    console.log( `  op_${o.id}_${o.type} finished ${o.action} - ${status()}` );

    if( !isReading )
    {
      const proceduresQueueCopy = [ ... proceduresQueue ];
      proceduresQueue = [];
      for( let i = 0; i < proceduresQueueCopy.length; i++ )
      _.time.out( 0, () => event( proceduresQueueCopy[ i ] ) );
    }

    return null;
  } );
}

/* aaa Artem : done. implement */
