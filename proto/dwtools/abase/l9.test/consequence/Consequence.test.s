( function _Consequence_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  var _ = require( '../../../../dwtools/Tools.s' );
  require( '../../l9/consequence/Consequence.s' );

  _.include( 'wTesting' );
  _.include( 'wLogger' );
  _.include( 'wProcess' );

}

var _global = _global_;
var _ = _global_.wTools;

// --
// inter
// --

function consequenceIs( test )
{
  test.case = 'instance of Consequence';
  var src = new _.Consequence().take( 0 );
  var got = _.consequenceIs( src );
  test.identical( got, true );
}

//

function consequenceLike( test )
{

  test.case = 'undefined';
  test.is( !_.consequenceLike() );

  test.case = 'map';
  test.is( !_.consequenceLike( {} ) );

  test.case = 'consequence';
  test.is( _.consequenceLike( new _.Consequence() ) );
  test.is( _.consequenceLike( _.Consequence() ) );

  test.case = 'consequecne with resource';
  var src = new _.Consequence().take( 0 );
  var got = _.consequenceLike( src );
  test.identical( got, true );

  test.case = 'promise';
  test.is( _.consequenceLike( Promise.resolve( 0 ) ) );
  var promise = new Promise( ( resolve, reject ) => { resolve( 0 ) } )
  test.is( _.consequenceLike( promise ) );
  test.is( _.consequenceLike( _.Consequence.From( promise ) ) );

}

//

function clone( test )
{
  var context = this;

  test.case = 'consequence with resource';
  var con1 = new _.Consequence({ tag : 'con1', capacity : 2 });
  con1.take( 'arg1' );
  var con2 = con1.clone();
  test.identical( con1.argumentsCount(), 1 );
  test.identical( con1.competitorsCount(), 0 );
  test.identical( con1.qualifiedName, 'Consequence::con1' );
  test.identical( con1.exportString({ verbosity : 1 }), 'Consequence::con1 1 / 0' );
  test.identical( con1.capacity, 2 );
  test.identical( con2.argumentsCount(), 1 );
  test.identical( con2.competitorsCount(), 0 );
  test.identical( con2.qualifiedName, 'Consequence::con1' );
  test.identical( con2.exportString({ verbosity : 1 }), 'Consequence::con1 1 / 0' );
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
  test.identical( con1.qualifiedName, 'Consequence::con1' );
  test.identical( con1.exportString({ verbosity : 1 }), 'Consequence::con1 0 / 1' );
  test.identical( con1.capacity, 2 );
  test.identical( con2.argumentsCount(), 0 );
  test.identical( con2.competitorsCount(), 0 );
  test.identical( con2.qualifiedName, 'Consequence::con1' );
  test.identical( con2.exportString({ verbosity : 1 }), 'Consequence::con1 0 / 0' );
  test.identical( con2.capacity, 2 );
  test.is( con1._resources !== con2._resources );
  test.is( con1._competitorsEarly !== con2._competitorsEarly );
  test.is( con1._competitorsLate !== con2._competitorsLate );

  test.identical( _.Procedure.Filter( f ).length, 1 );
  con2.cancel();
  test.identical( _.Procedure.Filter( f ).length, 1 );
  con1.cancel();
  test.identical( _.Procedure.Filter( f ).length, 0 );

}

// --
// from
// --

function fromAsyncMode00( test )
{
  let context = this;
  let testMsg = 'value';
  let amode = _.Consequence.AsyncModeGet();
  let ready = new _.Consequence().take( null )

  /* */

  .finally( () =>
  {
    _.Consequence.AsyncModeSet([ 0, 0 ]);
    test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );
    return null;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passing value';
    var con = _.Consequence.From( testMsg );
    test.identical( con.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
    test.identical( con.competitorsCount(), 0 );
    return con;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passing an error';
    var err = _.errAttend( testMsg );
    var con = _.Consequence.From( err );
    test.identical( con.resourcesGet(), [ { error : err, argument : undefined } ] );
    test.identical( con.competitorsCount(), 0 );
    return con.finally( () => null );
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passing consequence';
    var src = new _.Consequence().take( testMsg );
    var con = _.Consequence.From( src );
    test.identical( con, src );
    test.identical( con.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
    test.identical( con.competitorsCount(), 0 );
    return con;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passing resolved promise';
    var src = Promise.resolve( testMsg );
    var con = _.Consequence.From( src );
    return _.time.out( 1, function()
    {
      test.identical( con.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passing rejected promise';
    var src = Promise.reject( testMsg );
    var con = _.Consequence.From( src );
    return _.time.out( 1, function()
    {
        test.is( _.strHas( String( con.errorsGet()[ 0 ] ), testMsg ) );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'sync, resolved promise, timeout';
    var src = Promise.resolve( testMsg );
    var con = _.Consequence.From( src, context.t1*5 );
    con.give( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.competitorsCount(), 3 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    return _.time.out( 1, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 0 )
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'sync, promise resolved with timeout';
    var src = new Promise( ( resolve ) =>
    {
      setTimeout( () => resolve( testMsg ), context.t1*2 );
    })
    var con = _.Consequence.From( src, context.t1 );
    con.finally( ( err, got ) =>
    {
      test.is( _.errIs( err ) );
      if( err )
      _.errAttend( err );
      if( err )
      throw err;
    });
    test.identical( con.competitorsCount(), 3 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    return _.time.out( context.t1*3, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'sync, timeout, src is a consequence';
    var con = new _.Consequence({ tag : 'con' }).take( testMsg );
    con = _.Consequence.From( con , context.t1 );
    con.give( ( err, got ) =>
    {
      test.identical( got, testMsg );
    });
    test.identical( con.competitorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    return null;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'sync, timeout, src is a consequence';
    var con = _.time.out( context.t1*2, () => testMsg );
    con.tag = 'con1';
    con = _.Consequence.From( con , context.t1 );
    con.tag = 'con2';
    con.give( ( err, got ) =>
    {
      test.is( _.errIs( err ) );
      if( err )
      _.errAttend( err );
    });
    test.identical( con.competitorsCount(), 3 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    return _.time.out( context.t1*3, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
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

  /* */

  return ready;
}

fromAsyncMode00.timeOut = 30000;

//

function fromAsyncMode10( test )
{
  var testMsg = 'value';
  let amode = _.Consequence.AsyncModeGet();
  let ready = new _.Consequence().take( null )

  /* */

  .finally( () =>
  {
    _.Consequence.AsyncModeSet([ 1, 0 ]);
    test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );
    return null;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'async competitors adding, passing value';
    var con = _.Consequence.From( testMsg );
    con.give( ( err, got ) => test.identical( got, testMsg ) )
    test.identical( con.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
    test.identical( con.competitorsCount(), 1 );
    return _.time.out( 1, function()
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })

    return con;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'async competitors adding, passing an error';
    var src = _.errAttend( testMsg );
    var con = _.Consequence.From( src );
    con.give( ( err, got ) => test.is( err === src ) );
    test.identical( con.resourcesGet(), [ { error : src, argument : undefined } ] );
    test.identical( con.competitorsCount(), 1 );
    return _.time.out( 1, function()
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })

    return con;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'async competitors adding, passing consequence';
    var src = new _.Consequence().take( testMsg );
    var con = _.Consequence.From( src );
    con.give( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( src.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
    test.identical( con.competitorsCount(), 1 );
    test.identical( con, src );
    return _.time.out( 1, function()
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })

    return con;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'async competitors adding, passing resolved promise';
    var src = Promise.resolve( testMsg );
    var con = _.Consequence.From( src );
    con.give( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.competitorsCount(), 1 );
    test.identical( con.resourcesCount(), 0 )
    return _.time.out( 1, function()
    {
      test.identical( con.resourcesCount(), 0 )
      test.identical( con.competitorsCount(), 0 )
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'async competitors adding, passing rejected promise';
    var src = Promise.reject( testMsg );
    var con = _.Consequence.From( src );
    con.give( ( err, got ) => test.is( _.strHas( String( err ), testMsg ) ) );
    test.identical( con.competitorsCount(), 1 );
    test.identical( con.resourcesCount(), 0 )
    return _.time.out( 1, function()
    {
      test.identical( con.resourcesCount(), 0 )
      test.identical( con.competitorsCount(), 0 )
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
  return ready;
}

//

function fromAsyncMode01( test )
{
  var testMsg = 'value';
  let amode = _.Consequence.AsyncModeGet();
  let ready = new _.Consequence().take( null )

  /* */

  .finally( () =>
  {
    _.Consequence.AsyncModeSet([ 0, 1 ]);
    test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );
    return null;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'async resources adding passing value';
    var con = _.Consequence.From( testMsg );
    test.identical( con.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
    con.give( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.resourcesGet(), [] );
    return _.time.out( 1, function()
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })

    return con;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passing an error';
    var src = _.errAttend( testMsg );
    var con = _.Consequence.From( src );
    test.identical( con.resourcesGet(), [ { error : src, argument : undefined } ] );
    // con.give( ( err, got ) => test.is( _.strHas( String( err ), src ) ) );
    con.give( ( err, got ) => test.is( err === src ) );
    test.identical( con.resourcesGet(), [] );
    return _.time.out( 1, function()
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })

    return con;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passing consequence';
    var src = new _.Consequence().take( testMsg );
    var con = _.Consequence.From( src );
    test.identical( src.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
    con.give( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( src.resourcesGet(), [] );
    test.identical( con, src );
    return _.time.out( 1, function()
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })

    return con;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passing resolved promise';
    var src = Promise.resolve( testMsg );
    var con = _.Consequence.From( src );
    con.give( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.resourcesCount(), 0 )
    return _.time.out( 1, function()
    {
      test.identical( con.resourcesCount(), 0 )
      test.identical( con.competitorsCount(), 0 )
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passing rejected promise';
    var src = Promise.reject( testMsg );
    var con = _.Consequence.From( src );
    con.give( ( err, got ) => test.is( _.strHas( String( err ), testMsg ) ) );
    test.identical( con.resourcesCount(), 0 )
    return _.time.out( 1, function()
    {
      test.identical( con.resourcesCount(), 0 )
      test.identical( con.competitorsCount(), 0 )
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
  return ready;
}

//

function fromAsyncMode11( test )
{
  var testMsg = 'value';
  let amode = _.Consequence.AsyncModeGet();
  let ready = new _.Consequence().take( null )

  /* */

  .finally( () =>
  {
    _.Consequence.AsyncModeSet([ 1, 1 ]);
    test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );
    return null;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'async, passing value';
    var con = _.Consequence.From( testMsg );
    con.give( ( err, got ) => test.identical( got, testMsg ) )
    test.identical( con.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
    test.identical( con.competitorsCount(), 1 );
    return _.time.out( 1, function()
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })

    return con;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'async, passing an error';
    var src = _.errAttend( testMsg );
    var con = _.Consequence.From( src );
    con.give( ( err, got ) => test.is( err === src ) );
    test.identical( con.resourcesGet(), [ { error : src, argument : undefined } ] );
    test.identical( con.competitorsCount(), 1 );
    return _.time.out( 1, function()
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })

    return con;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'async, passing consequence';
    var src = new _.Consequence().take( testMsg );
    var con = _.Consequence.From( src );
    con.give( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( src.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
    test.identical( con.competitorsCount(), 1 );
    test.identical( con, src );
    return _.time.out( 1, function()
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })

    return con;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'async, passing resolved promise';
    var src = Promise.resolve( testMsg );
    var con = _.Consequence.From( src );
    con.give( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.competitorsCount(), 1 );
    test.identical( con.resourcesCount(), 0 )
    return _.time.out( 1, function()
    {
      test.identical( con.resourcesCount(), 0 )
      test.identical( con.competitorsCount(), 0 )
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'async, passing rejected promise';
    var src = Promise.reject( testMsg );
    var con = _.Consequence.From( src );
    con.give( ( err, got ) => test.is( _.strHas( String( err ), testMsg ) ) );
    test.identical( con.competitorsCount(), 1 );
    test.identical( con.resourcesCount(), 0 )
    return _.time.out( 1, function()
    {
      test.identical( con.resourcesCount(), 0 )
      test.identical( con.competitorsCount(), 0 )
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
  return ready;
}

//

function fromPromiseWithUndefined( test )
{
  let ready = new _.Consequence().take( null );

  ready.then( () =>
  {

    test.case = 'convert promise with undefined to consequence';
    return _.Consequence.From( Promise.resolve( undefined ) )
    .then( ( got ) =>
    {
      test.identical( got, null )
      return null;
    })

  });

  return ready;
}

//

function fromCustomPromise( test )
{
  class CustomPromise extends Promise {}
  let ready = new _.Consequence().take( null );

  ready.then( () =>
  {
    test.case = 'convert regular promise to consequence';
    return _.Consequence.From( Promise.resolve( 1 ) )
    .then( ( got ) =>
    {
      test.identical( got, 1 )
      return null;
    })
  })

  ready.then( () =>
  {
    test.case = 'convert custom promise to consequence';
    return _.Consequence.From( CustomPromise.resolve( 1 ) )
    .then( ( got ) =>
    {
      test.identical( got, 1 )
      return null;
    })
  })

  ready.then( () =>
  {
    test.case = 'return regular promise as value';
    let con = new _.Consequence().take( null );
    con.then( () =>
    {
      return Promise.resolve( 2 )
    })
    .then( ( got ) =>
    {
      test.identical( got, 2 )
      return null;
    })
    return con;
  })

  ready.then( () =>
  {
    test.case = 'return custom promise as value';
    let con = new _.Consequence().take( null );
    con.then( () =>
    {
      return CustomPromise.resolve( 2 )
    })
    .then( ( got ) =>
    {
      test.identical( got, 2 )
      return null;
    })
    return con;
  })

  ready.then( () =>
  {
    test.case = 'convert custom promise to regular promise and return as value';
    let con = new _.Consequence().take( null );
    con.then( () =>
    {
      return Promise.resolve( CustomPromise.resolve( 3 ) );
    })
    .then( ( got ) =>
    {
      test.identical( got, 3 )
      return null;
    })
    return con;
  })

  return ready;
}

//

function consequenceAwait( test )
{
  let context = this;
  let ready = new _.Consequence().take( null );

  ready.then( () => case1() )
  ready.then( () => case2() )
  ready.then( () => case3() )

  /* */

  return ready;

  /* */

  async function case1()
  {
    test.case = 'resolved con'
    let got = await new _.Consequence().take( 1 );
    test.identical( got, 1 );
    return true;
  }

  async function case2()
  {
    test.case = 'timeout return con resolved after 1sec'
    let t1 = _.time.now();
    let got = await _.time.out( context.t1*2, () => 1 );
    let t2 = _.time.now();
    test.ge( t2 - t1, context.t1*2 );
    test.identical( got, 1 );
    return true;
  }

  function case3()
  {
    test.case = 'con with error, await should return promise with error'
    let f = async () => await new _.Consequence().error( 'Some error' )
    return test.shouldThrowErrorAsync( () => _.Consequence.From( f() ) )
  }

}

// --
// export
// --

function toStr( test )
{

  act( 'toStr' );
  act( 'toString' );

  function act( rname )
  {

    test.open( 'verbosity:2' );
    {

      /* */

      test.case = 'empty';
      var con1 = _.Consequence();
      var exp =
`Consequence::
  argument resources : 0
  error resources : 0
  early competitors : 0
  late competitors : 0`;
      var got = con1[ rname ]({ verbosity : 2 });
      test.identical( got, exp );

      /* */

      test.case = 'tagged';
      var con1 = _.Consequence({ tag : 'con1' });
      var exp =
`Consequence::con1
  argument resources : 0
  error resources : 0
  early competitors : 0
  late competitors : 0`;
      var got = con1[ rname ]({ verbosity : 2 });
      test.identical( got, exp );

      /* */

      test.case = 'has compatitor';
      var con1 = _.Consequence().then( () => null );
      var exp =
`Consequence::
  argument resources : 0
  error resources : 0
  early competitors : 1
  late competitors : 0`;
      var got = con1[ rname ]({ verbosity : 2 });
      test.identical( got, exp );
      con1.take( null );

      /* */

      test.case = 'has argument';
      var con1 = _.Consequence().take( null );
      var exp =
`Consequence::
  argument resources : 1
  error resources : 0
  early competitors : 0
  late competitors : 0`;
      var got = con1[ rname ]({ verbosity : 2 });
      test.identical( got, exp );

      /* */

      test.case = 'has error';
      var con1 = _.Consequence().error( _.errAttend( 'error1' ) );
      var exp =
`Consequence::
  argument resources : 0
  error resources : 1
  early competitors : 0
  late competitors : 0`;
      var got = con1[ rname ]({ verbosity : 2 });
      test.identical( got, exp );

      /* */

    }
    test.close( 'verbosity:2' );
    test.open( 'verbosity:1' );
    {

      /* */

      test.case = 'empty';
      var con1 = _.Consequence();
      var exp = 'Consequence:: 0 / 0';
      var got = con1[ rname ]({ verbosity : 1 });
      test.identical( got, exp );

      /* */

      test.case = 'tagged';
      var con1 = _.Consequence({ tag : 'con1' });
      var exp = 'Consequence::con1 0 / 0';
      var got = con1[ rname ]({ verbosity : 1 });
      test.identical( got, exp );

      /* */

      test.case = 'has compatitor';
      var con1 = _.Consequence().then( () => null );
      var exp = 'Consequence:: 0 / 1';
      var got = con1[ rname ]({ verbosity : 1 });
      test.identical( got, exp );
      con1.take( null );

      /* */

      test.case = 'has argument';
      var con1 = _.Consequence().take( null );
      var exp = 'Consequence:: 1 / 0';
      var got = con1[ rname ]({ verbosity : 1 });
      test.identical( got, exp );

      /* */

      test.case = 'has error';
      var con1 = _.Consequence().error( _.errAttend( 'error1' ) );
      var exp = 'Consequence:: 1 / 0';
      var got = con1[ rname ]({ verbosity : 1 });
      test.identical( got, exp );

      /* */

    }
    test.close( 'verbosity:1' );
    test.open( 'no arguments' );
    {

      /* */

      test.case = 'empty';
      var con1 = _.Consequence();
      var exp = 'Consequence:: 0 / 0';
      var got = con1[ rname ]();
      test.identical( got, exp );

      /* */

      test.case = 'tagged';
      var con1 = _.Consequence({ tag : 'con1' });
      var exp = 'Consequence::con1 0 / 0';
      var got = con1[ rname ]();
      test.identical( got, exp );

      /* */

      test.case = 'has compatitor';
      var con1 = _.Consequence().then( () => null );
      var exp = 'Consequence:: 0 / 1';
      var got = con1[ rname ]();
      test.identical( got, exp );
      con1.take( null );

      /* */

      test.case = 'has argument';
      var con1 = _.Consequence().take( null );
      var exp = 'Consequence:: 1 / 0';
      var got = con1[ rname ]();
      test.identical( got, exp );

      /* */

      test.case = 'has error';
      var con1 = _.Consequence().error( _.errAttend( 'error1' ) );
      var exp = 'Consequence:: 1 / 0';
      var got = con1[ rname ]();
      test.identical( got, exp );

      /* */

    }
    test.close( 'no arguments' );

  }

}

//

function stringify( test )
{

  /* */

  test.case = 'empty';
  var con1 = _.Consequence();
  var exp = 'Consequence:: 0 / 0';
  var got = String( con1 );
  test.identical( got, exp );

  /* */

  test.case = 'tagged';
  var con1 = _.Consequence({ tag : 'con1' });
  var exp = 'Consequence::con1 0 / 0';
  var got = String( con1 );
  test.identical( got, exp );

  /* */

  test.case = 'has compatitor';
  var con1 = _.Consequence().then( () => null );
  var exp = 'Consequence:: 0 / 1';
  var got = String( con1 );
  test.identical( got, exp );
  con1.take( null );

  /* */

  test.case = 'has argument';
  var con1 = _.Consequence().take( null );
  var exp = 'Consequence:: 1 / 0';
  var got = String( con1 );
  test.identical( got, exp );

  /* */

  test.case = 'has error';
  var con1 = _.Consequence().error( _.errAttend( 'error1' ) );
  var exp = 'Consequence:: 1 / 0';
  var got = String( con1 );
  test.identical( got, exp );

  /* */

}

// --
// etc
// --

function trivial( test )
{
  var context = this;

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
  test.identical( con1.resourcesCount(), 1 );
  test.identical( con2.resourcesCount(), 1 );
  test.identical( con3.resourcesCount(), 1 );

  /* */

  test.case = 'class test';
  test.is( _.consequenceIs( con1 ) );
  test.is( _.consequenceIs( con2 ) );
  test.is( _.consequenceIs( con3 ) );

  con3.take( 3 );
  con3( 4 );
  con3( 5 );

  con3.give( ( err, arg ) => test.identical( arg, 2 ) );
  con3.give( ( err, arg ) => test.identical( arg, 3 ) );
  con3.give( ( err, arg ) => test.identical( arg, 4 ) );
  con3.finally( ( err, arg ) => test.identical( con3.resourcesCount(), 0 ) );

  return con3;
}

//

function fields( test )
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
  test.identical( con2._resources.length, 1 );
  test.identical( con2._competitorsEarly.length, 0 );

}

// --
// take
// --

function ordinarResourceAsyncMode00( test )
{
  let context = this;
  let amode = _.Consequence.AsyncModeGet();
  let ready = new _.Consequence().take( null )

  /* */

  .finally( () =>
  {
    test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );

    test.case = 'single resource';
    _.Consequence.AsyncModeSet([ 0, 0 ]);
    return null;
  })
  .then( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    con.take( 1 );
    test.identical( con.resourcesCount(), 1 );
    con.give( function( err, got )
    {
      test.identical( err, undefined )
      test.identical( got, 1 );
    })
    test.identical( con.resourcesCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    return null;
  })

  /* */

  .finally( () =>
  {
    test.case = 'several resources';
    return null;
  })
  .then( function( arg )
  {
    var con = new _.Consequence({ tag : 'con', capacity : 3 });
    con.take( 1 ).take( 2 ).take( 3 );
    test.identical( con.resourcesCount(), 3 );
    con.give( ( err, got ) => test.identical( got, 1 ) );
    con.give( ( err, got ) => test.identical( got, 2 ) );
    con.give( ( err, got ) => test.identical( got, 3 ) );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con.resourcesCount(), 0 );
    return null;
  })

  /* */

  .finally( () =>
  {
    test.case = 'single error';
    return null;
  })
  .then( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    con.error( _.errAttend( 'err' ) );
    test.identical( con.resourcesCount(), 1 );
    con.give( function( err, got )
    {
      test.is( !!err );
      test.identical( got, undefined );
    })
    test.identical( con.resourcesCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    return null;
  })

  /* */

  .finally( () =>
  {
    test.case = 'several error'
    return null;
  })
  .then( function( arg )
  {
    var con = new _.Consequence({ tag : 'con', capacity : 3 });
    con.error( _.errAttend( 'err1' ) ).error( _.errAttend( 'err2' ) ).error( _.errAttend( 'err3' ) );
    test.identical( con.resourcesCount(), 3 );
    con.give( ( err, got ) => test.is( !!err ) );
    con.give( ( err, got ) => test.is( !!err ) );
    con.give( ( err, got ) => test.is( !!err ) );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con.resourcesCount(), 0 );
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
  return ready;
}

//

function ordinarResourceAsyncMode10( test )
{
  let context = this;
  let amode = _.Consequence.AsyncModeGet();
  let ready = new _.Consequence().take( null )

  /* */

  .finally( () =>
  {
    test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );

    test.case = 'single resource';
    _.Consequence.AsyncModeSet([ 1, 0 ]);
    return null;
  })
  .then( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    con.take( 1 );
    test.identical( con.resourcesCount(), 1 );
    con.give( function( err, got )
    {
      test.identical( err, undefined )
      test.identical( got, 1 );
    })
    test.identical( con.resourcesCount(), 1 );
    test.identical( con.competitorsCount(), 1 );
    return _.time.out( 1, function()
    {
      test.identical( con.resourcesCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .finally( () =>
  {
    test.case = 'several resources';
    return null;
  })
  .then( function( arg )
  {
    var con = new _.Consequence({ tag : 'con', capacity : 3 });
    con.take( 1 ).take( 2 ).take( 3 );
    con.give( ( err, got ) => test.identical( got, 1 ) );
    con.give( ( err, got ) => test.identical( got, 2 ) );
    con.give( ( err, got ) => test.identical( got, 3 ) );
    test.identical( con.competitorsCount(), 3 );
    test.identical( con.resourcesCount(), 3 );
    return _.time.out( 1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesCount(), 0 );
      return null;
    })
  })

  /* */

  .finally( () =>
  {
    test.case = 'single error';
    return null;
  })
  .then( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    con.error( _.errAttend( 'err' ) );
    test.identical( con.resourcesCount(), 1 );
    con.give( function( err, got )
    {
      test.is( !!err );
      test.identical( got, undefined );
    })
    test.identical( con.resourcesCount(), 1 );
    test.identical( con.competitorsCount(), 1 );
    return _.time.out( 1, function()
    {
      test.identical( con.resourcesCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .finally( () =>
  {
    test.case = 'several error'
    return null;
  })
  .then( function( arg )
  {
    var con = new _.Consequence({ tag : 'con', capacity : 3 });
    con.error( _.errAttend( 'err1' ) ).error( _.errAttend( 'err2' ) ).error( _.errAttend( 'err3' ) );
    con.give( ( err, got ) => test.is( !!err ) );
    con.give( ( err, got ) => test.is( !!err ) );
    con.give( ( err, got ) => test.is( !!err ) );
    test.identical( con.competitorsCount(), 3 );
    test.identical( con.resourcesCount(), 3 );
    return _.time.out( 1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesCount(), 0 );
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
  return ready;
}

//

function ordinarResourceAsyncMode01( test )
{
  let context = this;
  let amode = _.Consequence.AsyncModeGet();
  let ready = new _.Consequence().take( null )

  /* */

  .finally( () =>
  {
    test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );

    test.case = 'single resource';
    _.Consequence.AsyncModeSet([ 0, 1 ]);
    return null;
  })
  .then( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    con.take( 1 );

    return _.time.out( 1, function()
    {
      test.identical( con.resourcesCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      con.give( function( err, got )
      {
        test.identical( err, undefined )
        test.identical( got, 1 );
      })
      return null;
    })
    .then( function( arg )
    {
      test.identical( con.resourcesCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .finally( () =>
  {
    test.case = 'several resources';
    return null;
  })
  .then( function( arg )
  {
    var con = new _.Consequence({ tag : 'con', capacity : 3 });
    con.take( 1 ).take( 2 ).take( 3 );

    return _.time.out( 1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesCount(), 3 );
      con.give( ( err, got ) => test.identical( got, 1 ) );
      con.give( ( err, got ) => test.identical( got, 2 ) );
      con.give( ( err, got ) => test.identical( got, 3 ) );
      return null;
    })
    .then( function( arg )
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesCount(), 0 );
      return null;
    })
  })

  /* */

  .finally( () =>
  {
    test.case = 'single error';
    return null;
  })
  .then( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    con.error( _.errAttend( 'err' ) );

    return _.time.out( 1, function()
    {
      test.identical( con.resourcesCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      con.give( function( err, got )
      {
        test.is( !!err );
        test.identical( got, undefined );
      })
      return null;
    })
    .then( function( arg )
    {
      test.identical( con.resourcesCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .finally( () =>
  {
    test.case = 'several error'
    return null;
  })
  .then( function( arg )
  {
    var con = new _.Consequence({ tag : 'con', capacity : 3 });
    con.error( _.errAttend( 'err1' ) ).error( _.errAttend( 'err2' ) ).error( _.errAttend( 'err3' ) );

    return _.time.out( 1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesCount(), 3 );
      con.give( ( err, got ) => test.is( !!err ) );
      con.give( ( err, got ) => test.is( !!err ) );
      con.give( ( err, got ) => test.is( !!err ) );
      return null;
    })
    .then( function( arg )
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesCount(), 0 );
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
  return ready;
}

//

function ordinarResourceAsyncMode11( test )
{
  let context = this;
  let amode = _.Consequence.AsyncModeGet();
  let ready = new _.Consequence().take( null )

  /* */

  .finally( () =>
  {
    test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );

    test.case = 'single resource';
    _.Consequence.AsyncModeSet([ 1, 1 ]);
    return null;
  })
  .then( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    con.take( 1 );
    con.give( function( err, got )
    {
      test.identical( err, undefined )
      test.identical( got, 1 );
    })
    test.identical( con.resourcesCount(), 1 );
    test.identical( con.competitorsCount(), 1 );
    return _.time.out( 1, function()
    {
      test.identical( con.resourcesCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .finally( () =>
  {
    test.case = 'several resources';
    return null;
  })
  .then( function( arg )
  {
    var con = new _.Consequence({ tag : 'con', capacity : 3 });
    con.take( 1 ).take( 2 ).take( 3 );
    con.give( ( err, got ) => test.identical( got, 1 ) );
    con.give( ( err, got ) => test.identical( got, 2 ) );
    con.give( ( err, got ) => test.identical( got, 3 ) );
    test.identical( con.competitorsCount(), 3 );
    test.identical( con.resourcesCount(), 3 );
    return _.time.out( 1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesCount(), 0 );
      return null;
    })
  })

  /* */

  .finally( () =>
  {
    test.case = 'single error';
    return null;
  })
  .then( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    con.error( _.errAttend( 'err' ) );
    con.give( function( err, got )
    {
      test.is( !!err );
      test.identical( got, undefined );
    })
    test.identical( con.resourcesCount(), 1 );
    test.identical( con.competitorsCount(), 1 );
    return _.time.out( 1, function()
    {
      test.identical( con.resourcesCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .finally( () =>
  {
    test.case = 'several error'
    return null;
  })
  .then( function( arg )
  {
    var con = new _.Consequence({ tag : 'con', capacity : 3 });
    con.error( _.errAttend( 'err1' ) ).error( _.errAttend( 'err2' ) ).error( _.errAttend( 'err3' ) );
    con.give( ( err, got ) => test.is( !!err ) );
    con.give( ( err, got ) => test.is( !!err ) );
    con.give( ( err, got ) => test.is( !!err ) );
    test.identical( con.competitorsCount(), 3 );
    test.identical( con.resourcesCount(), 3 );
    return _.time.out( 1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesCount(), 0 );
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
  return ready;
}

//

function takeAll( test )
{
  let context = this;

  test.case = 'basic';
  var con1 = _.Consequence({ capacity : 3 });
  con1.takeAll( 'a', 'b', 'c' );
  test.identical( _.select( con1.resourcesGet(), '*/argument' ), [ 'a', 'b', 'c' ] );

  test.case = 'too small capacity';
  var con1 = _.Consequence({ capacity : 2 });
  test.shouldThrowErrorSync( () => con1.takeAll( 'a', 'b', 'c' ) );

}

//--
// finallyPromiseGive
//--

function finallyPromiseGiveAsyncMode00( test )
{
  let context = this;
  let testMsg = 'testMsg';
  let con;
  let amode = _.Consequence.AsyncModeGet();
  let ready = new _.Consequence({ tag : 'finallyPromiseGiveCon' }).take( null );

  ready

  /* */

  .finally( () =>
  {
    test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );

    _.Consequence.AsyncModeSet([ 0, 0 ]);
    return null;
  })

  .then( function( arg )
  {
    test.case = 'no resource';
    var con = new _.Consequence({ tag : 'con' });
    var promise = con.finallyPromiseGive();
    test.identical( con.resourcesCount(), 0 );
    test.identical( con.competitorsCount(), 1 );
    promise.then( function( got )
    {
      test.identical( 0, 1 );
    });

    return _.time.out( 10, function()
    {
      test.identical( con.resourcesCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      con.competitorsCancel();
      test.identical( con.resourcesCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
    });

  })

  /* */

  .then( function( arg )
  {
    test.case = 'single resource';
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );
    test.identical( con.resourcesCount(), 1 );
    var promise = con.finallyPromiseGive();
    promise.then( function( got )
    {
      test.identical( got, testMsg );
      test.is( _.promiseIs( promise ) );
      test.identical( con.resourcesCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
    })
    let result = _.Consequence.From( promise );
    return result;
  })

  /* */

  .then( function( arg )
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

  .then( function( arg )
  {
    test.case = 'several resources';
    var con = new _.Consequence({ capacity : 3 });
    con.take( testMsg + 1 );
    con.take( testMsg + 2 );
    con.take( testMsg + 3 );
    test.identical( con.resourcesCount(), 3 );
    var promise = con.finallyPromiseGive();
    promise.then( function( got )
    {
      test.identical( got, testMsg + 1 );
      test.is( _.promiseIs( promise ) );
      test.identical( con.resourcesCount(), 2 );
      test.identical( con.competitorsCount(), 0 );
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
  return ready;
}

//

function finallyPromiseGiveAsyncMode10( test )
{
  let context = this;
  let testMsg = 'testMsg';
  let con;
  let amode = _.Consequence.AsyncModeGet();
  let ready = new _.Consequence({ tag : 'finallyPromiseGiveCon' }).take( null );

  ready

  /* */

  .finally( () =>
  {
    test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );

    _.Consequence.AsyncModeSet([ 1, 0 ]);
    return null;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'async competitors adding, single resource';
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );
    var promise = con.finallyPromiseGive();
    test.identical( con.competitorsCount(), 1 );
    test.identical( con.resourcesCount(), 1 );
    return _.time.out( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesCount(), 0 );
        test.identical( con.competitorsCount(), 0 );
      });
      return _.Consequence.From( promise );
    })
  })

  /* */

  .then( function( arg )
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
    test.identical( con.resourcesCount(), 1 );
    test.identical( con.competitorsCount(), 1 );
    return _.time.out( 1, function()
    {
      test.identical( con.resourcesCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      return _.Consequence.From( promise ).finally( () => null );
    });
  })

  /* */

  .then( function( arg )
  {
    test.case = 'async competitors adding, several resources';
    var con = new _.Consequence({ capacity : 3 });
    con.take( testMsg + 1 );
    con.take( testMsg + 2 );
    con.take( testMsg + 3 );
    var promise = con.finallyPromiseGive();
    test.identical( con.resourcesCount(), 3 );
    test.identical( con.competitorsCount(), 1 );

    return _.time.out( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg + 1 );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesCount(), 2 );
        test.identical( con.competitorsCount(), 0 );
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
  return ready;
}

//

function finallyPromiseGiveAsyncMode01( test )
{
  let context = this;
  let testMsg = 'testMsg';
  let con;
  let amode = _.Consequence.AsyncModeGet();
  let ready = new _.Consequence({ tag : 'finallyPromiseGiveCon' }).take( null );

  ready

  /* */

  .finally( () =>
  {
    test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );

    _.Consequence.AsyncModeSet([ 0, 1 ]);
    return null;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'async resources adding, single resource';
    var con = new _.Consequence({ tag : 'con' });
    var promise = con.finallyPromiseGive();
    con.take( testMsg );
    test.identical( con.competitorsCount(), 1 );
    test.identical( con.resourcesCount(), 1 );
    return _.time.out( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesCount(), 0 );
        test.identical( con.competitorsCount(), 0 );
      });
      return _.Consequence.From( promise );
    })
  })

  /* */

  .then( function( arg )
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
    test.identical( con.resourcesCount(), 1 );
    test.identical( con.competitorsCount(), 1 );
    return _.time.out( 1, function()
    {
      test.identical( con.resourcesCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      return _.Consequence.From( promise ).finally( () => null );
    });
  })

  /* */

  .then( function( arg )
  {
    test.case = 'async resources adding, several resources';
    var con = new _.Consequence({ capacity : 3 });
    var promise = con.finallyPromiseGive();
    con.take( testMsg + 1 );
    con.take( testMsg + 2 );
    con.take( testMsg + 3 );
    test.identical( con.resourcesCount(), 3 );
    test.identical( con.competitorsCount(), 1 );

    return _.time.out( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg + 1 );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesCount(), 2 );
        test.identical( con.competitorsCount(), 0 );
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
  return ready;
}

//

function finallyPromiseGiveAsyncMode11( test )
{
  let context = this;
  let testMsg = 'testMsg';
  let con;
  let amode = _.Consequence.AsyncModeGet();
  let ready = new _.Consequence({ tag : 'finallyPromiseGiveCon' }).take( null );

  ready

  /* */

  .finally( () =>
  {
    test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );

    _.Consequence.AsyncModeSet([ 1, 1 ]);
    return null;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'async competitors adding+resources adding signle resource';
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );
    var promise = con.finallyPromiseGive();
    test.identical( con.competitorsCount(), 1 );
    test.identical( con.resourcesCount(), 1 );
    return _.time.out( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesCount(), 0 );
        test.identical( con.competitorsCount(), 0 );
      });
      return _.Consequence.From( promise );
    })
  })

  /* */

  .then( function( arg )
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
    test.identical( con.resourcesCount(), 1 );
    test.identical( con.competitorsCount(), 1 );
    return _.time.out( 1, function()
    {
      test.identical( con.resourcesCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      return _.Consequence.From( promise ).finally( () => null );
    });
  })

  /* */

  .then( function( arg )
  {
    test.case = 'async competitors adding+resources adding several resources';
    var con = new _.Consequence({ capacity : 3 });
    con.take( testMsg + 1 );
    con.take( testMsg + 2 );
    con.take( testMsg + 3 );
    var promise = con.finallyPromiseGive();
    test.identical( con.resourcesCount(), 3 );
    test.identical( con.competitorsCount(), 1 );

    return _.time.out( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg + 1 );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesCount(), 2 );
        test.identical( con.competitorsCount(), 0 );
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
  return ready;
}

//--
// _finally
//--

function _finallyAsyncMode00( test )
{
  let context = this;
  let amode = _.Consequence.AsyncModeGet();
  let testMsg = 'msg';
  var con;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );

    test.case += ', no resource';
    _.Consequence.AsyncModeSet([ 0, 0 ]);
    return null;
  })
  .then( function( arg )
  {
    con = new _.Consequence();
    con.finally( () => test.identical( 0, 1 ) );
    test.identical( con.competitorsCount(), 1 );
    test.identical( con.resourcesCount(), 0 );
    return null;
  })
  .timeOut( context.t1 )
  .then( function( arg )
  {
    test.identical( con.competitorsCount(), 1 );
    test.identical( con.resourcesCount(), 0 );
    con.competitorsCancel();
    test.identical( con.competitorsCount(), 0 );
    test.identical( con.resourcesCount(), 0 );
    return null;
  })

  /* */

  .then( function( arg )
  {
    test.case += ', single resource, competitor is a routine';
    return null;
  })
  .then( function( arg )
  {
    function competitor( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg );
      return null;
    }
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );
    test.identical( con.resourcesCount(), 1 )
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg } )
    con.finally( competitor );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con.resourcesCount(), 1 )
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : null } );

    return con;
  })

  /* */

  .then( function( arg )
  {
    test.case += ', several finally, competitor is a routine';
    return null;
  })
  .then( function( arg )
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
    test.identical( con.competitorsCount(), 0 )
    test.identical( con.resourcesCount(), 1 )
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg + 3 } );

    return con;
  })

  /* */

  .then( function( arg )
  {
    test.case += ', single resource, consequence as a competitor';
    return null;
  })
  .then( function( arg )
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
      test.identical( con2.resourcesCount(), 1 );
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
      test.identical( con.resourcesCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con2.resourcesCount(), 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

    return con2;
  })

  /* */

  .then( function( arg )
  {
    test.case += 'competitor returns consequence with msg';
    return null;
  })
  .then( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    var con2 = new _.Consequence({ tag : 'con2' });
    con.take( null );
    con.finally( function()
    {
      return con2.take( testMsg );
    });

    test.identical( con.competitorsCount(), 0 );
    test.identical( con.resourcesCount(), 1 );
    test.identical( con.resourcesGet()[ 0 ].argument, testMsg );

    test.identical( con2.resourcesCount(), 1 );
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
  return ready;
}

//

function _finallyAsyncMode10( test )
{
  let context = this;
  let amode = _.Consequence.AsyncModeGet();
  let testMsg = 'msg';
  var con;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );

    test.case += ', no resource';
    _.Consequence.AsyncModeSet([ 1, 0 ]);
    return null;
  })

  // .then( function( arg )
  // {
  //   var con = new _.Consequence({ tag : 'con' });
  //   con.finally( () => test.identical( 0, 1 ) );
  //   test.identical( con.competitorsCount(), 1 );
  //   test.identical( con.resourcesCount(), 0 );ччч
  //   return null;
  // })

  .then( function( arg )
  {
    con = new _.Consequence();
    con.finally( () => test.identical( 0, 1 ) );
    test.identical( con.competitorsCount(), 1 );
    test.identical( con.resourcesCount(), 0 );
    return null;
  })
  .timeOut( context.t1 )
  .then( function( arg )
  {
    test.identical( con.competitorsCount(), 1 );
    test.identical( con.resourcesCount(), 0 );
    con.competitorsCancel();
    test.identical( con.competitorsCount(), 0 );
    test.identical( con.resourcesCount(), 0 );
    return null;
  })

  /* */

  .then( function( arg )
  {
    test.case += ', single resource, competitor is a routine';
    return null;
  })
  .then( function( arg )
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
    test.identical( con.resourcesCount(), 1 )
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg } )
    test.identical( con.competitorsCount(), 1 );

    return _.time.out( 1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesCount(), 1 )
      test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : null } )
    })
  })

  /* */

  .then( function( arg )
  {
    test.case += ', several finally, competitor is a routine';
    return null;
  })
  .then( function( arg )
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
    test.identical( con.competitorsCount(), 3 )
    test.identical( con.resourcesCount(), 1 )
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg } );

    return _.time.out( 1, function()
    {
      test.identical( con.competitorsCount(), 0 )
      test.identical( con.resourcesCount(), 1 )
      test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg + 3 } );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case += ', single resource, consequence as a competitor';
    return null;
  })
  .then( function( arg )
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
      test.identical( con2.resourcesCount(), 0 );
    });

    con2.give( function( err, got )
    {
      test.identical( got, testMsg )
      con2TakerFired = true;
    });

    test.identical( con2TakerFired, false );
    test.identical( con.resourcesCount(), 1 );
    test.identical( con.competitorsCount(), 2 );
    test.identical( con2.competitorsEarlyGet().length, 1 );

    return _.time.out( 1, function()
    {
      test.identical( con2TakerFired, true );
      test.identical( con.resourcesCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con2.resourcesCount(), 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case += 'competitor returns consequence with msg';
    return null;
  })
  .then( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    var con2 = new _.Consequence({ tag : 'con2' });
    con.take( null );
    con.finally( function()
    {
      return con2.take( testMsg );
    });

    test.identical( con.competitorsCount(), 1 );

    return _.time.out( 1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesCount(), 1 );
      test.identical( con.resourcesGet()[ 0 ].argument, testMsg );

      test.identical( con2.resourcesCount(), 1 );
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
  return ready;
}

//

function _finallyAsyncMode01( test )
{
  let context = this;
  let amode = _.Consequence.AsyncModeGet();
  let testMsg = 'msg';
  var con;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );

    test.case += ', no resource';
    _.Consequence.AsyncModeSet([ 0, 1 ]);
    return null;
  })
  // .then( function( arg )
  // {
  //   var con = new _.Consequence({ tag : 'con' });
  //   con.finally( () => test.identical( 0, 1 ) );
  //   test.identical( con.competitorsCount(), 1 );
  //   test.identical( con.resourcesCount(), 0 );
  //   return null;
  // })

  .then( function( arg )
  {
    con = new _.Consequence();
    con.finally( () => test.identical( 0, 1 ) );
    test.identical( con.competitorsCount(), 1 );
    test.identical( con.resourcesCount(), 0 );
    return null;
  })
  .timeOut( context.t1 )
  .then( function( arg )
  {
    test.identical( con.competitorsCount(), 1 );
    test.identical( con.resourcesCount(), 0 );
    con.competitorsCancel();
    test.identical( con.competitorsCount(), 0 );
    test.identical( con.resourcesCount(), 0 );
    return null;
  })

  /* */

  .then( function( arg )
  {
    test.case += ', single resource, competitor is a routine';
    return null;
  })
  .then( function( arg )
  {
    function competitor( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg );
      return null;
    }
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );

    return _.time.out( 1, function()
    {
      test.identical( con.resourcesCount(), 1 )
      test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg } )
      test.identical( con.competitorsCount(), 0 );

      con.finally( competitor );
      return null;
    })
    .then( function( arg )
    {
      test.identical( con.competitorsCount(), 0 )
      test.identical( con.resourcesCount(), 1 )
      test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : null } )
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case += ', several finally, competitor is a routine';
    return null;
  })
  .then( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );

    return _.time.out( 1, function()
    {
      test.identical( con.competitorsCount(), 0 )
      test.identical( con.resourcesCount(), 1 )
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
    .then( function( arg )
    {
      test.identical( con.competitorsCount(), 0 )
      test.identical( con.resourcesCount(), 1 )
      test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg + 3 } );
      return null;
    })
 })

  /* */

  .then( function( arg )
  {
    test.case += ', single resource, consequence as a competitor';
    return null;
  })
  .then( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    var con2 = new _.Consequence({ tag : 'con2' });
    var con2TakerFired = false;
    con.take( testMsg );

    test.identical( con2TakerFired, false );
    test.identical( con.resourcesCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con2.competitorsEarlyGet().length, 0 );

    return _.time.out( 1, function()
    {
      con.finally( con2 );
      con.give( function( err, arg )
      {
        test.identical( arg, testMsg );
        test.identical( con2TakerFired, false );
        test.identical( con2.resourcesCount(), 1 );
      });

      con2.finally( function( err, arg )
      {
        test.identical( arg, testMsg );
        con2TakerFired = true;
        return arg;
      });

    return con2;
    })
    .then( function( arg )
    {
      test.identical( con2TakerFired, true );
      test.identical( con.resourcesCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con2.resourcesCount(), 1 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case += 'competitor returns consequence with msg';
    return null;
  })
  .then( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    var con2 = new _.Consequence({ tag : 'con2' });
    con.take( null );

    test.identical( con.resourcesCount(), 1 );

    return _.time.out( 1, function()
    {
      con.finally( function()
      {
        return con2.take( testMsg );
      });

      return con;
    })
    .then( function( arg )
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesCount(), 1 );
      test.identical( con.resourcesGet()[ 0 ].argument, testMsg );

      test.identical( con2.resourcesCount(), 1 );
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
  return ready;
}

//

function _finallyAsyncMode11( test )
{
  let context = this;
  let amode = _.Consequence.AsyncModeGet();
  let testMsg = 'msg';
  var con;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );

    test.case += ', no resource';
    _.Consequence.AsyncModeSet([ 1, 1 ]);
    return null;
  })
  // .then( function( arg )
  // {
  //   var con = new _.Consequence({ tag : 'con' });
  //   con.finally( () => test.identical( 0, 1 ) );
  //   test.identical( con.competitorsCount(), 1 );
  //   test.identical( con.resourcesCount(), 0 );
  //   return null;
  // })

  .then( function( arg )
  {
    con = new _.Consequence();
    con.finally( () => test.identical( 0, 1 ) );
    test.identical( con.competitorsCount(), 1 );
    test.identical( con.resourcesCount(), 0 );
    return null;
  })
  .timeOut( context.t1 )
  .then( function( arg )
  {
    test.identical( con.competitorsCount(), 1 );
    test.identical( con.resourcesCount(), 0 );
    con.competitorsCancel();
    test.identical( con.competitorsCount(), 0 );
    test.identical( con.resourcesCount(), 0 );
    return null;
  })

  /* */

  .then( function( arg )
  {
    test.case += ', single resource, competitor is a routine'
    return null;
  })
  .then( function( arg )
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
    test.identical( con.competitorsCount(), 1 )
    test.identical( con.resourcesCount(), 1 )
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg } )
    return _.time.out( 1, function()
    {
      test.identical( con.competitorsCount(), 0 )
      test.identical( con.resourcesCount(), 1 )
      test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : null } )
      return null;
    })
 })

  /* */

  .then( function( arg )
  {
    test.case += ', several finally, competitor is a routine';
    return null;
  })
  .then( function( arg )
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

    test.identical( con.competitorsCount(), 3 );
    test.identical( con.resourcesCount(), 1 );
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg } );

    return _.time.out( 1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesCount(), 1 );
      test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg + 3} );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case += ', single resource, consequence as a competitor';
    return null;
  })
  .then( function( arg )
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
      test.identical( con2.resourcesCount(), 1 );
    });

    con2.give( function( err, got )
    {
      test.identical( got, testMsg );
      con2TakerFired = true;
    });

    test.identical( con2TakerFired, false );
    test.identical( con.resourcesCount(), 1 );
    test.identical( con.competitorsCount(), 2 );
    test.identical( con2.competitorsEarlyGet().length, 1 );
    test.identical( con2.resourcesCount(), 0 );

    return _.time.out( 1, function()
    {
      test.identical( con2TakerFired, true );
      test.identical( con.resourcesCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con2.resourcesCount(), 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case += 'competitor returns consequence with msg';
    return null;
  })
  .then( function( arg )
  {
    var con = new _.Consequence({ tag : 'con' });
    var con2 = new _.Consequence({ tag : 'con2' });
    con.take( null );
    con.finally( function()
    {
      return con2.take( testMsg );
    });

    test.identical( con.resourcesCount(), 1 );

    return _.time.out( 1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesCount(), 1 );
      test.identical( con.resourcesGet()[ 0 ].argument, testMsg );

      test.identical( con2.resourcesCount(), 1 );
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
  return ready;
}

//--
// finallyPromiseKeep
//--

function finallyPromiseKeepAsyncMode00( test )
{
  let context = this;
  let testMsg = 'testMsg';
  let con;
  let amode = _.Consequence.AsyncModeGet();
  let ready = new _.Consequence({ tag : 'finallyPromiseKeepCon' }).take( null );

  ready

  /* */

  .finally( () =>
  {
    test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );

    _.Consequence.AsyncModeSet([ 0, 0 ]);
    return null;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'no resource';
    con = new _.Consequence();
    var promise = con.finallyPromiseKeep();
    test.identical( con.resourcesCount(), 0 );
    test.identical( con.competitorsCount(), 1 );
    promise.then( function( got )
    {
      test.identical( 0, 1 );
    })
    return _.time.out( 10 );
  })

  .timeOut( context.t1 )
  .then( function( arg )
  {
    test.identical( con.resourcesCount(), 0 );
    test.identical( con.competitorsCount(), 1 );
    con.competitorsCancel();
    test.identical( con.resourcesCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    return arg;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'single resource';
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );
    test.identical( con.resourcesCount(), 1 );
    var promise = con.finallyPromiseKeep();
    promise.then( function( got )
    {
      test.identical( got, testMsg );
      test.is( _.promiseIs( promise ) );
      test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg }] );
      test.identical( con.competitorsCount(), 0 );
    })

    return _.Consequence.From( promise );
  })

  /* */

  .then( function( arg )
  {
    test.case = 'error resource';
    var con = new _.Consequence({ tag : 'con' });
    con.error( testMsg );
    test.identical( con.resourcesCount(), 1 );
    var promise = con.finallyPromiseKeep();
    promise.catch( function( err )
    {
      test.is( _.strHas( String( err ), testMsg ) );
      test.is( _.promiseIs( promise ) );
      // test.identical( con.resourcesGet(), [{ error : testMsg, argument : undefined }] );
      test.identical( con.argumentsGet(), [] );
      test.identical( con.errorsGet().length, 1 );
      test.identical( con.competitorsCount(), 0 );
    })
    return _.Consequence.From( promise ).finally( () => null );
  })

  /* */

  .then( function( arg )
  {
    test.case = 'several resources';
    var con = new _.Consequence({ capacity : 3 });
    con.take( testMsg + 1 );
    con.take( testMsg + 2 );
    con.take( testMsg + 3 );
    test.identical( con.resourcesCount(), 3 );
    var promise = con.finallyPromiseKeep();
    promise.then( function( got )
    {
      test.identical( got, testMsg + 1 );
      test.is( _.promiseIs( promise ) );
      test.identical( con.resourcesCount(), 3 );
      test.identical( con.competitorsCount(), 0 );
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
  return ready;
}

//

function finallyPromiseKeepAsyncMode10( test )
{
  let context = this;
  let testMsg = 'testMsg';
  let con;
  let amode = _.Consequence.AsyncModeGet();
  let ready = new _.Consequence({ tag : 'finallyPromiseKeepCon' }).take( null );

  ready

  /* */

  .finally( () =>
  {
    test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );

    _.Consequence.AsyncModeSet([ 1, 0 ]);
    return null;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'async competitors adding, single resource';
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );
    var promise = con.finallyPromiseKeep();
    test.identical( con.competitorsCount(), 1 );
    test.identical( con.resourcesCount(), 1 );
    return _.time.out( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg }] );
        test.identical( con.competitorsCount(), 0 );
      });
      return _.Consequence.From( promise );
    })
  })

  /* */

  .then( function( arg )
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
    test.identical( con.resourcesCount(), 1 );
    test.identical( con.competitorsCount(), 1 );
    return _.time.out( 1, function()
    {
      // test.identical( con.resourcesGet(), [{ error : testMsg, argument : undefined }] );
      test.identical( con.argumentsGet(), [] );
      test.identical( con.errorsGet().length, 1 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( catched, 1 );
      return _.Consequence.From( promise ).finally( () => null );
    });
  })

  /* */

  .then( function( arg )
  {
    test.case = 'async competitors adding, several resources';
    var con = new _.Consequence({ capacity : 3 });
    con.take( testMsg + 1 );
    con.take( testMsg + 2 );
    con.take( testMsg + 3 );
    var promise = con.finallyPromiseKeep();
    test.identical( con.resourcesCount(), 3 );
    test.identical( con.competitorsCount(), 1 );

    return _.time.out( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg + 1 );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesCount(), 3 );
        test.identical( con.competitorsCount(), 0 );
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
  return ready;
}

//

function finallyPromiseKeepAsyncMode01( test )
{
  let context = this;
  let testMsg = 'testMsg';
  let con;
  let amode = _.Consequence.AsyncModeGet();
  let ready = new _.Consequence({ tag : 'finallyPromiseKeepCon' }).take( null );

  ready

  /* */

  .finally( () =>
  {
    test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );

    _.Consequence.AsyncModeSet([ 0, 1 ]);
    return null;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'async resources adding, single resource';
    var con = new _.Consequence({ tag : 'con' });
    var promise = con.finallyPromiseKeep();
    con.take( testMsg );
    test.identical( con.competitorsCount(), 1 );
    test.identical( con.resourcesCount(), 1 );
    return _.time.out( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg }] );
        test.identical( con.competitorsCount(), 0 );
      });
      return _.Consequence.From( promise );
    })
  })

  /* */

  .then( function( arg )
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
    test.identical( con.resourcesCount(), 1 );
    test.identical( con.competitorsCount(), 1 );
    return _.time.out( 1, function()
    {
      // test.identical( con.resourcesGet(), [{ error : testMsg, argument : undefined }] );
      test.identical( con.argumentsGet(), [] );
      test.identical( con.errorsGet().length, 1 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( catched, 1 );
      return _.Consequence.From( promise ).finally( () => null );
    });
  })

  /* */

  .then( function( arg )
  {
    test.case = 'async resources adding, several resources';
    var con = new _.Consequence({ capacity : 3 });
    var promise = con.finallyPromiseKeep();
    con.take( testMsg + 1 );
    con.take( testMsg + 2 );
    con.take( testMsg + 3 );
    test.identical( con.resourcesCount(), 3 );
    test.identical( con.competitorsCount(), 1 );

    return _.time.out( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg + 1 );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesCount(), 3 );
        test.identical( con.competitorsCount(), 0 );
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
  return ready;
}

//

function finallyPromiseKeepAsyncMode11( test )
{
  let context = this;
  let testMsg = 'testMsg';
  let con;
  let amode = _.Consequence.AsyncModeGet();
  let ready = new _.Consequence({ tag : 'finallyPromiseKeepCon' }).take( null );

  ready

  /* */

  .finally( () =>
  {
    test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );

    _.Consequence.AsyncModeSet([ 1, 1 ]);
    return null;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'async competitors adding+resources adding, single resource';
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );
    var promise = con.finallyPromiseKeep();
    test.identical( con.competitorsCount(), 1 );
    test.identical( con.resourcesCount(), 1 );
    return _.time.out( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg }] );
        test.identical( con.competitorsCount(), 0 );
      });
      return _.Consequence.From( promise );
    })
  })

  /* */

  .then( function( arg )
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
    test.identical( con.resourcesCount(), 1 );
    test.identical( con.competitorsCount(), 1 );
    return _.time.out( 1, function()
    {
      // test.identical( con.resourcesGet(), [{ error : testMsg, argument : undefined }] );
      test.identical( con.argumentsGet(), [] );
      test.identical( con.errorsGet().length, 1 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( catched, 1 );
      return _.Consequence.From( promise ).finally( () => null );
    });
  })

  /* */

  .then( function( arg )
  {
    test.case = 'async competitors adding+resources adding, several resources';
    var con = new _.Consequence({ capacity : 3 });
    con.take( testMsg + 1 );
    con.take( testMsg + 2 );
    con.take( testMsg + 3 );
    var promise = con.finallyPromiseKeep();
    test.identical( con.resourcesCount(), 3 );
    test.identical( con.competitorsCount(), 1 );

    return _.time.out( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg + 1 );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesCount(), 3 );
        test.identical( con.competitorsCount(), 0 );
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
  return ready;
}

//

function deasync( test )
{
  let context = this;
  let ready = _.now();
  let t = context.t1;

  /* */

  ready.then( () =>
  {
    let counter = 0;
    let after = false;
    let con;

    _.time.out( t*20, () =>
    {
      test.is( after );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( counter, 1 );
      counter += 1;
    });
    _.time.out( 1, () =>
    {
      test.is( !after );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 2 );
      test.identical( counter, 0 );
      counter += 1;
    });

    con = _.time.out( t*4 );

    test.is( !after );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );
    test.identical( counter, 0 );

    con.deasync();

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( counter, 1 );
    after = 1;

    return _.time.out( t*40, () =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( counter, 2 );
    });
  })

  /* */

  return ready;
}

//

function split( test )
{
  let ready = new _.Consequence().take( null );

  /* */

  ready
  .then( function( arg )
  {
    test.case = 'split : run after resolve value';
    var con = new _.Consequence({ tag : 'con' }).take( 5 );
    var con2 = con.split();
    test.identical( con2.resourcesCount(), 1 );
    con2.give( function( err, got )
    {
      test.identical( got, 5 );
      test.identical( err, undefined );
    });

    test.identical( con.resourcesCount(), 1 );
    test.identical( con2.resourcesCount(), 0 );
    return null;
  })

  /* */

  .then( function( arg )
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
    test.identical( con.resourcesCount(), 1 );
    test.identical( con2.resourcesCount(), 0 );
    return null;
  })

  /* */

  .then( function( arg )
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
    test.identical( con.resourcesCount(), 2 );
    var con2 = con.split();
    test.identical( con.resourcesCount(), 2 );
    test.identical( con2.resourcesCount(), 1 );
    con2.give( competitor );
    con2.give( competitor );

    test.identical( con2.resourcesCount(), 0 );
    test.identical( con2.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesCount(), 2 );
    test.identical( _got, [ 5 ] );
    test.identical( _err, [ undefined ] );

    con2.competitorsCancel( competitor );
    test.identical( con2.resourcesCount(), 0 );
    test.identical( con2.competitorsEarlyGet().length, 0 );

    return null;
  })

  /* */

  .then( function( arg )
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
    test.identical( con.resourcesCount(), 2 );
    var con2 = con.split( competitor );

    test.identical( con2.resourcesCount(), 1 );
    test.identical( con2.resourcesGet()[ 0 ], { error : undefined, argument : null } );
    test.identical( con2.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesCount(), 2 );
    test.identical( _got, [ 5 ] )
    test.identical( _err, [ undefined ] )
    return null;
  })

  /* */

  return ready;
}

//

function tap( test )
{
  let testMsg = 'msg';
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    test.case = 'single value in give sequence, and single taker : attached taker after value resolved';
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );
    con.tap( ( err, got ) => test.identical( got, testMsg ) );
    con.give( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con.resourcesCount(), 0 );
    return null;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'single error and single taker : attached taker after value resolved';
    var con = new _.Consequence({ tag : 'con' });
    con.error( testMsg );
    con.tap( ( err, got ) => test.is( _.strHas( String( err ), testMsg ) ) );
    con.give( ( err, got ) => test.is( _.strHas( String( err ), testMsg ) ) );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con.resourcesCount(), 0 );
    return null;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'test tap in chain';
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );
    con.tap( ( err, got ) => test.identical( got, testMsg ) );
    con.tap( ( err, got ) => test.identical( got, testMsg ) );
    con.give( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con.resourcesCount(), 0 );
    return null;
  })

   /* */

  .then( function( arg )
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

  return ready;
}

//

function tapHandling( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    test.case = 'take at the end'
    var con = new _.Consequence({ tag : 'con' });
    var visited = [ 0, 0, 0, 0, 0, 0 ];

    con.take( null );
    con.then( ( arg ) =>
    {
      visited[ 0 ] = 1;
      throw 'Error';
      return arg;
    });
    con.then( ( arg ) =>
    {
      visited[ 1 ] = 1;
      return arg;
    });
    con.then( ( arg ) =>
    {
      visited[ 2 ] = 1;
      return arg;
    });
    con.tap( ( err, arg ) =>
    {
      test.is( _.errIs( err ) );
      if( err )
      _.errAttend( err );
      test.identical( arg, undefined );
      _.errAttend( err );
      visited[ 3 ] = 1;
    });
    con.then( ( arg ) =>
    {
      visited[ 4 ] = 1;
      return arg;
    });
    con.then( ( arg ) =>
    {
      visited[ 5 ] = 1;
      return arg;
    });

    return _.time.out( context.t1/2, () =>
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
      visited[ 0 ] = 1;
      throw 'Error';
      return arg;
    });
    con.then( ( arg ) =>
    {
      visited[ 1 ] = 1;
      return arg;
    });
    con.then( ( arg ) =>
    {
      visited[ 2 ] = 1;
      return arg;
    });
    con.tap( ( err, arg ) =>
    {
      test.is( _.errIs( err ) );
      if( err )
      _.errAttend( err );
      test.identical( arg, undefined );
      _.errAttend( err );
      visited[ 3 ] = 1;
    });
    con.then( ( arg ) =>
    {
      visited[ 4 ] = 1;
      return arg;
    });
    con.then( ( arg ) =>
    {
      visited[ 5 ] = 1;
      return arg;
    });
    con.take( null );

    return _.time.out( context.t1/2, () =>
    {
      test.identical( visited, [ 1, 0, 0, 1, 0, 0 ] );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
    });
  })

  /* */

  return ready;
}

//

function catchTestRoutine( test )
{
  let testMsg = 'msg';
  let ready = new _.Consequence().take( null )

  /* common wConsequence corespondent tests. */

  .then( function( arg )
  {
    test.case = 'single value in give sequence, and single taker : attached taker after value resolved';
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );
    con.catch( ( err ) => { test.identical( 0, 1 ); return null; } );
    con.give( ( err, got ) => test.identical( got, testMsg ));

    test.identical( con.competitorsCount(), 0 );
    test.identical( con.resourcesCount(), 0 );

    return arg;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'single err in give sequence, and single taker : attached taker after value resolved';
    var con = new _.Consequence({ tag : 'con' });
    con.error( testMsg );
    con.catch( ( err ) => { test.is( _.strHas( String( err ), testMsg ) ); return null; });
    con.give( ( err, got ) => test.identical( got, null ) );

    test.identical( con.competitorsCount(), 0 );
    test.identical( con.resourcesCount(), 0 );

    return arg;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'test catchTestRoutine in chain, regular resource is given before error';
    var con = new _.Consequence({ capacity : 0 });
    con.take( testMsg );
    con.error( testMsg + 1 );
    con.error( testMsg + 2 );

    con.catch( ( err ) => { test.identical( 0, 1 ); return null; });
    con.catch( ( err ) => { test.identical( 0, 1 ); return null; });
    con.give( ( err, got ) => test.identical( got, testMsg ) );

    test.identical( con.resourcesCount(), 2 );
    test.is( _.strHas( String( con.resourcesGet()[ 0 ].error ), testMsg + 1 ) );
    test.is( _.strHas( String( con.resourcesGet()[ 1 ].error ), testMsg + 2 ) );
    test.identical( con.competitorsCount(), 0 );

    return arg;
  })

  /* */

  .then( function( arg )
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

    test.identical( con.resourcesCount(), 2 );
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : null } );
    test.identical( con.resourcesGet()[ 1 ], { error : undefined, argument : null } );
    test.identical( con.competitorsCount(), 0 );

    return arg;
  })

   /* */

  .then( function( arg )
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

  return ready;
}

//

function ifNoErrorGotTrivial( test )
{
  let context = this;
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

  return _.time.out( context.t1, () =>
  {
    test.identical( last, 1 );
    con.competitorsCancel();
    return null;
  });

}

//

function ifNoErrorGotThrowing( test )
{
  let context = this;
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
    throw 'Throw error';
    return result;
  })
  .finally( ( err, arg ) =>
  {
    test.identical( arg, undefined );
    if( err )
    {
      error = err;
      _.errAttend( err );
    }
    last = 2
    return null;
  });

  return _.time.out( context.t1, () =>
  {
    test.identical( last, 2 );
    test.is( _.errIs( error ) );
    return null;
  });

}

//

function keep( test )
{
  let context = this;
  let testMsg = 'msg';
  let ready = new _.Consequence().take( null )

  /* common wConsequence corespondent tests. */

  .then( function( arg )
  {
    test.case = 'single value in give sequence, and single taker : attached taker after value resolved';
    var con = new _.Consequence({ tag : 'con' });
    con.take( testMsg );
    con.then( ( got ) => { test.identical( got, testMsg ); return null; } );
    con.give( ( err, got ) => test.identical( got, null ) );

    test.identical( con.competitorsCount(), 0 );
    test.identical( con.resourcesCount(), 0 );
    return null;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'single err in give sequence, and single taker : attached taker after value resolved';
    var con = new _.Consequence({ tag : 'con' });
    con.error( testMsg );
    con.then( ( got ) => { test.identical( 0, 1 ); return null; });
    con.give( ( err, got ) => test.is( _.strHas( String( err ), testMsg ) ) );

    test.identical( con.competitorsCount(), 0 );
    test.identical( con.resourcesCount(), 0 );
    return null;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'test keep in chain, regular resource is given before error';
    var con = new _.Consequence({ capacity : 0 });
    con.take( testMsg );
    con.take( testMsg );
    con.error( testMsg );

    con.then( ( got ) => { test.identical( got, testMsg ); return null; });
    con.then( ( got ) => { test.identical( got, testMsg ); return null; });

    test.identical( con.resourcesCount(), 3 );
    // test.identical( con.resourcesGet()[ 0 ].error, testMsg );
    test.is( _.strHas( String( con.resourcesGet()[ 0 ].error ), testMsg ) );
    test.identical( con.resourcesGet()[ 1 ], { error : undefined, argument : null } );
    test.identical( con.resourcesGet()[ 2 ], { error : undefined, argument : null } );
    test.identical( con.competitorsCount(), 0 );
    return null;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'test keep in chain, regular resource is given after error';
    var con = new _.Consequence({ capacity : 0 });
    con.error( testMsg );
    con.take( testMsg );
    con.take( testMsg );

    con.then( ( got ) => { test.identical( 0, 1 ); return null; });
    con.then( ( got ) => { test.identical( 0, 1 ); return null; });

    test.identical( con.resourcesCount(), 3 );
    // test.identical( con.resourcesGet()[ 0 ].error, testMsg );
    test.is( _.strHas( String( con.resourcesGet()[ 0 ].error ), testMsg ) );
    test.identical( con.resourcesGet()[ 1 ], { error : undefined, argument : testMsg } );
    test.identical( con.resourcesGet()[ 2 ], { error : undefined, argument : testMsg } );
    test.identical( con.competitorsCount(), 0 );
    return null;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'test keep in chain serveral resources';
    var con = new _.Consequence({ capacity : 0 });
    con.take( testMsg );
    con.take( testMsg );

    con.then( ( got ) => { test.identical( got, testMsg ); return null; });
    con.then( ( got ) => { test.identical( got, testMsg ); return null; });

    test.identical( con.resourcesCount(), 2 );
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : null } );
    test.identical( con.resourcesGet()[ 1 ], { error : undefined, argument : null } );
    test.identical( con.competitorsCount(), 0 );
    return null;
  })

   /* */

  .then( function( arg )
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

  return ready;
}

//

function timeOut( test )
{
  let context = this;
  let testMsg = 'msg';
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    let visited = [];
    test.case = 'zero delay';
    var con = new _.Consequence({ tag : 'con' });

    con.finally( () => visited.push( 'a' ) );

    con.timeOut( 0 );

    con.finally( () => visited.push( 'b' ) );

    test.identical( con.competitorsCount(), 3 );
    test.identical( con.resourcesCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( visited, [] );
    visited.push( 'context' )

    con.take( testMsg );
    visited.push( 'd' )

    test.identical( con.competitorsCount(), 1 );
    test.identical( con.resourcesCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( visited, [ 'context', 'a', 'd' ] );

    return _.time.out( context.t1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesCount(), 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( visited, [ 'context', 'a', 'd', 'b' ] );
    })
  })

  /* */

  .then( function( arg )
  {
    let visited = [];
    test.case = 'non-zero delay';
    var con = new _.Consequence({ tag : 'con' });

    con.finally( () => visited.push( 'a' ) );

    con.timeOut( 25 );

    con.finally( () => visited.push( 'b' ) );

    test.identical( con.competitorsCount(), 3 );
    test.identical( con.resourcesCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( visited, [] );
    visited.push( 'context' )

    con.take( testMsg );
    visited.push( 'd' )

    test.identical( con.competitorsCount(), 1 );
    test.identical( con.resourcesCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( visited, [ 'context', 'a', 'd' ] );

    return _.time.out( context.t1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesCount(), 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( visited, [ 'context', 'a', 'd', 'b' ] );
    })
  })

  /* */

  .then( function( arg )
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

  /* */

  return ready;
}

//

function timeLimitSplit( test )
{
  let context = this;
  let ready = _.now();
  let t = context.t1;

  ready

  /* */

  .then( function timeLimit1( arg )
  {
    test.case = 'timeOut, enough time';

    var con = _.time.out( t*1, 'a' );
    var con2 = con.timeLimitSplit( t*3 );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 2 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.competitorsCount(), 2 );

    con2.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.is( err === undefined );
      test.is( arg === 'a' );
    });

    _.time.out( t*1, function()
    {
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.competitorsCount(), 0 );
    });

    return _.time.out( t*5, function()
    {
      test.is( con.argumentsGet()[ 0 ] === 'a' );
      test.is( con2.argumentsGet()[ 0 ] === 'a' );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function timeLimit2( arg )
  {
    test.case = 'timeOut, not enough time';

    var con = _.time.out( t*8, 'a' );
    var con2 = con.timeLimitSplit( t*4 );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 2 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.competitorsCount(), 2 );

    con2.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.is( err === undefined );
      test.is( arg === _.time.out );
    });

    _.time.out( t*4, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.competitorsCount(), 0 );
    });

    return _.time.out( t*15, function()
    {
      test.is( con.argumentsGet()[ 0 ] === 'a' );
      test.is( con2.argumentsGet()[ 0 ] === _.time.out );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function timeLimit1( arg )
  {
    test.case = 'timeOutError, enough time';

    var con = _.time.outError( t*1 );
    var con2 = con.timeLimitSplit( t*3 );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 3 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.competitorsCount(), 2 );

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.is( _.errIs( err ) );
      test.is( arg === undefined );
    });

    con2.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.is( _.errIs( err ) );
      test.is( arg === undefined );
    });

    _.time.out( t*1, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.errorsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
    });

    return _.time.out( t*5, function()
    {
      test.identical( con.errorsGet()[ 0 ].reason, 'time out' );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con2.errorsGet()[ 0 ].reason, 'time out' );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.errorsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function timeLimit2( arg )
  {
    test.case = 'timeOutError, not enough time';

    var con = _.time.outError( t*8, 'a' );
    var con2 = con.timeLimitSplit( t*4 );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 3 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.competitorsCount(), 2 );

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.is( _.errIs( err ) );
      test.is( arg === undefined );
    });

    con2.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.is( err === undefined );
      test.is( arg === _.time.out );
    });

    _.time.out( t*4, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 3 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.competitorsCount(), 0 );
    });

    return _.time.out( t*15, function()
    {
      test.identical( con.errorsGet()[ 0 ].reason, 'time out' );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      test.is( con2.argumentsGet()[ 0 ] === _.time.out );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  return ready;
}

//

function timeLimitThrowingSplit( test )
{
  let context = this;
  let t = context.t1/2;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function timeLimit1( arg )
  {
    test.case = 'timeOut, enough time';

    var con = _.time.out( t*1, 'a' );
    var con2 = con.timeLimitThrowingSplit( t*3 );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 2 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.competitorsCount(), 2 );

    con2.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.is( err === undefined );
      test.is( arg === 'a' );
    });

    _.time.out( t*1, function()
    {
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.competitorsCount(), 0 );
    });

    return _.time.out( t*5, function()
    {
      test.is( con.argumentsGet()[ 0 ] === 'a' );
      test.is( con2.argumentsGet()[ 0 ] === 'a' );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function timeLimit2( arg )
  {
    test.case = 'timeOut, not enough time';

    var con = _.time.out( t*8, 'a' );
    var con2 = con.timeLimitThrowingSplit( t*4 );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 2 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.competitorsCount(), 2 );

    con2.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.is( _.errIs( err ) );
      test.is( arg === undefined );
    });

    _.time.out( t*4, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.errorsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
    });

    return _.time.out( t*15, function()
    {
      test.is( con.argumentsGet()[ 0 ] === 'a' );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con2.errorsGet()[ 0 ].reason, 'time limit' );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.errorsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function timeLimit1( arg )
  {
    test.case = 'timeOutError, enough time';

    var con = _.time.outError( t*1 );
    var con2 = con.timeLimitThrowingSplit( t*3 );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 3 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.competitorsCount(), 2 );

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.is( _.errIs( err ) );
      test.is( arg === undefined );
    });

    con2.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.is( _.errIs( err ) );
      test.is( arg === undefined );
    });

    _.time.out( t*1, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.errorsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
    });

    return _.time.out( t*5, function()
    {
      test.identical( con.errorsGet()[ 0 ].reason, 'time out' );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con2.errorsGet()[ 0 ].reason, 'time out' );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.errorsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function timeLimit2( arg )
  {
    test.case = 'timeOutError, not enough time';

    var con = _.time.outError( t*8, 'a' );
    var con2 = con.timeLimitThrowingSplit( t*4 );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 3 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.competitorsCount(), 2 );

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.is( _.errIs( err ) );
      test.is( arg === undefined );
    });

    con2.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.is( _.errIs( err ) );
      test.is( arg === undefined );
    });

    _.time.out( t*4, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 3 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.errorsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
    });

    return _.time.out( t*15, function()
    {
      test.identical( con.errorsGet()[ 0 ].reason, 'time out' );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con2.errorsGet()[ 0 ].reason, 'time limit' );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.errorsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  return ready;
}

//

function timeLimitConsequence( test )
{
  let context = this;
  let t = context.t1;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function timeLimit1( arg )
  {
    test.case = 'timeOut a timeLimit timeLimit-enough';

    var con = _.time.out( t*3 );
    var con0 = _.time.out( t*5, 'a' );
    con.timeLimit( t*10, con0 );

    test.identical( con0.argumentsCount(), 0 );
    test.identical( con0.errorsCount(), 0 );
    test.identical( con0.competitorsCount(), 2 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 4 );

    con.tap( ( err, arg ) =>
    {
      test.is( err === undefined );
      test.is( arg === 'a' );
    });

    _.time.out( t*1, function()
    {
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.competitorsCount(), 2 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 5 );
    });

    _.time.out( t*6, function()
    {
      test.identical( con0.argumentsCount(), 1 );
      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.competitorsCount(), 0 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t*15, function()
    {
      test.is( con.argumentsGet()[ 0 ] === 'a' );
      test.identical( con0.argumentsCount(), 1 );
      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.competitorsCount(), 0 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function timeLimit1( arg )
  {
    test.case = 'timeOut a timeLimit-not-enough';

    var con = _.time.out( t*3 );
    var con0 = _.time.out( t*10, 'a' );
    con.timeLimit( t*3, con0 );

    test.identical( con0.argumentsCount(), 0 );
    test.identical( con0.errorsCount(), 0 );
    test.identical( con0.competitorsCount(), 2 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 4 );

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.is( err === undefined );
      test.is( arg === _.time.out );
    });

    _.time.out( t*1, function()
    {
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.competitorsCount(), 2 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 5 );
    });

    _.time.out( t*3, function()
    {
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.competitorsCount(), 2 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 3 );
    });

    _.time.out( t*8, function()
    {
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.competitorsCount(), 1 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t*15, function()
    {
      test.is( con.argumentsGet()[ 0 ] === _.time.out );
      test.identical( con0.argumentsCount(), 1 );
      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.competitorsCount(), 0 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function timeLimit1( arg )
  {
    test.case = 'timeOut a-timeOutError timeLimit-enough';

    var con = _.time.out( t*3 );
    var con0 = _.time.outError( t*5, 'a' );
    con.timeLimit( t*10, con0 );

    test.identical( con0.argumentsCount(), 0 );
    test.identical( con0.errorsCount(), 0 );
    test.identical( con0.competitorsCount(), 3 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 4 );

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.is( _.errIs( err ) );
      test.is( arg === undefined );
    });

    _.time.out( t*1, function()
    {
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.competitorsCount(), 3 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 5 );
    });

    _.time.out( t*6, function()
    {
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.errorsCount(), 1 );
      test.identical( con0.competitorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t*15, function()
    {
      test.is( _.strHas( String( con.errorsGet()[ 0 ] ), 'Time out!' ) );
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.errorsCount(), 1 );
      test.identical( con0.competitorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function timeLimit1( arg )
  {
    test.case = 'timeOut a-timeOutError timeLimit-not-enough';

    var con = _.time.out( t*3 );
    var con0 = _.time.outError( t*10 );
    con.timeLimit( t*3, con0 );

    test.identical( con0.argumentsCount(), 0 );
    test.identical( con0.errorsCount(), 0 );
    test.identical( con0.competitorsCount(), 3 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 4 );

    con0.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.is( _.errIs( err ) );
      test.is( arg === undefined );
    });

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.is( err === undefined );
      test.is( arg === _.time.out );
    });

    _.time.out( t*1, function()
    {
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.competitorsCount(), 4 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 5 );
    });

    _.time.out( t*3, function()
    {
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.competitorsCount(), 4 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 3 );
    });

    _.time.out( t*8, function()
    {
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.competitorsCount(), 3 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t*15, function()
    {
      test.is( con.argumentsGet()[ 0 ] === _.time.out );
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.errorsCount(), 1 );
      test.identical( con0.competitorsCount(), 0 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function timeLimit1( arg )
  {
    test.case = 'timeOutError a timeLimit-enough';

    var con = _.time.outError( t*3 );
    var con0 = _.time.out( t*5, 'a' );
    con.timeLimit( t*10, con0 );

    test.identical( con0.argumentsCount(), 0 );
    test.identical( con0.errorsCount(), 0 );
    test.identical( con0.competitorsCount(), 2 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 5 );

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.is( _.errIs( err ) );
      test.is( arg === undefined );
    });

    _.time.out( t*1, function()
    {
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.competitorsCount(), 2 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 6 );
    });

    _.time.out( t*6, function()
    {
      test.identical( con0.argumentsCount(), 1 );
      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.competitorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t*15, function()
    {
      test.is( _.strHas( String( con.errorsGet()[ 0 ] ), 'Time out!' ) );
      test.identical( con0.argumentsCount(), 1 );
      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.competitorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function timeLimit1( arg )
  {
    test.case = 'timeOutError a timeLimit-not-enough';

    var con = _.time.outError( t*3 );
    var con0 = _.time.out( t*10 );
    con.timeLimit( t*3, con0 );

    test.identical( con0.argumentsCount(), 0 );
    test.identical( con0.errorsCount(), 0 );
    test.identical( con0.competitorsCount(), 2 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 5 );

    con0.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.is( err === undefined );
      test.is( arg === _.time.out );
    });

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.is( _.errIs( err ) );
      test.is( arg === undefined );
    });

    _.time.out( t*1, function()
    {
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.competitorsCount(), 3 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 6 );
    });

    _.time.out( t*3, function()
    {
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.competitorsCount(), 2 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
    });

    _.time.out( t*8, function()
    {
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.competitorsCount(), 2 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t*15, function()
    {
      test.is( _.strHas( String( con.errorsGet()[ 0 ] ), 'Time out!' ) );
      test.identical( con0.argumentsCount(), 1 );
      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.competitorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  return ready;
}

//

function timeLimitRoutine( test )
{
  let context = this;
  let t = context.t1/4;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function timeLimit1( arg )
  {
    test.case = 'timeOut timeLimit a timeLimitOut';

    var con = _.time.out( t*1 );
    con.timeLimit( t*6, () => _.time.out( t*3, 'a' ) );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 4 );

    con.tap( ( err, arg ) =>
    {
      test.is( err === undefined );
      test.is( arg === 'a' );
    });

    _.time.out( t*1, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 3 );
    });

    _.time.out( t*7, function()
    {
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t*15, function()
    {
      test.is( con.argumentsGet()[ 0 ] === 'a' );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function timeLimit2( arg )
  {
    test.case = 'timeOut timeLimit timeLimitOut a';

    var con = _.time.out( t*1 );
    con.timeLimit( t*5, () => _.time.out( t*10, 'a' ) );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 4 );

    con.tap( ( err, arg ) =>
    {
      test.is( err === undefined );
      test.is( arg === _.time.out );
    });

    _.time.out( t*3, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 3 );
    });

    _.time.out( t*10, function()
    {
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t*20, function()
    {
      test.is( con.argumentsGet()[ 0 ] === _.time.out );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function timeLimit3( arg )
  {
    test.case = 'timeOut-long timeLimit timeLimitOut a';

    var con = _.time.out( t*20 );
    con.timeLimit( t*5, () => _.time.out( t*10, 'a' ) );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 4 );

    con.tap( ( err, arg ) =>
    {
      test.is( err === undefined );
      test.is( arg === _.time.out );
    });

    _.time.out( t*10, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 5 );
    });

    _.time.out( t*20, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 3 );
    });

    return _.time.out( t*50, function()
    {
      test.is( con.argumentsGet()[ 0 ] === _.time.out );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function timeLimit1( arg )
  {
    test.case = 'timeOutError timeLimit a timeLimitOut';

    var con = _.time.outError( t*1 ).tap( ( err, arg ) => _.errAttend( err ) );
    con.timeLimit( t*6, () => _.time.out( t*3, 'a' ) );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 6 );

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.is( _.errIs( err ) );
      test.is( arg === undefined );
    });

    _.time.out( t*1, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
    });

    _.time.out( t*7, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t*15, function()
    {
      test.is( _.strHas( String( con.errorsGet()[ 0 ] ), 'Time out!' ) );
      test.is( con.errorsGet()[ 0 ].reason === 'time out' );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function timeLimit2( arg )
  {
    test.case = 'timeOutError timeLimit timeLimitOut a';

    var con = _.time.outError( t*1 ).tap( ( err, arg ) => _.errAttend( err ) );
    con.timeLimit( t*5, () => _.time.out( t*10, 'a' ) );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 6 );

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.is( _.errIs( err ) );
      test.is( arg === undefined );
    });

    _.time.out( t*3, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
    });

    _.time.out( t*10, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t*20, function()
    {
      test.is( _.strHas( String( con.errorsGet()[ 0 ] ), 'Time out!' ) );
      test.is( con.errorsGet()[ 0 ].reason === 'time out' );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function timeLimit3( arg )
  {
    test.case = 'timeOutError-long timeLimit timeLimitOut a';

    var con = _.time.outError( t*20 );
    con.timeLimit( t*5, () => _.time.out( t*10, 'a' ) );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 5 );

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.is( _.errIs( err ) );
      test.is( arg === undefined );
    });

    _.time.out( t*10, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 6 );
    });

    _.time.out( t*20, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t*50, function()
    {
      test.is( _.strHas( String( con.errorsGet()[ 0 ] ), 'Time out!' ) );
      test.is( con.errorsGet()[ 0 ].reason === 'time out' );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  return ready;
}

//

function timeLimitThrowingRoutine( test )
{
  let context = this;
  let t = context.t1/4;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function timeLimit1( arg )
  {
    test.case = 'timeOut timeLimit a timeLimitOut';

    var con = _.time.out( t*1 );
    con.timeLimitThrowing( t*6, () => _.time.out( t*3, 'a' ) );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 4 );

    con.tap( ( err, arg ) =>
    {
      test.is( err === undefined );
      test.is( arg === 'a' );
    });

    _.time.out( t*1, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 3 );
    });

    _.time.out( t*7, function()
    {
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t*15, function()
    {
      test.is( con.argumentsGet()[ 0 ] === 'a' );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function timeLimit2( arg )
  {
    test.case = 'timeOut timeLimit timeLimitOut a';

    var con = _.time.out( t*1 );
    con.timeLimitThrowing( t*5, () => _.time.out( t*10, 'a' ) );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 4 );

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.is( _.errIs( err ) );
      test.is( arg === undefined );
    });

    _.time.out( t*3, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 3 );
    });

    _.time.out( t*10, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t*20, function()
    {
      test.identical( con.errorsGet()[ 0 ].reason, 'time limit' );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function timeLimit3( arg )
  {
    test.case = 'timeOut-long timeLimit timeLimitOut a';

    var con = _.time.out( t*20 );
    con.timeLimitThrowing( t*5, () => _.time.out( t*10, 'a' ) );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 4 );

    con.tap( ( err, arg ) =>
    {
      test.is( _.errIs( err ) );
      test.is( arg === undefined );
      if( err )
      _.errAttend( err );
    });

    _.time.out( t*10, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 5 );
    });

    _.time.out( t*20, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 3 );
    });

    return _.time.out( t*50, function()
    {
      test.identical( con.errorsGet()[ 0 ].reason, 'time limit' );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function timeLimit1( arg )
  {
    test.case = 'timeOutError timeLimit a timeLimitOut';

    var con = _.time.outError( t*1 );
    con.timeLimitThrowing( t*6, () => _.time.out( t*3, 'a' ) );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 5 );

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.is( _.errIs( err ) );
      test.is( arg === undefined );
    });

    _.time.out( t*1, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
    });

    _.time.out( t*7, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t*15, function()
    {
      test.is( con.errorsGet()[ 0 ].reason === 'time out' );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function timeLimit2( arg )
  {
    test.case = 'timeOutError timeLimit timeLimitOut a';

    var con = _.time.outError( t*1 );
    con.timeLimitThrowing( t*5, () => _.time.out( t*10, 'a' ) );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 5 );

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.is( _.errIs( err ) );
      test.is( arg === undefined );
    });

    _.time.out( t*3, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
    });

    _.time.out( t*10, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t*20, function()
    {
      test.identical( con.errorsGet()[ 0 ].reason, 'time out' );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function timeLimit3( arg )
  {
    test.case = 'timeOutError-long timeLimit timeLimitOut a';

    var con = _.time.outError( t*20 );
    con.timeLimitThrowing( t*5, () => _.time.out( t*10, 'a' ) );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 5 );

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.is( _.errIs( err ) );
      test.is( arg === undefined );
    });

    _.time.out( t*10, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 6 );
    });

    _.time.out( t*20, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t*50, function()
    {
      test.identical( con.errorsGet()[ 0 ].reason, 'time out' );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  return ready;
}

//

function timeLimitThrowingConsequence( test )
{
  let context = this;
  let testMsg = 'value';
  let amode = _.Consequence.AsyncModeGet();
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    test.case = 'passing value';
    var con = _.now().timeLimitThrowing( 0, testMsg );
    test.identical( con.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    return con;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passing an error';
    var err = _.errAttend( testMsg );
    var con = _.now().timeLimitThrowing( 0, err );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    return con.finally( () => null );
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passing consequence';
    var src = new _.Consequence().take( testMsg );
    var con = _.now().timeLimitThrowing( 0, src );
    test.is( src !== con );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    return con;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passing consequence with error';
    var src = new _.Consequence().error( testMsg );
    var con = _.now().timeLimitThrowing( 0, src );
    test.is( src !== con );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    con.catch( ( err ) =>
    {
      test.is( _.strHas( String( err ), testMsg ) );
      return null;
    });
    return con;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passing resolved promise';
    var src = Promise.resolve( testMsg );
    var con = _.now().timeLimitThrowing( 10, src );
    return _.time.out( context.t1, function()
    {
      test.identical( con.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passing resolved promise';
    var src = Promise.resolve( testMsg );
    var con = _.now().timeLimitThrowing( 0, src );
    con.tap( ( err, arg ) =>
    {
      err ? _.errAttend( err ) : null;
    });
    return _.time.out( context.t1, function()
    {
      test.identical( con.errorsGet()[ 0 ].reason, 'time limit' );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passing rejected promise';
    var src = Promise.reject( testMsg );
    var con = _.now().timeLimitThrowing( 10, src );
    con.tap( ( err, arg ) =>
    {
      err ? _.errAttend( err ) : null;
    });
    return _.time.out( context.t1, function()
    {
      test.is( _.strHas( String( con.errorsGet()[ 0 ] ), testMsg ) );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passing rejected promise';
    var src = Promise.reject( _.errAttend( testMsg ) );
    var con = _.now().timeLimitThrowing( 0, src );
    con.tap( ( err, arg ) =>
    {
      err ? _.errAttend( err ) : null;
    });
    return _.time.out( context.t1, function()
    {
      test.identical( con.errorsGet()[ 0 ].reason, 'time limit' );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'sync, resolved promise, timeout';
    var src = Promise.resolve( testMsg );
    var con = _.now().timeLimitThrowing( context.t1*5, src );
    con.give( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 3 );
    return _.time.out( 1, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'sync, promise resolved with timeout';
    var src = new Promise( ( resolve ) =>
    {
      setTimeout( () => resolve( testMsg ), context.t1*2 );
    })
    var con = _.now().timeLimitThrowing( context.t1, src );
    con.finally( ( err, got ) =>
    {
      test.is( _.errIs( err ) );
      if( err )
      _.errAttend( err );
      if( err )
      throw err;
    });
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 3 );
    return _.time.out( context.t1*3, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'sync, timeout, src is a consequence';
    var con = new _.Consequence({ tag : 'con' }).take( testMsg );
    con = _.now().timeLimitThrowing( context.t1, con );
    con.give( ( err, got ) =>
    {
      test.identical( got, testMsg );
    });
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    return null;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'sync, timeout, src is a consequence';
    var con = _.time.out( context.t1*2, () => testMsg );
    con.tag = 'con1';
    con = _.now().timeLimitThrowing( context.t1, con );
    con.tag = 'con2';
    con.give( ( err, got ) =>
    {
      test.is( _.errIs( err ) );
      if( err )
      _.errAttend( err );
    });
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 3 );
    return _.time.out( context.t1*3, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  return ready;
}

timeLimitThrowingConsequence.timeOut = 30000;

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

// --
// and
// --

function andNotDeadLock( test )
{
  let ready =  new _.Consequence();
  let prevReady = ready;
  let readies = [];
  let elements = [ 0, 1 ];
  let got;

  if( !Config.debug )
  return _.dont;

  for( let context = 0 ; context < elements.length ; context++ )
  {
    let currentReady = new _.Consequence();

    test.identical( currentReady._dependsOf, [] );
    if( context === 1 )
    test.identical( prevReady._dependsOf, [ ready ] );
    else
    test.identical( prevReady._dependsOf, [] );

    readies.push( currentReady );
    prevReady.then( currentReady );

    test.identical( currentReady._dependsOf, [ prevReady ] );
    if( context === 1 )
    test.identical( prevReady._dependsOf, [ ready ] );
    else
    test.identical( prevReady._dependsOf, [] );

    prevReady = currentReady;
    currentReady.then( () => context );
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

  let ready = _.after();

  ready.then( () =>
  {
    test.case = 'serial, sync';
    return act( 0, 1 );
  });

  ready.then( () =>
  {
    test.case = 'serial, async';
    return act( 0, 0 );
  });

  ready.then( () =>
  {
    test.case = 'concurrent, sync';
    return act( 0, 1 );
  });

  ready.then( () =>
  {
    test.case = 'concurrent, async';
    return act( 0, 0 );
  });

  /* error */

  ready.then( () =>
  {
    test.case = 'serial, sync, error';
    return act( 0, 1, 'Error!' );
  });

  ready.then( () =>
  {
    test.case = 'serial, async, error';
    return act( 0, 0, 'Error!' );
  });

  ready.then( () =>
  {
    test.case = 'concurrent, sync, error';
    return act( 1, 1, 'Error!' );
  });

  ready.then( () =>
  {
    test.case = 'concurrent, async, error';
    return act( 1, 0, 'Error!' );
  });

  return ready;

  function act( concurrent, sync, error )
  {
    let elements = [ 0, 1 ];
    let gotError, gotArg;

    /* code to use : begin */

    let ready =  new _.Consequence();
    let prevReady = ready;
    let readies = [];

    for( let context = 0 ; context < elements.length ; context++ )
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

      action( currentReady, context );
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

      if( err )
      _.errAttend( err );

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

    function action( currentReady, context )
    {
      if( sync )
      {
        if( error && context === 0 )
        currentReady.then( () => { throw _.errAttend( error ) } );
        else
        currentReady.then( () => elements[ context ] += 10 );
      }
      else
      {
        if( error && context === 0 )
        currentReady.then( () => _.time.out( context.t1*5/2, () => { throw _.errAttend( error ) } ) );
        else
        currentReady.then( () => _.time.out( context.t1*5/2, elements[ context ] += 10 ) );
      }
    }

  }

}

//

function andKeepRoutinesTakeFirst( test )
{
  let context = this;
  var con = _.Consequence();
  var routines =
  [
    () => _.time.out( context.t1, 0 ),
    () => _.time.out( context.t1, 1 ),
    () => _.time.out( context.t1, 2 ),
    () => _.time.out( context.t1, 3 ),
    () => _.time.out( context.t1, 4 ),
    () => _.time.out( context.t1, 5 ),
    () => _.time.out( context.t1, 6 ),
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
  let context = this;
  var con = _.Consequence();
  var routines =
  [
    () => _.time.out( context.t1, 0 ),
    () => _.time.out( context.t1, 1 ),
    () => _.time.out( context.t1, 2 ),
    () => _.time.out( context.t1, 3 ),
    () => _.time.out( context.t1, 4 ),
    () => _.time.out( context.t1, 5 ),
    () => _.time.out( context.t1, 6 ),
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
  let context = this;
  var con = _.Consequence();
  var routines =
  [
    () => _.time.out( context.t1, 0 ),
    () => _.time.out( context.t1, 1 ),
    () => _.time.out( context.t1, 2 ),
    () => _.time.out( context.t1, 3 ),
    () => _.time.out( context.t1, 4 ),
    () => _.time.out( context.t1, 5 ),
    () => _.time.out( context.t1, 6 ),
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

  _.time.out( context.t1*2, () =>
  {
    con.take( null );
    return true;
  });

  return con;
}

//

function andKeepDuplicates( test )
{
  let context = this;
  let ready = _.Consequence().take( null )

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
      test.identical( con1.exportString({ verbosity : 1 }), 'Consequence::con1 1 / 0' );
      test.identical( con2.exportString({ verbosity : 1 }), 'Consequence::con2 1 / 0' );
      test.identical( con3.exportString({ verbosity : 1 }), 'Consequence::con3 1 / 0' );
      test.identical( con1.argumentsGet(), [ 1 ] );
      test.identical( con2.argumentsGet(), [ 2 ] );
      test.identical( con3.argumentsGet(), [ 3 ] );

      if( err )
      throw err;
      return arg;
    })

    _.time.begin( 10, () => con1.take( 1 ) );
    _.time.begin( 20, () => con2.take( 2 ) );
    _.time.begin( 30, () => con3.take( 3 ) );

    return con;
  })

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'mixed take';

    var con = _.Consequence({ capacity : 0 });
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

      test.identical( con1.exportString({ verbosity : 1 }), 'Consequence::con1 1 / 0' );
      test.identical( con2.exportString({ verbosity : 1 }), 'Consequence::con2 1 / 0' );
      test.identical( con3.exportString({ verbosity : 1 }), 'Consequence::con3 1 / 0' );
      test.identical( con1.argumentsGet(), [ 1 ] );
      test.identical( con2.argumentsGet(), [ 2 ] );
      test.identical( con3.argumentsGet(), [ 3 ] );

      if( err )
      throw err;
      return arg;
    })

    _.time.begin( 30, () => con3.take( 3 ) );

    return con;
  })

  return ready;
}

//

function andKeepInstant( test )
{
  let context = this;
  let testMsg = 'msg';
  let ready = new _.Consequence().take( null )

  /*
  instant version should work synchronously, but delayed should work asynchronously
  */

  ready
  .then( function( arg )
  {
    test.case = 'instant check, delayed, main takes later';
    return act( 0 );
  })
  .then( function( arg )
  {
    test.case = 'instant check, instant, main takes later';
    return act( 1 );
  })

  return ready;

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
  let context = this;
  let testMsg = 'msg';
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    test.case = 'andKeep waits only for first resource and return it back';
    let delay = context.t1;
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con = new _.Consequence({ tag : 'con', capacity : 2 });

    mainCon.take( testMsg );

    mainCon.andKeep( con );

    mainCon.finally( function( err, got )
    {
      test.identical( got, [ delay, testMsg ] );
      test.identical( mainCon.resourcesCount(), 0 );
      test.identical( con.resourcesGet(), [{ error : undefined, argument : delay }] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });

    _.time.out( delay, () => { con.take( delay ); return null; });
    _.time.out( delay * 2, () => { con.take( delay * 2 ); return null; });

    return _.time.out( delay * 4, function()
    {
      test.identical( con.resourcesCount(), 2 );
      test.identical( con.resourcesGet()[ 1 ].argument, delay * 2 );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'andKeep waits for first resource from consequence returned by routine call and returns resource back';
    let delay = context.t1;
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con = new _.Consequence({ tag : 'con', capacity : 2 });

    mainCon.take( testMsg );

    mainCon.andKeep( () => con );

    mainCon.finally( function( err, got )
    {
      test.identical( got, [ delay, testMsg ] );
      test.identical( mainCon.resourcesCount(), 0 );
      test.identical( con.resourcesCount(), 1 );
      test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : delay } );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });

    _.time.out( delay, () => { con.take( delay );return null; });
    _.time.out( delay * 2, () => { con.take( delay * 2 );return null; });

    return _.time.out( delay * 4, function()
    {
      test.identical( con.resourcesCount(), 2 );
      test.identical( con.resourcesGet()[ 1 ], { error : undefined, argument : delay * 2 } );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'give back resources to several consequences, different delays';
    let delay = context.t1;
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
      test.identical( mainCon.resourcesCount(), 0 );

      test.identical( con1.resourcesGet(), [ { error : undefined, argument : delay } ]);
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesGet(), [ { error : undefined, argument : delay * 2 } ]);
      test.identical( con2.competitorsEarlyGet().length, 0 );

      test.identical( con3.resourcesGet(), [ { error : undefined, argument : testMsg + testMsg } ]);
      test.identical( con3.competitorsEarlyGet().length, 0 );

      return null;
    });

    _.time.out( delay, () => { con1.take( delay );return null; });
    _.time.out( delay * 2, () => { con2.take( delay * 2 );return null; });
    con3.take( testMsg + testMsg );

    return mainCon;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'each con gives several resources, order of provided consequence is important, order of firing is not';
    let delay = context.t1;
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
      test.identical( mainCon.resourcesCount(), 0 );

      test.identical( con1.resourcesCount(), 3 );
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesCount(), 3 );
      test.identical( con2.competitorsEarlyGet().length, 0 );

      test.identical( con3.resourcesCount(), 3 );
      test.identical( con3.competitorsEarlyGet().length, 0 );

      return null;
    });

    _.time.out( delay / 2, () =>
    {
      con1.take( 'con1' );
      con1.take( 'con1' );
      con1.take( 'con1' );
      return null;
    });

    _.time.out( delay * 2, () =>
    {
      con2.take( 'con2' );
      con2.take( 'con2' );
      con2.take( 'con2' );
      return null;
    });

    _.time.out( delay, () =>
    {
      con3.take( 'con3' );
      con3.take( 'con3' );
      con3.take( 'con3' );
      return null;
    });

    return mainCon;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'each con gives several resources, order of provided consequence is important, order of firing is not';
    let delay = context.t1;
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
      test.identical( mainCon.resourcesCount(), 0 );

      test.identical( con1.resourcesCount(), 3 );
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesCount(), 3 );
      test.identical( con2.competitorsEarlyGet().length, 0 );

      test.identical( con3.resourcesCount(), 3 );
      test.identical( con3.competitorsEarlyGet().length, 0 );

      return null;
    });

    _.time.out( delay, () =>
    {
      con1.take( 'con1' );
      con1.take( 'con1' );
      con1.take( 'con1' );
      return null;
    });

    _.time.out( delay * 2, () =>
    {
      con2.take( 'con2' );
      con2.take( 'con2' );
      con2.take( 'con2' );
      return null;
    });

    _.time.out( delay / 2, () =>
    {
      con3.take( 'con3' );
      con3.take( 'con3' );
      con3.take( 'con3' );
      return null;
    });

    return mainCon;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'one of provided cons waits for another one to resolve';
    let delay = context.t1;
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

      test.identical( mainCon.resourcesCount(), 0 );

      test.identical( con1.resourcesCount(), 0 );
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesCount(), 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

    _.time.out( delay * 2, () => { con2.take( 'con2' ); return null;  } )

    return mainCon;
  })

  /* */

  .then( function( arg )
  {
    test.case =
    `consequence gives an error, only first error is taken into account
     other consequences are receiving their resources back`;

    let delay = context.t1;
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

      test.identical( mainCon.resourcesCount(), 0 );

      test.identical( con1.resourcesCount(), 1 );
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesCount(), 1 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

    _.time.out( delay, () => { con1.error( 'con1' );return null;  } )
    var t = _.time.out( delay * 2, () => { con2.take( 'con2' );return null;  } )

    t.finally( () =>
    {
      test.identical( con2.resourcesCount(), 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return mainCon;
    })

    return t;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passed consequence dont give any resource';
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con = new _.Consequence({ tag : 'con' });
    mainCon.take( null );
    mainCon.andKeep( con );
    mainCon.finally( () => { test.identical( 0, 1); return null; });
    test.identical( mainCon.resourcesCount(), 0 );
    test.identical( mainCon.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesCount(), 0 );

    return _.time.out( 10, function()
    {
      test.identical( mainCon.resourcesCount(), 0 );
      test.identical( mainCon.competitorsEarlyGet().length, 1 );
      test.identical( con.resourcesCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      con.competitorsCancel();
      mainCon.competitorsCancel();
      test.identical( mainCon.resourcesCount(), 0 );
      test.identical( mainCon.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
    });

  })

  /* */

  .then( function( arg )
  {
    test.case = 'returned consequence dont give any resource';
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con = new _.Consequence({ tag : 'con' });
    mainCon.take( null );
    mainCon.andKeep( () => con );
    mainCon.finally( () => { test.identical( 0, 1); return null; });
    test.identical( mainCon.resourcesCount(), 0 );
    test.identical( mainCon.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesCount(), 0 );

    return _.time.out( 10, function()
    {
      test.identical( mainCon.resourcesCount(), 0 );
      test.identical( mainCon.competitorsEarlyGet().length, 1 );
      test.identical( con.resourcesCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      con.competitorsCancel();
      mainCon.competitorsCancel();
      test.identical( mainCon.resourcesCount(), 0 );
      test.identical( mainCon.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
    });

  })

  /* */

  .then( function( arg )
  {
    test.case = 'one of srcs dont give any resource';
    let delay = context.t1;
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });
    var con3 = new _.Consequence({ tag : 'con3' });

    var srcs = [ con1, con2, con3 ];

    mainCon.take( testMsg );

    mainCon.andKeep( srcs );

    mainCon.finally( () => { test.identical( 0, 1); return null; });

    _.time.out( delay, () => { con1.take( delay );return null; });
    _.time.out( delay * 2, () => { con2.take( delay * 2 );return null; });

    return _.time.out( delay * 3, function()
    {

      test.identical( mainCon.resourcesCount(), 0 );
      test.identical( mainCon.competitorsEarlyGet().length, 1 );
      test.identical( con1.resourcesCount(), 0 );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesCount(), 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      test.identical( con3.resourcesCount(), 0 );
      test.identical( con3.competitorsEarlyGet().length, 1 );

      con3.competitorsCancel();
      mainCon.competitorsCancel();

      test.identical( mainCon.resourcesCount(), 0 );
      test.identical( mainCon.competitorsEarlyGet().length, 0 );
      test.identical( con1.resourcesCount(), 0 );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesCount(), 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      test.identical( con3.resourcesCount(), 0 );
      test.identical( con3.competitorsEarlyGet().length, 0 );

    });

  })

  /* */

  return ready;
}

//

function andTake( test )
{
  let context = this;
  let testMsg = 'msg';
  let ready = new _.Consequence().take( null )

   /* */

  .then( function( arg )
  {
    test.case = 'andTake waits only for first resource, dont return the resource';
    let delay = context.t1;
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con = new _.Consequence({ tag : 'con' });

    mainCon.take( testMsg );

    mainCon.andTake( con );

    mainCon.finally( function( err, got )
    {
      test.identical( got, [ delay, testMsg ] )
      test.identical( mainCon.resourcesCount(), 0 );
      test.identical( con.resourcesCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });

    _.time.out( delay, () => { con.take( delay ) });
    _.time.out( delay * 2, () => { con.take( delay * 2 ) });

    return _.time.out( delay * 2, function()
    {
      test.identical( con.resourcesCount(), 1 );
      test.identical( con.resourcesGet()[ 0 ].argument, delay * 2 );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'dont give resource back to single consequence returned from passed routine';
    let delay = context.t1;
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con = new _.Consequence({ tag : 'con' });

    mainCon.take( testMsg );

    mainCon.andTake( () => con );

    mainCon.finally( function( err, got )
    {
      test.identical( got, [ delay, testMsg ] );
      test.identical( mainCon.resourcesCount(), 0 );
      test.identical( con.resourcesCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });

    _.time.out( delay, () => { con.take( delay ); return null; });

    return mainCon;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'dont give resources back to several consequences with different delays';
    let delay = context.t1;
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

      test.identical( mainCon.resourcesCount(), 0 );

      test.identical( con1.resourcesGet(), []);
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesGet(), []);
      test.identical( con2.competitorsEarlyGet().length, 0 );

      test.identical( con3.resourcesGet(), []);
      test.identical( con3.competitorsEarlyGet().length, 0 );

      return null;
    });

    _.time.out( delay, () => { con1.take( delay ); return null; });
    _.time.out( delay * 2, () => { con2.take( delay * 2 ); return null; });
    con3.take( testMsg + testMsg );

    return mainCon;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'each con gives several resources, order of provided consequence is important';
    let delay = context.t1;
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

      test.identical( mainCon.resourcesCount(), 0 );

      test.identical( con1.resourcesCount(), 2 );
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesCount(), 2 );
      test.identical( con2.competitorsEarlyGet().length, 0 );

      test.identical( con3.resourcesCount(), 2 );
      test.identical( con3.competitorsEarlyGet().length, 0 );

      return null;
    });

    _.time.out( delay, () =>
    {
      con1.take( 'con1' );
      con1.take( 'con1' );
      con1.take( 'con1' );
      return null;
    });

    _.time.out( delay * 2, () =>
    {
      con2.take( 'con2' );
      con2.take( 'con2' );
      con2.take( 'con2' );
      return null;
    });

    _.time.out( delay / 2, () =>
    {
      con3.take( 'con3' );
      con3.take( 'con3' );
      con3.take( 'con3' );
      return null;
    });

    return mainCon;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'one of provided cons waits for another one to resolve';
    let delay = context.t1;
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

      test.identical( mainCon.resourcesCount(), 0 );

      test.identical( con1.resourcesCount(), 0 );
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesCount(), 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );

      return null;
    });

    _.time.out( delay * 2, () => { con2.take( 'con2' ); return null; } )

    return mainCon;
  })

  .then( function( arg )
  {
    test.case = 'consequence gives an error, only first error is taken into account';

    let delay = context.t1;
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

      test.identical( mainCon.resourcesCount(), 0 );

      test.identical( con1.resourcesCount(), 0 );
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesCount(), 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );

      return null;
    });

    _.time.out( delay, () => { con1.error( 'con1' );return null;  } )
    var t = _.time.out( delay * 2, () => { con2.take( 'con2' );return null;  } )

    t.finally( () =>
    {
      test.identical( con2.resourcesCount(), 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return mainCon;
    })

    return t;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passed consequence dont give any resource';
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con = new _.Consequence({ tag : 'con' });
    mainCon.take( null );
    mainCon.andTake( con );
    mainCon.finally( () => test.identical( 0, 1 ) );
    test.identical( mainCon.resourcesCount(), 0 );
    test.identical( mainCon.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesCount(), 0 );
    test.identical( con.competitorsCount(), 1 );
    return _.time.out( 10, function()
    {
      test.identical( mainCon.resourcesCount(), 0 );
      test.identical( mainCon.competitorsEarlyGet().length, 1 );
      test.identical( con.resourcesCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      con.competitorsCancel();
      mainCon.competitorsCancel();
      test.identical( mainCon.resourcesCount(), 0 );
      test.identical( mainCon.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
    });
  })

  /* */

  .then( function( arg )
  {
    test.case = 'returned consequence dont give any resource';
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con = new _.Consequence({ tag : 'con' });
    mainCon.take( null );
    mainCon.andTake( () => con );
    mainCon.finally( () => test.identical( 0, 1 ) );
    test.identical( mainCon.resourcesCount(), 0 );
    test.identical( mainCon.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesCount(), 0 );
    test.identical( con.competitorsCount(), 1 );

    return _.time.out( 10, function()
    {
      test.identical( mainCon.resourcesCount(), 0 );
      test.identical( mainCon.competitorsEarlyGet().length, 1 );
      test.identical( con.resourcesCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      con.competitorsCancel();
      mainCon.competitorsCancel();
      test.identical( mainCon.resourcesCount(), 0 );
      test.identical( mainCon.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
    });
  })

  /* */

  .then( function( arg )
  {
    test.case = 'one of srcs dont give any resource';
    let delay = context.t1;
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });
    var con3 = new _.Consequence({ tag : 'con3' });

    var srcs = [ con1, con2, con3 ];

    mainCon.take( testMsg );

    mainCon.andTake( srcs );
    mainCon.finally( () => { test.identical( 0, 1); return null; });

    _.time.out( delay, () => { con1.take( delay ); return null; });
    _.time.out( delay * 2, () => { con2.take( delay * 2 ); return null; });

    return _.time.out( delay * 3, function()
    {

      test.identical( mainCon.resourcesCount(), 0 );
      test.identical( mainCon.competitorsEarlyGet().length, 1 );
      test.identical( con1.resourcesCount(), 0 );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesCount(), 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      test.identical( con3.resourcesCount(), 0 );
      test.identical( con3.competitorsEarlyGet().length, 1 );

      con3.competitorsCancel();
      mainCon.competitorsCancel();

      test.identical( mainCon.resourcesCount(), 0 );
      test.identical( mainCon.competitorsEarlyGet().length, 0 );
      test.identical( con1.resourcesCount(), 0 );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesCount(), 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      test.identical( con3.resourcesCount(), 0 );
      test.identical( con3.competitorsEarlyGet().length, 0 );
    });
  })

  return ready;
}

//

function andKeepAccumulative( test )
{
  let context = this;
  let ready = new _.Consequence();
  let thenArg;
  let callbackDone = [];

  ready.andKeepAccumulative( () =>
  {
    return _.time.out( context.t1*10, () =>
    {
      callbackDone.push( 'a' );
      return 'a'
    });
  });

  ready.andKeepAccumulative( () =>
  {
    return _.time.out( context.t1/10, () =>
    {
      callbackDone.push( 'b' );
      return 'b'
    });
  });

  ready.andKeepAccumulative( () =>
  {
    return _.time.out( context.t1*5, () =>
    {
      callbackDone.push( 'context' );
      return 'context'
    });
  });

  ready.then( ( arg ) =>
  {
    callbackDone.push( '1' );
    thenArg = arg;
    return 1;
  });

  ready.take( 0 );
  callbackDone.push( '0' );

  return _.time.out( context.t1*20, () =>
  {
    test.identical( thenArg, [ 'context', 'b', 'a', 0 ] );
    test.identical( callbackDone, [ '0', 'a', 'b', 'context', '1' ] );
  });
}

//

function alsoKeepTrivialSyncBefore( test )
{
  let context = this;
  let ready = new _.Consequence();
  let thenArg;
  let callbackDone = [];

  callbackDone.push( '0' );
  ready.take( 0 );
  callbackDone.push( '2' );

  ready.alsoKeep( () =>
  {
    callbackDone.push( 'x' );
    return 'x';
  });

  ready.then( ( arg ) =>
  {
    callbackDone.push( '1' );
    thenArg = arg;
    return 1;
  });

  return _.time.out( context.t1*5, () =>
  {
    test.identical( thenArg, [ 0, 'x' ] );
    test.identical( callbackDone, [ '0', '2', 'x', '1' ] );
  });
}

//

function alsoKeepTrivialSyncAfter( test )
{
  let context = this;
  let ready = new _.Consequence();
  let thenArg;
  let callbackDone = [];

  ready.alsoKeep( () =>
  {
    callbackDone.push( 'x' );
    return 'x';
  });

  ready.then( ( arg ) =>
  {
    callbackDone.push( '1' );
    thenArg = arg;
    return 1;
  });

  callbackDone.push( '0' );
  ready.take( 0 );
  callbackDone.push( '2' );

  return _.time.out( context.t1*5, () =>
  {
    test.identical( thenArg, [ 0, 'x' ] );
    test.identical( callbackDone, [ 'x', '0', '1', '2' ] );
  });
}

//

function alsoKeepTrivialAsync( test )
{
  let context = this;
  let ready = new _.Consequence();
  let thenArg;
  let callbackDone = [];

  ready.alsoKeep( () =>
  {
    return _.time.out( context.t1*1, () =>
    {
      callbackDone.push( 'x' );
      return 'x'
    });
  });

  ready.then( ( arg ) =>
  {
    callbackDone.push( '1' );
    thenArg = arg;
    return 1;
  });

  callbackDone.push( '0' );
  ready.take( 0 );
  callbackDone.push( '2' );

  return _.time.out( context.t1*5, () =>
  {
    test.identical( thenArg, [ 0, 'x' ] );
    test.identical( callbackDone, [ '0', '2', 'x', '1' ] );
  });
}

//

function alsoKeep( test )
{
  let context = this;
  let ready = new _.Consequence();
  let thenArg;
  let callbackDone = [];

  ready.alsoKeep( () =>
  {
    return _.time.out( context.t1*10, () =>
    {
      callbackDone.push( 'a' );
      return 'a'
    });
  });

  ready.alsoKeep( () =>
  {
    return _.time.out( context.t1/10, () =>
    {
      callbackDone.push( 'b' );
      return 'b'
    });
  });

  ready.alsoKeep( () =>
  {
    return _.time.out( context.t1*5, () =>
    {
      callbackDone.push( 'context' );
      return 'context'
    });
  });

  ready.alsoKeep( () =>
  {
    callbackDone.push( 'd' );
    return 'd'
  });

  ready.then( ( arg ) =>
  {
    callbackDone.push( '1' );
    thenArg = arg;
    return 1;
  });

  callbackDone.push( '0' );
  ready.take( 0 );
  callbackDone.push( '2' );

  return _.time.out( context.t1*20, () =>
  {
    test.identical( thenArg, [ 0, 'a', 'b', 'context', 'd' ] );
    test.identical( callbackDone, [ 'd', '0', '2', 'b', 'context', 'a', '1' ] );
  });
}

//

function alsoKeepThrowingBeforeSync( test )
{
  let context = this;
  let ready = new _.Consequence();
  let thenArg;
  let callbackDone = [];

  ready.alsoKeep( () =>
  {
    callbackDone.push( 'error1' );
    throw _.errAttend( 'error1' );
  });

  ready.alsoKeep( () =>
  {
    callbackDone.push( 'd' );
    return 'd'
  });

  ready.finally( ( err, arg ) =>
  {
    callbackDone.push( '1' );
    thenArg = err ? err : arg;
    return 1;
  });

  callbackDone.push( '0' );
  ready.take( 0 );
  callbackDone.push( '2' );

  return _.time.out( context.t1*5, () =>
  {
    test.is( _.errIs( thenArg ) );
    test.identical( callbackDone, [ 'error1', 'd', '0', '1', '2' ] );
  });
}

//

function alsoKeepThrowingAfterSync( test )
{
  let context = this;
  let ready = new _.Consequence();
  let thenArg;
  let callbackDone = [];

  ready.alsoKeep( () =>
  {
    callbackDone.push( 'd' );
    return 'd'
  });

  ready.alsoKeep( () =>
  {
    callbackDone.push( 'error1' );
    throw _.errAttend( 'error1' );
  });

  ready.finally( ( err, arg ) =>
  {
    callbackDone.push( '1' );
    thenArg = err ? err : arg;
    return 1;
  });

  callbackDone.push( '0' );
  ready.take( 0 );
  callbackDone.push( '2' );

  return _.time.out( context.t1*5, () =>
  {
    test.is( _.errIs( thenArg ) );
    test.identical( callbackDone, [ 'd', 'error1', '0', '1', '2' ] );
  });
}

//

function alsoKeepThrowingBeforeAsync( test )
{
  let context = this;
  let ready = new _.Consequence().take( null );

  ready.then( () => run( 'alsoKeep', 1 ) );
  ready.then( () => run( 'alsoKeep', 0 ) );
  ready.then( () => run( 'alsoTake', 1 ) );
  ready.then( () => run( 'alsoTake', 0 ) );

  return ready;

  function run( methodName, syncThrowing )
  {
    test.case = `${methodName} sync throwing:${syncThrowing}`;

    let ready = new _.Consequence();
    let thenArg;
    let callbackDone = [];

    ready[ methodName ]( () =>
    {
      if( syncThrowing )
      {
        callbackDone.push( 'error1' );
        throw _.errAttend( 'error1' );
      }
      else
      return _.time.out( context.t1, () =>
      {
        callbackDone.push( 'error1' );
        throw _.errAttend( 'error1' );
      });
    });

    ready[ methodName ]( () =>
    {
      return _.time.out( context.t1*5, () =>
      {
        callbackDone.push( 'a' );
        return 'a'
      });
    });

    let b = _.time.out( context.t1/20, () =>
    {
      callbackDone.push( 'b' );
      return 'b'
    });
    ready[ methodName ]( () => b );

    ready[ methodName ]( () =>
    {
      return _.time.out( context.t1*5/2, () =>
      {
        callbackDone.push( 'context' );
        return 'context'
      });
    });

    ready[ methodName ]( () =>
    {
      callbackDone.push( 'd' );
      return 'd'
    });

    ready.finally( ( err, arg ) =>
    {
      callbackDone.push( '1' );
      thenArg = err ? err : arg;
      return 1;
    });

    callbackDone.push( '0' );
    ready.take( 0 );
    callbackDone.push( '2' );

    return _.time.out( context.t1*10, () =>
    {
      test.is( _.errIs( thenArg ) );
      if( syncThrowing )
      test.identical( callbackDone, [ 'error1', 'd', '0', '2', 'b', 'context', 'a', '1' ] );
      else
      test.identical( callbackDone, [ 'd', '0', '2', 'b', 'error1', 'context', 'a', '1' ] );
      test.identical( b.resourcesCount(), methodName === 'alsoKeep' ? 1 : 0 );
      test.identical( b.errorsCount(), 0 );
    });

  }

}

//

function alsoKeepThrowingAfterAsync( test )
{
  let context = this;
  let ready = new _.Consequence().take( null );

  ready.then( () => run( 'alsoKeep', 1 ) );
  ready.then( () => run( 'alsoKeep', 0 ) );
  ready.then( () => run( 'alsoTake', 1 ) );
  ready.then( () => run( 'alsoTake', 0 ) );

  return ready;

  function run( methodName, syncThrowing )
  {
    test.case = `${methodName} sync throwing:${syncThrowing}`;

    let ready = new _.Consequence();
    let thenArg;
    let callbackDone = [];

    ready[ methodName ]( () =>
    {
      return _.time.out( context.t1*5, () =>
      {
        callbackDone.push( 'a' );
        return 'a'
      });
    });

    let b = _.time.out( context.t1/20, () =>
    {
      callbackDone.push( 'b' );
      return 'b'
    });
    ready[ methodName ]( () => b );

    ready[ methodName ]( () =>
    {
      return _.time.out( context.t1*5/2, () =>
      {
        callbackDone.push( 'context' );
        return 'context'
      });
    });

    ready[ methodName ]( () =>
    {
      callbackDone.push( 'd' );
      return 'd'
    });

    ready[ methodName ]( () =>
    {
      if( syncThrowing )
      {
        callbackDone.push( 'error1' );
        throw _.errAttend( 'error1' );
      }
      else
      return _.time.out( context.t1, () =>
      {
        callbackDone.push( 'error1' );
        throw _.errAttend( 'error1' );
      });
    });

    ready.finally( ( err, arg ) =>
    {
      callbackDone.push( '1' );
      thenArg = err ? err : arg;
      return 1;
    });

    callbackDone.push( '0' );
    ready.take( 0 );
    callbackDone.push( '2' );

    return _.time.out( context.t1*10, () =>
    {
      test.is( _.errIs( thenArg ) );
      if( syncThrowing )
      test.identical( callbackDone, [ 'd', 'error1', '0', '2', 'b', 'context', 'a', '1' ] );
      else
      test.identical( callbackDone, [ 'd', '0', '2', 'b', 'error1', 'context', 'a', '1' ] );
      test.identical( b.resourcesCount(), methodName === 'alsoKeep' ? 1 : 0 );
      test.identical( b.errorsCount(), 0 );
    });

  }

}

//

function _and( test )
{
  let context = this;
  let testMsg = 'msg';
  let delay = context.t1*5;
  let ready = new _.Consequence().take( null )

  /* common wConsequence corespondent tests. */

  .then( function( arg )
  {
    test.case = 'give back resources to src consequences';

    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    mainCon.take( testMsg );

    mainCon._and({ competitors : [ con1, con2 ], keeping : true, accumulative : false, waiting : true, stack : 1 });

    con1.give( ( err, got ) => { test.identical( got, delay ); return null; });
    con2.give( ( err, got ) => { test.identical( got, delay * 2 ); return null; });

    mainCon.finally( function( err, got )
    {
      // at that moment all resources from srcs are processed
      test.identical( con1.resourcesCount(), 0 );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesCount(), 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      test.identical( got, [ delay, delay * 2, testMsg ] );
      return null;
    });

    _.time.out( delay, () => { con1.take( delay );return null; } );
    _.time.out( delay * 2, () => { con2.take( delay * 2 );return null; } );

    return mainCon;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'dont give back resources to src consequences';

    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    mainCon.take( testMsg );

    mainCon._and({ competitors : [ con1, con2 ], keeping : false, accumulative : false, waiting : true, stack : 1 });

    con1.give( ( err, got ) => { test.identical( 0, 1 ); return null; });
    con2.give( ( err, got ) => { test.identical( 0, 1 ); return null; });

    mainCon.finally( function( err, got )
    {
      /* no resources returned back to srcs, their competitors must not be invoked */
      test.identical( con1.resourcesCount(), 0 );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesCount(), 0 );
      test.identical( con2.competitorsEarlyGet().length, 1 );
      test.identical( got, [ delay, delay * 2, testMsg ] );
      return null;
    });

    _.time.out( delay, () => { con1.take( delay ); return null; });
    _.time.out( delay * 2, () => { con2.take( delay * 2 ); return null; });

    return _.time.out( delay * 3, () =>
    {
      test.identical( mainCon.resourcesCount(), 1 );
      test.identical( mainCon.competitorsEarlyGet().length, 0 );
      test.identical( con1.resourcesCount(), 0 );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesCount(), 0 );
      test.identical( con2.competitorsEarlyGet().length, 1 );
      con1.competitorsCancel();
      con2.competitorsCancel();
      test.identical( mainCon.resourcesCount(), 1 );
      test.identical( mainCon.competitorsEarlyGet().length, 0 );
      test.identical( con1.resourcesCount(), 0 );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesCount(), 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });
  })

  return ready;
}

//

function AndKeep( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    test.case = 'andKeep';
    let delay = context.t1;
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    let con = _.Consequence.AndKeep_( con1, con2 );

    con.finally( function( err, got )
    {
      test.identical( got, [ 1, 2 ] );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

    _.time.out( delay, () => { con1.take( 1 ) });
    _.time.out( delay * 2, () => { con2.take( 2 ) });

    return _.time.out( delay * 4, function()
    {
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : null } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  });

  return ready;
}

//

function AndTake( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    test.case = 'andKeep';
    let delay = context.t1;
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    let con = _.Consequence.AndTake_( con1, con2 );

    con.finally( function( err, got )
    {
      test.identical( got, [ 1, 2 ] );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

    _.time.out( delay, () => { con1.take( 1 ) });
    _.time.out( delay * 2, () => { con2.take( 2 ) });

    return _.time.out( delay * 4, function()
    {
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : null } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });
  });

  return ready;
}

//

function And( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    test.case = 'andKeep';
    let delay = context.t1;
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    let con = _.Consequence.And_( con1, con2 );

    con.finally( function( err, got )
    {
      test.identical( got, [ 1, 2 ] );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

    _.time.out( delay, () => { con1.take( 1 ) });
    _.time.out( delay * 2, () => { con2.take( 2 ) });

    return _.time.out( delay * 4, function()
    {
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : null } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  });

  return ready;
}

// --
// or
// --

function orKeepingWithSimple( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
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

    return _.time.out( context.t2, function( err, arg )
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

  .then( function( arg )
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

    return _.time.out( context.t2, function( err, arg )
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

  .then( function( arg )
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
      test.identical( arg, 1 );
      got = arg;

      return arg;
    });

    return _.time.out( context.t2, function( err, arg )
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

  return ready;
}

//

function orKeepingWithLater( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
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

    con1.takeLater( context.t1, 1 );
    con2.takeLater( context.t1/2, 2 );

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

    return _.time.out( context.t1*2, function( err, arg )
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

  .then( function( arg )
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

    con1.takeLater( context.t1, 1 );
    con2.takeLater( context.t1/2, 2 );

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

    return _.time.out( context.t1*2, function( err, arg )
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

  .then( function( arg )
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

    con1.takeLater( context.t1, 1 );
    con2.takeLater( context.t1/2, 2 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 ); /* yyy */
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

    con.takeLater( context.t1*3/2, 0 );

    return _.time.out( context.t1*2, function( err, arg )
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

  /* */

  return ready;
}

//

function orKeepingWithNow( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
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

    return _.time.out( context.t1*2, function( err, arg )
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

  .then( function( arg )
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

    return _.time.out( context.t1*2, function( err, arg )
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

  return ready;
}

//

function orTakingWithSimple( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
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

    return _.time.out( context.t1*2, function( err, arg )
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

  .then( function( arg )
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

    return _.time.out( context.t1*2, function( err, arg )
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

  .then( function( arg )
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
      test.identical( arg, 1 );
      got = arg;

      return arg;
    });

    return _.time.out( context.t1*2, function( err, arg )
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

  return ready;
}

//

function orTakingWithLater( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
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

    con1.takeLater( context.t1*2, 1 );
    con2.takeLater( context.t1/2, 2 );

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

    return _.time.out( context.t1*2, function( err, arg )
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

  .then( function( arg )
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

    con1.takeLater( context.t1, 1 );
    con2.takeLater( context.t1/2, 2 );

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

    return _.time.out( context.t1*2, function( err, arg )
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

  .then( function( arg )
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

    con1.takeLater( context.t1, 1 );
    con2.takeLater( context.t1/2, 2 );

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

    con.takeLater( context.t1*3/2, 0 );

    return _.time.out( context.t1*2, function( err, arg )
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

  return ready;
}

//

function orTakingWithNow( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
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

    return _.time.out( context.t1*2, function( err, arg )
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

  .then( function( arg )
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

    return _.time.out( context.t1*2, function( err, arg )
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

  return ready;
}

//

function orKeepingSplitCanceled( test )
{
  let context = this;
  let ready = _.async();

  /* */

  ready
  .then( function( arg )
  {
    test.case = 'cancel con0';

    let counter = 0;
    let con0 = new _.Consequence();
    let con1 = new _.Consequence();
    let con2 = new _.Consequence();
    let con00 = con0.orKeepingSplit([ con1, con2 ]);

    _.time.out( context.t1/4, () =>
    {

      test.identical( con00.errorsCount(), 0 );
      test.identical( con00.argumentsCount(), 0 );
      test.identical( con00.competitorsCount(), 0 );

      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.competitorsCount(), 1 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 1 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 1 );

      counter += 1;
    })

    _.time.out( context.t1/2, () =>
    {
      con0.cancel();

      test.identical( con00.errorsCount(), 0 );
      test.identical( con00.argumentsCount(), 0 );
      test.identical( con00.competitorsCount(), 0 );

      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.competitorsCount(), 0 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 1 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 1 );

      counter += 1;
    })

    _.time.out( context.t1*3/4, () =>
    {
      con2.take( 'context' )

      test.identical( con00.errorsCount(), 0 );
      test.identical( con00.argumentsCount(), 1 );
      test.identical( con00.competitorsCount(), 0 );

      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.competitorsCount(), 0 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      counter += 1;
    })

    return _.time.out( context.t1*3/2, () =>
    {

      test.identical( con00.errorsCount(), 0 );
      test.identical( con00.argumentsCount(), 1 );
      test.identical( con00.competitorsCount(), 0 );

      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.competitorsCount(), 0 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( counter, 3 );

    });

  });

  /* */

  ready
  .then( function( arg )
  {
    test.case = 'cancel con1';

    let counter = 0;
    let con0 = new _.Consequence();
    let con1 = new _.Consequence();
    let con2 = new _.Consequence();
    let con00 = con0.orKeepingSplit([ con1, con2 ]);

    _.time.out( context.t1/4, () =>
    {

      test.identical( con00.errorsCount(), 0 );
      test.identical( con00.argumentsCount(), 0 );
      test.identical( con00.competitorsCount(), 0 );

      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.competitorsCount(), 1 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 1 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 1 );

      counter += 1;
    })

    _.time.out( context.t1/4, () =>
    {
      con1.cancel();

      test.identical( con00.errorsCount(), 0 );
      test.identical( con00.argumentsCount(), 0 );
      test.identical( con00.competitorsCount(), 0 );

      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.competitorsCount(), 1 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 1 );

      counter += 1;
    })

    _.time.out( context.t1*3/4, () =>
    {
      con2.take( 'context' )

      test.identical( con00.errorsCount(), 0 );
      test.identical( con00.argumentsCount(), 1 );
      test.identical( con00.competitorsCount(), 0 );

      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.competitorsCount(), 0 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      counter += 1;
    })

    return _.time.out( context.t1*3/2, () =>
    {

      test.identical( con00.errorsCount(), 0 );
      test.identical( con00.argumentsCount(), 1 );
      test.identical( con00.competitorsCount(), 0 );

      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.competitorsCount(), 0 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( counter, 3 );

    });

  });

  /* */

  ready
  .then( function( arg )
  {
    test.case = 'cancel con2';

    let counter = 0;
    let con0 = new _.Consequence();
    let con1 = new _.Consequence();
    let con2 = new _.Consequence();
    let con00 = con0.orKeepingSplit([ con1, con2 ]);

    _.time.out( context.t1/4, () =>
    {

      test.identical( con00.errorsCount(), 0 );
      test.identical( con00.argumentsCount(), 0 );
      test.identical( con00.competitorsCount(), 0 );

      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.competitorsCount(), 1 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 1 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 1 );

      counter += 1;
    })

    _.time.out( context.t1/2, () =>
    {
      con2.cancel();

      test.identical( con00.errorsCount(), 0 );
      test.identical( con00.argumentsCount(), 0 );
      test.identical( con00.competitorsCount(), 0 );

      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.competitorsCount(), 1 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 1 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 0 );

      counter += 1;
    })

    _.time.out( context.t1*3/4, () =>
    {
      con2.take( 'context' )

      test.identical( con00.errorsCount(), 0 );
      test.identical( con00.argumentsCount(), 0 );
      test.identical( con00.competitorsCount(), 0 );

      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.competitorsCount(), 1 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 1 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      counter += 1;
    })

    return _.time.out( context.t1*3/2, () =>
    {

      test.identical( con00.errorsCount(), 0 );
      test.identical( con00.argumentsCount(), 0 );
      test.identical( con00.competitorsCount(), 0 );

      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.competitorsCount(), 1 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 1 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( counter, 3 );

      con0.cancel();
      con1.cancel();

    });

  });

  /* */

  return ready;
}

//

function orKeepingCanceled( test )
{
  let context = this;
  let ready = _.async();

  /* */

  ready
  .then( function( arg )
  {
    test.case = 'cancel con0';

    let counter = 0;
    let con0 = new _.Consequence();
    let con1 = new _.Consequence();
    let con2 = new _.Consequence();
    let con00 = con0.orKeeping([ con1, con2 ]);

    test.is( con0 === con00 );

    _.time.out( context.t1/4, () =>
    {

      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.competitorsCount(), 1 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 1 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 1 );

      counter += 1;
    })

    _.time.out( context.t1/2, () =>
    {
      con0.cancel();

      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.competitorsCount(), 0 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 1 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 1 );

      counter += 1;
    })

    _.time.out( context.t1*3/4, () =>
    {
      con2.take( 'context' )

      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.argumentsCount(), 1 );
      test.identical( con0.competitorsCount(), 0 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      counter += 1;
    })

    return _.time.out( context.t1*3/2, () =>
    {

      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.argumentsCount(), 1 );
      test.identical( con0.competitorsCount(), 0 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( counter, 3 );

    });

  });

  /* */

  ready
  .then( function( arg )
  {
    test.case = 'cancel con1';

    let counter = 0;
    let con0 = new _.Consequence();
    let con1 = new _.Consequence();
    let con2 = new _.Consequence();
    let con00 = con0.orKeeping([ con1, con2 ]);

    test.is( con0 === con00 );

    _.time.out( context.t1/4, () =>
    {

      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.competitorsCount(), 1 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 1 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 1 );

      counter += 1;
    })

    _.time.out( context.t1/2, () =>
    {
      con1.cancel();

      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.competitorsCount(), 1 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 1 );

      counter += 1;
    })

    _.time.out( context.t1*3/4, () =>
    {
      con2.take( 'context' )

      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.argumentsCount(), 1 );
      test.identical( con0.competitorsCount(), 0 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      counter += 1;
    })

    return _.time.out( context.t1*3/2, () =>
    {

      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.argumentsCount(), 1 );
      test.identical( con0.competitorsCount(), 0 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( counter, 3 );

    });

  });

  /* */

  ready
  .then( function( arg )
  {
    test.case = 'cancel con2';

    let counter = 0;
    let con0 = new _.Consequence();
    let con1 = new _.Consequence();
    let con2 = new _.Consequence();
    let con00 = con0.orKeeping([ con1, con2 ]);

    test.is( con0 === con00 );

    _.time.out( context.t1/4, () =>
    {

      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.competitorsCount(), 1 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 1 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 1 );

      counter += 1;
    })

    _.time.out( context.t1/2, () =>
    {
      con2.cancel();

      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.competitorsCount(), 1 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 1 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 0 );

      counter += 1;
    })

    _.time.out( context.t1*3/4, () =>
    {
      con2.take( 'context' )

      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.competitorsCount(), 1 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 1 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      counter += 1;
    })

    return _.time.out( context.t1*3/2, () =>
    {

      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.competitorsCount(), 1 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 1 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( counter, 3 );

      con0.cancel();
      con1.cancel();

    });

  });

  /* */

  return ready;
}

//

function afterOrKeepingNotFiring( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
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

    con.afterOrKeeping([ con1, con2 ]);

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

    return _.time.out( context.t1*2, function( err, arg )
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

  .then( function( arg )
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

    con.afterOrKeeping([ con1, con2 ]);

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

    _.time.begin( 1, () => con.take( 10 ) );

    return _.time.out( context.t1*2, function( err, arg )
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

  return ready;
}

//

function afterOrKeepingWithSimple( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    test.case = 'take0, afterOrKeeping, take1, take2';

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

    con.afterOrKeeping([ con1, con2 ]);

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

    return _.time.out( context.t1*2, function( err, arg )
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

  .then( function( arg )
  {
    test.case = 'error0, afterOrKeeping, take1, take2';

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

    con.afterOrKeeping([ con1, con2 ]);

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

    return _.time.out( context.t1*2, function( err, arg )
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

  .then( function( arg )
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

    con.afterOrKeeping([ con1, con2 ]);

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

    return _.time.out( context.t1*2, function( err, arg )
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

  return ready;
}

//

function afterOrKeepingWithLater( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
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

    con.afterOrKeeping([ con1, con2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 1 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 1 );

    con1.takeLater( context.t1, 1 );
    con2.takeLater( context.t1/2, 2 );

    con.finallyGive( ( err, arg ) =>
    {

      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 ); /* yyy */
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

    return _.time.out( context.t1*2, function( err, arg )
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

  .then( function( arg )
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

    con.afterOrKeeping([ con1, con2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con1.takeLater( context.t1, 1 );
    con2.takeLater( context.t1/2, 2 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 ); /* yyy */
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

    return _.time.out( context.t1*2, function( err, arg )
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

  .then( function( arg )
  {
    test.case = 'afterOrKeeping, later take1, later take2, later take0';

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

    con.afterOrKeeping([ con1, con2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con1.takeLater( context.t1, 1 );
    con2.takeLater( context.t1/2, 2 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 ); /* yyy */
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

    con.takeLater( context.t1*3/2, 0 );

    return _.time.out( context.t1*2, function( err, arg )
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

  return ready;
}

//

function afterOrKeepingWithTwoTake0( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    test.case = 'take0, take0, afterOrKeeping, take1';

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

    con.afterOrKeeping([ con1, con2 ]);

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

    return _.time.out( context.t1*2, function( err, arg )
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

  .then( function( arg )
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

    con.afterOrKeeping([ null, con1, null, con2, null ]);

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

    return _.time.out( context.t1*2, function( err, arg )
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

  return ready;
}

//

function afterOrTakingWithSimple( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
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

    con.afterOrTaking([ con1, con2 ]);

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

    return _.time.out( context.t1*2, function( err, arg )
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

  .then( function( arg )
  {
    test.case = 'error0, afterOrTaking, take1, take2';

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

    con.afterOrTaking([ con1, con2 ]);

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

    return _.time.out( context.t1*2, function( err, arg )
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

  .then( function( arg )
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

    con.afterOrTaking([ con1, con2 ]);

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

    return _.time.out( context.t1*2, function( err, arg )
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

  return ready;
}

//

function afterOrTakingWithLater( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
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

    con.afterOrTaking([ con1, con2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 1 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 1 );

    con1.takeLater( context.t1, 1 );
    con2.takeLater( context.t1/2, 2 );

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

    return _.time.out( context.t1*2, function( err, arg )
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

  .then( function( arg )
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

    con.afterOrTaking([ con1, con2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con1.takeLater( context.t1, 1 );
    con2.takeLater( context.t1/2, 2 );

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

    return _.time.out( context.t1*2, function( err, arg )
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

  .then( function( arg )
  {
    test.case = 'afterOrTaking, later take1, later take2, later take0';

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

    con.afterOrTaking([ con1, con2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    con1.takeLater( context.t1, 1 );
    con2.takeLater( context.t1/2, 2 );

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

    con.takeLater( context.t1*3/2, 0 );

    return _.time.out( context.t1*2, function( err, arg )
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

  return ready;
}

//

function afterOrTakingWithTwoTake0( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    test.case = 'take0, take0, afterOrTaking, take1';

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

    con.afterOrTaking([ con1, con2 ]);

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

    return _.time.out( context.t1*2, function( err, arg )
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

  .then( function( arg )
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

    con.afterOrTaking([ null, con1, null, con2, null ]);

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

    return _.time.out( context.t1*2, function( err, arg )
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

  return ready;
}

//

function OrKeep( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )
  let delay = context.t1;

  /* */

  ready
  .then( function( arg )
  {
    test.case = 'delay con1 delay con2';
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });
    var con = _.Consequence.OrKeep( con1, con2 );

    con.finally( function( err, got )
    {
      test.identical( got, 1 );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

    _.time.out( delay, () => { con1.take( 1 ) });
    _.time.out( delay * 2, () => { con2.take( 2 ) });

    return _.time.out( delay * 4, function()
    {
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : null } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  });

  /* */

  ready
  .then( function( arg )
  {
    test.case = 'delay con2 delay con1';
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });
    var con = _.Consequence.OrKeep( con1, con2 );

    con.finally( function( err, got )
    {
      test.identical( got, 2 );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

    _.time.out( delay * 2, () => { con1.take( 1 ) });
    _.time.out( delay * 1, () => { con2.take( 2 ) });

    return _.time.out( delay * 4, function()
    {
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : null } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  });

  /* */

  return ready;
}

//

function OrTake( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )
  let delay = context.t1;

  /* */

  ready
  .then( function( arg )
  {
    test.case = 'delay con1 delay con2';
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });
    var con = _.Consequence.OrTake( con1, con2 );

    con.finally( function( err, got )
    {
      test.identical( got, 1 );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

    _.time.out( delay, () => { con1.take( 1 ) });
    _.time.out( delay * 2, () => { con2.take( 2 ) });

    return _.time.out( delay * 4, function()
    {
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : null } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  });

  /* */

  ready
  .then( function( arg )
  {
    test.case = 'delay con2 delay con1';
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });
    var con = _.Consequence.OrTake( con1, con2 );

    con.finally( function( err, got )
    {
      test.identical( got, 2 );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

    _.time.out( delay * 2, () => { con1.take( 1 ) });
    _.time.out( delay * 1, () => { con2.take( 2 ) });

    return _.time.out( delay * 4, function()
    {
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : null } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  });

  /* */

  return ready;
}

//

function Or( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )
  let delay = context.t1;

  /* */

  ready
  .then( function( arg )
  {
    test.case = 'basic';
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });
    var con = _.Consequence.OrKeep( con1, con2 );

    con.finally( function( err, got )
    {
      test.identical( got, 1 );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

    _.time.out( delay, () => { con1.take( 1 ) });
    _.time.out( delay * 2, () => { con2.take( 2 ) });

    return _.time.out( delay * 4, function()
    {
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : null } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  });

  /* */

  return ready;
}

// --
// cancel
// --

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

function competitorsCancel2( test )
{
  let context = this;
  let con = new _.Consequence();
  con.finally( end );

  var competitor = con.competitorHas( end );
  var procedure = competitor.procedure;
  test.is( !!competitor );
  test.is( !!competitor.procedure );
  test.is( procedure.isAlive() );

  test.identical( con.argumentsCount(), 0 );
  test.identical( con.errorsCount(), 0 );
  test.identical( con.competitorsCount(), 1 );

  con.competitorsCancel( end );

  test.identical( con.argumentsCount(), 0 );
  test.identical( con.errorsCount(), 0 );
  test.identical( con.competitorsCount(), 0 );

  var competitor = con.competitorHas( end );
  test.is( !competitor );
  test.is( !procedure.isAlive() );

  return _.time.out( context.t1 );

  function end( err, got )
  {
    console.log( 'end:', got )
    return got;
  }
}

// --
// advanced
// --

function put( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )

  /* */

  .then( () =>
  {
    var r = trivialSample();
    test.identical( r, 0 );
    return r;
  })
  .then( () =>
  {
    var r = putSample();
    test.identical( r, [ 0, 1 ] );
    return r;
  })
  .then( () =>
  {
    var context = asyncSample();
    test.is( _.consequenceIs( context ) );
    context.finally( ( err, arg ) =>
    {
      test.is( err === undefined );
      test.identical( arg, [ 0, 1, 2 ] );
      if( err )
      throw err;
      return arg;
    });
    return context;
  })

  return ready;

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
      () => { return timeOut( context.t1, 1 ); },
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
    return _.time.out( time, arg ).finally( function( err, arg )
    {
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
  let context = this;
  let amode = _.Consequence.AsyncModeGet();
  let testMsg = 'msg';
  let ready = new _.Consequence().take( null )

  .finally( () =>
  {
    _.Consequence.AsyncModeSet([ 0, 0 ]);
    test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );
    return null;
  })

  /* */

  .then( function( arg )
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

  .then( function( arg )
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

  .then( function( arg )
  {
    test.case = 'routine throws error';
    var con = new _.Consequence({ tag : 'con' });
    con.first( () => { throw _.errAttend( testMsg ) });
    con.finally( function( err, got )
    {
      test.is( _.errIs( err ) );
      if( err )
      _.errAttend( err );
      test.identical( got, undefined );
      test.identical( con.resourcesGet(), [] );
      return null;
    })
    return con;
  })

  /* */

  .then( function( arg )
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

  .then( function( arg )
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

  .then( function( arg )
  {
    test.case = 'routine returns consequence that gives resource with timeout';
    var con = new _.Consequence({ tag : 'con' });
    var timeBefore = _.time.now();
    con.first( () => _.time.out( context.t1*3, () => null ));
    con.finally( function( err, got )
    {
      let delay = _.time.now() - timeBefore;
      var description = test.case = 'delay ' + delay;
      test.ge( delay, context.t1*3 - context.timeAccuracy );
      test.case = description;
      test.identical( err, undefined );
      test.identical( got, null );
      test.identical( con.resourcesGet(), [] );
      return null;
    })
    return con;
  })

  /* */

  .then( function( arg )
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

  .then( function( arg )
  {
    test.case = 'passed consequence shares own resource with timeout';
    var con = new _.Consequence({ tag : 'con' });
    var con2 = _.time.out( context.t1*3, () => testMsg );
    var timeBefore = _.time.now();
    con.first( con2 );
    con.finally( function( err, got )
    {
      let delay = _.time.now() - timeBefore;
      var description = test.case = 'delay ' + delay;
      test.ge( delay, context.t1*3 - context.timeAccuracy );
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
  return ready;
}

//

function firstAsyncMode10( test )
{
  let context = this;
  let amode = _.Consequence.AsyncModeGet();
  let testMsg = 'msg';
  let ready = new _.Consequence().take( null )

  .finally( () =>
  {
    _.Consequence.AsyncModeSet([ 1, 0 ]);
    test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );
    return null;
  })

  /* */

  .then( function( arg )
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

    return _.time.out( 1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesCount(), 1 );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'routine returns something';
    var con = new _.Consequence({ tag : 'con', capacity : 2 });
    con.first( () => testMsg );
    con.take( testMsg + 2 );
    con.give( function( err, got )
    {
      test.identical( got, testMsg );
    })

    return _.time.out( 1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg + 2 }] );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'routine throws error';
    var con = new _.Consequence({ tag : 'con' });
    con.first( () => { throw _.errAttend( testMsg ) });
    con.give( function( err, got )
    {
      test.is( _.errIs( err ) );
      if( err )
      _.errAttend( err );
      test.identical( got, undefined );
      test.identical( con.resourcesGet(), [] );
    })

    return _.time.out( 1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'routine returns consequence with resource';
    var con = new _.Consequence({ tag : 'con' });
    con.first( () => new _.Consequence().take( testMsg ));
    con.give( function( err, got )
    {
      test.identical( err, undefined );
      test.identical( got, testMsg );
    })

    return _.time.out( 1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function( arg )
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
    return _.time.out( 1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'routine returns consequence that gives resource with timeout';
    var con = new _.Consequence({ tag : 'con' });
    var timeBefore = _.time.now();
    con.first( () => _.time.out( context.t1*3, () => null ));
    con.give( function( err, got )
    {
      let delay = _.time.now() - timeBefore;
      var description = test.case = 'delay ' + delay;
      test.ge( delay, context.t1*3 - context.timeAccuracy );
      test.case = description;
      test.identical( err, undefined );
      test.identical( got, null );
      test.identical( con.resourcesGet(), [] );
    })
    return _.time.out( context.t1*3+1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function( arg )
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
    return _.time.out( 1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passed consequence shares own resource with timeout';
    var con = new _.Consequence({ tag : 'con' });
    var con2 = _.time.out( context.t1*3, () => testMsg );
    var timeBefore = _.time.now();
    con.first( con2 );
    con.give( function( err, got )
    {
      let delay = _.time.now() - timeBefore;
      var description = test.case = 'delay ' + delay;
      test.ge( delay, context.t1*3 - context.timeAccuracy );
      test.case = description;
      test.identical( err, undefined );
      test.identical( got, testMsg );
      test.identical( con.resourcesGet(), [] );
      test.identical( con2.resourcesGet(), [{ error : undefined, argument : testMsg }] );
    })
    return _.time.out( context.t1*3+1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesCount(), 0 );
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
  return ready;
}

//

function firstAsyncMode01( test )
{
  let context = this;
  let amode = _.Consequence.AsyncModeGet();
  let testMsg = 'msg';
  let ready = new _.Consequence().take( null )

  .finally( () =>
  {
    _.Consequence.AsyncModeSet([ 0, 1 ]);
    test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );
    return null;
  })

  .then( function( arg )
  {
    test.case = 'simplest, empty routine';
    var con = new _.Consequence({ tag : 'con', capacity : 2 });
    con.give( function( err, got )
    {
      test.identical( err, undefined );
      test.identical( got, null );
    });

    test.identical( con.resourcesCount(), 0 );
    test.identical( con.competitorsCount(), 1 );

    con.first( () => null );

    test.identical( con.resourcesCount(), 1 );
    test.identical( con.competitorsCount(), 1 );

    con.take( testMsg );

    test.identical( con.resourcesCount(), 2 );
    test.identical( con.competitorsCount(), 1 );

    return _.time.out( 1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg }] );
      return null;
    });

  })

  /* */

  .then( function( arg )
  {
    test.case = 'routine returns something';
    var con = new _.Consequence({ tag : 'con', capacity : 2 });
    con.give( function( err, got )
    {
      test.identical( got, testMsg );
    })
    con.first( () => testMsg );

    con.take( testMsg + 2 );

    test.identical( con.resourcesCount(), 2 );
    test.identical( con.competitorsCount(), 1 );

    return _.time.out( 1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg + 2 }] );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'routine throws error';
    var con = new _.Consequence({ tag : 'con' });

    con.first( () => { throw _.errAttend( testMsg ) } );
    test.identical( con.resourcesCount(), 1 );
    test.identical( con.errorsCount(), 1 );
    test.identical( con.argumentsCount(), 0 );

    return _.time.out( 1, function()
    {
      test.identical( con.resourcesCount(), 1 );
      con.give( function( err, got )
      {
        test.is( _.errIs( err ) );
        if( err )
        _.errAttend( err );
        test.identical( got, undefined );
      });
    })
    .then( function( arg )
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'routine returns consequence with resource';
    var con = new _.Consequence({ tag : 'con' });
    con.first( () => new _.Consequence().take( testMsg ) );

    test.identical( con.resourcesCount(), 1 );

    return _.time.out( 1, function()
    {
      test.identical( con.resourcesCount(), 1 );

      con.give( function( err, got )
      {
        test.identical( err, undefined );
        test.identical( got, testMsg );
      })
      return null;
    })
    .then( function( arg )
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'routine returns consequence with err resource';
    var con = new _.Consequence({ tag : 'con' });
    con.first( () => new _.Consequence().error( testMsg ));

    test.identical( con.resourcesCount(), 1 );

    return _.time.out( 1, function()
    {
      test.identical( con.resourcesCount(), 1 );


      con.give( function( err, got )
      {
        test.is( _.strHas( String( err ), testMsg ) );
        test.identical( got, undefined );
      })
      return null;
    })
    .then( function( arg )
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'routine returns consequence that gives resource with timeout';
    var con = new _.Consequence({ tag : 'con' });
    var timeBefore = _.time.now();
    con.first( () => _.time.out( context.t1*1, () => null ));

    test.identical( con.resourcesCount(), 0 );

    return _.time.out( context.t1*3, function()
    {
      test.identical( con.resourcesCount(), 1 );

      con.give( function( err, got )
      {
        let delay = _.time.now() - timeBefore;
        var description = test.case = 'delay ' + delay;
        test.ge( delay, context.t1*3 - context.timeAccuracy );
        test.case = description;
        test.identical( err, undefined );
        test.identical( got, null );
      })
      return null;
    })
    .then( function( arg )
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function( arg )
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

    return _.time.out( 1, function()
    {

      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );

      test.identical( con.resourcesCount(), 1 );

      con.give( function( err, got )
      {
        test.identical( err, undefined );
        test.identical( got, testMsg );
      })
      return null;
    })
    .then( function( arg )
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesCount(), 0 );
      test.identical( con2.resourcesCount(), 1 );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passed consequence shares own resource with timeout';
    var con = new _.Consequence({ tag : 'con' });
    var con2 = _.time.out( context.t1*1, () => testMsg );
    var timeBefore = _.time.now();
    con.first( con2 );

    return _.time.out( context.t1*3, function()
    {
      test.identical( con.resourcesCount(), 1 );

      con.give( function( err, got )
      {
        let delay = _.time.now() - timeBefore;
        var description = test.case = 'delay ' + delay;
        test.ge( delay, context.t1*3 - context.timeAccuracy );
        test.case = description;
        test.identical( err, undefined );
        test.identical( got, testMsg );
      })
      return null;
    })
    .then( function( arg )
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesCount(), 0 );
      test.identical( con2.resourcesCount(), 1 );
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
  return ready;
}

//

function firstAsyncMode11( test )
{
  let context = this;
  let amode = _.Consequence.AsyncModeGet();
  let testMsg = 'msg';
  let ready = new _.Consequence().take( null )

  .finally( () =>
  {
    _.Consequence.AsyncModeSet([ 1, 1 ]);
    test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );
    return null;
  })

  .then( function( arg )
  {
    test.case = 'simplest, empty routine';
    var con = new _.Consequence({ tag : 'con', capacity : 2 });
    con.give( function( err, got )
    {
      test.identical( got, null );
    });
    con.first( () => null );
    con.take( testMsg );

    test.identical( con.argumentsCount(), 2 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );

    return _.time.out( 1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg }] );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'routine returns something';
    var con = new _.Consequence({ tag : 'con', capacity : 2 });
    con.give( function( err, got )
    {
      test.identical( got, testMsg );
    })
    con.first( () => testMsg );

    con.take( testMsg + 2 );

    test.identical( con.argumentsCount(), 2 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );

    return _.time.out( 1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg + 2 }] );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'routine throws error';
    var con = new _.Consequence({ tag : 'con' });
    con.first( () => { throw _.errAttend( testMsg ) });
    con.give( function( err, got )
    {
      test.is( _.errIs( err ) );
      if( err )
      _.errAttend( err );
      test.identical( got, undefined );
    });

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );

    return _.time.out( 1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'routine returns consequence with resource';
    var con = new _.Consequence({ tag : 'con' });
    con.first( () => new _.Consequence().take( testMsg ));
    con.give( function( err, got )
    {
      test.identical( err, undefined );
      test.identical( got, testMsg );
    })
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );

    return _.time.out( 1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'routine returns consequence with err resource';
    var con = new _.Consequence({ tag : 'con' });
    con.first( () => new _.Consequence().error( testMsg ));
    con.give( function( err, got )
    {
      test.is( _.strHas( String( err ), testMsg ) );
      test.identical( got, undefined );
    })
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );

    return _.time.out( 1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'routine returns consequence that gives resource with timeout';
    var con = new _.Consequence({ tag : 'con' });
    var timeBefore = _.time.now();
    con.first( () => _.time.out( context.t1*3, () => null ));
    con.give( function( err, got )
    {
      let delay = _.time.now() - timeBefore;
      var description = test.case = 'delay ' + delay;
      test.ge( delay, context.t1*3 - context.timeAccuracy );
      test.case = description;
      test.identical( err, undefined );
      test.identical( got, null );
    })
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );

    return _.time.out( context.t1*3+1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function( arg )
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

    return _.time.out( 5, function()
    {

      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );

      test.identical( con.competitorsCount(), 0 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.errorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passed consequence shares own resource with timeout';
    var con = new _.Consequence({ tag : 'con' });
    var con2 = _.time.out( context.t1*3, () => testMsg );
    var timeBefore = _.time.now();
    con.first( con2 );
    con.give( function( err, got )
    {
      let delay = _.time.now() - timeBefore;
      var description = test.case = 'delay ' + delay;
      test.ge( delay, context.t1*3 - context.timeAccuracy );
      test.case = description;
      test.identical( err, undefined );
      test.identical( got, testMsg );
    })
    return _.time.out( context.t1*3+1, function()
    {
      test.identical( con.competitorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.errorsCount(), 0 );
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
  return ready;
}

// --
// experimental
// --

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

//

/*
zzz : implement con1.then( con )
*/

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

  return _.time.out( context.t1*10, () =>
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
    return _.time.out( context.t1/2, () =>
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
    return _.time.out( context.t1/2, () =>
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
    return _.time.out( context.t1/2, () =>
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
    return _.time.out( context.t1/2, () =>
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
    return _.time.out( context.t1/2, () =>
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

  name : 'Tools.base.Consequence',
  silencing : 1,
  routineTimeOut : 30000,

  context :
  {
    timeAccuracy : 1,
    t1 : 100,
    t2 : 500,
  },

  tests :
  {

    // inter

    consequenceIs,
    consequenceLike,
    clone,

    // from

    fromAsyncMode00,
    fromAsyncMode10,
    fromAsyncMode01,
    fromAsyncMode11,

    fromPromiseWithUndefined,
    fromCustomPromise,
    consequenceAwait,

    // export

    toStr,
    stringify,

    // etc

    trivial,
    fields,

    // take

    ordinarResourceAsyncMode00,
    ordinarResourceAsyncMode10,
    ordinarResourceAsyncMode01,
    ordinarResourceAsyncMode11,

    takeAll,

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

    //

    deasync,

    split,
    tap,
    tapHandling,

    catchTestRoutine,
    ifNoErrorGotTrivial,
    ifNoErrorGotThrowing,
    keep,

    timeOut,
    timeLimitSplit,
    timeLimitThrowingSplit,
    timeLimitConsequence,
    timeLimitRoutine,
    timeLimitThrowingRoutine,
    timeLimitThrowingConsequence,

    notDeadLock1,

    // and

    andNotDeadLock,
    andConcurrent,
    andKeepRoutinesTakeFirst,
    andKeepRoutinesTakeLast,
    andKeepRoutinesDelayed,
    andKeepDuplicates,
    andKeepInstant,
    andKeep,
    andTake,
    andKeepAccumulative,
    alsoKeepTrivialSyncBefore,
    alsoKeepTrivialSyncAfter,
    alsoKeepTrivialAsync,
    alsoKeep,
    alsoKeepThrowingBeforeSync,
    alsoKeepThrowingAfterSync,
    alsoKeepThrowingBeforeAsync,
    alsoKeepThrowingAfterAsync,
    _and,
    AndKeep,
    AndTake,
    And,

    // or

    orKeepingWithSimple,
    orKeepingWithLater,
    orKeepingWithNow,
    orTakingWithSimple,
    orTakingWithLater,
    orTakingWithNow,
    orKeepingSplitCanceled,
    orKeepingCanceled,

    afterOrKeepingNotFiring,
    afterOrKeepingWithSimple,
    afterOrKeepingWithLater,
    afterOrKeepingWithTwoTake0,
    afterOrTakingWithSimple,
    afterOrTakingWithLater,
    afterOrTakingWithTwoTake0,

    OrKeep,
    OrTake,
    Or,

    // cancel

    competitorsCancelSingle,
    competitorsCancel,
    competitorsCancel2,

    // advanced

    put,

    firstAsyncMode00,
    firstAsyncMode10,
    firstAsyncMode01,
    firstAsyncMode11,

    // experimental

    thenSequenceSync,
    // thenSequenceAsync,

  },

};

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
