( function _Time_test_s_()
{

'use strict';

/* xxx : remove the suite from tester */

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

  try
  {
    require( '../tester/entry/Main.s' );
  }
  catch( err )
  {
    _.include( 'wTesting' );
  }

  _.include( 'wConsequence' );

}

let _global = _global_;
let _ = _global_.wTools;

// --
// basic
// --

function _begin( test )
{
  let context = this;

  var onTime = () => 0;
  var onCancel = () => -1;
  var ready = new _testerGlobal_.wTools.Consequence().take( null );

  /* - */

  ready.finally( () =>
  {
    test.open( 'delay - Infinity' );
    return null;
  })

  .then( function()
  {
    test.case = 'without callbacks';
    var timer = _.time._begin( Infinity );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, undefined );
      test.identical( got.onCancel, undefined );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime';
    var timer = _.time._begin( Infinity, onTime );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, undefined );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, execute method time';
    var timer = _.time._begin( Infinity, onTime );
    timer.time();
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, undefined );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onCancel';
    var timer = _.time._begin( Infinity, undefined, onCancel );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, undefined );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onCancel, execute method cancel';
    var timer = _.time._begin( Infinity, undefined, onCancel );
    timer.cancel();
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer ) /* aaa : parametrize all time outs in the test suite */ /* Dmytro : add parametrized variables */
    .then( ( got ) =>
    {
      test.identical( got.onTime, undefined );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, -2 );
      test.identical( got.result, -1 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, onCancel';
    var timer = _.time._begin( Infinity, onTime, onCancel );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );

      return null;
    });
  })

  ready.finally( () =>
  {
    test.close( 'delay - Infinity' );
    return null;
  });

  /* - */

  ready.finally( () =>
  {
    test.open( 'delay - 0' );
    return null;
  })

  .then( function()
  {
    test.case = 'without callbacks';
    var timer = _.time._begin( 0 );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, undefined );
      test.identical( got.onCancel, undefined );
      test.identical( got.state, 2 );
      test.identical( got.result, undefined );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime';
    var timer = _.time._begin( 0, onTime );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, undefined );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, execute method time';
    var timer = _.time._begin( 0, onTime );
    timer.time()
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, undefined );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onCancel';
    var timer = _.time._begin( 0, undefined, onCancel );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, undefined );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, 2 );
      test.identical( got.result, undefined );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onCancel, execute method cancel';
    var timer = _.time._begin( 0, undefined, onCancel );
    timer.cancel();
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, undefined );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, -2 );
      test.identical( got.result, -1 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, onCancel';
    var timer = _.time._begin( 0, onTime, onCancel );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'only one execution';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
      }
    };

    var timer = _.time._begin( 0, onTime );
    return _testerGlobal_.wTools.time.out( context.dt3, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, undefined );
      test.identical( got.state, 2 );
      test.identical( got.result, undefined );
      test.identical( times, 4 );
      test.identical( result, [ 1 ] );

      return null;
    });
  })

  .finally( () =>
  {
    test.close( 'delay - 0' );
    return null;
  });

  /* - */

  ready.finally( () =>
  {
    test.open( 'delay > 0' );
    return null;
  })

  .then( function()
  {
    test.case = 'without callbacks, timeout < check time';
    var timer = _.time._begin( context.dt1/2 );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, undefined );
      test.identical( got.onCancel, undefined );
      test.identical( got.state, 2 );
      test.identical( got.result, undefined );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'without callbacks, timeout > check time';
    var timer = _.time._begin( context.dt3 );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, undefined );
      test.identical( got.onCancel, undefined );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, timeout < check time';
    var timer = _.time._begin( context.dt1/2, onTime );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, undefined );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, timeout > check time';
    var timer = _.time._begin( context.dt3, onTime );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, undefined );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, timeout > check time, execute method time';
    var timer = _.time._begin( context.dt3, onTime );
    timer.time()
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, undefined );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onCancel, timeout < check time';
    var timer = _.time._begin( context.dt1/2, undefined, onCancel );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, undefined );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, 2 );
      test.identical( got.result, undefined );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onCancel, timeout < check time, execute method cancel';
    var timer = _.time._begin( context.dt1/2, undefined, onCancel );
    timer.cancel();
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, undefined );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, -2 );
      test.identical( got.result, -1 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, onCancel, timeout < check time';
    var timer = _.time._begin( context.dt1/2, onTime, onCancel );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, onCancel, timeout > check time';
    var timer = _.time._begin( context.dt3, onTime, onCancel );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'only one execution';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
      }
    };

    var timer = _.time._begin( context.dt1/2, onTime );
    return _testerGlobal_.wTools.time.out( context.dt3, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, undefined );
      test.identical( got.state, 2 );
      test.identical( got.result, undefined );
      test.identical( times, 4 );
      test.identical( result, [ 1 ] );

      return null;
    });
  });

  ready.finally( ( err, arg ) =>
  {
    test.close( 'delay > 0' );

    if( err )
    throw err;
    return arg;
  });

  /* - */

  ready.then( () =>
  {
    test.case = 'executes method time twice, should throw error';
    var timer = _.time._begin( Infinity, onTime, onCancel );
    timer.time();

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.time() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });

    /* aaa2 : user should not call methods of timer | Dmytro : now the other concept is used, public methods can be used */

    /* aaa2 : test should ensure that there is no transitions from final states -2 either +2 to any another state. ask | Dmytro : timer not change state from state 2 to -2. State -2 changes to 2 if user call callback timer.time() */
  });

  ready.then( () =>
  {
    test.case = 'executes method cancel twice, should throw error';
    var timer = _.time._begin( Infinity, onTime, onCancel );
    timer.cancel();

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.cancel() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'executes method time and then method cancel, should throw error';
    var timer = _.time._begin( Infinity, onTime, onCancel );
    timer.time();

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.cancel() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'executes method time and then method cancel, should throw error';
    var timer = _.time._begin( Infinity, onTime, onCancel );
    timer.cancel();

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.time() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  /* */

  return ready;
}

//

function _beginTimerInsideOfCallback( test )
{
  let context = this;

  var onCancel = () => -1;
  var ready = new _testerGlobal_.wTools.Consequence().take( null );

  /* - */

  ready.then( () =>
  {
    test.case = 'single unlinked timer';
    var result = [];
    var onTime = () =>
    {
      result.push( 1 );
      _.time._begin( context.dt1, () => result.push( 2 ) );
      return 1;
    };
    var timer = _.time._begin( context.dt1, onTime );

    return _testerGlobal_.wTools.time.out( context.dt5, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, undefined );
      test.identical( got.state, 2 );
      test.identical( got.result, 1 );
      test.identical( result, [ 1, 2 ] );

      return null;
    });
  });

  /* - */

  ready.then( () =>
  {
    test.case = 'a periodical timer from simple timer';
    var result = [];
    var timer = _.time._begin( context.dt1, onTime );
    function onTime()
    {
      if( result.length < 3 )
      {
        result.push( 1 );
        timer = _.time._begin( context.dt1, onTime );
        return 1;
      }
      result.push( -1 );
      return -1;
    }

    return _testerGlobal_.wTools.time.out( context.dt5, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, undefined );
      test.identical( got.state, 2 );
      test.identical( got.result, -1 );
      test.identical( result, [ 1, 1, 1, -1 ] );

      return null;
    });
  });

  return ready;
}

//

function _finally( test )
{
  let context = this;

  var onTime = () => 0;
  var ready = new _testerGlobal_.wTools.Consequence().take( null );

  /* - */

  ready.finally( () =>
  {
    test.open( 'delay - Infinity' );
    return null;
  })

  .then( function()
  {
    test.case = 'without callbacks';
    var timer = _.time._finally( Infinity, undefined );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, undefined );
      test.identical( got.onCancel, undefined );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime';
    var timer = _.time._finally( Infinity, onTime );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, execute method time';
    var timer = _.time._finally( Infinity, onTime );
    timer.time()
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, execute method cancel';
    var timer = _.time._finally( Infinity, onTime );
    timer.cancel();
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, -2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  ready.finally( () =>
  {
    test.close( 'delay - Infinity' );
    return null;
  });

  /* - */

  ready.finally( () =>
  {
    test.open( 'delay - 0' );
    return null;
  })

  .then( function()
  {
    test.case = 'without callbacks';
    var timer = _.time._finally( 0, undefined );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, undefined );
      test.identical( got.onCancel, undefined );
      test.identical( got.state, 2 );
      test.identical( got.result, undefined );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime';
    var timer = _.time._finally( 0, onTime );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, execute method time';
    var timer = _.time._finally( 0, onTime );
    timer.time();
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, execute method cancel';
    var timer = _.time._finally( 0, onTime );
    timer.cancel();
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, -2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'only one execution';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
      }
    };

    var timer = _.time._finally( 0, onTime );
    return _testerGlobal_.wTools.time.out( context.dt3, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 2 );
      test.identical( got.result, undefined );
      test.identical( times, 4 );
      test.identical( result, [ 1 ] );

      return null;
    });
  })


  .finally( () =>
  {
    test.close( 'delay - 0' );
    return null;
  });

  /* - */

  ready.finally( () =>
  {
    test.open( 'delay > 0' );
    return null;
  })

  .then( function()
  {
    test.case = 'without callbacks, timeout < check time';
    var timer = _.time._finally( context.dt1/2, undefined );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, undefined );
      test.identical( got.onCancel, undefined );
      test.identical( got.state, 2 );
      test.identical( got.result, undefined );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'without callbacks, timeout > check time';
    var timer = _.time._finally( context.dt3, undefined );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, undefined );
      test.identical( got.onCancel, undefined );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, timeout < check time';
    var timer = _.time._finally( context.dt1/2, onTime );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, timeout > check time';
    var timer = _.time._finally( context.dt3, onTime );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, timeout > check time, execute method cancel';
    var timer = _.time._finally( context.dt3, onTime );
    timer.cancel();
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, -2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, timeout > check time';
    var timer = _.time._finally( context.dt3, onTime );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, timeout > check time, execute method time';
    var timer = _.time._finally( context.dt3, onTime );
    timer.time()
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'only one execution';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
      }
    };

    var timer = _.time._finally( 0, onTime );
    return _testerGlobal_.wTools.time.out( context.dt3, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 2 );
      test.identical( got.result, undefined );
      test.identical( times, 4 );
      test.identical( result, [ 1 ] );

      return null;
    });
  });

  ready.finally( ( err, arg ) =>
  {
    test.close( 'delay > 0' );

    if( err )
    throw err;
    return arg;
  });

  /* - */

  ready.then( () =>
  {
    test.case = 'executes method time twice, should throw error';
    var timer = _.time._finally( Infinity, onTime );
    timer.time();

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.time() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'executes method cancel twice, should throw error';
    var timer = _.time._finally( Infinity, onTime );
    timer.cancel();

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.cancel() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'executes method time and then method cancel, should throw error';
    var timer = _.time._finally( Infinity, onTime );
    timer.time();

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.cancel() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'executes method time and then method cancel, should throw error';
    var timer = _.time._finally( Infinity, onTime );
    timer.cancel();

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.time() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  /* */

  return ready;
}

//

function _periodic( test )
{
  let context = this;

  var onCancel = () => -1;
  var ready = new _testerGlobal_.wTools.Consequence().take( null );

  /* - */

  ready.finally( () =>
  {
    test.open( 'delay - 0' );
    return null;
  })

  .then( function()
  {
    test.case = 'onTime';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
        return true;
      }
      return undefined;
    };

    var timer = _.time._periodic( 0, onTime );
    return _testerGlobal_.wTools.time.out( context.dt4, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, undefined );
      test.identical( got.state, -2 );
      test.identical( got.result, undefined );
      test.identical( times, 0 );
      test.identical( result, [ 1, 1, 1, 1, 1 ] );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, execute onTime';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
        return true;
      }
      return _.dont;
    };

    var timer = _.time._periodic( 0, onTime );
    return _testerGlobal_.wTools.time.out( context.dt4, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, undefined );
      test.identical( got.state, -2 );
      test.identical( got.result, _.dont );
      test.identical( times, 0 );
      test.identical( result, [ 1, 1, 1, 1, 1 ] );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, onCancel';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
        return true;
      }
      return undefined;
    };

    var timer = _.time._periodic( 0, onTime, onCancel );
    return _testerGlobal_.wTools.time.out( context.dt4, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, -2 );
      test.identical( got.result, -1 );
      test.identical( times, 0 );
      test.identical( result, [ 1, 1, 1, 1, 1 ] );

      return null;
    });
  })

  .finally( () =>
  {
    test.close( 'delay - 0' );
    return null;
  });
  /* - */

  ready.finally( () =>
  {
    test.open( 'delay > 0' );
    return null;
  })

  .then( function()
  {
    test.case = 'onTime';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
        return true;
      }
    };

    var timer = _.time._periodic( context.dt1/2, onTime );
    return _testerGlobal_.wTools.time.out( context.dt4*2, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, undefined );
      test.is( got.state === -2 );
      test.identical( got.result, undefined );
      test.identical( times, 0 );
      test.identical( result, [ 1, 1, 1, 1, 1 ] );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, execute onTime';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
        return true;
      }
      return _.dont;
    };

    var timer = _.time._periodic( context.dt1/2, onTime );
    return _testerGlobal_.wTools.time.out( context.dt4*2, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, undefined );
      test.identical( got.state, -2 );
      test.identical( got.result, _.dont );
      test.identical( times, 0 );
      test.identical( result, [ 1, 1, 1, 1, 1 ] );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, onCancel';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
        return true;
      }
    };

    var timer = _.time._periodic( context.dt1/2, onTime, onCancel );
    return _testerGlobal_.wTools.time.out( context.dt4*2, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onCancel );
      test.is( got.state === -2 );
      test.identical( got.result, -1 );
      test.identical( times, 0 );
      test.identical( result, [ 1, 1, 1, 1, 1 ] );

      return null;
    });
  })

  /* - */

  ready.finally( ( err, arg ) =>
  {
    test.close( 'delay > 0' );

    if( err )
    throw err;
    return arg;
  });

  /* - */

  ready.then( () =>
  {
    test.case = 'executes method cancel twice, should throw error';
    var timer = _.time._periodic( 1000, () => 1, () => -1 );
    timer.cancel();

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.cancel() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'executes method time inside of method cancel, should throw error';
    var timer = _.time._periodic( 1000, () => 1, onCancel );
    function onCancel()
    {
      timer.time();
      return -1;
    };

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.cancel() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  /* */

  return ready;
}

//

function _cancel( test )
{
  let context = this;

  test.open( 'timer - _begin' );

  test.case = 'delay - Infinity';
  var timer = _.time._begin( Infinity );
  var got = _.time._cancel( timer );
  test.identical( got.onTime, undefined );
  test.identical( got.onCancel, undefined );
  test.identical( got.state, -2 );
  test.identical( got.result, undefined );

  test.case = 'delay - Infinity, onTime';
  var onTime = () => 0;
  var timer = _.time._begin( Infinity, onTime );
  var got = _.time._cancel( timer );
  test.identical( got.onTime, onTime );
  test.identical( got.onCancel, undefined );
  test.identical( got.state, -2 );
  test.identical( got.result, undefined );

  test.case = 'delay - Infinity, onCancel';
  var onCancel = () => -1;
  var timer = _.time._begin( Infinity, undefined, onCancel );
  var got = _.time._cancel( timer );
  test.identical( got.onTime, undefined );
  test.identical( got.onCancel, onCancel );
  test.identical( got.state, -2 );
  test.identical( got.result, -1 );

  test.case = 'delay - Infinity, onTime, onCancel';
  var onTime = () => 0;
  var onCancel = () => -1;
  var timer = _.time._begin( Infinity, onTime, onCancel );
  var got = _.time._cancel( timer );
  test.identical( got.onTime, onTime );
  test.identical( got.onCancel, onCancel );
  test.identical( got.state, -2 );
  test.identical( got.result, -1 );

  test.close( 'timer - _begin' );

  /* - */

  test.open( 'timer - _finally' );

  test.case = 'delay - Infinity';
  var timer = _.time._finally( Infinity, undefined );
  var got = _.time._cancel( timer );
  test.identical( got.onTime, undefined );
  test.identical( got.onCancel, undefined );
  test.identical( got.state, -2 );
  test.identical( got.result, undefined );

  test.case = 'delay - Infinity, onTime';
  var onTime = () => 0;
  var timer = _.time._finally( Infinity, onTime );
  var got = _.time._cancel( timer );
  test.identical( got.onTime, onTime );
  test.identical( got.onCancel, onTime );
  test.identical( got.state, -2 );
  test.identical( got.result, 0 );

  test.close( 'timer - _finally' );

  /* - */

  test.open( 'timer - _periodic' );

  test.case = 'delay - 0, onTime';
  var onTime = () => 0;
  var timer = _.time._periodic( context.dt6, onTime ) ;
  var got = _.time._cancel( timer );
  test.identical( got.onTime, onTime );
  test.identical( got.onCancel, undefined );
  test.identical( got.state, -2 );
  test.identical( got.result, undefined );

  test.case = 'delay - 0, onTime, onCancel';
  var onTime = () => 0;
  var onCancel = () => -1;
  var timer = _.time._periodic( context.dt6, onTime, onCancel ) ;
  var got = _.time._cancel( timer );
  test.identical( got.onTime, onTime );
  test.identical( got.onCancel, onCancel );
  test.identical( got.state, -2 );
  test.identical( got.result, -1 );

  test.close( 'timer - _periodic' );
}

//

function begin( test )
{
  let context = this;

  var onTime = () => 0;
  var onCancel = () => -1;
  var ready = new _testerGlobal_.wTools.Consequence().take( null );

  /* - */

  ready.finally( () =>
  {
    test.open( 'delay - Infinity' );
    return null;
  })

  .then( function()
  {
    test.case = 'onTime';
    var timer = _.time.begin( Infinity, onTime );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, null );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, execute method time';
    var timer = _.time.begin( Infinity, onTime );
    timer.time();
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, null );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onCancel';
    var timer = _.time.begin( Infinity, undefined, onCancel );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, null );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onCancel, execute method cancel';
    var timer = _.time.begin( Infinity, undefined, onCancel );
    timer.cancel();
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer ) /* aaa : parametrize all time outs in the test suite */ /* Dmytro : add parametrized variables */
    .then( ( got ) =>
    {
      test.identical( got.onTime, null );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, -2 );
      test.identical( got.result, -1 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, onCancel';
    var timer = _.time.begin( Infinity, onTime, onCancel );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );

      return null;
    });
  })

  ready.finally( () =>
  {
    test.close( 'delay - Infinity' );
    return null;
  });

  /* - */

  ready.finally( () =>
  {
    test.open( 'delay - 0' );
    return null;
  })

  .then( function()
  {
    test.case = 'onTime';
    var timer = _.time.begin( 0, onTime );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, null );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, execute method time';
    var timer = _.time.begin( 0, onTime );
    timer.time()
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, null );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onCancel';
    var timer = _.time.begin( 0, undefined, onCancel );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, null );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, 2 );
      test.identical( got.result, undefined );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onCancel, execute method cancel';
    var timer = _.time.begin( 0, undefined, onCancel );
    timer.cancel();
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, null );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, -2 );
      test.identical( got.result, -1 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, onCancel';
    var timer = _.time.begin( 0, onTime, onCancel );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'only one execution';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
      }
    };

    var timer = _.time.begin( 0, onTime );
    return _testerGlobal_.wTools.time.out( context.dt3, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, null );
      test.identical( got.state, 2 );
      test.identical( got.result, undefined );
      test.identical( times, 4 );
      test.identical( result, [ 1 ] );

      return null;
    });
  })

  .finally( () =>
  {
    test.close( 'delay - 0' );
    return null;
  });

  /* - */

  ready.finally( () =>
  {
    test.open( 'delay > 0' );
    return null;
  })

  .then( function()
  {
    test.case = 'onTime, timeout < check time';
    var timer = _.time.begin( context.dt1/2, onTime );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, null );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, timeout > check time';
    var timer = _.time.begin( context.dt3, onTime );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, null );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, timeout > check time, execute method time';
    var timer = _.time.begin( context.dt3, onTime );
    timer.time()
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, null );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onCancel, timeout < check time';
    var timer = _.time.begin( context.dt1/2, undefined, onCancel );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, null );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, 2 );
      test.identical( got.result, undefined );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onCancel, timeout < check time, execute method cancel';
    var timer = _.time.begin( context.dt1/2, undefined, onCancel );
    timer.cancel();
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, null );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, -2 );
      test.identical( got.result, -1 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, onCancel, timeout < check time';
    var timer = _.time.begin( context.dt1/2, onTime, onCancel );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, onCancel, timeout > check time';
    var timer = _.time.begin( context.dt3, onTime, onCancel );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'only one execution';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
      }
    };

    var timer = _.time.begin( context.dt1/2, onTime );
    return _testerGlobal_.wTools.time.out( context.dt3, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, null );
      test.identical( got.state, 2 );
      test.identical( got.result, undefined );
      test.identical( times, 4 );
      test.identical( result, [ 1 ] );

      return null;
    });
  });

  ready.finally( ( err, arg ) =>
  {
    test.close( 'delay > 0' );

    if( err )
    throw err;
    return arg;
  });

  /* - */

  ready.then( () =>
  {
    test.case = 'without arguments';
    return _testerGlobal_.wTools.time.out( 0, () => _.time.begin() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'not enough arguments';
    return _testerGlobal_.wTools.time.out( 0, () => _.time.begin( 0 ) )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'wrong type of onTime';
    return _testerGlobal_.wTools.time.out( 0, () => _.time.begin( 0, [] ) )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'wrong type of onCancel';
    return _testerGlobal_.wTools.time.out( 0, () => _.time.begin( 0, () => 1, [] ) )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'executes method time twice, should throw error';
    var timer = _.time.begin( Infinity, onTime, onCancel );
    timer.time();

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.time() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'executes method cancel twice, should throw error';
    var timer = _.time.begin( Infinity, onTime, onCancel );
    timer.cancel();

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.cancel() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'executes method time and then method cancel, should throw error';
    var timer = _.time.begin( Infinity, onTime, onCancel );
    timer.time();

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.cancel() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'executes method time and then method cancel, should throw error';
    var timer = _.time.begin( Infinity, onTime, onCancel );
    timer.cancel();

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.time() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  /* */

  return ready;
}

//

function beginWithProcedure( test )
{
  let context = this;

  var onTime = () => 0;
  var onCancel = () => -1;
  var ready = new _testerGlobal_.wTools.Consequence().take( null );

  /* - */

  ready.finally( () =>
  {
    test.open( 'delay - Infinity' );
    return null;
  })

  .then( function()
  {
    test.case = 'onTime';
    var procedure = _.Procedure( 5 );
    var timer = _.time.begin( Infinity, procedure, onTime );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( !procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, null );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );
      test.is( procedure.isFinited() );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, execute method time';
    var procedure = _.Procedure( 5 );
    var timer = _.time.begin( Infinity, procedure, onTime );
    timer.time();
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, null );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onCancel';
    var procedure = _.Procedure( 5 );
    var timer = _.time.begin( Infinity, procedure, undefined, onCancel );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( !procedure.isFinited() );
      test.identical( got.onTime, null );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );
      test.is( procedure.isFinited() );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onCancel, execute method cancel';
    var procedure = _.Procedure( 5 );
    var timer = _.time.begin( Infinity, procedure, undefined, onCancel );
    timer.cancel();
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, null );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, -2 );
      test.identical( got.result, -1 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, onCancel';
    var procedure = _.Procedure( 5 );
    var timer = _.time.begin( Infinity, procedure, onTime, onCancel );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( !procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );
      test.is( procedure.isFinited() );

      return null;
    });
  })

  ready.finally( () =>
  {
    test.close( 'delay - Infinity' );
    return null;
  });

  /* - */

  ready.finally( () =>
  {
    test.open( 'delay - 0' );
    return null;
  })

  .then( function()
  {
    test.case = 'onTime';
    var procedure = _.Procedure( 5 );
    var timer = _.time.begin( 0, procedure, onTime );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, null );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, execute method time';
    var procedure = _.Procedure( 5 );
    var timer = _.time.begin( 0, procedure, onTime );
    timer.time()
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, null );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onCancel';
    var procedure = _.Procedure( 5 );
    var timer = _.time.begin( 0, procedure, undefined, onCancel );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, null );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, 2 );
      test.identical( got.result, undefined );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onCancel, execute method cancel';
    var procedure = _.Procedure( 5 );
    var timer = _.time.begin( 0, procedure, undefined, onCancel );
    timer.cancel();
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, null );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, -2 );
      test.identical( got.result, -1 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, onCancel';
    var procedure = _.Procedure( 5 );
    var timer = _.time.begin( 0, procedure, onTime, onCancel );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'only one execution';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
      }
    };

    var procedure = _.Procedure( 5 );
    var timer = _.time.begin( 0, procedure, onTime );
    return _testerGlobal_.wTools.time.out( context.dt3, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, null );
      test.identical( got.state, 2 );
      test.identical( got.result, undefined );
      test.identical( times, 4 );
      test.identical( result, [ 1 ] );

      return null;
    });
  })

  .finally( () =>
  {
    test.close( 'delay - 0' );
    return null;
  });

  /* - */

  ready.finally( () =>
  {
    test.open( 'delay > 0' );
    return null;
  })

  .then( function()
  {
    test.case = 'onTime, timeout < check time';
    var procedure = _.Procedure( 5 );
    var timer = _.time.begin( context.dt1/2, procedure, onTime );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, null );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, timeout > check time';
    var procedure = _.Procedure( 5 );
    var timer = _.time.begin( context.dt3, procedure, onTime );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( !procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, null );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );
      test.is( procedure.isFinited() );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, timeout > check time, execute method time';
    var procedure = _.Procedure( 5 );
    var timer = _.time.begin( context.dt3, procedure, onTime );
    timer.time()
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, null );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onCancel, timeout < check time';
    var procedure = _.Procedure( 5 );
    var timer = _.time.begin( context.dt1/2, procedure, undefined, onCancel );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, null );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, 2 );
      test.identical( got.result, undefined );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onCancel, timeout < check time, execute method cancel';
    var procedure = _.Procedure( 5 );
    var timer = _.time.begin( context.dt1/2, procedure, undefined, onCancel );
    timer.cancel();
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, null );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, -2 );
      test.identical( got.result, -1 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, onCancel, timeout < check time';
    var procedure = _.Procedure( 5 );
    var timer = _.time.begin( context.dt1/2, procedure, onTime, onCancel );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, onCancel, timeout > check time';
    var procedure = _.Procedure( 5 );
    var timer = _.time.begin( context.dt3, procedure, onTime, onCancel );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( !procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );
      test.is( procedure.isFinited() );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'only one execution';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
      }
    };

    var procedure = _.Procedure( 5 );
    var timer = _.time.begin( context.dt1/2, procedure, onTime );
    return _testerGlobal_.wTools.time.out( context.dt3, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, null );
      test.identical( got.state, 2 );
      test.identical( got.result, undefined );
      test.identical( times, 4 );
      test.identical( result, [ 1 ] );

      return null;
    });
  });

  ready.finally( ( err, arg ) =>
  {
    test.close( 'delay > 0' );

    if( err )
    throw err;
    return arg;
  });

  /* - */

  ready.then( () =>
  {
    test.case = 'without arguments';
    return _testerGlobal_.wTools.time.out( 0, () => _.time.begin() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'not enough arguments';
    return _testerGlobal_.wTools.time.out( 0, () => _.time.begin( 0 ) )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'wrong type of onTime';
    return _testerGlobal_.wTools.time.out( 0, () => _.time.begin( 0, [] ) )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'wrong type of onCancel';
    return _testerGlobal_.wTools.time.out( 0, () => _.time.begin( 0, () => 1, [] ) )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'executes method time twice, should throw error';
    var timer = _.time.begin( Infinity, onTime, onCancel );
    timer.time();

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.time() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'executes method cancel twice, should throw error';
    var timer = _.time.begin( Infinity, onTime, onCancel );
    timer.cancel();

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.cancel() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'executes method time and then method cancel, should throw error';
    var timer = _.time.begin( Infinity, onTime, onCancel );
    timer.time();

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.cancel() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'executes method time and then method cancel, should throw error';
    var timer = _.time.begin( Infinity, onTime, onCancel );
    timer.cancel();

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.time() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  /* */

  return ready;
}

//

function beginTimerInsideOfCallback( test )
{
  let context = this;

  var onCancel = () => -1;
  var ready = new _testerGlobal_.wTools.Consequence().take( null );

  /* - */

  ready.then( () =>
  {
    test.case = 'single unlinked timer';
    var result = [];
    var onTime = () =>
    {
      result.push( 1 );
      _.time.begin( context.dt1, () => result.push( 2 ) );
      return 1;
    };
    var timer = _.time.begin( context.dt1, onTime );

    return _testerGlobal_.wTools.time.out( context.dt5, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, null );
      test.identical( got.state, 2 );
      test.identical( got.result, 1 );
      test.identical( result, [ 1, 2 ] );

      return null;
    });
  });

  /* - */

  ready.then( () =>
  {
    test.case = 'a periodical timer from simple timer';
    var result = [];
    var timer = _.time.begin( context.dt1, onTime );
    function onTime()
    {
      if( result.length < 3 )
      {
        result.push( 1 );
        timer = _.time.begin( context.dt1, onTime );
        return 1;
      }
      result.push( -1 );
      return -1;
    }

    return _testerGlobal_.wTools.time.out( context.dt5, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, null );
      test.identical( got.state, 2 );
      test.identical( got.result, -1 );
      test.identical( result, [ 1, 1, 1, -1 ] );

      return null;
    });
  });

  return ready;
}

//

function finally_( test )
{
  let context = this;

  var onTime = () => 0;
  var ready = new _testerGlobal_.wTools.Consequence().take( null );

  /* - */

  ready.finally( () =>
  {
    test.open( 'delay - Infinity' );
    return null;
  })

  .then( function()
  {
    test.case = 'without callbacks';
    var timer = _.time.finally( Infinity, undefined );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, null );
      test.identical( got.onCancel, null );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime';
    var timer = _.time.finally( Infinity, onTime );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, execute method time';
    var timer = _.time.finally( Infinity, onTime );
    timer.time()
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, execute method cancel';
    var timer = _.time.finally( Infinity, onTime );
    timer.cancel();
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, -2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  ready.finally( () =>
  {
    test.close( 'delay - Infinity' );
    return null;
  });

  /* - */

  ready.finally( () =>
  {
    test.open( 'delay - 0' );
    return null;
  })

  .then( function()
  {
    test.case = 'without callbacks';
    var timer = _.time.finally( 0, undefined );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, null );
      test.identical( got.onCancel, null );
      test.identical( got.state, 2 );
      test.identical( got.result, undefined );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime';
    var timer = _.time.finally( 0, onTime );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, execute method time';
    var timer = _.time.finally( 0, onTime );
    timer.time();
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, execute method cancel';
    var timer = _.time.finally( 0, onTime );
    timer.cancel();
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, -2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'only one execution';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
      }
    };

    var timer = _.time.finally( 0, onTime );
    return _testerGlobal_.wTools.time.out( context.dt3, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 2 );
      test.identical( got.result, undefined );
      test.identical( times, 4 );
      test.identical( result, [ 1 ] );

      return null;
    });
  })

  .finally( () =>
  {
    test.close( 'delay - 0' );
    return null;
  });

  /* - */

  ready.finally( () =>
  {
    test.open( 'delay > 0' );
    return null;
  })

  .then( function()
  {
    test.case = 'without callbacks, timeout < check time';
    var timer = _.time.finally( context.dt1/2, undefined );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, null );
      test.identical( got.onCancel, null );
      test.identical( got.state, 2 );
      test.identical( got.result, undefined );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'without callbacks, timeout > check time';
    var timer = _.time.finally( context.dt3, undefined );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, null );
      test.identical( got.onCancel, null );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, timeout < check time';
    var timer = _.time.finally( context.dt1/2, onTime );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, timeout > check time';
    var timer = _.time.finally( context.dt3, onTime );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, timeout > check time, execute method cancel';
    var timer = _.time.finally( context.dt3, onTime );
    timer.cancel();
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, -2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, timeout > check time';
    var timer = _.time.finally( context.dt3, onTime );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, timeout > check time, execute method time';
    var timer = _.time.finally( context.dt3, onTime );
    timer.time()
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'only one execution';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
      }
    };

    var timer = _.time.finally( 0, onTime );
    return _testerGlobal_.wTools.time.out( context.dt3, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 2 );
      test.identical( got.result, undefined );
      test.identical( times, 4 );
      test.identical( result, [ 1 ] );

      return null;
    });
  });

  ready.finally( ( err, arg ) =>
  {
    test.close( 'delay > 0' );

    if( err )
    throw err;
    return arg;
  });

  /* - */

  ready.then( () =>
  {
    test.case = 'without arguments';
    return _testerGlobal_.wTools.time.out( 0, () => _.time.finally() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'not enough arguments';
    return _testerGlobal_.wTools.time.out( 0, () => _.time.finally( 0 ) )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'wrong type of onTime';
    return _testerGlobal_.wTools.time.out( 0, () => _.time.finally( 0, [] ) )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'executes method time twice, should throw error';
    var timer = _.time.finally( Infinity, onTime );
    timer.time();

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.time() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'executes method cancel twice, should throw error';
    var timer = _.time.finally( Infinity, onTime );
    timer.cancel();

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.cancel() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'executes method time and then method cancel, should throw error';
    var timer = _.time.finally( Infinity, onTime );
    timer.time();

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.cancel() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'executes method time and then method cancel, should throw error';
    var timer = _.time.finally( Infinity, onTime );
    timer.cancel();

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.time() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  /* */

  return ready;
}

//

function finallyWithProcedure( test )
{
  let context = this;

  var onTime = () => 0;
  var ready = new _testerGlobal_.wTools.Consequence().take( null );

  /* - */

  debugger;
  ready.finally( () =>
  {
    test.open( 'delay - Infinity' );
    return null;
  })

  .then( function()
  {
    test.case = 'without callbacks';
    var procedure = _.Procedure( 5 );
    var timer = _.time.finally( Infinity, procedure, undefined );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( !procedure.isFinited() );
      test.identical( got.onTime, null );
      test.identical( got.onCancel, null );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );
      test.is( procedure.isFinited() );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime';
    var procedure = _.Procedure( 5 );
    var timer = _.time.finally( Infinity, procedure, onTime );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( !procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );
      test.is( procedure.isFinited() );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, execute method time';
    var procedure = _.Procedure( 5 );
    var timer = _.time.finally( Infinity, procedure, onTime );
    timer.time()
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, execute method cancel';
    var procedure = _.Procedure( 5 );
    var timer = _.time.finally( Infinity, procedure, onTime );
    timer.cancel();
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, -2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  ready.finally( () =>
  {
    test.close( 'delay - Infinity' );
    return null;
  });

  /* - */

  ready.finally( () =>
  {
    test.open( 'delay - 0' );
    return null;
  })

  .then( function()
  {
    test.case = 'without callbacks';
    var procedure = _.Procedure( 5 );
    var timer = _.time.finally( 0, procedure, undefined );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, null );
      test.identical( got.onCancel, null );
      test.identical( got.state, 2 );
      test.identical( got.result, undefined );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime';
    var procedure = _.Procedure( 5 );
    var timer = _.time.finally( 0, procedure, onTime );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, execute method time';
    var procedure = _.Procedure( 5 );
    var timer = _.time.finally( 0, procedure, onTime );
    timer.time();
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, execute method cancel';
    var procedure = _.Procedure( 5 );
    var timer = _.time.finally( 0, procedure,  onTime );
    timer.cancel();
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, -2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'only one execution';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
      }
    };

    var procedure = _.Procedure( 5 );
    var timer = _.time.finally( 0, procedure, onTime );
    return _testerGlobal_.wTools.time.out( context.dt3, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 2 );
      test.identical( got.result, undefined );
      test.identical( times, 4 );
      test.identical( result, [ 1 ] );

      return null;
    });
  })

  .finally( () =>
  {
    test.close( 'delay - 0' );
    return null;
  });

  /* - */

  ready.finally( () =>
  {
    test.open( 'delay > 0' );
    return null;
  })

  .then( function()
  {
    test.case = 'without callbacks, timeout < check time';
    var procedure = _.Procedure( 5 );
    var timer = _.time.finally( context.dt1/2, procedure, undefined );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, null );
      test.identical( got.onCancel, null );
      test.identical( got.state, 2 );
      test.identical( got.result, undefined );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'without callbacks, timeout > check time';
    var procedure = _.Procedure( 5 );
    var timer = _.time.finally( context.dt3, procedure, undefined );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( !procedure.isFinited() );
      test.identical( got.onTime, null );
      test.identical( got.onCancel, null );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );
      test.is( procedure.isFinited() );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, timeout < check time';
    var procedure = _.Procedure( 5 );
    var timer = _.time.finally( context.dt1/2, procedure, onTime );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, timeout > check time';
    var procedure = _.Procedure( 5 );
    var timer = _.time.finally( context.dt3, procedure, onTime );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( !procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );
      test.is( procedure.isFinited() );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, timeout > check time, execute method cancel';
    var procedure = _.Procedure( 5 );
    var timer = _.time.finally( context.dt3, procedure, onTime );
    timer.cancel();
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, -2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, timeout > check time';
    var procedure = _.Procedure( 5 );
    var timer = _.time.finally( context.dt3, procedure, onTime );
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( !procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 0 );
      test.identical( got.result, undefined );
      _.time.cancel( timer );
      test.is( procedure.isFinited() );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, timeout > check time, execute method time';
    var procedure = _.Procedure( 5 );
    var timer = _.time.finally( context.dt3, procedure, onTime );
    timer.time()
    return _testerGlobal_.wTools.time.out( context.dt1, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 2 );
      test.identical( got.result, 0 );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'only one execution';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
      }
    };

    var procedure = _.Procedure( 5 );
    var timer = _.time.finally( 0, procedure, onTime );
    return _testerGlobal_.wTools.time.out( context.dt3, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onTime );
      test.identical( got.state, 2 );
      test.identical( got.result, undefined );
      test.identical( times, 4 );
      test.identical( result, [ 1 ] );

      return null;
    });
  });

  ready.finally( ( err, arg ) =>
  {
    test.close( 'delay > 0' );

    if( err )
    throw err;
    return arg;
  });

  /* - */

  ready.then( () =>
  {
    test.case = 'without arguments';
    return _testerGlobal_.wTools.time.out( 0, () => _.time.finally() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'not enough arguments';
    return _testerGlobal_.wTools.time.out( 0, () => _.time.finally( 0 ) )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'wrong type of onTime';
    return _testerGlobal_.wTools.time.out( 0, () => _.time.finally( 0, [] ) )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'executes method time twice, should throw error';
    var timer = _.time.finally( Infinity, onTime );
    timer.time();

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.time() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'executes method cancel twice, should throw error';
    var timer = _.time.finally( Infinity, onTime );
    timer.cancel();

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.cancel() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'executes method time and then method cancel, should throw error';
    var timer = _.time.finally( Infinity, onTime );
    timer.time();

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.cancel() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'executes method time and then method cancel, should throw error';
    var timer = _.time.finally( Infinity, onTime );
    timer.cancel();

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.time() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  /* */

  return ready;
}

//

function periodic( test )
{
  let context = this;

  var onCancel = () => -1;
  var ready = new _testerGlobal_.wTools.Consequence().take( null );

  /* - */

  ready.finally( () =>
  {
    test.open( 'delay - 0' );
    return null;
  })

  .then( function()
  {
    test.case = 'onTime';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
        return true;
      }
      return undefined;
    };

    var timer = _.time.periodic( 0, onTime );
    return _testerGlobal_.wTools.time.out( context.dt4, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, null );
      test.identical( got.state, -2 );
      test.identical( got.result, undefined );
      test.identical( times, 0 );
      test.identical( result, [ 1, 1, 1, 1, 1 ] );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, execute onTime';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
        return true;
      }
      return _.dont;
    };

    var timer = _.time.periodic( 0, onTime );
    return _testerGlobal_.wTools.time.out( context.dt4, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, null );
      test.identical( got.state, -2 );
      test.identical( got.result, _.dont );
      test.identical( times, 0 );
      test.identical( result, [ 1, 1, 1, 1, 1 ] );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, onCancel';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
        return true;
      }
      return undefined;
    };

    var timer = _.time.periodic( 0, onTime, onCancel );
    return _testerGlobal_.wTools.time.out( context.dt4, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, -2 );
      test.identical( got.result, -1 );
      test.identical( times, 0 );
      test.identical( result, [ 1, 1, 1, 1, 1 ] );

      return null;
    });
  })

  .finally( () =>
  {
    test.close( 'delay - 0' );
    return null;
  });

  /* - */

  ready.finally( () =>
  {
    test.open( 'delay > 0' );
    return null;
  })

  .then( function()
  {
    test.case = 'onTime';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
        return true;
      }
    };

    var timer = _.time.periodic( context.dt1/2, onTime );
    return _testerGlobal_.wTools.time.out( context.dt4*2, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, null );
      test.is( got.state === -2 );
      test.identical( got.result, undefined );
      test.identical( times, 0 );
      test.identical( result, [ 1, 1, 1, 1, 1 ] );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, execute onTime';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
        return true;
      }
      return _.dont;
    };

    var timer = _.time.periodic( context.dt1/2, onTime );
    return _testerGlobal_.wTools.time.out( context.dt4*2, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, null );
      test.identical( got.state, -2 );
      test.identical( got.result, _.dont );
      test.identical( times, 0 );
      test.identical( result, [ 1, 1, 1, 1, 1 ] );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, onCancel';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
        return true;
      }
    };

    var timer = _.time.periodic( context.dt1/2, onTime, onCancel );
    return _testerGlobal_.wTools.time.out( context.dt4*2, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onCancel );
      test.is( got.state === -2 );
      test.identical( got.result, -1 );
      test.identical( times, 0 );
      test.identical( result, [ 1, 1, 1, 1, 1 ] );

      return null;
    });
  })

  /* - */

  ready.finally( ( err, arg ) =>
  {
    test.close( 'delay > 0' );

    if( err )
    throw err;
    return arg;
  });

  /* - */

  ready.then( () =>
  {
    test.case = 'without arguments';
    return _testerGlobal_.wTools.time.out( 0, () => _.time.periodic() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'not enough arguments';
    return _testerGlobal_.wTools.time.out( 0, () => _.time.periodic( 0 ) )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'wrong type of onTime';
    return _testerGlobal_.wTools.time.out( 0, () => _.time.periodic( 0, [] ) )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'wrong type of onCancel';
    return _testerGlobal_.wTools.time.out( 0, () => _.time.periodic( 0, () => 1, [] ) )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'executes method cancel twice, should throw error';
    var timer = _.time.periodic( 1000, () => 1, () => -1 );
    timer.cancel();

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.cancel() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'executes method time inside of method cancel, should throw error';
    var timer = _.time.periodic( 1000, () => 1, onCancel );
    function onCancel()
    {
      timer.time();
      return -1;
    };

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.cancel() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  /* */

  return ready;
}

//

function periodicWithProcedure( test )
{
  let context = this;

  var onCancel = () => -1;
  var ready = new _testerGlobal_.wTools.Consequence().take( null );

  /* - */

  ready.finally( () =>
  {
    test.open( 'delay - 0' );
    return null;
  })

  .then( function()
  {
    test.case = 'onTime';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
        return true;
      }
      return undefined;
    };

    var procedure = _.Procedure( 5 );
    var timer = _.time.periodic( 0, procedure, onTime );
    return _testerGlobal_.wTools.time.out( context.dt4, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, null );
      test.identical( got.state, -2 );
      test.identical( got.result, undefined );
      test.identical( times, 0 );
      test.identical( result, [ 1, 1, 1, 1, 1 ] );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, execute onTime';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
        return true;
      }
      return _.dont;
    };

    var procedure = _.Procedure( 5 );
    var timer = _.time.periodic( 0, procedure, onTime );
    return _testerGlobal_.wTools.time.out( context.dt4, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, null );
      test.identical( got.state, -2 );
      test.identical( got.result, _.dont );
      test.identical( times, 0 );
      test.identical( result, [ 1, 1, 1, 1, 1 ] );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, onCancel';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
        return true;
      }
      return undefined;
    };

    var procedure = _.Procedure( 5 );
    var timer = _.time.periodic( 0, procedure, onTime, onCancel );
    return _testerGlobal_.wTools.time.out( context.dt4, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onCancel );
      test.identical( got.state, -2 );
      test.identical( got.result, -1 );
      test.identical( times, 0 );
      test.identical( result, [ 1, 1, 1, 1, 1 ] );

      return null;
    });
  })

  .finally( () =>
  {
    test.close( 'delay - 0' );
    return null;
  });

  /* - */

  ready.finally( () =>
  {
    test.open( 'delay > 0' );
    return null;
  })

  .then( function()
  {
    test.case = 'onTime';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
        return true;
      }
    };

    var procedure = _.Procedure( 5 );
    var timer = _.time.periodic( context.dt1/2, procedure, onTime );
    return _testerGlobal_.wTools.time.out( context.dt4*2, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, null );
      test.is( got.state === -2 );
      test.identical( got.result, undefined );
      test.identical( times, 0 );
      test.identical( result, [ 1, 1, 1, 1, 1 ] );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, execute onTime';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
        return true;
      }
      return _.dont;
    };

    var procedure = _.Procedure( 5 );
    var timer = _.time.periodic( context.dt1/2, procedure, onTime );
    return _testerGlobal_.wTools.time.out( context.dt4*2, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, null );
      test.identical( got.state, -2 );
      test.identical( got.result, _.dont );
      test.identical( times, 0 );
      test.identical( result, [ 1, 1, 1, 1, 1 ] );

      return null;
    });
  })

  .then( function()
  {
    test.case = 'onTime, onCancel';
    var times = 5;
    var result = [];
    var onTime = () =>
    {
      if( times > 0 )
      {
        result.push( 1 );
        times--;
        return true;
      }
    };

    var procedure = _.Procedure( 5 );
    var timer = _.time.periodic( context.dt1/2, procedure, onTime, onCancel );
    return _testerGlobal_.wTools.time.out( context.dt4*2, () => timer )
    .then( ( got ) =>
    {
      test.identical( got.procedure, procedure );
      test.is( procedure.isFinited() );
      test.identical( got.onTime, onTime );
      test.identical( got.onCancel, onCancel );
      test.is( got.state === -2 );
      test.identical( got.result, -1 );
      test.identical( times, 0 );
      test.identical( result, [ 1, 1, 1, 1, 1 ] );

      return null;
    });
  })

  /* - */

  ready.finally( ( err, arg ) =>
  {
    test.close( 'delay > 0' );

    if( err )
    throw err;
    return arg;
  });

  /* - */

  ready.then( () =>
  {
    test.case = 'without arguments';
    return _testerGlobal_.wTools.time.out( 0, () => _.time.periodic() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'not enough arguments';
    return _testerGlobal_.wTools.time.out( 0, () => _.time.periodic( 0 ) )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'wrong type of onTime';
    return _testerGlobal_.wTools.time.out( 0, () => _.time.periodic( 0, [] ) )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'wrong type of onCancel';
    return _testerGlobal_.wTools.time.out( 0, () => _.time.periodic( 0, () => 1, [] ) )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'executes method cancel twice, should throw error';
    var timer = _.time.periodic( 1000, () => 1, () => -1 );
    timer.cancel();

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.cancel() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  ready.then( () =>
  {
    test.case = 'executes method time inside of method cancel, should throw error';
    var timer = _.time.periodic( 1000, () => 1, onCancel );
    function onCancel()
    {
      timer.time();
      return -1;
    };

    return _testerGlobal_.wTools.time.out( context.dt1, () => timer.cancel() )
    .finally( ( err, arg ) =>
    {
      if( arg )
      {
        test.is( false );
      }
      else
      {
        _.errAttend( err );
        test.is( true );
      }
      return null;
    });
  });

  /* */

  return ready;
}

//

function sleep( test )
{
  test.case = 'delay - 0';
  var start = _.time.now();
  _.time.sleep( 0 );
  var got = _.time.now() - start;
  test.is( 0 <= got && got <= 3 );

  test.case = 'delay - 1';
  var start = _.time.now();
  _.time.sleep( 1 );
  var got = _.time.now() - start;
  test.is( 1 <= got && got <= 4 );

  test.case = 'delay - 100';
  var start = _.time.now();
  _.time.sleep( 100 );
  var got = _.time.now() - start;
  test.is( 100 <= got && got <= 103 );

  test.case = 'delay - 2000';
  var start = _.time.now();
  _.time.sleep( 2000 );
  var got = _.time.now() - start;
  test.is( 2000 <= got && got <= 2004 );

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

//

function cancel( test )
{
  let context = this;

  test.open( 'timer - _begin' );

  test.case = 'delay - Infinity';
  var timer = _.time._begin( Infinity );
  var got = _.time.cancel( timer );
  test.identical( got.onTime, undefined );
  test.identical( got.onCancel, undefined );
  test.identical( got.state, -2 );
  test.identical( got.result, undefined );

  test.case = 'delay - Infinity, onTime';
  var onTime = () => 0;
  var timer = _.time._begin( Infinity, onTime );
  var got = _.time.cancel( timer );
  test.identical( got.onTime, onTime );
  test.identical( got.onCancel, undefined );
  test.identical( got.state, -2 );
  test.identical( got.result, undefined );

  test.case = 'delay - Infinity, onCancel';
  var onCancel = () => -1;
  var timer = _.time._begin( Infinity, undefined, onCancel );
  var got = _.time.cancel( timer );
  test.identical( got.onTime, undefined );
  test.identical( got.onCancel, onCancel );
  test.identical( got.state, -2 );
  test.identical( got.result, -1 );

  test.case = 'delay - Infinity, onTime, onCancel';
  var onTime = () => 0;
  var onCancel = () => -1;
  var timer = _.time._begin( Infinity, onTime, onCancel );
  var got = _.time.cancel( timer );
  test.identical( got.onTime, onTime );
  test.identical( got.onCancel, onCancel );
  test.identical( got.state, -2 );
  test.identical( got.result, -1 );

  test.close( 'timer - _begin' );

  /* - */

  test.open( 'timer - _finally' );

  test.case = 'delay - Infinity';
  var timer = _.time._finally( Infinity, undefined );
  var got = _.time.cancel( timer );
  test.identical( got.onTime, undefined );
  test.identical( got.onCancel, undefined );
  test.identical( got.state, -2 );
  test.identical( got.result, undefined );

  test.case = 'delay - Infinity, onTime';
  var onTime = () => 0;
  var timer = _.time._finally( Infinity, onTime );
  var got = _.time.cancel( timer );
  test.identical( got.onTime, onTime );
  test.identical( got.onCancel, onTime );
  test.identical( got.state, -2 );
  test.identical( got.result, 0 );

  test.close( 'timer - _finally' );

  /* - */

  test.open( 'timer - _periodic' );

  test.case = 'delay - 0, onTime';
  var onTime = () => 0;
  var timer = _.time._periodic( context.dt6, onTime ) ;
  var got = _.time.cancel( timer );
  test.identical( got.onTime, onTime );
  test.identical( got.onCancel, undefined );
  test.identical( got.state, -2 );
  test.identical( got.result, undefined );

  test.case = 'delay - 0, onTime, onCancel';
  var onTime = () => 0;
  var onCancel = () => -1;
  var timer = _.time._periodic( context.dt6, onTime, onCancel ) ;
  var got = _.time.cancel( timer );
  test.identical( got.onTime, onTime );
  test.identical( got.onCancel, onCancel );
  test.identical( got.state, -2 );
  test.identical( got.result, -1 );

  test.close( 'timer - _periodic' );
}

//

function timeOutCancelInsideOfCallback( test )
{
  let context = this;
  let visited = [];

  var timer = _.time.begin( 1, () =>
  {
    visited.push( 'v1' );
    debugger;
    _.time.cancel( timer );
    visited.push( 'v2' );
  });

  visited.push( 'v0' );

  return _.time.out( context.dt2*5 ).then( () =>
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

  var timer = _.time.begin( context.dt2, () =>
  {
    visited.push( 'v1' );
  });

  _.time.cancel( timer );
  visited.push( 'v0' );

  return _.time.out( context.dt2*5 ).then( () =>
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

  return _.time.out( context.dt2*5 ).then( () =>
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

  debugger;
  var timer = _.time.begin( 0, () =>
  {
    visited.push( 'v1' );
  });

  _.time.cancel( timer );
  visited.push( 'v0' );

  return _.time.out( context.dt2*5 ).then( () =>
  {
    test.identical( visited, [ 'v0' ] );
    return null;
  });
}

// --
// tests
// --

function timeOut( test )
{
  var c = this;
  var ready = new _.Consequence().take( null )

  /* */

  .then( function()
  {
    test.case = 'delay only';
    var timeBefore = _.time.now();
    return _.time.out( c.dt5 )
    .finally( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt5-c.timeAccuracy );
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
    return _.time.out( c.dt5, () => null )
    .finally( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt5-c.timeAccuracy );
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
    return _.time.out( c.dt5, () => value )
    .finally( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt5-c.timeAccuracy );
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
    return _.time.out( c.dt5, () => _.time.out( c.dt5 ) )
    .finally( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      // test.is( elapsedTime >= c.dt5 * 2 );
      test.ge( elapsedTime, 2 * c.dt5-c.timeAccuracy );
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
    return _.time.out( c.dt5, () => { _.time.out( c.dt5 ); return null } )
    .finally( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt5-c.timeAccuracy );
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
    return _.time.out( c.dt5, undefined, r, [ c.dt5 ] )
    .finally( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt5-c.timeAccuracy );
      test.identical( got, c.dt5 / 2 );
      test.identical( err, undefined );
      return null;
    });
  })

  /* */

  .then( function()
  {
    test.case = 'delay + consequence, first delay greater';
    var timeBefore = _.time.now();

    return _.time.out( c.dt5, _.time.out( c.dt5 * 2 ) )
    .finally( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      // test.is( elapsedTime >= c.dt5 * 2 );
      test.ge( elapsedTime, 2 * c.dt5-c.timeAccuracy );
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

    return _.time.out( c.dt5*3, _.time.out( c.dt5 * 2 ) )
    .finally( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      // test.is( elapsedTime >= c.dt5 * 2 );
      test.ge( elapsedTime, 3 * c.dt5-c.timeAccuracy );
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

    return _.time.out( c.dt5, () => _.time.out( c.dt5 * 2, () => val ) )
    .finally( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt5 * 3-c.timeAccuracy );
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

    return _.time.out( c.dt5, _.time.out( c.dt5 * 2, () => val ) )
    .finally( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt5 * 2-c.timeAccuracy );
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

    return _.time.out( c.dt5, _.time.out( c.dt5 * 2, () => _.time.out( c.dt5 * 2 ) ) )
    .finally( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt5 * 4-c.timeAccuracy );
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

    return _.time.out( c.dt5, _.time.out( c.dt5 * 2, () => { throw _.err( 'err' ) } ) )
    .finally( function( err, got )
    {
      if( err )
      _.errAttend( err );
      var elapsedTime = _.time.now() - timeBefore;
      // test.is( elapsedTime >= c.dt5 * 2 );
      test.ge( elapsedTime, 2 * c.dt5-c.timeAccuracy );
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

    var t = _.time.out( c.dt5 );
    t.finally( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt5 / 2 - c.timeAccuracy );
      // test.identical( _.strHas( _.err( err ).message, 'stop' ), true );
      // test.identical( got, undefined );
      test.identical( err, undefined );
      test.identical( got, _.dont );
      return null;
    })
    _.time.out( c.dt5 / 2, () =>
    {
      t.take( _.dont );
      return null;
    });
    // _.time.out( c.dt5 / 2, () => { t.take( _.dont ); return null; });
    // _.time.out( c.dt5 / 2, () => { t.error( _.errAttend( 'stop' ) ); return null; });

    return t;
  })

  /* */

  .then( function()
  {
    test.case = 'stop timer with error, routine passed';
    var timeBefore = _.time.now();
    var called = false;

    var t = _.time.out( c.dt5, () => { called = true } );
    t.finally( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt5 / 2 - c.timeAccuracy );
      // test.identical( got, undefined );
      // test.identical( _.strHas( _.err( err ).message, 'stop' ), true );
      test.identical( err, undefined );
      test.identical( got, _.dont );
      test.identical( called, false );
      return null;
    })
    _.time.out( c.dt5 / 2, () =>
    {
      t.take( _.dont );
      return null;
    });
    // _.time.out( c.dt5 / 2, () => { t.error( _.errAttend( 'stop' ) ); return null; });

    return t;
  })

  /* */

  .then( function()
  {
    test.case = 'stop after timeOut';
    var timeBefore = _.time.now();

    var t = _.time.out( c.dt5, () => null );
    t.give( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt5-c.timeAccuracy );
      test.identical( got, null );
      test.identical( err, undefined );
    });

    return _.time.out( c.dt5 + 50, function()
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

    var t = _.time.out( c.dt5, () => returnValue );

    return _.time.out( c.dt5 / 2, function()
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
        test.ge( elapsedTime, c.dt5-c.timeAccuracy );
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

    var t = _.time.out( c.dt5, () => { called = true } );
    t.finally( function( err, got )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt5 / 2 - c.timeAccuracy );
      // test.identical( got, undefined );
      // test.identical( _.strHas( _.err( err ).message, 'stop' ), true )
      test.identical( err, undefined );
      test.identical( got, _.dont );
      test.identical( called, false );
      return null;
    })
    _.time.out( c.dt5 / 2, () =>
    {
      t.take( _.dont );
      return null;
    });
    // _.time.out( c.dt5 / 2, () =>
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
    var t = _.time.out( c.dt5 );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 0 );
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt5 - c.timeAccuracy );
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
    var t = _.time.out( c.dt5, () => null );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt5-c.timeAccuracy );
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
    var t = _.time.out( c.dt5, () => value );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt5-c.timeAccuracy );
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
    var t = _.time.out( c.dt5, () => _.time.out( c.dt5 ) );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt5-c.timeAccuracy );
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
    var t = _.time.out( c.dt5, () => _.time.out( c.dt5 ) );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt5-c.timeAccuracy );
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
    var t = _.time.out( c.dt5, undefined, r, [ c.dt5 ] );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt5-c.timeAccuracy );
        test.identical( got, c.dt5 * 13 );
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
    var t = _.time.out( c.dt5 );

    // _.time.out( c.dt5 / 2, () => { t.error( _.errAttend( 'stop' ) ); return null; });
    _.time.out( c.dt5 / 2, () =>
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
        test.ge( elapsedTime, c.dt5 / 2 );
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

    var t = _.time.out( c.dt5, () => { called = true } );
    // _.time.out( c.dt5 / 2, () => { t.error( _.errAttend( 'stop' ) ); return null; });
    _.time.out( c.dt5 / 2, () =>
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
        test.ge( elapsedTime, c.dt5 / 2 );
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
    var t = _.time.out( c.dt5, () => null );

    var con = new _.Consequence();
    con.first( t );
    con.then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt5-c.timeAccuracy );
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

    return _.time.out( c.dt5 + 50, function()
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
    var t = _.time.out( c.dt5 );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt5-c.timeAccuracy );
        test.is( _.routineIs( got ) );
        test.is( err === undefined );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .timeOut( 1 )
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
    var t = _.time.out( c.dt5, () => null );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt5-c.timeAccuracy );
        test.identical( got, null );
        test.identical( err, undefined );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .timeOut( 1 )
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
    var t = _.time.out( c.dt5, () => value );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt5-c.timeAccuracy );
        test.is( got === value );
        test.identical( err, undefined );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .timeOut( 1 )
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
    var t = _.time.out( c.dt5, () => _.time.out( c.dt5 ) );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt5-c.timeAccuracy );
        test.is( _.routineIs( got ));
        test.identical( err, undefined );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .timeOut( 1 )
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
    var t = _.time.out( c.dt5, () => { _.time.out( c.dt5 ); return null; } );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt5-c.timeAccuracy );
        test.identical( got, null );
        test.identical( err, undefined );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .timeOut( 1 )
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
    var t = _.time.out( c.dt5, undefined, r, [ c.dt5 ] );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt5-c.timeAccuracy );
        test.is( got === c.dt5 / 2 );
        test.identical( err, undefined );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .timeOut( 1 )
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
    var t = _.time.out( c.dt5 );

    // _.time.out( c.dt5 / 2, () =>
    // {
    //   t.error( _.errAttend( 'stop' ) );
    //   return null;
    // });

    _.time.out( c.dt5 / 2, () =>
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
        test.ge( elapsedTime, c.dt5 / 2 );
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

    var t = _.time.out( c.dt5, () => { called = true } );
    // _.time.out( c.dt5 / 2, () => { t.error( _.errAttend( 'stop' ) ); return null; });

    _.time.out( c.dt5 / 2, () =>
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
        test.ge( elapsedTime, c.dt5 / 2 );
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
    var t = _.time.out( c.dt5, () => null );

    var con = new _.Consequence();
    con.first( t );
    con.then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt5-c.timeAccuracy );
        test.identical( got, null );
        test.identical( err, undefined );
      })
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .timeOut( 1 )
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
    .timeOut( 1 )
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
    var t = _.time.out( c.dt5 );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt5-c.timeAccuracy );
        test.is( _.routineIs( got ) );
        test.is( err === undefined );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .timeOut( 1 )
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
    var t = _.time.out( c.dt5, () => null );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt5-c.timeAccuracy );
        test.identical( got, null );
        test.identical( err, undefined );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .timeOut( 1 )
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
    var t = _.time.out( c.dt5, () => value );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt5-c.timeAccuracy );
        test.is( got === value );
        test.identical( err, undefined );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .timeOut( 1 )
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
    var t = _.time.out( c.dt5, () => _.time.out( c.dt5 ) );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt5-c.timeAccuracy );
        test.is( _.routineIs( got ));
        test.identical( err, undefined );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .timeOut( 1 )
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
    var t = _.time.out( c.dt5, () => { _.time.out( c.dt5 );return null; } );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt5-c.timeAccuracy );
        test.identical( got, null );
        test.identical( err, undefined );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .timeOut( 1 )
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
    var t = _.time.out( c.dt5, undefined, r, [ c.dt5 ] );
    return new _.Consequence().first( t )
    .then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt5-c.timeAccuracy );
        test.is( got === c.dt5 / 2 );
        test.identical( err, undefined );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .timeOut( 1 )
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
    var t = _.time.out( c.dt5 );

    // _.time.out( c.dt5 / 2, () => { t.error( _.errAttend( 'stop' ) ); return null; });
    _.time.out( c.dt5 / 2, () =>
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
        test.ge( elapsedTime, c.dt5 / 2 );
        // test.identical( got, undefined );
        // test.identical( _.strHas( _.err( err ).message, 'stop' ), true );;
        test.identical( err, undefined );
        test.identical( got, _.dont );
      });
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .timeOut( 1 )
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

    var t = _.time.out( c.dt5, () => { called = true; return null; } );
    // _.time.out( c.dt5 / 2, () => { t.error( _.errAttend( 'stop' ) ); return null; });
    _.time.out( c.dt5 / 2, () =>
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
        test.ge( elapsedTime, c.dt5 / 2 );
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
    .timeOut( 1 )
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
    var t = _.time.out( c.dt5, () => null );

    var con = new _.Consequence();
    con.first( t );
    con.then( function( arg )
    {
      t.give( function( err, got )
      {
        var elapsedTime = _.time.now() - timeBefore;
        test.ge( elapsedTime, c.dt5-c.timeAccuracy );
        test.identical( got, null );
        test.identical( err, undefined );
      })
      test.identical( t.resourcesGet().length, 1 );
      test.identical( t.competitorsEarlyGet().length, 1 );
      return null;
    })
    .timeOut( 1 )
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
    .timeOut( 1 )
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
    return _.time.outError( c.dt5 )
    .finally( function( err, got )
    {
      if( err )
      _.errAttend( err );
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt5-c.timeAccuracy );
      test.is( _.errIs( err ) );
      return null;
    });
  })

  /* */

  .then( function( arg )
  {
    test.case = 'delay + routine';
    var timeBefore = _.time.now();
    return _.time.outError( c.dt5, () => null )
    .finally( function( err, got )
    {
      if( err )
      _.errAttend( err );
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt5-c.timeAccuracy );
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
    return _.time.outError( c.dt5, () => value )
    .finally( function( err, got )
    {
      if( err )
      _.errAttend( err );
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt5-c.timeAccuracy );
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
    return _.time.outError( c.dt5, () => _.time.out( c.dt5 ) )
    .finally( function( err, got )
    {
      if( err )
      _.errAttend( err );
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, 2 * c.dt5-c.timeAccuracy );
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
    return _.time.outError( c.dt5, () => { _.time.out( c.dt5 ) } )
    .finally( function( err, got )
    {
      if( err )
      _.errAttend( err );
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt5-c.timeAccuracy );
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
    return _.time.outError( c.dt5, undefined, r, [ c.dt5 ] )
    .finally( function( err, got )
    {
      if( err )
      _.errAttend( err );
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt5-c.timeAccuracy );
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

    return _.time.outError( c.dt5, _.time.out( c.dt5 * 2 ) )
    .finally( function( err, got )
    {
      if( err )
      _.errAttend( err );
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt5 * 2-c.timeAccuracy );
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

    var t = _.time.outError( c.dt5 );
    t.finally( function( err, got )
    {
      if( err )
      _.errAttend( err );
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt5 / 2 - c.timeAccuracy );
      test.identical( got, _.dont );
      test.is( !err );
      test.identical( t.resourcesGet().length, 0 );
      return null;
    })
    _.time.out( c.dt5 / 2, () => { t.take( _.dont ); return null; } );
    // _.time.out( c.dt5 / 2, () => { t.error( _.errAttend( 'stop' ) ); return null; } );

    return t;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'stop timer with dont, routine passed';
    var timeBefore = _.time.now();
    var called = false;

    var t = _.time.outError( c.dt5, () => { called = true } );
    t.finally( function( err, arg )
    {
      var elapsedTime = _.time.now() - timeBefore;
      test.ge( elapsedTime, c.dt5 / 2 - c.timeAccuracy );
      // test.identical( arg, _.dont );
      // test.identical( _.strHas( _.err( err ).message, 'stop' ), true );
      test.identical( err, undefined );
      test.identical( arg, _.dont );
      test.identical( called, false );
      test.identical( t.resourcesGet().length, 0 );
      return null;
    })

    _.time.out( c.dt5 / 2, () =>
    {
      t.take( _.dont );
      return null;
    });

    // _.time.out( c.dt5 / 2, () => { t.take( _.dont ); return null; } );
    // _.time.out( c.dt5 / 2, () => { t.error( _.errAttend( 'stop' ) ); return null; } );

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

  name : 'Tools/Time/' + Math.floor( Math.random()*100000 ),
  silencing : 1,
  enabled : 1,

  context :
  {
    timeAccuracy : 1,
    dt1 : 10,
    dt2 : 25,
    dt3 : 100,
    dt4 : 200,
    dt5 : 400,
    dt6 : 1000,
  },

  tests :
  {

    // basic

    _begin,
    _beginTimerInsideOfCallback,
    _finally,
    _periodic,
    _cancel,
    begin,
    beginWithProcedure,
    beginTimerInsideOfCallback,
    finally : finally_,
    finallyWithProcedure,
    periodic,
    periodicWithProcedure,
    sleep,
    timeOutCancelInsideOfCallback,
    timeOutCancelOutsideOfCallback,
    timeOutCancelZeroDelayInsideOfCallback,
    timeOutCancelZeroDelayOutsideOfCallback,

    //

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
