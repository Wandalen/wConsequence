( function _Time_test_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{

  try
  {
    const _ = require( '../../../../node_modules/Tools' );
  }
  catch( err )
  {
    const _ = require( '../../../node_modules/Tools' );
  }

  const _ = _global_.wTools;
  _.include( 'wTesting' );
  require( '../../l9/consequence/Namespace.s' );
}

const _global = _global_;
const _ = _global_.wTools;

/* qqq : split test cases by / * * / */

// --
// etc
// --

function sleep( test )
{

  test.case = 'delay - 0';
  var start = _.time.now();
  _.time.sleep( 0 );
  var got = _.time.now() - start;
  test.true( 0 <= got );

  test.case = 'delay - 2';
  var start = _.time.now();
  _.time.sleep( 2 );
  var got = _.time.now() - start;
  test.true( 1 <= got );

  test.case = 'delay - 100';
  var start = _.time.now();
  _.time.sleep( 100 );
  var got = _.time.now() - start;
  test.true( 99 <= got );

  test.case = 'delay - 2000';
  var start = _.time.now();
  _.time.sleep( 2000 );
  var got = _.time.now() - start;
  test.true( 1999 <= got );

  /* - */

  if( !Config.debug )
  return;

  test.case = 'without arguments';
  test.shouldThrowErrorSync( () => _.time.sleep() );

  test.case = 'extra arguments';
  test.shouldThrowErrorSync( () => _.time.sleep( 10, '1', 10 ) );

  test.case = 'wrong type of delay';
  test.shouldThrowErrorSync( () => _.time.sleep( '10' ) );

  test.case = 'negative value of delay';
  test.shouldThrowErrorSync( () => _.time.sleep( -1 ) );

  test.case = 'Infinity value of delay';
  test.shouldThrowErrorSync( () => _.time.sleep( Infinity ) );

  test.case = 'delay has NaN value';
  test.shouldThrowErrorSync( () => _.time.sleep( NaN ) );
}

sleep.timeOut = 30000;

//

function stagesRun( test )
{
  let self = this;

  test.case = 'trivial';

  var src1Result, src2Result;

  var o = { a : 1, b : 2 };
  var got = _.stagesRun( [ src1, src2 ], { args : [ o ] });

  return got.thenKeep( ( arg ) =>
  {
    test.identical( src1Result, 1 );
    test.identical( src2Result, 2 );
    return arg;
  })

  function src1( o )
  {
    src1Result = o.a;
    return o.a;
  }

  function src2( o )
  {
    src2Result = o.b;
    return o.b;
  }

}

// --
// time out
// --

function timeOutStructural( test )
{
  let context = this;
  let ready = _.take( null );
  let track, pcounter, timer;

  ready.then( () => run( 0 ) );
  ready.then( () => run( 1 ) );

  return ready;

  /* */

  function run( returning )
  {
    test.case = `returning:${returning}`;

    track = [];
    pcounter = _.Procedure.Counter;

    track.push( 'a' );

    let con1 = _.time.out( context.t1, function( _timer )
    {
      timer = _timer;

      test.identical( arguments.length, 1 );
      test.identical( _.time.timerIs( timer ), true );
      test.identical( _.time.timerInBegin( timer ), false );
      test.identical( _.time.timerInCancelBegun( timer ), false );
      test.identical( _.time.timerInCancelEnded( timer ), false );
      test.identical( _.time.timerIsCanceled( timer ), false );
      test.identical( _.time.timerInEndBegun( timer ), true );
      test.identical( _.time.timerInEndEnded( timer ), false );

      track.push( `callback` );
      if( returning )
      return 13;
    })
    .tap( function( err, _timer )
    {

      if( returning )
      test.true( 13 === _timer );
      else
      test.true( timer === _timer );

      if( !returning )
      timer = _timer;

      test.identical( arguments.length, 2 );
      test.identical( _.time.timerIs( timer ), true );
      test.identical( _.time.timerInBegin( timer ), false );
      test.identical( _.time.timerInCancelBegun( timer ), false );
      test.identical( _.time.timerInCancelEnded( timer ), false );
      test.identical( _.time.timerIsCanceled( timer ), false );
      test.identical( _.time.timerInEndBegun( timer ), true );
      test.identical( _.time.timerInEndEnded( timer ), false );

      trackAdd( 'tap', err, timer );
    });

    track.push( 'b' );
    test.identical( _.Procedure.Counter - pcounter, 3 );
    pcounter = _.Procedure.Counter;
    test.identical( con1.toStr(), 'Consequence::time.out 0 / 2' );

    return _.time.out( context.t1*10, () =>
    {
      var exp = [ 'a', 'b', 'callback', 'tap.arg' ];
      test.identical( track, exp );
      if( _.Procedure.Counter - pcounter === 2 )
      test.identical( _.Procedure.Counter - pcounter, 2 );
      else
      test.identical( _.Procedure.Counter - pcounter, 4 );
      pcounter = _.Procedure.Counter;
      test.identical( con1.toStr(), 'Consequence::time.out 1 / 0' );

      test.identical( _.time.timerInBegin( timer ), false );
      test.identical( _.time.timerInCancelBegun( timer ), false );
      test.identical( _.time.timerInCancelEnded( timer ), false );
      test.identical( _.time.timerIsCanceled( timer ), false );
      test.identical( _.time.timerInEndBegun( timer ), false );
      test.identical( _.time.timerInEndEnded( timer ), true );

    });

  }

  function trackAdd( name, err, arg )
  {
    if( err )
    track.push( `${name}.${_.symbolIs( err ) ? 'symbol' : 'err'}` );
    else
    track.push( `${name}.arg` );
  }

}

//

/* qqq : extend test routine timeOutArgs */
function timeOutArgs( test )
{
  let context = this;
  let ready = _.take( null );
  let track;

  /* */

  ready.then( () =>
  {
    test.case = `arg`;

    track = [];
    track.push( 'a' );

    let con1 = _.time.out( context.t1, 13 )
    .tap( function( err, arg )
    {
      test.true( 13 === arg );
      test.identical( arguments.length, 2 );
      trackAdd( 'tap', err, arg );
    });

    track.push( 'b' );
    test.identical( con1.toStr(), 'Consequence::time.out 0 / 2' );

    return _.time.out( context.t1*10, () =>
    {
      var exp = [ 'a', 'b', 'tap.arg' ];
      test.identical( track, exp );
      test.identical( con1.toStr(), 'Consequence::time.out 1 / 0' );
    });

  });

  /* */

  ready.then( () =>
  {
    test.case = `context routine arg`;

    track = [];
    track.push( 'a' );

    let con1 = _.time.out( context.t1, 10, function( arg1, arg2, arg3 )
    {
      test.identical( arguments.length, 3 );
      test.identical( this, 10 );
      test.identical( arg1, 12 );
      test.identical( arg2, 13 );
      test.identical( _.timerIs( arg3 ), true );
      track.push( 'callback' );
      return 14;
    }, [ 12, 13 ] )
    .tap( function( err, arg )
    {
      test.identical( arg, 14 );
      test.identical( arguments.length, 2 );
      trackAdd( 'tap', err, arg );
    });

    track.push( 'b' );
    test.identical( con1.toStr(), 'Consequence::time.out 0 / 2' );

    return _.time.out( context.t1*10, () =>
    {
      var exp = [ 'a', 'b', 'callback', 'tap.arg' ];
      test.identical( track, exp );
      test.identical( con1.toStr(), 'Consequence::time.out 1 / 0' );
    });

  });

  /* */

  ready.then( () =>
  {
    test.case = `undefined routine arg`;

    track = [];
    track.push( 'a' );

    let con1 = _.time.out( context.t1, undefined, function( arg1, arg2, arg3 )
    {
      test.identical( arguments.length, 3 );
      test.identical( _.timerIs( this ), true );
      test.identical( arg1, 12 );
      test.identical( arg2, 13 );
      test.identical( _.timerIs( arg3 ), true );
      track.push( 'callback' );
      return 14;
    }, [ 12, 13 ] )
    .tap( function( err, arg )
    {
      test.identical( arg, 14 );
      test.identical( arguments.length, 2 );
      trackAdd( 'tap', err, arg );
    });

    track.push( 'b' );
    test.identical( con1.toStr(), 'Consequence::time.out 0 / 2' );

    return _.time.out( context.t1*10, () =>
    {
      var exp = [ 'a', 'b', 'callback', 'tap.arg' ];
      test.identical( track, exp );
      test.identical( con1.toStr(), 'Consequence::time.out 1 / 0' );
    });

  });
  /* */

  return ready;

  /* */

  function trackAdd( name, err, arg )
  {
    if( err )
    track.push( `${name}.${_.symbolIs( err ) ? 'symbol' : 'err'}` );
    else
    track.push( `${name}.arg` );
  }

}

//

/* qqq : extend test routine timeOutCallbackTimeOut */
function timeOutCallbackTimeOut( test )
{
  let context = this;
  let ready = _.take( null );
  let track;

  /* */

  ready.then( () =>
  {
    test.case = `time.out`;

    track = [];
    track.push( 'a' );
    let now = _.time.now();

    let con1 = _.time.out( context.t2, () => _.time.out( context.t2 ) )
    .tap( function( err, arg )
    {
      test.true( _.timerIs( arg ) );
      test.identical( arguments.length, 2 );
      test.ge( _.time.now() - now, context.t2*2 - context.timeAccuracy );
      trackAdd( 'tap', err, arg );
    });

    track.push( 'b' );
    test.identical( con1.toStr(), 'Consequence::time.out 0 / 2' );

    return _.time.out( context.t2*5, () =>
    {
      var exp = [ 'a', 'b', 'tap.arg' ];
      test.identical( track, exp );
      test.identical( con1.toStr(), 'Consequence::time.out 1 / 0' );
    });

  });

  /* */

  ready.then( () =>
  {
    test.case = `time.outError`;

    track = [];
    track.push( 'a' );
    let now = _.time.now();

    let con1 = _.time.outError( context.t2, ( err ) =>
    {
      test.true( _.errIs( err ) );
      _.errAttend( err );
      return _.time.out( context.t2 );
    })
    .tap( function( err, arg )
    {
      test.true( _.timerIs( arg ) );
      test.identical( arguments.length, 2 );
      test.ge( _.time.now() - now, context.t2*2 - context.timeAccuracy );
      trackAdd( 'tap', err, arg );
    });

    track.push( 'b' );
    test.identical( con1.toStr(), 'Consequence::time.out 0 / 2' );

    return _.time.out( context.t2*5, () =>
    {
      var exp = [ 'a', 'b', 'tap.arg' ];
      test.identical( track, exp );
      test.identical( con1.toStr(), 'Consequence::time.out 1 / 0' );
    });

  });

  /* */

  return ready;

  /* */

  function trackAdd( name, err, arg )
  {
    if( err )
    track.push( `${name}.${_.symbolIs( err ) ? 'symbol' : 'err'}` );
    else
    track.push( `${name}.arg` );
  }

}

//

function timeOutThrowingStructural( test )
{
  let context = this;
  let ready = _.take( null );
  let track, pcounter, timer;

  ready.then( () => run() );

  return ready;

  /* */

  function run()
  {
    test.case = `basic`;

    track = [];
    pcounter = _.Procedure.Counter;

    track.push( 'a' );

    let con1 = _.time.out( context.t1, function( _timer )
    {
      timer = _timer;

      test.identical( arguments.length, 1 );
      test.identical( _.time.timerIs( timer ), true );
      test.identical( _.time.timerInBegin( timer ), false );
      test.identical( _.time.timerInCancelBegun( timer ), false );
      test.identical( _.time.timerInCancelEnded( timer ), false );
      test.identical( _.time.timerIsCanceled( timer ), false );
      test.identical( _.time.timerInEndBegun( timer ), true );
      test.identical( _.time.timerInEndEnded( timer ), false );

      track.push( `callback` );
      throw _.errAttend( 'Error1' );
    })
    .tap( function( err, _timer )
    {

      test.identical( arguments.length, 2 );
      test.identical( _.time.timerIs( timer ), true );
      test.identical( _.time.timerInBegin( timer ), false );
      test.identical( _.time.timerInCancelBegun( timer ), false );
      test.identical( _.time.timerInCancelEnded( timer ), false );
      test.identical( _.time.timerIsCanceled( timer ), false );
      test.identical( _.time.timerInEndBegun( timer ), true );
      test.identical( _.time.timerInEndEnded( timer ), false );
      test.true( err.originalMessage === 'Error1' );

      trackAdd( 'tap', err, timer );
    });

    track.push( 'b' );
    test.identical( _.Procedure.Counter - pcounter, 3 );
    pcounter = _.Procedure.Counter;
    test.identical( con1.toStr(), 'Consequence::time.out 0 / 2' );

    return _.time.out( context.t1*10, () =>
    {
      var exp = [ 'a', 'b', 'callback', 'tap.err' ];
      test.identical( track, exp );
      if( _.Procedure.Counter - pcounter === 2 )
      test.identical( _.Procedure.Counter - pcounter, 2 );
      else
      test.identical( _.Procedure.Counter - pcounter, 3 );
      pcounter = _.Procedure.Counter;
      test.identical( con1.toStr(), 'Consequence::time.out 1 / 0' );

      test.identical( _.time.timerInBegin( timer ), false );
      test.identical( _.time.timerInCancelBegun( timer ), false );
      test.identical( _.time.timerInCancelEnded( timer ), false );
      test.identical( _.time.timerIsCanceled( timer ), false );
      test.identical( _.time.timerInEndBegun( timer ), false );
      test.identical( _.time.timerInEndEnded( timer ), true );

    });

  }

  function trackAdd( name, err, arg )
  {
    if( err )
    track.push( `${name}.${_.symbolIs( err ) ? 'symbol' : 'err'}` );
    else
    track.push( `${name}.arg` );
  }

}

//

function timeOutErrorStructural( test )
{
  let context = this;
  let ready = _.take( null );
  let track, pcounter;

  ready.then( () => run( 0 ) );
  ready.then( () => run( 1 ) );

  return ready;

  /* */

  function run( returning )
  {
    test.case = `returning:${returning}`;

    track = [];
    pcounter = _.Procedure.Counter;

    track.push( 'a' );

    let con1 = _.time.outError( context.t1, function( err )
    {

      test.identical( arguments.length, 1 );
      test.true( _.timerIs( this ) );

      test.true( _.errIs( err ) );
      test.true( !_.error.isAttended( err ) );
      test.true( _.error.isWary( err ) );
      test.true( !_.error.isSuspended( err ) );
      test.identical( err.originalMessage, 'Time out!' );
      test.identical( err.reason, 'time out' );

      track.push( `callback` );

      if( returning )
      _.errAttend( err );
      if( returning )
      return 13;
    })
    .tap( function( err, arg )
    {

      test.identical( arguments.length, 2 );
      if( returning )
      {
        test.true( 13 === arg );
      }
      else
      {
        test.true( _.errIs( err ) );
        test.true( !_.error.isAttended( err ) );
        test.true( _.error.isWary( err ) );
        test.true( !_.error.isSuspended( err ) );
        test.identical( err.originalMessage, 'Time out!' );
        test.identical( err.reason, 'time out' );
        _.errAttend( err );
      }

      trackAdd( 'tap', err, arg );
    });

    track.push( 'b' );
    test.identical( _.Procedure.Counter - pcounter, 3 );
    pcounter = _.Procedure.Counter;
    test.identical( con1.toStr(), 'Consequence::time.out 0 / 2' );

    return _.time.out( context.t1*10, () =>
    {
      var exp = [ 'a', 'b', 'callback', 'tap.err' ];
      if( returning )
      exp[ 3 ] = 'tap.arg';
      test.identical( track, exp );
      if( _.Procedure.Counter - pcounter === 2 )
      test.identical( _.Procedure.Counter - pcounter, 2 );
      else
      test.identical( _.Procedure.Counter - pcounter, 4 );
      pcounter = _.Procedure.Counter;
      test.identical( con1.toStr(), 'Consequence::time.out 1 / 0' );
    });

  }

  function trackAdd( name, err, arg )
  {
    if( err )
    track.push( `${name}.${_.symbolIs( err ) ? 'symbol' : 'err'}` );
    else
    track.push( `${name}.arg` );
  }

}

//

function timeOutErrorThrowingStructural( test )
{
  let context = this;
  let ready = _.take( null );
  let track, pcounter;

  ready.then( () => run() );

  return ready;

  /* */

  function run()
  {
    test.case = `basic`;

    track = [];
    pcounter = _.Procedure.Counter;

    track.push( 'a' );

    let con1 = _.time.outError( context.t1, function( err )
    {
      test.identical( arguments.length, 1 );

      test.true( _.errIs( err ) );
      test.true( !_.error.isAttended( err ) );
      test.true( _.error.isWary( err ) );
      test.true( !_.error.isSuspended( err ) );
      test.identical( err.originalMessage, 'Time out!' );
      test.identical( err.reason, 'time out' );
      _.errAttend( err );

      track.push( `callback` );
      throw _.err( 'Error1' );
    })
    .tap( function( err, arg )
    {
      test.identical( arguments.length, 2 );
      test.true( err.originalMessage === 'Error1' );
      test.true( _.errIs( err ) );
      test.true( !_.error.isAttended( err ) );
      test.true( _.error.isWary( err ) );
      test.true( !_.error.isSuspended( err ) );
      _.errAttend( err );
      trackAdd( 'tap', err, arg );
    });

    track.push( 'b' );
    test.identical( _.Procedure.Counter - pcounter, 3 );
    pcounter = _.Procedure.Counter;
    test.identical( con1.toStr(), 'Consequence::time.out 0 / 2' );

    return _.time.out( context.t1*10, () =>
    {
      var exp = [ 'a', 'b', 'callback', 'tap.err' ];
      test.identical( track, exp );
      if( _.Procedure.Counter - pcounter === 2 )
      test.identical( _.Procedure.Counter - pcounter, 2 );
      else
      test.identical( _.Procedure.Counter - pcounter, 3 );
      pcounter = _.Procedure.Counter;
      test.identical( con1.toStr(), 'Consequence::time.out 1 / 0' );
    });

  }

  function trackAdd( name, err, arg )
  {
    if( err )
    track.push( `${name}.${_.symbolIs( err ) ? 'symbol' : 'err'}` );
    else
    track.push( `${name}.arg` );
  }

}

//

function timeOutErrorThrowingUnattended( test )
{
  let context = this;
  let ready = _.take( null );
  let track, pcounter;

  ready.then( () => run() );

  return ready;

  /* */

  function run()
  {
    test.case = `basic`;

    let now = _.time.now();
    track = [];
    pcounter = _.Procedure.Counter;

    _.process.on( 'uncaughtError', uncaughtError_functor() );

    track.push( 'a' );

    // let con1 = _.time.outError( context.t2, _.time.out( context.t2 * 2 ) )
    let con1 = _.time.outError( context.t2 / 2, _.time.out( context.t2 * 2 ) )
    .tap( function( err, arg )
    {
      test.identical( arguments.length, 2 );
      test.ge( _.time.now() - now, context.t2*2 - context.timeAccuracy );
      test.true( _.consequenceIs( this ) );
      test.true( _.timerIs( arg ) );
      trackAdd( 'tap', err, arg );
    });

    track.push( 'b' );
    test.identical( _.Procedure.Counter - pcounter, 5 );
    pcounter = _.Procedure.Counter;
    test.identical( con1.toStr(), 'Consequence::time.out 0 / 2' );

    return _.time.out( context.t2*5, () =>
    {
      var exp = [ 'a', 'b', 'uncaughtError', 'tap.arg' ];
      test.identical( track, exp );
      if( _.Procedure.Counter - pcounter === 2 )
      test.identical( _.Procedure.Counter - pcounter, 2 );
      else
      test.identical( _.Procedure.Counter - pcounter, 3 );
      pcounter = _.Procedure.Counter;
      test.identical( con1.toStr(), 'Consequence::time.out 1 / 0' );
    });

  }

  function trackAdd( name, err, arg )
  {
    if( err )
    track.push( `${name}.${_.symbolIs( err ) ? 'symbol' : 'err'}` );
    else
    track.push( `${name}.arg` );
  }

  function uncaughtError_functor()
  {
    return function uncaughtError( e )
    {
      console.log( 'uncaughtError' );
      test.identical( e.err.originalMessage, 'Time out!' );
      test.identical( e.err.reason, 'time out' );
      _.errAttend( e.err );
      track.push( 'uncaughtError' );
      _.process.off( 'uncaughtError', uncaughtError );
    }
  }

}

//

function timeOutCancelWithCancel( test )
{
  let context = this;
  let ready = _.take( null );
  let track, pcounter, timer;
  ready.then( () => run() );

  return ready;

  /* */

  function run()
  {
    test.case = `basic`;

    track = [];
    pcounter = _.Procedure.Counter;
    track.push( 'a' );

    let con1 = _.time.out( context.t1, function( _timer )
    {
      timer = _timer;
      test.identical( arguments.length, 1 );
      track.push( `callback` );
    })
    .tap( function( err, arg )
    {
      test.identical( arguments.length, 2 );
      trackAdd( 'tap', err, arg );
    });

    track.push( 'b' );
    test.identical( _.Procedure.Counter - pcounter, 3 );
    pcounter = _.Procedure.Counter;
    test.identical( con1.toStr(), 'Consequence::time.out 0 / 2' );
    con1.cancel();
    test.identical( con1.toStr(), 'Consequence::time.out 0 / 0' );

    return _.time.out( context.t1*10, () =>
    {
      var exp = [ 'a', 'b' ];
      test.identical( track, exp );
      test.identical( _.Procedure.Counter - pcounter, 3 );
      pcounter = _.Procedure.Counter;
      test.identical( con1.toStr(), 'Consequence::time.out 0 / 0' );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );
    });

  }

  function trackAdd( name, err, arg )
  {
    if( err )
    track.push( `${name}.${_.symbolIs( err ) ? 'symbol' : 'err'}` );
    else
    track.push( `${name}.arg` );
  }

}

//

function timeOutCancelWithErrorSymbol( test )
{
  let context = this;
  let ready = _.take( null );
  let track, pcounter, timer;
  ready.then( () => run( _.dont ) );
  ready.then( () => run( Symbol.for( 'symbol1' ) ) );

  return ready;

  /* */

  function run( cancelErr )
  {
    test.case = `${_.entity.strType( cancelErr )}`;

    track = [];
    pcounter = _.Procedure.Counter;

    track.push( 'a' );

    let con1 = _.time.out( context.t1*2, function( _timer )
    {
      track.push( `callback` );
    })
    .tap( function( err, _timer )
    {
      test.true( err === cancelErr );
      trackAdd( 'tap', err, _timer );
    });

    track.push( 'b' );
    test.identical( _.Procedure.Counter - pcounter, 3 );
    pcounter = _.Procedure.Counter;
    test.identical( con1.toStr(), 'Consequence::time.out 0 / 2' );
    con1.error( cancelErr );
    test.identical( con1.toStr(), 'Consequence::time.out 1 / 0' );

    return _.time.out( context.t1*10, () =>
    {
      var exp = [ 'a', 'b', 'tap.symbol' ];
      if( !_.symbolIs( cancelErr ) )
      exp[ 2 ] = 'tap.err';
      test.identical( track, exp );
      if( _.Procedure.Counter - pcounter === 2 )
      test.identical( _.Procedure.Counter - pcounter, 2 );
      else
      test.identical( _.Procedure.Counter - pcounter, 4 );
      pcounter = _.Procedure.Counter;
      test.identical( con1.toStr(), 'Consequence::time.out 1 / 0' );
    });

  }

  function trackAdd( name, err, arg )
  {
    if( err )
    track.push( `${name}.${_.symbolIs( err ) ? 'symbol' : 'err'}` );
    else
    track.push( `${name}.arg` );
  }

}

//

// function timeOutCancelWithArgument( test )
// {
//   let context = this;
//   let ready = _.take( null );
//   let track;
//   let pcounter;
//   let timer;
//
//   ready.then( () => run( _.dont ) );
//   ready.then( () => run( null ) );
//   ready.then( () => run( Symbol.for( 'symbol1' ) ) );
//   ready.then( () => run( _.errAttend( 'Error1' ) ) );
//
//   return ready;
//
//   /* */
//
//   function run( cancelArg )
//   {
//     test.case = `${_.entity.strType( cancelArg )}`;
//
//     track = [];
//     pcounter = _.Procedure.Counter;
//
//     track.push( 'a' );
//
//     let con1 = _.time.out( context.t1*2, function( _timer )
//     {
//       track.push( `callback` );
//     })
//     .tap( function( err, arg )
//     {
//       test.true( arg === cancelArg );
//       trackAdd( 'tap', err, arg );
//     });
//
//     track.push( 'b' );
//     test.identical( _.Procedure.Counter - pcounter, 3 );
//     pcounter = _.Procedure.Counter;
//     test.identical( con1.toStr(), 'Consequence::time.out 0 / 2' );
//     con1.take( cancelArg );
//     test.identical( con1.toStr(), 'Consequence::time.out 1 / 0' );
//
//     return _.time.out( context.t1*10, () =>
//     {
//       var exp = [ 'a', 'b', 'tap.arg' ];
//       test.identical( track, exp );
//       if( _.Procedure.Counter - pcounter === 2 )
//       test.identical( _.Procedure.Counter - pcounter, 2 );
//       else
//       test.identical( _.Procedure.Counter - pcounter, 6 );
//       pcounter = _.Procedure.Counter;
//       test.identical( con1.toStr(), 'Consequence::time.out 1 / 0' );
//     });
//
//   }
//
//   function trackAdd( name, err, arg )
//   {
//     if( err )
//     track.push( `${name}.${_.symbolIs( err ) ? 'symbol' : 'err'}` );
//     else
//     track.push( `${name}.arg` );
//   }
//
// }

//

function timeOutCancelInsideOfCallback( test )
{
  let context = this;
  let track = [];

  var timer = _.time.begin( 1, () =>
  {
    track.push( 'v1' );
    _.time.cancel( timer );
    track.push( 'v2' );
  });

  track.push( 'v0' );

  return _.time.out( context.t1*15 ).then( () =>
  {
    test.identical( track, [ 'v0', 'v1', 'v2' ] );
    return null;
  });
}

//

function timeOutCancelOutsideOfCallback( test )
{
  let context = this;
  let track = [];

  var timer = _.time.begin( context.t1*3, () =>
  {
    track.push( 'v1' );
  });

  _.time.cancel( timer );
  track.push( 'v0' );

  return _.time.out( context.t1*15 ).then( () =>
  {
    test.identical( track, [ 'v0' ] );
    return null;
  });
}

timeOutCancelOutsideOfCallback.timeOut = 10000;

//

function timeOutCancelZeroDelayInsideOfCallback( test )
{
  let context = this;
  let track = [];

  var timer = _.time.begin( 0, () =>
  {
    track.push( 'v1' );
    _.time.cancel( timer );
    track.push( 'v2' );
  });

  track.push( 'v0' );

  return _.time.out( context.t1*15 ).then( () =>
  {
    test.identical( track, [ 'v0', 'v1', 'v2' ] );
    return null;
  });
}

//

function timeOutCancelZeroDelayOutsideOfCallback( test )
{
  let context = this;
  let track = [];

  var timer = _.time.begin( 0, () =>
  {
    track.push( 'v1' );
  });

  _.time.cancel( timer );
  track.push( 'v0' );

  return _.time.out( context.t1*15 ).then( () =>
  {
    test.identical( track, [ 'v0' ] );
    return null;
  });
}

//

function timeOut( test )
{
  let context = this;
  var ready = new _.Consequence().take( null )

  /* */

  .then( function()
  {
    test.case = 'delay only';
    var timeBefore = _.time.now();
    return _.time.out( context.t2 )
    .finally( function( err, arg )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, context.t2 - context.timeAccuracy );
      test.true( _.timerIs( arg ) );
      test.identical( err, undefined );
      return null;
    });
  })

  /* */

  .then( function()
  {
    test.case = 'delay + routine';
    var timeBefore = _.time.now();
    return _.time.out( context.t2, () => null )
    .finally( function( err, arg )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, context.t2 - context.timeAccuracy );
      test.identical( arg, null );
      test.identical( err, undefined );
      return null;
    });
  })

  /* */

  .then( function()
  {
    test.case = 'delay + routine that returns a value';
    var timeBefore = _.time.now();
    var value = 'value';
    return _.time.out( context.t2, () => value )
    .finally( function( err, arg )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, context.t2 - context.timeAccuracy );
      test.identical( arg, value );
      test.identical( err, undefined );
      return null;
    });
  })

  /* */

  .then( function()
  {
    test.case = 'delay + routine that returns a consequence';
    var timeBefore = _.time.now();
    return _.time.out( context.t2, () => _.time.out( context.t2 ) )
    .finally( function( err, arg )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, 2 * context.t2 - context.timeAccuracy );
      test.true( _.timerIs( arg ) );
      test.identical( err, undefined );
      return null;
    });
  })

  /* */

  .then( function()
  {
    test.case = 'delay + routine that calls another timeOut';
    var timeBefore = _.time.now();
    return _.time.out( context.t2, () => { _.time.out( context.t2 ); return null } )
    .finally( function( err, arg )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, context.t2 - context.timeAccuracy );
      test.identical( err, undefined );
      test.identical( arg, null );
      return null;
    });
  })

  /* */

  .then( function()
  {
    test.case = 'delay + context + routine + arguments';
    var timeBefore = _.time.now();
    function r( delay )
    {
      return delay / 2;
    }
    return _.time.out( context.t2, undefined, r, [ context.t2 ] )
    .finally( function( err, arg )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, context.t2 - context.timeAccuracy );
      test.identical( arg, context.t2 / 2 );
      test.identical( err, undefined );
      return null;
    });
  })

  /* */

  .then( function()
  {
    test.case = 'delay + consequence, first delay greater';
    var timeBefore = _.time.now();

    return _.time.out( context.t2, _.time.out( context.t2 * 2 ) )
    .finally( function( err, arg )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, 2 * context.t2 - context.timeAccuracy );
      test.true( _.timerIs( arg ) );
      test.identical( err, undefined );
      return null;
    });
  })

  /* */

  .then( function()
  {
    test.case = 'delay + consequence, second delay greater';
    var timeBefore = _.time.now();

    return _.time.out( context.t2*3, _.time.out( context.t2 * 2 ) )
    .finally( function( err, arg )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, 3 * context.t2 - context.timeAccuracy );
      test.true( _.timerIs( arg ) );
      test.identical( err, undefined );
      return null;
    });
  })

  /* */

  .then( function()
  {
    test.case = 'delay + consequence that returns delayed value, launched serially';
    var timeBefore = _.time.now();
    var val = 13;

    return _.time.out( context.t2, () => _.time.out( context.t2 * 2, () => val ) )
    .finally( function( err, arg )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, context.t2 * 3- context.timeAccuracy );
      test.identical( err, undefined );
      test.identical( arg, val );
      return null;
    })
  })

  /* */

  .then( function()
  {
    test.case = 'delay + consequence that returns delayed value, launched concurrently';
    var timeBefore = _.time.now();
    var val = 13;

    return _.time.out( context.t2, _.time.out( context.t2 * 2, () => val ) )
    .finally( function( err, arg )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, context.t2 * 2 - context.timeAccuracy );
      test.identical( err, undefined );
      test.identical( arg, val );
      return null;
    })
  })

  /* */

  .then( function()
  {
    test.case = 'delay + consequence that returns delayed value, launched concurrently';
    var timeBefore = _.time.now();

    return _.time.out( context.t2, _.time.out( context.t2 * 2, () => _.time.out( context.t2 * 2 ) ) )
    .finally( function( err, arg )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, context.t2 * 4- context.timeAccuracy );
      test.identical( err, undefined );
      test.identical( _.timerIs( arg ), true );
      // test.identical( arg, _.time.out );
      return null;
    })
  })

  /* */

  .then( function()
  {
    test.case = 'delay + consequence + error';
    var timeBefore = _.time.now();

    return _.time.out( context.t2, _.time.out( context.t2 * 2, () => { throw _.err( 'err' ) } ) )
    .finally( function( err, arg )
    {
      if( err )
      _.errAttend( err );
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, 2 * context.t2 - context.timeAccuracy );
      test.true( _.errIs( err ) );
      test.identical( arg, undefined );
      return null;
    });
  })

  /* */

  .then( function()
  {
    test.case = 'stop timer with dont';
    var timeBefore = _.time.now();

    var t = _.time.out( context.t2 );
    t.finally( function( err, arg )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, context.t2 / 2 - context.timeAccuracy );
      test.identical( err, _.dont );
      test.identical( arg, undefined );
      return null;
    })
    _.time.out( context.t2 / 2, () =>
    {
      t.error( _.dont );
      return null;
    });

    return t;
  })

  /* */

  .then( function()
  {
    test.case = 'stop timer with other symbol';
    var timeBefore = _.time.now();

    var t = _.time.out( context.t2 );
    t.finally( function( err, arg )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, context.t2 / 2 - context.timeAccuracy );
      test.identical( err, Symbol.for( 'symbol1' ) );
      test.identical( arg, undefined );
      return null;
    })
    _.time.out( context.t2 / 2, () =>
    {
      t.error( Symbol.for( 'symbol1' ) );
      return null;
    });

    return t;
  })

  /* */

  // .then( function()
  // {
  //   test.case = 'stop timer with error, routine passed';
  //   var timeBefore = _.time.now();
  //   var called = false;
  //
  //   var t = _.time.out( context.t2, () => { called = true } );
  //   t.finally( function( err, arg )
  //   {
  //     var elapsedTime = _.time.now() - timeBefore;
  //     test.ge( elapsedTime, context.t2 / 2 - context.timeAccuracy );
  //     test.identical( err, undefined );
  //     test.identical( arg, _.dont );
  //     test.identical( called, false );
  //     return null;
  //   })
  //   _.time.out( context.t2 / 2, () =>
  //   {
  //     t.take( _.dont );
  //     return null;
  //   });
  //
  //   return t;
  // })

  /* */

  .then( function()
  {
    test.case = 'stop after timeOut';
    var timeBefore = _.time.now();

    var t = _.time.out( context.t2, () => null );
    t.give( function( err, arg )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, context.t2 - context.timeAccuracy );
      test.identical( arg, null );
      test.identical( err, undefined );
    });

    return _.time.out( context.t2 + 50, function()
    {
      t.take( _.dont );
      t.give( ( err, arg ) =>
      {
        test.identical( err, undefined );
        test.identical( arg, _.dont );
      });
      return null;
    });

    return t;
  })

  /* */

  // .then( function()
  // {
  //   test.case = 'give msg before timeOut';
  //   var track = [];
  //   var timeBefore = _.time.now();
  //   var returnValue = 1;
  //   var msg = 2;
  //
  //   track.push( 'a' );
  //   var t = _.time.out( context.t2, () => returnValue );
  //
  //   _.time.out( context.t2 / 2, function()
  //   {
  //     track.push( 'b' );
  //     t.take( msg );
  //     t.give( ( err, arg ) =>
  //     {
  //       test.identical( arg, msg );
  //       test.identical( err, undefined );
  //       track.push( 'c' );
  //       return 1;
  //     });
  //     t.give( ( err, arg ) =>
  //     {
  //       track.push( 'd' );
  //       var elapsedTime = _.time.now() - timeBefore;
  //       test.ge( elapsedTime, context.t2 - context.timeAccuracy );
  //       test.identical( arg, returnValue );
  //       test.identical( err, undefined );
  //     })
  //     return null;
  //   })
  //
  //   return _.time.out( context.t2*2, function()
  //   {
  //     let exp = [ 'a', 'b', 'c' ];
  //     test.identical( track, exp );
  //     t.cancel();
  //   });
  // })
  //
  // /* */
  //
  // .then( function()
  // {
  //   test.case = 'stop timer with error + arg, routine passed';
  //   var timeBefore = _.time.now();
  //   var called = false;
  //
  //   var t = _.time.out( context.t2, () => { called = true } );
  //   t.finally( function( err, arg )
  //   {
  //     var elapsedTime = _.time.now() - timeBefore;
  //     test.ge( elapsedTime, context.t2 / 2 - context.timeAccuracy );
  //     test.identical( err, undefined );
  //     test.identical( arg, _.dont );
  //     test.identical( called, false );
  //     return null;
  //   })
  //   _.time.out( context.t2 / 2, () =>
  //   {
  //     t.take( _.dont );
  //     return null;
  //   });
  //
  //   return t;
  // })

  /* */

  .then( function()
  {

    test.case = 'could have the second argument';

    let f = () => 'a';

    test.mustNotThrowError( () => _.time.out( 0, 'x' ) );
    test.mustNotThrowError( () => _.time.out( 0, 13 ) );
    test.mustNotThrowError( () => _.time.out( 0, f ) );

    _.time.out( 0, 'x' )
    .finally( ( err, arg ) =>
    {
      test.identical( arg, 'x' );
      test.identical( err, undefined );
      return null;
    });
    _.time.out( 0, 13 )
    .finally( ( err, arg ) =>
    {
      test.identical( arg, 13 );
      test.identical( err, undefined );
      return null;
    });
    _.time.out( 0, f )
    .finally( ( err, arg ) =>
    {
      test.identical( arg, 'a' );
      test.identical( err, undefined );
      return null;
    });

    return _.time.out( 50 );
  })

  /* */

  .then( function()
  {

    if( !Config.debug )
    return null;

    test.case = 'delay must be number';
    test.shouldThrowErrorSync( () => _.time.out( 'x' ) );

    test.case = 'if two arguments provided, second must consequence/routine';
    test.shouldThrowErrorSync( () => _.time.out() );

    test.case = 'if four arguments provided, third must routine';
    test.shouldThrowErrorSync( () => _.time.out( 0, {}, 'x', [] ) );

    return null;
  })

  /* */

  return ready;
}

timeOut.timeOut = 20000;

function timeOutSourcePath( test )
{
  let context = this;
  var ready = new _.Consequence().take( null );

  /* */

  ready.then( function timeOut1()
  {
    test.case = '_sourcePath';

    let timeOut = _.time.out( context.t2*4 );

    test.identical( timeOut.competitorsCount(), 1 );

    timeOut.competitorsGet().forEach( ( competitor ) =>
    {
      test.false( _.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'timeOut1' ) );
    })

    return timeOut.finally( function( err, arg )
    {
      test.identical( timeOut.competitorsCount(), 1 );
      return null;
    });
  })

  return ready;

}

//

// function timeOutMode01( test )
// {
//   let context = this;
//   var mode = _.Consequence.AsyncModeGet();
//   var ready = new _.Consequence().take( null )
//
//   /* AsyncCompetitorHanding : 0, AsyncResourceAdding : 1 */
//
//   .finally( () =>
//   {
//     _.Consequence.AsyncModeSet([ 0, 1 ]);
//     return null;
//   })
//   .then( function( arg )
//   {
//     test.case = 'delay only';
//     var timeBefore = _.time.now();
//     var t = _.time.out( context.t2 );
//     return new _.Consequence().first( t )
//     .then( function( arg )
//     {
//       test.identical( t.resourcesGet().length, 1 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       t.give( function( err, arg )
//       {
//         var elapsedTime = _.time.now() - timeBefore;
//         test.ge( elapsedTime, context.t2 - context.timeAccuracy );
//         test.true( _.timerIs( arg ) );
//         test.identical( err, undefined );
//       });
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//     .finally(function()
//     {
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//   })
//
//   /**/
//
//   .then( function( arg )
//   {
//     test.case = 'delay + routine';
//     var timeBefore = _.time.now();
//     var t = _.time.out( context.t2, () => null );
//     return new _.Consequence().first( t )
//     .then( function( arg )
//     {
//       t.give( function( err, arg )
//       {
//         var elapsedTime = _.time.now() - timeBefore;
//         test.ge( elapsedTime, context.t2 - context.timeAccuracy );
//         test.identical( _.timerIs( arg ), true );
//         test.identical( err, undefined );
//       });
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//     .finally(function()
//     {
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//   })
//
//   /**/
//
//   .then( function( arg )
//   {
//     test.case = 'delay + routine that returns a value';
//     var timeBefore = _.time.now();
//     var value = 'value';
//     debugger;
//     var t = _.time.out( context.t2, () =>
//     {
//       debugger;
//       return value;
//     } );
//     t.tap( function( err, arg )
//     {
//       debugger;
//     });
//     return new _.Consequence().first( t )
//     .then( function( arg1 )
//     {
//       debugger;
//       t.give( function( err, arg )
//       {
//         debugger;
//         var elapsedTime = _.time.now() - timeBefore;
//         test.ge( elapsedTime, context.t2 - context.timeAccuracy );
//         test.true( arg === value );
//         test.identical( err, undefined );
//       });
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//     .finally(function()
//     {
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//   })
//
//   /**/
//
//   .then( function( arg )
//   {
//     test.case = 'delay + routine that returns a consequence';
//     var timeBefore = _.time.now();
//     var t = _.time.out( context.t2, () => _.time.out( context.t2 ) );
//     return new _.Consequence().first( t )
//     .then( function( arg )
//     {
//       t.give( function( err, arg )
//       {
//         var elapsedTime = _.time.now() - timeBefore;
//         test.ge( elapsedTime, context.t2 - context.timeAccuracy );
//         test.true( _.timerIs( arg ));
//         test.identical( err, undefined );
//       });
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//     .finally(function()
//     {
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//   })
//
//   /**/
//
//   .then( function( arg )
//   {
//     test.case = 'delay + routine that calls another timeOut';
//     var timeBefore = _.time.now();
//     var t = _.time.out( context.t2, () => _.time.out( context.t2 ) );
//     return new _.Consequence().first( t )
//     .then( function( arg )
//     {
//       t.give( function( err, arg )
//       {
//         var elapsedTime = _.time.now() - timeBefore;
//         test.ge( elapsedTime, context.t2 - context.timeAccuracy );
//         test.identical( _.timerIs( arg ), true );
//         // test.identical( arg, _.time.out );
//         test.identical( err, undefined );
//       });
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//     .finally(function()
//     {
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//   })
//
//   /**/
//
//   .then( function( arg )
//   {
//     test.case = 'delay + context + routine + arguments';
//     var timeBefore = _.time.now();
//     function r( delay )
//     {
//       return delay * 13;
//     }
//     var t = _.time.out( context.t2, undefined, r, [ context.t2 ] );
//     return new _.Consequence().first( t )
//     .then( function( arg )
//     {
//       t.give( function( err, arg )
//       {
//         var elapsedTime = _.time.now() - timeBefore;
//         test.ge( elapsedTime, context.t2 - context.timeAccuracy );
//         test.identical( arg, context.t2 * 13 );
//         test.identical( err, undefined );
//       });
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//     .finally(function()
//     {
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//   })
//
//   /**/
//
//   .then( function( arg )
//   {
//     test.case = 'stop timer with error';
//     var timeBefore = _.time.now();
//     var t = _.time.out( context.t2 );
//
//     // _.time.out( context.t2 / 2, () => { t.error( _.errAttend( 'stop' ) ); return null; });
//     _.time.out( context.t2 / 2, () =>
//     {
//       t.take( _.dont );
//       return null;
//     });
//
//     return new _.Consequence().first( t )
//     .then( function( arg )
//     {
//       test.identical( t.resourcesGet().length, 1 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       t.give( function( err, arg )
//       {
//         var elapsedTime = _.time.now() - timeBefore;
//         test.ge( elapsedTime, context.t2 / 2 );
//         // test.identical( arg, undefined );
//         // test.identical( _.strHas( _.err( err ).message, 'stop' ), true );
//         test.identical( err, undefined );
//         test.identical( arg, _.dont );
//       });
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//     .finally( function()
//     {
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//   })
//
//   /**/
//
//   .then( function( arg )
//   {
//     test.case = 'stop timer with error, routine passed';
//     var timeBefore = _.time.now();
//     var called = false;
//
//     var t = _.time.out( context.t2, () => { called = true } );
//     // _.time.out( context.t2 / 2, () => { t.error( _.errAttend( 'stop' ) ); return null; });
//     _.time.out( context.t2 / 2, () =>
//     {
//       t.take( _.dont );
//       return null;
//     });
//
//     return new _.Consequence().first( t )
//     .then( function( arg )
//     {
//       t.give( function( err, arg )
//       {
//         var elapsedTime = _.time.now() - timeBefore;
//         test.ge( elapsedTime, context.t2 / 2 );
//         // test.identical( arg, undefined );
//         // test.identical( _.strHas( _.err( err ).message, 'stop' ), true );
//         test.identical( err, undefined );
//         test.identical( arg, _.dont );
//         test.identical( called, false );
//       });
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//     .finally( function()
//     {
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//   })
//
//   /**/
//
//   .then( function( arg )
//   {
//     test.case = 'stop after timeOut';
//     var timeBefore = _.time.now();
//     var t = _.time.out( context.t2, () => null );
//
//     var con = new _.Consequence();
//     con.first( t );
//     con.then( function( arg )
//     {
//       t.give( function( err, arg )
//       {
//         var elapsedTime = _.time.now() - timeBefore;
//         test.ge( elapsedTime, context.t2 - context.timeAccuracy );
//         test.identical( _.timerIs( arg ), true );
//         test.identical( err, undefined );
//       })
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//     .finally(function()
//     {
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//
//     return _.time.out( context.t2 + 50, function()
//     {
//       // t.error( _.errAttend( 'stop' ) );
//       t.take( _.dont );
//       t.give( ( err, arg ) =>
//       {
//         test.identical( err, undefined );
//         test.identical( arg, _.dont );
//         // test.identical( _.strHas( _.err( err ).message, 'stop' ), true );
//       });
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//     .then( function( arg )
//     {
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//
//       _.Consequence.AsyncModeSet( mode );
//       return null;
//     });
//
//   })
//
//   /**/
//
//   return ready;
// }
//
// timeOutMode10.timeOut = 30000;
//
// //
//
// function timeOutMode10( test )
// {
//   let context = this;
//   var mode = _.Consequence.AsyncModeGet();
//   var ready = new _.Consequence().take( null )
//   /* AsyncCompetitorHanding : 1, AsyncResourceAdding : 0, */
//
//   .finally( () =>
//   {
//     _.Consequence.AsyncModeSet([ 1, 0 ])
//     return null;
//   })
//   .then( function( arg )
//   {
//     test.case = 'delay only';
//     var timeBefore = _.time.now();
//     var t = _.time.out( context.t2 );
//     return new _.Consequence().first( t )
//     .then( function( arg )
//     {
//       t.give( function( err, arg )
//       {
//         var elapsedTime = _.time.now() - timeBefore;
//         test.ge( elapsedTime, context.t2 - context.timeAccuracy );
//         test.true( _.timerIs( arg ) );
//         test.identical( err, undefined );
//       });
//       test.identical( t.resourcesGet().length, 1 );
//       test.identical( t.competitorsEarlyGet().length, 1 );
//       return null;
//     })
//     .delay( 1 )
//     .then( function()
//     {
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//   })
//
//   /**/
//
//   .then( function( arg )
//   {
//     test.case = 'delay + routine';
//     var timeBefore = _.time.now();
//     var t = _.time.out( context.t2, () => null );
//     return new _.Consequence().first( t )
//     .then( function( arg )
//     {
//       t.give( function( err, arg )
//       {
//         var elapsedTime = _.time.now() - timeBefore;
//         test.ge( elapsedTime, context.t2 - context.timeAccuracy );
//         test.identical( _.timerIs( arg ), true );
//         test.identical( err, undefined );
//       });
//       test.identical( t.resourcesGet().length, 1 );
//       test.identical( t.competitorsEarlyGet().length, 1 );
//       return null;
//     })
//     .delay( 1 )
//     .then( function()
//     {
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//   })
//
//   /**/
//
//   .then( function( arg )
//   {
//     test.case = 'delay + routine that returns a value';
//     var timeBefore = _.time.now();
//     var value = 'value';
//     var t = _.time.out( context.t2, () => value );
//     return new _.Consequence().first( t )
//     .then( function( arg )
//     {
//       t.give( function( err, arg )
//       {
//         var elapsedTime = _.time.now() - timeBefore;
//         test.ge( elapsedTime, context.t2 - context.timeAccuracy );
//         test.true( arg === value );
//         test.identical( err, undefined );
//       });
//       test.identical( t.resourcesGet().length, 1 );
//       test.identical( t.competitorsEarlyGet().length, 1 );
//       return null;
//     })
//     .delay( 1 )
//     .then( function()
//     {
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//   })
//
//   /**/
//
//   .then( function( arg )
//   {
//     test.case = 'delay + routine that returns a consequence';
//     var timeBefore = _.time.now();
//     var t = _.time.out( context.t2, () => _.time.out( context.t2 ) );
//     return new _.Consequence().first( t )
//     .then( function( arg )
//     {
//       t.give( function( err, arg )
//       {
//         var elapsedTime = _.time.now() - timeBefore;
//         test.ge( elapsedTime, context.t2 - context.timeAccuracy );
//         test.true( _.timerIs( arg ));
//         test.identical( err, undefined );
//       });
//       test.identical( t.resourcesGet().length, 1 );
//       test.identical( t.competitorsEarlyGet().length, 1 );
//       return null;
//     })
//     .delay( 1 )
//     .then( function()
//     {
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//   })
//
//   /**/
//
//   .then( function( arg )
//   {
//     test.case = 'delay + routine that calls another timeOut';
//     var timeBefore = _.time.now();
//     var t = _.time.out( context.t2, () => { _.time.out( context.t2 ); return null; } );
//     return new _.Consequence().first( t )
//     .then( function( arg )
//     {
//       t.give( function( err, arg )
//       {
//         var elapsedTime = _.time.now() - timeBefore;
//         test.ge( elapsedTime, context.t2 - context.timeAccuracy );
//         test.identical( _.timerIs( arg ), true );
//         test.identical( err, undefined );
//       });
//       test.identical( t.resourcesGet().length, 1 );
//       test.identical( t.competitorsEarlyGet().length, 1 );
//       return null;
//     })
//     .delay( 1 )
//     .then( function()
//     {
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//   })
//
//   /**/
//
//   .then( function( arg )
//   {
//     test.case = 'delay + context + routine + arguments';
//     var timeBefore = _.time.now();
//     function r( delay )
//     {
//       return delay / 2;
//     }
//     var t = _.time.out( context.t2, undefined, r, [ context.t2 ] );
//     return new _.Consequence().first( t )
//     .then( function( arg )
//     {
//       t.give( function( err, arg )
//       {
//         var elapsedTime = _.time.now() - timeBefore;
//         test.ge( elapsedTime, context.t2 - context.timeAccuracy );
//         test.true( arg === context.t2 / 2 );
//         test.identical( err, undefined );
//       });
//       test.identical( t.resourcesGet().length, 1 );
//       test.identical( t.competitorsEarlyGet().length, 1 );
//       return null;
//     })
//     .delay( 1 )
//     .then( function()
//     {
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//   })
//
//   /**/
//
//   .then( function( arg )
//   {
//     test.case = 'stop timer with error';
//     var timeBefore = _.time.now();
//     var t = _.time.out( context.t2 );
//
//     // _.time.out( context.t2 / 2, () =>
//     // {
//     //   t.error( _.errAttend( 'stop' ) );
//     //   return null;
//     // });
//
//     _.time.out( context.t2 / 2, () =>
//     {
//       t.take( _.dont );
//       return null;
//     });
//
//     return new _.Consequence().first( t )
//     .finally( function()
//     {
//
//       t.give( function( err, arg )
//       {
//         var elapsedTime = _.time.now() - timeBefore;
//         test.ge( elapsedTime, context.t2 / 2 );
//         // test.identical( arg, undefined );
//         // test.identical( _.strHas( _.err( err ).message, 'stop' ), true );;
//         test.identical( err, undefined );
//         test.identical( arg, _.dont );
//         test.identical( t.resourcesGet().length, 0 );
//         test.identical( t.competitorsEarlyGet().length, 0 );
//       });
//
//       test.identical( t.resourcesGet().length, 1 );
//       test.identical( t.competitorsEarlyGet().length, 1 );
//       return null;
//     })
//   })
//
//   /**/
//
//   .then( function( arg )
//   {
//     test.case = 'stop timer with error, routine passed';
//     var timeBefore = _.time.now();
//     var called = false;
//
//     var t = _.time.out( context.t2, () => { called = true } );
//     // _.time.out( context.t2 / 2, () => { t.error( _.errAttend( 'stop' ) ); return null; });
//
//     _.time.out( context.t2 / 2, () =>
//     {
//       t.take( _.dont );
//       return null;
//     });
//
//     return new _.Consequence().first( t )
//     .finally( function()
//     {
//       t.give( function( err, arg )
//       {
//         var elapsedTime = _.time.now() - timeBefore;
//         test.ge( elapsedTime, context.t2 / 2 );
//         // test.identical( arg, undefined );
//         // test.identical( _.strHas( _.err( err ).message, 'stop' ), true );
//         test.identical( err, undefined );
//         test.identical( arg, _.dont );
//         test.identical( called, false );
//         test.identical( t.resourcesGet().length, 0 );
//         test.identical( t.competitorsEarlyGet().length, 0 );
//       });
//       test.identical( t.resourcesGet().length, 1 );
//       test.identical( t.competitorsEarlyGet().length, 1 );
//       return null;
//     })
//   })
//
//   /**/
//
//   .then( function( arg )
//   {
//     test.case = 'stop after timeOut';
//     var timeBefore = _.time.now();
//     var t = _.time.out( context.t2, () => null );
//
//     var con = new _.Consequence();
//     con.first( t );
//     con.then( function( arg )
//     {
//       t.give( function( err, arg )
//       {
//         var elapsedTime = _.time.now() - timeBefore;
//         test.ge( elapsedTime, context.t2 - context.timeAccuracy );
//         test.identical( _.timerIs( arg ), true );
//         test.identical( err, undefined );
//       })
//       test.identical( t.resourcesGet().length, 1 );
//       test.identical( t.competitorsEarlyGet().length, 1 );
//       return null;
//     })
//     .delay( 1 )
//     .then( function()
//     {
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//     .then( function( arg )
//     {
//       // t.error( _.errAttend( 'stop' ) );
//       t.take( _.dont );
//       t.give( ( err, arg ) =>
//       {
//         // test.identical( _.strHas( _.err( err ).message, 'stop' ), true )
//         test.identical( err, undefined );
//         test.identical( arg, _.dont );
//       });
//       test.identical( t.resourcesGet().length, 1 );
//       test.identical( t.competitorsEarlyGet().length, 1 );
//       return null;
//     })
//     .delay( 1 )
//     .then( function()
//     {
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//
//       _.Consequence.AsyncModeSet( mode );
//
//       return null;
//     });
//
//     return con;
//   })
//
//   return ready;
// }
//
// timeOutMode01.timeOut = 30000;
//
// //
//
// function timeOutMode11( test )
// {
//   let context = this;
//   var mode = _.Consequence.AsyncModeGet();
//   var ready = new _.Consequence().take( null )
//
//   /* AsyncResourceAdding : 1, AsyncCompetitorHanding : 1 */
//
//   .finally( () =>
//   {
//     _.Consequence.AsyncModeSet([ 1, 1 ])
//     return null;
//   })
//   .then( function( arg )
//   {
//     test.case = 'delay only';
//     var timeBefore = _.time.now();
//     var t = _.time.out( context.t2 );
//     return new _.Consequence().first( t )
//     .then( function( arg )
//     {
//       t.give( function( err, arg )
//       {
//         var elapsedTime = _.time.now() - timeBefore;
//         test.ge( elapsedTime, context.t2 - context.timeAccuracy );
//         test.true( _.timerIs( arg ) );
//         test.identical( err, undefined );
//       });
//       test.identical( t.resourcesGet().length, 1 );
//       test.identical( t.competitorsEarlyGet().length, 1 );
//       return null;
//     })
//     .delay( 1 )
//     .then( function()
//     {
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//   })
//
//   /**/
//
//   .then( function( arg )
//   {
//     test.case = 'delay + routine';
//     var timeBefore = _.time.now();
//     var t = _.time.out( context.t2, () => null );
//     return new _.Consequence().first( t )
//     .then( function( arg )
//     {
//       t.give( function( err, arg )
//       {
//         var elapsedTime = _.time.now() - timeBefore;
//         test.ge( elapsedTime, context.t2 - context.timeAccuracy );
//         test.identical( _.timerIs( arg ), true );
//         test.identical( err, undefined );
//       });
//       test.identical( t.resourcesGet().length, 1 );
//       test.identical( t.competitorsEarlyGet().length, 1 );
//       return null;
//     })
//     .delay( 1 )
//     .then( function()
//     {
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//   })
//
//   /**/
//
//   .then( function( arg )
//   {
//     test.case = 'delay + routine that returns a value';
//     var timeBefore = _.time.now();
//     var value = 'value';
//     var t = _.time.out( context.t2, () => value );
//     return new _.Consequence().first( t )
//     .then( function( arg )
//     {
//       t.give( function( err, arg )
//       {
//         var elapsedTime = _.time.now() - timeBefore;
//         test.ge( elapsedTime, context.t2 - context.timeAccuracy );
//         test.true( arg === value );
//         test.identical( err, undefined );
//       });
//       test.identical( t.resourcesGet().length, 1 );
//       test.identical( t.competitorsEarlyGet().length, 1 );
//       return null;
//     })
//     .delay( 1 )
//     .then( function()
//     {
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//   })
//
//   /**/
//
//   .then( function( arg )
//   {
//     test.case = 'delay + routine that returns a consequence';
//     var timeBefore = _.time.now();
//     var t = _.time.out( context.t2, () => _.time.out( context.t2 ) );
//     return new _.Consequence().first( t )
//     .then( function( arg )
//     {
//       t.give( function( err, arg )
//       {
//         var elapsedTime = _.time.now() - timeBefore;
//         test.ge( elapsedTime, context.t2 - context.timeAccuracy );
//         test.true( _.timerIs( arg ));
//         test.identical( err, undefined );
//       });
//       test.identical( t.resourcesGet().length, 1 );
//       test.identical( t.competitorsEarlyGet().length, 1 );
//       return null;
//     })
//     .delay( 1 )
//     .then( function()
//     {
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//   })
//
//   /**/
//
//   .then( function( arg )
//   {
//     test.case = 'delay + routine that calls another timeOut';
//     var timeBefore = _.time.now();
//     var t = _.time.out( context.t2, () => { _.time.out( context.t2 );return null; } );
//     return new _.Consequence().first( t )
//     .then( function( arg )
//     {
//       t.give( function( err, arg )
//       {
//         var elapsedTime = _.time.now() - timeBefore;
//         test.ge( elapsedTime, context.t2 - context.timeAccuracy );
//         test.identical( _.timerIs( arg ), true );
//         test.identical( err, undefined );
//       });
//       test.identical( t.resourcesGet().length, 1 );
//       test.identical( t.competitorsEarlyGet().length, 1 );
//       return null;
//     })
//     .delay( 1 )
//     .then( function()
//     {
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//   })
//
//   /**/
//
//   .then( function( arg )
//   {
//     test.case = 'delay + context + routine + arguments';
//     var timeBefore = _.time.now();
//     function r( delay )
//     {
//       return delay / 2;
//     }
//     var t = _.time.out( context.t2, undefined, r, [ context.t2 ] );
//     return new _.Consequence().first( t )
//     .then( function( arg )
//     {
//       t.give( function( err, arg )
//       {
//         var elapsedTime = _.time.now() - timeBefore;
//         test.ge( elapsedTime, context.t2 - context.timeAccuracy );
//         test.true( arg === context.t2 / 2 );
//         test.identical( err, undefined );
//       });
//       test.identical( t.resourcesGet().length, 1 );
//       test.identical( t.competitorsEarlyGet().length, 1 );
//       return null;
//     })
//     .delay( 1 )
//     .then( function()
//     {
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//   })
//
//   /**/
//
//   .then( function( arg )
//   {
//     test.case = 'stop timer with error';
//     var timeBefore = _.time.now();
//     var t = _.time.out( context.t2 );
//
//     // _.time.out( context.t2 / 2, () => { t.error( _.errAttend( 'stop' ) ); return null; });
//     _.time.out( context.t2 / 2, () =>
//     {
//       t.take( _.dont );
//       return null;
//     });
//
//     return new _.Consequence().first( t )
//     .finally( function()
//     {
//       t.give( function( err, arg )
//       {
//         var elapsedTime = _.time.now() - timeBefore;
//         test.ge( elapsedTime, context.t2 / 2 );
//         // test.identical( arg, undefined );
//         // test.identical( _.strHas( _.err( err ).message, 'stop' ), true );;
//         test.identical( err, undefined );
//         test.identical( arg, _.dont );
//       });
//       test.identical( t.resourcesGet().length, 1 );
//       test.identical( t.competitorsEarlyGet().length, 1 );
//       return null;
//     })
//     .delay( 1 )
//     .then( function()
//     {
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//   })
//
//   /**/
//
//   .then( function( arg )
//   {
//     test.case = 'stop timer with error, routine passed';
//     var timeBefore = _.time.now();
//     var called = false;
//
//     var t = _.time.out( context.t2, () => { called = true; return null; } );
//     // _.time.out( context.t2 / 2, () => { t.error( _.errAttend( 'stop' ) ); return null; });
//     _.time.out( context.t2 / 2, () =>
//     {
//       t.take( _.dont );
//       return null;
//     });
//
//     return new _.Consequence().first( t )
//     .finally( function()
//     {
//       t.give( function( err, arg )
//       {
//         var elapsedTime = _.time.now() - timeBefore;
//         test.ge( elapsedTime, context.t2 / 2 );
//         // test.identical( arg, undefined );
//         // test.identical( _.strHas( _.err( err ).message, 'stop' ), true )
//         test.identical( err, undefined );
//         test.identical( arg, _.dont );
//         test.identical( called, false );
//       });
//       test.identical( t.resourcesGet().length, 1 );
//       test.identical( t.competitorsEarlyGet().length, 1 );
//       return null;
//     })
//     .delay( 1 )
//     .then( function()
//     {
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//   })
//
//   /**/
//
//   .then( function( arg )
//   {
//     test.case = 'stop after timeOut';
//     var timeBefore = _.time.now();
//     var t = _.time.out( context.t2, () => null );
//
//     var con = new _.Consequence();
//     con.first( t );
//     con.then( function( arg )
//     {
//       t.give( function( err, arg )
//       {
//         var elapsedTime = _.time.now() - timeBefore;
//         test.ge( elapsedTime, context.t2 - context.timeAccuracy );
//         test.identical( _.timerIs( arg ), true );
//         test.identical( err, undefined );
//       })
//       test.identical( t.resourcesGet().length, 1 );
//       test.identical( t.competitorsEarlyGet().length, 1 );
//       return null;
//     })
//     .delay( 1 )
//     .then( function()
//     {
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//     .then( function( arg )
//     {
//       t.take( _.dont );
//       t.give( ( err, arg ) =>
//       {
//         test.identical( err, undefined );
//         test.identical( arg, _.dont );
//       });
//       test.identical( t.resourcesGet().length, 1 );
//       test.identical( t.competitorsEarlyGet().length, 1 );
//       return null;
//     })
//     .delay( 1 )
//     .then( function()
//     {
//       test.identical( t.resourcesGet().length, 0 );
//       test.identical( t.competitorsEarlyGet().length, 0 );
//
//       _.Consequence.AsyncModeSet( mode );
//       return null;
//     });
//
//     return con;
//   })
//
//   return ready;
// }
//
// timeOutMode11.timeOut = 30000;

//

function timeOutError( test )
{
  let context = this;
  var ready = new _.Consequence().take( null );

  /* */

  ready
  .then( function( arg )
  {
    test.case = 'delay only';
    var timeBefore = _.time.now();
    return _.time.outError( context.t2 )
    .finally( function( err, arg )
    {
      if( err )
      _.errAttend( err );
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, context.t2 - context.timeAccuracy );
      test.true( _.errIs( err ) );
      return null;
    });
  })

  /* */

  .then( function( arg )
  {
    test.case = 'delay + routine';
    var timeBefore = _.time.now();
    return _.time.outError( context.t2, ( err ) =>
    {
      test.true( _.errIs( err ) );
      _.errAttend( err );
      return null;
    })
    .finally( function( err, arg )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, context.t2 - context.timeAccuracy );
      test.identical( arg, null );
      test.identical( err, undefined );
      return null;
    });
  })

  /* */

  .then( function( arg )
  {
    test.case = 'delay + routine that returns a value';
    var timeBefore = _.time.now();
    var value = 'value';
    return _.time.outError( context.t2, ( err ) =>
    {
      test.true( _.errIs( err ) );
      _.errAttend( err );
      return value;
    })
    .finally( function( err, arg )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, context.t2 - context.timeAccuracy );
      test.identical( arg, value );
      test.identical( err, undefined );
      return null;
    });
  })

  /* */

  .then( function( arg )
  {
    test.case = 'delay + routine that returns a consequence';
    var timeBefore = _.time.now();
    return _.time.outError( context.t2, ( err ) =>
    {
      test.true( _.errIs( err ) );
      _.errAttend( err );
      return _.time.out( context.t2 );
    })
    .finally( function( err, arg )
    {
      if( err )
      _.errAttend( err );
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, 2 * context.t2 - context.timeAccuracy );
      test.true( _.timerIs( arg ) );
      test.identical( err, undefined );
      return null;
    });
  })

  /* */

  .then( function( arg )
  {
    test.case = 'delay + context + routine + arguments';
    var timeBefore = _.time.now();
    function r( delay, err )
    {
      test.true( _.errIs( err ) );
      _.errAttend( err );
      return delay / 2;
    }
    return _.time.outError( context.t2, undefined, r, [ context.t2 ] )
    .finally( function( err, arg )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, context.t2 - context.timeAccuracy );
      test.identical( arg, context.t2 / 2 );
      test.identical( err, undefined );
      return null;
    });
  })

  /* */

  .then( function( arg )
  {
    test.case = 'stop timer with dont';
    var timeBefore = _.time.now();

    var t = _.time.outError( context.t2 );
    t.finally( function( err, arg )
    {
      if( err )
      _.errAttend( err );
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, context.t2 / 2 - context.timeAccuracy );
      test.identical( arg, undefined );
      test.identical( err, _.dont );
      test.identical( t.resourcesGet().length, 0 );
      return null;
    })
    _.time.out( context.t2 / 2, () => { t.error( _.dont ); return null; } );

    return t;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'stop timer with other smyol';
    var timeBefore = _.time.now();

    var t = _.time.outError( context.t2 );
    t.finally( function( err, arg )
    {
      if( err )
      _.errAttend( err );
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, context.t2 / 2 - context.timeAccuracy );
      test.identical( arg, undefined );
      test.identical( err, Symbol.for( 'symbol1' ) );
      test.identical( t.resourcesGet().length, 0 );
      return null;
    })
    _.time.out( context.t2 / 2, () => { t.error( Symbol.for( 'symbol1' ) ); return null; } );

    return t;
  })

  /* */

  // .then( function( arg )
  // {
  //   test.case = 'stop timer with dont, routine passed';
  //   var timeBefore = _.time.now();
  //   var called = false;
  //
  //   var t = _.time.outError( context.t2, () => { called = true } );
  //   t.finally( function( err, arg )
  //   {
  //     var elapsedTime = _.time.now() - timeBefore;
  //     test.ge( elapsedTime, context.t2 / 2 - context.timeAccuracy );
  //     test.identical( err, undefined );
  //     test.identical( arg, _.dont );
  //     test.identical( called, false );
  //     test.identical( t.resourcesGet().length, 0 );
  //     return null;
  //   })
  //
  //   _.time.out( context.t2 / 2, () =>
  //   {
  //     t.take( _.dont );
  //     return null;
  //   });
  //
  //   return t;
  // })

  /* */

  .finally( function( err, arg )
  {
    if( err )
    throw err;
    return null;
  });

  return ready;
}

timeOutError.timeOut = 30000;
timeOutError.description =
`
throw error on time out
stop timer with error
`

//

function asyncStackTimeOutError( test )
{
  let context = this;
  let ready = _.take( null );
  let track = [];

  ready.then( function case1()
  {

    let error;
    let con = _.time.outError( 1 ).tap( ( err, arg ) => error = _.errAttend( err ) );

    return _.time.out( 100, () =>
    {
      logger.log( error );
      test.identical( _.strCount( error.throwCallsStack, 'case1' ), 1 );
      test.identical( _.strCount( error.throwCallsStack, 'Time.test.s' ), 2 );
      test.identical( _.strCount( error.asyncCallsStack.join( '' ), 'Time.test.s' ), 2 );
      test.identical( error.asyncCallsStack.length, 1 );
    });
  });

  return ready;
}

//

function asyncStackTimeOut( test )
{
  let context = this;
  let ready = _.take( null );
  let track = [];

  ready.then( () =>
  {

    let error;
    let con = _.time.out( 1 )
    .then( ( arg ) =>
    {
      throw _.err( 'Error' );
    })
    .finally( ( err, arg ) =>
    {
      logger.log( err );
      test.identical( _.strCount( String( err ), 'Time.test.s' ), 5 );
      test.identical( _.strCount( err.asyncCallsStack.join( '' ), 'Time.test.s' ), 2 );
      test.identical( err.asyncCallsStack.length, 1 );
      return null;
    })

    return con;
  });

  return ready;
}

// --
// test suite
// --

const Proto =
{

  name : 'Tools/consequence/Time',
  silencing : 1,
  enabled : 1,

  context :
  {
    timeAccuracy : 1,
    t1 : 10,
    t2 : 250,
  },

  tests :
  {

    // etc

    sleep,
    stagesRun,

    // time out

    timeOutStructural,
    timeOutArgs,
    timeOutCallbackTimeOut,
    timeOutThrowingStructural,
    timeOutErrorStructural,
    timeOutErrorThrowingStructural,
    timeOutErrorThrowingUnattended,
    timeOutCancelWithCancel,
    timeOutCancelWithErrorSymbol,
    // timeOutCancelWithArgument,

    timeOutCancelInsideOfCallback,
    timeOutCancelOutsideOfCallback,
    timeOutCancelZeroDelayInsideOfCallback,
    timeOutCancelZeroDelayOutsideOfCallback,

    timeOut,
    timeOutSourcePath,
    // timeOutMode01,
    // timeOutMode10,
    // timeOutMode11,
    timeOutError,
    asyncStackTimeOutError,
    asyncStackTimeOut,

  }

}

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();

