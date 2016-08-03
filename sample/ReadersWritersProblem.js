/*
 Problem describes situation in which many threads try to access the same shared resource at one time. Some threads may
 read and some may write, with the constraint that no process may access the share for either reading or writing, while
 another process is in the act of writing to it. (In particular, it is allowed for two or more readers to access the share
 at the same time.)

 source: https://en.wikipedia.org/wiki/Readers%E2%80%93writers_problem
 */

if( typeof module !== 'undefined' )
{
  var _ = require( 'wTools' );
  /* require( 'wConsequence' ); */
  /* require( '../staging/abase/syn/Consequence.s' ); */
}

var resource = {
  sharedData : '',
  readers: [],
  writers: [],
};

function RWSubject( name )
{
  this.name = name;
  this.read = function() {
    console.log(resource.sharedData);
  };

  this.write = function() {
    resource.sharedData += this.name + 'was here);\n';
  };
}

var rwSubjects =
  [
    new RWSubject('1'),
    new RWSubject('2'),
    new RWSubject('3'),
    new RWSubject('4'),
  ];

var rwEventList =
  {
    '1':
      [
        { operation: 'write', delay: 1000, duration: 1500 },
        { operation: 'read', delay: 3000, duration: 2000 },
        { operation: 'read', delay: 5000, duration: 1000 },
        { operation: 'write', delay: 7000, duration: 500 },
        { operation: 'read', delay: 9000, duration: 1700 },
        { operation: 'write', delay: 11000, duration: 4000 }
      ],
    '2':
      [
        { operation: 'write', delay: 2000, duration: 1000 },
        { operation: 'read', delay: 6000, duration: 500 },
        { operation: 'read', delay: 7000, duration: 600 },
        { operation: 'read', delay: 9000, duration: 600 },
        { operation: 'write', delay: 11000, duration: 1000 }
      ],
    '3':
      [
        { operation: 'write', delay: 0, duration: 200 },
        { operation: 'read', delay: 2000, duration: 200 },
        { operation: 'write', delay: 4000, duration: 1400 },
        { operation: 'read', delay: 6000, duration: 1300 },
        { operation: 'read', delay: 8000, duration: 200 }
      ],
    '4':
      [
        { operation: 'read', delay: 1000, duration: 200 },
        { operation: 'read', delay: 2000, duration: 300 },
        { operation: 'write', delay: 3000, duration: 200 },
        { operation: 'write', delay: 4000, duration: 200 },
        { operation: 'read', delay: 5000, duration: 400 },
        { operation: 'read', delay: 6000, duration: 200 }
      ]
  };

function simulateReadWriteEvent()
{
  var subject;
  for( subject in rwEventList )
  {
    if( !rwEventList.hasOwnProperty( subject ) )
      continue;

    var i = 0,
      list = rwEventList[ subject ],
      len = list.length,
      time = _.timeNow(),
      rWSubject = rwSubjects[ subject - 1 ];
    for( ; i < len; i++ )
    {
      var event = list[ i ];
      setTimeout( ( function( rWSubject, event )
      {
        var context = {};
        context.time = time;
        context.rwSubject = rWSubject;
        context.event = event;
        this.precessEvent( context );
      }).bind( this, rWSubject, event ), event.delay );
    }
  }
}

function  precessEvent( opt )
{
  console.log( 'try to perform ' + opt.event.operation + ' by ' + opt.rwSubject.name + ' at '
    + _.timeSpent( ' ',opt.time ) );

  // in progress
  
}

var Self =
{
  precessEvent : precessEvent,
  simulateReadWriteEvent : simulateReadWriteEvent,
};

//

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
  if( !module.parent )
    Self.simulateReadWriteEvent();
}