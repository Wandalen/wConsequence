( function _Ext_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../Tools.s' );
  require( '../../l9/consequence/Consequence.s' );
  _.include( 'wTesting' );

  _.include( 'wLogger' );
  _.include( 'wAppBasic' );

}

let _ = _global_.wTools;
let fileProvider = _testerGlobal_.wTools.fileProvider;
let path = fileProvider.path;

// --
// context
// --

function onSuiteBegin()
{
  let self = this;

  self.suiteTempPath = path.pathDirTempOpen( path.join( __dirname, '../..'  ), 'ConsequenceExternal' );
  self.assetsOriginalSuitePath = path.join( __dirname, '_asset' );
}

//

function onSuiteEnd()
{
  let self = this;
  _.assert( _.strHas( self.suiteTempPath, '/ConsequenceExternal-' ) )
  path.pathDirTempClose( self.suiteTempPath );
}

//

function assetFor( test, ... args )
{
  let context = this;
  let a = test.assetFor( ... args );
  return a;
}

// --
// tests
// --

function unhandledSyncErrorOnExit( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.program( program );

  a.jsNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'unhandled error on termination' ), 2 );
    test.identical( _.strCount( op.output, 'error1' ), 1 );
    return null;
  });

  return a.ready;

  function program()
  {
    var _ = require( toolsPath );
    _.include( 'wAppBasic' );
    let con = new _.Consequence();
    _.process.on( 'exit', () =>
    {
      debugger
      throw _.err( 'error1' );
    })
  }
}

unhandledSyncErrorOnExit.description =
`
Unhandled synchronous error on temrination caught and handled
`

//

function unhandledAsyncErrorOnExit( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.program( program );

  a.jsNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'unhandled asynchronous error' ), 2 );
    test.identical( _.strCount( op.output, 'error1' ), 1 );
    return null;
  });

  return a.ready;

  function program()
  {
    var _ = require( toolsPath );
    _.include( 'wAppBasic' );
    let con = new _.Consequence();
    _.process.on( 'exit', () =>
    {
      debugger;
      con.error( 'error1' );
    })
  }
}

unhandledAsyncErrorOnExit.description =
`
Unhandled synchronous error on temrination caught and handled
`

//

function asyncStackWithTimeOut( test )
{
  let context = this;
  let visited = [];
  let a = context.assetFor( test, false );
  let programPath = a.program( program );

  /* */

  a.jsNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 0 );
    test.identical( _.strCount( op.output, 'procedure::' ), 0 );
    test.identical( _.strCount( op.output, /v1(.|\n|\r)*v2(.|\n|\r)*error1(.|\n|\r)*/mg ), 1 );
    test.identical( _.strCount( op.output, 'Program.js:12' ), 1 );
    test.identical( _.strCount( op.output, 'Program.js:15' ), 2 );
    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    let _ = require( toolsPath );

    _.include( 'wConsequence' );
    _.include( 'wProcedure' );

    let t = 10;

    _.time.begin( t, () =>
    {
      console.log( 'v2' );
      throw _.err( 'error1' );
    });

    console.log( 'v1' );
  }

}

asyncStackWithTimeOut.timeOut = 60000;
asyncStackWithTimeOut.description =
`
- async stack presents
- async stack does not have duplicates
`

//

function asyncStackWithConsequence( test )
{
  let context = this;
  let visited = [];
  let a = context.assetFor( test, false );
  let programPath = a.program( program );

  /* */

  a.jsNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 0 );
    test.identical( _.strCount( op.output, 'procedure::' ), 0 );
    test.identical( _.strCount( op.output, /v1(.|\n|\r)*v2(.|\n|\r)*error1(.|\n|\r)*/mg ), 1 );
    test.identical( _.strCount( op.output, 'Program.js:13' ), 1 );
    test.identical( _.strCount( op.output, 'Program.js:16' ), 2 );
    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    let _ = require( toolsPath );

    _.include( 'wConsequence' );
    _.include( 'wProcedure' );

    let t = 10;
    let con = _.time.out( t );

    con.then( () =>
    {
      console.log( 'v2' );
      throw _.err( 'error1' );
    });

    console.log( 'v1' );
  }

}

asyncStackWithConsequence.timeOut = 60000;
asyncStackWithConsequence.description =
`
- async stack presents
- async stack does not have duplicates
`

//

function timeLimit( test )
{
  let context = this;
  let visited = [];
  let a = context.assetFor( test, false );
  let programPath = a.program( program );

  /* */

  a.jsNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 0 );
    test.identical( _.strCount( op.output, 'procedure::' ), 0 );
    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    let _ = require( toolsPath );
    let t = 25;
    _.include( 'wConsequence' );
    _.include( 'wProcedure' );
    var con = _.time.out( t*1 );
    con.timeLimit( t*6, () => _.time.out( t*3, 'a' ) );
    // _.procedure.terminationBegin();
  }

}

timeLimit.timeOut = 30000;
timeLimit.description =
`
- application does not have to wait for procedures
`

//

function timeLimitWaitingEnough( test )
{
  let context = this;
  let visited = [];
  let a = context.assetFor( test, false );
  let programPath = a.program( program );

  /* */

  a.jsNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 1 );
    test.identical( _.strCount( op.output, 'Waiting for 8 procedure(s)' ), 1 );
    test.identical( _.strCount( op.output, 'procedure::' ), 8 );
    test.identical( _.strCount( op.output, 'Program.js:19' ), 0 );
    test.identical( _.strCount( op.output, 'Program.js:13' ), 6 );
    test.identical( _.strCount( op.output, 'Program.js:16' ), 2 );
    test.identical( _.strCount( op.output, /v0(.|\n|\r)*v1(.|\n|\r)*v2(.|\n|\r)*v3(.|\n|\r)*v4/mg ), 1 );
    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    let _ = require( toolsPath );
    let t = 1000;
    _.include( 'wConsequence' );
    _.include( 'wProcedure' );
    var con = _.time.out( t*1 );

    console.log( 'v0' );

    con.timeLimit( t*6, () =>
    {
      console.log( 'v2' );
      return _.time.out( t*3, () =>
      {
        console.log( 'v4' );
        return 'a';
      });
    });

    _.time.out( t*2, () =>
    {
      console.log( 'v3' );
      _.Procedure.TerminationPeriod = 1000;
      _.procedure.terminationBegin();
    });

    console.log( 'v1' );
  }

}

timeLimitWaitingEnough.timeOut = 60000;
timeLimitWaitingEnough.description =
`
- application should wait for procedures because of large time out of async routines
- limit is enough
`

//

function timeLimitWaitingNotEnough( test )
{
  let context = this;
  let visited = [];
  let a = context.assetFor( test, false );
  let programPath = a.program( program );

  /* */

  a.jsNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 1 );
    test.identical( _.strCount( op.output, 'Waiting for 3 procedure(s)' ), 1 );
    test.identical( _.strCount( op.output, 'procedure::' ), 3 );
    test.identical( _.strCount( op.output, 'Program.js:17' ), 2 );
    test.identical( _.strCount( op.output, 'Program.js:14' ), 1 );
    test.identical( _.strCount( op.output, /v0(.|\n|\r)*v1(.|\n|\r)*v2(.|\n|\r)*v3(.|\n|\r)*v4/mg ), 1 );
    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    let _ = require( toolsPath );
    _.include( 'wConsequence' );
    _.include( 'wProcedure' );

    let t = 250;
    var con = _.time.out( t*1 );

    console.log( 'v0' );

    con.timeLimit( t*3, () =>
    {
      console.log( 'v2' );
      return _.time.out( t*6, () =>
      {
        console.log( 'v4' );
        return 'a';
      });
    });

    _.time.out( t*2, () =>
    {
      console.log( 'v3' );
      _.Procedure.TerminationPeriod = t*2;
      _.procedure.terminationBegin();
    });

    console.log( 'v1' );
  }

}

timeLimitWaitingNotEnough.timeOut = 60000;
timeLimitWaitingNotEnough.description =
`
- application should wait for procedures because of large time out of async routines
- limit is not enough
`

//

function timeCancelBefore( test )
{
  let context = this;
  let visited = [];
  let a = context.assetFor( test, false );
  let programPath = a.program( program );

  /* */

  a.jsNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 0 );
    test.identical( _.strCount( op.output, 'procedure::' ), 0 );
    test.identical( _.strCount( op.output, 'v1' ), 1 );
    test.identical( _.strCount( op.output, 'v2' ), 0 );
    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    let _ = require( toolsPath );
    _.include( 'wConsequence' );
    _.include( 'wProcedure' );

    let t = 25;

    let timer = _.time.begin( t*2, () =>
    {
      console.log( 'v2' );
    });

    _.time.out( t, () => _.time.cancel( timer ) );

    console.log( 'v1' );

    _.Procedure.TerminationPeriod = 1000;
    _.procedure.terminationBegin();

    return _.time.out( t*3 );
  }

}

timeCancelBefore.timeOut = 60000;
timeCancelBefore.description =
`
- time cancel before time out leave no zombie
`

//

function timeCancelAfter( test )
{
  let context = this;
  let visited = [];
  let a = context.assetFor( test, false );
  let programPath = a.program( program );

  /* */

  a.jsNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 0 );
    test.identical( _.strCount( op.output, 'procedure::' ), 0 );
    test.identical( _.strCount( op.output, /v1(.|\n|\r)*v2(.|\n|\r)/mg ), 1 );
    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    let _ = require( toolsPath );
    _.include( 'wConsequence' );
    _.include( 'wProcedure' );

    let t = 25;

    let timer = _.time.begin( t, () =>
    {
      console.log( 'v2' );
    });

    _.time.out( t*2, () => _.time.cancel( timer ) );

    console.log( 'v1' );

    _.Procedure.TerminationPeriod = 1000;
    _.procedure.terminationBegin();

    return _.time.out( t*3 );
  }

}

timeCancelAfter.timeOut = 60000;
timeCancelAfter.description =
`
- time cancel after time out leave no zombie
`

//

function timeOutExternalMessage( test )
{
  let context = this;
  let visited = [];
  let a = context.assetFor( test, false );
  let programPath = a.program( program );

  /* */

  a.jsNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 0 );

    test.identical( _.strCount( op.output, 'v1' ), 1 );
    test.identical( _.strCount( op.output, 'v2' ), 1 );
    test.identical( _.strCount( op.output, 'v3' ), 1 );
    test.identical( _.strCount( op.output, 'v4' ), 1 );
    test.identical( _.strCount( op.output, 'v5' ), 0 );
    test.identical( _.strCount( op.output, 'argumentsCount 0' ), 1 );
    test.identical( _.strCount( op.output, 'errorsCount 0' ), 1 );
    test.identical( _.strCount( op.output, 'competitorsCount 1' ), 1 );
    test.identical( _.strCount( op.output, /v1(.|\n|\r)*v2(.|\n|\r)*v3(.|\n|\r)*v4(.|\n|\r)*/mg ), 1 );

    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    let _ = require( toolsPath );
    _.include( 'wProcedure' );
    _.include( 'wConsequence' );
    var t = 100;

    var con1 = _.time.out( t*2, () => 1 );

    console.log( 'v1' );
    _.time.out( t, function()
    {
      console.log( 'v2' );
      con1.take( 2 );
      con1.give( ( err, got ) =>
      {
        console.log( 'v3' );
      });
      con1.give( ( err, got ) =>
      {
        console.log( 'v4' );
      });
      con1.give( ( err, got ) =>
      {
        console.log( 'v5' );
      });
    })

    return _.time.out( t*5 ).then( () =>
    {
      console.log( 'v6' );
      console.log( 'argumentsCount', con1.argumentsCount() );
      console.log( 'errorsCount', con1.errorsCount() );
      console.log( 'competitorsCount', con1.competitorsCount() );
      con1.cancel();
      return null;
    });
  }

}

timeOutExternalMessage.timeOut = 60000;
timeOutExternalMessage.description =
`
- consequence of time out can get a message from outside of time out routine
`

//

function timeBegin( test )
{
  let context = this;
  let visited = [];
  let a = context.assetFor( test, false );
  let programPath = a.program( program );

  /* */

  a.jsNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 0 );
    test.identical( _.strCount( op.output, 'procedure::' ), 0 );
    test.identical( _.strCount( op.output, /v1(.|\n|\r)*v2(.|\n|\r)/mg ), 1 );
    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    let _ = require( toolsPath );
    _.include( 'wConsequence' );
    _.include( 'wProcedure' );

    let t = 10;

    _.time.begin( t, () =>
    {
      console.log( 'v2' );
    });

    console.log( 'v1' );

    _.Procedure.TerminationPeriod = 1000;
    _.procedure.terminationBegin();

    _.time.out( t*2 );
  }

}

timeBegin.timeOut = 60000;
timeBegin.description =
`
- time begin leave no zombie procedures
`

// --
// declare
// --

var Self =
{

  name : 'Tools.base.Consequence.Ext',
  silencing : 1,

  onSuiteBegin,
  onSuiteEnd,

  context :
  {

    nameOfFile : 'Ext.test.s',
    suiteTempPath : null,
    assetsOriginalSuitePath : null,
    defaultJsPath : null,

    assetFor,

  },

  tests :
  {

    unhandledSyncErrorOnExit, /* xxx : move to process */
    unhandledAsyncErrorOnExit, /* xxx : move to process */ /* xxx : fix later */
    asyncStackWithTimeOut,
    asyncStackWithConsequence,

    timeLimit,
    timeLimitWaitingEnough,
    timeLimitWaitingNotEnough,

    timeCancelBefore,
    timeCancelAfter,
    timeOutExternalMessage,
    timeBegin,

  }

}

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();