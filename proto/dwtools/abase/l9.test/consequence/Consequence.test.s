( function _Consequence_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  var _ = require( '../../../Tools.s' );
  require( '../../l9/consequence/Consequence.s' );
  _.include( 'wTesting' );

}

var _global = _global_;
var _ = _global_.wTools;

// --
// test
// --

function clone( test )
{
  var self = this;

  test.case = 'consequence with resource';
  var con1 = new _.Consequence({ tag : 'con1', capacity : 2 });
  con1.take( 'arg1' );
  var con2 = con1.clone();
  test.identical( con1.argumentsCount(), 1 );
  test.identical( con1.competitorsCount(), 0 );
  test.identical( con1.nickName, 'Consequence::con1' );
  test.identical( con1.infoExport({ verbosity : 1 }), 'Consequence::con1 1 / 0' );
  test.identical( con1.capacity, 2 );
  test.identical( con2.argumentsCount(), 1 );
  test.identical( con2.competitorsCount(), 0 );
  test.identical( con2.nickName, 'Consequence::con1' );
  test.identical( con2.infoExport({ verbosity : 1 }), 'Consequence::con1 1 / 0' );
  test.identical( con2.capacity, 2 );
  test.is( con1._resources !== con2._resources );
  test.is( con1._competitorsEarly !== con2._competitorsEarly );
  test.is( con1._competitorsLate !== con2._competitorsLate );

  test.case = 'consequence with competitor';
  var con1 = new _.Consequence({ tag : 'con1', capacity : 2 });
  var f = function f(){};
  con1.then( f );
  var con2 = con1.clone();
  test.identical( con1.argumentsCount(), 0 );
  test.identical( con1.competitorsCount(), 1 );
  test.identical( con1.nickName, 'Consequence::con1' );
  test.identical( con1.infoExport({ verbosity : 1 }), 'Consequence::con1 0 / 1' );
  test.identical( con1.capacity, 2 );
  test.identical( con2.argumentsCount(), 0 );
  test.identical( con2.competitorsCount(), 0 );
  test.identical( con2.nickName, 'Consequence::con1' );
  test.identical( con2.infoExport({ verbosity : 1 }), 'Consequence::con1 0 / 0' );
  test.identical( con2.capacity, 2 );
  test.is( con1._resources !== con2._resources );
  test.is( con1._competitorsEarly !== con2._competitorsEarly );
  test.is( con1._competitorsLate !== con2._competitorsLate );

  test.identical( _.Procedure.Get( f ).length, 1 );
  con2.cancel();
  test.identical( _.Procedure.Get( f ).length, 1 );
  con1.cancel();
  test.identical( _.Procedure.Get( f ).length, 0 );

}

//

function trivial( test )
{
  var self = this;

  /* */

  test.case = 'class checks';
  test.is( _.routineIs( wConsequence.prototype.FinallyPass ) );
  test.is( _.routineIs( wConsequence.FinallyPass ) );
  test.is( _.objectIs( wConsequence.prototype.KindOfResource ) );
  test.is( _.objectIs( wConsequence.KindOfResource ) );
  test.is( wConsequence.name === 'wConsequence' );
  test.is( wConsequence.shortName === 'Consequence' );

  /* */

  test.case = 'construction';
  var con1 = new _.Consequence({ tag : 'con1' }).take( 1 );
  var con2 = _.Consequence({ capacity : 0 }).take( 2 );
  var con3 = con2.clone();
  test.identical( con1.resourcesGet().length, 1 );
  test.identical( con2.resourcesGet().length, 1 );
  test.identical( con3.resourcesGet().length, 1 );

  /* */

  test.case = 'class test';
  test.is( _.consequenceIs( con1 ) );
  test.is( con1 instanceof wConsequence );
  test.is( _.consequenceIs( con2 ) );
  test.is( con2 instanceof wConsequence );
  test.is( _.consequenceIs( con3 ) );
  test.is( con3 instanceof wConsequence );

  con3.take( 3 );
  con3( 4 );
  con3( 5 );

  con3.give( ( err, arg ) => test.identical( arg, 2 ) );
  con3.give( ( err, arg ) => test.identical( arg, 3 ) );
  con3.give( ( err, arg ) => test.identical( arg, 4 ) );
  con3.finally( ( err, arg ) => test.identical( con3.resourcesGet().length, 0 ) );

  return con3;
}

//

function ordinarResourceAsyncMode00( test )
{
  var c = this;
  var amode = _.Consequence.AsyncModeGet();
  var que = new _.Consequence().take( null )

  /* */

  .finally( () =>
  {
    test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );

    test.case = 'single resource';
    _.Consequence.AsyncModeSet([ 0, 0 ]);
    return null;
  })
  .thenKeep( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    con.take( 1 );
    test.identical( con.resourcesGet().length, 1 );
    con.give( function( err, got )
    {
      test.identical( err, undefined )
      test.identical( got, 1 );
    })
    test.identical( con.resourcesGet().length, 0 );
    test.identical( con.competitorsEarlyGet().length, 0 );
    return null;
  })

  /* */

  .finally( () =>
  {
    test.case = 'several resources';
    return null;
  })
  .thenKeep( function( arg )
  {
    var con = new _.Consequence({ tag : 'con', capacity : 3 });
    con.take( 1 ).take( 2 ).take( 3 );
    test.identical( con.resourcesGet().length, 3 );
    con.give( ( err, got ) => test.identical( got, 1 ) );
    con.give( ( err, got ) => test.identical( got, 2 ) );
    con.give( ( err, got ) => test.identical( got, 3 ) );
    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })

  /* */

  .finally( () =>
  {
    test.case = 'single error';
    return null;
  })
  .thenKeep( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    con.error( 'err' );
    test.identical( con.resourcesGet().length, 1 );
    con.give( function( err, got )
    {
      test.is( !!err );
      test.identical( got, undefined );
    })
    test.identical( con.resourcesGet().length, 0 );
    test.identical( con.competitorsEarlyGet().length, 0 );
    return null;
  })

  /* */

  .finally( () =>
  {
    test.case = 'several error'
    return null;
  })
  .thenKeep( function( arg )
  {
    var con = new _.Consequence({ tag : 'con', capacity : 3 });
    con.error( 'err1' ).error( 'err2' ).error( 'err3' );
    test.identical( con.resourcesGet().length, 3 );
    con.give( ( err, got ) => test.is( !!err ) );
    con.give( ( err, got ) => test.is( !!err ) );
    con.give( ( err, got ) => test.is( !!err ) );
    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })

  /* */

  .finally( ( err, arg ) =>
  {
    test.close( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );

    _.Consequence.AsyncModeSet( amode );


    if( err )
    throw err;
    return arg;

  })
  return que;
}

//

function ordinarResourceAsyncMode10( test )
{
  var c = this;
  var amode = _.Consequence.AsyncModeGet();
  var que = new _.Consequence().take( null )

  /* */

  .finally( () =>
  {
    test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );

    test.case = 'single resource';
    _.Consequence.AsyncModeSet([ 1, 0 ]);
    return null;
  })
  .thenKeep( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    con.take( 1 );
    test.identical( con.resourcesGet().length, 1 );
    con.give( function( err, got )
    {
      test.identical( err, undefined )
      test.identical( got, 1 );
    })
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /* */

  .finally( () =>
  {
    test.case = 'several resources';
    return null;
  })
  .thenKeep( function( arg )
  {
    var con = new _.Consequence({ tag : 'con', capacity : 3 });
    con.take( 1 ).take( 2 ).take( 3 );
    con.give( ( err, got ) => test.identical( got, 1 ) );
    con.give( ( err, got ) => test.identical( got, 2 ) );
    con.give( ( err, got ) => test.identical( got, 3 ) );
    test.identical( con.competitorsEarlyGet().length, 3 );
    test.identical( con.resourcesGet().length, 3 );
    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /* */

  .finally( () =>
  {
    test.case = 'single error';
    return null;
  })
  .thenKeep( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    con.error( 'err' );
    test.identical( con.resourcesGet().length, 1 );
    con.give( function( err, got )
    {
      test.is( !!err );
      test.identical( got, undefined );
    })
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /* */

  .finally( () =>
  {
    test.case = 'several error'
    return null;
  })
  .thenKeep( function( arg )
  {
    var con = new _.Consequence({ tag : 'con', capacity : 3 });
    con.error( 'err1' ).error( 'err2' ).error( 'err3' );
    con.give( ( err, got ) => test.is( !!err ) );
    con.give( ( err, got ) => test.is( !!err ) );
    con.give( ( err, got ) => test.is( !!err ) );
    test.identical( con.competitorsEarlyGet().length, 3 );
    test.identical( con.resourcesGet().length, 3 );
    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /* */

  .finally( ( err, arg ) =>
  {
    test.close( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );

    _.Consequence.AsyncModeSet( amode );


    if( err )
    throw err;
    return arg;

  })
  return que;
}

//

function ordinarResourceAsyncMode01( test )
{
  var c = this;
  var amode = _.Consequence.AsyncModeGet();
  var que = new _.Consequence().take( null )

  /* */

  .finally( () =>
  {
    test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );

    test.case = 'single resource';
    _.Consequence.AsyncModeSet([ 0, 1 ]);
    return null;
  })
  .thenKeep( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    con.take( 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 1 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      con.give( function( err, got )
      {
        test.identical( err, undefined )
        test.identical( got, 1 );
      })
      return null;
    })
    .thenKeep( function( arg )
    {
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /* */

  .finally( () =>
  {
    test.case = 'several resources';
    return null;
  })
  .thenKeep( function( arg )
  {
    var con = new _.Consequence({ tag : 'con', capacity : 3 });
    con.take( 1 ).take( 2 ).take( 3 );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 3 );
      con.give( ( err, got ) => test.identical( got, 1 ) );
      con.give( ( err, got ) => test.identical( got, 2 ) );
      con.give( ( err, got ) => test.identical( got, 3 ) );
      return null;
    })
    .thenKeep( function( arg )
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /* */

  .finally( () =>
  {
    test.case = 'single error';
    return null;
  })
  .thenKeep( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    con.error( 'err' );

    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 1 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      con.give( function( err, got )
      {
        test.is( !!err );
        test.identical( got, undefined );
      })
      return null;
    })
    .thenKeep( function( arg )
    {
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /* */

  .finally( () =>
  {
    test.case = 'several error'
    return null;
  })
  .thenKeep( function( arg )
  {
    var con = new _.Consequence({ tag : 'con', capacity : 3 });
    con.error( 'err1' ).error( 'err2' ).error( 'err3' );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 3 );
      con.give( ( err, got ) => test.is( !!err ) );
      con.give( ( err, got ) => test.is( !!err ) );
      con.give( ( err, got ) => test.is( !!err ) );
      return null;
    })
    .thenKeep( function( arg )
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /* */

  .finally( ( err, arg ) =>
  {
    test.close( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );

    _.Consequence.AsyncModeSet( amode );


    if( err )
    throw err;
    return arg;

  })
  return que;
}

//

function ordinarResourceAsyncMode11( test )
{
  var c = this;
  var amode = _.Consequence.AsyncModeGet();
  var que = new _.Consequence().take( null )

  /* */

  .finally( () =>
  {
    test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );

    test.case = 'single resource';
    _.Consequence.AsyncModeSet([ 1, 1 ]);
    return null;
  })
  .thenKeep( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    con.take( 1 );
    con.give( function( err, got )
    {
      test.identical( err, undefined )
      test.identical( got, 1 );
    })
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /* */

  .finally( () =>
  {
    test.case = 'several resources';
    return null;
  })
  .thenKeep( function( arg )
  {
    var con = new _.Consequence({ tag : 'con', capacity : 3 });
    con.take( 1 ).take( 2 ).take( 3 );
    con.give( ( err, got ) => test.identical( got, 1 ) );
    con.give( ( err, got ) => test.identical( got, 2 ) );
    con.give( ( err, got ) => test.identical( got, 3 ) );
    test.identical( con.competitorsEarlyGet().length, 3 );
    test.identical( con.resourcesGet().length, 3 );
    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /* */

  .finally( () =>
  {
    test.case = 'single error';
    return null;
  })
  .thenKeep( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    con.error( 'err' );
    con.give( function( err, got )
    {
      test.is( !!err );
      test.identical( got, undefined );
    })
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /* */

  .finally( () =>
  {
    test.case = 'several error'
    return null;
  })
  .thenKeep( function( arg )
  {
    var con = new _.Consequence({ tag : 'con', capacity : 3 });
    con.error( 'err1' ).error( 'err2' ).error( 'err3' );
    con.give( ( err, got ) => test.is( !!err ) );
    con.give( ( err, got ) => test.is( !!err ) );
    con.give( ( err, got ) => test.is( !!err ) );
    test.identical( con.competitorsEarlyGet().length, 3 );
    test.identical( con.resourcesGet().length, 3 );
    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /* */

  .finally( ( err, arg ) =>
  {
    test.close( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );

    _.Consequence.AsyncModeSet( amode );


    if( err )
    throw err;
    return arg;

  })
  return que;
}

//--
// finallyPromiseGive
//--

function finallyPromiseGiveAsyncMode00( test )
{
  var testMsg = 'testMsg';
  var amode = _.Consequence.AsyncModeGet();
  var que = new _.Consequence().take( null )

  /* */

  .finally( () =>
  {
    test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );

    _.Consequence.AsyncModeSet([ 0, 0 ]);
    return null;
  })

  .thenKeep( function( arg )
  {
    test.case = 'no resource';
    var con = new _.Consequence({ tag : 'con' });
    var promise = con.finallyPromiseGive();
    test.identical( con.resourcesGet().length, 0 );
    test.identical( con.competitorsEarlyGet().length, 1 );
    promise.then( function( got )
    {
      test.identical( 0, 1 );
    });

    return _.timeOut( 10, function()
    {
      debugger;
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 1 );
      con.competitorsCancel();
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
    });

  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'single resource';
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );
    test.identical( con.resourcesGet().length, 1 );
    // debugger;
    var promise = con.finallyPromiseGive();
    // debugger;
    promise.then( function( got )
    {
      test.identical( got, testMsg );
      test.is( _.promiseIs( promise ) );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      // debugger;
    })
    // debugger;
    let result = _.Consequence.From( promise );
    // debugger;
    return result;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'single error';
    var con = new _.Consequence({ tag : 'con' });
    con.error( testMsg );

    test.identical( con.resourcesCount(), 1 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );

    var promise = con.finallyPromiseGive();

    test.identical( con.resourcesCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );

    promise.catch( function( err )
    {
      test.is( _.strHas( String( err ), testMsg ) );
      test.is( _.promiseIs( promise ) );
      test.identical( con.resourcesCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.Consequence.From( promise ).finally( () => null );
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'several resources';
    var con = new _.Consequence({ capacity : 3 });
    con.take( testMsg + 1 );
    con.take( testMsg + 2 );
    con.take( testMsg + 3 );
    test.identical( con.resourcesGet().length, 3 );
    var promise = con.finallyPromiseGive();
    promise.then( function( got )
    {
      test.identical( got, testMsg + 1 );
      test.is( _.promiseIs( promise ) );
      test.identical( con.resourcesGet().length, 2 );
      test.identical( con.competitorsEarlyGet().length, 0 );
    })
    return _.Consequence.From( promise );
  })

  /* */

  .finally( ( err, arg ) =>
  {
    test.close( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );

    _.Consequence.AsyncModeSet( amode );


    if( err )
    throw err;
    return arg;

  })
  return que;
}

//

function finallyPromiseGiveAsyncMode10( test )
{
  var testMsg = 'testMsg';
  var amode = _.Consequence.AsyncModeGet();
  var que = new _.Consequence().take( null )

  /* */

  .finally( () =>
  {
    test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );

    _.Consequence.AsyncModeSet([ 1, 0 ]);
    return null;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async competitors adding, single resource';
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );
    var promise = con.finallyPromiseGive();
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 1 );
    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesGet().length, 0 );
        test.identical( con.competitorsEarlyGet().length, 0 );
      });
      return _.Consequence.From( promise );
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async competitors adding, error resource';
    var con = new _.Consequence({ tag : 'con' });
    con.error( testMsg );
    var promise = con.finallyPromiseGive();
    promise.catch( function( err )
    {
      test.is( _.strHas( String( err ), testMsg ) );
      test.is( _.promiseIs( promise ) );
    });
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return _.Consequence.From( promise ).finally( () => null );
    });
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async competitors adding, several resources';
    var con = new _.Consequence({ capacity : 3 });
    con.take( testMsg + 1 );
    con.take( testMsg + 2 );
    con.take( testMsg + 3 );
    var promise = con.finallyPromiseGive();
    test.identical( con.resourcesGet().length, 3 );
    test.identical( con.competitorsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg + 1 );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesGet().length, 2 );
        test.identical( con.competitorsEarlyGet().length, 0 );
      })
      return _.Consequence.From( promise );
    })
  })

  /* */

  .finally( ( err, arg ) =>
  {
    test.close( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );

    _.Consequence.AsyncModeSet( amode );


    if( err )
    throw err;
    return arg;

  })
  return que;
}

//

function finallyPromiseGiveAsyncMode01( test )
{
  var testMsg = 'testMsg';
  var amode = _.Consequence.AsyncModeGet();
  var que = new _.Consequence().take( null )

  /* */

  .finally( () =>
  {
    test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );

    _.Consequence.AsyncModeSet([ 0, 1 ]);
    return null;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async resources adding, single resource';
    var con = new _.Consequence({ tag : 'con' });
    var promise = con.finallyPromiseGive();
    con.take( testMsg );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 1 );
    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesGet().length, 0 );
        test.identical( con.competitorsEarlyGet().length, 0 );
      });
      return _.Consequence.From( promise );
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async resources adding, single error';
    var con = new _.Consequence({ tag : 'con' });
    var promise = con.finallyPromiseGive();
    con.error( testMsg );
    promise.catch( function( err )
    {
      test.is( _.strHas( String( err ), testMsg ) );
      test.is( _.promiseIs( promise ) );
    });
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return _.Consequence.From( promise ).finally( () => null );
    });
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async resources adding, several resources';
    var con = new _.Consequence({ capacity : 3 });
    var promise = con.finallyPromiseGive();
    con.take( testMsg + 1 );
    con.take( testMsg + 2 );
    con.take( testMsg + 3 );
    test.identical( con.resourcesGet().length, 3 );
    test.identical( con.competitorsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg + 1 );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesGet().length, 2 );
        test.identical( con.competitorsEarlyGet().length, 0 );
      })
      return _.Consequence.From( promise );
    })
  })

  /* */

  .finally( ( err, arg ) =>
  {
    test.close( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );

    _.Consequence.AsyncModeSet( amode );


    if( err )
    throw err;
    return arg;

  })
  return que;
}

//

function finallyPromiseGiveAsyncMode11( test )
{
  var testMsg = 'testMsg';
  var amode = _.Consequence.AsyncModeGet();
  var que = new _.Consequence().take( null )

  /* */

  .finally( () =>
  {
    test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );

    _.Consequence.AsyncModeSet([ 1, 1 ]);
    return null;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async competitors adding+resources adding signle resource';
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );
    var promise = con.finallyPromiseGive();
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 1 );
    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesGet().length, 0 );
        test.identical( con.competitorsEarlyGet().length, 0 );
      });
      return _.Consequence.From( promise );
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async competitors adding+resources adding error resource';
    var con = new _.Consequence({ tag : 'con' });
    con.error( testMsg );
    var promise = con.finallyPromiseGive();
    promise.catch( function( err )
    {
      test.is( _.strHas( String( err ), testMsg ) );
      test.is( _.promiseIs( promise ) );
    });
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return _.Consequence.From( promise ).finally( () => null );
    });
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async competitors adding+resources adding several resources';
    var con = new _.Consequence({ capacity : 3 });
    con.take( testMsg + 1 );
    con.take( testMsg + 2 );
    con.take( testMsg + 3 );
    var promise = con.finallyPromiseGive();
    test.identical( con.resourcesGet().length, 3 );
    test.identical( con.competitorsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg + 1 );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesGet().length, 2 );
        test.identical( con.competitorsEarlyGet().length, 0 );
      })
      return _.Consequence.From( promise );
    })
  })

  /* */

  .finally( ( err, arg ) =>
  {
    test.close( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );

    _.Consequence.AsyncModeSet( amode );


    if( err )
    throw err;
    return arg;

  })
  return que;
}

//--
// _finally
//--

function _finallyAsyncMode00( test )
{
  var c = this;
  var amode = _.Consequence.AsyncModeGet();
  var testMsg = 'msg';
  var con;
  var que = new _.Consequence().take( null )

  /* */

  .thenKeep( function( arg )
  {
    test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );

    test.case += ', no resource';
    _.Consequence.AsyncModeSet([ 0, 0 ]);
    return null;
  })
  .thenKeep( function( arg )
  {
    con = new _.Consequence();
    con.finally( () => test.identical( 0, 1 ) );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })
  .timeOut( 100 )
  .thenKeep( function( arg )
  {
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 );
    con.competitorsCancel();
    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case += ', single resource, competitor is a routine';
    return null;
  })
  .thenKeep( function( arg )
  {
    function competitor( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg );
      return null;
    }
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );
    test.identical( con.resourcesGet().length, 1 )
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg } )
    con.finally( competitor );
    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 1 )
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : null } );

    return con;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case += ', several finally, competitor is a routine';
    return null;
  })
  .thenKeep( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );
    con.finally( function( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg );
      return testMsg + 1;
    });
    con.finally( function( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg + 1);
      return testMsg + 2;
    });
    con.finally( function( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg + 2);
      return testMsg + 3;
    });
    test.identical( con.competitorsEarlyGet().length, 0 )
    test.identical( con.resourcesGet().length, 1 )
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg + 3 } );

    return con;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case += ', single resource, consequence as a competitor';
    return null;
  })
  .thenKeep( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    var con2 = new _.Consequence({ tag : 'con2' });
    var con2TakerFired = false;
    con.take( testMsg );
    /* finally only transfers the copy of messsage to the competitor without waiting for response */
    con.finally( con2 );
    con.give( function( err, got )
    {
      test.identical( got, testMsg );
      test.identical( con2TakerFired, false );
      test.identical( con2.resourcesGet().length, 1 );
    });

    con2.finally( function( err, got )
    {
      test.identical( got, testMsg )
      con2TakerFired = true;
      return null;
    });

    con2.finally( function()
    {
      test.identical( con2TakerFired, true );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet().length, 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

    return con2;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case += 'competitor returns consequence with msg';
    return null;
  })
  .thenKeep( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    var con2 = new _.Consequence({ tag : 'con2' });
    con.take( null );
    con.finally( function()
    {
      return con2.take( testMsg );
    });

    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.resourcesGet()[ 0 ].argument, testMsg );

    test.identical( con2.resourcesGet().length, 1 );
    test.identical( con2.resourcesGet()[ 0 ].argument, testMsg );

    return null;
  })

  /* */

  .finally( ( err, arg ) =>
  {
    test.close( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );

    _.Consequence.AsyncModeSet( amode );
    if( err )
    throw err;
    return arg;
  });
  return que;
}

//

function _finallyAsyncMode10( test )
{
  var c = this;
  var amode = _.Consequence.AsyncModeGet();
  var testMsg = 'msg';
  var con;
  var que = new _.Consequence().take( null )

  /* */

  .thenKeep( function( arg )
  {
    test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );

    test.case += ', no resource';
    _.Consequence.AsyncModeSet([ 1, 0 ]);
    return null;
  })

  // .thenKeep( function( arg )
  // {
  //   var con = new _.Consequence({ tag : 'con' });
  //   con.finally( () => test.identical( 0, 1 ) );
  //   test.identical( con.competitorsEarlyGet().length, 1 );
  //   test.identical( con.resourcesGet().length, 0 );ччч
  //   return null;
  // })

  .thenKeep( function( arg )
  {
    con = new _.Consequence();
    con.finally( () => test.identical( 0, 1 ) );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })
  .timeOut( 100 )
  .thenKeep( function( arg )
  {
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 );
    con.competitorsCancel();
    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case += ', single resource, competitor is a routine';
    return null;
  })
  .thenKeep( function( arg )
  {
    function competitor( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg );
      return null;
    }
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );
    con.finally( competitor );
    test.identical( con.resourcesGet().length, 1 )
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg } )
    test.identical( con.competitorsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 1 )
      test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : null } )
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case += ', several finally, competitor is a routine';
    return null;
  })
  .thenKeep( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );
    con.finally( function( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg );
      return testMsg + 1;
    });
    con.finally( function( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg + 1);
      return testMsg + 2;
    });
    con.finally( function( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg + 2);
      return testMsg + 3;
    });
    test.identical( con.competitorsEarlyGet().length, 3 )
    test.identical( con.resourcesGet().length, 1 )
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg } );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 )
      test.identical( con.resourcesGet().length, 1 )
      test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg + 3 } );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case += ', single resource, consequence as a competitor';
    return null;
  })
  .thenKeep( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    var con2 = new _.Consequence({ tag : 'con2' });
    var con2TakerFired = false;
    con.take( testMsg );
    con.finally( con2 );
    con.give( function( err, got )
    {
      test.identical( got, testMsg );
      test.identical( con2TakerFired, true );
      test.identical( con2.resourcesGet().length, 0 );
    });

    con2.give( function( err, got )
    {
      test.identical( got, testMsg )
      con2TakerFired = true;
    });

    test.identical( con2TakerFired, false );
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.competitorsEarlyGet().length, 2 );
    test.identical( con2.competitorsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con2TakerFired, true );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet().length, 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case += 'competitor returns consequence with msg';
    return null;
  })
  .thenKeep( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    var con2 = new _.Consequence({ tag : 'con2' });
    con.take( null );
    con.finally( function()
    {
      return con2.take( testMsg );
    });

    test.identical( con.competitorsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 1 );
      test.identical( con.resourcesGet()[ 0 ].argument, testMsg );

      test.identical( con2.resourcesGet().length, 1 );
      test.identical( con2.resourcesGet()[ 0 ].argument, testMsg );
      return null;
    })
  })

  /* */

  .finally( ( err, arg ) =>
  {
    test.close( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );

    _.Consequence.AsyncModeSet( amode );
    if( err )
    throw err;
    return arg;
  });
  return que;
}

//

function _finallyAsyncMode01( test )
{
  var c = this;
  var amode = _.Consequence.AsyncModeGet();
  var testMsg = 'msg';
  var con;
  var que = new _.Consequence().take( null )

  /* */

  .thenKeep( function( arg )
  {
    test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );

    test.case += ', no resource';
    _.Consequence.AsyncModeSet([ 0, 1 ]);
    return null;
  })
  // .thenKeep( function( arg )
  // {
  //   var con = new _.Consequence({ tag : 'con' });
  //   con.finally( () => test.identical( 0, 1 ) );
  //   test.identical( con.competitorsEarlyGet().length, 1 );
  //   test.identical( con.resourcesGet().length, 0 );
  //   return null;
  // })

  .thenKeep( function( arg )
  {
    con = new _.Consequence();
    con.finally( () => test.identical( 0, 1 ) );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })
  .timeOut( 100 )
  .thenKeep( function( arg )
  {
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 );
    con.competitorsCancel();
    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case += ', single resource, competitor is a routine';
    return null;
  })
  .thenKeep( function( arg )
  {
    function competitor( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg );
      return null;
    }
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );

    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 1 )
      test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg } )
      test.identical( con.competitorsEarlyGet().length, 0 );

      con.finally( competitor );
      return null;
    })
    .thenKeep( function( arg )
    {
      test.identical( con.competitorsEarlyGet().length, 0 )
      test.identical( con.resourcesGet().length, 1 )
      test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : null } )
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case += ', several finally, competitor is a routine';
    return null;
  })
  .thenKeep( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 )
      test.identical( con.resourcesGet().length, 1 )
      test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg } );

      con.finally( function( err, got )
      {
        test.identical( err , undefined )
        test.identical( got , testMsg );
        return testMsg + 1;
      });
      con.finally( function( err, got )
      {
        test.identical( err , undefined )
        test.identical( got , testMsg + 1);
        return testMsg + 2;
      });
      con.finally( function( err, got )
      {
        test.identical( err , undefined )
        test.identical( got , testMsg + 2);
        return testMsg + 3;
      });

      return con;
    })
    .thenKeep( function( arg )
    {
      test.identical( con.competitorsEarlyGet().length, 0 )
      test.identical( con.resourcesGet().length, 1 )
      test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg + 3 } );
      return null;
    })
 })

  /* */

  .thenKeep( function( arg )
  {
    test.case += ', single resource, consequence as a competitor';
    return null;
  })
  .thenKeep( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    var con2 = new _.Consequence({ tag : 'con2' });
    var con2TakerFired = false;
    con.take( testMsg );

    test.identical( con2TakerFired, false );
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con2.competitorsEarlyGet().length, 0 );

    return _.timeOut( 1, function()
    {
      con.finally( con2 );
      con.give( function( err, arg )
      {
        test.identical( arg, testMsg );
        test.identical( con2TakerFired, false );
        test.identical( con2.resourcesGet().length, 1 );
      });

      con2.finally( function( err, arg )
      {
        test.identical( arg, testMsg );
        con2TakerFired = true;
        return arg;
      });

    return con2;
    })
    .thenKeep( function( arg )
    {
      test.identical( con2TakerFired, true );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet().length, 1 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case += 'competitor returns consequence with msg';
    return null;
  })
  .thenKeep( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    var con2 = new _.Consequence({ tag : 'con2' });
    con.take( null );

    test.identical( con.resourcesGet().length, 1 );

    return _.timeOut( 1, function()
    {
      con.finally( function()
      {
        return con2.take( testMsg );
      });

      return con;
    })
    .thenKeep( function( arg )
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 1 );
      test.identical( con.resourcesGet()[ 0 ].argument, testMsg );

      test.identical( con2.resourcesGet().length, 1 );
      test.identical( con2.resourcesGet()[ 0 ].argument, testMsg );
      return null;
    })
  })

  /* */

  .finally( ( err, arg ) =>
  {
    test.close( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );

    _.Consequence.AsyncModeSet( amode );
    if( err )
    throw err;
    return arg;
  });
  return que;
}

//

function _finallyAsyncMode11( test )
{
  var c = this;
  var amode = _.Consequence.AsyncModeGet();
  var testMsg = 'msg';
  var con;
  var que = new _.Consequence().take( null )

  /* */

  .thenKeep( function( arg )
  {
    test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );

    test.case += ', no resource';
    _.Consequence.AsyncModeSet([ 1, 1 ]);
    return null;
  })
  // .thenKeep( function( arg )
  // {
  //   var con = new _.Consequence({ tag : 'con' });
  //   con.finally( () => test.identical( 0, 1 ) );
  //   test.identical( con.competitorsEarlyGet().length, 1 );
  //   test.identical( con.resourcesGet().length, 0 );
  //   return null;
  // })

  .thenKeep( function( arg )
  {
    con = new _.Consequence();
    con.finally( () => test.identical( 0, 1 ) );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })
  .timeOut( 100 )
  .thenKeep( function( arg )
  {
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 );
    con.competitorsCancel();
    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case += ', single resource, competitor is a routine'
    return null;
  })
  .thenKeep( function( arg )
  {
    function competitor( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg );
      return null;
    }
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );
    con.finally( competitor );
    test.identical( con.competitorsEarlyGet().length, 1 )
    test.identical( con.resourcesGet().length, 1 )
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg } )
    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 )
      test.identical( con.resourcesGet().length, 1 )
      test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : null } )
      return null;
    })
 })

  /* */

  .thenKeep( function( arg )
  {
    test.case += ', several finally, competitor is a routine';
    return null;
  })
  .thenKeep( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );

    con.finally( function( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg );
      return testMsg + 1;
    });
    con.finally( function( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg + 1);
      return testMsg + 2;
    });
    con.finally( function( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg + 2);
      return testMsg + 3;
    });

    test.identical( con.competitorsEarlyGet().length, 3 );
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg } );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 1 );
      test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg + 3} );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case += ', single resource, consequence as a competitor';
    return null;
  })
  .thenKeep( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    var con2 = new _.Consequence({ tag : 'con2' });
    var con2TakerFired = false;
    con.take( testMsg );
    con.finally( con2 );
    con.give( function( err, got )
    {
      test.identical( got, testMsg );
      test.identical( con2TakerFired, false );
      test.identical( con2.resourcesGet().length, 1 );
    });

    con2.give( function( err, got )
    {
      test.identical( got, testMsg );
      con2TakerFired = true;
    });

    test.identical( con2TakerFired, false );
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.competitorsEarlyGet().length, 2 );
    test.identical( con2.competitorsEarlyGet().length, 1 );
    test.identical( con2.resourcesGet().length, 0 );

    return _.timeOut( 1, function()
    {
      test.identical( con2TakerFired, true );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet().length, 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case += 'competitor returns consequence with msg';
    return null;
  })
  .thenKeep( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    var con2 = new _.Consequence({ tag : 'con2' });
    con.take( null );
    con.finally( function()
    {
      return con2.take( testMsg );
    });

    test.identical( con.resourcesGet().length, 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 1 );
      test.identical( con.resourcesGet()[ 0 ].argument, testMsg );

      test.identical( con2.resourcesGet().length, 1 );
      test.identical( con2.resourcesGet()[ 0 ].argument, testMsg );
      return null;
    })
  })

  /* */

  .finally( ( err, arg ) =>
  {
    test.close( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );

    _.Consequence.AsyncModeSet( amode );
    if( err )
    throw err;
    return arg;
  });
  return que;
}

//--
// finallyPromiseKeep
//--

function finallyPromiseKeepAsyncMode00( test )
{
  var testMsg = 'testMsg';
  var con;
  var amode = _.Consequence.AsyncModeGet();
  var que = new _.Consequence({ tag : 'finallyPromiseKeepCon' }).take( null )

  /* */

  .finally( () =>
  {
    test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );

    _.Consequence.AsyncModeSet([ 0, 0 ]);
    return null;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'no resource';
    con = new _.Consequence();
    var promise = con.finallyPromiseKeep();
    test.identical( con.resourcesGet().length, 0 );
    test.identical( con.competitorsEarlyGet().length, 1 );
    promise.then( function( got )
    {
      test.identical( 0, 1 );
    })
    return _.timeOut( 10 );
  })

  .timeOut( 100 )
  .thenKeep( function( arg )
  {
    test.identical( con.resourcesGet().length, 0 );
    test.identical( con.competitorsEarlyGet().length, 1 );
    con.competitorsCancel();
    test.identical( con.resourcesGet().length, 0 );
    test.identical( con.competitorsEarlyGet().length, 0 );
    return arg;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'single resource';
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );
    test.identical( con.resourcesGet().length, 1 );
    var promise = con.finallyPromiseKeep();
    promise.then( function( got )
    {
      test.identical( got, testMsg );
      test.is( _.promiseIs( promise ) );
      test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg }] );
      test.identical( con.competitorsEarlyGet().length, 0 );
    })

    return _.Consequence.From( promise );
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'error resource';
    var con = new _.Consequence({ tag : 'con' });
    con.error( testMsg );
    test.identical( con.resourcesGet().length, 1 );
    var promise = con.finallyPromiseKeep();
    promise.catch( function( err )
    {
      test.is( _.strHas( String( err ), testMsg ) );
      test.is( _.promiseIs( promise ) );
      // test.identical( con.resourcesGet(), [{ error : testMsg, argument : undefined }] );
      test.identical( con.argumentsGet(), [] );
      test.identical( con.errorsGet().length, 1 );
      test.identical( con.competitorsEarlyGet().length, 0 );
    })
    return _.Consequence.From( promise ).finally( () => null );
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'several resources';
    var con = new _.Consequence({ capacity : 3 });
    con.take( testMsg + 1 );
    con.take( testMsg + 2 );
    con.take( testMsg + 3 );
    test.identical( con.resourcesGet().length, 3 );
    var promise = con.finallyPromiseKeep();
    promise.then( function( got )
    {
      test.identical( got, testMsg + 1 );
      test.is( _.promiseIs( promise ) );
      test.identical( con.resourcesGet().length, 3 );
      test.identical( con.competitorsEarlyGet().length, 0 );
    })
    return _.Consequence.From( promise );
  })

  /* */

  .finally( ( err, arg ) =>
  {
    test.close( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );

    _.Consequence.AsyncModeSet( amode );
    if( err )
    throw err;
    return arg;
  })
  return que;
}

//

function finallyPromiseKeepAsyncMode10( test )
{
  var testMsg = 'testMsg';
  var con;
  var amode = _.Consequence.AsyncModeGet();
  var que = new _.Consequence({ tag : 'finallyPromiseKeepCon' }).take( null )

  /* */

  .finally( () =>
  {
    test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );

    _.Consequence.AsyncModeSet([ 1, 0 ]);
    return null;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async competitors adding, single resource';
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );
    var promise = con.finallyPromiseKeep();
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 1 );
    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg }] );
        test.identical( con.competitorsEarlyGet().length, 0 );
      });
      return _.Consequence.From( promise );
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async competitors adding, error resource';
    var con = new _.Consequence({ tag : 'con' });
    var catched = 0;
    con.error( testMsg );
    var promise = con.finallyPromiseKeep();
    promise.catch( function( err )
    {
      catched = 1;
      test.is( _.strHas( String( err ), testMsg ) );
      test.is( _.promiseIs( promise ) );
    });
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      // test.identical( con.resourcesGet(), [{ error : testMsg, argument : undefined }] );
      test.identical( con.argumentsGet(), [] );
      test.identical( con.errorsGet().length, 1 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( catched, 1 );
      return _.Consequence.From( promise ).finally( () => null );
    });
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async competitors adding, several resources';
    var con = new _.Consequence({ capacity : 3 });
    con.take( testMsg + 1 );
    con.take( testMsg + 2 );
    con.take( testMsg + 3 );
    var promise = con.finallyPromiseKeep();
    test.identical( con.resourcesGet().length, 3 );
    test.identical( con.competitorsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg + 1 );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesGet().length, 3 );
        test.identical( con.competitorsEarlyGet().length, 0 );
      })
      return _.Consequence.From( promise );
    })
  })

  /* */

  .finally( ( err, arg ) =>
  {
    test.close( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );

    _.Consequence.AsyncModeSet( amode );
    if( err )
    throw err;
    return arg;
  })
  return que;
}

//

function finallyPromiseKeepAsyncMode01( test )
{
  var testMsg = 'testMsg';
  var con;
  var amode = _.Consequence.AsyncModeGet();
  var que = new _.Consequence({ tag : 'finallyPromiseKeepCon' }).take( null )

  /* */

  .finally( () =>
  {
    test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );

    _.Consequence.AsyncModeSet([ 0, 1 ]);
    return null;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async resources adding, single resource';
    var con = new _.Consequence({ tag : 'con' });
    var promise = con.finallyPromiseKeep();
    con.take( testMsg );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 1 );
    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg }] );
        test.identical( con.competitorsEarlyGet().length, 0 );
      });
      return _.Consequence.From( promise );
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async resources adding, error resource';
    var catched = 0;
    var con = new _.Consequence({ tag : 'con' });
    var promise = con.finallyPromiseKeep();
    promise.catch( function( err )
    {
      test.is( _.strHas( String( err ), testMsg ) );
      test.is( _.promiseIs( promise ) );
      catched = 1;
    });
    con.error( testMsg );
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      // test.identical( con.resourcesGet(), [{ error : testMsg, argument : undefined }] );
      test.identical( con.argumentsGet(), [] );
      test.identical( con.errorsGet().length, 1 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( catched, 1 );
      return _.Consequence.From( promise ).finally( () => null );
    });
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async resources adding, several resources';
    var con = new _.Consequence({ capacity : 3 });
    var promise = con.finallyPromiseKeep();
    con.take( testMsg + 1 );
    con.take( testMsg + 2 );
    con.take( testMsg + 3 );
    test.identical( con.resourcesGet().length, 3 );
    test.identical( con.competitorsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg + 1 );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesGet().length, 3 );
        test.identical( con.competitorsEarlyGet().length, 0 );
      })
      return _.Consequence.From( promise );
    })
  })

  /* */

  .finally( ( err, arg ) =>
  {
    test.close( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );

    _.Consequence.AsyncModeSet( amode );
    if( err )
    throw err;
    return arg;
  })
  return que;
}

//

function finallyPromiseKeepAsyncMode11( test )
{
  var testMsg = 'testMsg';
  var con;
  var amode = _.Consequence.AsyncModeGet();
  var que = new _.Consequence({ tag : 'finallyPromiseKeepCon' }).take( null )

  /* */

  .finally( () =>
  {
    test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );

    _.Consequence.AsyncModeSet([ 1, 1 ]);
    return null;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async competitors adding+resources adding, single resource';
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );
    var promise = con.finallyPromiseKeep();
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 1 );
    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg }] );
        test.identical( con.competitorsEarlyGet().length, 0 );
      });
      return _.Consequence.From( promise );
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async competitors adding+resources adding, error resource';
    var catched = 0;
    var con = new _.Consequence({ tag : 'con' });
    con.error( testMsg );
    var promise = con.finallyPromiseKeep();
    promise.catch( function( err )
    {
      test.is( _.strHas( String( err ), testMsg ) );
      test.is( _.promiseIs( promise ) );
      catched = 1;
    });
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      // test.identical( con.resourcesGet(), [{ error : testMsg, argument : undefined }] );
      test.identical( con.argumentsGet(), [] );
      test.identical( con.errorsGet().length, 1 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( catched, 1 );
      return _.Consequence.From( promise ).finally( () => null );
    });
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async competitors adding+resources adding, several resources';
    var con = new _.Consequence({ capacity : 3 });
    con.take( testMsg + 1 );
    con.take( testMsg + 2 );
    con.take( testMsg + 3 );
    var promise = con.finallyPromiseKeep();
    test.identical( con.resourcesGet().length, 3 );
    test.identical( con.competitorsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg + 1 );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesGet().length, 3 );
        test.identical( con.competitorsEarlyGet().length, 0 );
      })
      return _.Consequence.From( promise );
    })
  })

  /* */

  .finally( ( err, arg ) =>
  {
    test.close( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );

    _.Consequence.AsyncModeSet( amode );
    if( err )
    throw err;
    return arg;
  })
  return que;
}

//

function split( test )
{
  var que = new _.Consequence().take( null )

  .thenKeep( function( arg )
  {
    test.case = 'split : run after resolve value';
    var con = new _.Consequence({ tag : 'con' }).take( 5 );
    var con2 = con.split();
    test.identical( con2.resourcesGet().length, 1 );
    con2.give( function( err, got )
    {
      test.identical( got, 5 );
      test.identical( err, undefined );
    });

    test.identical( con.resourcesGet().length, 1 );
    test.identical( con2.resourcesGet().length, 0 );
    return null;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'split : run before resolve value';
    var con = new _.Consequence({ tag : 'con' });
    var con2 = con.split();
    con2.give( function( err, got )
    {
      test.identical( got, 5 );
      test.identical( err, undefined );
    });
    con.take( 5 );
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con2.resourcesGet().length, 0 );
    return null;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'test split in chain';
    var _got = [];
    var _err = [];
    function competitor( err, got )
    {
      _got.push( got );
      _err.push( err );
    }

    var con = new _.Consequence({ capacity : 0 });
    con.take( 5 );
    con.take( 6 );
    test.identical( con.resourcesGet().length, 2 );
    var con2 = con.split();
    test.identical( con.resourcesGet().length, 2 );
    test.identical( con2.resourcesGet().length, 1 );
    con2.give( competitor );
    con2.give( competitor );

    test.identical( con2.resourcesGet().length, 0 );
    test.identical( con2.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 2 );
    test.identical( _got, [ 5 ] );
    test.identical( _err, [ undefined ] );

    con2.competitorsCancel( competitor );
    test.identical( con2.resourcesGet().length, 0 );
    test.identical( con2.competitorsEarlyGet().length, 0 );

    return null;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'passing competitor as argument';
    var _got = [];
    var _err = [];
    function competitor( err, got )
    {
      _got.push( got );
      _err.push( err );
      return null;
    }

    var con = new _.Consequence({ capacity : 0 });
    con.take( 5 );
    con.take( 6 );
    test.identical( con.resourcesGet().length, 2 );
    var con2 = con.split( competitor );

    test.identical( con2.resourcesGet().length, 1 );
    test.identical( con2.resourcesGet()[ 0 ], { error : undefined, argument : null } );
    test.identical( con2.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 2 );
    test.identical( _got, [ 5 ] )
    test.identical( _err, [ undefined ] )
    return null;
  })

  return que;
}

//

function tap( test )
{
  var testMsg = 'msg';
  var que = new _.Consequence().take( null )

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'single value in give sequence, and single taker : attached taker after value resolved';
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );
    con.tap( ( err, got ) => test.identical( got, testMsg ) );
    con.give( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'single error and single taker : attached taker after value resolved';
    var con = new _.Consequence({ tag : 'con' });
    con.error( testMsg );
    con.tap( ( err, got ) => test.is( _.strHas( String( err ), testMsg ) ) );
    con.give( ( err, got ) => test.is( _.strHas( String( err ), testMsg ) ) );
    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'test tap in chain';
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );
    con.tap( ( err, got ) => test.identical( got, testMsg ) );
    con.tap( ( err, got ) => test.identical( got, testMsg ) );
    con.give( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })

   /* */

  .thenKeep( function( arg )
  {
    if( !Config.debug )
    return;

    test.case = 'missed arguments';
    var con = _.Consequence();
    test.shouldThrowErrorOfAnyKind( function()
    {
      con.tap();
    });

    return null;
  })

  return que;
}

//

function tapHandling( test )
{
  var que = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    test.case = 'take at the end'
    var con = new _.Consequence({ tag : 'con' });
    var visited = [ 0, 0, 0, 0, 0, 0 ];

    con.take( null );
    con.then( ( arg ) =>
    {
      debugger;
      visited[ 0 ] = 1;
      throw 'Error';
      return arg;
    });
    con.then( ( arg ) =>
    {
      debugger;
      visited[ 1 ] = 1;
      return arg;
    });
    con.then( ( arg ) =>
    {
      debugger;
      visited[ 2 ] = 1;
      return arg;
    });
    con.tap( ( err, arg ) =>
    {
      debugger;
      test.is( _.errIs( err ) );
      test.identical( arg, undefined );
      visited[ 3 ] = 1;
    });
    con.then( ( arg ) =>
    {
      debugger;
      visited[ 4 ] = 1;
      return arg;
    });
    con.then( ( arg ) =>
    {
      debugger;
      visited[ 5 ] = 1;
      return arg;
    });

    return _.timeOut( 50, () =>
    {
      test.identical( visited, [ 1, 0, 0, 1, 0, 0 ] );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
    });
  })

  /* */

  .then( function( arg )
  {
    test.case = 'take at the end'
    var con = new _.Consequence({ tag : 'con' });
    var visited = [ 0, 0, 0, 0, 0, 0 ];

    con.then( ( arg ) =>
    {
      debugger;
      visited[ 0 ] = 1;
      throw 'Error';
      return arg;
    });
    con.then( ( arg ) =>
    {
      debugger;
      visited[ 1 ] = 1;
      return arg;
    });
    con.then( ( arg ) =>
    {
      debugger;
      visited[ 2 ] = 1;
      return arg;
    });
    con.tap( ( err, arg ) =>
    {
      debugger;
      test.is( _.errIs( err ) );
      test.identical( arg, undefined );
      visited[ 3 ] = 1;
    });
    con.then( ( arg ) =>
    {
      debugger;
      visited[ 4 ] = 1;
      return arg;
    });
    con.then( ( arg ) =>
    {
      debugger;
      visited[ 5 ] = 1;
      return arg;
    });
    con.take( null );

    return _.timeOut( 50, () =>
    {
      test.identical( visited, [ 1, 0, 0, 1, 0, 0 ] );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
    });
  })

  /* */

  return que;
}

//

// function catchTestRoutine( test )
// {

//   var testCheck1 =

//     {
//       givSequence : [ 5 ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence : [],
//         throwErr : false
//       }
//     },
//     testCheck2 =
//     {
//       givSequence :
//         [
//           'err msg'
//         ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//           [
//             { err : 'err msg', takerId : 'taker1' }
//           ],
//         throwErr : false
//       }
//     },
//     testCheck3 =
//     {
//       givSequence : [ 5, 'err msg',  4 ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//           [
//             { err : undefined, value : 5, takerId : 'taker3' },
//           ],
//         throwErr : false
//       }
//     };


//   /* common wConsequence corespondent tests. */

//   test.case = 'single value in give sequence, and single taker : attached taker after value resolved';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, takerId } );
//     }

//     var con = _.Consequence();
//     con.take( givSequence.shift() );
//     try
//     {
//       con.catch( testTaker1 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck1 );

//   /* */

//   test.case = 'single err in give sequence, and single taker : attached taker after value resolved';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, takerId } );
//     }

//     var con = _.Consequence();
//     try
//     {
//       con.error( givSequence.shift() );
//       con.catch( testTaker1 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck2 );

//   /* */

//   test.case = 'test tap in chain';

//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, takerId } );
//       value++;
//       return value;
//     }

//     function testTaker2( err )
//     {
//       var takerId = 'taker2';
//       got.gotSequence.push( { err, takerId } );
//     }

//     function testTaker3( err, value )
//     {
//       var takerId = 'taker3';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();

//     con.take( givSequence.shift() );
//     con.error( givSequence.shift() );
//     con.take( givSequence.shift() );

//     try
//     {
//       con.catch( testTaker1 );
//       con.catch( testTaker2 );
//       con.give( testTaker3 );

//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck3 );

//   if( Config.debug )
//   {
//     var conDeb1 = _.Consequence();

//     test.case = 'missed arguments';
//     test.shouldThrowErrorOfAnyKind( function()
//     {
//       conDeb1.catch();
//     } );
//   }

// };

//

function catchTestRoutine( test )
{
  var testMsg = 'msg';
  var que = new _.Consequence().take( null )

  /* common wConsequence corespondent tests. */

  .thenKeep( function( arg )
  {
    test.case = 'single value in give sequence, and single taker : attached taker after value resolved';
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );
    con.catch( ( err ) => { test.identical( 0, 1 ); return null; } );
    con.give( ( err, got ) => test.identical( got, testMsg ));

    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 0 );

    return arg;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'single err in give sequence, and single taker : attached taker after value resolved';
    var con = new _.Consequence({ tag : 'con' });
    con.error( testMsg );
    con.catch( ( err ) => { test.is( _.strHas( String( err ), testMsg ) ); return null; });
    con.give( ( err, got ) => test.identical( got, null ) );

    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 0 );

    return arg;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'test catchTestRoutine in chain, regular resource is given before error';
    var con = new _.Consequence({ capacity : 0 });
    con.take( testMsg );
    con.error( testMsg + 1 );
    con.error( testMsg + 2 );

    con.catch( ( err ) => { test.identical( 0, 1 ); return null; });
    con.catch( ( err ) => { test.identical( 0, 1 ); return null; });
    con.give( ( err, got ) => test.identical( got, testMsg ) );

    test.identical( con.resourcesGet().length, 2 );
    test.is( _.strHas( String( con.resourcesGet()[ 0 ].error ), testMsg + 1 ) );
    test.is( _.strHas( String( con.resourcesGet()[ 1 ].error ), testMsg + 2 ) );
    test.identical( con.competitorsEarlyGet().length, 0 );

    return arg;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'test catchTestRoutine in chain, regular resource is given after error';
    var con = new _.Consequence({ capacity : 0 });
    con.error( testMsg + 1 );
    con.error( testMsg + 2 );
    con.take( testMsg );

    test.is( _.strHas( String( con.resourcesGet()[ 0 ].error ), testMsg + 1 ) );

    con.catch( ( err ) => { test.is( _.strHas( String( err ), testMsg + 1 ) ); return null; });
    con.catch( ( err ) => { test.is( _.strHas( String( err ), testMsg + 2 ) ); return null; });
    con.give( ( err, got ) => test.identical( got, testMsg ) );

    test.identical( con.resourcesGet().length, 2 );
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : null } );
    test.identical( con.resourcesGet()[ 1 ], { error : undefined, argument : null } );
    test.identical( con.competitorsEarlyGet().length, 0 );

    return arg;
  })

   /* */

  .thenKeep( function( arg )
  {
    if( !Config.debug )
    return;

    test.case = 'missed arguments';
    var con = _.Consequence();
    return test.shouldThrowErrorSync( function()
    {
      con.catch();
    });
  })

  return que;
}

//

function ifNoErrorGotTrivial( test )
{
  let con = new _.Consequence();
  let last = 0;

  con.take( 0 );
  con.toStr();

  con
  .ifNoErrorGot( ( arg ) =>
  {
    let result = _.Consequence().take( 1 );
    test.identical( arg, 0 );
    last = 1;
    return result;
  })
  .finally( ( err, arg ) =>
  {
    if( err )
    _.errLogOnce( err );
    last = 2
    return null;
  });

  return _.timeOut( 100, () =>
  {
    test.identical( last, 1 );
    con.competitorsCancel();
    return null;
  });

}

//

function ifNoErrorGotThrowing( test )
{
  let con = new _.Consequence();
  let last = 0;
  let error = null;

  con.take( 0 );
  con.toStr();

  con
  .ifNoErrorGot( ( arg ) =>
  {
    let result = _.Consequence().take( 1 );
    test.identical( arg, 0 );
    last = 1;
    // debugger;
    throw 'Throw error';
    return result;
  })
  .finally( ( err, arg ) =>
  {
    test.identical( arg, undefined );
    if( err )
    {
      // debugger;
      error = err;
      // _.errLogOnce( err );
      _.errAttend( err );
    }
    last = 2
    return null;
  });

  return _.timeOut( 100, () =>
  {
    test.identical( last, 2 );
    test.is( _.errIs( error ) );
    return null;
  });

}

//

function keep( test )
{
  var testMsg = 'msg';
  var que = new _.Consequence().take( null )

  /* common wConsequence corespondent tests. */

  .thenKeep( function( arg )
  {
    test.case = 'single value in give sequence, and single taker : attached taker after value resolved';
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );
    con.then( ( got ) => { test.identical( got, testMsg ); return null; } );
    con.give( ( err, got ) => test.identical( got, null ) );

    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'single err in give sequence, and single taker : attached taker after value resolved';
    var con = new _.Consequence({ tag : 'con' });
    con.error( testMsg );
    con.then( ( got ) => { test.identical( 0, 1 ); return null; });
    con.give( ( err, got ) => test.is( _.strHas( String( err ), testMsg ) ) );

    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'test keep in chain, regular resource is given before error';
    var con = new _.Consequence({ capacity : 0 });
    con.take( testMsg );
    con.take( testMsg );
    con.error( testMsg );

    con.then( ( got ) => { test.identical( got, testMsg ); return null; });
    con.then( ( got ) => { test.identical( got, testMsg ); return null; });

    test.identical( con.resourcesGet().length, 3 );
    // test.identical( con.resourcesGet()[ 0 ].error, testMsg );
    test.is( _.strHas( String( con.resourcesGet()[ 0 ].error ), testMsg ) );
    test.identical( con.resourcesGet()[ 1 ], { error : undefined, argument : null } );
    test.identical( con.resourcesGet()[ 2 ], { error : undefined, argument : null } );
    test.identical( con.competitorsEarlyGet().length, 0 );
    return null;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'test keep in chain, regular resource is given after error';
    var con = new _.Consequence({ capacity : 0 });
    con.error( testMsg );
    con.take( testMsg );
    con.take( testMsg );

    con.then( ( got ) => { test.identical( 0, 1 ); return null; });
    con.then( ( got ) => { test.identical( 0, 1 ); return null; });

    test.identical( con.resourcesGet().length, 3 );
    // test.identical( con.resourcesGet()[ 0 ].error, testMsg );
    test.is( _.strHas( String( con.resourcesGet()[ 0 ].error ), testMsg ) );
    test.identical( con.resourcesGet()[ 1 ], { error : undefined, argument : testMsg } );
    test.identical( con.resourcesGet()[ 2 ], { error : undefined, argument : testMsg } );
    test.identical( con.competitorsEarlyGet().length, 0 );
    return null;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'test keep in chain serveral resources';
    var con = new _.Consequence({ capacity : 0 });
    con.take( testMsg );
    con.take( testMsg );

    con.then( ( got ) => { test.identical( got, testMsg ); return null; });
    con.then( ( got ) => { test.identical( got, testMsg ); return null; });

    test.identical( con.resourcesGet().length, 2 );
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : null } );
    test.identical( con.resourcesGet()[ 1 ], { error : undefined, argument : null } );
    test.identical( con.competitorsEarlyGet().length, 0 );
    return null;
  })

   /* */

  .thenKeep( function( arg )
  {
    if( !Config.debug )
    return;

    test.case = 'missed arguments';
    var con = _.Consequence();
    test.shouldThrowErrorOfAnyKind( function()
    {
      con.then();
    });
    return null;
  })

  return que;
}

//

function timeOut( test )
{
  var testMsg = 'msg';
  var que = new _.Consequence().take( null )

  /* common wConsequence corespondent tests. */

  .thenKeep( function( arg )
  {
    test.case = 'single value in give sequence, and single taker : attached taker after value resolved';
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );
    con.timeOut( 0, ( err, got ) => { test.identical( got, testMsg ); return null; } );
    con.give( ( err, got ) => test.identical( got, null ) );

    return _.timeOut( 0, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'single err in give sequence, and single taker : attached taker after value resolved';
    var con = new _.Consequence({ tag : 'con' });
    con.error( testMsg );
    con.timeOut( 0, ( err, got ) => { test.is( _.strHas( String( err ), testMsg ) ); return null; } );
    con.give( ( err, got ) => test.identical( got, null ) );

    return _.timeOut( 0, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'test timeOut in chain';
    var delay = 0;
    var con = new _.Consequence({ capacity : 3 });
    con.take( testMsg );
    con.take( testMsg + 1 );
    con.take( testMsg + 2 );
    con.timeOut( delay, ( err, got ) => { test.identical( got, testMsg ); return null; } );
    con.timeOut( ++delay, ( err, got ) => { test.identical( got, testMsg + 1 ); return null; } );
    con.timeOut( ++delay, ( err, got ) => { test.identical( got, testMsg + 2 ); return null; } );

    return _.timeOut( delay, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 3 );
      con.resourcesGet()
      .every( ( msg ) => test.identical( msg, { error : undefined, argument : null } ) )
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    if( !Config.debug )
    return;

    test.case = 'missed arguments';
    var con = _.Consequence();
    test.shouldThrowErrorOfAnyKind( function()
    {
      con.timeOut();
    });
    return null;
  })

  return que;
}

//

function notDeadLock1( test )
{
  let con1 =  new _.Consequence({ capacity : 0 });
  let con2 =  new _.Consequence({ capacity : 0 });

  if( !Config.debug )
  return _.dont;

  test.case = 'take argument later';
  var got = [];
  test.identical( con1._dependsOf, [] );
  test.identical( con2._dependsOf, [] );
  con1.then( con2 );

  test.identical( con1._dependsOf, [] );
  test.identical( con2._dependsOf, [ con1 ] );
  con2.then( con1 );

  con1.then( ( arg ) => got.push( arg+1 ) );
  con2.then( ( arg ) => got.push( arg+2 ) );
  con1.take( 0 );

  test.identical( con1.resourcesGet(), [ { error : undefined, argument : 0 }, { error : undefined, argument : 1 } ] );
  test.identical( con1.competitorsEarlyGet().length, 0 );
  test.identical( con2.resourcesGet(), [{ error : undefined, argument : 2 }] );
  test.identical( con2.competitorsEarlyGet().length, 0 );
  test.identical( got, [ 1, 2 ] );

  /* */

  test.case = 'take argument early';
  var got = [];
  con1.cancel();
  con2.cancel();

  test.identical( con1._dependsOf, [] );
  test.identical( con2._dependsOf, [] );

  con2.take( 0 );
  con1.then( con2 );
  con2.then( con1 );
  con1.then( ( arg ) => got.push( arg+3 ) );
  con2.then( ( arg ) => got.push( arg+4 ) );

  test.identical( con1.resourcesGet(), [ { error : undefined, argument : 1 } ] );
  test.identical( con1.competitorsEarlyGet().length, 0 );
  test.identical( con2.resourcesGet(), [ { error : undefined, argument : 0 }, { error : undefined, argument : 2 } ] );
  test.identical( con2.competitorsEarlyGet().length, 0 );
  test.identical( got, [ 3, 4 ] );

  /* */

  test.case = 'thenGive';
  var got = [];
  con1.cancel();
  con2.cancel();

  test.identical( con1._dependsOf, [] );
  test.identical( con2._dependsOf, [] );
  con1.thenGive( con2 );

  test.identical( con1._dependsOf, [] );
  test.identical( con2._dependsOf, [ con1 ] );
  con2.then( con1 );

  con1.thenGive( ( arg ) => got.push( arg+1 ) );
  con2.thenGive( ( arg ) => got.push( arg+2 ) );

  con1.take( 0 );

  test.identical( con1.resourcesGet(), [] );
  test.identical( con1.competitorsEarlyGet().length, 0 );
  test.identical( con2.resourcesGet(), [] );
  test.identical( con2.competitorsEarlyGet().length, 0 );
  test.identical( got, [ 1, 2 ] );
}

//

function andNotDeadLock( test )
{
  let ready =  new _.Consequence();
  let prevReady = ready;
  let readies = [];
  let elements = [ 0, 1 ];
  let got;

  if( !Config.debug )
  return _.dont;

  for( let c = 0 ; c < elements.length ; c++ )
  {
    let currentReady = new _.Consequence();

    test.identical( currentReady._dependsOf, [] );
    if( c === 1 )
    test.identical( prevReady._dependsOf, [ ready ] );
    else
    test.identical( prevReady._dependsOf, [] );

    readies.push( currentReady );
    prevReady.then( currentReady );

    test.identical( currentReady._dependsOf, [ prevReady ] );
    if( c === 1 )
    test.identical( prevReady._dependsOf, [ ready ] );
    else
    test.identical( prevReady._dependsOf, [] );

    prevReady = currentReady;
    currentReady.then( () => c );
  }

  test.identical( ready._dependsOf, [] );
  test.identical( readies[ 0 ]._dependsOf, [ ready ] );
  test.identical( readies[ 1 ]._dependsOf, [ readies[ 0 ] ] );

  ready.take( null );
  ready.andKeep( readies );

  test.identical( ready._dependsOf, [] );
  test.identical( readies[ 0 ]._dependsOf, [] );
  test.identical( readies[ 1 ]._dependsOf, [] );

  ready.finally( ( err, arg ) =>
  {
    test.is( err === undefined );
    test.identical( arg, [ 0, 1, null ] );
    got = arg;
    if( err )
    throw err;
    return arg;
  });

  test.identical( got, [ 0, 1, null ] );

  return ready;
}

//

function andConcurrent( test )
{
  if( !Config.debug )
  return _.dont;

  let que = _.after();

  que.then( () =>
  {
    test.case = 'serial, sync';
    return act( 0, 1 );
  });

  que.then( () =>
  {
    test.case = 'serial, async';
    return act( 0, 0 );
  });

  que.then( () =>
  {
    test.case = 'concurrent, sync';
    return act( 0, 1 );
  });

  que.then( () =>
  {
    test.case = 'concurrent, async';
    return act( 0, 0 );
  });

  /* error */

  que.then( () =>
  {
    test.case = 'serial, sync, error';
    return act( 0, 1, 'Error!' );
  });

  que.then( () =>
  {
    test.case = 'serial, async, error';
    return act( 0, 0, 'Error!' );
  });

  que.then( () =>
  {
    test.case = 'concurrent, sync, error';
    return act( 1, 1, 'Error!' );
  });

  que.then( () =>
  {
    test.case = 'concurrent, async, error';
    return act( 1, 0, 'Error!' );
  });

  return que;

  function act( concurrent, sync, error )
  {
    let elements = [ 0, 1 ];
    let gotError, gotArg;

    /* code to use : begin */

    let ready =  new _.Consequence();
    let prevReady = ready;
    let readies = [];

    for( let c = 0 ; c < elements.length ; c++ )
    {
      let currentReady = new _.Consequence();
      readies.push( currentReady );

      if( concurrent )
      {
        prevReady.then( currentReady );
      }
      else
      {
        prevReady.finally( currentReady );
        prevReady = currentReady;
      }

      action( currentReady, c );
    }

    /* code to use : end */

    if( sync )
    ready.take( null );

    ready.andKeep( readies );
    ready.finally( ( err, arg ) =>
    {
      gotError = err;
      gotArg = arg;

      if( error )
      test.is( _.errIs( err ) );
      else
      test.is( err === undefined );

      if( error )
      test.identical( readies[ 0 ].resourcesGet(), [ { 'error' : err, 'argument' : undefined } ] );
      else
      test.identical( readies[ 0 ].resourcesGet(), [ { 'error' : undefined, 'argument' : 10 } ] );
      test.identical( readies[ 0 ].competitorsEarlyGet().length, 0 );

      if( error && !concurrent )
      test.identical( readies[ 1 ].resourcesGet(), [ { 'error' : err, 'argument' : undefined } ] );
      else
      test.identical( readies[ 1 ].resourcesGet(), [ { 'error' : undefined, 'argument' : 11 } ] );
      test.identical( readies[ 1 ].competitorsEarlyGet().length, 0 );

      test.identical( ready.resourcesGet(), [] );
      test.identical( ready.competitorsEarlyGet().length, sync ? 0 : 1 );

      if( error )
      test.identical( arg, undefined );
      else
      test.identical( arg, [ 10, 11, null ] );

      if( error )
      test.identical( elements, [ 0, concurrent ? 11 : 1 ] );
      else
      test.identical( elements, [ 10, 11 ] );

      if( err )
      {
        if( error )
        return null
        else
        throw err;
      }

      if( err )
      _.errAttend( err );

      return arg;
    });

    if( !sync )
    ready.take( null );

    if( sync )
    {

      if( error )
      test.identical( readies[ 0 ].resourcesGet(), [ { 'error' : gotError, 'argument' : undefined } ] );
      else
      test.identical( readies[ 0 ].resourcesGet(), [ { 'error' : undefined, 'argument' : 10 } ] );
      test.identical( readies[ 0 ].competitorsEarlyGet().length, 0 );

      if( error && !concurrent )
      test.identical( readies[ 1 ].resourcesGet(), [ { 'error' : gotError, 'argument' : undefined } ] );
      else
      test.identical( readies[ 1 ].resourcesGet(), [ { 'error' : undefined, 'argument' : 11 } ] );
      test.identical( readies[ 1 ].competitorsEarlyGet().length, 0 );

      if( error )
      test.identical( gotArg, undefined );
      else
      test.identical( gotArg, [ 10, 11, null ] );
      test.identical( ready.competitorsEarlyGet().length, 0 );
    }

    return ready;

    function action( currentReady, c )
    {
      if( sync )
      {
        if( error && c === 0 )
        currentReady.then( () => { throw error } );
        else
        currentReady.then( () => elements[ c ] += 10 );
      }
      else
      {
        if( error && c === 0 )
        currentReady.then( () => _.timeOut( 250, () => { throw error } ) );
        else
        currentReady.then( () => _.timeOut( 250, elements[ c ] += 10 ) );
      }
    }

  }

}

//

function andKeepRoutinesTakeFirst( test )
{
  var con = _.Consequence();
  var routines =
  [
    () => _.timeOut( 100, 0 ),
    () => _.timeOut( 100, 1 ),
    () => _.timeOut( 100, 2 ),
    () => _.timeOut( 100, 3 ),
    () => _.timeOut( 100, 4 ),
    () => _.timeOut( 100, 5 ),
    () => _.timeOut( 100, 6 ),
  ]

  con.take( null );
  con.andKeep( routines );

  con.finally( ( err, args ) =>
  {
    test.identical( err, undefined );
    test.identical( args, [ 0, 1, 2, 3, 4, 5, 6, null ] );
    if( err )
    throw err;
    return args;
  })

  return con;
}

//

function andKeepRoutinesTakeLast( test )
{
  var con = _.Consequence();
  var routines =
  [
    () => _.timeOut( 100, 0 ),
    () => _.timeOut( 100, 1 ),
    () => _.timeOut( 100, 2 ),
    () => _.timeOut( 100, 3 ),
    () => _.timeOut( 100, 4 ),
    () => _.timeOut( 100, 5 ),
    () => _.timeOut( 100, 6 ),
  ]

  con.andKeep( routines );

  con.finally( ( err, args ) =>
  {
    test.identical( err, undefined );
    test.identical( args, [ 0, 1, 2, 3, 4, 5, 6, null ] );
    if( err )
    throw err;
    return args;
  })

  con.take( null );

  return con;
}

//

function andKeepRoutinesDelayed( test )
{
  var con = _.Consequence();
  var routines =
  [
    () => _.timeOut( 100, 0 ),
    () => _.timeOut( 100, 1 ),
    () => _.timeOut( 100, 2 ),
    () => _.timeOut( 100, 3 ),
    () => _.timeOut( 100, 4 ),
    () => _.timeOut( 100, 5 ),
    () => _.timeOut( 100, 6 ),
  ]

  con.andKeep( routines );

  con.finally( ( err, args ) =>
  {
    test.identical( err, undefined );
    test.identical( args, [ 0, 1, 2, 3, 4, 5, 6, null ] );
    if( err )
    throw err;
    return args;
  })

  _.timeOut( 250, () =>
  {
    con.take( null );
    return true;
  });

  return con;
}

//

function andKeepDuplicates( test )
{

  let que = _.Consequence().take( null )

  /* */

  .then( ( arg ) =>
  {
    test.case = 'late take';

    var con = _.Consequence({ tag : 'con' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });
    var con3 = new _.Consequence({ tag : 'con3' });
    var cons =
    [
      con3,
      con3,
      con1,
      con2,
      con2,
      con2,
      con1,
    ]

    con.take( null );
    con.andKeep( cons );
    con.finally( ( err, arg ) =>
    {
      test.identical( err, undefined );
      test.identical( arg, [ 3, 3, 1, 2, 2, 2, 1, null ] );
      if( Config.debug )
      test.identical( con._dependsOf.length, 0 );
      test.identical( con1.infoExport({ verbosity : 1 }), 'Consequence::con1 1 / 0' );
      test.identical( con2.infoExport({ verbosity : 1 }), 'Consequence::con2 1 / 0' );
      test.identical( con3.infoExport({ verbosity : 1 }), 'Consequence::con3 1 / 0' );
      test.identical( con1.argumentsGet(), [ 1 ] );
      test.identical( con2.argumentsGet(), [ 2 ] );
      test.identical( con3.argumentsGet(), [ 3 ] );

      if( err )
      throw err;
      return arg;
    })

    _.timeBegin( 10, () => con1.take( 1 ) );
    _.timeBegin( 20, () => con2.take( 2 ) );
    _.timeBegin( 30, () => con3.take( 3 ) );

    return con;
  })

  /* */

  que.then( ( arg ) =>
  {
    test.case = 'mixed take';

    var con = _.Consequence({ capacity : 0 });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });
    var con3 = new _.Consequence({ tag : 'con3' });
    debugger;
    var cons =
    [
      con3,
      con3,
      con1,
      con2,
      con2,
      con2,
      con1,
    ]

    con1.take( 1 );
    con.take( null );
    con.andKeep( cons );
    con2.take( 2 );
    con.finally( ( err, arg ) =>
    {
      test.identical( err, undefined );
      test.identical( arg, [ 3, 3, 1, 2, 2, 2, 1, null ] );
      if( Config.debug )
      test.identical( con._dependsOf.length, 0 );

      test.identical( con1.infoExport({ verbosity : 1 }), 'Consequence::con1 1 / 0' );
      test.identical( con2.infoExport({ verbosity : 1 }), 'Consequence::con2 1 / 0' );
      test.identical( con3.infoExport({ verbosity : 1 }), 'Consequence::con3 1 / 0' );
      test.identical( con1.argumentsGet(), [ 1 ] );
      test.identical( con2.argumentsGet(), [ 2 ] );
      test.identical( con3.argumentsGet(), [ 3 ] );

      if( err )
      throw err;
      return arg;
    })

    _.timeBegin( 30, () => con3.take( 3 ) );

    return con;
  })

  return que;
}

//

function andKeepInstant( test )
{
  var testMsg = 'msg';
  var que = new _.Consequence().take( null )

  /*
  instant version should work synchronously, but delayed should work asynchronously
  */

  que
  .thenKeep( function( arg )
  {
    test.case = 'instant check, delayed, main takes later';
    return act( 0 );
  })
  .thenKeep( function( arg )
  {
    test.case = 'instant check, instant, main takes later';
    return act( 1 );
  })

  return que;

  function act( instant )
  {

    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con1 = new _.Consequence({ tag : 'con1', capacity : 3 });
    var con2 = new _.Consequence({ tag : 'con2', capacity : 3 });
    var con3 = new _.Consequence({ tag : 'con3', capacity : 3 });
    var srcs = [ con3, con1, con2  ];

    mainCon.take( testMsg );

    con1.take( 'con1a' );
    con1.take( 'con1b' );
    con1.take( 'con1c' );

    if( instant )
    {

      con2.take( 'con2a' );
      con2.take( 'con2b' );
      con2.take( 'con2c' );

      con3.take( 'con3a' );
      con3.take( 'con3b' );
      con3.take( 'con3c' );

    }

    mainCon.andKeep( srcs );
    mainCon.finally( function( err, got )
    {
      test.identical( got, [ 'con3a', 'con1a', 'con2a', testMsg ] );
      checkFinally();
      return null;
    });

    if( !instant )
    {

      con2.take( 'con2a' );
      con2.take( 'con2b' );
      con2.take( 'con2c' );

      checkBeforeCon3();
      con3.take( 'con3a' );
      checkAfterCon3();
      con3.take( 'con3b' );
      con3.take( 'con3c' );

    }

    return mainCon;

    function checkFinally()
    {
      test.identical( mainCon.resourcesGet(), [] );
      test.identical( mainCon.competitorsEarlyGet().length, instant ? 0 : 1 );
      var expected =
      [
        { 'error' : undefined, 'argument' : 'con1b' },
        { 'error' : undefined, 'argument' : 'con1c' },
        { 'error' : undefined, 'argument' : 'con1a' },
      ]
      test.identical( con1.resourcesGet(), expected );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      var expected =
      [
        { 'error' : undefined, 'argument' : 'con2b' },
        { 'error' : undefined, 'argument' : 'con2c' },
        { 'error' : undefined, 'argument' : 'con2a' }
      ]
      test.identical( con2.resourcesGet(), expected );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      var expected =
      [
        { 'error' : undefined, 'argument' : 'con3b' },
        { 'error' : undefined, 'argument' : 'con3c' },
        { 'error' : undefined, 'argument' : 'con3a' }
      ]
      test.identical( con3.resourcesGet(), expected );
      test.identical( con3.competitorsEarlyGet().length, 0 );
    }

    function checkBeforeCon3()
    {
      test.identical( mainCon.resourcesGet(), [] );
      test.identical( mainCon.competitorsEarlyGet().length, 1 );
      var expected =
      [
        { 'error' : undefined, 'argument' : 'con1b' },
        { 'error' : undefined, 'argument' : 'con1c' },
      ]
      test.identical( con1.resourcesGet(), expected );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      var expected =
      [
        { 'error' : undefined, 'argument' : 'con2b' },
        { 'error' : undefined, 'argument' : 'con2c' },
      ]
      test.identical( con2.resourcesGet(), expected );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      var expected =
      [
      ]
      test.identical( con3.resourcesGet(), expected );
      test.identical( con3.competitorsEarlyGet().length, 1 );
    }

    function checkAfterCon3()
    {
      test.identical( mainCon.resourcesGet(), [] );
      test.identical( mainCon.competitorsEarlyGet().length, 1 );
      var expected =
      [
        { 'error' : undefined, 'argument' : 'con1b' },
        { 'error' : undefined, 'argument' : 'con1c' },
      ]
      test.identical( con1.resourcesGet(), expected );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      var expected =
      [
        { 'error' : undefined, 'argument' : 'con2b' },
        { 'error' : undefined, 'argument' : 'con2c' },
      ]
      test.identical( con2.resourcesGet(), expected );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      var expected =
      [
      ]
      test.identical( con3.resourcesGet(), expected );
      test.identical( con3.competitorsEarlyGet().length, 0 );
    }

  }

}

//

function andKeep( test )
{
  var testMsg = 'msg';
  var que = new _.Consequence().take( null )

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'andKeep waits only for first resource and return it back';
    var delay = 100;
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con = new _.Consequence({ tag : 'con', capacity : 2 });

    mainCon.take( testMsg );

    mainCon.andKeep( con );

    mainCon.finally( function( err, got )
    {
      test.identical( got, [ delay, testMsg ] );
      test.identical( mainCon.resourcesGet().length, 0 );
      test.identical( con.resourcesGet(), [{ error : undefined, argument : delay }] );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return null;
    });

    _.timeOut( delay, () => { con.take( delay ); return null; });
    _.timeOut( delay * 2, () => { con.take( delay * 2 ); return null; });

    return _.timeOut( delay * 4, function()
    {
      test.identical( con.resourcesGet().length, 2 );
      test.identical( con.resourcesGet()[ 1 ].argument, delay * 2 );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'andKeep waits for first resource from consequence returned by routine call and returns resource back';
    var delay = 100;
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con = new _.Consequence({ tag : 'con', capacity : 2 });

    mainCon.take( testMsg );

    mainCon.andKeep( () => con );

    mainCon.finally( function( err, got )
    {
      test.identical( got, [ delay, testMsg ] );
      test.identical( mainCon.resourcesGet().length, 0 );
      test.identical( con.resourcesGet().length, 1 );
      test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : delay } );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return null;
    });

    _.timeOut( delay, () => { con.take( delay );return null; });
    _.timeOut( delay * 2, () => { con.take( delay * 2 );return null; });

    return _.timeOut( delay * 4, function()
    {
      test.identical( con.resourcesGet().length, 2 );
      test.identical( con.resourcesGet()[ 1 ], { error : undefined, argument : delay * 2 } );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'give back resources to several consequences, different delays';
    var delay = 100;
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });
    var con3 = new _.Consequence({ tag : 'con3' });

    var srcs = [ con1, con2, con3 ];

    mainCon.take( testMsg );

    mainCon.andKeep( srcs );

    mainCon.finally( function( err, got )
    {
      test.identical( got, [ delay, delay * 2, testMsg + testMsg, testMsg ] )
      test.identical( mainCon.resourcesGet().length, 0 );

      test.identical( con1.resourcesGet(), [ { error : undefined, argument : delay } ]);
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesGet(), [ { error : undefined, argument : delay * 2 } ]);
      test.identical( con2.competitorsEarlyGet().length, 0 );

      test.identical( con3.resourcesGet(), [ { error : undefined, argument : testMsg + testMsg } ]);
      test.identical( con3.competitorsEarlyGet().length, 0 );

      return null;
    });

    _.timeOut( delay, () => { con1.take( delay );return null; });
    _.timeOut( delay * 2, () => { con2.take( delay * 2 );return null; });
    con3.take( testMsg + testMsg );

    return mainCon;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'each con gives several resources, order of provided consequence is important, order of firing is not';
    var delay = 100;
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con1 = new _.Consequence({ tag : 'con1', capacity : 3 });
    var con2 = new _.Consequence({ tag : 'con2', capacity : 3 });
    var con3 = new _.Consequence({ tag : 'con3', capacity : 3 });
    var srcs = [ con3, con1, con2  ];

    mainCon.take( testMsg );

    mainCon.andKeep( srcs );

    mainCon.finally( function( err, got )
    {
      test.identical( got, [ 'con3', 'con1', 'con2', testMsg ] );
      test.identical( mainCon.resourcesGet().length, 0 );

      test.identical( con1.resourcesGet().length, 3 );
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesGet().length, 3 );
      test.identical( con2.competitorsEarlyGet().length, 0 );

      test.identical( con3.resourcesGet().length, 3 );
      test.identical( con3.competitorsEarlyGet().length, 0 );

      return null;
    });

    _.timeOut( delay / 2, () =>
    {
      con1.take( 'con1' );
      con1.take( 'con1' );
      con1.take( 'con1' );
      return null;
    });

    _.timeOut( delay * 2, () =>
    {
      con2.take( 'con2' );
      con2.take( 'con2' );
      con2.take( 'con2' );
      return null;
    });

    _.timeOut( delay, () =>
    {
      con3.take( 'con3' );
      con3.take( 'con3' );
      con3.take( 'con3' );
      return null;
    });

    return mainCon;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'each con gives several resources, order of provided consequence is important, order of firing is not';
    var delay = 100;
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con1 = new _.Consequence({ tag : 'con1', capacity : 3 });
    var con2 = new _.Consequence({ tag : 'con2', capacity : 3 });
    var con3 = new _.Consequence({ tag : 'con3', capacity : 3 });

    var srcs = [ con3, con1, con2  ];

    mainCon.take( testMsg );

    mainCon.andKeep( srcs );

    mainCon.finally( function( err, got )
    {
      test.identical( got, [ 'con3', 'con1', 'con2', testMsg ] );
      test.identical( mainCon.resourcesGet().length, 0 );

      test.identical( con1.resourcesGet().length, 3 );
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesGet().length, 3 );
      test.identical( con2.competitorsEarlyGet().length, 0 );

      test.identical( con3.resourcesGet().length, 3 );
      test.identical( con3.competitorsEarlyGet().length, 0 );

      return null;
    });

    _.timeOut( delay, () =>
    {
      con1.take( 'con1' );
      con1.take( 'con1' );
      con1.take( 'con1' );
      return null;
    });

    _.timeOut( delay * 2, () =>
    {
      con2.take( 'con2' );
      con2.take( 'con2' );
      con2.take( 'con2' );
      return null;
    });

    _.timeOut( delay / 2, () =>
    {
      con3.take( 'con3' );
      con3.take( 'con3' );
      con3.take( 'con3' );
      return null;
    });

    return mainCon;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'one of provided cons waits for another one to resolve';
    var delay = 100;
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    var srcs = [ con1, con2  ];

    con1.take( null );
    con1.finally( () => con2 );
    con1.finally( () => 'con1' );

    mainCon.take( testMsg );

    mainCon.andTake( srcs );

    mainCon.finally( function( err, got )
    {
      test.identical( got, [ 'con1', 'con2', testMsg ] );

      test.identical( mainCon.resourcesGet().length, 0 );

      test.identical( con1.resourcesGet().length, 0 );
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesGet().length, 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

    _.timeOut( delay * 2, () => { con2.take( 'con2' ); return null;  } )

    return mainCon;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case =
    `consequence gives an error, only first error is taken into account
     other consequences are receiving their resources back`;

    var delay = 100;
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    var srcs = [ con1, con2  ];

    mainCon.take( testMsg );

    mainCon.andKeep( srcs );

    mainCon.finally( function( err, got )
    {
      test.is( _.strHas( String( err ), 'con1' ) );
      test.identical( got, undefined );

      test.identical( mainCon.resourcesGet().length, 0 );

      test.identical( con1.resourcesGet().length, 1 );
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesGet().length, 1 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

    _.timeOut( delay, () => { con1.error( 'con1' );return null;  } )
    var t = _.timeOut( delay * 2, () => { con2.take( 'con2' );return null;  } )

    t.finally( () =>
    {
      test.identical( con2.resourcesGet().length, 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return mainCon;
    })

    return t;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'passed consequence dont give any resource';
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con = new _.Consequence({ tag : 'con' });
    mainCon.take( null );
    mainCon.andKeep( con );
    mainCon.finally( () => { test.identical( 0, 1); return null; });
    test.identical( mainCon.resourcesGet().length, 0 );
    test.identical( mainCon.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 );

    return _.timeOut( 10, function()
    {
      test.identical( mainCon.resourcesGet().length, 0 );
      test.identical( mainCon.competitorsEarlyGet().length, 1 );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 1 );
      con.competitorsCancel();
      mainCon.competitorsCancel();
      test.identical( mainCon.resourcesGet().length, 0 );
      test.identical( mainCon.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
    });

  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'returned consequence dont give any resource';
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con = new _.Consequence({ tag : 'con' });
    mainCon.take( null );
    mainCon.andKeep( () => con );
    mainCon.finally( () => { test.identical( 0, 1); return null; });
    test.identical( mainCon.resourcesGet().length, 0 );
    test.identical( mainCon.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 );

    return _.timeOut( 10, function()
    {
      test.identical( mainCon.resourcesGet().length, 0 );
      test.identical( mainCon.competitorsEarlyGet().length, 1 );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 1 );
      con.competitorsCancel();
      mainCon.competitorsCancel();
      test.identical( mainCon.resourcesGet().length, 0 );
      test.identical( mainCon.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
    });

  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'one of srcs dont give any resource';
    var delay = 100;
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });
    var con3 = new _.Consequence({ tag : 'con3' });

    var srcs = [ con1, con2, con3 ];

    mainCon.take( testMsg );

    mainCon.andKeep( srcs );

    mainCon.finally( () => { test.identical( 0, 1); return null; });

    _.timeOut( delay, () => { con1.take( delay );return null; });
    _.timeOut( delay * 2, () => { con2.take( delay * 2 );return null; });

    return _.timeOut( delay * 3, function()
    {

      test.identical( mainCon.resourcesGet().length, 0 );
      test.identical( mainCon.competitorsEarlyGet().length, 1 );
      test.identical( con1.resourcesGet().length, 0 );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet().length, 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      test.identical( con3.resourcesGet().length, 0 );
      test.identical( con3.competitorsEarlyGet().length, 1 );

      con3.competitorsCancel();
      mainCon.competitorsCancel();

      test.identical( mainCon.resourcesGet().length, 0 );
      test.identical( mainCon.competitorsEarlyGet().length, 0 );
      test.identical( con1.resourcesGet().length, 0 );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet().length, 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      test.identical( con3.resourcesGet().length, 0 );
      test.identical( con3.competitorsEarlyGet().length, 0 );

    });

  })

  /* */

  return que;
}

//

function andTake( test )
{
  var testMsg = 'msg';
  var que = new _.Consequence().take( null )

   /* */

  .thenKeep( function( arg )
  {
    test.case = 'andTake waits only for first resource, dont return the resource';
    var delay = 100;
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con = new _.Consequence({ tag : 'con' });

    mainCon.take( testMsg );

    mainCon.andTake( con );

    mainCon.finally( function( err, got )
    {
      test.identical( got, [ delay, testMsg ] )
      test.identical( mainCon.resourcesGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return null;
    });

    _.timeOut( delay, () => { con.take( delay ) });
    _.timeOut( delay * 2, () => { con.take( delay * 2 ) });

    return _.timeOut( delay * 2, function()
    {
      test.identical( con.resourcesGet().length, 1 );
      test.identical( con.resourcesGet()[ 0 ].argument, delay * 2 );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'dont give resource back to single consequence returned from passed routine';
    var delay = 100;
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con = new _.Consequence({ tag : 'con' });

    mainCon.take( testMsg );

    mainCon.andTake( () => con );

    mainCon.finally( function( err, got )
    {
      test.identical( got, [ delay, testMsg ] );
      test.identical( mainCon.resourcesGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return null;
    });

    _.timeOut( delay, () => { con.take( delay ); return null; });

    return mainCon;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'dont give resources back to several consequences with different delays';
    var delay = 100;
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });
    var con3 = new _.Consequence({ tag : 'con3' });

    var srcs = [ con1, con2, con3 ];

    mainCon.take( testMsg );

    mainCon.andTake( srcs );

    mainCon.finally( function( err, got )
    {
      test.identical( got, [ delay, delay * 2, testMsg + testMsg, testMsg ] );

      test.identical( mainCon.resourcesGet().length, 0 );

      test.identical( con1.resourcesGet(), []);
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesGet(), []);
      test.identical( con2.competitorsEarlyGet().length, 0 );

      test.identical( con3.resourcesGet(), []);
      test.identical( con3.competitorsEarlyGet().length, 0 );

      return null;
    });

    _.timeOut( delay, () => { con1.take( delay ); return null; });
    _.timeOut( delay * 2, () => { con2.take( delay * 2 ); return null; });
    con3.take( testMsg + testMsg );

    return mainCon;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'each con gives several resources, order of provided consequence is important';
    var delay = 100;
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con1 = new _.Consequence({ tag : 'con1', capacity : 3 });
    var con2 = new _.Consequence({ tag : 'con2', capacity : 3 });
    var con3 = new _.Consequence({ tag : 'con3', capacity : 3 });

    var srcs = [ con3, con1, con2  ];

    mainCon.take( testMsg );

    mainCon.andTake( srcs );

    mainCon.finally( function( err, got )
    {
      test.identical( got, [ 'con3', 'con1', 'con2', testMsg ] );

      test.identical( mainCon.resourcesGet().length, 0 );

      test.identical( con1.resourcesGet().length, 2 );
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesGet().length, 2 );
      test.identical( con2.competitorsEarlyGet().length, 0 );

      test.identical( con3.resourcesGet().length, 2 );
      test.identical( con3.competitorsEarlyGet().length, 0 );

      return null;
    });

    _.timeOut( delay, () =>
    {
      con1.take( 'con1' );
      con1.take( 'con1' );
      con1.take( 'con1' );
      return null;
    });

    _.timeOut( delay * 2, () =>
    {
      con2.take( 'con2' );
      con2.take( 'con2' );
      con2.take( 'con2' );
      return null;
    });

    _.timeOut( delay / 2, () =>
    {
      con3.take( 'con3' );
      con3.take( 'con3' );
      con3.take( 'con3' );
      return null;
    });

    return mainCon;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'one of provided cons waits for another one to resolve';
    var delay = 100;
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    var srcs = [ con1, con2  ];

    con1.take( null );
    con1.finally( () => con2 );
    con1.finally( () => 'con1' );

    mainCon.take( testMsg );

    mainCon.andTake( srcs );

    mainCon.finally( function( err, got )
    {
      test.identical( got, [ 'con1', 'con2', testMsg ] );

      test.identical( mainCon.resourcesGet().length, 0 );

      test.identical( con1.resourcesGet().length, 0 );
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesGet().length, 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );

      return null;
    });

    _.timeOut( delay * 2, () => { con2.take( 'con2' ); return null; } )

    return mainCon;
  })

  .thenKeep( function( arg )
  {
    test.case = 'consequence gives an error, only first error is taken into account';

    var delay = 100;
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    var srcs = [ con1, con2  ];

    mainCon.take( testMsg );

    mainCon.andTake( srcs );

    mainCon.finally( function( err, got )
    {
      test.is( _.strHas( String( err ), 'con1' ) );
      test.identical( got, undefined );

      test.identical( mainCon.resourcesGet().length, 0 );

      test.identical( con1.resourcesGet().length, 0 );
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesGet().length, 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );

      return null;
    });

    _.timeOut( delay, () => { con1.error( 'con1' );return null;  } )
    var t = _.timeOut( delay * 2, () => { con2.take( 'con2' );return null;  } )

    t.finally( () =>
    {
      test.identical( con2.resourcesGet().length, 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return mainCon;
    })

    return t;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'passed consequence dont give any resource';
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con = new _.Consequence({ tag : 'con' });
    mainCon.take( null );
    mainCon.andTake( con );
    mainCon.finally( () => test.identical( 0, 1 ) );
    test.identical( mainCon.resourcesGet().length, 0 );
    test.identical( mainCon.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 10, function()
    {
      test.identical( mainCon.resourcesGet().length, 0 );
      test.identical( mainCon.competitorsEarlyGet().length, 1 );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 1 );
      con.competitorsCancel();
      mainCon.competitorsCancel();
      test.identical( mainCon.resourcesGet().length, 0 );
      test.identical( mainCon.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
    });
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'returned consequence dont give any resource';
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con = new _.Consequence({ tag : 'con' });
    mainCon.take( null );
    mainCon.andTake( () => con );
    mainCon.finally( () => test.identical( 0, 1 ) );
    test.identical( mainCon.resourcesGet().length, 0 );
    test.identical( mainCon.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 );
    test.identical( con.competitorsEarlyGet().length, 1 );

    return _.timeOut( 10, function()
    {
      test.identical( mainCon.resourcesGet().length, 0 );
      test.identical( mainCon.competitorsEarlyGet().length, 1 );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 1 );
      con.competitorsCancel();
      mainCon.competitorsCancel();
      test.identical( mainCon.resourcesGet().length, 0 );
      test.identical( mainCon.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
    });
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'one of srcs dont give any resource';
    var delay = 100;
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });
    var con3 = new _.Consequence({ tag : 'con3' });

    var srcs = [ con1, con2, con3 ];

    mainCon.take( testMsg );

    mainCon.andTake( srcs );
    mainCon.finally( () => { test.identical( 0, 1); return null; });

    _.timeOut( delay, () => { con1.take( delay ); return null; });
    _.timeOut( delay * 2, () => { con2.take( delay * 2 ); return null; });

    return _.timeOut( delay * 3, function()
    {

      test.identical( mainCon.resourcesGet().length, 0 );
      test.identical( mainCon.competitorsEarlyGet().length, 1 );
      test.identical( con1.resourcesGet().length, 0 );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet().length, 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      test.identical( con3.resourcesGet().length, 0 );
      test.identical( con3.competitorsEarlyGet().length, 1 );

      con3.competitorsCancel();
      mainCon.competitorsCancel();

      test.identical( mainCon.resourcesGet().length, 0 );
      test.identical( mainCon.competitorsEarlyGet().length, 0 );
      test.identical( con1.resourcesGet().length, 0 );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet().length, 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      test.identical( con3.resourcesGet().length, 0 );
      test.identical( con3.competitorsEarlyGet().length, 0 );
    });
  })

  return que;
}

//

function _and( test )
{
  var testMsg = 'msg';
  var delay = 500;
  var que = new _.Consequence().take( null )

  /* common wConsequence corespondent tests. */

  .thenKeep( function( arg )
  {
    test.case = 'give back resources to src consequences';

    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    mainCon.take( testMsg );

    mainCon._and({ competitors : [ con1, con2 ], taking : false, accumulative : false, stackLevel : 1 });

    con1.give( ( err, got ) => { test.identical( got, delay ); return null; });
    con2.give( ( err, got ) => { test.identical( got, delay * 2 ); return null; });

    mainCon.finally( function( err, got )
    {
      // at that moment all resources from srcs are processed
      test.identical( con1.resourcesGet().length, 0 );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet().length, 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      test.identical( got, [ delay, delay * 2, testMsg ] );
      return null;
    });

    _.timeOut( delay, () => { con1.take( delay );return null; } );
    _.timeOut( delay * 2, () => { con2.take( delay * 2 );return null; } );

    return mainCon;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'dont give back resources to src consequences';

    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    mainCon.take( testMsg );

    mainCon._and({ competitors : [ con1, con2 ], taking : true, accumulative : false, stackLevel : 1 });

    con1.give( ( err, got ) => { test.identical( 0, 1 ); return null; });
    con2.give( ( err, got ) => { test.identical( 0, 1 ); return null; });

    mainCon.finally( function( err, got )
    {
      /* no resources returned back to srcs, their competitors must not be invoked */
      test.identical( con1.resourcesGet().length, 0 );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet().length, 0 );
      test.identical( con2.competitorsEarlyGet().length, 1 );
      test.identical( got, [ delay, delay * 2, testMsg ] );
      return null;
    });

    _.timeOut( delay, () => { con1.take( delay ); return null; });
    _.timeOut( delay * 2, () => { con2.take( delay * 2 ); return null; });

    return _.timeOut( delay * 3, () =>
    {
      test.identical( mainCon.resourcesGet().length, 1 );
      test.identical( mainCon.competitorsEarlyGet().length, 0 );
      test.identical( con1.resourcesGet().length, 0 );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet().length, 0 );
      test.identical( con2.competitorsEarlyGet().length, 1 );
      con1.competitorsCancel();
      con2.competitorsCancel();
      test.identical( mainCon.resourcesGet().length, 1 );
      test.identical( mainCon.competitorsEarlyGet().length, 0 );
      test.identical( con1.resourcesGet().length, 0 );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet().length, 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });
  })

  return que;
}

//

function AndKeep( test )
{
  var que = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    test.case = 'andKeep';
    var delay = 100;
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    let con = _.Consequence.AndKeep([ con1, con2 ]);

    con.finally( function( err, got )
    {
      test.identical( got, [ 1, 2, null ] );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

    _.timeOut( delay, () => { con1.take( 1 ) });
    _.timeOut( delay * 2, () => { con2.take( 2 ) });

    return _.timeOut( delay * 4, function()
    {
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : null } ] );
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  });

  return que;
}

//

function AndTake( test )
{
  var que = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    test.case = 'andKeep';
    var delay = 100;
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    let con = _.Consequence.AndTake([ con1, con2 ]);

    con.finally( function( err, got )
    {
      test.identical( got, [ 1, 2 ] );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

    _.timeOut( delay, () => { con1.take( 1 ) });
    _.timeOut( delay * 2, () => { con2.take( 2 ) });

    return _.timeOut( delay * 4, function()
    {
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : null } ] );
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });
  });

  return que;
}

//

function AndKeep( test )
{
  var que = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    test.case = 'andKeep';
    var delay = 100;
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    let con = _.Consequence.AndKeep([ con1, con2 ]);

    con.finally( function( err, got )
    {
      test.identical( got, [ 1, 2 ] );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

    _.timeOut( delay, () => { con1.take( 1 ) });
    _.timeOut( delay * 2, () => { con2.take( 2 ) });

    return _.timeOut( delay * 4, function()
    {
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : null } ] );
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });
  });

  return que;
}

//--
// orKeeping
//--

function orKeepingWithSimple( test )
{
  var que = new _.Consequence().take( null )

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'take0, orKeeping, take1, take2';

    var got = null;
    var con = new _.Consequence({ tag : 'con' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    con.take( 0 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    let rcon = con.orKeeping([ con1, con2 ]);
    test.is( rcon === con );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con1.take( 1 );
    con2.take( 2 );

    con.finallyGive( ( err, arg ) =>
    {

      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 0 );
      got = arg;

    });

    con.finally( ( err, arg ) =>
    {
      test.is( false );
      return null;
    });

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con1.resourcesGet( 0 ), { argument : 1, error : undefined } );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      test.identical( con2.resourcesGet( 0 ), { argument : 2, error : undefined } );
      con.competitorsCancel();
    });
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'take1, take2, orKeeping, take0';

    var got = null;
    var con = new _.Consequence({ tag : 'con', capacity : 2 });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    con1.take( 1 );
    con2.take( 2 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 1 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 1 );
    test.identical( con2.competitorsCount(), 0 );

    let rcon = con.orKeeping([ con1, con2 ]);
    test.is( rcon === con );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 1 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 1 );
    test.identical( con2.competitorsCount(), 0 );

    con.take( 0 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 2 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 1 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 1 );
    test.identical( con2.competitorsCount(), 0 );

    con.finallyGive( ( err, arg ) =>
    {

      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 1 );
      got = arg;

    });

    con.finally( ( err, arg ) =>
    {

      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 0 );
      got += 100;

      return arg;
    });

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 101 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesGet( 0 ), { argument : 0, error : undefined } );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con1.resourcesGet( 0 ), { argument : 1, error : undefined } );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      test.identical( con2.resourcesGet( 0 ), { argument : 2, error : undefined } );

      // con.competitorsCancel();
    });
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'take1, take2, orKeeping';

    var got = null;
    var con = new _.Consequence({ tag : 'con' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    con1.take( 1 );
    con2.take( 2 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 1 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 1 );
    test.identical( con2.competitorsCount(), 0 );

    let rcon = con.orKeeping([ con1, con2 ]);
    test.is( rcon === con );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 1 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 1 );
    test.identical( con2.competitorsCount(), 0 );

    con.finallyKeep( ( err, arg ) =>
    {

      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 1 );
      got = arg;

      return arg;
    });

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesGet( 0 ), { argument : 1, error : undefined } );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con1.resourcesGet( 0 ), { argument : 1, error : undefined } );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      test.identical( con2.resourcesGet( 0 ), { argument : 2, error : undefined } );
    });
  })

  return que;
}

//

function orKeepingWithLater( test )
{
  var que = new _.Consequence().take( null )

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'take0, or, later take2, later take1';

    var got = null;
    var con = new _.Consequence({ tag : 'or' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    con.take( 0 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con.orKeeping([ con1, con2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con1.takeLater( 100, 1 );
    con2.takeLater( 50, 2 );

    con.finallyGive( ( err, arg ) =>
    {

      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 0 );
      got = arg;
    });

    con.finally( ( err, arg ) =>
    {
      test.is( false );
      return null;
    });

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con1.resourcesGet( 0 ), { argument : 1, error : undefined } );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      test.identical( con2.resourcesGet( 0 ), { argument : 2, error : undefined } );

      con.competitorsCancel();
    });
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'or, later take1, later take2, take0';

    var got = null;
    var con = new _.Consequence({ tag : 'or' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con.orKeeping([ con1, con2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 1 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 1 );

    con1.takeLater( 100, 1 );
    con2.takeLater( 50, 2 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 0 );
      got = arg;
    });

    con.finally( ( err, arg ) =>
    {
      test.is( false );
      return null;
    });

    con.take( 0 );

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      con.competitorsCancel();
    });
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'orKeeping, later take1, later take2, later take0';

    var got = null;
    var con = new _.Consequence({ tag : 'or' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con.orKeeping([ con1, con2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 1 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 1 );

    con1.takeLater( 100, 1 );
    con2.takeLater( 50, 2 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 2 );
      got = arg;
    });

    con.finally( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      test.identical( err, undefined );
      test.identical( arg, 0 );
      got += 100;
      return got;
    });

    con.takeLater( 150, 0 );

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 102 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      con.competitorsCancel();
    });
  })

  return que;
}

function orKeepingWithNow( test )
{
  var que = new _.Consequence().take( null )

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'now, take0, take0, orKeeping, take1';

    var got = null;
    var con = new _.Consequence({ tag : 'con', capacity : 2 });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    con.take( 0 );
    con.take( 10 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 2 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con.orKeeping([ con1, con2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 2 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con1.take( 1 );
    con2.take( 2 );

    con.finallyGive( ( err, arg ) =>
    {

      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 10 );
    });

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 0 );
      got = arg;
    });

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
    });
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'now, take0, take0, orKeeping with nulls, take1';

    var got = null;
    var con = new _.Consequence({ tag : 'con', capacity : 2 });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    con.take( 0 );
    con.take( 10 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 2 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con.orKeeping([ null, con1, null, con2, null ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 2 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con1.take( 1 );
    con2.take( 2 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 10 );
    });

    con.finallyGive( ( err, arg ) =>
    {

      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 0 );
      got = arg;
    });

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
    });
  })

  /* - */

  return que;
}

//

function orTakingWithSimple( test )
{
  var que = new _.Consequence().take( null )

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'take0, orTaking, take1, take2';

    var got = null;
    var con = new _.Consequence({ tag : 'con' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    con.take( 0 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    let rcon = con.orTaking([ con1, con2 ]);
    test.is( rcon === con );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con1.take( 1 );
    con2.take( 2 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 0 );
      got = arg;
    });

    con.finally( ( err, arg ) =>
    {
      test.is( false );
      return null;
    });

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con1.resourcesGet( 0 ), { argument : 1, error : undefined } );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      test.identical( con2.resourcesGet( 0 ), { argument : 2, error : undefined } );
      con.competitorsCancel();
    });
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'take1, take2, orTaking, take0';

    var got = null;
    var con = new _.Consequence({ tag : 'con', capacity : 2 });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    con1.take( 1 );
    con2.take( 2 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 1 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 1 );
    test.identical( con2.competitorsCount(), 0 );

    let rcon = con.orTaking([ con1, con2 ]);
    test.is( rcon === con );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 1 );
    test.identical( con2.competitorsCount(), 0 );

    con.take( 0 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 2 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 1 );
    test.identical( con2.competitorsCount(), 0 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 1 );
      got = arg;
    });

    con.finally( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 0 );
      got += 100;

      return arg;
    });

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 101 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesGet( 0 ), { argument : 0, error : undefined } );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      test.identical( con2.resourcesGet( 0 ), { argument : 2, error : undefined } );

      // con.competitorsCancel();
    });
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'take1, take2, orTaking';

    var got = null;
    var con = new _.Consequence({ tag : 'con' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    con1.take( 1 );
    con2.take( 2 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 1 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 1 );
    test.identical( con2.competitorsCount(), 0 );

    let rcon = con.orTaking([ con1, con2 ]);
    test.is( rcon === con );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 1 );
    test.identical( con2.competitorsCount(), 0 );

    con.finallyKeep( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      test.identical( err, undefined );
      test.identical( arg, 1 );
      got = arg;

      return arg;
    });

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesGet( 0 ), { argument : 1, error : undefined } );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      test.identical( con2.resourcesGet( 0 ), { argument : 2, error : undefined } );
    });
  })

  /* */

  return que;
}

//

function orTakingWithLater( test )
{
  var que = new _.Consequence().take( null )

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'take0, or, later take2, later take1';

    var got = null;
    var con = new _.Consequence({ tag : 'or' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    con.take( 0 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con.orTaking([ con1, con2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con1.takeLater( 100, 1 );
    con2.takeLater( 50, 2 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 0 );
      got = arg;
    });

    con.finally( ( err, arg ) =>
    {
      test.is( false );
      return null;
    });

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con1.resourcesGet( 0 ), { argument : 1, error : undefined } );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      test.identical( con2.resourcesGet( 0 ), { argument : 2, error : undefined } );

      con.competitorsCancel();
    });
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'or, later take1, later take2, take0';

    var got = null;
    var con = new _.Consequence({ tag : 'or' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con.orTaking([ con1, con2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 1 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 1 );

    con1.takeLater( 100, 1 );
    con2.takeLater( 50, 2 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 0 );
      got = arg;
    });

    con.finally( ( err, arg ) =>
    {
      test.is( false );
      return null;
    });

    con.take( 0 );

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      con.competitorsCancel();
    });
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'orTaking, later take1, later take2, later take0';

    var got = null;
    var con = new _.Consequence({ tag : 'or' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con.orTaking([ con1, con2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 1 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 1 );

    con1.takeLater( 100, 1 );
    con2.takeLater( 50, 2 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 2 );
      got = arg;
    });

    con.finally( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 0 );
      test.identical( err, undefined );
      test.identical( arg, 0 );
      got += 100;
      return got;
    });

    con.takeLater( 150, 0 );

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 102 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 0 );
      con.competitorsCancel();
    });
  })

  /* */

  return que;
}

//

function orTakingWithNow( test )
{
  var que = new _.Consequence().take( null )

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'now, take0, take0, orTaking, take1';

    var got = null;
    var con = new _.Consequence({ tag : 'con', capacity : 2 });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    con.take( 0 );
    con.take( 10 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 2 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con.orTaking([ con1, con2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 2 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con1.take( 1 );
    con2.take( 2 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 10 );
    });

    con.finallyGive( ( err, arg ) =>
    {

      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 0 );
      got = arg;
    });

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
    });
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'now, take0, take0, orTaking with nulls, take1';

    var got = null;
    var con = new _.Consequence({ tag : 'con', capacity : 2 });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    con.take( 0 );
    con.take( 10 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 2 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con.orTaking([ null, con1, null, con2, null ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 2 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con1.take( 1 );
    con2.take( 2 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 10 );
    });

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 0 );
      got = arg;
    });

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
    });
  })

  /* */

  return que;
}

//

function thenOrKeepingNotFiring( test )
{
  var que = new _.Consequence().take( null )

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'now, take0 take0 or';

    var got = null;
    var con = new _.Consequence({ tag : 'con', capacity : 2 });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    con.take( 0 ).take( 10 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 2 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con.thenOrKeeping([ con1, con2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 1 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 1 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 1 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 1 );

      test.identical( err, undefined );
      test.identical( arg, 10 );
      got = arg;
    });

    con.finally( ( err, arg ) =>
    {
      test.is( false );
      return null;
    });

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 10 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 1 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 1 );
      con.competitorsCancel();
      con1.competitorsCancel();
      con2.competitorsCancel();
    });
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'take0 or later take0';

    var got = null;
    var con = new _.Consequence({ tag : 'con' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    con.take( 0 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con.thenOrKeeping([ con1, con2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 1 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 1 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 1 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 1 );

      test.identical( err, undefined );
      test.identical( arg, 10 );
      got = arg;
    });

    con.finally( ( err, arg ) =>
    {
      test.is( false );
      return null;
    });

    _.timeBegin( 1, () => con.take( 10 ) );

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 10 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 1 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 1 );
      con.competitorsCancel();
      con1.competitorsCancel();
      con2.competitorsCancel();
    });
  })

  /* */

  return que;
}

//

function thenOrKeepingWithSimple( test )
{
  var que = new _.Consequence().take( null )

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'take0, thenOrKeeping, take1, take2';

    var got = null;
    var con = new _.Consequence({ tag : 'con' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    con.take( 0 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con.thenOrKeeping([ con1, con2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 1 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 1 );

    con1.take( 1 );
    con2.take( 2 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 1 );
      got = arg;
    });

    con.finally( ( err, arg ) =>
    {
      test.is( false );
      return null;
    });

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      con.competitorsCancel();
    });
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'error0, thenOrKeeping, take1, take2';

    var got = null;
    var con = new _.Consequence({ tag : 'con' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    con.error( 'error1' );

    test.identical( con.errorsCount(), 1 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con.thenOrKeeping([ con1, con2 ]);

    test.identical( con.errorsCount(), 1 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con1.take( 1 );
    con2.take( 2 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.is( _.strHas( String( err ), 'error1' ) );
      test.identical( arg, undefined );
      got = err;
    });

    con.finally( ( err, arg ) =>
    {
      test.is( false );
      return null;
    });

    return _.timeOut( 200, function( err, arg )
    {
      test.is( _.strHas( String( got ), 'error1' ) );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      con.competitorsCancel();
    });
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'take1, take2, or, take0';

    var got = null;
    var con = new _.Consequence({ tag : 'con' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    con1.take( 1 );
    con2.take( 2 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 1 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 1 );
    test.identical( con2.competitorsCount(), 0 );

    con.thenOrKeeping([ con1, con2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 1 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 1 );
    test.identical( con2.competitorsCount(), 0 );

    con.take( 0 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 1 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 1 );
    test.identical( con2.competitorsCount(), 0 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 1 );
      got = arg;
    });

    con.finally( ( err, arg ) =>
    {
      test.is( false );
      return null;
    });

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con1.resourcesGet( 0 ), { argument : 1, error : undefined } );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      test.identical( con2.resourcesGet( 0 ), { argument : 2, error : undefined } );

      con.competitorsCancel();
    });
  })

  /* */

  return que;
}

//

function thenOrKeepingWithLater( test )
{
  var que = new _.Consequence().take( null )

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'take0, or, later take2, later take1';

    var got = null;
    var con = new _.Consequence({ tag : 'or' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    con.take( 0 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con.thenOrKeeping([ con1, con2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 1 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 1 );

    con1.takeLater( 100, 1 );
    con2.takeLater( 50, 2 );

    con.finallyGive( ( err, arg ) =>
    {

      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 2 );
      got = arg;

    });

    con.finally( ( err, arg ) =>
    {
      test.is( false );
      return null;
    });

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 2 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      con.competitorsCancel();
    });
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'or, later take1, later take2, take0';

    var got = null;
    var con = new _.Consequence({ tag : 'or' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con.thenOrKeeping([ con1, con2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con1.takeLater( 100, 1 );
    con2.takeLater( 50, 2 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 2 );
      got = arg;
    });

    con.finally( ( err, arg ) =>
    {
      test.is( false );
      return null;
    });

    con.take( 0 );

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 2 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      con.competitorsCancel();
    });
  })

  /* - */

  .thenKeep( function( arg )
  {
    test.case = 'thenOrKeeping, later take1, later take2, later take0';

    var got = null;
    var con = new _.Consequence({ tag : 'or' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con.thenOrKeeping([ con1, con2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con1.takeLater( 100, 1 );
    con2.takeLater( 50, 2 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 1 );
      got = arg;
    });

    con.finally( ( err, arg ) =>
    {
      test.is( false );
      return got;
    });

    con.takeLater( 150, 0 );

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      con.competitorsCancel();
    });
  })

  /* */

  return que;
}

//

function thenOrKeepingWithTwoTake0( test )
{
  var que = new _.Consequence().take( null )

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'take0, take0, thenOrKeeping, take1';

    var got = null;
    var con = new _.Consequence({ tag : 'con', capacity : 2 });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    con.take( 0 );
    con.take( 10 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 2 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con.thenOrKeeping([ con1, con2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 1 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 1 );

    con1.take( 1 );
    con2.take( 2 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 10 );
    });

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 1 );
      got = arg;
    });

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
    });
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'take0, take0, or with null, take1, take2';

    var got = null;
    var con = new _.Consequence({ tag : 'con', capacity : 2 });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    con.take( 0 );
    con.take( 10 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 2 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con.thenOrKeeping([ null, con1, null, con2, null ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 1 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 1 );

    con1.take( 1 );
    con2.take( 2 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 10 );
    });

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 1 );
      got = arg;
    });

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
    });
  })

  /* */

  return que;
}

//

function thenOrTakingWithSimple( test )
{
  var que = new _.Consequence().take( null )

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'take0, or, take1, take2';

    var got = null;
    var con = new _.Consequence({ tag : 'con' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    con.take( 0 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con.thenOrTaking([ con1, con2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 1 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 1 );

    con1.take( 1 );
    con2.take( 2 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 1 );
      got = arg;
    });

    con.finally( ( err, arg ) =>
    {
      test.is( false );
      return null;
    });

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      con.competitorsCancel();
    });
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'error0, thenOrTaking, take1, take2';

    var got = null;
    var con = new _.Consequence({ tag : 'con' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    con.error( 'error1' );

    test.identical( con.errorsCount(), 1 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con.thenOrTaking([ con1, con2 ]);

    test.identical( con.errorsCount(), 1 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con1.take( 1 );
    con2.take( 2 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.is( _.strHas( String( err ), 'error1' ) );
      test.identical( arg, undefined );
      got = err;
    });

    con.finally( ( err, arg ) =>
    {
      test.is( false );
      return null;
    });

    return _.timeOut( 200, function( err, arg )
    {
      test.is( _.strHas( String( got ), 'error1' ) );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      con.competitorsCancel();
    });
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'take1, take2, or, take0';

    var got = null;
    var con = new _.Consequence({ tag : 'con' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    con1.take( 1 );
    con2.take( 2 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 1 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 1 );
    test.identical( con2.competitorsCount(), 0 );

    con.thenOrTaking([ con1, con2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 1 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 1 );
    test.identical( con2.competitorsCount(), 0 );

    con.take( 0 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 1 );
    test.identical( con2.competitorsCount(), 0 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 1 );
      got = arg;
    });

    con.finally( ( err, arg ) =>
    {
      test.is( false );
      return null;
    });

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      test.identical( con2.resourcesGet( 0 ), { argument : 2, error : undefined } );

      con.competitorsCancel();
    });
  })

  /* */

  return que;
}

//

function thenOrTakingWithLater( test )
{
  var que = new _.Consequence().take( null )

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'take0, or, later take2, later take1';

    var got = null;
    var con = new _.Consequence({ tag : 'or' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    con.take( 0 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con.thenOrTaking([ con1, con2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 1 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 1 );

    con1.takeLater( 100, 1 );
    con2.takeLater( 50, 2 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 2 );
      got = arg;
    });

    con.finally( ( err, arg ) =>
    {
      test.is( false );
      return null;
    });

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 2 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 0 );
      con.competitorsCancel();
    });
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'or, later take1, later take2, take0';

    var got = null;
    var con = new _.Consequence({ tag : 'or' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con.thenOrTaking([ con1, con2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con1.takeLater( 100, 1 );
    con2.takeLater( 50, 2 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 2 );
      got = arg;
    });

    con.finally( ( err, arg ) =>
    {
      test.is( false );
      return null;
    });

    con.take( 0 );

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 2 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 0 );
      con.competitorsCancel();
    });
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'thenOrTaking, later take1, later take2, later take0';

    var got = null;
    var con = new _.Consequence({ tag : 'or' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con.thenOrTaking([ con1, con2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con1.takeLater( 100, 1 );
    con2.takeLater( 50, 2 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 1 );
      got = arg;
    });

    con.finally( ( err, arg ) =>
    {
      test.is( false );
      return got;
    });

    con.takeLater( 150, 0 );

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      con.competitorsCancel();
    });
  })

  /* */

  return que;
}

//

function thenOrTakingWithTwoTake0( test )
{
  var que = new _.Consequence().take( null )

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'take0, take0, thenOrTaking, take1';

    var got = null;
    var con = new _.Consequence({ tag : 'con', capacity : 2 });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    con.take( 0 );
    con.take( 10 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 2 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con.thenOrTaking([ con1, con2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 1 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 1 );

    con1.take( 1 );
    con2.take( 2 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 10 );
    });

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 1 );
      got = arg;
    });

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
    });
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'take0, take0, or with null, take1, take2';

    var got = null;
    var con = new _.Consequence({ tag : 'con', capacity : 2 });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    con.take( 0 );
    con.take( 10 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 2 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con.thenOrTaking([ null, con1, null, con2, null ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 1 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 1 );

    con1.take( 1 );
    con2.take( 2 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 10 );
    });

    con.finallyGive( ( err, arg ) =>
    {

      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 1 );
      got = arg;
    });

    return _.timeOut( 200, function( err, arg )
    {
      test.identical( got, 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
    });
  })

  /* */

  return que;
}

//

function inter( test )
{

  test.case = 'got';
  var con1 = new _.Consequence({ tag : 'con1' }).take( 1 );
  var con2 = new _.Consequence({ tag : 'con2' });

  con1.give( con2 );

  test.identical( con1._resources.length, 0 );
  test.identical( con1._competitorsEarly.length, 0 );
  // test.identical( con1._competitorsLate.length, 0 );
  test.identical( con2._resources.length, 1 );
  test.identical( con2._competitorsEarly.length, 0 );
  // test.identical( con2._competitorsLate.length, 0 );

  /* */

  test.case = 'done';
  var con1 = new _.Consequence({ tag : 'con1' }).take( 1 );
  var con2 = new _.Consequence({ tag : 'con2' });

  con1.give( con2 );

  test.identical( con1._resources.length, 0 );
  test.identical( con1._competitorsEarly.length, 0 );
  // test.identical( con1._competitorsLate.length, 0 );
  test.identical( con2._resources.length, 1 );
  test.identical( con2._competitorsEarly.length, 0 );
  // test.identical( con2._competitorsLate.length, 0 );

  /* */

  test.case = 'finally';
  var con1 = new _.Consequence({ tag : 'con1' }).take( 1 );
  var con2 = new _.Consequence({ tag : 'con2' });

  con1.finally( con2 );

  test.identical( con1._resources.length, 1 );
  test.identical( con1._competitorsEarly.length, 0 );
  // test.identical( con1._competitorsLate.length, 0 );
  test.identical( con2._resources.length, 1 );
  test.identical( con2._competitorsEarly.length, 0 );
  // test.identical( con2._competitorsLate.length, 0 );

  /* */

  test.case = 'finally';
  var con1 = new _.Consequence({ tag : 'con1' }).take( 1 );
  var con2 = new _.Consequence({ tag : 'con2' });

  con1.finally( con2 );

  test.identical( con1._resources.length, 1 );
  test.identical( con1._competitorsEarly.length, 0 );
  // test.identical( con1._competitorsLate.length, 0 );
  test.identical( con2._resources.length, 1 );
  test.identical( con2._competitorsEarly.length, 0 );
  // test.identical( con2._competitorsLate.length, 0 );

  /* */

  test.case = 'take';
  var con1 = new _.Consequence({ tag : 'con1' }).take( 1 );
  var con2 = new _.Consequence({ tag : 'con2' });

  con2.take( con1 );

  test.identical( con1._resources.length, 0 );
  test.identical( con1._competitorsEarly.length, 0 );
  // test.identical( con1._competitorsLate.length, 0 );
  test.identical( con2._resources.length, 1 );
  test.identical( con2._competitorsEarly.length, 0 );
  // test.identical( con2._competitorsLate.length, 0 );
}

//

function put( test )
{
  var que = new _.Consequence().take( null )

  /* */

  .then( () =>
  {
    debugger;
    var r = trivialSample();
    test.identical( r, 0 );
    return r;
  })
  .then( () =>
  {
    debugger;
    var r = putSample();
    test.identical( r, [ 0, 1 ] );
    return r;
  })
  .then( () =>
  {
    var c = asyncSample();
    test.is( _.consequenceIs( c ) );
    c.finally( ( err, arg ) =>
    {
      test.is( err === undefined );
      test.identical( arg, [ 0, 1, 2 ] );
      if( err )
      throw err;
      return arg;
    });
    return c;
  })

  return que;

  /* */

  function trivialSample()
  {
    var con = new _.Consequence({ tag : 'con' });
    var result = [];
    var array =
    [
      () => { console.log( 'sync0' ); return 0; },
      () => { console.log( 'sync1' ); return 1; },
    ]

    for( var a = 0 ; a < array.length ; a++ )
    con.give( 1 ).take( array[ a ]() );
    con.take( 0 );

    return con.syncMaybe();
  }

  /* */

  function putSample()
  {
    var result = [];
    var con = new _.Consequence({ tag : 'con' });
    var array =
    [
      () => { return 0; },
      () => { return 1; },
    ]

    for( var a = 0 ; a < array.length ; a++ )
    _.after( array[ a ]() ).putKeep( result, a ).participateGive( con );
    con.wait().take( result );

    return con.syncMaybe();
  }

  /* */

  function asyncSample()
  {
    var result = [];
    var con = new _.Consequence({ tag : 'con' });
    var array =
    [
      () => { return 0; },
      () => { return timeOut( 100, 1 ); },
      () => { return 2; },
    ]

    for( var a = 0 ; a < array.length ; a++ )
    _.after( array[ a ]() ).putKeep( result, a ).participateGive( con );
    con.wait().take( result );

    return con.syncMaybe();
  }

  /* */

  function timeOut( time, arg )
  {
    return _.timeOut( time, arg ).finally( function( err, arg )
    {
      debugger;
      if( err )
      throw err;
      return arg;
    });
  }

}

put.experimental = 0;

//--
// first
//--

function firstAsyncMode00( test )
{
  var c = this;
  var amode = _.Consequence.AsyncModeGet();
  var testMsg = 'msg';
  var que = new _.Consequence().take( null )

  .finally( () =>
  {
    _.Consequence.AsyncModeSet([ 0, 0 ]);
    test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );
    return null;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'simplest, empty routine';
    var con = new _.Consequence({ tag : 'con', capacity : 2 });
    con.first( () => null );
    con.take( testMsg );
    con.finally( function( err, got )
    {
      test.identical( got, null );
      test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg }] );
      return null;
    })
    return con;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'routine returns something';
    var con = new _.Consequence({ tag : 'con', capacity : 2 });
    con.first( () => testMsg );
    con.take( testMsg + 2 );
    con.finally( function( err, got )
    {
      test.identical( got, testMsg );
      test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg + 2 }] );
      return null;
    })
    return con;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'routine throws error';
    var con = new _.Consequence({ tag : 'con' });
    con.first( () => { throw testMsg });
    con.finally( function( err, got )
    {
      test.is( _.errIs( err ) );
      test.identical( got, undefined );
      test.identical( con.resourcesGet(), [] );
      return null;
    })
    return con;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'routine returns consequence with resource';
    var con = new _.Consequence({ tag : 'con' });
    con.first( () => new _.Consequence().take( testMsg ));
    con.finally( function( err, got )
    {
      test.identical( err, undefined );
      test.identical( got, testMsg );
      test.identical( con.resourcesGet(), [] );
      return null;
    })
    return con;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'routine returns consequence with err resource';
    var con = new _.Consequence({ tag : 'con' });
    con.first( () => new _.Consequence().error( testMsg ));
    con.finally( function( err, got )
    {
      test.is( _.strHas( String( err ), testMsg ) );
      test.identical( got, undefined );
      test.identical( con.resourcesGet(), [] );
      return null;
    })
    return con;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'routine returns consequence that gives resource with timeout';
    var con = new _.Consequence({ tag : 'con' });
    var timeBefore = _.timeNow();
    con.first( () => _.timeOut( 250, () => null ));
    con.finally( function( err, got )
    {
      var delay = _.timeNow() - timeBefore;
      var description = test.case = 'delay ' + delay;
      test.ge( delay, 250 - c.timeAccuracy );
      test.case = description;
      test.identical( err, undefined );
      test.identical( got, null );
      test.identical( con.resourcesGet(), [] );
      return null;
    })
    return con;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'passed consequence shares own resource';
    var con = new _.Consequence({ tag : 'con' });
    var con2 = new _.Consequence({ tag : 'con2' }).take( testMsg );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 1 );

    con.first( con2 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 1 );

    con.finally( function( err, got )
    {

      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );

      test.identical( err, undefined );
      test.identical( got, testMsg );
      test.identical( con.resourcesGet(), [] );
      test.identical( con2.resourcesGet(), [{ error : undefined, argument : testMsg }] );
      return null;
    })

    return con;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'passed consequence shares own resource with timeout';
    var con = new _.Consequence({ tag : 'con' });
    var con2 = _.timeOut( 250, () => testMsg );
    var timeBefore = _.timeNow();
    con.first( con2 );
    con.finally( function( err, got )
    {
      var delay = _.timeNow() - timeBefore;
      var description = test.case = 'delay ' + delay;
      test.ge( delay, 250 - c.timeAccuracy );
      test.case = description;
      test.identical( err, undefined );
      test.identical( got, testMsg );
      test.identical( con.resourcesGet(), [] );
      test.identical( con2.resourcesGet(), [{ error : undefined, argument : testMsg }] );
      return null;
    })
    return con;
  })

  .finally( ( err, arg ) =>
  {
    test.close( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );

    _.Consequence.AsyncModeSet( amode );


    if( err )
    throw err;
    return arg;

  })
  return que;
}

//

function firstAsyncMode10( test )
{
  var c = this;
  var amode = _.Consequence.AsyncModeGet();
  var testMsg = 'msg';
  var que = new _.Consequence().take( null )

  .finally( () =>
  {
    _.Consequence.AsyncModeSet([ 1, 0 ]);
    test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );
    return null;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'simplest, empty routine';
    var con = new _.Consequence({ tag : 'con', capacity : 2 });
    con.first( () => null );
    con.take( testMsg );
    con.give( function( err, got )
    {
      test.identical( got, null );
      test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg }] );
      return null;
    })

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 1 );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'routine returns something';
    var con = new _.Consequence({ tag : 'con', capacity : 2 });
    con.first( () => testMsg );
    con.take( testMsg + 2 );
    con.give( function( err, got )
    {
      test.identical( got, testMsg );
    })

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg + 2 }] );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'routine throws error';
    var con = new _.Consequence({ tag : 'con' });
    con.first( () => { throw testMsg });
    con.give( function( err, got )
    {
      test.is( _.errIs( err ) );
      test.identical( got, undefined );
      test.identical( con.resourcesGet(), [] );
    })

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'routine returns consequence with resource';
    var con = new _.Consequence({ tag : 'con' });
    con.first( () => new _.Consequence().take( testMsg ));
    con.give( function( err, got )
    {
      test.identical( err, undefined );
      test.identical( got, testMsg );
    })

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'routine returns consequence with err resource';
    var con = new _.Consequence({ tag : 'con' });
    con.first( () => new _.Consequence().error( testMsg ));
    con.give( function( err, got )
    {
      test.is( _.strHas( String( err ), testMsg ) );
      test.identical( got, undefined );
      test.identical( con.resourcesGet(), [] );
    })
    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'routine returns consequence that gives resource with timeout';
    var con = new _.Consequence({ tag : 'con' });
    var timeBefore = _.timeNow();
    con.first( () => _.timeOut( 250, () => null ));
    con.give( function( err, got )
    {
      var delay = _.timeNow() - timeBefore;
      var description = test.case = 'delay ' + delay;
      test.ge( delay, 250 - c.timeAccuracy );
      test.case = description;
      test.identical( err, undefined );
      test.identical( got, null );
      test.identical( con.resourcesGet(), [] );
    })
    return _.timeOut( 251, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'passed consequence shares own resource';
    var con = new _.Consequence({ tag : 'con' });
    var con2 = new _.Consequence({ tag : 'con2' }).take( testMsg );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 1 );

    con.first( con2 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 1 );

    con.give( function( err, got )
    {

      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );

      test.identical( err, undefined );
      test.identical( got, testMsg );
      test.identical( con.resourcesGet(), [] );
      test.identical( con2.resourcesGet(), [{ error : undefined, argument : testMsg }] );

    })
    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'passed consequence shares own resource with timeout';
    var con = new _.Consequence({ tag : 'con' });
    var con2 = _.timeOut( 250, () => testMsg );
    var timeBefore = _.timeNow();
    con.first( con2 );
    con.give( function( err, got )
    {
      var delay = _.timeNow() - timeBefore;
      var description = test.case = 'delay ' + delay;
      test.ge( delay, 250 - c.timeAccuracy );
      test.case = description;
      test.identical( err, undefined );
      test.identical( got, testMsg );
      test.identical( con.resourcesGet(), [] );
      test.identical( con2.resourcesGet(), [{ error : undefined, argument : testMsg }] );
    })
    return _.timeOut( 251, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /* */

  .finally( ( err, arg ) =>
  {
    test.close( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );

    _.Consequence.AsyncModeSet( amode );


    if( err )
    throw err;
    return arg;

  })
  return que;
}

//

function firstAsyncMode01( test )
{
  var c = this;
  var amode = _.Consequence.AsyncModeGet();
  var testMsg = 'msg';
  var que = new _.Consequence().take( null )

  .finally( () =>
  {
    _.Consequence.AsyncModeSet([ 0, 1 ]);
    test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );
    return null;
  })

  .thenKeep( function( arg )
  {
    test.case = 'simplest, empty routine';
    var con = new _.Consequence({ tag : 'con', capacity : 2 });
    con.give( function( err, got )
    {
      test.identical( err, undefined );
      test.identical( got, null );
    });

    test.identical( con.resourcesGet().length, 0 );
    test.identical( con.competitorsEarlyGet().length, 1 );

    con.first( () => null );

    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.competitorsEarlyGet().length, 1 );

    con.take( testMsg );

    test.identical( con.resourcesGet().length, 2 );
    test.identical( con.competitorsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg }] );
      return null;
    });

  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'routine returns something';
    var con = new _.Consequence({ tag : 'con', capacity : 2 });
    con.give( function( err, got )
    {
      test.identical( got, testMsg );
    })
    con.first( () => testMsg );

    con.take( testMsg + 2 );

    test.identical( con.resourcesGet().length, 2 );
    test.identical( con.competitorsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg + 2 }] );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'routine throws error';
    var con = new _.Consequence({ tag : 'con' });

    debugger;
    con.first( () => { throw testMsg } );
    debugger;
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.errorsCount(), 1 );
    test.identical( con.argumentsCount(), 0 );

    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 1 );
      con.give( function( err, got )
      {
        test.is( _.errIs( err ) );
        test.identical( got, undefined );
      });
    })
    .thenKeep( function( arg )
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'routine returns consequence with resource';
    var con = new _.Consequence({ tag : 'con' });
    con.first( () => new _.Consequence().take( testMsg ) );

    test.identical( con.resourcesGet().length, 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 1 );

      con.give( function( err, got )
      {
        test.identical( err, undefined );
        test.identical( got, testMsg );
      })
      return null;
    })
    .thenKeep( function( arg )
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'routine returns consequence with err resource';
    var con = new _.Consequence({ tag : 'con' });
    con.first( () => new _.Consequence().error( testMsg ));

    test.identical( con.resourcesGet().length, 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 1 );


      con.give( function( err, got )
      {
        test.is( _.strHas( String( err ), testMsg ) );
        test.identical( got, undefined );
      })
      return null;
    })
    .thenKeep( function( arg )
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'routine returns consequence that gives resource with timeout';
    var con = new _.Consequence({ tag : 'con' });
    var timeBefore = _.timeNow();
    con.first( () => _.timeOut( 250, () => null ));

    test.identical( con.resourcesGet().length, 0 );

    return _.timeOut( 251, function()
    {
      test.identical( con.resourcesGet().length, 1 );

      con.give( function( err, got )
      {
        var delay = _.timeNow() - timeBefore;
        var description = test.case = 'delay ' + delay;
        test.ge( delay, 250 - c.timeAccuracy );
        test.case = description;
        test.identical( err, undefined );
        test.identical( got, null );
      })
      return null;
    })
    .thenKeep( function( arg )
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'passed consequence shares own resource';
    var con = new _.Consequence({ tag : 'con' });
    var con2 = new _.Consequence({ tag : 'con2' }).take( testMsg );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 1 );

    con.first( con2 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 1 );

    return _.timeOut( 1, function()
    {

      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );

      test.identical( con.resourcesGet().length, 1 );

      con.give( function( err, got )
      {
        test.identical( err, undefined );
        test.identical( got, testMsg );
      })
      return null;
    })
    .thenKeep( function( arg )
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con2.resourcesGet().length, 1 );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'passed consequence shares own resource with timeout';
    var con = new _.Consequence({ tag : 'con' });
    var con2 = _.timeOut( 250, () => testMsg );
    var timeBefore = _.timeNow();
    con.first( con2 );

    return _.timeOut( 251, function()
    {
      test.identical( con.resourcesGet().length, 1 );

      con.give( function( err, got )
      {
        var delay = _.timeNow() - timeBefore;
        var description = test.case = 'delay ' + delay;
        test.ge( delay, 250 - c.timeAccuracy );
        test.case = description;
        test.identical( err, undefined );
        test.identical( got, testMsg );
      })
      return null;
    })
    .thenKeep( function( arg )
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con2.resourcesGet().length, 1 );
      return null;
    })
  })

  /* */

  .finally( ( err, arg ) =>
  {
    test.close( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );

    _.Consequence.AsyncModeSet( amode );


    if( err )
    throw err;
    return arg;

  })
  return que;
}

//

function firstAsyncMode11( test )
{
  var c = this;
  var amode = _.Consequence.AsyncModeGet();
  var testMsg = 'msg';
  var que = new _.Consequence().take( null )

  .finally( () =>
  {
    _.Consequence.AsyncModeSet([ 1, 1 ]);
    test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );
    return null;
  })

  .thenKeep( function( arg )
  {
    test.case = 'simplest, empty routine';
    var con = new _.Consequence({ tag : 'con', capacity : 2 });
    con.give( function( err, got )
    {
      test.identical( got, null );
    });
    con.first( () => null );
    con.take( testMsg );

    test.identical( con.resourcesGet().length, 2 );
    test.identical( con.competitorsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg }] );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'routine returns something';
    var con = new _.Consequence({ tag : 'con', capacity : 2 });
    con.give( function( err, got )
    {
      test.identical( got, testMsg );
    })
    con.first( () => testMsg );

    con.take( testMsg + 2 );

    test.identical( con.resourcesGet().length, 2 );
    test.identical( con.competitorsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg + 2 }] );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'routine throws error';
    var con = new _.Consequence({ tag : 'con' });
    con.first( () => { throw testMsg });
    con.give( function( err, got )
    {
      test.is( _.errIs( err ) );
      test.identical( got, undefined );
    });

    test.identical( con.resourcesGet().length, 0 );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'routine returns consequence with resource';
    var con = new _.Consequence({ tag : 'con' });
    con.first( () => new _.Consequence().take( testMsg ));
    con.give( function( err, got )
    {
      test.identical( err, undefined );
      test.identical( got, testMsg );
    })
    test.identical( con.resourcesGet().length, 0 );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'routine returns consequence with err resource';
    var con = new _.Consequence({ tag : 'con' });
    con.first( () => new _.Consequence().error( testMsg ));
    con.give( function( err, got )
    {
      test.is( _.strHas( String( err ), testMsg ) );
      test.identical( got, undefined );
    })
    test.identical( con.resourcesGet().length, 0 );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'routine returns consequence that gives resource with timeout';
    var con = new _.Consequence({ tag : 'con' });
    var timeBefore = _.timeNow();
    con.first( () => _.timeOut( 250, () => null ));
    con.give( function( err, got )
    {
      var delay = _.timeNow() - timeBefore;
      var description = test.case = 'delay ' + delay;
      test.ge( delay, 250 - c.timeAccuracy );
      test.case = description;
      test.identical( err, undefined );
      test.identical( got, null );
    })
    test.identical( con.resourcesGet().length, 0 );

    return _.timeOut( 251, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'passed consequence shares own resource';
    var con = new _.Consequence({ tag : 'con' });
    var con2 = new _.Consequence({ tag : 'con2' }).take( testMsg );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 1 );

    con.first( con2 );

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 1 );

    con.finally( function( err, got )
    {

      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );

      test.identical( err, undefined );
      test.identical( got, testMsg );

      return got;
    });

    return _.timeOut( 5, function()
    {

      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );

      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 1 );
      test.identical( con2.resourcesGet().length, 1 );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'passed consequence shares own resource with timeout';
    var con = new _.Consequence({ tag : 'con' });
    var con2 = _.timeOut( 250, () => testMsg );
    var timeBefore = _.timeNow();
    con.first( con2 );
    con.give( function( err, got )
    {
      var delay = _.timeNow() - timeBefore;
      var description = test.case = 'delay ' + delay;
      test.ge( delay, 250 - c.timeAccuracy );
      test.case = description;
      test.identical( err, undefined );
      test.identical( got, testMsg );
    })
    return _.timeOut( 251, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con2.resourcesGet().length, 1 );
      return null;
    })
  })

  /* */

  .finally( ( err, arg ) =>
  {
    test.close( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );

    _.Consequence.AsyncModeSet( amode );


    if( err )
    throw err;
    return arg;

  })
  return que;
}

//

function fromAsyncMode00( test )
{
  var testMsg = 'value';
  var amode = _.Consequence.AsyncModeGet();
  var que = new _.Consequence().take( null )

  /* */

  .finally( () =>
  {
    _.Consequence.AsyncModeSet([ 0, 0 ]);
    test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );
    return null;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'passing value';
    var con = _.Consequence.From( testMsg );
    test.identical( con.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
    test.identical( con.competitorsEarlyGet(), [] );
    return con;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'passing an error';
    var err = _.err( testMsg );
    var con = _.Consequence.From( err );
    test.identical( con.resourcesGet(), [ { error : err, argument : undefined } ] );
    test.identical( con.competitorsEarlyGet(), [] );
    return con.finally( () => null );
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'passing consequence';
    var src = new _.Consequence().take( testMsg );
    var con = _.Consequence.From( src );
    test.identical( con, src );
    test.identical( con.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
    test.identical( con.competitorsEarlyGet(), [] );
    return con;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'passing resolved promise';
    var src = Promise.resolve( testMsg );
    var con = _.Consequence.From( src );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
      test.identical( con.competitorsEarlyGet(), [] );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'passing rejected promise';
    var src = Promise.reject( testMsg );
    var con = _.Consequence.From( src );
    return _.timeOut( 1, function()
    {
      // test.identical( con.resourcesGet(), [ { error : testMsg, argument : undefined } ] );
        test.is( _.strHas( String( con.errorsGet()[ 0 ] ), testMsg ) );
      test.identical( con.competitorsEarlyGet(), [] );
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'sync, resolved promise, timeout';
    var src = Promise.resolve( testMsg );
    var con = _.Consequence.From( src, 500 );
    con.give( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 )
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 0 )
      test.identical( con.competitorsEarlyGet().length, 0 )
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'sync, promise resolved with timeout';
    var src = new Promise( ( resolve ) =>
    {
      setTimeout( () => resolve( testMsg ), 600 );
    })
    var con = _.Consequence.From( src, 500 );
    con.give( ( err, got ) => test.is( _.errIs( err ) ) );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 )
    return _.timeOut( 600, function()
    {
      test.identical( con.resourcesGet().length, 0 )
      test.identical( con.competitorsEarlyGet().length, 0 )
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'sync, timeout, src is a consequence';
    var con = new _.Consequence({ tag : 'con' }).take( testMsg );
    con = _.Consequence.From( con , 500 );
    con.give( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'sync, timeout, src is a consequence';
    var con = _.timeOut( 600, () => testMsg );
    con = _.Consequence.From( con , 500 );
    con.give( ( err, got ) => test.is( _.errIs( err ) ) );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 );
    return _.timeOut( 600, function()
    {
      test.identical( con.resourcesGet().length, 0 )
      test.identical( con.competitorsEarlyGet().length, 0 )
      return null;
    })
  })

  /* */

  .finally( ( err, arg ) =>
  {
    test.close( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );

    _.Consequence.AsyncModeSet( amode );


    if( err )
    throw err;
    return arg;

  })
  return que;
}

//

function fromAsyncMode10( test )
{
  var testMsg = 'value';
  var amode = _.Consequence.AsyncModeGet();
  var que = new _.Consequence().take( null )

  /* */

  .finally( () =>
  {
    _.Consequence.AsyncModeSet([ 1, 0 ]);
    test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );
    return null;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async competitors adding, passing value';
    var con = _.Consequence.From( testMsg );
    con.give( ( err, got ) => test.identical( got, testMsg ) )
    test.identical( con.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsEarlyGet(), [] );
      return null;
    })

    return con;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async competitors adding, passing an error';
    var src = _.err( testMsg );
    var con = _.Consequence.From( src );
    con.give( ( err, got ) => test.is( err === src ) );
    test.identical( con.resourcesGet(), [ { error : src, argument : undefined } ] );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsEarlyGet(), [] );
      return null;
    })

    return con;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async competitors adding, passing consequence';
    var src = new _.Consequence().take( testMsg );
    var con = _.Consequence.From( src );
    con.give( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( src.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con, src );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsEarlyGet(), [] );
      return null;
    })

    return con;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async competitors adding, passing resolved promise';
    var src = Promise.resolve( testMsg );
    var con = _.Consequence.From( src );
    con.give( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 )
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 0 )
      test.identical( con.competitorsEarlyGet().length, 0 )
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async competitors adding, passing rejected promise';
    var src = Promise.reject( testMsg );
    var con = _.Consequence.From( src );
    con.give( ( err, got ) => test.is( _.strHas( String( err ), testMsg ) ) );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 )
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 0 )
      test.identical( con.competitorsEarlyGet().length, 0 )
      return null;
    })
  })

  /* */

  .finally( ( err, arg ) =>
  {
    test.close( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );

    _.Consequence.AsyncModeSet( amode );


    if( err )
    throw err;
    return arg;

  })
  return que;
}

//

function fromAsyncMode01( test )
{
  var testMsg = 'value';
  var amode = _.Consequence.AsyncModeGet();
  var que = new _.Consequence().take( null )

  /* */

  .finally( () =>
  {
    _.Consequence.AsyncModeSet([ 0, 1 ]);
    test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );
    return null;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async resources adding passing value';
    var con = _.Consequence.From( testMsg );
    test.identical( con.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
    con.give( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.resourcesGet(), [] );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsEarlyGet(), [] );
      return null;
    })

    return con;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'passing an error';
    var src = _.err( testMsg );
    var con = _.Consequence.From( src );
    test.identical( con.resourcesGet(), [ { error : src, argument : undefined } ] );
    // con.give( ( err, got ) => test.is( _.strHas( String( err ), src ) ) );
    con.give( ( err, got ) => test.is( err === src ) );
    test.identical( con.resourcesGet(), [] );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsEarlyGet(), [] );
      return null;
    })

    return con;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'passing consequence';
    var src = new _.Consequence().take( testMsg );
    var con = _.Consequence.From( src );
    test.identical( src.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
    con.give( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( src.resourcesGet(), [] );
    test.identical( con, src );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsEarlyGet(), [] );
      return null;
    })

    return con;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'passing resolved promise';
    var src = Promise.resolve( testMsg );
    var con = _.Consequence.From( src );
    con.give( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.resourcesGet().length, 0 )
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 0 )
      test.identical( con.competitorsEarlyGet().length, 0 )
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'passing rejected promise';
    var src = Promise.reject( testMsg );
    var con = _.Consequence.From( src );
    con.give( ( err, got ) => test.is( _.strHas( String( err ), testMsg ) ) );
    test.identical( con.resourcesGet().length, 0 )
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 0 )
      test.identical( con.competitorsEarlyGet().length, 0 )
      return null;
    })
  })

  /* */

  .finally( ( err, arg ) =>
  {
    test.close( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );

    _.Consequence.AsyncModeSet( amode );


    if( err )
    throw err;
    return arg;

  })
  return que;
}

//

function fromAsyncMode11( test )
{
  var testMsg = 'value';
  var amode = _.Consequence.AsyncModeGet();
  var que = new _.Consequence().take( null )

  /* */

  .finally( () =>
  {
    _.Consequence.AsyncModeSet([ 1, 1 ]);
    test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );
    return null;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async, passing value';
    var con = _.Consequence.From( testMsg );
    con.give( ( err, got ) => test.identical( got, testMsg ) )
    test.identical( con.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsEarlyGet(), [] );
      return null;
    })

    return con;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async, passing an error';
    var src = _.err( testMsg );
    var con = _.Consequence.From( src );
    con.give( ( err, got ) => test.is( err === src ) );
    test.identical( con.resourcesGet(), [ { error : src, argument : undefined } ] );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsEarlyGet(), [] );
      return null;
    })

    return con;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async, passing consequence';
    var src = new _.Consequence().take( testMsg );
    var con = _.Consequence.From( src );
    con.give( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( src.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con, src );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsEarlyGet(), [] );
      return null;
    })

    return con;
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async, passing resolved promise';
    var src = Promise.resolve( testMsg );
    var con = _.Consequence.From( src );
    con.give( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 )
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 0 )
      test.identical( con.competitorsEarlyGet().length, 0 )
      return null;
    })
  })

  /* */

  .thenKeep( function( arg )
  {
    test.case = 'async, passing rejected promise';
    var src = Promise.reject( testMsg );
    var con = _.Consequence.From( src );
    con.give( ( err, got ) => test.is( _.strHas( String( err ), testMsg ) ) );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 )
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 0 )
      test.identical( con.competitorsEarlyGet().length, 0 )
      return null;
    })
  })

  /* */

  .finally( ( err, arg ) =>
  {
    test.close( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );

    _.Consequence.AsyncModeSet( amode );


    if( err )
    throw err;
    return arg;

  })
  return que;
}

//

function consequenceLike( test )
{
  test.case = 'check if entity is a consequenceLike';
  if( !_.consequenceLike )
  return test.identical( true, true );

  test.is( !_.consequenceLike() );
  test.is( !_.consequenceLike( {} ) );
  if( _.Consequence )
  {
    test.is( _.consequenceLike( new _.Consequence() ) );
    test.is( _.consequenceLike( _.Consequence() ) );
  }
  test.is( _.consequenceLike( Promise.resolve( 0 ) ) );

  var promise = new Promise( ( resolve, reject ) => { resolve( 0 ) } )
  test.is( _.consequenceLike( promise ) );
  test.is( _.consequenceLike( _.Consequence.From( promise ) ) );

}

//

function competitorsCancelSingle( test )
{
  var con = new _.Consequence({ tag : 'con' }).take( null );

  function competitor1(){}
  function competitor2(){}

  test.case = 'setup';
  con.give( competitor1 );
  con.give( competitor1 );
  con.give( competitor2 );

  test.identical( con.argumentsCount(), 0 );
  test.identical( con.errorsCount(), 0 );
  test.identical( con.competitorsCount(), 2 );

  test.case = 'cancel comeptitor2';
  con.competitorsCancel( competitor2 );
  if( Config.debug )
  test.shouldThrowErrorSync( () => con.competitorsCancel( competitor2 ) );
  test.identical( con.argumentsCount(), 0 );
  test.identical( con.errorsCount(), 0 );
  test.identical( con.competitorsCount(), 1 );

  test.case = 'cancel comeptitor1';
  con.competitorsCancel( competitor1 );
  if( Config.debug )
  test.shouldThrowErrorSync( () => con.competitorsCancel( competitor1 ) );
  test.identical( con.argumentsCount(), 0 );
  test.identical( con.errorsCount(), 0 );
  test.identical( con.competitorsCount(), 0 );

  test.case = 'all';
  con.give( competitor1 );
  con.give( competitor1 );
  con.give( competitor2 );
  con.competitorsCancel();
  test.identical( con.argumentsCount(), 0 );
  test.identical( con.errorsCount(), 0 );
  test.identical( con.competitorsCount(), 0 );

  /* */

  if( !Config.debug )
  return;

  test.case = 'throwing';
  test.shouldThrowErrorSync( () => con.competitorsCancel( competitor1 ) );
  test.shouldThrowErrorSync( () => con.competitorsCancel( competitor2 ) );
  test.shouldThrowErrorSync( () => con.competitorsCancel( undefined ) );
  test.shouldThrowErrorSync( () => con.competitorsCancel( null ) );
  test.shouldThrowErrorSync( () => con.competitorsCancel( 1 ) );
  test.shouldThrowErrorSync( () => con.competitorsCancel( '1' ) );

}

//

function competitorsCancel( test )
{
  var con = new _.Consequence({ tag : 'con' }).take( null );

  function competitor1(){};
  function competitor2(){};

  con.give( competitor1 );
  con.give( competitor1 );
  con.give( competitor1 );
  con.give( competitor2 );

  test.case = 'setup';
  test.identical( con.argumentsCount(), 0 );
  test.identical( con.errorsCount(), 0 );
  test.identical( con.competitorsCount(), 3 );

  test.case = 'cancel competitor2';
  con.competitorsCancel( competitor2 );
  test.identical( con.argumentsCount(), 0 );
  test.identical( con.errorsCount(), 0 );
  test.identical( con.competitorsCount(), 2 );

  test.shouldThrowErrorSync( () =>
  {
    test.case = 'cancel competitor2, none found';
    con.competitorsCancel( competitor2 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 2 );
  });

  test.case = 'cancel several competitor1';
  con.competitorsCancel( competitor1 );
  test.identical( con.argumentsCount(), 0 );
  test.identical( con.errorsCount(), 0 );
  test.identical( con.competitorsCount(), 0 );

  test.shouldThrowErrorSync( () =>
  {
    test.case = 'cancel competitor1, none found';
    con.competitorsCancel( competitor1 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
  });

  test.case = 'cancel all, none found';
  con.competitorsCancel();
  test.identical( con.argumentsCount(), 0 );
  test.identical( con.errorsCount(), 0 );
  test.identical( con.competitorsCount(), 0 );

  test.case = 'cancel all';
  con.give( competitor1 );
  con.give( competitor1 );
  con.give( competitor1 );
  con.give( competitor2 );

  test.identical( con.argumentsCount(), 0 );
  test.identical( con.errorsCount(), 0 );
  test.identical( con.competitorsCount(), 4 );

  con.competitorsCancel()

  test.identical( con.argumentsCount(), 0 );
  test.identical( con.errorsCount(), 0 );
  test.identical( con.competitorsCount(), 0 );

  /* */

  if( !Config.debug )
  return;

  test.case = 'throwing';
  test.shouldThrowErrorSync( () => con.competitorsCancel( null ) );
  test.shouldThrowErrorSync( () => con.competitorsCancel( 1 ) );
  test.shouldThrowErrorSync( () => con.competitorsCancel( '1' ) );
}

//

function thenSequenceSync( test )
{
  test.case = 'consequences in then has resources';
  var con = new _.Consequence({ tag : 'con' }).take( 0 );
  var con1 = new _.Consequence({ tag : 'con1', capacity : 2 }).take( 1 );
  var con2 = new _.Consequence({ tag : 'con2', capacity : 3 }).take( 2 ).take( 3 );
  con.then( con1 ).then( con2 );
  test.identical( _.select( con.resourcesGet(), '*/argument' ), [ 0 ] );
  test.identical( _.select( con1.resourcesGet(), '*/argument' ), [ 1, 0 ] );
  test.identical( _.select( con2.resourcesGet(), '*/argument' ), [ 2, 3, 0 ] );

  /* */

  test.case = 'consequences in then has competitors';
  var sequence = [];
  var con = new _.Consequence({ tag : 'con' });
  var con1 = new _.Consequence({ tag : 'con1' }).then( comp1 );
  var con2 = new _.Consequence({ tag : 'con2' }).then( comp2 ).then( comp3 );

  con.then( con1 ).then( con2 );
  con.then( comp0 );
  con.take( 'con' );

  test.identical( _.select( con.resourcesGet(), '*/argument' ), [ 'comp0' ] );
  test.identical( _.select( con1.resourcesGet(), '*/argument' ), [ 'comp1' ] );
  test.identical( _.select( con2.resourcesGet(), '*/argument' ), [ 'comp3' ] );
  test.identical( sequence, [ 'comp1', 'comp2', 'comp3', 'comp0' ] );

  /* */

  function comp0()
  {
    sequence.push( 'comp0' );
    logger.log( 'comp0' );
    return 'comp0';
  }

  function comp1()
  {
    sequence.push( 'comp1' );
    logger.log( 'comp1' );
    return 'comp1';
  }

  function comp2()
  {
    sequence.push( 'comp2' );
    logger.log( 'comp2' );
    return 'comp2';
  }

  function comp3()
  {
    sequence.push( 'comp3' );
    logger.log( 'comp3' );
    return 'comp3';
  }

}

// xxx : implement con1.then( con )

function thenSequenceAsync( test )
{

  /* */

  // test.case = 'consequences in then has resources';
  // var con = new _.Consequence({ tag : 'con' }).take( 0 );
  // var con1 = new _.Consequence({ tag : 'con1' }).take( 1 );
  // var con2 = new _.Consequence({ tag : 'con2' }).take( 2 ).take( 3 );
  // con.then( con1 ).then( con2 );
  // test.identical( _.select( con.resourcesGet(), '*/argument' ), [ 0 ] );
  // test.identical( _.select( con1.resourcesGet(), '*/argument' ), [ 1, 0 ] );
  // test.identical( _.select( con2.resourcesGet(), '*/argument' ), [ 2, 3, 0 ] );

  /* */

  test.case = 'consequences in then has competitors';
  var sequence = [];
  var con = new _.Consequence({ tag : 'con' });
  var con1 = new _.Consequence({ tag : 'con1' }).then( comp1 );
  var con2 = new _.Consequence({ tag : 'con2' }).then( comp2 ).then( comp3 );

  con.then( con1 ).then( con2 );
  con.then( comp0 );
  con.take( 'con' );

  test.identical( _.select( con.resourcesGet(), '*/argument' ), [] );
  test.identical( _.select( con1.resourcesGet(), '*/argument' ), [] );
  test.identical( _.select( con2.resourcesGet(), '*/argument' ), [] );
  test.identical( sequence, [ 'comp1:begin' ] );

  return _.timeOut( 1000, () =>
  {
    test.identical( _.select( con.resourcesGet(), '*/argument' ), [ 'comp0' ] );
    test.identical( _.select( con1.resourcesGet(), '*/argument' ), [ 'comp1b' ] );
    test.identical( _.select( con2.resourcesGet(), '*/argument' ), [ 'comp3' ] );
    var exp =
    [
      'comp1:begin',
      'comp1:end',
      'comp1b:begin',
      'comp1b:end',
      'comp2:begin',
      'comp2:end',
      'comp3:begin',
      'comp3:end',
      'comp0:begin',
      'comp0:end',
    ]
    test.identical( sequence, exp );
  });

  /* */

  function comp0()
  {
    sequence.push( 'comp0:begin' );
    logger.log( 'comp0:begin' );
    return _.timeOut( 50, () =>
    {
      sequence.push( 'comp0:end' );
      logger.log( 'comp0:end' );
      return 'comp0';
    });
  }

  function comp1()
  {
    sequence.push( 'comp1:begin' );
    logger.log( 'comp1:begin' );
    this.then( comp1b );
    return _.timeOut( 50, () =>
    {
      sequence.push( 'comp1:end' );
      logger.log( 'comp1:end' );
      return 'comp1';
    });
  }

  function comp1b()
  {
    sequence.push( 'comp1b:begin' );
    logger.log( 'comp1b:begin' );
    return _.timeOut( 50, () =>
    {
      sequence.push( 'comp1b:end' );
      logger.log( 'comp1b:end' );
      return 'comp1b';
    });
  }

  function comp2()
  {
    sequence.push( 'comp2:begin' );
    logger.log( 'comp2:begin' );
    return _.timeOut( 50, () =>
    {
      sequence.push( 'comp2:end' );
      logger.log( 'comp2:end' );
      return 'comp2';
    });
  }

  function comp3()
  {
    sequence.push( 'comp3:begin' );
    logger.log( 'comp3:begin' );
    return _.timeOut( 50, () =>
    {
      sequence.push( 'comp3:end' );
      logger.log( 'comp3:end' );
      return 'comp3';
    });
  }

}

// --
// declare
// --

var Self =
{

  name : 'Tools/base/Consequence',
  silencing : 1,
  routineTimeOut : 30000,

  context :
  {
    timeAccuracy : 1,
  },

  tests :
  {

    clone,

    trivial,

    ordinarResourceAsyncMode00,
    ordinarResourceAsyncMode10,
    ordinarResourceAsyncMode01,
    ordinarResourceAsyncMode11,

    finallyPromiseGiveAsyncMode00,
    finallyPromiseGiveAsyncMode10,
    finallyPromiseGiveAsyncMode01,
    finallyPromiseGiveAsyncMode11,

    _finallyAsyncMode00,
    _finallyAsyncMode10,
    _finallyAsyncMode01,
    _finallyAsyncMode11,

    finallyPromiseKeepAsyncMode00,
    finallyPromiseKeepAsyncMode10,
    finallyPromiseKeepAsyncMode01,
    finallyPromiseKeepAsyncMode11,

    split,
    tap,
    tapHandling,

    catchTestRoutine,
    ifNoErrorGotTrivial,
    ifNoErrorGotThrowing,
    keep,

    timeOut,

    notDeadLock1,

    andNotDeadLock,
    andConcurrent,
    andKeepRoutinesTakeFirst,
    andKeepRoutinesTakeLast,
    andKeepRoutinesDelayed,
    andKeepDuplicates,
    andKeepInstant,
    andKeep,
    andTake,
    _and,

    AndKeep,
    AndTake,

    orKeepingWithSimple,
    orKeepingWithLater,
    orKeepingWithNow,
    orTakingWithSimple,
    orTakingWithLater,
    orTakingWithNow,

    thenOrKeepingNotFiring,
    thenOrKeepingWithSimple,
    thenOrKeepingWithLater,
    thenOrKeepingWithTwoTake0,
    thenOrTakingWithSimple,
    thenOrTakingWithLater,
    thenOrTakingWithTwoTake0,

    inter,
    put,

    firstAsyncMode00,
    firstAsyncMode10,
    firstAsyncMode01,
    firstAsyncMode11,

    fromAsyncMode00,
    fromAsyncMode10,
    fromAsyncMode01,
    fromAsyncMode11,
    consequenceLike,

    competitorsCancelSingle,
    competitorsCancel,

    thenSequenceSync,
    // thenSequenceAsync,

  },

};

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
