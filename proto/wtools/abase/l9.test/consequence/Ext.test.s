( function _Ext_test_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( '../../../../node_modules/Tools' );

  _.include( 'wTesting' );
  _.include( 'wLogger' );
  _.include( 'wProcess' );

  require( '../../l9/consequence/Namespace.s' );
}

const _ = _global_.wTools;
const __ = _globals_.testing.wTools;
const fileProvider = __.fileProvider;
const path = fileProvider.path;

// --
// context
// --

function onSuiteBegin()
{
  let self = this;
  self.suiteTempPath = path.tempOpen( path.join( __dirname, '../..' ), 'ConsequenceExternal' );
  self.assetsOriginalPath = path.join( __dirname, '_asset' );
}

//

function onSuiteEnd()
{
  let self = this;
  _.assert( _.strHas( self.suiteTempPath, '/ConsequenceExternal-' ) )
  path.tempClose( self.suiteTempPath );
}

//

function assetFor( test, ... args )
{
  let context = this;
  let a = test.assetFor( ... args );

  _.assert( _.routineIs( a.program.head ) );
  _.assert( _.routineIs( a.program.body ) );

  let oprogram = a.program;
  program_body.defaults = a.program.defaults;
  a.program = _.routine.uniteCloning_( a.program.head, program_body );

  return a;

  /* */

  function program_body( o )
  {
    let locals =
    {
      context : { t0 : context.t0, t1 : context.t1, t2 : context.t2, t3 : context.t3 },
      toolsPath : _.module.resolve( 'wTools' ),
    };
    o.locals = o.locals || locals;
    _.mapSupplement( o.locals, locals );
    _.mapSupplement( o.locals.context, locals.context );
    if( !o.locals.consequencePath )
    o.locals.consequencePath = a.path.nativize( a.path.join( __dirname, '../../l9/consequence/Namespace.s' ) );
    let programPath = a.path.nativize( oprogram.body.call( a, o ) );
    return programPath;
  }

}

// --
// tests
// --

function uncaughtSyncErrorOnExit( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.program({ routine : program });

  a.appStartNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '-- uncaught error --' ), 2 );
    test.identical( _.strCount( op.output, 'Error on handing event exit' ), 1 );
    test.identical( _.strCount( op.output, 'error1' ), 2 );
    test.identical( _.strCount( op.output, 'ncaught' ), 8 );
    test.identical( _.strCount( op.output, 'nhandled' ), 0 );
    return null;
  });

  return a.ready;

  function program()
  {
    const _ = require( toolsPath );
    _.include( 'wProcess' );
    let con = new _.Consequence();
    _.process.on( 'exit', () =>
    {
      debugger
      throw _.err( 'error1' );
    })
  }
}

uncaughtSyncErrorOnExit.description =
`
Uncaught synchronous error on temrination caught and handled
`

//

function uncaughtAsyncErrorOnExit( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.program({ routine : program });

  a.appStartNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'uncaught asynchronous error' ), 0 );
    test.identical( _.strCount( op.output, 'error1' ), 0 );
    return null;
  });

  return a.ready;

  function program()
  {
    const _ = require( toolsPath );
    _.include( 'wProcess' );
    let con = new _.Consequence();
    _.process.on( 'exit', () =>
    {
      debugger;
      con.error( 'error1' );
    })
  }
}

uncaughtAsyncErrorOnExit.description =
`
Uncaught synchronous error on temrination caught and handled
`

//

function uncaughtAsyncErrorOnExitBefore( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.program({ routine : program });

  a.appStartNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'uncaught asynchronous error' ), 2 );
    test.identical( _.strCount( op.output, 'error1' ), 2 );
    return null;
  });

  return a.ready;

  function program()
  {
    const _ = require( toolsPath );
    _.include( 'wProcess' );
    let con = new _.Consequence();
    _.process.on( 'exitBefore', () =>
    {
      debugger;
      con.error( 'error1' );
    })
  }
}

uncaughtAsyncErrorOnExitBefore.description =
`
Uncaught synchronous error on temrination caught and handled
`

//

function AndKeepErrorAttend( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.program({ routine : program });

  a.appStartNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'uncaught asynchronous error' ), 0 );
    test.identical( _.strCount( op.output, 'error' ), 0 );
    test.identical( _.strCount( op.output, 'Error' ), 0 );
    test.identical( _.strCount( op.output, /time1(.|\n|\r)*time2(.|\n|\r)*finally/mg ), 1 );
    return null;
  });

  return a.ready;

  function program()
  {
    const _ = require( toolsPath );
    _.include( 'wConsequence' );

    var con1 = _.time.out( context.t1, () =>
    {
      console.log( 'time1' );
      throw _.err( 'Test error' );
    })
    var con2 = _.time.out( context.t1*3, () =>
    {
      console.log( 'time2' );
      return null
    })

    _.Consequence.AndKeep( con1, con2 )
    .finally( ( err, arg ) =>
    {
      console.log( 'finally' );
      _.errAttend( err );
      return null;
    })
  }

}

AndKeepErrorAttend.description =
`
First consequence gives error message after small delay.
Second consequence gives regular message after first consequence.
Third consequence waits until both consequences will be resolved.
Uncaught error will not be throwen because _.errAttend will attend the error.
Third consequence will catch error from first consequence.
`

//

function AndKeepErrorNotAttend( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.program({ routine : program });

  a.appStartNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'uncaught asynchronous error' ), 2 );
    test.identical( _.strCount( op.output, 'Test error' ), 1 );
    test.identical( _.strCount( op.output, /time1(.|\n|\r)*time2(.|\n|\r)*finally/mg ), 1 );
    return null;
  });

  return a.ready;

  function program()
  {
    const _ = require( toolsPath );
    _.include( 'wConsequence' );

    var con1 = _.time.out( context.t1, () =>
    {
      console.log( 'time1' );
      throw _.err( 'Test error' );
    })
    var con2 = _.time.out( context.t1*3, () =>
    {
      console.log( 'time2' );
      return null
    })

    _.Consequence.AndKeep( con1, con2 )
    .finally(( err, arg ) =>
    {
      if( err )
      console.log( 'finally' );
      return null;
    })
  }
}

AndKeepErrorNotAttend.description =
`
First consequence gives error message after small delay.
Second consequence gives regular message after first consequence.
Third consequence waits until both consequences will be resolved.
Uncaught error will be throwen because nothing will attend the error.
Third consequence will catch error from first consequence.
`

//

function asyncStackWithTimeOut( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.program({ routine : program });

  /* */

  a.appStartNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 0 );
    test.identical( _.strCount( op.output, 'procedure::' ), 0 );
    test.identical( _.strCount( op.output, 'ncaught' ), 2 );
    test.identical( _.strCount( op.output, 'nhandled' ), 0 );
    test.identical( _.strCount( op.output, 'uncaught error' ), 2 );
    test.identical( _.strCount( op.output, /v1(.|\n|\r)*v2(.|\n|\r)*error1(.|\n|\r)*/mg ), 1 );
    test.identical( _.strCount( op.output, 'program.js:10' ), 1 );
    test.identical( _.strCount( op.output, 'program.js:13' ), 2 );
    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    const _ = require( toolsPath );

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
  let a = context.assetFor( test, false );
  let programPath = a.program({ routine : program });

  /* */

  a.appStartNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 0 );
    test.identical( _.strCount( op.output, 'procedure::' ), 0 );
    test.identical( _.strCount( op.output, 'ncaught' ), 2 );
    test.identical( _.strCount( op.output, 'nhandled' ), 0 );
    test.identical( _.strCount( op.output, 'uncaught asynchronous error' ), 2 );
    test.identical( _.strCount( op.output, /v1(.|\n|\r)*v2(.|\n|\r)*error1(.|\n|\r)*/mg ), 1 );
    test.identical( _.strCount( op.output, 'program.js:11' ), 1 );
    test.identical( _.strCount( op.output, 'program.js:14' ), 2 );
    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    const _ = require( toolsPath );

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

function asyncStackInConsequenceTrivial( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.program({ routine : program });

  /* */

  a.appStartNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '- uncaught asynchronous error -' ), 2 );
    test.identical( _.strCount( op.output, '= Source code from' ), 1 );
    test.identical( _.strCount( op.output, `program.js:6` ), 1 );
    test.identical( _.strCount( op.output, `at program` ), 1 );
    test.identical( _.strCount( op.output, `Error1` ), 2 );
    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    const _ = require( toolsPath );
    _.include( 'wFiles' );
    _.include( 'wConsequence' );
    _.time.out( context.t1*3/2, () =>
    {
      throw _.err( 'Error1' );
      return null;
    });
  }

}

asyncStackInConsequenceTrivial.timeOut = 30000;
asyncStackInConsequenceTrivial.description =
`
stack has async substack
`

//

function asyncStackInConsequenceThen( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.program({ routine : program });

  /* */

  a.appStartNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '- uncaught asynchronous error -' ), 2 );
    test.identical( _.strCount( op.output, '= Source code from' ), 1 );
    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    const _ = require( toolsPath );
    _.include( 'wFiles' );
    _.include( 'wConsequence' );

    var con = _.Consequence()
    con.then( function callback1( arg )
    {
      console.log( 'sourcePath::callback1 ' + _.Procedure.ActiveProcedure._sourcePath );
      return 'callback1';
    })
    con.then( function callback2( arg )
    {
      console.log( 'sourcePath::callback2 ' + _.Procedure.ActiveProcedure._sourcePath );
      throw _.err( 'callback2' );
      return 'callback2';
    })

    console.log( 'sourcePath::program ' + _.Procedure.ActiveProcedure._sourcePath );
    _.time.out( 100, function timeOut1()
    {
      console.log( 'sourcePath::timeout ' + _.Procedure.ActiveProcedure._sourcePath );
      con.take( 'timeout1' );
    });

  }

}

asyncStackInConsequenceThen.timeOut = 30000;
asyncStackInConsequenceThen.description =
`
each callback has its own stack
`

//

function syncMaybeError( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.program({ routine : program });

  /* */

  a.appStartNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '- uncaught error -' ), 2 );
    test.identical( _.strCount( op.output, 'uncaught error' ), 2 );
    test.identical( _.strCount( op.output, 'nhandled' ), 0 );
    test.identical( _.strCount( op.output, `at program` ), 1 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 0 );
    test.identical( _.strCount( op.output, 'procedure::' ), 0 );
    test.identical( _.strCount( op.output, 'ncaught' ), 2 );

    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    const _ = require( toolsPath );
    _.include( 'wConsequence' );

    test.case = 'syncMaybe in try/catch block, must not throw erro, error is not attended'
    var con = _.Consequence().error( 'Test error' );
    test.mustNotThrowError( () =>
    {
      try
      {
        con.sync();
      }
      catch( err )
      {
      }
    });
  }
}

//

function symbolAsError( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.program({ routine : program });
  let ready = _.take( null );

  /* */

  ready.then( () =>
  {
    return a.appStartNonThrowing
    ({
      execPath : programPath,
      args : [ 'symbol:0' ],
    })
    .then( ( op ) =>
    {
      test.notIdentical( op.exitCode, 0 );
      test.identical( _.strCount( op.output, 'con1.tap Error.constructible Undefined' ), 1 );
      test.identical( _.strCount( op.output, 'Error1' ), 3 );
      test.identical( _.strCount( op.output, 'uncaught asynchronous error' ), 2 );
      return null;
    });
  });

  /* */

  ready.then( () =>
  {
    return a.appStartNonThrowing
    ({
      execPath : programPath,
      args : [ 'symbol:1' ],
    })
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( _.strCount( op.output, 'con1.tap Symbol Undefined' ), 1 );
      test.identical( _.strCount( op.output, 'Error1' ), 0 );
      test.identical( _.strCount( op.output, 'uncaught asynchronous error' ), 0 );
      return null;
    });
  });

  /* */

  return ready;

  function program()
  {
    const _ = require( toolsPath );
    require( consequencePath );
    _.include( 'wProcess' );
    let input = _.process.input();
    let con1 = new _.Consequence();

    con1.tap( ( err, arg ) =>
    {
      console.log( `con1.tap ${_.entity.strType( err )} ${_.entity.strType( arg )}` );
    });

    _.time.begin( context.t1, () =>
    {
      if( input.map.symbol )
      con1.error( Symbol.for( 'Error1' ) );
      else
      con1.error( 'Error1' );
    });
  }

}

symbolAsError.timeOut = 10000;

//

function tester( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.program({ routine : program });

  /* */

  a.appStartNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 0 );
    test.identical( _.strCount( op.output, 'procedure::' ), 0 );
    test.identical( _.strCount( op.output, 'ncaught' ), 0 );
    test.identical( _.strCount( op.output, 'nhandled' ), 0 );
    test.identical( _.strCount( op.output, 'Passed test suites 1 / 1' ), 1 );
    return null;
  });

  /* */

  return a.ready;

  function program()
  {

    const _ = require( toolsPath );
    require( consequencePath );
    _.include( 'wTesting' );

    function routine1( test )
    {
      test.true( true );
    }

    const Proto =
    {
      tests :
      {
        routine1,
      }
    }

    const Self = wTestSuite( Proto );
    wTester.test( Self.name );

  }

}

tester.timeOut = 60000;
tester.description =
`
  - async stack is here
  - async stack does not have duplicates
`

//

function timeLimit( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.program({ routine : program });

  /* */

  a.appStartNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 0 );
    test.identical( _.strCount( op.output, 'procedure::' ), 0 );
    test.identical( _.strCount( op.output, 'ncaught' ), 0 );
    test.identical( _.strCount( op.output, 'nhandled' ), 0 );
    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    const _ = require( toolsPath );
    let t = 25;
    _.include( 'wConsequence' );
    _.include( 'wProcedure' );
    var con = _.time.out( t );
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
  let a = context.assetFor( test, false );
  let programPath = a.program({ routine : program });

  /* */

  a.appStartNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'ncaught' ), 0 );
    test.identical( _.strCount( op.output, 'nhandled' ), 0 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 1 );
    test.identical( _.strCount( op.output, 'Waiting for 7 procedure(s)' ), 1 );
    test.identical( _.strCount( op.output, 'procedure::' ), 7 );
    test.identical( _.strCount( op.output, 'program.js:10' ), 5 );
    test.identical( _.strCount( op.output, 'program.js:13' ), 2 );
    test.identical( _.strCount( op.output, 'program.js:' ), 7 );
    test.identical( _.strCount( op.output, /v0(.|\n|\r)*v1(.|\n|\r)*v2(.|\n|\r)*v3(.|\n|\r)*v4/mg ), 1 );
    return null;
  });

  /* */


  return a.ready;

  function program()
  {
    const _ = require( toolsPath );
    _.include( 'wConsequence' );
    _.include( 'wProcedure' );
    let con = _.time.out( context.t2 );

    console.log( 'v0', _.time.spent( _.setup.startTime ) );

    con.timeLimit( context.t2*6, () =>
    {
      console.log( 'v2', _.time.spent( _.setup.startTime ) );
      return _.time.out( context.t2*4, () =>
      {
        console.log( 'v4', _.time.spent( _.setup.startTime ) );
        return 'a';
      });
    });

    _.time.out( context.t2*2, () =>
    {
      console.log( 'v3', _.time.spent( _.setup.startTime ) );
      _.procedure.terminationPeriod = context.t2*2;
      _.procedure.terminationBegin();
    });

    console.log( 'v1', _.time.spent( _.setup.startTime ) );
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
  let a = context.assetFor( test, false );
  let programPath = a.program({ routine : program });

  /* */

  a.appStartNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'ncaught' ), 0 );
    test.identical( _.strCount( op.output, 'nhandled' ), 0 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 1 );
    test.identical( _.strCount( op.output, 'Waiting for 2 procedure(s)' ), 1 );
    test.identical( _.strCount( op.output, 'procedure::' ), 2 );
    test.identical( _.strCount( op.output, 'program.js:11' ), 0 );
    test.identical( _.strCount( op.output, 'program.js:14' ), 2 );
    test.identical( _.strCount( op.output, 'program.js:' ), 2 );
    test.identical( _.strCount( op.output, /v0(.|\n|\r)*v1(.|\n|\r)*v2(.|\n|\r)*v3(.|\n|\r)*v4/mg ), 1 );
    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    const _ = require( toolsPath );
    _.include( 'wConsequence' );
    _.include( 'wProcedure' );

    var con = _.time.out( context.t2 );

    console.log( 'v0', _.time.spent( _.setup.startTime ) );

    con.timeLimit( context.t2*2, () =>
    {
      console.log( 'v2', _.time.spent( _.setup.startTime ) );
      return _.time.out( context.t2*6, () =>
      {
        console.log( 'v4', _.time.spent( _.setup.startTime ) );
        return 'a';
      });
    });

    _.time.out( context.t2*2, () =>
    {
      console.log( 'v3', _.time.spent( _.setup.startTime ) );
      _.procedure.terminationPeriod = context.t2*2;
      _.procedure.terminationBegin();
    });

    console.log( 'v1', _.time.spent( _.setup.startTime ) );
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
  let a = context.assetFor( test, false );
  let programPath = a.program({ routine : program });

  /* */

  a.appStartNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'ncaught' ), 0 );
    test.identical( _.strCount( op.output, 'nhandled' ), 0 );
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
    const _ = require( toolsPath );
    _.include( 'wConsequence' );
    _.include( 'wProcedure' );

    let t = 25;

    let timer = _.time.begin( t*2, () =>
    {
      console.log( 'v2' );
    });

    _.time.out( t, () => _.time.cancel( timer ) );

    console.log( 'v1' );

    _.procedure.terminationPeriod = 1000;
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
  let a = context.assetFor( test, false );
  let programPath = a.program({ routine : program });

  /* */

  a.appStartNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'ncaught' ), 0 );
    test.identical( _.strCount( op.output, 'nhandled' ), 0 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 0 );
    test.identical( _.strCount( op.output, 'procedure::' ), 0 );
    test.identical( _.strCount( op.output, /v1(.|\n|\r)*v2(.|\n|\r)/mg ), 1 );
    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    const _ = require( toolsPath );
    _.include( 'wConsequence' );
    _.include( 'wProcedure' );

    let t = 25;

    let timer = _.time.begin( t, () =>
    {
      console.log( 'v2' );
    });

    _.time.out( t*2, () => _.time.cancel( timer ) );

    console.log( 'v1' );

    _.procedure.terminationPeriod = 1000;
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
  let a = context.assetFor( test, false );
  let programPath = a.program({ routine : program });

  /* */

  a.appStartNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 0 );
    test.identical( _.strCount( op.output, 'ncaught' ), 0 );
    test.identical( _.strCount( op.output, 'nhandled' ), 0 );

    test.identical( _.strCount( op.output, 'v1' ), 1 );
    test.identical( _.strCount( op.output, 'v2' ), 1 );
    test.identical( _.strCount( op.output, 'v3' ), 1 );
    test.identical( _.strCount( op.output, 'v4' ), 0 );
    test.identical( _.strCount( op.output, 'v5' ), 0 );
    test.identical( _.strCount( op.output, 'v6' ), 1 );
    test.identical( _.strCount( op.output, 'argumentsCount 0' ), 1 );
    test.identical( _.strCount( op.output, 'errorsCount 0' ), 1 );
    test.identical( _.strCount( op.output, 'competitorsCount 2' ), 1 );

    var exp =
`
v1
v2
err : Symbol
arg : Undefined
v3
v6
argumentsCount 0
errorsCount 0
competitorsCount 2
`
    test.equivalent( op.output, exp );

    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    const _ = require( toolsPath );
    _.include( 'wProcedure' );
    _.include( 'wConsequence' );

    var con1 = _.time.out( context.t1*2, () => 1 );

    console.log( 'v1' );
    _.time.out( 1, function()
    {
      console.log( 'v2' );
      // con1.take( 2 );
      con1.error( _.dont );
      con1.give( ( err, got ) =>
      {
        console.log( `err : ${_.entity.strType( err )}` );
        console.log( `arg : ${_.entity.strType( got )}` );
        console.log( 'v3' );
      });
      con1.give( ( err, got ) =>
      {
        console.log( `err : ${_.entity.strType( err )}` );
        console.log( `arg : ${_.entity.strType( got )}` );
        console.log( 'v4' );
      });
      con1.give( ( err, got ) =>
      {
        console.log( `err : ${_.entity.strType( err )}` );
        console.log( `arg : ${_.entity.strType( got )}` );
        console.log( 'v5' );
      });
    })

    return _.time.out( context.t1*5 ).then( () =>
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
  let a = context.assetFor( test, false );
  let programPath = a.program({ routine : program });

  /* */

  a.appStartNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'ncaught' ), 0 );
    test.identical( _.strCount( op.output, 'nhandled' ), 0 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 0 );
    test.identical( _.strCount( op.output, 'procedure::' ), 0 );
    test.identical( _.strCount( op.output, /v1(.|\n|\r)*v2(.|\n|\r)/mg ), 1 );
    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    const _ = require( toolsPath );
    _.include( 'wConsequence' );
    _.include( 'wProcedure' );

    let t = 10;

    _.time.begin( t, () =>
    {
      console.log( 'v2' );
    });

    console.log( 'v1' );

    _.procedure.terminationPeriod = 1000;
    _.procedure.terminationBegin();

    _.time.out( t*2 );
  }

}

timeBegin.timeOut = 60000;
timeBegin.description =
`
- time begin leave no zombie procedures
`

//

function timeOutCancelWithErrorNotSymbol( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.program({ routine : program1 });

  /* */

  a.appStartNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'Only symbol in error channel of conseqeucne should be used to cancel timer' ), 1 );
    test.identical( _.strCount( op.output, 'Error of type Error.constructible was recieved instead' ), 1 );
    return null;
  });

  return a.ready;

  function program1()
  {
    const _ = require( toolsPath );
    _.include( 'wConsequence' );

    cancelErr = _.errAttend( 'Error1' );

    let con1 = _.time.out( context.t1*2, function( _timer )
    {
      console.log( `callback` );
    })
    .tap( function( err, _timer )
    {
      console.log( `err : ${err}` );
      console.log( `timer : ${_timer}` );
    });

    con1.error( cancelErr );

  }

}

// --
// declare
// --

const Proto =
{

  name : 'Tools.consequence.Ext',
  silencing : 1,

  onSuiteBegin,
  onSuiteEnd,

  context :
  {

    suiteTempPath : null,
    assetsOriginalPath : null,
    appJsPath : null,
    t1 : 100,
    t2 : 500,
    t3 : 10000,
    assetFor,

  },

  tests :
  {

    uncaughtSyncErrorOnExit,
    uncaughtAsyncErrorOnExit,
    uncaughtAsyncErrorOnExitBefore,

    AndKeepErrorAttend,
    AndKeepErrorNotAttend,

    asyncStackWithTimeOut,
    asyncStackWithConsequence,
    asyncStackInConsequenceTrivial,
    asyncStackInConsequenceThen,

    syncMaybeError,
    symbolAsError,

    tester,

    timeLimit,
    timeLimitWaitingEnough,
    timeLimitWaitingNotEnough,

    timeCancelBefore,
    timeCancelAfter,
    timeOutExternalMessage,
    timeBegin,
    timeOutCancelWithErrorNotSymbol,

  }

}

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
