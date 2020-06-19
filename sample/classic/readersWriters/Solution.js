/* aaa Artem : done. implement */
let _;

if( typeof module !== 'undefined' )
{
  _ = require( 'wTools' );
  require( 'wConsequence' );
}

const startTime = _.time.now();
let isReading = false;
let isWriting = false;
let activeWriters = 0;
let activeReaders = 0;
let proceduresQueue = [];

const writersReaders =
[
  { id : 1, type : 'reader', action : 'read', duration : 2000, delay : 1000 },
  { id : 2, type : 'writer', action : 'write', duration : 1000, delay : 2000 },
  { id : 3, type : 'reader', action : 'read', duration : 2000, delay : 2500 },
  { id : 4, type : 'writer', action : 'write', duration : 1000, delay : 5000 },
  { id : 5, type : 'reader', action : 'read', duration : 2000, delay : 5000 },
];

run();

//

function run()
{
  for( let i = 0; i < writersReaders.length; i++ )
  _.time.out( writersReaders[ i ].delay, () => event( writersReaders[ i ] ) );
}

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
