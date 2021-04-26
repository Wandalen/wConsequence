( function _Process_test_s_()
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

// --
// test
// --

function ready( test )
{
  let t1 = 10;
  let t2 = 100;
  let ready =  new _.Consequence().take( null );

  /* */

  ready.then( () =>
  {
    test.case = 'without arguments';
    var proceduresBefore = _.Procedure.Counter;
    var got = _.process.ready();
    var proceduresAfter = _.Procedure.Counter;
    test.identical( proceduresAfter - proceduresBefore, 2 );
    test.true( _.consequenceIs( got ) );

    return null;
  });

  ready.then( () =>
  {
    test.case = 'only onReady, no timeOut';
    var arr = [];
    var onReady = () => arr.push( 1 );
    var proceduresBefore = _.Procedure.Counter;
    _.process.ready( onReady );
    var proceduresAfter = _.Procedure.Counter;
    test.identical( proceduresAfter - proceduresBefore, 2 );

    return _.time.out( t2, () =>
    {
      test.identical( arr, [ 1 ] );
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'timeOut and onReady';
    var arr = [];
    var onReady = () => arr.push( 1 );
    var proceduresBefore = _.Procedure.Counter;
    _.process.ready( t2, onReady );
    var proceduresAfter = _.Procedure.Counter;
    test.identical( proceduresAfter - proceduresBefore, 2 );
    test.identical( arr, [] );

    return _.time.out( t2 * 2, () =>
    {
      test.identical( arr, [ 1 ] );
      return null;
    });
  });

  /* */

  ready.then( () =>
  {
    test.case = 'empty map';
    var proceduresBefore = _.Procedure.Counter;
    var got = _.process.ready( {} );
    var proceduresAfter = _.Procedure.Counter;
    test.identical( proceduresAfter - proceduresBefore, 2 );
    test.true( _.consequenceIs( got ) );

    return null;
  });

  ready.then( () =>
  {
    test.case = 'only timeOut';
    var proceduresBefore = _.Procedure.Counter;
    var got = _.process.ready({ timeOut : t1 });
    var proceduresAfter = _.Procedure.Counter;
    test.identical( proceduresAfter - proceduresBefore, 2 );
    test.identical( got.resourcesCount(), 0 );

    return _.time.out( t2, () =>
    {
      test.identical( got.resourcesCount(), 1 );
    });
  });

  ready.then( () =>
  {
    test.case = 'only onReady, no timeOut, no procedure';
    var arr = [];
    var onReady = () => arr.push( 1 );
    var proceduresBefore = _.Procedure.Counter;
    _.process.ready({ onReady });
    var proceduresAfter = _.Procedure.Counter;
    test.identical( proceduresAfter - proceduresBefore, 2 );

    return _.time.out( t2, () =>
    {
      test.identical( arr, [ 1 ] );
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'only procedure, no timeOut, no onReady';
    var procedure = _.Procedure( 2 );
    var proceduresBefore = _.Procedure.Counter;
    _.process.ready({ procedure });
    var proceduresAfter = _.Procedure.Counter;
    test.identical( proceduresAfter - proceduresBefore, 1 );

    return null;
  });

  ready.then( () =>
  {
    test.case = 'timeOut and onReady';
    var arr = [];
    var onReady = () => arr.push( 1 );
    var proceduresBefore = _.Procedure.Counter;
    _.process.ready({ timeOut : t1, onReady });
    var proceduresAfter = _.Procedure.Counter;
    test.identical( proceduresAfter - proceduresBefore, 2 );
    test.identical( arr, [] );

    return _.time.out( t2 * 2, () =>
    {
      test.identical( arr, [ 1 ] );
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'timeOut and procedure';
    var procedure = _.Procedure( 2 );
    var proceduresBefore = _.Procedure.Counter;
    var got = _.process.ready({ timeOut : t1, procedure });
    var proceduresAfter = _.Procedure.Counter;
    test.identical( proceduresAfter - proceduresBefore, 1 );
    test.identical( got.resourcesCount(), 0 );

    return _.time.out( t2 * 2, () =>
    {
      test.identical( got.resourcesCount(), 1 );
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'onReady and procedure';
    var arr = [];
    var procedure = _.Procedure( 2 );
    var onReady = () => arr.push( 1 );
    var proceduresBefore = _.Procedure.Counter;
    _.process.ready({ procedure, onReady });
    var proceduresAfter = _.Procedure.Counter;
    test.identical( proceduresAfter - proceduresBefore, 1 );
    test.identical( arr, [] );

    return _.time.out( t2 * 2, () =>
    {
      test.identical( arr, [ 1 ] );
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'timeOut, onReady and procedure';
    var arr = [];
    var procedure = _.Procedure( 2 );
    var onReady = () => arr.push( 1 );
    var proceduresBefore = _.Procedure.Counter;
    _.process.ready({ timeOut : t1, procedure, onReady });
    var proceduresAfter = _.Procedure.Counter;
    test.identical( proceduresAfter - proceduresBefore, 1 );
    test.identical( arr, [] );

    return _.time.out( t2 * 2, () =>
    {
      test.identical( arr, [ 1 ] );
      return null;
    });
  });

  /* - */

  if( !Config.debug )
  return;

  test.case = 'single arg is not a routine';
  test.shouldThrowErrorSync( () => _.process.ready( 1 ) );

  test.case = 'wrong type of timeOut';
  test.shouldThrowErrorSync( () => _.process.ready( 'wrong', () => 'ready' ) );
  test.shouldThrowErrorSync( () => _.process.ready( 10.5, () => 'ready' ) );
  test.shouldThrowErrorSync( () => _.process.ready( Infinity, () => 'ready' ) );

  test.case = 'wrong type of onReady';
  test.shouldThrowErrorSync( () => _.process.ready( 10, 'wrong' ) );

  test.case = 'options map has not known option';
  test.shouldThrowErrorSync( () => _.process.ready({ timeOut : 10, unknown : 'unknown', onReady : () => 'ready' }) );

  return ready;
}

ready.timeOut = 10000;

//

function readyProcedure( test )
{
  let ready =  new _.Consequence().take( null );

  /* */

  ready.then( function ready1()
  {
    test.case = 'without arguments';
    var got = _.process.ready();

    test.identical( got.competitorsCount(), 1 );
    got.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'ready1' ) );
    });

    return null;
  });

  //

  ready.then( function ready2()
  {
    test.case = 'procedure with delta = 0';
    var procedure = _.Procedure( 0 );
    var got = _.process.ready({ procedure });

    test.identical( got.competitorsCount(), 1 );
    got.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'ready2' ) );
    })

    return null;
  });

  //

  ready.then( function ready3()
  {
    test.case = 'procedure with delta = 1';

    var procedure = _.Procedure( 1 );
    var got = _.process.ready({ procedure });

    test.identical( got.competitorsCount(), 1 );
    got.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( !_.strHas( competitor.procedure._sourcePath, 'ready3' ) );
    })

    return null;
  });

  return ready;
}

//

function readyJoinProcedure( test )
{
  let ready =  new _.Consequence().take( null );

  /* */

  ready.then( function readyJoin1()
  {
    test.case = 'without arguments';
    var got = _.process.readyJoin( null, ( arg ) => 'hello ' + arg, [ 'ready' ] )();

    test.identical( got.competitorsCount(), 1 );
    got.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'readyJoin1' ) );
    });

    return null;
  });

  //

  return ready;
}

//

function sessionsRunWithEmptySessions( test )
{
  let ready = _.take( null );
  let o;

  /* */

  ready.then( () =>
  {
    test.case = 'empty sessions';
    o =
    {
      conBeginName : 'conStart',
      conEndName : 'conTerminate',
      concurrent : 0,
      error : null,
      onBegin : ( err, o2 ) =>
      {
        if( o2 )
        return o2;
        throw err;
      },
      onEnd : ( err, o2 ) =>
      {
        if( o2 )
        return o2;
        throw err;
      },
      onError : ( err ) => { throw err },
      onRun : ( session ) => { return session },
      readyName : 'ready',
      sessions : [],
      ready : null,
    };
    return _.sessionsRun( o );
  });
  ready.then( ( op ) =>
  {
    test.true( _.mapIs( op ) );
    test.true( op === o );
    test.identical( op.conBeginName, 'conStart' );
    test.identical( op.conEndName, 'conTerminate' );
    test.identical( op.concurrent, 0 );
    test.identical( op.error, null );
    test.true( _.routineIs( op.onBegin ) );
    test.true( _.routineIs( op.onEnd ) );
    test.true( _.routineIs( op.onError ) );
    test.true( _.routineIs( op.onRun ) );
    test.true( _.consequenceIs( op.ready ) );
    test.identical( op.readyName, 'ready' );
    test.identical( op.sessions, [] );
    return null;
  });

  return ready;
}

// --
// declare
// --

const Proto =
{

  name : 'Tools/consequence/Process',
  silencing : 1,
  enabled : 1,

  tests :
  {

    ready,
    readyProcedure,
    readyJoinProcedure,
    sessionsRunWithEmptySessions,

  }

}

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();

