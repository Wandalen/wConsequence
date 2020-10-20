( function _Namespace_s_()
{

'use strict';

/**
 * Advanced synchronization mechanism. Asynchronous routines may use Consequence to wrap postponed result, what allows classify callback for such routines as output, not input, what improves analyzability of a program. Consequence may be used to make a queue for mutually exclusive access to a resource. Algorithmically speaking Consequence is 2 queues ( FIFO ) and a customizable arbitrating algorithm. The first queue contains available resources, the second queue includes competitors for this resources. At any specific moment, one or another queue may be empty or full. Arbitrating algorithm makes resource available for a competitor as soon as possible. There are 2 kinds of resource: regular and erroneous. Unlike Promise, Consequence is much more customizable and can solve engineering problem which Promise cant. But have in mind with great power great responsibility comes. Consequence can coexist and interact with a Promise, getting fulfillment/rejection of a Promise or fulfilling it. Use Consequence to get more flexibility and improve readability of asynchronous aspect of your application.
  @module Tools/base/Consequence
*/

if( typeof module !== 'undefined' )
{
  let _ = require( '../../../../wtools/Tools.s' );
  _.include( 'wProto' );
  _.include( 'wCopyable' );
  _.include( 'wProcedure' );
}

let _global = _global_;
let _ = _global_.wTools;

_.assert( !_.Consequence, 'Consequence included several times' );

// --
// time
// --

function sleep( delay )
{

  _.assert( arguments.length === 1 );
  _.assert( _.numberIs( delay ) && delay >= 0, 'Specify valid value {-delay-}.' );
  _.assert( _.numberIsFinite( delay ), 'Delay should have finite value.' );

  let con = new _.Consequence().take( null );
  con.delay( delay ).deasync();
}

//

/**
 * Routine creates timer that executes provided routine( onReady ) after some amout of time( delay ).
 * Returns wConsequence instance. {@link module:Tools/base/Consequence.wConsequence wConsequence}
 *
 * If ( onReady ) is not provided, time.out returns consequence that gives empty message after ( delay ).
 * If ( onReady ) is a routine, time.out returns consequence that gives message with value returned or error throwed by ( onReady ).
 * If ( onReady ) is a consequence or routine that returns it, time.out returns consequence and waits until consequence from ( onReady ) resolves the message, then
 * time.out gives that resolved message throught own consequence.
 * If ( delay ) <= 0 time.out performs all operations on nextTick in node
 * @see {@link https://nodejs.org/en/docs/guides/event-loop-timers-and-nexttick/#the-node-js-event-loop-timers-and-process-nexttick }
 * or after 1 ms delay in browser.
 * Returned consequence controls the timer. Timer can be easly stopped by giving an error from than consequence( see examples below ).
 * Important - Error that stops timer is returned back as regular message inside consequence returned by time.out.
 * Also time.out can run routine with different context and arguments( see example below ).
 *
 * @param {Number} delay - Delay in ms before ( onReady ) is fired.
 * @param {Function|wConsequence} onReady - Routine that will be executed with delay.
 *
 * @example
 * // simplest, just timer
 * let t = _.time.out( 1000 );
 * t.give( () => console.log( 'Message with 1000ms delay' ) )
 * console.log( 'Normal message' )
 *
 * @example
 * // run routine with delay
 * let routine = () => console.log( 'Message with 1000ms delay' );
 * let t = _.time.out( 1000, routine );
 * t.give( () => console.log( 'Routine finished work' ) );
 * console.log( 'Normal message' )
 *
 * @example
 * // routine returns consequence
 * let routine = () => new _.Consequence().take( 'msg' );
 * let t = _.time.out( 1000, routine );
 * t.give( ( err, got ) => console.log( 'Message from routine : ', got ) );
 * console.log( 'Normal message' )
 *
 * @example
 * // time.out waits for long time routine
 * let routine = () => _.time.out( 1500, () => 'work done' ) ;
 * let t = _.time.out( 1000, routine );
 * t.give( ( err, got ) => console.log( 'Message from routine : ', got ) );
 * console.log( 'Normal message' )
 *
 * @example
 * // how to stop timer
 * let routine = () => console.log( 'This message never appears' );
 * let t = _.time.out( 5000, routine );
 * t.error( 'stop' );
 * t.give( ( err, got ) => console.log( 'Error returned as regular message : ', got ) );
 * console.log( 'Normal message' )
 *
 * @example
 * // running routine with different context and arguments
 * function routine( y )
 * {
 *   let self = this;
 *   return self.x * y;
 * }
 * let context = { x : 5 };
 * let arguments = [ 6 ];
 * let t = _.time.out( 100, context, routine, arguments );
 * t.give( ( err, got ) => console.log( 'Result of routine execution : ', got ) );
 *
 * @returns {wConsequence} Returns wConsequence instance that resolves message when work is done.
 * @throws {Error} If ( delay ) is not a Number.
 * @throws {Error} If ( onEnd ) is not a routine or wConsequence instance.
 * @function time.out
 * @namespace Tools
 */

function out_head( routine, args )
{
  let o, procedure;

  _.assert( arguments.length === 2 );
  _.assert( !!args );

  if( _.procedureIs( args[ 1 ] ) )
  {
    procedure = args[ 1 ];
    args = _.longBut( args, [ 1, 2 ] );
  }

  if( !_.mapIs( args[ 0 ] ) || args.length !== 1 )
  {
    let delay = args[ 0 ];
    let onEnd = args[ 1 ];

    if( onEnd !== undefined && !_.routineIs( onEnd ) && !_.consequenceIs( onEnd ) )
    {
      _.assert( args.length === 2, 'Expects two arguments if second one is not callable' );
      let returnOnEnd = onEnd;
      onEnd = function onEnd()
      {
        return returnOnEnd;
      }
    }
    else if( _.routineIs( onEnd ) && !_.consequenceIs( onEnd ) )
    {
      let _onEnd = onEnd;
      onEnd = function timeOutEnd()
      {
        let result = _onEnd.apply( this, arguments );
        return result === undefined ? null : result;
      }
    }

    _.assert( args.length <= 4 );

    if( args[ 1 ] !== undefined && args[ 2 ] === undefined && args[ 3 ] === undefined )
    _.assert( _.routineIs( onEnd ) || _.consequenceIs( onEnd ) );
    else if( args[ 2 ] !== undefined || args[ 3 ] !== undefined )
    _.assert( _.routineIs( args[ 2 ] ) );

    if( args[ 2 ] !== undefined || args[ 3 ] !== undefined )
    onEnd = _.routineJoin.call( _, args[ 1 ], args[ 2 ], args[ 3 ] );

    o = { delay, onEnd }

  }
  else
  {
    o = args[ 0 ];
  }

  _.assert( _.mapIs( o ) );

  if( procedure )
  o.procedure = procedure;

  _.routineOptions( routine, o );
  _.assert( _.numberIs( o.delay ) );
  _.assert( o.onEnd === null || _.routineIs( o.onEnd ) );

  return o;
}

//

function out_body( o )
{
  let con = new _.Consequence();
  let timer = null;
  let handleCalled = false;

  _.assertRoutineOptions( out_body, arguments );

  if( o.procedure === null )
  o.procedure = _.Procedure( 2 ).name( 'time.out' );
  _.assert( _.procedureIs( o.procedure ) );

  // if( o.procedure.id === 2 )
  // debugger;

  // /* */
  //
  // timer = _.time.begin( o.delay, o.procedure, timeEnd );

  /* */

  if( con )
  {
    con.procedure( o.procedure.clone() );
    // con.procedure( o.procedure );
    con.give( function timeGot( err, arg )
    {
      if( arg === _.dont )
      _.time.cancel( timer );
      con.take( err, arg );
    });
  }

  /* */

  timer = _.time.begin( o.delay, o.procedure, timeEnd );

  return con;

  /* */

  function timeEnd()
  {
    let result;

    handleCalled = true;

    if( con )
    {
      if( o.onEnd )
      con.first( o.onEnd );
      else
      con.take( _.time.out );
    }
    else
    {
      o.onEnd();
    }

  }

  /* */

}

out_body.defaults =
{
  delay : null,
  onEnd : null,
  procedure : null,
  isFinally : false,
}

let out = _.routineUnite( out_head, out_body );

//

/**
 * Routine works moslty same like {@link wTools.time.out} but has own small features:
 *  Is used to set execution time limit for async routines that can run forever or run too long.
 *  wConsequence instance returned by time.outError always give an error:
 *  - Own 'time.out' error message if ( onReady ) was not provided or it execution dont give any error.
 *  - Error throwed or returned in consequence by ( onRead ) routine.
 *
 * @param {Number} delay - Delay in ms before ( onReady ) is fired.
 * @param {Function|wConsequence} onReady - Routine that will be executed with delay.
 *
 * @example
 * // time.out error after delay
 * let t = _.time.outError( 1000 );
 * t.give( ( err, got ) => { throw err; } )
 *
 * @example
 * // using time.outError with long time routine
 * let time = 5000;
 * let time.out = time / 2;
 * function routine()
 * {
 *   return _.time.out( time );
 * }
 * // orKeepingSplit waits until one of provided consequences will resolve the message.
 * // In our example single time.outError consequence was added, so orKeepingSplit adds own context consequence to the queue.
 * // Consequence returned by 'routine' resolves message in 5000 ms, but time.outError will do the same in 2500 ms and 'time.out'.
 * routine()
 * .orKeepingSplit( _.time.outError( time.out ) )
 * .give( function( err, got )
 * {
 *   if( err )
 *   throw err;
 *   console.log( got );
 * })
 *
 * @returns {wConsequence} Returns wConsequence instance that resolves error message when work is done.
 * @throws {Error} If ( delay ) is not a Number.
 * @throws {Error} If ( onReady ) is not a routine or wConsequence instance.
 * @function time.outError
 * @namespace Tools
 */

/* zzz : remove the body, use out_body */
function outError_body( o )
{
  _.assert( _.routineIs( _.Consequence ) );
  _.assertRoutineOptions( outError_body, arguments );

  if( _.numberIs( o.procedure ) )
  o.procedure += 1;
  else if( o.procedure === null )
  o.procedure = 2;

  if( !o.procedure || _.numberIs( o.procedure ) )
  o.procedure = _.procedure.from( o.procedure ).nameElse( 'time.outError' );

  let con = _.time.out.body.call( _, o );
  if( Config.debug && con.tag === '' )
  con.tag = 'TimeOutError';

  _.assert( con._procedure === null );
  con.procedure( o.procedure.clone() );
  con.finally( outError );
  _.assert( con._procedure === null );

  return con;

  function outError( err, arg )
  {
    if( err )
    throw err;
    if( arg === _.dont )
    return arg;

    err = _.time._errTimeOut
    ({
      message : 'Time out!',
      reason : 'time out',
      consequnce : con,
      procedure : o.procedure,
    });

    throw err;
  }

}

outError_body.defaults = Object.create( out_body.defaults );

let outError = _.routineUnite( out_head, outError_body );

//

function _errTimeOut( o )
{
  if( _.strIs( o ) )
  o = { message : o }
  o = _.routineOptions( _errTimeOut, o );
  _.assert( arguments.length === 0 || arguments.length === 1 );

  o.message = o.message || 'Time out!';
  o.reason = o.reason || 'time out';

  let err = _._err
  ({
    args : [ o.message ],
    throws : o.procedure ? [ o.procedure._sourcePath ] : [],
    asyncCallsStack : o.procedure ? [ o.procedure.stack() ] : [],
    reason : o.reason,
  });

  if( o.consequnce )
  {
    let properties =
    {
      enumerable : false,
      configurable : false,
      writable : false,
      value : o.consequnce,
    };
    Object.defineProperty( err, 'consequnce', properties );
  }

  return err;
}

_errTimeOut.defaults =
{
  message : null,
  reason : null,
  consequnce : null,
  procedure : null,
}

// --
// experimental
// --

function take()
{
  if( !arguments.length )
  return new _.Consequence().take( null );
  else
  return new _.Consequence().take( ... arguments );
}

//

function Now()
{
  _.assert( arguments.length === 0, 'Expects no arguments' );
  return new _.Consequence().take( null );
}

//

function After( resource )
{
  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( arguments.length === 0 || resource !== undefined );

  if( resource !== undefined )
  return _.Consequence.From( resource );
  else
  return new _.Consequence().take( null );

}

// //
//
// function Before( consequence )
// {
//   _.assert( arguments.length === 1 );
//   _.assert( arguments.length === 0 || consequence !== undefined );
//   _.assert( 0, 'not tested' );
//
//   let result;
//   if( _.consequenceLike( consequence ) )
//   {
//     consequence = _.Consequence.From( consequence );
//   }
//
//   let result = _.Consequence();
//   result.lateFinally( consequence );
//
//   return result;
// }

//

function execStages( stages, o )
{
  let logger = _global.logger || _global.console;

  o = o || Object.create( null );

  _.routineOptionsPreservingUndefines( execStages, o );

  o.stages = stages;
  o.stack = _.introspector.stackRelative( o.stack, 1 );

  Object.preventExtensions( o );

  /* validation */

  _.assert( _.objectIs( stages ) || _.longIs( stages ),'Expects array or object ( stages ), but got',_.strType( stages ) );

  for( let s in stages )
  {

    let routine = stages[ s ];

    if( o.onRoutine )
    routine = o.onRoutine( routine );

    // _.assert( routine || routine === null,'execStages :','#'+s,'stage is not defined' );
    _.assert( _.routineIs( routine ) || routine === null, () => 'stage' + '#'+s + ' does not have routine to execute' );

  }

  /*  let */

  let ready = _.time.out( 1 );
  let keys = Object.keys( stages );
  let s = 0;

  _.assert( arguments.length === 1 || arguments.length === 2 );

  /* begin */

  if( o.onBegin )
  {
    ready.procedure({ _stack : o.stack });
    ready.finally( o.onBegin );
    _.assert( ready._procedure === null );
  }

  handleStage();

  return ready;

  /* end */

  function handleEnd()
  {

    ready.procedure({ _stack : o.stack });
    ready.finally( function( err, data )
    {
      if( err )
      {
        debugger;
        throw _.errLogOnce( err );
      }
      else
      {
        return data;
      }
    });
    _.assert( ready._procedure === null );

    if( o.onEnd )
    {
      ready.procedure({ _stack : o.stack });
      ready.finally( o.onEnd );
      _.assert( ready._procedure === null );
    }

  }

  /* staging */

  function handleStage()
  {

    let stage = stages[ keys[ s ] ];
    let iteration = Object.create( null );

    iteration.index = s;
    iteration.key = keys[ s ];

    s += 1;

    if( stage === null )
    return handleStage();

    if( !stage )
    return handleEnd();

    /* arguments */

    iteration.stage = stage;
    if( o.onRoutine )
    iteration.routine = o.onRoutine( stage );
    else
    iteration.routine = stage;
    iteration.routine = _.routineJoin( o.context, iteration.routine, o.args );

    function routineCall()
    {
      let ret = iteration.routine();
      return ret;
    }

    /* exec */

    if( o.onEachRoutine )
    {
      ready.procedure({ _stack : o.stack });
      ready.ifNoErrorThen( _.routineSeal( o.context, o.onEachRoutine, [ iteration.stage, iteration, o ] ) );
      _.assert( ready._procedure === null );
    }

    if( !o.manual )
    {
      ready.procedure({ _stack : o.stack });
      ready.ifNoErrorThen( routineCall );
      _.assert( ready._procedure === null );
    }

    ready.procedure({ _stack : o.stack });
    ready.delay( o.delay );
    _.assert( ready._procedure === null );

    handleStage();

  }

}

execStages.defaults =
{
  delay : 1,
  stack : null,

  args : undefined,
  context : undefined,
  manual : false,

  onEachRoutine : null,
  onBegin : null,
  onEnd : null,
  onRoutine : null,
}

// --
// meta
// --

// function _Extend( dstGlobal, srcGlobal )
// {
//   _.assert( _.routineIs( srcGlobal.wConsequence.After ) );
//   _.assert( _.mapIs( srcGlobal.wConsequence.Tools ) );
//   _.mapExtend( dstGlobal.wTools, srcGlobal.wConsequence.Tools );
//   let Self = srcGlobal.wConsequence;
//   dstGlobal.wTools[ Self.shortName ] = Self;
//   if( typeof module !== 'undefined' )
//   module[ 'exports' ] = Self;
//   return;
// }

// --
// relations
// --

let ToolsExtension =
{
  take,
  now : Now,
  async : Now,
  after : After,
  // before : Before,
  execStages,
}

let TimeExtension =
{
  out,
  outError,
  _errTimeOut,
  sleep,
};

_.mapExtend( _, ToolsExtension );
_.mapExtend( _realGlobal_.wTools, ToolsExtension );
_.time = _.mapExtend( _.time || null, TimeExtension );
_realGlobal_.wTools.time = _.mapExtend( _realGlobal_.wTools.time || null, TimeExtension );

require( './Consequence.s' );

// --
// export
// --

if( typeof module !== 'undefined' )
module[ 'exports' ] = _;

})();
