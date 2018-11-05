if( typeof module !== 'undefined' )
{
  var _ = require( 'wTools' );
  /* require( 'wConsequence' ); */
  require( '../../proto/dwtools/abase/oclass/Consequence.s' );
  var ReadersWritersProblem = require( './ReadersWritersProblem.js' );
}

//

var writeLock = wConsequence().give(), // on begin resource allowed wor read/write by any subject.
  readLock = wConsequence().give(); // on begin resource allowed wor read by any subject.

function SReadersWritersProblem () {};

//
  SReadersWritersProblem.prototype = ReadersWritersProblem;

  SReadersWritersProblem.prototype.constructor = SReadersWritersProblem;
//

SReadersWritersProblem.prototype.precessEvent = function( opt )
{
  console.log( 'try to perform ' + opt.event.operation + ' by ' + opt.rwSubject.name + ' at '
    + _.timeSpent( ' ', opt.time ) );

  var resource = this.resource;

  if( opt.event.operation == 'read' )
  {
    performRead( resource, opt );
  }
  else if( opt.event.operation == 'write' )
  {
    performWrite( resource, opt );
  }
}

function performWrite( resource, opt ) {
  writeLock.got( function()
  {
    readLock.got(); // prevent reading during process write
    if ( resource.writers.length + resource.readers.length > 0 )
    {
      console.log('PROBLEM : ' + opt.rwSubject.name + 'can`t wwrite resource, because it busy by ' +
        resource.readers.join( ', ' ) + ' read subjects and ' + resource.writers.join( ', ' ) + ' write subjects' );
      writeLock.give(); // allow write
      readLock.give(); //allow read
    }
    else
    {
      resource.writers.push( opt.rwSubject.name );
      console.log( 'start write by ' + opt.rwSubject.name );
      setTimeout( ( function( opt )
      {
        console.log( 'end write by ' + opt.rwSubject.name );
        opt.rwSubject.write();
        _.arrayRemovedOnce(resource.writers, opt.rwSubject.name);
        writeLock.give(); // allow write
        readLock.give(); //allow read
      } ).bind( null, opt ), opt.event.duration );
    }
  });
}

function performRead( resource, opt ) {
  readLock.got( function()
  {
    if( writeLock.hasMessage() !== 0 ) // prevent writing during process read if not prevented by any
    // other reader yet.
    {
      writeLock.got();
    }
    readLock.give(); // allow reading, because reading allowed for several readers in one time
    if ( resource.writers.length > 0 )
    {
      console.log('PROBLEM : ' + opt.rwSubject.name + 'can`t read resource, because it busy by ' +
        resource.writers.join( ', ' ) + 'subjects' );
      if( writeLock.hasMessage() === 0 )
      {
        writeLock.give(); // allow writing
      }
    }
    else
    {
      resource.readers.push( opt.rwSubject.name );
      console.log( 'start read by ' + opt.rwSubject.name );
      setTimeout( ( function( opt )
      {
        console.log( 'end read by ' + opt.rwSubject.name );
        opt.rwSubject.read();
        _.arrayRemovedOnce(resource.readers, opt.rwSubject.name);
        if( writeLock.hasMessage() === 0 )
        {
          writeLock.give(); // allow writing
        }
      } ).bind( null, opt ), opt.event.duration );
    }
  });
}

var readersWritersProblem = new SReadersWritersProblem();

readersWritersProblem.init();
