( function _Time_test_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{

  try
  {
    let _ = require( '../../../../wtools/Tools.s' );
  }
  catch( err )
  {
    let _ = require( '../../../wtools/Tools.s' );
  }

  let _ = _global_.wTools;

  // try
  // {
  //   require( '../tester/entry/Main.s' );
  // }
  // catch( err )
  // {
    _.include( 'wTesting' );
  // }

  // _.include( 'wConsequence' );
  require( '../../l9/consequence/Namespace.s' );
}

let _global = _global_;
let _ = _global_.wTools;

/* qqq : split test cases by / * * / */

// --
// tests
// --

function sleep( test )
{

  test.case = 'delay - 0';
  var start = _.time.now();
  _.time.sleep( 0 );
  var got = _.time.now() - start;
  test.is( 0 <= got );

  test.case = 'delay - 2';
  var start = _.time.now();
  _.time.sleep( 2 );
  var got = _.time.now() - start;
  test.is( 1 <= got );

  test.case = 'delay - 100';
  var start = _.time.now();
  _.time.sleep( 100 );
  var got = _.time.now() - start;
  test.is( 99 <= got );

  test.case = 'delay - 2000';
  var start = _.time.now();
  _.time.sleep( 2000 );
  var got = _.time.now() - start;
  test.is( 1999 <= got );

  /* - */

  if( !Config.debug )
  return;

  test.case = 'without arguments';
  test.shouldThrowErrorSync( () => _.time.sleep() );

  test.case = 'extra arguments';
  test.shouldThrowErrorSync( () => _.time.sleep( 10, new _.Procedure(), 10 ) );

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

function timeOutCancelInsideOfCallback( test )
{
  let context = this;
  let visited = [];

  var timer = _.time.begin( 1, () =>
  {
    visited.push( 'v1' );
    _.time.cancel( timer );
    visited.push( 'v2' );
  });

  visited.push( 'v0' );

  return _.time.out( context.dt1*15 ).then( () =>
  {
    test.identical( visited, [ 'v0', 'v1', 'v2' ] );
    return null;
  });
}

//

function timeOutCancelOutsideOfCallback( test )
{
  let context = this;
  let visited = [];

  var timer = _.time.begin( context.dt1*3, () =>
  {
    visited.push( 'v1' );
  });

  _.time.cancel( timer );
  visited.push( 'v0' );

  return _.time.out( context.dt1*15 ).then( () =>
  {
    test.identical( visited, [ 'v0' ] );
    return null;
  });
}

//

function timeOutCancelZeroDelayInsideOfCallback( test )
{
  let context = this;
  let visited = [];

  var timer = _.time.begin( 0, () =>
  {
    visited.push( 'v1' );
    _.time.cancel( timer );
    visited.push( 'v2' );
  });

  visited.push( 'v0' );

  return _.time.out( context.dt1*15 ).then( () =>
  {
    test.identical( visited, [ 'v0', 'v1', 'v2' ] );
    return null;
  });
}

//

function timeOutCancelZeroDelayOutsideOfCallback( test )
{
  let context = this;
  let visited = [];

  var timer = _.time.begin( 0, () =>
  {
    visited.push( 'v1' );
  });

  _.time.cancel( timer );
  visited.push( 'v0' );

  return _.time.out( context.dt1*15 ).then( () =>
  {
    test.identical( visited, [ 'v0' ] );
    return null;
  });
}

//

function timeOut( test )
{
  var c = this;
  var ready = new _.Consequence().take( null )

  /* */

  .then( function()
  {
    test.case = 'delay only';
    var timeBefore = _.time.now();
    return _.time.out( c.dt2 )
    .finally( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt2-c.timeAccuracy );
      test.is( _.routineIs( got ) );
      test.identical( err, undefined );
      return null;
    });
  })

  /* */

  .then( function()
  {
    test.case = 'delay + routine';
    var timeBefore = _.time.now();
    return _.time.out( c.dt2, () => null )
    .finally( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt2-c.timeAccuracy );
      test.identical( got, null );
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
    return _.time.out( c.dt2, () => value )
    .finally( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt2-c.timeAccuracy );
      test.identical( got, value );
      test.identical( err, undefined );
      return null;
    });
  })

  /* */

  .then( function()
  {
    test.case = 'delay + routine that returns a consequence';
    var timeBefore = _.time.now();
    return _.time.out( c.dt2, () => _.time.out( c.dt2 ) )
    .finally( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      // test.is( elapsedTime >= c.dt2 * 2 );
      test.ge( elapsedTime, 2 * c.dt2-c.timeAccuracy );
      test.is( _.routineIs( got ) );
      test.identical( err, undefined );
      return null;
    });
  })

  /* */

  .then( function()
  {
    test.case = 'delay + routine that calls another timeOut';
    var timeBefore = _.time.now();
    return _.time.out( c.dt2, () => { _.time.out( c.dt2 ); return null } )
    .finally( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt2-c.timeAccuracy );
      test.identical( err, undefined );
      test.identical( got, null );
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
    return _.time.out( c.dt2, undefined, r, [ c.dt2 ] )
    .finally( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt2-c.timeAccuracy );
      test.identical( got, c.dt2 / 2 );
      test.identical( err, undefined );
      return null;
    });
  })

  /* */

  .then( function()
  {
    test.case = 'delay + consequence, first delay greater';
    var timeBefore = _.time.now();

    return _.time.out( c.dt2, _.time.out( c.dt2 * 2 ) )
    .finally( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      // test.is( elapsedTime >= c.dt2 * 2 );
      test.ge( elapsedTime, 2 * c.dt2-c.timeAccuracy );
      test.is( _.routineIs( got ) );
      test.identical( err, undefined );
      return null;
    });
  })

  /* */

  .then( function()
  {
    test.case = 'delay + consequence, second delay greater';
    var timeBefore = _.time.now();

    return _.time.out( c.dt2*3, _.time.out( c.dt2 * 2 ) )
    .finally( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      // test.is( elapsedTime >= c.dt2 * 2 );
      test.ge( elapsedTime, 3 * c.dt2-c.timeAccuracy );
      test.is( _.routineIs( got ) );
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

    return _.time.out( c.dt2, () => _.time.out( c.dt2 * 2, () => val ) )
    .finally( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt2 * 3-c.timeAccuracy );
      test.identical( err, undefined );
      test.identical( got, val );
      return null;
    })
  })

  /* */

  .then( function()
  {
    test.case = 'delay + consequence that returns delayed value, launched concurrently';
    var timeBefore = _.time.now();
    var val = 13;

    return _.time.out( c.dt2, _.time.out( c.dt2 * 2, () => val ) )
    .finally( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt2 * 2-c.timeAccuracy );
      test.identical( err, undefined );
      test.identical( got, val );
      return null;
    })
  })

  /* */

  .then( function()
  {
    test.case = 'delay + consequence that returns delayed value, launched concurrently';
    var timeBefore = _.time.now();

    return _.time.out( c.dt2, _.time.out( c.dt2 * 2, () => _.time.out( c.dt2 * 2 ) ) )
    .finally( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt2 * 4-c.timeAccuracy );
      test.identical( err, undefined );
      test.identical( got, _.time.out );
      return null;
    })
  })

  /* */

  .then( function()
  {
    test.case = 'delay + consequence + error';
    var timeBefore = _.time.now();

    return _.time.out( c.dt2, _.time.out( c.dt2 * 2, () => { throw _.err( 'err' ) } ) )
    .finally( function( err, got )
    {
      if( err )
      _.errAttend( err );
      var elapsedTime = _.time.now() - timeBefore;
      // test.is( elapsedTime >= c.dt2 * 2 );
      test.ge( elapsedTime, 2 * c.dt2-c.timeAccuracy );
      test.is( _.errIs( err ) );
      test.identical( got, undefined );
      return null;
    });
  })

  /* */

  .then( function()
  {
    test.case = 'stop timer with dont';
    var timeBefore = _.time.now();

    var t = _.time.out( c.dt2 );
    t.finally( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt2 / 2 - c.timeAccuracy );
      // test.identical( _.strHas( _.err( err ).message, 'stop' ), true );
      // test.identical( got, undefined );
      test.identical( err, undefined );
      test.identical( got, _.dont );
      return null;
    })
    _.time.out( c.dt2 / 2, () =>
    {
      t.take( _.dont );
      return null;
    });
    // _.time.out( c.dt2 / 2, () => { t.take( _.dont ); return null; });
    // _.time.out( c.dt2 / 2, () => { t.error( _.errAttend( 'stop' ) ); return null; });

    return t;
  })

  /* */

  .then( function()
  {
    test.case = 'stop timer with error, routine passed';
    var timeBefore = _.time.now();
    var called = false;

    var t = _.time.out( c.dt2, () => { called = true } );
    t.finally( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt2 / 2 - c.timeAccuracy );
      // test.identical( got, undefined );
      // test.identical( _.strHas( _.err( err ).message, 'stop' ), true );
      test.identical( err, undefined );
      test.identical( got, _.dont );
      test.identical( called, false );
      return null;
    })
    _.time.out( c.dt2 / 2, () =>
    {
      t.take( _.dont );
      return null;
    });
    // _.time.out( c.dt2 / 2, () => { t.error( _.errAttend( 'stop' ) ); return null; });

    return t;
  })

  /* */

  .then( function()
  {
    test.case = 'stop after timeOut';
    var timeBefore = _.time.now();

    var t = _.time.out( c.dt2, () => null );
    t.give( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt2-c.timeAccuracy );
      test.identical( got, null );
      test.identical( err, undefined );
    });

    return _.time.out( c.dt2 + 50, function()
    {
      // t.error( _.errAttend( 'stop' ) );
      t.take( _.dont );
      t.give( ( err, got ) =>
      {
        // test.identical( _.strHas( _.err( err ).message, 'stop' ), true )
        test.identical( err, undefined );
        test.identical( got, _.dont );
      });
      return null;
    });

    return t;
  })

  /* */

  .then( function()
  {
    test.case = 'give msg before timeOut';
    var timeBefore = _.time.now();
    var returnValue = 1;
    var msg = 2;

    var t = _.time.out( c.dt2, () => returnValue );

    return _.time.out( c.dt2 / 2, function()
    {
      t.take( msg );
      t.give( ( err, got ) =>
      {
        test.identical( got, msg );
        test.identical( err, undefined );
        return 1;
      });
      t.give( ( err, got ) =>
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt2-c.timeAccuracy );
        test.identical( got, returnValue );
        test.identical( err, undefined );

      })
      return null;
    })

    return t;
  })

  /* */

  .then( function()
  {
    test.case = 'stop timer with error + arg, routine passed';
    var timeBefore = _.time.now();
    var called = false;

    var t = _.time.out( c.dt2, () => { called = true } );
    t.finally( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt2 / 2 - c.timeAccuracy );
      // test.identical( got, undefined );
      // test.identical( _.strHas( _.err( err ).message, 'stop' ), true )
      test.identical( err, undefined );
      test.identical( got, _.dont );
      test.identical( called, false );
      return null;
    })
    _.time.out( c.dt2 / 2, () =>
    {
      t.take( _.dont );
      return null;
    });
    // _.time.out( c.dt2 / 2, () =>
    // {
    //   t.take( _.errAttend( 'stop' ), undefined );
    //   return null;
    // });

    return t;
  })

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

  return ready;
}

timeOut.timeOut = 20000;

//

function timeOutMode01( test )
{
  var c = this;
  var mode = _.Consequence.AsyncModeGet();
  var ready = new _.Consequence().take( null )

  /* AsyncCompetitorHanding : 0, AsyncResourceAdding : 1 */

  .finally( () =>
  {
    _.Consequence.AsyncModeSet([ 0, 1 ]);
    return null;
  })
  .then( function( arg )
  {
    test.case = 'delay only';
    var timeBefore = _.time.now();
    var t = _.time.out( c.dt2 );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt2 - c.timeAccuracy );
        test.is( _.routineIs( got ) );
        test.is( err === undefined );
      });
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
    .finally(function()
    {
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /**/

  .then( function( arg )
  {
    test.case = 'delay + routine';
    var timeBefore = _.time.now();
    var t = _.time.out( c.dt2, () => null );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt2-c.timeAccuracy );
        test.identical( got, null );
        test.is( err === undefined );
      });
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
    .finally(function()
    {
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /**/

  .then( function( arg )
  {
    test.case = 'delay + routine that returns a value';
    var timeBefore = _.time.now();
    var value = 'value';
    var t = _.time.out( c.dt2, () => value );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt2-c.timeAccuracy );
        test.is( got === value );
        test.is( err === undefined );
      });
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
    .finally(function()
    {
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /**/

  .then( function( arg )
  {
    test.case = 'delay + routine that returns a consequence';
    var timeBefore = _.time.now();
    var t = _.time.out( c.dt2, () => _.time.out( c.dt2 ) );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt2-c.timeAccuracy );
        test.is( _.routineIs( got ));
        test.is( err === undefined );
      });
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
    .finally(function()
    {
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /**/

  .then( function( arg )
  {
    test.case = 'delay + routine that calls another timeOut';
    var timeBefore = _.time.now();
    var t = _.time.out( c.dt2, () => _.time.out( c.dt2 ) );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt2-c.timeAccuracy );
        test.identical( got, _.time.out );
        test.identical( err, undefined );
      });
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
    .finally(function()
    {
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /**/

  .then( function( arg )
  {
    test.case = 'delay + context + routine + arguments';
    var timeBefore = _.time.now();
    function r( delay )
    {
      return delay * 13;
    }
    var t = _.time.out( c.dt2, undefined, r, [ c.dt2 ] );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt2-c.timeAccuracy );
        test.identical( got, c.dt2 * 13 );
        test.identical( err, undefined );
      });
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
    .finally(function()
    {
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /**/

  .then( function( arg )
  {
    test.case = 'stop timer with error';
    var timeBefore = _.time.now();
    var t = _.time.out( c.dt2 );

    // _.time.out( c.dt2 / 2, () => { t.error( _.errAttend( 'stop' ) ); return null; });
    _.time.out( c.dt2 / 2, () =>
    {
      t.take( _.dont );
      return null;
    });

    return new _.Consequence().first( t )
    .then( function( arg )
    {
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt2 / 2 );
        // test.identical( got, undefined );
        // test.identical( _.strHas( _.err( err ).message, 'stop' ), true );
        test.identical( err, undefined );
        test.identical( got, _.dont );
      });
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
    .finally( function()
    {
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /**/

  .then( function( arg )
  {
    test.case = 'stop timer with error, routine passed';
    var timeBefore = _.time.now();
    var called = false;

    var t = _.time.out( c.dt2, () => { called = true } );
    // _.time.out( c.dt2 / 2, () => { t.error( _.errAttend( 'stop' ) ); return null; });
    _.time.out( c.dt2 / 2, () =>
    {
      t.take( _.dont );
      return null;
    });

    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt2 / 2 );
        // test.identical( got, undefined );
        // test.identical( _.strHas( _.err( err ).message, 'stop' ), true );
        test.identical( err, undefined );
        test.identical( got, _.dont );
        test.identical( called, false );
      });
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
    .finally( function()
    {
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /**/

  .then( function( arg )
  {
    test.case = 'stop after timeOut';
    var timeBefore = _.time.now();
    var t = _.time.out( c.dt2, () => null );

    var con = new _.Consequence();
    con.first( t );
    con.then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt2-c.timeAccuracy );
        test.identical( got, null );
        test.identical( err, undefined );
      })
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
    .finally(function()
    {
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })

    return _.time.out( c.dt2 + 50, function()
    {
      // t.error( _.errAttend( 'stop' ) );
      t.take( _.dont );
      t.give( ( err, got ) =>
      {
        test.identical( err, undefined );
        test.identical( got, _.dont );
        // test.identical( _.strHas( _.err( err ).message, 'stop' ), true );
      });
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
    .then( function( arg )
    {
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );

      _.Consequence.AsyncModeSet( mode );
      return null;
    });

  })

  /**/

  return ready;
}

timeOutMode10.timeOut = 30000;

//

function timeOutMode10( test )
{
  var c = this;
  var mode = _.Consequence.AsyncModeGet();
  var ready = new _.Consequence().take( null )
  /* AsyncCompetitorHanding : 1, AsyncResourceAdding : 0, */

  .finally( () =>
  {
    _.Consequence.AsyncModeSet([ 1, 0 ])
    return null;
  })
  .then( function( arg )
  {
    test.case = 'delay only';
    var timeBefore = _.time.now();
    var t = _.time.out( c.dt2 );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt2-c.timeAccuracy );
        test.is( _.routineIs( got ) );
        test.is( err === undefined );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .delay( 1 )
    .then( function()
    {
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /**/

  .then( function( arg )
  {
    test.case = 'delay + routine';
    var timeBefore = _.time.now();
    var t = _.time.out( c.dt2, () => null );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt2-c.timeAccuracy );
        test.identical( got, null );
        test.identical( err, undefined );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .delay( 1 )
    .then( function()
    {
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /**/

  .then( function( arg )
  {
    test.case = 'delay + routine that returns a value';
    var timeBefore = _.time.now();
    var value = 'value';
    var t = _.time.out( c.dt2, () => value );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt2-c.timeAccuracy );
        test.is( got === value );
        test.identical( err, undefined );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .delay( 1 )
    .then( function()
    {
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /**/

  .then( function( arg )
  {
    test.case = 'delay + routine that returns a consequence';
    var timeBefore = _.time.now();
    var t = _.time.out( c.dt2, () => _.time.out( c.dt2 ) );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt2-c.timeAccuracy );
        test.is( _.routineIs( got ));
        test.identical( err, undefined );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .delay( 1 )
    .then( function()
    {
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /**/

  .then( function( arg )
  {
    test.case = 'delay + routine that calls another timeOut';
    var timeBefore = _.time.now();
    var t = _.time.out( c.dt2, () => { _.time.out( c.dt2 ); return null; } );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt2-c.timeAccuracy );
        test.identical( got, null );
        test.identical( err, undefined );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .delay( 1 )
    .then( function()
    {
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /**/

  .then( function( arg )
  {
    test.case = 'delay + context + routine + arguments';
    var timeBefore = _.time.now();
    function r( delay )
    {
      return delay / 2;
    }
    var t = _.time.out( c.dt2, undefined, r, [ c.dt2 ] );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt2-c.timeAccuracy );
        test.is( got === c.dt2 / 2 );
        test.identical( err, undefined );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .delay( 1 )
    .then( function()
    {
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /**/

  .then( function( arg )
  {
    test.case = 'stop timer with error';
    var timeBefore = _.time.now();
    var t = _.time.out( c.dt2 );

    // _.time.out( c.dt2 / 2, () =>
    // {
    //   t.error( _.errAttend( 'stop' ) );
    //   return null;
    // });

    _.time.out( c.dt2 / 2, () =>
    {
      t.take( _.dont );
      return null;
    });

    return new _.Consequence().first( t )
    .finally( function()
    {

      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt2 / 2 );
        // test.identical( got, undefined );
        // test.identical( _.strHas( _.err( err ).message, 'stop' ), true );;
        test.identical( err, undefined );
        test.identical( got, _.dont );
        test.identical( t.resourcesGet().length, 0 );
        test.identical( t.competitorsEarlyGet().length, 0 );
      });

      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
  })

  /**/

  .then( function( arg )
  {
    test.case = 'stop timer with error, routine passed';
    var timeBefore = _.time.now();
    var called = false;

    var t = _.time.out( c.dt2, () => { called = true } );
    // _.time.out( c.dt2 / 2, () => { t.error( _.errAttend( 'stop' ) ); return null; });

    _.time.out( c.dt2 / 2, () =>
    {
      t.take( _.dont );
      return null;
    });

    return new _.Consequence().first( t )
    .finally( function()
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt2 / 2 );
        // test.identical( got, undefined );
        // test.identical( _.strHas( _.err( err ).message, 'stop' ), true );
        test.identical( err, undefined );
        test.identical( got, _.dont );
        test.identical( called, false );
        test.identical( t.resourcesGet().length, 0 );
        test.identical( t.competitorsEarlyGet().length, 0 );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
  })

  /**/

  .then( function( arg )
  {
    test.case = 'stop after timeOut';
    var timeBefore = _.time.now();
    var t = _.time.out( c.dt2, () => null );

    var con = new _.Consequence();
    con.first( t );
    con.then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt2-c.timeAccuracy );
        test.identical( got, null );
        test.identical( err, undefined );
      })
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .delay( 1 )
    .then( function()
    {
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
    .then( function( arg )
    {
      // t.error( _.errAttend( 'stop' ) );
      t.take( _.dont );
      t.give( ( err, got ) =>
      {
        // test.identical( _.strHas( _.err( err ).message, 'stop' ), true )
        test.identical( err, undefined );
        test.identical( got, _.dont );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .delay( 1 )
    .then( function()
    {
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );

      _.Consequence.AsyncModeSet( mode );

      return null;
    });

    return con;
  })

  return ready;
}

timeOutMode01.timeOut = 30000;

//

function timeOutMode11( test )
{
  var c = this;
  var mode = _.Consequence.AsyncModeGet();
  var ready = new _.Consequence().take( null )

  /* AsyncResourceAdding : 1, AsyncCompetitorHanding : 1 */

  .finally( () =>
  {
    _.Consequence.AsyncModeSet([ 1, 1 ])
    return null;
  })
  .then( function( arg )
  {
    test.case = 'delay only';
    var timeBefore = _.time.now();
    var t = _.time.out( c.dt2 );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt2-c.timeAccuracy );
        test.is( _.routineIs( got ) );
        test.is( err === undefined );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .delay( 1 )
    .then( function()
    {
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /**/

  .then( function( arg )
  {
    test.case = 'delay + routine';
    var timeBefore = _.time.now();
    var t = _.time.out( c.dt2, () => null );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt2-c.timeAccuracy );
        test.identical( got, null );
        test.identical( err, undefined );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .delay( 1 )
    .then( function()
    {
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /**/

  .then( function( arg )
  {
    test.case = 'delay + routine that returns a value';
    var timeBefore = _.time.now();
    var value = 'value';
    var t = _.time.out( c.dt2, () => value );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt2-c.timeAccuracy );
        test.is( got === value );
        test.identical( err, undefined );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .delay( 1 )
    .then( function()
    {
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /**/

  .then( function( arg )
  {
    test.case = 'delay + routine that returns a consequence';
    var timeBefore = _.time.now();
    var t = _.time.out( c.dt2, () => _.time.out( c.dt2 ) );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt2-c.timeAccuracy );
        test.is( _.routineIs( got ));
        test.identical( err, undefined );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .delay( 1 )
    .then( function()
    {
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /**/

  .then( function( arg )
  {
    test.case = 'delay + routine that calls another timeOut';
    var timeBefore = _.time.now();
    var t = _.time.out( c.dt2, () => { _.time.out( c.dt2 );return null; } );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt2-c.timeAccuracy );
        test.identical( got, null );
        test.identical( err, undefined );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .delay( 1 )
    .then( function()
    {
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /**/

  .then( function( arg )
  {
    test.case = 'delay + context + routine + arguments';
    var timeBefore = _.time.now();
    function r( delay )
    {
      return delay / 2;
    }
    var t = _.time.out( c.dt2, undefined, r, [ c.dt2 ] );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt2-c.timeAccuracy );
        test.is( got === c.dt2 / 2 );
        test.identical( err, undefined );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .delay( 1 )
    .then( function()
    {
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /**/

  .then( function( arg )
  {
    test.case = 'stop timer with error';
    var timeBefore = _.time.now();
    var t = _.time.out( c.dt2 );

    // _.time.out( c.dt2 / 2, () => { t.error( _.errAttend( 'stop' ) ); return null; });
    _.time.out( c.dt2 / 2, () =>
    {
      t.take( _.dont );
      return null;
    });

    return new _.Consequence().first( t )
    .finally( function()
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt2 / 2 );
        // test.identical( got, undefined );
        // test.identical( _.strHas( _.err( err ).message, 'stop' ), true );;
        test.identical( err, undefined );
        test.identical( got, _.dont );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .delay( 1 )
    .then( function()
    {
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /**/

  .then( function( arg )
  {
    test.case = 'stop timer with error, routine passed';
    var timeBefore = _.time.now();
    var called = false;

    var t = _.time.out( c.dt2, () => { called = true; return null; } );
    // _.time.out( c.dt2 / 2, () => { t.error( _.errAttend( 'stop' ) ); return null; });
    _.time.out( c.dt2 / 2, () =>
    {
      t.take( _.dont );
      return null;
    });

    return new _.Consequence().first( t )
    .finally( function()
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt2 / 2 );
        // test.identical( got, undefined );
        // test.identical( _.strHas( _.err( err ).message, 'stop' ), true )
        test.identical( err, undefined );
        test.identical( got, _.dont );
        test.identical( called, false );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .delay( 1 )
    .then( function()
    {
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /**/

  .then( function( arg )
  {
    test.case = 'stop after timeOut';
    var timeBefore = _.time.now();
    var t = _.time.out( c.dt2, () => null );

    var con = new _.Consequence();
    con.first( t );
    con.then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt2-c.timeAccuracy );
        test.identical( got, null );
        test.identical( err, undefined );
      })
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .delay( 1 )
    .then( function()
    {
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      return null;
    })
    .then( function( arg )
    {
      // t.error( _.errAttend( 'stop' ) );
      t.take( _.dont );
      t.give( ( err, got ) =>
      {
        // test.identical( _.strHas( _.err( err ).message, 'stop' ), true );
        test.identical( err, undefined );
        test.identical( got, _.dont );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .delay( 1 )
    .then( function()
    {
      test.identical( t.resourcesGet().length, 0 );
      test.identical( t.competitorsEarlyGet().length, 0 );

      _.Consequence.AsyncModeSet( mode );
      return null;
    });

    return con;
  })

  return ready;
}

timeOutMode11.timeOut = 30000;

//

function timeOutError( test )
{
  var c = this;
  var ready = new _.Consequence().take( null );

  /* */

  ready
  .then( function( arg )
  {
    test.case = 'delay only';
    var timeBefore = _.time.now();
    return _.time.outError( c.dt2 )
    .finally( function( err, got )
    {
      if( err )
      _.errAttend( err );
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt2-c.timeAccuracy );
      test.is( _.errIs( err ) );
      return null;
    });
  })

  /* */

  .then( function( arg )
  {
    test.case = 'delay + routine';
    var timeBefore = _.time.now();
    return _.time.outError( c.dt2, () => null )
    .finally( function( err, got )
    {
      if( err )
      _.errAttend( err );
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt2-c.timeAccuracy );
      test.identical( got, undefined );
      test.is( _.errIs( err ) );
      return null;
    });
  })

  /* */

  .then( function( arg )
  {
    test.case = 'delay + routine that returns a value';
    var timeBefore = _.time.now();
    var value = 'value';
    return _.time.outError( c.dt2, () => value )
    .finally( function( err, got )
    {
      if( err )
      _.errAttend( err );
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt2-c.timeAccuracy );
      test.identical( got, undefined );
      test.is( _.errIs( err ) );
      return null;
    });
  })

  /* */

  .then( function( arg )
  {
    test.case = 'delay + routine that returns a consequence';
    var timeBefore = _.time.now();
    return _.time.outError( c.dt2, () => _.time.out( c.dt2 ) )
    .finally( function( err, got )
    {
      if( err )
      _.errAttend( err );
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, 2 * c.dt2-c.timeAccuracy );
      test.identical( got, undefined );
      test.is( _.errIs( err ) );
      return null;
    });
  })

  /* */

  .then( function( arg )
  {
    test.case = 'delay + routine that calls another timeOut';
    var timeBefore = _.time.now();
    return _.time.outError( c.dt2, () => { _.time.out( c.dt2 ) } )
    .finally( function( err, got )
    {
      if( err )
      _.errAttend( err );
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt2-c.timeAccuracy );
      test.identical( got, undefined );
      test.is( _.errIs( err ) );
      return null;
    });
  })

  /* */

  .then( function( arg )
  {
    test.case = 'delay + context + routine + arguments';
    var timeBefore = _.time.now();
    function r( delay )
    {
      return delay / 2;
    }
    return _.time.outError( c.dt2, undefined, r, [ c.dt2 ] )
    .finally( function( err, got )
    {
      if( err )
      _.errAttend( err );
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt2-c.timeAccuracy );
      test.identical( got, undefined );
      test.is( _.errIs( err ) );
      return null;
    });
  })

  /* */

  .then( function( arg )
  {
    test.case = 'delay + consequence';
    var timeBefore = _.time.now();

    return _.time.outError( c.dt2, _.time.out( c.dt2 * 2 ) )
    .finally( function( err, got )
    {
      if( err )
      _.errAttend( err );
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt2 * 2-c.timeAccuracy );
      test.identical( got, undefined );
      test.is( _.errIs( err ) );
      return null;
    });

  })

  /* */

  .then( function( arg )
  {
    test.case = 'stop timer with dont';
    var timeBefore = _.time.now();

    var t = _.time.outError( c.dt2 );
    t.finally( function( err, got )
    {
      if( err )
      _.errAttend( err );
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt2 / 2 - c.timeAccuracy );
      test.identical( got, _.dont );
      test.is( !err );
      test.identical( t.resourcesGet().length, 0 );
      return null;
    })
    _.time.out( c.dt2 / 2, () => { t.take( _.dont ); return null; } );
    // _.time.out( c.dt2 / 2, () => { t.error( _.errAttend( 'stop' ) ); return null; } );

    return t;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'stop timer with dont, routine passed';
    var timeBefore = _.time.now();
    var called = false;

    var t = _.time.outError( c.dt2, () => { called = true } );
    t.finally( function( err, arg )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt2 / 2 - c.timeAccuracy );
      // test.identical( arg, _.dont );
      // test.identical( _.strHas( _.err( err ).message, 'stop' ), true );
      test.identical( err, undefined );
      test.identical( arg, _.dont );
      test.identical( called, false );
      test.identical( t.resourcesGet().length, 0 );
      return null;
    })

    _.time.out( c.dt2 / 2, () =>
    {
      t.take( _.dont );
      return null;
    });

    // _.time.out( c.dt2 / 2, () => { t.take( _.dont ); return null; } );
    // _.time.out( c.dt2 / 2, () => { t.error( _.errAttend( 'stop' ) ); return null; } );

    return t;
  })

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
  let ready = _.now();
  let visited = [];

  ready.then( () =>
  {

    let error;
    let con = _.time.outError( 1 ).tap( ( err, arg ) => error = _.errAttend( err ) );

    return _.time.out( 100, () =>
    {
      logger.log( error );
      test.identical( _.strCount( String( error ), 'Time.test.s' ), 3 );
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
  let ready = _.now();
  let visited = [];

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

let Self =
{

  name : 'Tools/consequence/Time',
  silencing : 1,
  enabled : 1,

  context : /* aaa xxx : minimize number of time parameters. too many of such */ /* Dmytro : minimized for module */
  {
    timeAccuracy : 1,
    dt1 : 10,
    dt2 : 400,
  },

  tests :
  {

    // tests

    sleep,

    //

    timeOutCancelInsideOfCallback,
    timeOutCancelOutsideOfCallback,
    timeOutCancelZeroDelayInsideOfCallback,
    timeOutCancelZeroDelayOutsideOfCallback,

    timeOut,
    timeOutMode01,
    timeOutMode10,
    timeOutMode11,
    timeOutError,
    asyncStackTimeOutError,
    asyncStackTimeOut,

  }

}

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
