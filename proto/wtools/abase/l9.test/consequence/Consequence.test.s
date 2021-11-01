( function _Consequence_test_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( '../../../../node_modules/Tools' );

  _.include( 'wTesting' );
  // _.include( 'wLogger' );
  // _.include( 'wProcess' );

  require( '../../l9/consequence/Namespace.s' );
}

const _global = _global_;
const _ = _global_.wTools;

// --
// inter
// --

/* qqq : extend test for Consequence from different global namespace */
/* qqq : extend test for custom Consequence */
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
  test.true( !_.consequenceLike() );

  test.case = 'map';
  test.true( !_.consequenceLike( {} ) );

  test.case = 'consequence';
  test.true( _.consequenceLike( new _.Consequence() ) );
  test.true( _.consequenceLike( _.Consequence() ) );

  test.case = 'consequecne with resource';
  var src = new _.Consequence().take( 0 );
  var got = _.consequenceLike( src );
  test.identical( got, true );

  test.case = 'promise';
  test.true( _.consequenceLike( Promise.resolve( 0 ) ) );
  var promise = new Promise( ( resolve, reject ) => { resolve( 0 ) } )
  test.true( _.consequenceLike( promise ) );
  test.true( _.consequenceLike( _.Consequence.From( promise ) ) );

}

//

function clone( test )
{
  let context = this;

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
  test.true( con1._resources !== con2._resources );
  test.true( con1._competitorsEarly !== con2._competitorsEarly );
  test.true( con1._competitorsLate !== con2._competitorsLate );

  test.case = 'consequence with competitor';
  var con1 = new _.Consequence({ tag : 'con1', capacity : 2 });
  var f = () => undefined;
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
  test.true( con1._resources !== con2._resources );
  test.true( con1._competitorsEarly !== con2._competitorsEarly );
  test.true( con1._competitorsLate !== con2._competitorsLate );

  test.identical( _.Procedure.Find( f ).length, 1 );
  con2.cancel();
  test.identical( _.Procedure.Find( f ).length, 1 );
  con1.cancel();
  test.identical( _.Procedure.Find( f ).length, 0 );

}

// --
// from
// --

function fromAsyncMode00( test )
{
  let context = this;
  let amode = _.Consequence.AsyncModeGet();
  let ready = new _.Consequence().take( null )

  /* */

  // .finally( () =>
  // {
  //   _.Consequence.AsyncModeSet([ 0, 0 ]);
  //   test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );
  //   return null;
  // })

  /* */

  .then( function( arg )
  {
    test.case = 'passing value';
    var con = _.Consequence.From( 'str' );
    test.identical( con.resourcesGet(), [ { error : undefined, argument : 'str' } ] );
    test.identical( con.competitorsCount(), 0 );
    return con;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passing an error';
    var err = _.errAttend( 'str' );
    var con = _.Consequence.From( err );
    test.identical( con.resourcesGet(), [ { error : err, argument : undefined } ] );
    test.identical( con.competitorsCount(), 0 );
    return con.finally( () => null );
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passing consequence';
    var src = new _.Consequence().take( 'str' );
    var con = _.Consequence.From( src );
    test.identical( con, src );
    test.identical( con.resourcesGet(), [ { error : undefined, argument : 'str' } ] );
    test.identical( con.competitorsCount(), 0 );
    return con;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passing resolved promise';
    var src = Promise.resolve( 'str' );
    var con = _.Consequence.From( src );
    return _.time.out( 1, function()
    {
      test.identical( con.resourcesGet(), [ { error : undefined, argument : 'str' } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passing rejected promise';
    var src = Promise.reject( 'str' );
    var con = _.Consequence.From( src );
    return _.time.out( 1, function()
    {
      test.true( _.strHas( String( con.errorsGet()[ 0 ] ), 'str' ) );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* */

  .then( function( arg )
  {
    test.case = 'sync, resolved promise, timeout';
    var src = Promise.resolve( 'str' );
    // var con = _.Consequence.From( src, context.t1*5 );
    var con = _.Consequence.TimeLimitError( context.t1*5, src );
    con.give( ( err, got ) => /* qqq : rename all err, got -> err, arg */
    {
      test.identical( got, 'str' );
      test.identical( err, undefined );
      return null;
    });
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
      setTimeout( () => resolve( 'str' ), context.t1*2 );
    })
    // var con = _.Consequence.From( src, context.t1 );
    var con = _.Consequence.TimeLimitError( context.t1, src );
    con.finally( ( err, got ) =>
    {
      test.true( _.errIs( err ) );
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
    var con = new _.Consequence({ tag : 'con' }).take( 'str' );
    // con = _.Consequence.From( con, context.t1 );
    con = _.Consequence.TimeLimitError( context.t1, con );
    con.give( ( err, got ) =>
    {
      test.identical( got, 'str' );
      test.identical( err, undefined );
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
    var con = _.time.out( context.t1*2, () => 'str' );
    con.tag = 'con1';
    // con = _.Consequence.From( con, context.t1 );
    // con = _.Consequence.TimeLimitError( context.t1, con );
    con = con.timeLimitErrorSplit( context.t1 );
    con.tag = 'con2';
    con.give( ( err, got ) =>
    {
      test.true( _.errIs( err ) );
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

  // .finally( ( err, arg ) =>
  // {
  //   test.close( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );
  //   _.Consequence.AsyncModeSet( amode );
  //   if( err )
  //   throw err;
  //   return arg;
  //
  // })

  /* */

  return ready;
}

fromAsyncMode00.timeOut = 30000;

//

// function fromAsyncMode10( test )
// {
//   let amode = _.Consequence.AsyncModeGet();
//   let ready = new _.Consequence().take( null )
//
//   /* */
//
//   .finally( () =>
//   {
//     _.Consequence.AsyncModeSet([ 1, 0 ]);
//     test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );
//     return null;
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async competitors adding, passing value';
//     var con = _.Consequence.From( 'str' );
//     con.give( ( err, got ) =>
//     {
//       test.identical( got, 'str' );
//       test.identical( err, undefined );
//     });
//     test.identical( con.resourcesGet(), [ { error : undefined, argument : 'str' } ] );
//     test.identical( con.competitorsCount(), 1 );
//     return _.time.out( 1, function()
//     {
//       test.identical( con.resourcesGet(), [] );
//       test.identical( con.competitorsCount(), 0 );
//       return null;
//     });
//
//     return con;
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async competitors adding, passing an error';
//     var src = _.errAttend( 'str' );
//     var con = _.Consequence.From( src );
//     con.give( ( err, got ) => test.true( err === src ) );
//     test.identical( con.resourcesGet(), [ { error : src, argument : undefined } ] );
//     test.identical( con.competitorsCount(), 1 );
//     return _.time.out( 1, function()
//     {
//       test.identical( con.resourcesGet(), [] );
//       test.identical( con.competitorsCount(), 0 );
//       return null;
//     })
//
//     return con;
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async competitors adding, passing consequence';
//     var src = new _.Consequence().take( 'str' );
//     var con = _.Consequence.From( src );
//     con.give( ( err, got ) =>
//     {
//       test.identical( got, 'str' );
//       test.identical( err, undefined );
//     });
//     test.identical( src.resourcesGet(), [ { error : undefined, argument : 'str' } ] );
//     test.identical( con.competitorsCount(), 1 );
//     test.identical( con, src );
//     return _.time.out( 1, function()
//     {
//       test.identical( con.resourcesGet(), [] );
//       test.identical( con.competitorsCount(), 0 );
//       return null;
//     })
//
//     return con;
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async competitors adding, passing resolved promise';
//     var src = Promise.resolve( 'str' );
//     var con = _.Consequence.From( src );
//     con.give( ( err, got ) =>
//     {
//       test.identical( got, 'str' );
//       test.identical( err, undefined );
//     });
//     test.identical( con.competitorsCount(), 1 );
//     test.identical( con.resourcesCount(), 0 )
//     return _.time.out( 1, function()
//     {
//       test.identical( con.resourcesCount(), 0 )
//       test.identical( con.competitorsCount(), 0 )
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async competitors adding, passing rejected promise';
//     var src = Promise.reject( 'str' );
//     var con = _.Consequence.From( src );
//     con.give( ( err, got ) => test.true( _.strHas( String( err ), 'str' ) ) );
//     test.identical( con.competitorsCount(), 1 );
//     test.identical( con.resourcesCount(), 0 )
//     return _.time.out( 1, function()
//     {
//       test.identical( con.resourcesCount(), 0 )
//       test.identical( con.competitorsCount(), 0 )
//       return null;
//     })
//   })
//
//   /* */
//
//   .finally( ( err, arg ) =>
//   {
//     test.close( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );
//
//     _.Consequence.AsyncModeSet( amode );
//
//
//     if( err )
//     throw err;
//     return arg;
//
//   })
//   return ready;
// }
//
// //
//
// function fromAsyncMode01( test )
// {
//   let amode = _.Consequence.AsyncModeGet();
//   let ready = new _.Consequence().take( null )
//
//   /* */
//
//   .finally( () =>
//   {
//     _.Consequence.AsyncModeSet([ 0, 1 ]);
//     test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );
//     return null;
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async resources adding passing value';
//     var con = _.Consequence.From( 'str' );
//     test.identical( con.resourcesGet(), [ { error : undefined, argument : 'str' } ] );
//     con.give( ( err, got ) =>
//     {
//       test.identical( got, 'str' );
//       test.identical( err, undefined );
//     });
//     test.identical( con.resourcesGet(), [] );
//     return _.time.out( 1, function()
//     {
//       test.identical( con.resourcesGet(), [] );
//       test.identical( con.competitorsCount(), 0 );
//       return null;
//     })
//
//     return con;
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'passing an error';
//     var src = _.errAttend( 'str' );
//     var con = _.Consequence.From( src );
//     test.identical( con.resourcesGet(), [ { error : src, argument : undefined } ] );
//     // con.give( ( err, got ) => test.true( _.strHas( String( err ), src ) ) );
//     con.give( ( err, got ) => test.true( err === src ) );
//     test.identical( con.resourcesGet(), [] );
//     return _.time.out( 1, function()
//     {
//       test.identical( con.resourcesGet(), [] );
//       test.identical( con.competitorsCount(), 0 );
//       return null;
//     })
//
//     return con;
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'passing consequence';
//     var src = new _.Consequence().take( 'str' );
//     var con = _.Consequence.From( src );
//     test.identical( src.resourcesGet(), [ { error : undefined, argument : 'str' } ] );
//     con.give( ( err, got ) =>
//     {
//       test.identical( got, 'str' );
//       test.identical( err, undefined );
//     });
//     test.identical( src.resourcesGet(), [] );
//     test.identical( con, src );
//     return _.time.out( 1, function()
//     {
//       test.identical( con.resourcesGet(), [] );
//       test.identical( con.competitorsCount(), 0 );
//       return null;
//     })
//
//     return con;
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'passing resolved promise';
//     var src = Promise.resolve( 'str' );
//     var con = _.Consequence.From( src );
//     con.give( ( err, got ) =>
//     {
//       test.identical( got, 'str' );
//       test.identical( err, undefined );
//     });
//     test.identical( con.resourcesCount(), 0 )
//     return _.time.out( 1, function()
//     {
//       test.identical( con.resourcesCount(), 0 )
//       test.identical( con.competitorsCount(), 0 )
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'passing rejected promise';
//     var src = Promise.reject( 'str' );
//     var con = _.Consequence.From( src );
//     con.give( ( err, got ) => test.true( _.strHas( String( err ), 'str' ) ) );
//     test.identical( con.resourcesCount(), 0 )
//     return _.time.out( 1, function()
//     {
//       test.identical( con.resourcesCount(), 0 )
//       test.identical( con.competitorsCount(), 0 )
//       return null;
//     })
//   })
//
//   /* */
//
//   .finally( ( err, arg ) =>
//   {
//     test.close( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );
//
//     _.Consequence.AsyncModeSet( amode );
//
//
//     if( err )
//     throw err;
//     return arg;
//
//   })
//   return ready;
// }
//
// //
//
// function fromAsyncMode11( test )
// {
//   let amode = _.Consequence.AsyncModeGet();
//   let ready = new _.Consequence().take( null )
//
//   /* */
//
//   .finally( () =>
//   {
//     _.Consequence.AsyncModeSet([ 1, 1 ]);
//     test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );
//     return null;
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async, passing value';
//     var con = _.Consequence.From( 'str' );
//     con.give( ( err, got ) =>
//     {
//       test.identical( got, 'str' );
//       test.identical( err, undefined );
//     });
//     test.identical( con.resourcesGet(), [ { error : undefined, argument : 'str' } ] );
//     test.identical( con.competitorsCount(), 1 );
//     return _.time.out( 1, function()
//     {
//       test.identical( con.resourcesGet(), [] );
//       test.identical( con.competitorsCount(), 0 );
//       return null;
//     })
//
//     return con;
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async, passing an error';
//     var src = _.errAttend( 'str' );
//     var con = _.Consequence.From( src );
//     con.give( ( err, got ) => test.true( err === src ) );
//     test.identical( con.resourcesGet(), [ { error : src, argument : undefined } ] );
//     test.identical( con.competitorsCount(), 1 );
//     return _.time.out( 1, function()
//     {
//       test.identical( con.resourcesGet(), [] );
//       test.identical( con.competitorsCount(), 0 );
//       return null;
//     })
//
//     return con;
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async, passing consequence';
//     var src = new _.Consequence().take( 'str' );
//     var con = _.Consequence.From( src );
//     con.give( ( err, got ) =>
//     {
//       test.identical( got, 'str' );
//       test.identical( err, undefined );
//     });
//     test.identical( src.resourcesGet(), [ { error : undefined, argument : 'str' } ] );
//     test.identical( con.competitorsCount(), 1 );
//     test.identical( con, src );
//     return _.time.out( 1, function()
//     {
//       test.identical( con.resourcesGet(), [] );
//       test.identical( con.competitorsCount(), 0 );
//       return null;
//     })
//
//     return con;
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async, passing resolved promise';
//     var src = Promise.resolve( 'str' );
//     var con = _.Consequence.From( src );
//     con.give( ( err, got ) =>
//     {
//       test.identical( got, 'str' );
//       test.identical( err, undefined );
//     });
//     test.identical( con.competitorsCount(), 1 );
//     test.identical( con.resourcesCount(), 0 )
//     return _.time.out( 1, function()
//     {
//       test.identical( con.resourcesCount(), 0 )
//       test.identical( con.competitorsCount(), 0 )
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async, passing rejected promise';
//     var src = Promise.reject( 'str' );
//     var con = _.Consequence.From( src );
//     con.give( ( err, got ) => test.true( _.strHas( String( err ), 'str' ) ) );
//     test.identical( con.competitorsCount(), 1 );
//     test.identical( con.resourcesCount(), 0 )
//     return _.time.out( 1, function()
//     {
//       test.identical( con.resourcesCount(), 0 )
//       test.identical( con.competitorsCount(), 0 )
//       return null;
//     })
//   })
//
//   /* */
//
//   .finally( ( err, arg ) =>
//   {
//     test.close( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );
//
//     _.Consequence.AsyncModeSet( amode );
//
//
//     if( err )
//     throw err;
//     return arg;
//
//   })
//   return ready;
// }

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
    let f = async () => new _.Consequence().error( 'Some error' )
    return test.shouldThrowErrorAsync( () => _.Consequence.From( f() ) )
  }

}

// --
// export
// --

function toStr( test )
{

  test.case = 'toStrFine';
  var con1 = _.Consequence();
  var exp = 'Consequence:: 0 / 0';
  var got = _.entity.exportStringFine( con1 );
  test.identical( got, exp );

  act( 'toStr' );
  act( 'toString' );

  function act( rname )
  {

    test.open( 'verbosity:2' );

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

    test.close( 'verbosity:2' );

    /* - */
    test.open( 'verbosity:1' );

    test.case = 'empty';
    var con1 = _.Consequence();
    var exp = 'Consequence:: 0 / 0';
    var got = con1[ rname ]({ verbosity : 1 });
    test.identical( got, exp );

    test.case = 'tagged';
    var con1 = _.Consequence({ tag : 'con1' });
    var exp = 'Consequence::con1 0 / 0';
    var got = con1[ rname ]({ verbosity : 1 });
    test.identical( got, exp );

    test.case = 'has compatitor';
    var con1 = _.Consequence().then( () => null );
    var exp = 'Consequence:: 0 / 1';
    var got = con1[ rname ]({ verbosity : 1 });
    test.identical( got, exp );
    con1.take( null );

    test.case = 'has argument';
    var con1 = _.Consequence().take( null );
    var exp = 'Consequence:: 1 / 0';
    var got = con1[ rname ]({ verbosity : 1 });
    test.identical( got, exp );

    test.case = 'has error';
    var con1 = _.Consequence().error( _.errAttend( 'error1' ) );
    var exp = 'Consequence:: 1 / 0';
    var got = con1[ rname ]({ verbosity : 1 });
    test.identical( got, exp );

    test.close( 'verbosity:1' );

    /* - */

    test.open( 'no arguments' );

    test.case = 'empty';
    var con1 = _.Consequence();
    var exp = 'Consequence:: 0 / 0';
    var got = con1[ rname ]();
    test.identical( got, exp );

    test.case = 'tagged';
    var con1 = _.Consequence({ tag : 'con1' });
    var exp = 'Consequence::con1 0 / 0';
    var got = con1[ rname ]();
    test.identical( got, exp );

    test.case = 'has compatitor';
    var con1 = _.Consequence().then( () => null );
    var exp = 'Consequence:: 0 / 1';
    var got = con1[ rname ]();
    test.identical( got, exp );
    con1.take( null );

    test.case = 'has argument';
    var con1 = _.Consequence().take( null );
    var exp = 'Consequence:: 1 / 0';
    var got = con1[ rname ]();
    test.identical( got, exp );

    test.case = 'has error';
    var con1 = _.Consequence().error( _.errAttend( 'error1' ) );
    var exp = 'Consequence:: 1 / 0';
    var got = con1[ rname ]();
    test.identical( got, exp );

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
// take
// --

function ordinarResourceAsyncMode00( test )
{
  let context = this;
  let amode = _.Consequence.AsyncModeGet();
  let ready = new _.Consequence().take( null )

  /* */

  // .finally( () =>
  // {
  //   test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );
  //   test.case = 'single resource';
  //   _.Consequence.AsyncModeSet([ 0, 0 ]);
  //   return null;
  // })

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
    con.take( 1 )
    .take( 2 )
    .take( 3 );
    test.identical( con.resourcesCount(), 3 );
    con.give( ( err, got ) => test.identical( got, 1 ) && test.identical( err, undefined ) );
    con.give( ( err, got ) => test.identical( got, 2 ) && test.identical( err, undefined ) );
    con.give( ( err, got ) => test.identical( got, 3 ) && test.identical( err, undefined ) );
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
      test.true( !!err );
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
    con.error( _.errAttend( 'err1' ) )
    .error( _.errAttend( 'err2' ) )
    .error( _.errAttend( 'err3' ) );
    test.identical( con.resourcesCount(), 3 );
    con.give( ( err, got ) => test.true( !!err ) );
    con.give( ( err, got ) => test.true( !!err ) );
    con.give( ( err, got ) => test.true( !!err ) );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con.resourcesCount(), 0 );
    return null;
  })

  /* */

  // .finally( ( err, arg ) =>
  // {
  //   test.close( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );
  //   _.Consequence.AsyncModeSet( amode );
  //   if( err )
  //   throw err;
  //   return arg;
  // })

  return ready;
}

//

// function ordinarResourceAsyncMode10( test )
// {
//   let context = this;
//   let amode = _.Consequence.AsyncModeGet();
//   let ready = new _.Consequence().take( null )
//
//   /* */
//
//   .finally( () =>
//   {
//     test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );
//
//     test.case = 'single resource';
//     _.Consequence.AsyncModeSet([ 1, 0 ]);
//     return null;
//   })
//   .then( function( arg )
//   {
//     var con = new _.Consequence({ tag : 'con' });
//     con.take( 1 );
//     test.identical( con.resourcesCount(), 1 );
//     con.give( function( err, got )
//     {
//       test.identical( err, undefined )
//       test.identical( got, 1 );
//     })
//     test.identical( con.resourcesCount(), 1 );
//     test.identical( con.competitorsCount(), 1 );
//     return _.time.out( 1, function()
//     {
//       test.identical( con.resourcesCount(), 0 );
//       test.identical( con.competitorsCount(), 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .finally( () =>
//   {
//     test.case = 'several resources';
//     return null;
//   })
//   .then( function( arg )
//   {
//     var con = new _.Consequence({ tag : 'con', capacity : 3 });
//     con.take( 1 )
//     .take( 2 )
//     .take( 3 );
//     con.give( ( err, got ) => test.identical( got, 1 ) && test.identical( err, undefined ) );
//     con.give( ( err, got ) => test.identical( got, 2 ) && test.identical( err, undefined ) );
//     con.give( ( err, got ) => test.identical( got, 3 ) && test.identical( err, undefined ) );
//     test.identical( con.competitorsCount(), 3 );
//     test.identical( con.resourcesCount(), 3 );
//     return _.time.out( 1, function()
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesCount(), 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .finally( () =>
//   {
//     test.case = 'single error';
//     return null;
//   })
//   .then( function( arg )
//   {
//     var con = new _.Consequence({ tag : 'con' });
//     con.error( _.errAttend( 'err' ) );
//     test.identical( con.resourcesCount(), 1 );
//     con.give( function( err, got )
//     {
//       test.true( !!err );
//       test.identical( got, undefined );
//     })
//     test.identical( con.resourcesCount(), 1 );
//     test.identical( con.competitorsCount(), 1 );
//     return _.time.out( 1, function()
//     {
//       test.identical( con.resourcesCount(), 0 );
//       test.identical( con.competitorsCount(), 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .finally( () =>
//   {
//     test.case = 'several error'
//     return null;
//   })
//   .then( function( arg )
//   {
//     var con = new _.Consequence({ tag : 'con', capacity : 3 });
//     con.error( _.errAttend( 'err1' ) )
//     .error( _.errAttend( 'err2' ) )
//     .error( _.errAttend( 'err3' ) );
//     con.give( ( err, got ) => test.true( !!err ) );
//     con.give( ( err, got ) => test.true( !!err ) );
//     con.give( ( err, got ) => test.true( !!err ) );
//     test.identical( con.competitorsCount(), 3 );
//     test.identical( con.resourcesCount(), 3 );
//     return _.time.out( 1, function()
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesCount(), 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .finally( ( err, arg ) =>
//   {
//     test.close( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );
//
//     _.Consequence.AsyncModeSet( amode );
//
//
//     if( err )
//     throw err;
//     return arg;
//
//   })
//   return ready;
// }
//
// //
//
// function ordinarResourceAsyncMode01( test )
// {
//   let context = this;
//   let amode = _.Consequence.AsyncModeGet();
//   let ready = new _.Consequence().take( null )
//
//   /* */
//
//   .finally( () =>
//   {
//     test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );
//
//     test.case = 'single resource';
//     _.Consequence.AsyncModeSet([ 0, 1 ]);
//     return null;
//   })
//   .then( function( arg )
//   {
//     var con = new _.Consequence({ tag : 'con' });
//     con.take( 1 );
//
//     return _.time.out( 1, function()
//     {
//       test.identical( con.resourcesCount(), 1 );
//       test.identical( con.competitorsCount(), 0 );
//       con.give( function( err, got )
//       {
//         test.identical( err, undefined )
//         test.identical( got, 1 );
//       })
//     })
//     .then( function( arg )
//     {
//       test.identical( con.resourcesCount(), 0 );
//       test.identical( con.competitorsCount(), 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .finally( () =>
//   {
//     test.case = 'several resources';
//     return null;
//   })
//   .then( function( arg )
//   {
//     var con = new _.Consequence({ tag : 'con', capacity : 3 });
//     con.take( 1 )
//     .take( 2 )
//     .take( 3 );
//
//     return _.time.out( 1, function()
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesCount(), 3 );
//       con.give( ( err, got ) => test.identical( got, 1 ) && test.identical( err, undefined ) );
//       con.give( ( err, got ) => test.identical( got, 2 ) && test.identical( err, undefined ) );
//       con.give( ( err, got ) => test.identical( got, 3 ) && test.identical( err, undefined ) );
//       return null;
//     })
//     .then( function( arg )
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesCount(), 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .finally( () =>
//   {
//     test.case = 'single error';
//     return null;
//   })
//   .then( function( arg )
//   {
//     var con = new _.Consequence({ tag : 'con' });
//     con.error( _.errAttend( 'err' ) );
//
//     return _.time.out( 1, function()
//     {
//       test.identical( con.resourcesCount(), 1 );
//       test.identical( con.competitorsCount(), 0 );
//       con.give( function( err, got )
//       {
//         test.true( !!err );
//         test.identical( got, undefined );
//       })
//       return null;
//     })
//     .then( function( arg )
//     {
//       test.identical( con.resourcesCount(), 0 );
//       test.identical( con.competitorsCount(), 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .finally( () =>
//   {
//     test.case = 'several error'
//     return null;
//   })
//   .then( function( arg )
//   {
//     var con = new _.Consequence({ tag : 'con', capacity : 3 });
//     con.error( _.errAttend( 'err1' ) )
//     .error( _.errAttend( 'err2' ) )
//     .error( _.errAttend( 'err3' ) );
//
//     return _.time.out( 1, function()
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesCount(), 3 );
//       con.give( ( err, got ) => test.true( !!err ) );
//       con.give( ( err, got ) => test.true( !!err ) );
//       con.give( ( err, got ) => test.true( !!err ) );
//       return null;
//     })
//     .then( function( arg )
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesCount(), 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .finally( ( err, arg ) =>
//   {
//     test.close( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );
//
//     _.Consequence.AsyncModeSet( amode );
//
//
//     if( err )
//     throw err;
//     return arg;
//
//   })
//   return ready;
// }
//
// //
//
// function ordinarResourceAsyncMode11( test )
// {
//   let context = this;
//   let amode = _.Consequence.AsyncModeGet();
//   let ready = new _.Consequence().take( null )
//
//   /* */
//
//   .finally( () =>
//   {
//     test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );
//
//     test.case = 'single resource';
//     _.Consequence.AsyncModeSet([ 1, 1 ]);
//     return null;
//   })
//   .then( function( arg )
//   {
//     var con = new _.Consequence({ tag : 'con' });
//     con.take( 1 );
//     con.give( function( err, got )
//     {
//       test.identical( err, undefined )
//       test.identical( got, 1 );
//     })
//     test.identical( con.resourcesCount(), 1 );
//     test.identical( con.competitorsCount(), 1 );
//     return _.time.out( 1, function()
//     {
//       test.identical( con.resourcesCount(), 0 );
//       test.identical( con.competitorsCount(), 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .finally( () =>
//   {
//     test.case = 'several resources';
//     return null;
//   })
//   .then( function( arg )
//   {
//     var con = new _.Consequence({ tag : 'con', capacity : 3 });
//     con.take( 1 )
//     .take( 2 )
//     .take( 3 );
//     con.give( ( err, got ) => test.identical( got, 1 ) && test.identical( err, undefined ) );
//     con.give( ( err, got ) => test.identical( got, 2 ) && test.identical( err, undefined ) );
//     con.give( ( err, got ) => test.identical( got, 3 ) && test.identical( err, undefined ) );
//     test.identical( con.competitorsCount(), 3 );
//     test.identical( con.resourcesCount(), 3 );
//     return _.time.out( 1, function()
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesCount(), 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .finally( () =>
//   {
//     test.case = 'single error';
//     return null;
//   })
//   .then( function( arg )
//   {
//     var con = new _.Consequence({ tag : 'con' });
//     con.error( _.errAttend( 'err' ) );
//     con.give( function( err, got )
//     {
//       test.true( !!err );
//       test.identical( got, undefined );
//     })
//     test.identical( con.resourcesCount(), 1 );
//     test.identical( con.competitorsCount(), 1 );
//     return _.time.out( 1, function()
//     {
//       test.identical( con.resourcesCount(), 0 );
//       test.identical( con.competitorsCount(), 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .finally( () =>
//   {
//     test.case = 'several error'
//     return null;
//   })
//   .then( function( arg )
//   {
//     var con = new _.Consequence({ tag : 'con', capacity : 3 });
//     con.error( _.errAttend( 'err1' ) )
//     .error( _.errAttend( 'err2' ) )
//     .error( _.errAttend( 'err3' ) );
//     con.give( ( err, got ) => test.true( !!err ) );
//     con.give( ( err, got ) => test.true( !!err ) );
//     con.give( ( err, got ) => test.true( !!err ) );
//     test.identical( con.competitorsCount(), 3 );
//     test.identical( con.resourcesCount(), 3 );
//     return _.time.out( 1, function()
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesCount(), 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .finally( ( err, arg ) =>
//   {
//     test.close( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );
//
//     _.Consequence.AsyncModeSet( amode );
//
//
//     if( err )
//     throw err;
//     return arg;
//
//   })
//   return ready;
// }

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
  let con;
  let amode = _.Consequence.AsyncModeGet();
  let ready = new _.Consequence({ tag : 'finallyPromiseGiveCon' }).take( null );

  ready

  /* */

  // .finally( () =>
  // {
  //   test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );
  //   _.Consequence.AsyncModeSet([ 0, 0 ]); /* xxx */
  //   return null;
  // })

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
    con.take( 'str' );
    test.identical( con.resourcesCount(), 1 );
    var promise = con.finallyPromiseGive();
    promise.then( function( got )
    {
      test.identical( got, 'str' );
      test.true( _.promiseIs( promise ) );
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
    con.error( 'str' );

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
      test.true( _.strHas( String( err ), 'str' ) );
      test.true( _.promiseIs( promise ) );
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
    con.take( 'str' + 1 );
    con.take( 'str' + 2 );
    con.take( 'str' + 3 );
    test.identical( con.resourcesCount(), 3 );
    var promise = con.finallyPromiseGive();
    promise.then( function( got )
    {
      test.identical( got, 'str' + 1 );
      test.true( _.promiseIs( promise ) );
      test.identical( con.resourcesCount(), 2 );
      test.identical( con.competitorsCount(), 0 );
    })
    return _.Consequence.From( promise );
  })

  /* */

  // .finally( ( err, arg ) =>
  // {
  //   test.close( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );
  //   _.Consequence.AsyncModeSet( amode );
  //   if( err )
  //   throw err;
  //   return arg;
  // })

  return ready;
}

//

// function finallyPromiseGiveAsyncMode10( test )
// {
//   let context = this;
//
//   let con;
//   let amode = _.Consequence.AsyncModeGet();
//   let ready = new _.Consequence({ tag : 'finallyPromiseGiveCon' }).take( null );
//
//   ready
//
//   /* */
//
//   .finally( () =>
//   {
//     test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );
//
//     _.Consequence.AsyncModeSet([ 1, 0 ]);
//     return null;
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async competitors adding, single resource';
//     var con = new _.Consequence({ tag : 'con' });
//     con.take( 'str' );
//     var promise = con.finallyPromiseGive();
//     test.identical( con.competitorsCount(), 1 );
//     test.identical( con.resourcesCount(), 1 );
//     return _.time.out( 1, function()
//     {
//       promise.then( function( got )
//       {
//         test.identical( got, 'str' );
//         test.true( _.promiseIs( promise ) );
//         test.identical( con.resourcesCount(), 0 );
//         test.identical( con.competitorsCount(), 0 );
//       });
//       return _.Consequence.From( promise );
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async competitors adding, error resource';
//     var con = new _.Consequence({ tag : 'con' });
//     con.error( 'str' );
//     var promise = con.finallyPromiseGive();
//     promise.catch( function( err )
//     {
//       test.true( _.strHas( String( err ), 'str' ) );
//       test.true( _.promiseIs( promise ) );
//     });
//     test.identical( con.resourcesCount(), 1 );
//     test.identical( con.competitorsCount(), 1 );
//     return _.time.out( 1, function()
//     {
//       test.identical( con.resourcesCount(), 0 );
//       test.identical( con.competitorsCount(), 0 );
//       return _.Consequence.From( promise ).finally( () => null );
//     });
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async competitors adding, several resources';
//     var con = new _.Consequence({ capacity : 3 });
//     con.take( 'str' + 1 );
//     con.take( 'str' + 2 );
//     con.take( 'str' + 3 );
//     var promise = con.finallyPromiseGive();
//     test.identical( con.resourcesCount(), 3 );
//     test.identical( con.competitorsCount(), 1 );
//
//     return _.time.out( 1, function()
//     {
//       promise.then( function( got )
//       {
//         test.identical( got, 'str' + 1 );
//         test.true( _.promiseIs( promise ) );
//         test.identical( con.resourcesCount(), 2 );
//         test.identical( con.competitorsCount(), 0 );
//       })
//       return _.Consequence.From( promise );
//     })
//   })
//
//   /* */
//
//   .finally( ( err, arg ) =>
//   {
//     test.close( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );
//
//     _.Consequence.AsyncModeSet( amode );
//
//
//     if( err )
//     throw err;
//     return arg;
//
//   })
//   return ready;
// }
//
// //
//
// function finallyPromiseGiveAsyncMode01( test )
// {
//   let context = this;
//
//   let con;
//   let amode = _.Consequence.AsyncModeGet();
//   let ready = new _.Consequence({ tag : 'finallyPromiseGiveCon' }).take( null );
//
//   ready
//
//   /* */
//
//   .finally( () =>
//   {
//     test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );
//
//     _.Consequence.AsyncModeSet([ 0, 1 ]);
//     return null;
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async resources adding, single resource';
//     var con = new _.Consequence({ tag : 'con' });
//     var promise = con.finallyPromiseGive();
//     con.take( 'str' );
//     test.identical( con.competitorsCount(), 1 );
//     test.identical( con.resourcesCount(), 1 );
//     return _.time.out( 1, function()
//     {
//       promise.then( function( got )
//       {
//         test.identical( got, 'str' );
//         test.true( _.promiseIs( promise ) );
//         test.identical( con.resourcesCount(), 0 );
//         test.identical( con.competitorsCount(), 0 );
//       });
//       return _.Consequence.From( promise );
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async resources adding, single error';
//     var con = new _.Consequence({ tag : 'con' });
//     var promise = con.finallyPromiseGive();
//     con.error( 'str' );
//     promise.catch( function( err )
//     {
//       test.true( _.strHas( String( err ), 'str' ) );
//       test.true( _.promiseIs( promise ) );
//     });
//     test.identical( con.resourcesCount(), 1 );
//     test.identical( con.competitorsCount(), 1 );
//     return _.time.out( 1, function()
//     {
//       test.identical( con.resourcesCount(), 0 );
//       test.identical( con.competitorsCount(), 0 );
//       return _.Consequence.From( promise ).finally( () => null );
//     });
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async resources adding, several resources';
//     var con = new _.Consequence({ capacity : 3 });
//     var promise = con.finallyPromiseGive();
//     con.take( 'str' + 1 );
//     con.take( 'str' + 2 );
//     con.take( 'str' + 3 );
//     test.identical( con.resourcesCount(), 3 );
//     test.identical( con.competitorsCount(), 1 );
//
//     return _.time.out( 1, function()
//     {
//       promise.then( function( got )
//       {
//         test.identical( got, 'str' + 1 );
//         test.true( _.promiseIs( promise ) );
//         test.identical( con.resourcesCount(), 2 );
//         test.identical( con.competitorsCount(), 0 );
//       })
//       return _.Consequence.From( promise );
//     })
//   })
//
//   /* */
//
//   .finally( ( err, arg ) =>
//   {
//     test.close( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );
//
//     _.Consequence.AsyncModeSet( amode );
//
//
//     if( err )
//     throw err;
//     return arg;
//
//   })
//   return ready;
// }
//
// //
//
// function finallyPromiseGiveAsyncMode11( test )
// {
//   let context = this;
//
//   let con;
//   let amode = _.Consequence.AsyncModeGet();
//   let ready = new _.Consequence({ tag : 'finallyPromiseGiveCon' }).take( null );
//
//   ready
//
//   /* */
//
//   .finally( () =>
//   {
//     test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );
//
//     _.Consequence.AsyncModeSet([ 1, 1 ]);
//     return null;
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async competitors adding+resources adding signle resource';
//     var con = new _.Consequence({ tag : 'con' });
//     con.take( 'str' );
//     var promise = con.finallyPromiseGive();
//     test.identical( con.competitorsCount(), 1 );
//     test.identical( con.resourcesCount(), 1 );
//     return _.time.out( 1, function()
//     {
//       promise.then( function( got )
//       {
//         test.identical( got, 'str' );
//         test.true( _.promiseIs( promise ) );
//         test.identical( con.resourcesCount(), 0 );
//         test.identical( con.competitorsCount(), 0 );
//       });
//       return _.Consequence.From( promise );
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async competitors adding+resources adding error resource';
//     var con = new _.Consequence({ tag : 'con' });
//     con.error( 'str' );
//     var promise = con.finallyPromiseGive();
//     promise.catch( function( err )
//     {
//       test.true( _.strHas( String( err ), 'str' ) );
//       test.true( _.promiseIs( promise ) );
//     });
//     test.identical( con.resourcesCount(), 1 );
//     test.identical( con.competitorsCount(), 1 );
//     return _.time.out( 1, function()
//     {
//       test.identical( con.resourcesCount(), 0 );
//       test.identical( con.competitorsCount(), 0 );
//       return _.Consequence.From( promise ).finally( () => null );
//     });
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async competitors adding+resources adding several resources';
//     var con = new _.Consequence({ capacity : 3 });
//     con.take( 'str' + 1 );
//     con.take( 'str' + 2 );
//     con.take( 'str' + 3 );
//     var promise = con.finallyPromiseGive();
//     test.identical( con.resourcesCount(), 3 );
//     test.identical( con.competitorsCount(), 1 );
//
//     return _.time.out( 1, function()
//     {
//       promise.then( function( got )
//       {
//         test.identical( got, 'str' + 1 );
//         test.true( _.promiseIs( promise ) );
//         test.identical( con.resourcesCount(), 2 );
//         test.identical( con.competitorsCount(), 0 );
//       })
//       return _.Consequence.From( promise );
//     })
//   })
//
//   /* */
//
//   .finally( ( err, arg ) =>
//   {
//     test.close( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );
//
//     _.Consequence.AsyncModeSet( amode );
//
//
//     if( err )
//     throw err;
//     return arg;
//
//   })
//   return ready;
// }

//--
// _finally
//--

function _finallyAsyncMode00( test )
{
  let context = this;
  let amode = _.Consequence.AsyncModeGet();
  var con;
  let ready = new _.Consequence().take( null )

  /* */

  // .then( function( arg )
  // {
  //   test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );
  //
  //   test.case += ', no resource';
  //   _.Consequence.AsyncModeSet([ 0, 0 ]);
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
  .delay( context.t1 )
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
      test.identical( err, undefined )
      test.identical( got, 'str' );
      return null;
    }
    var con = new _.Consequence({ tag : 'con' });
    con.take( 'str' );
    test.identical( con.resourcesCount(), 1 )
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : 'str' } )
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
    con.take( 'str' );
    con.finally( function( err, got )
    {
      test.identical( err, undefined )
      test.identical( got, 'str' );
      return 'str' + 1;
    });
    con.finally( function( err, got )
    {
      test.identical( err, undefined )
      test.identical( got, 'str' + 1);
      return 'str' + 2;
    });
    con.finally( function( err, got )
    {
      test.identical( err, undefined )
      test.identical( got, 'str' + 2 );
      return 'str' + 3;
    });
    test.identical( con.competitorsCount(), 0 )
    test.identical( con.resourcesCount(), 1 )
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : 'str' + 3 } );

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
    var con2TakerCalled = false;
    con.take( 'str' );
    /* finally only transfers the copy of messsage to the competitor without waiting for response */
    con.finally( con2 );
    con.give( function( err, got )
    {
      test.identical( got, 'str' );
      test.identical( err, undefined );
      test.identical( con2TakerCalled, false );
      test.identical( con2.resourcesCount(), 1 );
    });

    con2.finally( function( err, got )
    {
      test.identical( got, 'str' );
      test.identical( err, undefined );
      con2TakerCalled = true;
      return null;
    });

    con2.finally( function()
    {
      test.identical( con2TakerCalled, true );
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
      return con2.take( 'str' );
    });

    test.identical( con.competitorsCount(), 0 );
    test.identical( con.resourcesCount(), 1 );
    test.identical( con.resourcesGet()[ 0 ].argument, 'str' );

    test.identical( con2.resourcesCount(), 1 );
    test.identical( con2.resourcesGet()[ 0 ].argument, 'str' );

    return null;
  })

  /* */

  // .finally( ( err, arg ) =>
  // {
  //   test.close( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );
  //   _.Consequence.AsyncModeSet( amode );
  //   if( err )
  //   throw err;
  //   return arg;
  // });

  return ready;
}

// //
//
// function _finallyAsyncMode10( test )
// {
//   let context = this;
//   let amode = _.Consequence.AsyncModeGet();
//
//   var con;
//   let ready = new _.Consequence().take( null )
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );
//
//     test.case += ', no resource';
//     _.Consequence.AsyncModeSet([ 1, 0 ]);
//     return null;
//   })
//
//   // .then( function( arg )
//   // {
//   //   var con = new _.Consequence({ tag : 'con' });
//   //   con.finally( () => test.identical( 0, 1 ) );
//   //   test.identical( con.competitorsCount(), 1 );
//   //   test.identical( con.resourcesCount(), 0 );
//   //   return null;
//   // })
//
//   .then( function( arg )
//   {
//     con = new _.Consequence();
//     con.finally( () => test.identical( 0, 1 ) );
//     test.identical( con.competitorsCount(), 1 );
//     test.identical( con.resourcesCount(), 0 );
//     return null;
//   })
//   .delay( context.t1 )
//   .then( function( arg )
//   {
//     test.identical( con.competitorsCount(), 1 );
//     test.identical( con.resourcesCount(), 0 );
//     con.competitorsCancel();
//     test.identical( con.competitorsCount(), 0 );
//     test.identical( con.resourcesCount(), 0 );
//     return null;
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case += ', single resource, competitor is a routine';
//     return null;
//   })
//   .then( function( arg )
//   {
//     function competitor( err, got )
//     {
//       test.identical( err, undefined )
//       test.identical( got, 'str' );
//       return null;
//     }
//     var con = new _.Consequence({ tag : 'con' });
//     con.take( 'str' );
//     con.finally( competitor );
//     test.identical( con.resourcesCount(), 1 )
//     test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : 'str' } )
//     test.identical( con.competitorsCount(), 1 );
//
//     return _.time.out( 1, function()
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesCount(), 1 )
//       test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : null } )
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case += ', several finally, competitor is a routine';
//     return null;
//   })
//   .then( function( arg )
//   {
//     var con = new _.Consequence({ tag : 'con' });
//     con.take( 'str' );
//     con.finally( function( err, got )
//     {
//       test.identical( err, undefined )
//       test.identical( got, 'str' );
//       return 'str' + 1;
//     });
//     con.finally( function( err, got )
//     {
//       test.identical( err, undefined )
//       test.identical( got, 'str' + 1);
//       return 'str' + 2;
//     });
//     con.finally( function( err, got )
//     {
//       test.identical( err, undefined )
//       test.identical( got, 'str' + 2);
//       return 'str' + 3;
//     });
//     test.identical( con.competitorsCount(), 3 )
//     test.identical( con.resourcesCount(), 1 )
//     test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : 'str' } );
//
//     return _.time.out( 1, function()
//     {
//       test.identical( con.competitorsCount(), 0 )
//       test.identical( con.resourcesCount(), 1 )
//       test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : 'str' + 3 } );
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case += ', single resource, consequence as a competitor';
//     return null;
//   })
//   .then( function( arg )
//   {
//     var con = new _.Consequence({ tag : 'con' });
//     var con2 = new _.Consequence({ tag : 'con2' });
//     var con2TakerCalled = false;
//     con.take( 'str' );
//     con.finally( con2 );
//     con.give( function( err, got )
//     {
//       test.identical( got, 'str' );
//       test.identical( err, undefined );
//       test.identical( con2TakerCalled, true );
//       test.identical( con2.resourcesCount(), 0 );
//     });
//
//     con2.give( function( err, got )
//     {
//       test.identical( got, 'str' );
//       test.identical( err, undefined );
//       con2TakerCalled = true;
//     });
//
//     test.identical( con2TakerCalled, false );
//     test.identical( con.resourcesCount(), 1 );
//     test.identical( con.competitorsCount(), 2 );
//     test.identical( con2.competitorsEarlyGet().length, 1 );
//
//     return _.time.out( 1, function()
//     {
//       test.identical( con2TakerCalled, true );
//       test.identical( con.resourcesCount(), 0 );
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con2.resourcesCount(), 0 );
//       test.identical( con2.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case += 'competitor returns consequence with msg';
//     return null;
//   })
//   .then( function( arg )
//   {
//     var con = new _.Consequence({ tag : 'con' });
//     var con2 = new _.Consequence({ tag : 'con2' });
//     con.take( null );
//     con.finally( function()
//     {
//       return con2.take( 'str' );
//     });
//
//     test.identical( con.competitorsCount(), 1 );
//
//     return _.time.out( 1, function()
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesCount(), 1 );
//       test.identical( con.resourcesGet()[ 0 ].argument, 'str' );
//
//       test.identical( con2.resourcesCount(), 1 );
//       test.identical( con2.resourcesGet()[ 0 ].argument, 'str' );
//       return null;
//     })
//   })
//
//   /* */
//
//   .finally( ( err, arg ) =>
//   {
//     test.close( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );
//
//     _.Consequence.AsyncModeSet( amode );
//     if( err )
//     throw err;
//     return arg;
//   });
//   return ready;
// }
//
// //
//
// function _finallyAsyncMode01( test )
// {
//   let context = this;
//   let amode = _.Consequence.AsyncModeGet();
//
//   var con;
//   let ready = new _.Consequence().take( null )
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );
//
//     test.case += ', no resource';
//     _.Consequence.AsyncModeSet([ 0, 1 ]);
//     return null;
//   })
//   // .then( function( arg )
//   // {
//   //   var con = new _.Consequence({ tag : 'con' });
//   //   con.finally( () => test.identical( 0, 1 ) );
//   //   test.identical( con.competitorsCount(), 1 );
//   //   test.identical( con.resourcesCount(), 0 );
//   //   return null;
//   // })
//
//   .then( function( arg )
//   {
//     con = new _.Consequence();
//     con.finally( () => test.identical( 0, 1 ) );
//     test.identical( con.competitorsCount(), 1 );
//     test.identical( con.resourcesCount(), 0 );
//     return null;
//   })
//   .delay( context.t1 )
//   .then( function( arg )
//   {
//     test.identical( con.competitorsCount(), 1 );
//     test.identical( con.resourcesCount(), 0 );
//     con.competitorsCancel();
//     test.identical( con.competitorsCount(), 0 );
//     test.identical( con.resourcesCount(), 0 );
//     return null;
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case += ', single resource, competitor is a routine';
//     return null;
//   })
//   .then( function( arg )
//   {
//     function competitor( err, got )
//     {
//       test.identical( err, undefined )
//       test.identical( got, 'str' );
//       return null;
//     }
//     var con = new _.Consequence({ tag : 'con' });
//     con.take( 'str' );
//
//     return _.time.out( 1, function()
//     {
//       test.identical( con.resourcesCount(), 1 )
//       test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : 'str' } )
//       test.identical( con.competitorsCount(), 0 );
//
//       con.finally( competitor );
//       return null;
//     })
//     .then( function( arg )
//     {
//       test.identical( con.competitorsCount(), 0 )
//       test.identical( con.resourcesCount(), 1 )
//       test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : 'str' } )
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case += ', several finally, competitor is a routine';
//     return null;
//   })
//   .then( function( arg )
//   {
//     var con = new _.Consequence({ tag : 'con' });
//     con.take( 'str' );
//
//     return _.time.out( 1, function()
//     {
//       test.identical( con.competitorsCount(), 0 )
//       test.identical( con.resourcesCount(), 1 )
//       test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : 'str' } );
//
//       con.finally( function( err, got )
//       {
//         test.identical( err, undefined )
//         test.identical( got, 'str' );
//         return 'str' + 1;
//       });
//       con.finally( function( err, got )
//       {
//         test.identical( err, undefined )
//         test.identical( got, 'str' + 1);
//         return 'str' + 2;
//       });
//       con.finally( function( err, got )
//       {
//         test.identical( err, undefined )
//         test.identical( got, 'str' + 2);
//         return 'str' + 3;
//       });
//
//       return con;
//     })
//     .then( function( arg )
//     {
//       test.identical( con.competitorsCount(), 0 )
//       test.identical( con.resourcesCount(), 1 )
//       test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : 'str' + 3 } );
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case += ', single resource, consequence as a competitor';
//     return null;
//   })
//   .then( function( arg )
//   {
//     var con = new _.Consequence({ tag : 'con' });
//     var con2 = new _.Consequence({ tag : 'con2' });
//     var con2TakerCalled = false;
//     con.take( 'str' );
//
//     test.identical( con2TakerCalled, false );
//     test.identical( con.resourcesCount(), 1 );
//     test.identical( con.competitorsCount(), 0 );
//     test.identical( con2.competitorsEarlyGet().length, 0 );
//
//     return _.time.out( 1, function()
//     {
//       con.finally( con2 );
//       con.give( function( err, arg )
//       {
//         test.identical( arg, 'str' );
//         test.identical( err, undefined );
//         test.identical( con2TakerCalled, false );
//         test.identical( con2.resourcesCount(), 1 );
//       });
//
//       con2.finally( function( err, arg )
//       {
//         test.identical( arg, 'str' );
//         test.identical( err, undefined );
//         con2TakerCalled = true;
//         return arg;
//       });
//
//       return con2;
//     })
//     .then( function( arg )
//     {
//       test.identical( con2TakerCalled, true );
//       test.identical( con.resourcesCount(), 0 );
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con2.resourcesCount(), 1 );
//       test.identical( con2.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case += 'competitor returns consequence with msg';
//     return null;
//   })
//   .then( function( arg )
//   {
//     var con = new _.Consequence({ tag : 'con' });
//     var con2 = new _.Consequence({ tag : 'con2' });
//     con.take( null );
//
//     test.identical( con.resourcesCount(), 1 );
//
//     return _.time.out( 1, function()
//     {
//       con.finally( function()
//       {
//         return con2.take( 'str' );
//       });
//
//       return con;
//     })
//     .then( function( arg )
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesCount(), 1 );
//       test.identical( con.resourcesGet()[ 0 ].argument, 'str' );
//
//       test.identical( con2.resourcesCount(), 1 );
//       test.identical( con2.resourcesGet()[ 0 ].argument, 'str' );
//       return null;
//     })
//   })
//
//   /* */
//
//   .finally( ( err, arg ) =>
//   {
//     test.close( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );
//
//     _.Consequence.AsyncModeSet( amode );
//     if( err )
//     throw err;
//     return arg;
//   });
//   return ready;
// }
//
// //
//
// function _finallyAsyncMode11( test )
// {
//   let context = this;
//   let amode = _.Consequence.AsyncModeGet();
//
//   var con;
//   let ready = new _.Consequence().take( null )
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );
//
//     test.case += ', no resource';
//     _.Consequence.AsyncModeSet([ 1, 1 ]);
//     return null;
//   })
//   // .then( function( arg )
//   // {
//   //   var con = new _.Consequence({ tag : 'con' });
//   //   con.finally( () => test.identical( 0, 1 ) );
//   //   test.identical( con.competitorsCount(), 1 );
//   //   test.identical( con.resourcesCount(), 0 );
//   //   return null;
//   // })
//
//   .then( function( arg )
//   {
//     con = new _.Consequence();
//     con.finally( () => test.identical( 0, 1 ) );
//     test.identical( con.competitorsCount(), 1 );
//     test.identical( con.resourcesCount(), 0 );
//     return null;
//   })
//   .delay( context.t1 )
//   .then( function( arg )
//   {
//     test.identical( con.competitorsCount(), 1 );
//     test.identical( con.resourcesCount(), 0 );
//     con.competitorsCancel();
//     test.identical( con.competitorsCount(), 0 );
//     test.identical( con.resourcesCount(), 0 );
//     return null;
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case += ', single resource, competitor is a routine'
//     return null;
//   })
//   .then( function( arg )
//   {
//     function competitor( err, got )
//     {
//       test.identical( err, undefined )
//       test.identical( got, 'str' );
//       return null;
//     }
//     var con = new _.Consequence({ tag : 'con' });
//     con.take( 'str' );
//     con.finally( competitor );
//     test.identical( con.competitorsCount(), 1 )
//     test.identical( con.resourcesCount(), 1 )
//     test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : 'str' } )
//     return _.time.out( 1, function()
//     {
//       test.identical( con.competitorsCount(), 0 )
//       test.identical( con.resourcesCount(), 1 )
//       test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : null } )
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case += ', several finally, competitor is a routine';
//     return null;
//   })
//   .then( function( arg )
//   {
//     var con = new _.Consequence({ tag : 'con' });
//     con.take( 'str' );
//
//     con.finally( function( err, got )
//     {
//       test.identical( err, undefined )
//       test.identical( got, 'str' );
//       return 'str' + 1;
//     });
//     con.finally( function( err, got )
//     {
//       test.identical( err, undefined )
//       test.identical( got, 'str' + 1);
//       return 'str' + 2;
//     });
//     con.finally( function( err, got )
//     {
//       test.identical( err, undefined )
//       test.identical( got, 'str' + 2);
//       return 'str' + 3;
//     });
//
//     test.identical( con.competitorsCount(), 3 );
//     test.identical( con.resourcesCount(), 1 );
//     test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : 'str' } );
//
//     return _.time.out( 1, function()
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesCount(), 1 );
//       test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : 'str' + 3 } );
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case += ', single resource, consequence as a competitor';
//     return null;
//   })
//   .then( function( arg )
//   {
//     var con = new _.Consequence({ tag : 'con' });
//     var con2 = new _.Consequence({ tag : 'con2' });
//     var con2TakerCalled = false;
//     con.take( 'str' );
//     con.finally( con2 );
//     con.give( function( err, got )
//     {
//       test.identical( got, 'str' );
//       test.identical( err, undefined );
//       test.identical( con2TakerCalled, false );
//       test.identical( con2.resourcesCount(), 1 );
//     });
//
//     con2.give( function( err, got )
//     {
//       test.identical( got, 'str' );
//       test.identical( err, undefined );
//       con2TakerCalled = true;
//     });
//
//     test.identical( con2TakerCalled, false );
//     test.identical( con.resourcesCount(), 1 );
//     test.identical( con.competitorsCount(), 2 );
//     test.identical( con2.competitorsEarlyGet().length, 1 );
//     test.identical( con2.resourcesCount(), 0 );
//
//     return _.time.out( 1, function()
//     {
//       test.identical( con2TakerCalled, true );
//       test.identical( con.resourcesCount(), 0 );
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con2.resourcesCount(), 0 );
//       test.identical( con2.competitorsEarlyGet().length, 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case += 'competitor returns consequence with msg';
//     return null;
//   })
//   .then( function( arg )
//   {
//     var con = new _.Consequence({ tag : 'con' });
//     var con2 = new _.Consequence({ tag : 'con2' });
//     con.take( null );
//     con.finally( function()
//     {
//       return con2.take( 'str' );
//     });
//
//     test.identical( con.resourcesCount(), 1 );
//
//     return _.time.out( 1, function()
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesCount(), 1 );
//       test.identical( con.resourcesGet()[ 0 ].argument, 'str' );
//
//       test.identical( con2.resourcesCount(), 1 );
//       test.identical( con2.resourcesGet()[ 0 ].argument, 'str' );
//       return null;
//     })
//   })
//
//   /* */
//
//   .finally( ( err, arg ) =>
//   {
//     test.close( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );
//
//     _.Consequence.AsyncModeSet( amode );
//     if( err )
//     throw err;
//     return arg;
//   });
//   return ready;
// }

//--
// finallyPromiseKeep
//--

function finallyPromiseKeepAsyncMode00( test )
{
  let context = this;
  let con;
  let amode = _.Consequence.AsyncModeGet();
  let ready = new _.Consequence({ tag : 'finallyPromiseKeepCon' }).take( null );

  ready

  /* */

  // .finally( () =>
  // {
  //   test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );
  //   _.Consequence.AsyncModeSet([ 0, 0 ]);
  //   return null;
  // })

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

  .delay( context.t1 )
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
    con.take( 'str' );
    test.identical( con.resourcesCount(), 1 );
    var promise = con.finallyPromiseKeep();
    promise.then( function( got )
    {
      test.identical( got, 'str' );
      test.true( _.promiseIs( promise ) );
      test.identical( con.resourcesGet(), [ { error : undefined, argument : 'str' } ] );
      test.identical( con.competitorsCount(), 0 );
    })

    return _.Consequence.From( promise );
  })

  /* */

  .then( function( arg )
  {
    test.case = 'error resource';
    var con = new _.Consequence({ tag : 'con' });
    con.error( 'str' );
    test.identical( con.resourcesCount(), 1 );
    var promise = con.finallyPromiseKeep();
    promise.catch( function( err )
    {
      test.true( _.strHas( String( err ), 'str' ) );
      test.true( _.promiseIs( promise ) );
      // test.identical( con.resourcesGet(), [ { error : 'str', argument : undefined } ] );
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
    con.take( 'str' + 1 );
    con.take( 'str' + 2 );
    con.take( 'str' + 3 );
    test.identical( con.resourcesCount(), 3 );
    var promise = con.finallyPromiseKeep();
    promise.then( function( got )
    {
      test.identical( got, 'str' + 1 );
      test.true( _.promiseIs( promise ) );
      test.identical( con.resourcesCount(), 3 );
      test.identical( con.competitorsCount(), 0 );
    })
    return _.Consequence.From( promise );
  })

  /* */

  // .finally( ( err, arg ) =>
  // {
  //   test.close( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );
  //   _.Consequence.AsyncModeSet( amode );
  //   if( err )
  //   throw err;
  //   return arg;
  // })

  return ready;
}

//

// function finallyPromiseKeepAsyncMode10( test )
// {
//   let context = this;
//
//   let con;
//   let amode = _.Consequence.AsyncModeGet();
//   let ready = new _.Consequence({ tag : 'finallyPromiseKeepCon' }).take( null );
//
//   ready
//
//   /* */
//
//   .finally( () =>
//   {
//     test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );
//
//     _.Consequence.AsyncModeSet([ 1, 0 ]);
//     return null;
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async competitors adding, single resource';
//     var con = new _.Consequence({ tag : 'con' });
//     con.take( 'str' );
//     var promise = con.finallyPromiseKeep();
//     test.identical( con.competitorsCount(), 1 );
//     test.identical( con.resourcesCount(), 1 );
//     return _.time.out( 1, function()
//     {
//       promise.then( function( got )
//       {
//         test.identical( got, 'str' );
//         test.true( _.promiseIs( promise ) );
//         test.identical( con.resourcesGet(), [ { error : undefined, argument : 'str' } ] );
//         test.identical( con.competitorsCount(), 0 );
//       });
//       return _.Consequence.From( promise );
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async competitors adding, error resource';
//     var con = new _.Consequence({ tag : 'con' });
//     var catched = 0;
//     con.error( 'str' );
//     var promise = con.finallyPromiseKeep();
//     promise.catch( function( err )
//     {
//       catched = 1;
//       test.true( _.strHas( String( err ), 'str' ) );
//       test.true( _.promiseIs( promise ) );
//     });
//     test.identical( con.resourcesCount(), 1 );
//     test.identical( con.competitorsCount(), 1 );
//     return _.time.out( 1, function()
//     {
//       // test.identical( con.resourcesGet(), [ { error : 'str', argument : undefined } ] );
//       test.identical( con.argumentsGet(), [] );
//       test.identical( con.errorsGet().length, 1 );
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( catched, 1 );
//       return _.Consequence.From( promise ).finally( () => null );
//     });
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async competitors adding, several resources';
//     var con = new _.Consequence({ capacity : 3 });
//     con.take( 'str' + 1 );
//     con.take( 'str' + 2 );
//     con.take( 'str' + 3 );
//     var promise = con.finallyPromiseKeep();
//     test.identical( con.resourcesCount(), 3 );
//     test.identical( con.competitorsCount(), 1 );
//
//     return _.time.out( 1, function()
//     {
//       promise.then( function( got )
//       {
//         test.identical( got, 'str' + 1 );
//         test.true( _.promiseIs( promise ) );
//         test.identical( con.resourcesCount(), 3 );
//         test.identical( con.competitorsCount(), 0 );
//       })
//       return _.Consequence.From( promise );
//     })
//   })
//
//   /* */
//
//   .finally( ( err, arg ) =>
//   {
//     test.close( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );
//
//     _.Consequence.AsyncModeSet( amode );
//     if( err )
//     throw err;
//     return arg;
//   })
//   return ready;
// }
//
// //
//
// function finallyPromiseKeepAsyncMode01( test )
// {
//   let context = this;
//
//   let con;
//   let amode = _.Consequence.AsyncModeGet();
//   let ready = new _.Consequence({ tag : 'finallyPromiseKeepCon' }).take( null );
//
//   ready
//
//   /* */
//
//   .finally( () =>
//   {
//     test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );
//
//     _.Consequence.AsyncModeSet([ 0, 1 ]);
//     return null;
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async resources adding, single resource';
//     var con = new _.Consequence({ tag : 'con' });
//     var promise = con.finallyPromiseKeep();
//     con.take( 'str' );
//     test.identical( con.competitorsCount(), 1 );
//     test.identical( con.resourcesCount(), 1 );
//     return _.time.out( 1, function()
//     {
//       promise.then( function( got )
//       {
//         test.identical( got, 'str' );
//         test.true( _.promiseIs( promise ) );
//         test.identical( con.resourcesGet(), [ { error : undefined, argument : 'str' } ] );
//         test.identical( con.competitorsCount(), 0 );
//       });
//       return _.Consequence.From( promise );
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async resources adding, error resource';
//     var catched = 0;
//     var con = new _.Consequence({ tag : 'con' });
//     var promise = con.finallyPromiseKeep();
//     promise.catch( function( err )
//     {
//       test.true( _.strHas( String( err ), 'str' ) );
//       test.true( _.promiseIs( promise ) );
//       catched = 1;
//     });
//     con.error( 'str' );
//     test.identical( con.resourcesCount(), 1 );
//     test.identical( con.competitorsCount(), 1 );
//     return _.time.out( 1, function()
//     {
//       // test.identical( con.resourcesGet(), [ { error : 'str', argument : undefined } ] );
//       test.identical( con.argumentsGet(), [] );
//       test.identical( con.errorsGet().length, 1 );
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( catched, 1 );
//       return _.Consequence.From( promise ).finally( () => null );
//     });
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async resources adding, several resources';
//     var con = new _.Consequence({ capacity : 3 });
//     var promise = con.finallyPromiseKeep();
//     con.take( 'str' + 1 );
//     con.take( 'str' + 2 );
//     con.take( 'str' + 3 );
//     test.identical( con.resourcesCount(), 3 );
//     test.identical( con.competitorsCount(), 1 );
//
//     return _.time.out( 1, function()
//     {
//       promise.then( function( got )
//       {
//         test.identical( got, 'str' + 1 );
//         test.true( _.promiseIs( promise ) );
//         test.identical( con.resourcesCount(), 3 );
//         test.identical( con.competitorsCount(), 0 );
//       })
//       return _.Consequence.From( promise );
//     })
//   })
//
//   /* */
//
//   .finally( ( err, arg ) =>
//   {
//     test.close( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );
//
//     _.Consequence.AsyncModeSet( amode );
//     if( err )
//     throw err;
//     return arg;
//   })
//   return ready;
// }
//
// //
//
// function finallyPromiseKeepAsyncMode11( test )
// {
//   let context = this;
//
//   let con;
//   let amode = _.Consequence.AsyncModeGet();
//   let ready = new _.Consequence({ tag : 'finallyPromiseKeepCon' }).take( null );
//
//   ready
//
//   /* */
//
//   .finally( () =>
//   {
//     test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );
//
//     _.Consequence.AsyncModeSet([ 1, 1 ]);
//     return null;
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async competitors adding+resources adding, single resource';
//     var con = new _.Consequence({ tag : 'con' });
//     con.take( 'str' );
//     var promise = con.finallyPromiseKeep();
//     test.identical( con.competitorsCount(), 1 );
//     test.identical( con.resourcesCount(), 1 );
//     return _.time.out( 1, function()
//     {
//       promise.then( function( got )
//       {
//         test.identical( got, 'str' );
//         test.true( _.promiseIs( promise ) );
//         test.identical( con.resourcesGet(), [ { error : undefined, argument : 'str' } ] );
//         test.identical( con.competitorsCount(), 0 );
//       });
//       return _.Consequence.From( promise );
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async competitors adding+resources adding, error resource';
//     var catched = 0;
//     var con = new _.Consequence({ tag : 'con' });
//     con.error( 'str' );
//     var promise = con.finallyPromiseKeep();
//     promise.catch( function( err )
//     {
//       test.true( _.strHas( String( err ), 'str' ) );
//       test.true( _.promiseIs( promise ) );
//       catched = 1;
//     });
//     test.identical( con.resourcesCount(), 1 );
//     test.identical( con.competitorsCount(), 1 );
//     return _.time.out( 1, function()
//     {
//       test.identical( con.argumentsGet(), [] );
//       test.identical( con.errorsGet().length, 1 );
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( catched, 1 );
//       return _.Consequence.From( promise ).finally( () => null );
//     });
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'async competitors adding+resources adding, several resources';
//     var con = new _.Consequence({ capacity : 3 });
//     con.take( 'str' + 1 );
//     con.take( 'str' + 2 );
//     con.take( 'str' + 3 );
//     var promise = con.finallyPromiseKeep();
//     test.identical( con.resourcesCount(), 3 );
//     test.identical( con.competitorsCount(), 1 );
//
//     return _.time.out( 1, function()
//     {
//       promise.then( function( got )
//       {
//         test.identical( got, 'str' + 1 );
//         test.true( _.promiseIs( promise ) );
//         test.identical( con.resourcesCount(), 3 );
//         test.identical( con.competitorsCount(), 0 );
//       })
//       return _.Consequence.From( promise );
//     })
//   })
//
//   /* */
//
//   .finally( ( err, arg ) =>
//   {
//     test.close( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );
//
//     _.Consequence.AsyncModeSet( amode );
//     if( err )
//     throw err;
//     return arg;
//   })
//   return ready;
// }

// --
// etc
// --

function trivial( test )
{
  let context = this;

  /* */

  test.case = 'class checks';
  test.true( _.routineIs( wConsequence.prototype.FinallyPass ) );
  test.true( _.routineIs( wConsequence.FinallyPass ) );
  test.true( _.object.isBasic( wConsequence.prototype.KindOfResource ) );
  test.true( _.object.isBasic( wConsequence.KindOfResource ) );
  test.true( wConsequence.name === 'wConsequence' );
  test.true( wConsequence.shortName === 'Consequence' );

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
  test.true( _.consequenceIs( con1 ) );
  test.true( _.consequenceIs( con2 ) );
  test.true( _.consequenceIs( con3 ) );

  con3.take( 3 );
  con3( 4 );
  con3( 5 );

  con3.give( ( err, arg ) => test.identical( arg, 2 ) && test.identical( err, undefined ) );
  con3.give( ( err, arg ) => test.identical( arg, 3 ) && test.identical( err, undefined ) );
  con3.give( ( err, arg ) => test.identical( arg, 4 ) && test.identical( err, undefined ) );
  con3.finally( ( err, arg ) =>
  {
    test.identical( con3.resourcesCount(), 0 );
    test.identical( err, undefined );
    return null;
  });

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

//

function deasync( test )
{
  let context = this;
  let ready = _.take( null );
  let t = context.t1;

  /* */

  ready.then( () =>
  {
    let counter = 0;
    let after = false;
    let con;

    _.time.out( t*20, () =>
    {
      test.true( after );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( counter, 1 );
      counter += 1;
    });
    _.time.out( 1, () =>
    {
      test.true( !after );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 2 );
      test.identical( counter, 0 );
      counter += 1;
    });

    con = _.time.out( t*4 );

    test.true( !after );
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

  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    test.case = 'single value in give sequence, and single taker : attached taker after value resolved';
    var con = new _.Consequence({ tag : 'con' });
    con.take( 'str' );
    con.tap( ( err, got ) => test.identical( got, 'str' ) && test.identical( err, undefined ) );
    con.give( ( err, got ) => test.identical( got, 'str' ) && test.identical( err, undefined ) );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con.resourcesCount(), 0 );
    return null;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'single error and single taker : attached taker after value resolved';
    var con = new _.Consequence({ tag : 'con' });
    con.error( 'str' );
    con.tap( ( err, got ) => test.true( _.strHas( String( err ), 'str' ) ) );
    con.give( ( err, got ) => test.true( _.strHas( String( err ), 'str' ) ) );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con.resourcesCount(), 0 );
    return null;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'test tap in chain';
    var con = new _.Consequence({ tag : 'con' });
    con.take( 'str' );
    con.tap( ( err, got ) => test.identical( got, 'str' ) && test.identical( err, undefined ) );
    con.tap( ( err, got ) => test.identical( got, 'str' ) && test.identical( err, undefined ) );
    con.give( ( err, got ) => test.identical( got, 'str' ) && test.identical( err, undefined ) );
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
      throw _.err( 'Error' );
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
      test.true( _.errIs( err ) );
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
      throw _.err( 'Error' );
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
      test.true( _.errIs( err ) );
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

  let ready = new _.Consequence().take( null )

  /* common wConsequence corespondent tests. */

  .then( function( arg )
  {
    test.case = 'single value in give sequence, and single taker : attached taker after value resolved';
    var con = new _.Consequence({ tag : 'con' });
    con.take( 'str' );
    // con.catch( ( err ) => { test.identical( 0, 1 ); return null; } );
    con.catch( ( err ) => { test.identical( err, undefined ); return null; } );
    con.give( ( err, got ) => test.identical( got, 'str' ) && test.identical( err, undefined ) );

    test.identical( con.competitorsCount(), 0 );
    test.identical( con.resourcesCount(), 0 );

    return arg;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'single err in give sequence, and single taker : attached taker after value resolved';
    var con = new _.Consequence({ tag : 'con' });
    con.error( 'str' );
    con.catch( ( err ) => { test.true( _.strHas( String( err ), 'str' ) ); return null; });
    con.give( ( err, got ) => test.identical( got, null ) && test.identical( err, undefined ) );

    test.identical( con.competitorsCount(), 0 );
    test.identical( con.resourcesCount(), 0 );

    return arg;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'test catchTestRoutine in chain, regular resource is given before error';
    var con = new _.Consequence({ capacity : 0 });
    con.take( 'str' );
    con.error( 'str' + 1 );
    con.error( 'str' + 2 );

    con.catch( ( err ) => { test.identical( err, 1 ); return null; });
    con.catch( ( err ) => { test.identical( err, 1 ); return null; });
    con.give( ( err, got ) => test.identical( got, 'str' ) && test.identical( err, undefined ) );

    test.identical( con.resourcesCount(), 2 );
    test.true( _.strHas( String( con.resourcesGet()[ 0 ].error ), 'str' + 1 ) );
    test.true( _.strHas( String( con.resourcesGet()[ 1 ].error ), 'str' + 2 ) );
    test.identical( con.competitorsCount(), 0 );

    return arg;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'test catchTestRoutine in chain, regular resource is given after error';
    var con = new _.Consequence({ capacity : 0 });
    con.error( 'str' + 1 );
    con.error( 'str' + 2 );
    con.take( 'str' );

    test.true( _.strHas( String( con.resourcesGet()[ 0 ].error ), 'str' + 1 ) );

    con.catch( ( err ) => { test.true( _.strHas( String( err ), 'str' + 1 ) ); return null; });
    con.catch( ( err ) => { test.true( _.strHas( String( err ), 'str' + 2 ) ); return null; });
    con.give( ( err, got ) => test.identical( got, 'str' ) && test.identical( err, undefined ) );

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

function thenGiveTrivial( test )
{
  let context = this;
  let con = new _.Consequence();
  let last = 0;

  con.take( 0 );
  con.toStr();

  con
  .thenGive( ( arg ) =>
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

function thenGiveThrowing( test )
{
  let context = this;
  let con = new _.Consequence();
  let last = 0;
  let error = null;

  con.take( 0 );
  con.toStr();

  con
  .thenGive( ( arg ) =>
  {
    let result = _.Consequence().take( 1 );
    test.identical( arg, 0 );
    last = 1;
    throw _.err( 'Throw error' );
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
    test.true( _.errIs( error ) );
    return null;
  });

}

//

function keep( test )
{
  let context = this;

  let ready = new _.Consequence().take( null )

  /* common wConsequence corespondent tests. */

  .then( function( arg )
  {
    test.case = 'single value in give sequence, and single taker : attached taker after value resolved';
    var con = new _.Consequence({ tag : 'con' });
    con.take( 'str' );
    con.then( ( got ) => { test.identical( got, 'str' ); return null; } );
    con.give( ( err, got ) => test.identical( got, null ) && test.identical( err, undefined ) );

    test.identical( con.competitorsCount(), 0 );
    test.identical( con.resourcesCount(), 0 );
    return null;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'single err in give sequence, and single taker : attached taker after value resolved';
    var con = new _.Consequence({ tag : 'con' });
    con.error( 'str' );
    con.then( ( got ) => { test.identical( 0, 1 ); return null; });
    con.give( ( err, got ) => test.true( _.strHas( String( err ), 'str' ) ) );

    test.identical( con.competitorsCount(), 0 );
    test.identical( con.resourcesCount(), 0 );
    return null;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'test keep in chain, regular resource is given before error';
    var con = new _.Consequence({ capacity : 0 });
    con.take( 'str' );
    con.take( 'str' );
    con.error( 'str' );

    con.then( ( got ) => { test.identical( got, 'str' ); return null; });
    con.then( ( got ) => { test.identical( got, 'str' ); return null; });

    test.identical( con.resourcesCount(), 3 );
    // test.identical( con.resourcesGet()[ 0 ].error, 'str' );
    test.true( _.strHas( String( con.resourcesGet()[ 0 ].error ), 'str' ) );
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
    con.error( 'str' );
    con.take( 'str' );
    con.take( 'str' );

    con.then( ( got ) => { test.identical( 0, 1 ); return null; });
    con.then( ( got ) => { test.identical( 0, 1 ); return null; });

    test.identical( con.resourcesCount(), 3 );
    // test.identical( con.resourcesGet()[ 0 ].error, 'str' );
    test.true( _.strHas( String( con.resourcesGet()[ 0 ].error ), 'str' ) );
    test.identical( con.resourcesGet()[ 1 ], { error : undefined, argument : 'str' } );
    test.identical( con.resourcesGet()[ 2 ], { error : undefined, argument : 'str' } );
    test.identical( con.competitorsCount(), 0 );
    return null;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'test keep in chain serveral resources';
    var con = new _.Consequence({ capacity : 0 });
    con.take( 'str' );
    con.take( 'str' );

    con.then( ( got ) => { test.identical( got, 'str' ); return null; });
    con.then( ( got ) => { test.identical( got, 'str' ); return null; });

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
  test.identical( con2.resourcesGet(), [ { error : undefined, argument : 2 } ] );
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
// time
// --

function timeOut( test )
{
  let context = this;

  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    let visited = [];
    test.case = 'zero delay';
    var con = new _.Consequence({ tag : 'con' });

    con.finally( () => visited.push( 'a' ) );

    con.delay( 0 );

    con.finally( () => visited.push( 'b' ) );

    test.identical( con.competitorsCount(), 3 );
    test.identical( con.resourcesCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( visited, [] );
    visited.push( 'context' )

    con.take( 'str' );
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

    con.delay( 25 );

    con.finally( () => visited.push( 'b' ) );

    test.identical( con.competitorsCount(), 3 );
    test.identical( con.resourcesCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( visited, [] );
    visited.push( 'context' )

    con.take( 'str' );
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
      con.delay();
    });
    return null;
  })

  /* */

  return ready;
}

//

function timeLimitProcedure( test )
{
  let context = this;
  let ready = _.take( null );
  let t = context.t1;

  ready.then( function timeLimit1( arg )
  {
    test.case = 'timeLimit';

    var con = _.time.out( t );
    var con0 = _.time.out( t*3 );
    con.timeLimit( t*7, con0 );

    test.identical( con.competitorsCount(), 4 );
    con.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'timeLimit1' ) );
    })

    test.identical( con0.competitorsCount(), 2 );
    con0.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'timeLimit1' ) );
    })

    return _.time.out( t*10, function()
    {
      return null;
    })
  })

  return ready;
}

//

function timeLimitSplitProcedure( test )
{
  let context = this;
  let ready = _.take( null );
  let t = context.t1;

  ready.then( function timeLimitSplit1( arg )
  {
    test.case = 'timeLimitSplit';

    var con = _.time.out( t );
    con.timeLimitSplit( t*5 );

    test.identical( con.competitorsCount(), 2 );
    con.competitorsGet().forEach( ( competitor ) =>
    {
      console.log( competitor )
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'timeLimitSplit1' ) );
    })

    return _.time.out( t*10, function()
    {
      return null;
    })
  })

  return ready;
}

//

function timeLimitErrorProcedure( test )
{
  let context = this;
  let ready = _.take( null );
  let t = context.t1;

  ready.then( function timeLimitError1( arg )
  {
    test.case = 'timeLimitError';

    var con = _.time.out( t );
    var con0 = _.time.out( t*3 );
    con.timeLimitError( t*7, con0 );

    test.identical( con.competitorsCount(), 4 );
    con.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'timeLimitError1' ) );
    })

    test.identical( con0.competitorsCount(), 2 );
    con0.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'timeLimitError1' ) );
    })

    return _.time.out( t*10, function()
    {
      return null;
    })
  })

  return ready;
}

//

function timeLimitErrorSplitProcedure( test )
{
  let context = this;
  let ready = _.take( null );
  let t = context.t1;

  ready.then( function timeLimitErrorSplit1( arg )
  {
    test.case = 'timeLimitErrorSplit';

    var con = _.time.out( t );
    con.timeLimitErrorSplit( t*5 );

    test.identical( con.competitorsCount(), 2 );
    con.competitorsGet().forEach( ( competitor ) =>
    {
      console.log( competitor )
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'timeLimitErrorSplit1' ) );
    })

    return _.time.out( t*10, function()
    {
      return null;
    })
  })

  return ready;
}

//

function TimeLimitProcedure( test )
{
  let context = this;
  let ready = _.take( null );
  let t = context.t1;

  ready.then( function TimeLimit1( arg )
  {
    test.case = 'TimeLimit';

    var con0 = _.time.out( t*3 );
    var con = _.Consequence.TimeLimit( t*7, con0 );

    test.identical( con.competitorsCount(), 2 );
    con.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'TimeLimit1' ) );
    })

    test.identical( con0.competitorsCount(), 2 );
    con0.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'TimeLimit1' ) );
    })

    return _.time.out( t*10, function()
    {
      return null;
    })
  })

  return ready;
}

//

function TimeLimitErrorProcedure( test )
{
  let context = this;
  let ready = _.take( null );
  let t = context.t1;

  ready.then( function TimeLimitError1( arg )
  {
    test.case = 'TimeLimitError';

    var con0 = _.time.out( t*3 );
    var con = _.Consequence.TimeLimitError( t*7, con0 );

    test.identical( con.competitorsCount(), 2 );
    con.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'TimeLimitError1' ) );
    })

    test.identical( con0.competitorsCount(), 2 );
    con0.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'TimeLimitError1' ) );
    })

    return _.time.out( t*10, function()
    {
      return null;
    })
  })

  return ready;
}

//

function timeLimitSplit( test )
{
  let context = this;
  let ready = _.take( null );
  let t = context.t1;

  ready

  /* */

  .then( function timeLimit1( arg )
  {
    test.case = 'timeOut, enough time';

    var con = _.time.out( t, 'a' );
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
      test.true( err === undefined );
      test.true( arg === 'a' );
    });

    _.time.out( t, function()
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
      test.true( con.argumentsGet()[ 0 ] === 'a' );
      test.true( con2.argumentsGet()[ 0 ] === 'a' );
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
      test.true( err === undefined );
      test.true( arg === _.time.out );
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
      test.true( con.argumentsGet()[ 0 ] === 'a' );
      test.true( con2.argumentsGet()[ 0 ] === _.time.out );
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

    var con = _.time.outError( t );
    var con2 = con.timeLimitSplit( t*3 );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 2 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.competitorsCount(), 2 );

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.true( _.errIs( err ) );
      test.true( arg === undefined );
    });

    con2.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.true( _.errIs( err ) );
      test.true( arg === undefined );
    });

    _.time.out( t, function()
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

    var con = _.time.outError( t*8 );
    var con2 = con.timeLimitSplit( t*4 );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 2 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.competitorsCount(), 2 );

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.true( _.errIs( err ) );
      test.true( arg === undefined );
    });

    con2.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.true( err === undefined );
      test.true( arg === _.time.out );
    });

    _.time.out( t*4, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 2 );
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
      test.true( con2.argumentsGet()[ 0 ] === _.time.out );
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

function timeLimitErrorSplit( test )
{
  let context = this;
  let t = context.t1/2;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function timeLimit1( arg )
  {
    test.case = 'timeOut, enough time';

    var con = _.time.out( t, 'a' );
    var con2 = con.timeLimitErrorSplit( t*4 );

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
      test.true( err === undefined );
      test.true( arg === 'a' );
    });

    _.time.out( t*2, function()
    {
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.competitorsCount(), 0 );
    });

    return _.time.out( t*8, function()
    {
      test.true( con.argumentsGet()[ 0 ] === 'a' );
      test.true( con2.argumentsGet()[ 0 ] === 'a' );
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
    var con2 = con.timeLimitErrorSplit( t*4 );

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
      test.true( _.errIs( err ) );
      test.true( arg === undefined );
    });

    _.time.out( t*6, function()
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
      test.true( con.argumentsGet()[ 0 ] === 'a' );
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

    var con = _.time.outError( t );
    var con2 = con.timeLimitErrorSplit( t*4 );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 2 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.competitorsCount(), 2 );

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.true( _.errIs( err ) );
      test.true( arg === undefined );
    });

    con2.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.true( _.errIs( err ) );
      test.true( arg === undefined );
    });

    _.time.out( t*2, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.errorsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
    });

    return _.time.out( t*8, function()
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

    var con = _.time.outError( t*10 );
    var con2 = con.timeLimitErrorSplit( t*4 );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 2 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.competitorsCount(), 2 );

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.true( _.errIs( err ) );
      test.true( arg === undefined );
    });

    con2.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.true( _.errIs( err ) );
      test.true( arg === undefined );
    });

    _.time.out( t*8, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 2 );
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
    var con0 = _.time.out( t*6, 'a' );
    con.timeLimit( t*10, con0 );

    test.identical( con0.argumentsCount(), 0 );
    test.identical( con0.errorsCount(), 0 );
    test.identical( con0.competitorsCount(), 2 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 4 );

    con.tap( ( err, arg ) =>
    {
      test.true( err === undefined );
      test.true( arg === 'a' );
    });

    _.time.out( t, function()
    {
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.competitorsCount(), 2 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 5 );
    });

    _.time.out( t*8, function()
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
      test.true( con.argumentsGet()[ 0 ] === 'a' );
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

    var con = _.time.out( t*2 );
    var con0 = _.time.out( t*10, 'a' );
    con.timeLimit( t*4, con0 );

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
      test.true( err === undefined );
      test.true( arg === _.time.out );
    });

    _.time.out( t, function()
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
      test.true( con.argumentsGet()[ 0 ] === _.time.out );
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

    var con = _.time.out( t*2 );
    var con0 = _.time.outError( t*4 );
    con.timeLimit( t*10, con0 );

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
      test.true( _.errIs( err ) );
      test.true( arg === undefined );
    });

    _.time.out( t, function()
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
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.errorsCount(), 1 );
      test.identical( con0.competitorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t*15, function()
    {
      test.true( _.strHas( String( con.errorsGet()[ 0 ] ), 'Time out!' ) );
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

    var con = _.time.out( t*2 );
    var con0 = _.time.outError( t*10 );
    con.timeLimit( t*4, con0 );

    test.identical( con0.argumentsCount(), 0 );
    test.identical( con0.errorsCount(), 0 );
    test.identical( con0.competitorsCount(), 2 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 4 );

    con0.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.true( _.errIs( err ) );
      test.true( arg === undefined );
    });

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.true( err === undefined );
      test.true( arg === _.time.out );
    });

    _.time.out( t, function()
    {
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.competitorsCount(), 3 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 5 );
    });

    _.time.out( t*3, function()
    {
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.competitorsCount(), 3 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 3 );
    });

    _.time.out( t*8, function()
    {
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.competitorsCount(), 2 );
      test.identical( con.argumentsCount(), 1 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t*15, function()
    {
      test.true( con.argumentsGet()[ 0 ] === _.time.out );
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

    var con = _.time.outError( t*2 );
    var con0 = _.time.out( t*4, 'a' );
    con.timeLimit( t*10, con0 );

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
      test.true( _.errIs( err ) );
      test.true( arg === undefined );
    });

    _.time.out( t, function()
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
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t*15, function()
    {
      test.true( _.strHas( String( con.errorsGet()[ 0 ] ), 'Time out!' ) );
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

    var con = _.time.outError( t*2 );
    var con0 = _.time.out( t*10 );
    con.timeLimit( t*4, con0 );

    test.identical( con0.argumentsCount(), 0 );
    test.identical( con0.errorsCount(), 0 );
    test.identical( con0.competitorsCount(), 2 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 4 );

    con0.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.true( err === undefined );
      test.true( _.timerIs( arg ) );
    });

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.true( _.errIs( err ) );
      test.true( arg === undefined );
    });

    _.time.out( t, function()
    {
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.competitorsCount(), 3 );
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
      test.true( _.strHas( String( con.errorsGet()[ 0 ] ), 'Time out!' ) );
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

  /* - */

  .then( function timeLimit1( arg )
  {
    test.case = 'timeOut timeLimit a timeLimitOut';

    var con = _.time.out( t );
    con.timeLimit( t*6, () => _.time.out( t*3, 'a' ) );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 4 );

    con.tap( ( err, arg ) =>
    {
      test.true( err === undefined );
      test.true( arg === 'a' );
    });

    _.time.out( t, function()
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

    return _.time.out( t*15, function()
    {
      test.true( con.argumentsGet()[ 0 ] === 'a' );
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

    var con = _.time.out( t );
    con.timeLimit( t*5, () => _.time.out( t*10, 'a' ) );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 4 );

    con.tap( ( err, arg ) =>
    {
      test.true( err === undefined );
      test.true( arg === _.time.out );
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
      test.true( con.argumentsGet()[ 0 ] === _.time.out );
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
      test.true( err === undefined );
      test.true( arg === _.time.out );
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
      test.true( con.argumentsGet()[ 0 ] === _.time.out );
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

    var con = _.time.outError( t ).tap( ( err, arg ) => _.errAttend( err ) );
    con.timeLimit( t*6, () => _.time.out( t*3, 'a' ) );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 5 );

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.true( _.errIs( err ) );
      test.true( arg === undefined );
    });

    _.time.out( t, function()
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
      test.true( _.strHas( String( con.errorsGet()[ 0 ] ), 'Time out!' ) );
      test.true( con.errorsGet()[ 0 ].reason === 'time out' );
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

    var con = _.time.outError( t ).tap( ( err, arg ) => _.errAttend( err ) );
    con.timeLimit( t*5, () => _.time.out( t*10, 'a' ) );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 5 );

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.true( _.errIs( err ) );
      test.true( arg === undefined );
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
      test.true( _.strHas( String( con.errorsGet()[ 0 ] ), 'Time out!' ) );
      test.true( con.errorsGet()[ 0 ].reason === 'time out' );
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
    test.identical( con.competitorsCount(), 4 );

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.true( _.errIs( err ) );
      test.true( arg === undefined );
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
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t*50, function()
    {
      test.true( _.strHas( String( con.errorsGet()[ 0 ] ), 'Time out!' ) );
      test.true( con.errorsGet()[ 0 ].reason === 'time out' );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
      return null;
    })
  })

  /* - */

  return ready;
}

//

function timeLimitErrorRoutine( test )
{
  let context = this;
  let t = context.t1/2;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function timeLimit1( arg )
  {
    test.case = 'timeOut timeLimit a timeLimitOut';

    var con = _.time.out( t );
    con.timeLimitError( t*6, () => _.time.out( t*3, 'a' ) );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 4 );

    con.tap( ( err, arg ) =>
    {
      test.true( err === undefined );
      test.true( arg === 'a' );
    });

    _.time.out( t, function()
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

    return _.time.out( t*15, function()
    {
      test.true( con.argumentsGet()[ 0 ] === 'a' );
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

    var con = _.time.out( t );
    con.timeLimitError( t*5, () => _.time.out( t*10, 'a' ) );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 4 );

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.true( _.errIs( err ) );
      test.true( arg === undefined );
    });

    _.time.out( t*3, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 3 );
    });

    _.time.out( t*12, function()
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
    con.timeLimitError( t*5, () => _.time.out( t*10, 'a' ) );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 4 );

    con.tap( ( err, arg ) =>
    {
      test.true( _.errIs( err ) );
      test.true( arg === undefined );
      if( err )
      _.errAttend( err );
    });

    _.time.out( t*8, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 5 );
    });

    _.time.out( t*22, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 3 );
    });

    return _.time.out( t*30, function()
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

    var con = _.time.outError( t );
    con.timeLimitError( t*6, () => _.time.out( t*3, 'a' ) );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 4 );

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.true( _.errIs( err ) );
      test.true( arg === undefined );
    });

    _.time.out( t, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
    });

    _.time.out( t*8, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t*15, function()
    {
      test.true( con.errorsGet()[ 0 ].reason === 'time out' );
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

    var con = _.time.outError( t );
    con.timeLimitError( t*5, () => _.time.out( t*10, 'a' ) );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 4 );

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.true( _.errIs( err ) );
      test.true( arg === undefined );
    });

    _.time.out( t*3, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
    });

    _.time.out( t*12, function()
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
    con.timeLimitError( t*5, () => _.time.out( t*10, 'a' ) );

    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 4 );

    con.tap( ( err, arg ) =>
    {
      if( err )
      _.errAttend( err );
      test.true( _.errIs( err ) );
      test.true( arg === undefined );
    });

    _.time.out( t*12, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.competitorsCount(), 5 );
    });

    _.time.out( t*22, function()
    {
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.errorsCount(), 1 );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t*30, function()
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

function timeLimitErrorConsequence( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    test.case = 'passing value';
    var con = _.take( null ).timeLimitError( 0, 'str' );
    test.identical( con.resourcesGet(), [ { error : undefined, argument : 'str' } ] );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    return con;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passing an error';
    var err = _.errAttend( 'str' );
    var con = _.take( null ).timeLimitError( 0, err );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    return con.finally( () => null );
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passing consequence';
    var src = new _.Consequence().take( 'str' );
    var con = _.take( null ).timeLimitError( 0, src );
    test.true( src !== con );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.errorsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    return con;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passing consequence with error';
    var src = new _.Consequence().error( 'str' );
    var con = _.take( null ).timeLimitError( 0, src );
    test.true( src !== con );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.errorsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    con.catch( ( err ) =>
    {
      test.true( _.strHas( String( err ), 'str' ) );
      return null;
    });
    return con;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passing resolved promise';
    var src = Promise.resolve( 'str' );
    var con = _.take( null ).timeLimitError( 10, src );
    return _.time.out( context.t1, function()
    {
      test.identical( con.resourcesGet(), [ { error : undefined, argument : 'str' } ] );
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
    var src = Promise.resolve( 'str' );
    var con = _.take( null ).timeLimitError( 0, src );
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
    var src = Promise.reject( 'str' );
    var con = _.take( null ).timeLimitError( 10, src );
    con.tap( ( err, arg ) =>
    {
      err ? _.errAttend( err ) : null;
    });
    return _.time.out( context.t1, function()
    {
      test.true( _.strHas( String( con.errorsGet()[ 0 ] ), 'str' ) );
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
    var src = Promise.reject( _.errAttend( 'str' ) );
    var con = _.take( null ).timeLimitError( 0, src );
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
    var src = Promise.resolve( 'str' );
    var con = _.take( null ).timeLimitError( context.t1*5, src );
    con.give( ( err, got ) => test.identical( got, 'str' ) && test.identical( err, undefined ) );
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
      setTimeout( () => resolve( 'str' ), context.t1*2 );
    })
    var con = _.take( null ).timeLimitError( context.t1, src );
    con.finally( ( err, got ) =>
    {
      test.true( _.errIs( err ) );
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
    var con = new _.Consequence({ tag : 'con' }).take( 'str' );
    con = _.take( null ).timeLimitError( context.t1, con );
    con.give( ( err, got ) =>
    {
      test.identical( got, 'str' );
      test.identical( err, undefined );
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
    var con = _.time.out( context.t1*2, () => 'str' );
    con.tag = 'con1';
    con = _.take( null ).timeLimitError( context.t1, con );
    con.tag = 'con2';
    con.give( ( err, got ) =>
    {
      test.true( _.errIs( err ) );
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

timeLimitErrorConsequence.timeOut = 30000;

// --
// procedure
// --

function procedureBasic( test )
{
  let pcounter = _.Procedure.Counter;
  let counter = 0;
  let con1 = new _.Consequence({ tag : 'con1' });

  test.case = 'thenKeep';
  test.identical( _.Procedure.Counter - pcounter, 0 );
  con1.thenKeep( counterInc );
  test.identical( _.Procedure.Counter - pcounter, 1 );
  pcounter = _.Procedure.Counter;
  var competitor = con1.competitorHas( counterInc );
  test.identical( competitor.procedure._counter, 0 );
  test.identical( competitor.procedure._name, 'counterInc' );
  test.identical( competitor.procedure.isActivated(), false );
  test.identical( competitor.procedure.isAlive(), true );
  test.identical( competitor.procedure.isFinited(), false );
  test.identical( competitor.procedure.isUsed(), false );
  con1.cancel();
  test.identical( con1.competitorHas( counterInc ), false );

  test.case = 'thenGive';
  test.identical( _.Procedure.Counter - pcounter, 0 );
  con1.thenGive( counterInc );
  test.identical( _.Procedure.Counter - pcounter, 1 );
  pcounter = _.Procedure.Counter;
  var competitor = con1.competitorHas( counterInc );
  test.identical( competitor.procedure._counter, 0 );
  test.identical( competitor.procedure._name, 'counterInc' );
  test.identical( competitor.procedure.isActivated(), false );
  test.identical( competitor.procedure.isAlive(), true );
  test.identical( competitor.procedure.isFinited(), false );
  test.identical( competitor.procedure.isUsed(), false );
  con1.cancel();
  test.identical( con1.competitorHas( counterInc ), false );

  test.case = 'catchKeep';
  test.identical( _.Procedure.Counter - pcounter, 0 );
  con1.catchKeep( counterInc );
  test.identical( _.Procedure.Counter - pcounter, 1 );
  pcounter = _.Procedure.Counter;
  var competitor = con1.competitorHas( counterInc );
  test.identical( competitor.procedure._counter, 0 );
  test.identical( competitor.procedure._name, 'counterInc' );
  test.identical( competitor.procedure.isActivated(), false );
  test.identical( competitor.procedure.isAlive(), true );
  test.identical( competitor.procedure.isFinited(), false );
  test.identical( competitor.procedure.isUsed(), false );
  con1.cancel();
  test.identical( con1.competitorHas( counterInc ), false );

  test.case = 'catchGive';
  test.identical( _.Procedure.Counter - pcounter, 0 );
  con1.catchGive( counterInc );
  test.identical( _.Procedure.Counter - pcounter, 1 );
  pcounter = _.Procedure.Counter;
  var competitor = con1.competitorHas( counterInc );
  test.identical( competitor.procedure._counter, 0 );
  test.identical( competitor.procedure._name, 'counterInc' );
  test.identical( competitor.procedure.isActivated(), false );
  test.identical( competitor.procedure.isAlive(), true );
  test.identical( competitor.procedure.isFinited(), false );
  test.identical( competitor.procedure.isUsed(), false );
  con1.cancel();
  test.identical( con1.competitorHas( counterInc ), false );

  test.case = 'finallyKeep';
  test.identical( _.Procedure.Counter - pcounter, 0 );
  con1.finallyKeep( counterInc );
  test.identical( _.Procedure.Counter - pcounter, 1 );
  pcounter = _.Procedure.Counter;
  var competitor = con1.competitorHas( counterInc );
  test.identical( competitor.procedure._counter, 0 );
  test.identical( competitor.procedure._name, 'counterInc' );
  test.identical( competitor.procedure.isActivated(), false );
  test.identical( competitor.procedure.isAlive(), true );
  test.identical( competitor.procedure.isFinited(), false );
  test.identical( competitor.procedure.isUsed(), false );
  con1.cancel();
  test.identical( con1.competitorHas( counterInc ), false );

  test.case = 'finallyGive';
  test.identical( _.Procedure.Counter - pcounter, 0 );
  con1.finallyGive( counterInc );
  test.identical( _.Procedure.Counter - pcounter, 1 );
  pcounter = _.Procedure.Counter;
  var competitor = con1.competitorHas( counterInc );
  test.identical( competitor.procedure._counter, 0 );
  test.identical( competitor.procedure._name, 'counterInc' );
  test.identical( competitor.procedure.isActivated(), false );
  test.identical( competitor.procedure.isAlive(), true );
  test.identical( competitor.procedure.isFinited(), false );
  test.identical( competitor.procedure.isUsed(), false );
  con1.cancel();
  test.identical( con1.competitorHas( counterInc ), false );

  test.case = 'tap';
  test.identical( _.Procedure.Counter - pcounter, 0 );
  con1.tap( counterInc );
  test.identical( _.Procedure.Counter - pcounter, 1 );
  pcounter = _.Procedure.Counter;
  var competitor = con1.competitorHas( counterInc );
  test.identical( competitor.procedure._counter, 0 );
  test.identical( competitor.procedure._name, 'counterInc' );
  test.identical( competitor.procedure.isActivated(), false );
  test.identical( competitor.procedure.isAlive(), true );
  test.identical( competitor.procedure.isFinited(), false );
  test.identical( competitor.procedure.isUsed(), false );
  con1.cancel();
  test.identical( con1.competitorHas( counterInc ), false );

  function counterInc()
  {
    counter += 1;
    return counter;
  }
}

procedureBasic.description =
`
 - procedure is created for callback in method thenKeep
`

//

function procedureThenKeepCallback( test )
{
  let pcounter = _.Procedure.Counter;
  let counter = 0;
  let con1 = new _.Consequence({ tag : 'con1' });

  test.case = 'first';
  test.identical( _.Procedure.Counter - pcounter, 0 );
  con1.thenKeep( counterInc );
  test.identical( _.Procedure.Counter - pcounter, 1 );
  pcounter = _.Procedure.Counter;
  var competitor = con1.competitorHas( counterInc );
  test.identical( competitor.procedure._counter, 0 );
  test.identical( competitor.procedure._name, 'counterInc' );
  test.identical( competitor.procedure.isActivated(), false );
  test.identical( competitor.procedure.isAlive(), true );
  test.identical( competitor.procedure.isFinited(), false );
  test.identical( competitor.procedure.isUsed(), false );

  test.case = 'second';
  test.identical( _.Procedure.Counter - pcounter, 0 );
  con1.thenKeep( counterInc );
  test.identical( _.Procedure.Counter - pcounter, 1 );
  pcounter = _.Procedure.Counter;
  var competitor = con1.competitorsGet()[ 1 ];
  test.identical( competitor.procedure._counter, 0 );
  test.identical( competitor.procedure._name, 'counterInc' );
  test.identical( competitor.procedure.isActivated(), false );
  test.identical( competitor.procedure.isAlive(), true );
  test.identical( competitor.procedure.isFinited(), false );
  test.identical( competitor.procedure.isUsed(), false );

  con1.cancel();

  function counterInc()
  {
    counter += 1;
    return counter;
  }
}

procedureThenKeepCallback.description =
`
 - several procedures is created for callback in method thenKeep
`

//

function procedureForConsequence( test )
{
  let pcounter = _.Procedure.Counter;
  let con1 = new _.Consequence({ tag : 'con1' });
  let con2 = new _.Consequence({ tag : 'con2' });

  test.identical( _.Procedure.Counter - pcounter, 0 );
  con2.then( () => con1 );
  test.identical( _.Procedure.Counter - pcounter, 1 );
  pcounter = _.Procedure.Counter;
  con2.take( null )
  test.identical( _.Procedure.Counter - pcounter, 0 );
  pcounter = _.Procedure.Counter;

}

procedureForConsequence.description =
`
 - no procedue is created for consequence
`

//

function procedureStatesThenKeep( test )
{
  let pcounter = _.Procedure.Counter;
  let counter = 0;
  let con1 = new _.Consequence({ tag : 'con1' });

  test.case = 'basic';
  test.identical( _.Procedure.Counter - pcounter, 0 );
  con1.thenKeep( counterInc );
  test.identical( _.Procedure.Counter - pcounter, 1 );
  pcounter = _.Procedure.Counter;
  var competitor = con1.competitorHas( counterInc );
  test.identical( competitor.procedure._counter, 0 );
  test.identical( competitor.procedure._name, 'counterInc' );
  test.identical( competitor.procedure.isActivated(), false );
  test.identical( competitor.procedure.isAlive(), true );
  test.identical( competitor.procedure.isFinited(), false );
  test.identical( competitor.procedure.isUsed(), false );

  con1.take( null );

  test.identical( competitor.procedure._counter, 0 );
  test.identical( competitor.procedure._name, 'counterInc' );
  test.identical( competitor.procedure.isActivated(), false );
  test.identical( competitor.procedure.isAlive(), false );
  test.identical( competitor.procedure.isFinited(), true );
  test.identical( competitor.procedure.isUsed(), false );

  con1.cancel();
  test.identical( counter, 1 );

  function counterInc()
  {
    counter += 1;
    test.identical( competitor.procedure._counter, 1 );
    test.identical( competitor.procedure._name, 'counterInc' );
    test.identical( competitor.procedure.isActivated(), true );
    test.identical( competitor.procedure.isAlive(), true );
    test.identical( competitor.procedure.isFinited(), false );
    test.identical( competitor.procedure.isUsed(), true );
    return counter;
  }
}

procedureStatesThenKeep.description =
`
 - states of procedure changed properly during lifecycle of thenKeep
`

//

function procedureStatesTap( test )
{
  let pcounter = _.Procedure.Counter;
  let counter = 0;
  let con1 = new _.Consequence({ tag : 'con1' });

  test.case = 'first';
  test.identical( _.Procedure.Counter - pcounter, 0 );
  con1.tap( counterInc );
  test.identical( _.Procedure.Counter - pcounter, 1 );
  pcounter = _.Procedure.Counter;
  var competitor = con1.competitorHas( counterInc );
  test.identical( competitor.procedure._counter, 0 );
  test.identical( competitor.procedure._name, 'counterInc' );
  test.identical( competitor.procedure.isActivated(), false );
  test.identical( competitor.procedure.isAlive(), true );
  test.identical( competitor.procedure.isFinited(), false );
  test.identical( competitor.procedure.isUsed(), false );

  con1.take( null );

  test.identical( competitor.procedure._counter, 0 );
  test.identical( competitor.procedure._name, 'counterInc' );
  test.identical( competitor.procedure.isActivated(), false );
  test.identical( competitor.procedure.isAlive(), false );
  test.identical( competitor.procedure.isFinited(), true );
  test.identical( competitor.procedure.isUsed(), false );

  con1.cancel();
  test.identical( counter, 1 );

  function counterInc()
  {
    counter += 1;
    test.identical( competitor.procedure._counter, 1 );
    test.identical( competitor.procedure._name, 'counterInc' );
    test.identical( competitor.procedure.isActivated(), true );
    test.identical( competitor.procedure.isAlive(), true );
    test.identical( competitor.procedure.isFinited(), false );
    test.identical( competitor.procedure.isUsed(), true );
    return counter;
  }
}

procedureStatesTap.description =
`
 - states of procedure changed properly during lifecycle of tap
`

//

function procedureOff( test )
{
  let pcounter = _.Procedure.Counter;
  let counter = 0;
  let con1 = new _.Consequence({ tag : 'con1' });
  test.identical( con1._procedure, null );
  con1.procedure( false );
  test.identical( con1._procedure, false );

  test.case = 'first';
  test.identical( con1._procedure, false );
  test.identical( _.Procedure.Counter - pcounter, 0 );
  con1.thenKeep( counterInc );
  test.identical( _.Procedure.Counter - pcounter, 0 );
  pcounter = _.Procedure.Counter;
  var competitor = con1.competitorHas( counterInc );
  test.identical( competitor.procedure, null );

  test.case = 'second';
  test.identical( con1._procedure, false );
  test.identical( _.Procedure.Counter - pcounter, 0 );
  con1.thenKeep( counterInc );
  test.identical( _.Procedure.Counter - pcounter, 0 );
  pcounter = _.Procedure.Counter;
  var competitor = con1.competitorsGet()[ 1 ];
  test.identical( competitor.procedure, null );

  con1.take( null );
  test.identical( con1.competitorHas( counterInc ), false );
  test.identical( competitor.procedure, null );

  test.case = 'third';
  test.identical( con1._procedure, false );
  test.identical( _.Procedure.Counter - pcounter, 0 );
  con1.thenKeep( counterInc );
  test.identical( _.Procedure.Counter - pcounter, 0 );
  pcounter = _.Procedure.Counter;
  test.identical( con1.competitorHas( counterInc ), false );

  con1.cancel();
  test.identical( counter, 3 );

  function counterInc()
  {
    counter += 1;
    test.identical( competitor.procedure, null );
    return counter;
  }
}

procedureOff.description =
`
 - no procedures are created if _procedure is false
 - consequence.procedure( false ) switch off generating of procedures
`

//

function procedureOffOn( test )
{
  let pcounter = _.Procedure.Counter;
  let counter = 0;
  let con1 = new _.Consequence({ tag : 'con1' });

  test.case = 'off';
  test.identical( con1._procedure, null );
  con1.procedure( false );
  test.identical( con1._procedure, false );
  test.identical( _.Procedure.Counter - pcounter, 0 );
  con1.thenKeep( counterInc );
  test.identical( _.Procedure.Counter - pcounter, 0 );
  pcounter = _.Procedure.Counter;
  var competitor1 = con1.competitorHas( counterInc );
  test.identical( competitor1.procedure, null );
  test.identical( con1._procedure, false );

  test.case = 'on first';
  test.identical( con1._procedure, false );
  con1.procedure( true );
  test.identical( con1._procedure, null );
  test.identical( _.Procedure.Counter - pcounter, 0 );
  con1.thenKeep( counterInc );
  test.identical( _.Procedure.Counter - pcounter, 1 );
  pcounter = _.Procedure.Counter;
  var competitor2 = con1.competitorsGet()[ 1 ];
  test.identical( competitor2.procedure._counter, 0 );
  test.identical( competitor2.procedure._name, 'counterInc' );
  test.identical( competitor2.procedure.isActivated(), false );
  test.identical( competitor2.procedure.isAlive(), true );
  test.identical( competitor2.procedure.isFinited(), false );
  test.identical( competitor2.procedure.isUsed(), false );

  test.case = 'on second';
  test.identical( con1._procedure, null );
  test.identical( _.Procedure.Counter - pcounter, 0 );
  con1.thenKeep( counterInc );
  test.identical( _.Procedure.Counter - pcounter, 1 );
  pcounter = _.Procedure.Counter;
  var competitor3 = con1.competitorsGet()[ 2 ];
  test.identical( competitor3.procedure._counter, 0 );
  test.identical( competitor3.procedure._name, 'counterInc' );
  test.identical( competitor3.procedure.isActivated(), false );
  test.identical( competitor3.procedure.isAlive(), true );
  test.identical( competitor3.procedure.isFinited(), false );
  test.identical( competitor3.procedure.isUsed(), false );

  con1.take( null );
  test.identical( con1.competitorHas( counterInc ), false );
  test.true( competitor1.procedure === null );
  test.true( !!competitor2.procedure );
  test.true( !!competitor3.procedure );

  con1.cancel();
  test.identical( counter, 3 );

  function counterInc()
  {
    counter += 1;
    return counter;
  }
}

procedureOffOn.description =
`
 - no procedures are created if _procedure is false
 - consequence.procedure( false ) switch off generating of procedures
`

// --
// and
// --

function andTakeProcedure( test )
{
  let context = this;

  let ready = new _.Consequence().take( null );

  /* */

  ready.then( function andTake1( arg )
  {
    test.case = 'andTake';

    let delay = context.t1;
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con = new _.Consequence({ tag : 'con' });

    test.identical( mainCon.competitorsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );

    mainCon.take( null );
    mainCon.andTake( () => con );

    mainCon.finally( function( err, got )
    {
      test.identical( con.competitorsCount(), 0 );
      return null;
    });

    test.identical( con.competitorsCount(), 1 );
    test.identical( mainCon.competitorsCount(), 1 );

    mainCon.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'andTake1' ) );
    })

    con.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'andTake1' ) );
    })

    _.time.out( delay, () => { con.take( delay ); return null; });

    return mainCon;
  })

  return ready;
}

//

function andKeepProcedure( test )
{
  let context = this;

  let ready = new _.Consequence().take( null );

  /* */

  ready.then( function andKeep1( arg )
  {
    test.case = 'andKeep';

    let delay = context.t1;
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con = new _.Consequence({ tag : 'con' });

    test.identical( mainCon.competitorsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );

    mainCon.take( null );
    mainCon.andKeep( () => con );

    mainCon.finally( function( err, got )
    {
      test.identical( con.competitorsCount(), 0 );
      return null;
    });

    test.identical( con.competitorsCount(), 1 );
    test.identical( mainCon.competitorsCount(), 1 );

    mainCon.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'andKeep1' ) );
    })

    con.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'andKeep1' ) );
    })

    _.time.out( delay, () => { con.take( delay ); return null; });

    return mainCon;
  })

  return ready;
}

//

function andKeepAccumulativeProcedure( test )
{
  let context = this;

  let ready = new _.Consequence().take( null );

  /* */

  ready.then( function andKeepAccumulative1( arg )
  {
    test.case = 'andKeepAccumulative';

    let delay = context.t1;
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con = new _.Consequence({ tag : 'con' });

    test.identical( mainCon.competitorsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );

    mainCon.take( null );
    mainCon.andKeepAccumulative( () => con );

    mainCon.finally( function( err, got )
    {
      test.identical( con.competitorsCount(), 0 );
      return null;
    });

    test.identical( con.competitorsCount(), 1 );
    test.identical( mainCon.competitorsCount(), 1 );

    mainCon.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'andKeepAccumulative1' ) );
    })

    con.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'andKeepAccumulative1' ) );
    })

    _.time.out( delay, () => { con.take( delay ); return null; });

    return mainCon;
  })

  return ready;
}

//

function andImmediateProcedure( test )
{
  let context = this;

  let ready = new _.Consequence().take( null );

  /* */

  ready.then( function andImmediate1( arg )
  {
    test.case = 'andImmediate';

    let delay = context.t1;
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con = new _.Consequence({ tag : 'con' });

    test.identical( mainCon.competitorsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );

    mainCon.take( null );
    mainCon.andImmediate( () => con );

    mainCon.finally( function( err, got )
    {
      test.identical( con.competitorsCount(), 0 );
      return null;
    });

    test.identical( con.competitorsCount(), 1 );
    test.identical( mainCon.competitorsCount(), 1 );

    mainCon.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'andImmediate1' ) );
    })

    con.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'andImmediate1' ) );
    })

    _.time.out( delay, () => { con.take( delay ); return null; });

    return mainCon;
  })

  return ready;
}

//

function AndTakeProcedure( test )
{
  let context = this;

  let ready = new _.Consequence().take( null );

  /* */

  ready.then( function AndTake1( arg )
  {
    test.case = 'AndTake';

    let delay = context.t1;
    var con1 = new _.Consequence({ tag : 'mainCon' });
    var con2 = new _.Consequence({ tag : 'con' });

    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    let conOwner = _.Consequence.AndTake( con1, con2 );

    con1.take( null );
    con2.take( null );

    con1.finally( function( err, got )
    {
      test.identical( con1.competitorsCount(), 0 );
      return null;
    });

    con2.finally( function( err, got )
    {
      test.identical( con2.competitorsCount(), 0 );
      return null;
    });

    test.identical( con1.competitorsCount(), 1 );
    test.identical( con2.competitorsCount(), 1 );
    test.identical( conOwner.competitorsCount(), 1 );

    con1.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'AndTake1' ) );
    })

    con2.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'AndTake1' ) );
    })

    conOwner.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'AndTake1' ) );
    })

    return _.time.out( delay * 4, function()
    {
      con1.cancel();
      con2.cancel();
      return null;
    });

  })

  return ready;
}

//

function AndKeepProcedure( test )
{
  let context = this;

  let ready = new _.Consequence().take( null );

  /* */

  ready.then( function AndKeep1( arg )
  {
    test.case = 'AndKeep';

    let delay = context.t1;
    var con1 = new _.Consequence({ tag : 'mainCon' });
    var con2 = new _.Consequence({ tag : 'con' });

    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    let conOwner = _.Consequence.AndKeep( con1, con2 );

    con1.take( null );
    con2.take( null );

    con1.finally( function( err, got )
    {
      test.identical( con1.competitorsCount(), 0 );
      return null;
    });

    con2.finally( function( err, got )
    {
      test.identical( con2.competitorsCount(), 0 );
      return null;
    });

    test.identical( con1.competitorsCount(), 1 );
    test.identical( con2.competitorsCount(), 1 );
    test.identical( conOwner.competitorsCount(), 1 );

    con1.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'AndKeep1' ) );
    })

    con2.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'AndKeep1' ) );
    })

    conOwner.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'AndKeep1' ) );
    })

    return _.time.out( delay * 4, function()
    {
      con1.cancel();
      con2.cancel();
      return null;
    });

  })

  return ready;
}

//

function AndImmediateProcedure( test )
{
  let context = this;

  let ready = new _.Consequence().take( null );

  /* */

  ready.then( function AndImmediate1( arg )
  {
    test.case = 'AndImmediate';

    let delay = context.t1;
    var con1 = new _.Consequence({ tag : 'mainCon' });
    var con2 = new _.Consequence({ tag : 'con' });

    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    let conOwner = _.Consequence.AndImmediate( con1, con2 );

    con1.finally( function( err, got )
    {
      test.identical( con1.competitorsCount(), 0 );
      return null;
    });

    con2.finally( function( err, got )
    {
      test.identical( con2.competitorsCount(), 0 );
      return null;
    });

    test.identical( con1.competitorsCount(), 2 );
    test.identical( con2.competitorsCount(), 2 );
    test.identical( conOwner.competitorsCount(), 1 );

    con1.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'AndImmediate1' ) );
    })

    con2.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'AndImmediate1' ) );
    })

    conOwner.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'AndImmediate1' ) );
    })

    con1.take( null );
    con2.take( null );

    return _.time.out( delay * 4, function()
    {
      con1.cancel();
      con2.cancel();
      return null;
    });

  })

  return ready;
}

//

function andTake( test )
{
  let context = this;

  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    test.case = 'andTake waits only for first resource, dont return the resource';
    let delay = context.t1;
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con = new _.Consequence({ tag : 'con' });

    mainCon.take( 'str' );

    mainCon.andTake( con );

    mainCon.finally( function( err, got )
    {
      test.identical( got, [ delay, 'str' ] )
      test.identical( err, undefined );
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

    mainCon.take( 'str' );

    mainCon.andTake( () => con );

    mainCon.finally( function( err, got )
    {
      test.identical( got, [ delay, 'str' ] );
      test.identical( err, undefined );
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

    mainCon.take( 'str' );

    mainCon.andTake( srcs );

    mainCon.finally( function( err, got )
    {
      test.identical( got, [ delay, delay * 2, 'str' + 'str', 'str' ] );
      test.identical( err, undefined );

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
    con3.take( 'str' + 'str' );

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

    var srcs = [ con3, con1, con2 ];

    mainCon.take( 'str' );

    mainCon.andTake( srcs );

    mainCon.finally( function( err, got )
    {
      test.identical( got, [ 'con3', 'con1', 'con2', 'str' ] );
      test.identical( err, undefined );

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

    var srcs = [ con1, con2 ];

    con1.take( null );
    con1.finally( () => con2 );
    con1.finally( () => 'con1' );

    mainCon.take( 'str' );

    mainCon.andTake( srcs );

    mainCon.finally( function( err, got )
    {
      test.identical( got, [ 'con1', 'con2', 'str' ] );
      test.identical( err, undefined );

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

    var srcs = [ con1, con2 ];

    mainCon.take( 'str' );

    mainCon.andTake( srcs );

    mainCon.finally( function( err, got )
    {
      test.true( _.strHas( String( err ), 'con1' ) );
      test.identical( got, undefined );

      test.identical( mainCon.resourcesCount(), 0 );

      test.identical( con1.resourcesCount(), 0 );
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesCount(), 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );

      return null;
    });

    _.time.out( delay, () => { con1.error( 'con1' );return null; } )
    var t = _.time.out( delay * 2, () => { con2.take( 'con2' );return null; } )

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

    mainCon.take( 'str' );

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

function andTakeExtended( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )

  /* */

  .then( ( arg ) =>
  {
    test.case = 'take take';
    let t = context.t1;
    let track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = new _.Consequence().take( 3 );
    con.andTake([ con1, con2 ]);

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, 2, 3 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.take' );
      con1.take( 1 );
    });
    _.time.out( t + t/2, () =>
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.take' );
      con2.take( 2 )
    });
    _.time.out( t * 2 + t/2, () =>
    {
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'con1.take', 'con2.take', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
      con1.cancel();
      con2.cancel();
      return null;
    });

  })

  /* */

  .then( ( arg ) =>
  {
    test.case = 'error take';
    let t = context.t1;
    let track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = new _.Consequence().take( 3 );
    con.andTake([ con1, con2 ]);
    let err1 = _.errAttend( 'Error1' );

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.error' );
      con1.error( err1 );
    });
    _.time.out( t + t/2, () =>
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.take' );
      con2.take( 2 )
    });
    _.time.out( t * 2 + t/2, () =>
    {
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'con1.error', 'con2.take', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
      con1.cancel();
      con2.cancel();
      return null;
    });

  })

  /* */

  .then( ( arg ) =>
  {
    test.case = 'take error';
    let t = context.t1;
    let track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = new _.Consequence().take( 3 );
    con.andTake([ con1, con2 ]);
    let err1 = _.errAttend( 'Error1' );

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.take' );
      con1.take( 1 );
    });
    _.time.out( t + t/2, () =>
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.error' );
      con2.error( err1 )
    });
    _.time.out( t * 2 + t/2, () =>
    {
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'con1.take', 'con2.error', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
      con1.cancel();
      con2.cancel();
      return null;
    });

  })

  /* */

  return ready;
}

//

function andTakeWithPromise( test )
{
  let context = this;
  let t = context.t1;
  let track;
  let ready = new _.Consequence().take( null );
  let err1, err2;

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - resolved, promise2 - resolved';
    track = [];
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( resolve2 );
    let con = new _.Consequence().take( 3 );
    con.andTake([ promise1, promise2 ]);

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, 2, 3 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.resolve', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - rejected, promise2 - resolved';
    track = [];
    err1 = _.errAttend( 'reject1' );
    let promise1 = new Promise( reject1 );
    let promise2 = new Promise( resolve2 );
    let con = new _.Consequence().take( 3 );
    con.andTake([ promise1, promise2 ]);

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.reject', 'promise2.resolve', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - resolved, promise2 - rejected';
    track = [];
    err2 = _.errAttend( 'reject2' );
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( reject2 );
    let con = new _.Consequence().take( 3 );
    con.andTake([ promise1, promise2 ]);

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err2 );
      test.identical( con.resourcesGet(), [ { 'error' : err2, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.reject', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err2, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - rejected, promise2 - rejected';
    track = [];
    err1 = _.errAttend( 'reject1' );
    err2 = _.errAttend( 'reject2' );
    let promise1 = new Promise( reject1 );
    let promise2 = new Promise( reject2 );
    let con = new _.Consequence().take( 3 );
    con.andTake([ promise1, promise2 ]);

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.reject', 'promise2.reject', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  return ready;

  /* */

  function resolve1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.resolve' ); resolve( 1 ) } );
  }

  function resolve2( resolve, reject )
  {
    return _.time.out( t + t, () => { track.push( 'promise2.resolve' ); resolve( 2 ) } );
  }

  function reject1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.reject' ); reject( err1 ) } );
  }

  function reject2( resolve, reject )
  {
    return _.time.out( t + t, () => { track.push( 'promise2.reject' ); reject( _.errAttend( err2 ) ) } );
  }
}

//

function andTakeWithPromiseAndConsequence( test )
{
  let context = this;
  let t = context.t1;
  let track;
  let ready = new _.Consequence().take( null );
  let err1, err2;

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - resolved, promise2 - resolved, con - take';
    track = [];
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( resolve2 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = new _.Consequence().take( 4 );
    con.andTake([ promise1, promise2, con1 ]);

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, 2, 3, 4 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 3, 4 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.take' );
      con1.take( 3 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.resolve', 'con1.take', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 3, 4 ] } ] );
      test.identical( con.competitorsCount(), 0 );

      con1.cancel();
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - rejected, promise2 - resolved, con - take';
    track = [];
    err1 = _.errAttend( 'rejected1' );
    let promise1 = new Promise( reject1 );
    let promise2 = new Promise( resolve2 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = new _.Consequence().take( 3 );
    con.andTake([ promise1, promise2, con1 ]);

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.take' );
      con1.take( 3 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.reject', 'promise2.resolve', 'con1.take', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );

      con1.cancel();
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - resolved, promise2 - resolved, con - error';
    track = [];
    err1 = _.errAttend( 'err1' );
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( resolve2 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = new _.Consequence().take( 3 );
    con.andTake([ promise1, promise2, con1 ]);

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.error' );
      con1.error( err1 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.resolve', 'con1.error', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );

      con1.cancel();
      return null;
    });
  });

  /* */

  return ready;

  /* */

  function resolve1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.resolve' ); resolve( 1 ) } );
  }

  function resolve2( resolve, reject )
  {
    return _.time.out( t + t, () => { track.push( 'promise2.resolve' ); resolve( 2 ) } );
  }

  function reject1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.reject' ); reject( err1 ) } );
  }
}

//

function andTakeWithMixedCompetitors( test )
{
  let context = this;
  let t = context.t1;
  let track;
  let ready = new _.Consequence().take( null );
  let err1, err2;

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'none of async competitors';
    track = [];
    let con = new _.Consequence().take( 3 );
    con.andTake([ 'str', null, 1 ]);

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 'str', null, 1, 3 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 'str', null, 1, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t, () =>
    {
      var exp = [ 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 'str', null, 1, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'none of async competitors and error';
    track = [];
    err1 = _.errAttend( 'err' );
    let con = new _.Consequence().take( 3 );
    con.andTake([ [], {}, 'str', err1 ]);

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ [], {}, 'str', err1, 3 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ [], {}, 'str', err1, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t, () =>
    {
      var exp = [ 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ [], {}, 'str', err1, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise, routine, string, consequence';
    track = [];
    let promise = new Promise( resolve1 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = new _.Consequence().take( 4 );
    con.andTake([ promise, routineReturnsConsequence, 'str', con1 ]);

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, null, 'str', 3, 4 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, null, 'str', 3, 4 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.take' );
      con1.take( 3 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'routine.con', 'promise1.resolve', 'con1.take', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, null, 'str', 3, 4 ] } ] );
      test.identical( con.competitorsCount(), 0 );

      con1.cancel();
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'routine, string, consequence, promise, null';
    track = [];
    let promise = new Promise( resolve1 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = new _.Consequence().take( 4 );
    con.andTake([ routineReturnsConsequence, 'str', con1, promise, null ]);

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ null, 'str', 3, 1, null, 4 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ null, 'str', 3, 1, null, 4 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.take' );
      con1.take( 3 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'routine.con', 'promise1.resolve', 'con1.take', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ null, 'str', 3, 1, null, 4 ] } ] );
      test.identical( con.competitorsCount(), 0 );

      con1.cancel();
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'routine, string, consequence, promise, null, consequence - error';
    track = [];
    err1 = _.errAttend( 'err' );
    let promise = new Promise( resolve1 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = new _.Consequence().take( 3 );
    con.andTake([ routineReturnsConsequence, 'str', con1, promise, null ]);

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.error' );
      con1.error( err1 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'routine.con', 'promise1.resolve', 'con1.error', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );

      con1.cancel();
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'competitor - undefined, should throw error';
    return test.shouldThrowErrorOfAnyKind( () =>
    {
      new _.Consequence().take( 3 );
      con.andTake([ routineReturnsConsequence, 'str', con1, promise, null ]);
    });
  });

  /* */

  return ready;

  /* */

  function routineReturnsConsequence()
  {
    track.push( 'routine.con' );
    return _.take( null );
  }

  function resolve1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.resolve' ); resolve( 1 ) } );
  }

  function reject1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.reject' ); reject( err1 ) } );
  }
}

//

function andTakeWithSeveralIdenticalCompetitors( test )
{
  let context = this;
  let t = context.t1;
  let track;
  let ready = new _.Consequence().take( null );
  let err1, err2;

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'few identical consequences in queue';
    track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = new _.Consequence().take( 3 );
    con.andTake([ con1, con2, con1, con2 ]);

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( got, 1 );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    con2.tap( ( err, got ) =>
    {
      track.push( 'con2.tap' );
      test.identical( got, 2 );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, 2, 1, 2, 3 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.take' );
      con1.take( 1 );
    });

    _.time.out( t + t, () =>
    {
      track.push( 'con2.take' );
      con2.take( 2 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'con1.take', 'con2.take', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );

      con1.cancel();
      con2.cancel();
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'few identical promises in queue';
    track = [];
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( resolve2 );
    let con = new _.Consequence().take( 3 );
    con.andTake([ promise2, promise1, promise1, promise2 ]);

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 2, 1, 1, 2, 3 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 2, 1, 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.resolve', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 2, 1, 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  return ready;

  /* */

  function resolve1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.resolve' ); resolve( 1 ) } );
  }

  function resolve2( resolve, reject )
  {
    return _.time.out( t + t, () => { track.push( 'promise2.resolve' ); resolve( 2 ) } );
  }
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
    test.true( err === undefined );
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
      test.true( _.errIs( err ) );
      else
      test.true( err === undefined );

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

  // xxx
  // ready.then( ( arg ) =>
  // {
  //   test.case = 'mixed take';
  //
  //   var con = _.Consequence({ capacity : 0 });
  //   var con1 = new _.Consequence({ tag : 'con1' });
  //   var con2 = new _.Consequence({ tag : 'con2' });
  //   var con3 = new _.Consequence({ tag : 'con3' });
  //   var cons =
  //   [
  //     con3,
  //     con3,
  //     con1,
  //     con2,
  //     con2,
  //     con2,
  //     con1,
  //   ]
  //
  //   con1.take( 1 );
  //   con.take( null );
  //   con.andKeep( cons );
  //   con2.take( 2 );
  //   con.finally( ( err, arg ) =>
  //   {
  //     test.identical( err, undefined );
  //     test.identical( arg, [ 3, 3, 1, 2, 2, 2, 1, null ] );
  //     if( Config.debug )
  //     test.identical( con._dependsOf.length, 0 );
  //
  //     test.identical( con1.exportString({ verbosity : 1 }), 'Consequence::con1 1 / 0' );
  //     test.identical( con2.exportString({ verbosity : 1 }), 'Consequence::con2 1 / 0' );
  //     test.identical( con3.exportString({ verbosity : 1 }), 'Consequence::con3 1 / 0' );
  //     test.identical( con1.argumentsGet(), [ 1 ] );
  //     test.identical( con2.argumentsGet(), [ 2 ] );
  //     test.identical( con3.argumentsGet(), [ 3 ] );
  //
  //     if( err )
  //     throw err;
  //     return arg;
  //   })
  //
  //   _.time.begin( 30, () => con3.take( 3 ) );
  //
  //   return con;
  // })

  /* */

  return ready;
}

//

function andKeepInstant( test )
{
  let context = this;

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
    var srcs = [ con3, con1, con2 ];

    mainCon.take( 'str' );

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
      test.identical( got, [ 'con3a', 'con1a', 'con2a', 'str' ] );
      test.identical( err, undefined );
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
      var expected =[];
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
      var expected = [];
      test.identical( con3.resourcesGet(), expected );
      test.identical( con3.competitorsEarlyGet().length, 0 );
    }

  }

}

//

function andKeep( test )
{
  let context = this;

  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    test.case = 'andKeep waits only for first resource and return it back';
    let delay = context.t1;
    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con = new _.Consequence({ tag : 'con', capacity : 2 });

    mainCon.take( 'str' );

    mainCon.andKeep( con );

    mainCon.finally( function( err, got )
    {
      test.identical( got, [ delay, 'str' ] );
      test.identical( err, undefined );
      test.identical( mainCon.resourcesCount(), 0 );
      test.identical( con.resourcesGet(), [ { error : undefined, argument : delay } ] );
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

    mainCon.take( 'str' );

    mainCon.andKeep( () => con );

    mainCon.finally( function( err, got )
    {
      test.identical( got, [ delay, 'str' ] );
      test.identical( err, undefined );
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

    mainCon.take( 'str' );

    mainCon.andKeep( srcs );

    mainCon.finally( function( err, got )
    {
      test.identical( got, [ delay, delay * 2, 'str' + 'str', 'str' ] )
      test.identical( mainCon.resourcesCount(), 0 );
      test.identical( err, undefined );

      test.identical( con1.resourcesGet(), [ { error : undefined, argument : delay } ]);
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesGet(), [ { error : undefined, argument : delay * 2 } ]);
      test.identical( con2.competitorsEarlyGet().length, 0 );

      test.identical( con3.resourcesGet(), [ { error : undefined, argument : 'str' + 'str' } ]);
      test.identical( con3.competitorsEarlyGet().length, 0 );

      return null;
    });

    _.time.out( delay, () => { con1.take( delay );return null; });
    _.time.out( delay * 2, () => { con2.take( delay * 2 );return null; });
    con3.take( 'str' + 'str' );

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
    var srcs = [ con3, con1, con2 ];

    mainCon.take( 'str' );

    mainCon.andKeep( srcs );

    mainCon.finally( function( err, got )
    {
      test.identical( got, [ 'con3', 'con1', 'con2', 'str' ] );
      test.identical( mainCon.resourcesCount(), 0 );
      test.identical( err, undefined );

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

    var srcs = [ con3, con1, con2 ];

    mainCon.take( 'str' );

    mainCon.andKeep( srcs );

    mainCon.finally( function( err, got )
    {
      test.identical( got, [ 'con3', 'con1', 'con2', 'str' ] );
      test.identical( mainCon.resourcesCount(), 0 );
      test.identical( err, undefined );

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

    var srcs = [ con1, con2 ];

    con1.take( null );
    con1.finally( () => con2 );
    con1.finally( () => 'con1' );

    mainCon.take( 'str' );

    mainCon.andTake( srcs );

    mainCon.finally( function( err, got )
    {
      test.identical( got, [ 'con1', 'con2', 'str' ] );
      test.identical( err, undefined );

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

    var srcs = [ con1, con2 ];

    mainCon.take( 'str' );

    mainCon.andKeep( srcs );

    mainCon.finally( function( err, got )
    {
      test.true( _.strHas( String( err ), 'con1' ) );
      test.identical( got, undefined );

      test.identical( mainCon.resourcesCount(), 0 );

      test.identical( con1.resourcesCount(), 1 );
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesCount(), 1 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

    _.time.out( delay, () => { con1.error( 'con1' );return null; } )
    var t = _.time.out( delay * 2, () => { con2.take( 'con2' );return null; } )

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

    mainCon.take( 'str' );

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

function andKeepExtended( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )

  /* */

  .then( ( arg ) =>
  {
    test.case = 'take take';
    let t = context.t1;
    let track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = new _.Consequence().take( 3 );
    con.andKeep([ con1, con2 ]);

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, 2, 3 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.take' );
      con1.take( 1 );
    });
    _.time.out( t + t/2, () =>
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.take' );
      con2.take( 2 )
    });
    _.time.out( t * 2 + t/2, () =>
    {
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'con1.take', 'con2.take', 'con1.tap', 'con2.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  })

  /* */

  .then( ( arg ) =>
  {
    test.case = 'error take';
    let t = context.t1;
    let track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = new _.Consequence().take( 3 );
    con.andKeep([ con1, con2 ]);
    let err1 = _.errAttend( 'Error1' );

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.error' );
      con1.error( err1 );
    });
    _.time.out( t + t/2, () =>
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.take' );
      con2.take( 2 )
    });
    _.time.out( t * 2 + t/2, () =>
    {
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'con1.error', 'con2.take', 'con1.tap', 'con2.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  })

  /* */

  .then( ( arg ) =>
  {
    test.case = 'take error';
    let t = context.t1;
    let track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = _.Consequence().take( 3 );
    con.andKeep([ con1, con2 ]);
    let err1 = _.errAttend( 'Error1' );

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.take' );
      con1.take( 1 );
    });
    _.time.out( t + t/2, () =>
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.error' );
      con2.error( err1 )
    });
    _.time.out( t * 2 + t/2, () =>
    {
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'con1.take', 'con2.error', 'con1.tap', 'con2.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  })

  /* */

  return ready;
}

//

function andKeepWithPromise( test )
{
  let context = this;
  let t = context.t1;
  let track;
  let ready = new _.Consequence().take( null );
  let err1, err2;

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - resolved, promise2 - resolved';
    track = [];
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( resolve2 );
    let con = new _.Consequence().take( 3 );
    con.andKeep([ promise1, promise2 ]);

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, 2, 3 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.resolve', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - rejected, promise2 - resolved';
    track = [];
    err1 = _.errAttend( 'reject1' );
    let promise1 = new Promise( reject1 );
    let promise2 = new Promise( resolve2 );
    let con = new _.Consequence().take( 3 );
    con.andKeep([ promise1, promise2 ]);

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.reject', 'promise2.resolve', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - resolved, promise2 - rejected';
    track = [];
    err2 = _.errAttend( 'reject2' );
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( reject2 );
    let con = new _.Consequence().take( 3 );
    con.andKeep([ promise1, promise2 ]);

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err2 );
      test.identical( con.resourcesGet(), [ { 'error' : err2, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.reject', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err2, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - rejected, promise2 - rejected';
    track = [];
    err1 = _.errAttend( 'reject1' );
    err2 = _.errAttend( 'reject2' );
    let promise1 = new Promise( reject1 );
    let promise2 = new Promise( reject2 );
    let con = new _.Consequence().take( 3 );
    con.andKeep([ promise1, promise2 ]);

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.reject', 'promise2.reject', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  return ready;

  /* */

  function resolve1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.resolve' ); resolve( 1 ) } );
  }

  function resolve2( resolve, reject )
  {
    return _.time.out( t + t, () => { track.push( 'promise2.resolve' ); resolve( 2 ) } );
  }

  function reject1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.reject' ); reject( err1 ) } );
  }

  function reject2( resolve, reject )
  {
    return _.time.out( t + t, () => { track.push( 'promise2.reject' ); reject( _.errAttend( err2 ) ) } );
  }
}

//

function andKeepWithPromiseAndConsequence( test )
{
  let context = this;
  let t = context.t1;
  let track;
  let ready = new _.Consequence().take( null );
  let err1, err2;

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - resolved, promise2 - resolved, con - take';
    track = [];
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( resolve2 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = new _.Consequence().take( 4 );
    con.andKeep([ promise1, promise2, con1 ]);

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, 2, 3, 4 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 3, 4 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.take' );
      con1.take( 3 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.resolve', 'con1.take', 'con1.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 3, 4 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - rejected, promise2 - resolved, con - take';
    track = [];
    err1 = _.errAttend( 'rejected1' );
    let promise1 = new Promise( reject1 );
    let promise2 = new Promise( resolve2 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = new _.Consequence().take( 3 );
    con.andKeep([ promise1, promise2, con1 ]);

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.take' );
      con1.take( 3 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.reject', 'promise2.resolve', 'con1.take', 'con1.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - resolved, promise2 - resolved, con - error';
    track = [];
    err1 = _.errAttend( 'err1' );
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( resolve2 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = new _.Consequence().take( 3 );
    con.andKeep([ promise1, promise2, con1 ]);

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.error' );
      con1.error( err1 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.resolve', 'con1.error', 'con1.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  return ready;

  /* */

  function resolve1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.resolve' ); resolve( 1 ) } );
  }

  function resolve2( resolve, reject )
  {
    return _.time.out( t + t, () => { track.push( 'promise2.resolve' ); resolve( 2 ) } );
  }

  function reject1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.reject' ); reject( err1 ) } );
  }
}

//

function andKeepWithMixedCompetitors( test )
{
  let context = this;
  let t = context.t1;
  let track;
  let ready = new _.Consequence().take( null );
  let err1, err2;

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'none of async competitors';
    track = [];
    let con = new _.Consequence().take( 4 );
    con.andKeep([ 'str', null, 1 ]);

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 'str', null, 1, 4 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 'str', null, 1, 4 ] } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t, () =>
    {
      var exp = [ 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 'str', null, 1, 4 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'none of async competitors and error';
    track = [];
    err1 = _.errAttend( 'err' );
    let con = new _.Consequence().take( 3 );
    con.andKeep([ [], {}, 'str', err1 ]);

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ [], {}, 'str', err1, 3 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ [], {}, 'str', err1, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t, () =>
    {
      var exp = [ 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ [], {}, 'str', err1, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise, routine, string, consequence';
    track = [];
    let promise = new Promise( resolve1 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = new _.Consequence().take( 4 );
    con.andKeep([ promise, routineReturnsConsequence, 'str', con1 ]);

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, null, 'str', 3, 4 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, null, 'str', 3, 4 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.take' );
      con1.take( 3 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'routine.con', 'promise1.resolve', 'con1.take', 'con1.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, null, 'str', 3, 4 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'routine, string, consequence, promise, null';
    track = [];
    let promise = new Promise( resolve1 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = new _.Consequence().take( 4 );
    con.andKeep([ routineReturnsConsequence, 'str', con1, promise, null ]);

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ null, 'str', 3, 1, null, 4 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ null, 'str', 3, 1, null, 4 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.take' );
      con1.take( 3 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'routine.con', 'promise1.resolve', 'con1.take', 'con1.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ null, 'str', 3, 1, null, 4 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'routine, string, consequence, promise, null, consequence - error';
    track = [];
    err1 = _.errAttend( 'err' );
    let promise = new Promise( resolve1 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = new _.Consequence().take( 3 );
    con.andKeep([ routineReturnsConsequence, 'str', con1, promise, null ]);

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.error' );
      con1.error( err1 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'routine.con', 'promise1.resolve', 'con1.error', 'con1.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'competitor - undefined, should throw error';
    return test.shouldThrowErrorOfAnyKind( () =>
    {
      new _.Consequence().take( 3 );
      con.andKeep([ routineReturnsConsequence, 'str', con1, promise, null ]);
    });
  });

  /* */

  return ready;

  /* */

  function routineReturnsConsequence()
  {
    track.push( 'routine.con' );
    return _.take( null );
  }

  function resolve1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.resolve' ); resolve( 1 ) } );
  }

  function reject1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.reject' ); reject( err1 ) } );
  }
}

//

function andKeepWithSeveralIdenticalCompetitors( test )
{
  let context = this;
  let t = context.t1;
  let track;
  let ready = new _.Consequence().take( null );
  let err1, err2;

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'few identical consequences in queue';
    track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = new _.Consequence().take( 3 );
    con.andKeep([ con1, con2, con1, con2 ]);

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( got, 1 );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    con2.tap( ( err, got ) =>
    {
      track.push( 'con2.tap' );
      test.identical( got, 2 );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, 2, 1, 2, 3 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.take' );
      con1.take( 1 );
    });

    _.time.out( t + t, () =>
    {
      track.push( 'con2.take' );
      con2.take( 2 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'con1.take', 'con2.take', 'con1.tap', 'con2.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'few identical promises in queue';
    track = [];
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( resolve2 );
    let con = new _.Consequence().take( 3 );
    con.andKeep([ promise2, promise1, promise1, promise2 ]);

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 2, 1, 1, 2, 3 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 2, 1, 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.resolve', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 2, 1, 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  return ready;

  /* */

  function resolve1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.resolve' ); resolve( 1 ) } );
  }

  function resolve2( resolve, reject )
  {
    return _.time.out( t + t, () => { track.push( 'promise2.resolve' ); resolve( 2 ) } );
  }
}

//

function andKeepAccumulative( test )
{
  let context = this;
  let ready = new _.Consequence();
  let thenArg;
  let track = [];

  ready.andKeepAccumulative( () =>
  {
    return _.time.out( context.t1*10, () =>
    {
      track.push( 'a' );
      return 'a'
    });
  });

  ready.andKeepAccumulative( () =>
  {
    return _.time.out( context.t1/10, () =>
    {
      track.push( 'b' );
      return 'b'
    });
  });

  ready.andKeepAccumulative( () =>
  {
    return _.time.out( context.t1*5, () =>
    {
      track.push( 'context' );
      return 'context'
    });
  });

  ready.then( ( arg ) =>
  {
    track.push( '1' );
    thenArg = arg;
    return 1;
  });

  ready.take( 0 );
  track.push( '0' );

  return _.time.out( context.t1*20, () =>
  {
    test.identical( thenArg, [ 'context', 'b', 'a', 0 ] );
    test.identical( track, [ '0', 'a', 'b', 'context', '1' ] );
  });
}

//

function andKeepAccumulativeNonConsequence( test )
{
  let context = this;
  let ready = new _.Consequence();
  let thenArg;
  let track = [];

  ready.andKeepAccumulative( () =>
  {
    track.push( 1 );
    return 1;
  });

  ready.andKeepAccumulative( () =>
  {
    track.push( null );
    return null;
  });

  ready.andKeepAccumulative( () =>
  {
    track.push( 2 );
    return 2;
  });

  ready.andKeepAccumulative( () =>
  {
    return _.time.out( context.t1, () =>
    {
      track.push( 3 );
      return 3;
    });
  });

  ready.then( ( arg ) =>
  {
    thenArg = arg;
    return null;
  });

  ready.take( 10 );
  track.push( 10 );

  return _.time.out( context.t1*20, () =>
  {
    test.identical( thenArg, [ 3, 2, null, 1, 10 ] );
    test.identical( track, [ 1, 10, null, 2, 3 ] );
  });
}

//

function andImmediate( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )

  /* */

  .then( ( arg ) =>
  {
    test.case = 'take take';
    let t = context.t1;
    let track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = _.Consequence().take( 3 );
    con.andImmediate([ con1, con2 ]);

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, 2, 3 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.take' );
      con1.take( 1 );
    });
    _.time.out( t + t/2, () =>
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.take' );
      con2.take( 2 )
    });
    _.time.out( t * 2 + t/2, () =>
    {
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'con1.take', 'con1.tap', 'con2.take', 'con2.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  })

  /* */

  .then( ( arg ) =>
  {
    test.case = 'error take';
    let t = context.t1;
    let track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = _.Consequence().take( 3 );
    con.andImmediate([ con1, con2 ]);
    let err1 = _.errAttend( 'Error1' );

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.error' );
      con1.error( err1 );
    });
    _.time.out( t + t/2, () =>
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.take' );
      con2.take( 2 )
    });
    _.time.out( t * 2 + t/2, () =>
    {
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'con1.error', 'con1.tap', 'con2.take', 'con2.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  })

  /* */

  .then( ( arg ) =>
  {
    test.case = 'take error';
    let t = context.t1;
    let track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = _.Consequence().take( 3 );
    con.andImmediate([ con1, con2 ]);
    let err1 = _.errAttend( 'Error1' );

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.take' );
      con1.take( 1 );
    });
    _.time.out( t + t/2, () =>
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.error' );
      con2.error( err1 )
    });
    _.time.out( t * 2 + t/2, () =>
    {
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'con1.take', 'con1.tap', 'con2.error', 'con2.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  })

  /* */

  return ready;
}

//

function andImmediateWithPromise( test )
{
  let context = this;
  let t = context.t1;
  let track;
  let ready = new _.Consequence().take( null );
  let err1, err2;

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - resolved, promise2 - resolved';
    track = [];
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( resolve2 );
    let con = new _.Consequence().take( 3 );
    con.andImmediate([ promise1, promise2 ]);

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, 2, 3 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.resolve', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - rejected, promise2 - resolved';
    track = [];
    err1 = _.errAttend( 'reject1' );
    let promise1 = new Promise( reject1 );
    let promise2 = new Promise( resolve2 );
    let con = new _.Consequence().take( 3 );
    con.andImmediate([ promise1, promise2 ]);

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.reject', 'promise2.resolve', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - resolved, promise2 - rejected';
    track = [];
    err2 = _.errAttend( 'reject2' );
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( reject2 );
    let con = new _.Consequence().take( 3 );
    con.andImmediate([ promise1, promise2 ]);

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err2 );
      test.identical( con.resourcesGet(), [ { 'error' : err2, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.reject', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err2, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - rejected, promise2 - rejected';
    track = [];
    err1 = _.errAttend( 'reject1' );
    err2 = _.errAttend( 'reject2' );
    let promise1 = new Promise( reject1 );
    let promise2 = new Promise( reject2 );
    let con = new _.Consequence().take( 3 );
    con.andImmediate([ promise1, promise2 ]);

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.reject', 'promise2.reject', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  return ready;

  /* */

  function resolve1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.resolve' ); resolve( 1 ) } );
  }

  function resolve2( resolve, reject )
  {
    return _.time.out( t + t, () => { track.push( 'promise2.resolve' ); resolve( 2 ) } );
  }

  function reject1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.reject' ); reject( err1 ) } );
  }

  function reject2( resolve, reject )
  {
    return _.time.out( t + t, () => { track.push( 'promise2.reject' ); reject( _.errAttend( err2 ) ) } );
  }
}

//

function andImmediateWithPromiseAndConsequence( test )
{
  let context = this;
  let t = context.t1;
  let track;
  let ready = new _.Consequence().take( null );
  let err1, err2;

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - resolved, promise2 - resolved, con - take';
    track = [];
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( resolve2 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = new _.Consequence().take( 4 );
    con.andImmediate([ promise1, promise2, con1 ]);

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, 2, 3, 4 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 3, 4 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.take' );
      con1.take( 3 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.resolve', 'con1.take', 'con1.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 3, 4 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - rejected, promise2 - resolved, con - take';
    track = [];
    err1 = _.errAttend( 'rejected1' );
    let promise1 = new Promise( reject1 );
    let promise2 = new Promise( resolve2 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = new _.Consequence().take( 3 );
    con.andImmediate([ promise1, promise2, con1 ]);

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.take' );
      con1.take( 3 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.reject', 'promise2.resolve', 'con1.take', 'con1.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - resolved, promise2 - resolved, con - error';
    track = [];
    err1 = _.errAttend( 'err1' );
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( resolve2 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = new _.Consequence().take( 3 );
    con.andImmediate([ promise1, promise2, con1 ]);

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.error' );
      con1.error( err1 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.resolve', 'con1.error', 'con1.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  return ready;

  /* */

  function resolve1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.resolve' ); resolve( 1 ) } );
  }

  function resolve2( resolve, reject )
  {
    return _.time.out( t + t, () => { track.push( 'promise2.resolve' ); resolve( 2 ) } );
  }

  function reject1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.reject' ); reject( err1 ) } );
  }
}

//

function andImmediateWithMixedCompetitors( test )
{
  let context = this;
  let t = context.t1;
  let track;
  let ready = new _.Consequence().take( null );
  let err1, err2;

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'none of async competitors';
    track = [];
    let con = new _.Consequence().take( 3 );
    con.andImmediate([ 'str', null, 1 ]);

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 'str', null, 1, 3 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 'str', null, 1, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t, () =>
    {
      var exp = [ 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 'str', null, 1, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'none of async competitors and error';
    track = [];
    err1 = _.errAttend( 'err' );
    let con = new _.Consequence().take( 3 );
    con.andImmediate([ [], {}, 'str', err1 ]);

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ [], {}, 'str', err1, 3 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ [], {}, 'str', err1, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t, () =>
    {
      var exp = [ 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ [], {}, 'str', err1, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise, routine, string, consequence';
    track = [];
    let promise = new Promise( resolve1 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = new _.Consequence().take( 4 );
    con.andImmediate([ promise, routineReturnsConsequence, 'str', con1 ]);

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, null, 'str', 3, 4 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, null, 'str', 3, 4 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.take' );
      con1.take( 3 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'routine.con', 'promise1.resolve', 'con1.take', 'con1.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, null, 'str', 3, 4 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'routine, string, consequence, promise, null';
    track = [];
    let promise = new Promise( resolve1 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = new _.Consequence().take( 3 );
    con.andImmediate([ routineReturnsConsequence, 'str', con1, promise, null ]);

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ null, 'str', 3, 1, null, 3 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ null, 'str', 3, 1, null, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.take' );
      con1.take( 3 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'routine.con', 'promise1.resolve', 'con1.take', 'con1.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ null, 'str', 3, 1, null, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'routine, string, consequence, promise, null, consequence - error';
    track = [];
    err1 = _.errAttend( 'err' );
    let promise = new Promise( resolve1 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = new _.Consequence().take( 3 );
    con.andImmediate([ routineReturnsConsequence, 'str', con1, promise, null ]);

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.error' );
      con1.error( err1 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'routine.con', 'promise1.resolve', 'con1.error', 'con1.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'competitor - undefined, should throw error';
    return test.shouldThrowErrorOfAnyKind( () =>
    {
      new _.Consequence().take( 3 );
      con.andImmediate([ routineReturnsConsequence, 'str', con1, promise, null ]);
    });
  });

  /* */

  return ready;

  /* */

  function routineReturnsConsequence()
  {
    track.push( 'routine.con' );
    return _.take( null );
  }

  function resolve1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.resolve' ); resolve( 1 ) } );
  }

  function reject1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.reject' ); reject( err1 ) } );
  }
}

//

function andImmediateWithSeveralIdenticalCompetitors( test )
{
  let context = this;
  let t = context.t1;
  let track;
  let ready = new _.Consequence().take( null );
  let err1, err2;

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'few identical consequences in queue';
    track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = new _.Consequence().take( 3 );
    con.andImmediate([ con1, con2, con1, con2 ]);

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( got, 1 );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });

    con2.tap( ( err, got ) =>
    {
      track.push( 'con2.tap' );
      test.identical( got, 2 );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, 2, 1, 2, 3 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.take' );
      con1.take( 1 );
    });

    _.time.out( t + t, () =>
    {
      track.push( 'con2.take' );
      con2.take( 2 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'con1.take', 'con1.tap', 'con2.take', 'con2.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'few identical promises in queue';
    track = [];
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( resolve2 );
    let con = new _.Consequence().take( 3 );
    con.andImmediate([ promise2, promise1, promise1, promise2 ]);

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 2, 1, 1, 2, 3 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 2, 1, 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.resolve', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 2, 1, 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  return ready;

  /* */

  function resolve1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.resolve' ); resolve( 1 ) } );
  }

  function resolve2( resolve, reject )
  {
    return _.time.out( t + t, () => { track.push( 'promise2.resolve' ); resolve( 2 ) } );
  }
}

//

function alsoKeepTrivialSyncBefore( test )
{
  let context = this;
  let ready = new _.Consequence();
  let thenArg;
  let track = [];

  track.push( '0' );
  ready.take( 0 );
  track.push( '2' );

  ready.alsoKeep( () =>
  {
    track.push( 'x' );
    return 'x';
  });

  ready.then( ( arg ) =>
  {
    track.push( '1' );
    thenArg = arg;
    return 1;
  });

  return _.time.out( context.t1*5, () =>
  {
    test.identical( thenArg, [ 0, 'x' ] );
    test.identical( track, [ '0', '2', 'x', '1' ] );
  });
}

//

function alsoKeepTrivialSyncAfter( test )
{
  let context = this;
  let ready = new _.Consequence();
  let thenArg;
  let track = [];

  ready.alsoKeep( () =>
  {
    track.push( 'x' );
    return 'x';
  });

  ready.then( ( arg ) =>
  {
    track.push( '1' );
    thenArg = arg;
    return 1;
  });

  track.push( '0' );
  ready.take( 0 );
  track.push( '2' );

  return _.time.out( context.t1*5, () =>
  {
    test.identical( thenArg, [ 0, 'x' ] );
    test.identical( track, [ 'x', '0', '1', '2' ] );
  });
}

//

function alsoKeepTrivialAsync( test )
{
  let context = this;
  let ready = new _.Consequence();
  let thenArg;
  let track = [];

  ready.alsoKeep( () =>
  {
    return _.time.out( context.t1, () =>
    {
      track.push( 'x' );
      return 'x'
    });
  });

  ready.then( ( arg ) =>
  {
    track.push( '1' );
    thenArg = arg;
    return 1;
  });

  track.push( '0' );
  ready.take( 0 );
  track.push( '2' );

  return _.time.out( context.t1*5, () =>
  {
    test.identical( thenArg, [ 0, 'x' ] );
    test.identical( track, [ '0', '2', 'x', '1' ] );
  });
}

//

function alsoKeep( test )
{
  let context = this;
  let ready = new _.Consequence();
  let thenArg;
  let track = [];

  ready.alsoKeep( () =>
  {
    return _.time.out( context.t1*10, () =>
    {
      track.push( 'a' );
      return 'a'
    });
  });

  ready.alsoKeep( () =>
  {
    return _.time.out( context.t1/10, () =>
    {
      track.push( 'b' );
      return 'b'
    });
  });

  ready.alsoKeep( () =>
  {
    return _.time.out( context.t1*5, () =>
    {
      track.push( 'context' );
      return 'context'
    });
  });

  ready.alsoKeep( () =>
  {
    track.push( 'd' );
    return 'd'
  });

  ready.then( ( arg ) =>
  {
    track.push( '1' );
    thenArg = arg;
    return 1;
  });

  track.push( '0' );
  ready.take( 0 );
  track.push( '2' );

  return _.time.out( context.t1*20, () =>
  {
    test.identical( thenArg, [ 0, 'a', 'b', 'context', 'd' ] );
    test.identical( track, [ 'd', '0', '2', 'b', 'context', 'a', '1' ] );
  });
}

//

function alsoKeepExtended( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )

  /* */

  .then( ( arg ) =>
  {
    test.case = 'take take';
    let t = context.t1;
    let track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = new _.Consequence().take( 3 );
    con.alsoKeep([ con1, con2 ]);

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 3, 1, 2 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 3, 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.take' );
      con1.take( 1 );
    });
    _.time.out( t + t/2, () =>
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.take' );
      con2.take( 2 )
    });
    _.time.out( t * 2 + t/2, () =>
    {
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 3, 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'con1.take', 'con2.take', 'con1.tap', 'con2.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 3, 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  })

  /* */

  .then( ( arg ) =>
  {
    test.case = 'error take';
    let t = context.t1;
    let track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = new _.Consequence().take( 3 );
    con.alsoKeep([ con1, con2 ]);
    let err1 = _.errAttend( 'Error1' );

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.error' );
      con1.error( err1 );
    });
    _.time.out( t + t/2, () =>
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.take' );
      con2.take( 2 )
    });
    _.time.out( t * 2 + t/2, () =>
    {
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'con1.error', 'con2.take', 'con1.tap', 'con2.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  })

  /* */

  .then( ( arg ) =>
  {
    test.case = 'take error';
    let t = context.t1;
    let track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = _.Consequence().take( 3 );
    con.alsoKeep([ con1, con2 ]);
    let err1 = _.errAttend( 'Error1' );

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.take' );
      con1.take( 1 );
    });
    _.time.out( t + t/2, () =>
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.error' );
      con2.error( err1 )
    });
    _.time.out( t * 2 + t/2, () =>
    {
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'con1.take', 'con2.error', 'con1.tap', 'con2.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  })

  /* */

  return ready;
}

//

function alsoKeepThrowingBeforeSync( test )
{
  let context = this;
  let ready = new _.Consequence();
  let thenArg;
  let track = [];

  ready.alsoKeep( () =>
  {
    track.push( 'error1' );
    throw _.errAttend( 'error1' );
  });

  ready.alsoKeep( () =>
  {
    track.push( 'd' );
    return 'd'
  });

  ready.finally( ( err, arg ) =>
  {
    track.push( '1' );
    thenArg = err ? err : arg;
    return 1;
  });

  track.push( '0' );
  ready.take( 0 );
  track.push( '2' );

  return _.time.out( context.t1*5, () =>
  {
    test.true( _.errIs( thenArg ) );
    test.identical( track, [ 'error1', 'd', '0', '1', '2' ] );
  });
}

//

function alsoKeepThrowingAfterSync( test )
{
  let context = this;
  let ready = new _.Consequence();
  let thenArg;
  let track = [];

  ready.alsoKeep( () =>
  {
    track.push( 'd' );
    return 'd'
  });

  ready.alsoKeep( () =>
  {
    track.push( 'error1' );
    throw _.errAttend( 'error1' );
  });

  ready.finally( ( err, arg ) =>
  {
    track.push( '1' );
    thenArg = err ? err : arg;
    return 1;
  });

  track.push( '0' );
  ready.take( 0 );
  track.push( '2' );

  return _.time.out( context.t1*5, () =>
  {
    test.true( _.errIs( thenArg ) );
    test.identical( track, [ 'd', 'error1', '0', '1', '2' ] );
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
    let track = [];

    ready[ methodName ]( () =>
    {
      if( syncThrowing )
      {
        track.push( 'error1' );
        throw _.errAttend( 'error1' );
      }
      else
      return _.time.out( context.t1*2, () =>
      {
        track.push( 'error1' );
        throw _.errAttend( 'error1' );
      });
    });

    ready[ methodName ]( () =>
    {
      return _.time.out( context.t1*10, () =>
      {
        track.push( 'a' );
        return 'a'
      });
    });

    let b = _.time.out( context.t1/10, () =>
    {
      track.push( 'b' );
      return 'b'
    });
    ready[ methodName ]( () => b );

    ready[ methodName ]( () =>
    {
      return _.time.out( context.t1*5, () =>
      {
        track.push( 'context' );
        return 'context'
      });
    });

    ready[ methodName ]( () =>
    {
      track.push( 'd' );
      return 'd'
    });

    ready.finally( ( err, arg ) =>
    {
      track.push( '1' );
      thenArg = err ? err : arg;
      return 1;
    });

    track.push( '0' );
    ready.take( 0 );
    track.push( '2' );

    return _.time.out( context.t1*20, () =>
    {
      test.true( _.errIs( thenArg ) );
      if( syncThrowing )
      test.identical( track, [ 'error1', 'd', '0', '2', 'b', 'context', 'a', '1' ] );
      else
      test.identical( track, [ 'd', '0', '2', 'b', 'error1', 'context', 'a', '1' ] );
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
    let track = [];

    ready[ methodName ]( () =>
    {
      return _.time.out( context.t1*5, () =>
      {
        track.push( 'a' );
        return 'a'
      });
    });

    let b = _.time.out( context.t1/20, () =>
    {
      track.push( 'b' );
      return 'b'
    });
    ready[ methodName ]( () => b );

    ready[ methodName ]( () =>
    {
      return _.time.out( context.t1*5/2, () =>
      {
        track.push( 'context' );
        return 'context'
      });
    });

    ready[ methodName ]( () =>
    {
      track.push( 'd' );
      return 'd'
    });

    ready[ methodName ]( () =>
    {
      if( syncThrowing )
      {
        track.push( 'error1' );
        throw _.errAttend( 'error1' );
      }
      else
      return _.time.out( context.t1, () =>
      {
        track.push( 'error1' );
        throw _.errAttend( 'error1' );
      });
    });

    ready.finally( ( err, arg ) =>
    {
      track.push( '1' );
      thenArg = err ? err : arg;
      return 1;
    });

    track.push( '0' );
    ready.take( 0 );
    track.push( '2' );

    return _.time.out( context.t1*10, () =>
    {
      test.true( _.errIs( thenArg ) );
      if( syncThrowing )
      test.identical( track, [ 'd', 'error1', '0', '2', 'b', 'context', 'a', '1' ] );
      else
      test.identical( track, [ 'd', '0', '2', 'b', 'error1', 'context', 'a', '1' ] );
      test.identical( b.resourcesCount(), methodName === 'alsoKeep' ? 1 : 0 );
      test.identical( b.errorsCount(), 0 );
    });

  }

}

//

function alsoImmediate( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )

  /* */

  .then( ( arg ) =>
  {
    test.case = 'take take';
    let t = context.t1;
    let track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = _.Consequence().take( 3 );
    con.alsoImmediate([ con1, con2 ]);

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 3, 1, 2 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 3, 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.take' );
      con1.take( 1 );
    });
    _.time.out( t + t/2, () =>
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.take' );
      con2.take( 2 )
    });
    _.time.out( t * 2 + t/2, () =>
    {
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 3, 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'con1.take', 'con1.tap', 'con2.take', 'con2.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 3, 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  })

  /* */

  .then( ( arg ) =>
  {
    test.case = 'error take';
    let t = context.t1;
    let track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = _.Consequence().take( 3 );
    con.alsoImmediate([ con1, con2 ]);
    let err1 = _.errAttend( 'Error1' );

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.error' );
      con1.error( err1 );
    });
    _.time.out( t + t/2, () =>
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.take' );
      con2.take( 2 )
    });
    _.time.out( t * 2 + t/2, () =>
    {
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'con1.error', 'con1.tap', 'con2.take', 'con2.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  })

  /* */

  .then( ( arg ) =>
  {
    test.case = 'take error';
    let t = context.t1;
    let track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = _.Consequence().take( 3 );
    con.alsoImmediate([ con1, con2 ]);
    let err1 = _.errAttend( 'Error1' );

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.take' );
      con1.take( 1 );
    });
    _.time.out( t + t/2, () =>
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.error' );
      con2.error( err1 )
    });
    _.time.out( t * 2 + t/2, () =>
    {
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'con1.take', 'con1.tap', 'con2.error', 'con2.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  })

  /* */

  return ready;
}

// --
// And
// --

function _and( test )
{
  let context = this;

  let delay = context.t1*5;
  let ready = new _.Consequence().take( null )

  /* common wConsequence corespondent tests. */

  .then( function( arg )
  {
    test.case = 'give back resources to src consequences';

    var mainCon = new _.Consequence({ tag : 'mainCon' });
    var con1 = new _.Consequence({ tag : 'con1' });
    var con2 = new _.Consequence({ tag : 'con2' });

    mainCon.take( 'str' );

    mainCon._and
    ({
      competitors : [ con1, con2 ],
      keeping : true,
      accumulative : false,
      waitingResource : true,
      waitingOthers : true,
      stack : 1,
    });

    con1.give( ( err, got ) =>
    {
      test.identical( got, delay );
      test.identical( err, undefined );
      return null;
    });
    con2.give( ( err, got ) =>
    {
      test.identical( got, delay * 2 );
      test.identical( err, undefined );
      return null;
    });

    mainCon.finally( function( err, got )
    {
      test.description = `at that moment all resources from srcs are processed`;
      test.identical( con1.resourcesCount(), 0 );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesCount(), 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      test.identical( got, [ delay, delay * 2, 'str' ] );
      test.identical( err, undefined );
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

    mainCon.take( 'str' );

    mainCon._and
    ({
      competitors : [ con1, con2 ],
      keeping : false,
      accumulative : false,
      waitingResource : true,
      waitingOthers : true,
      stack : 1,
    });

    con1.give( ( err, got ) =>
    {
      test.identical( 0, 1 );
      test.identical( err, undefined );
      return null;
    });
    con2.give( ( err, got ) =>
    {
      test.identical( 0, 1 );
      test.identical( err, undefined );
      return null;
    });

    mainCon.finally( function( err, got )
    {
      /* no resources returned back to srcs, their competitors must not be invoked */
      test.identical( con1.resourcesCount(), 0 );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesCount(), 0 );
      test.identical( con2.competitorsEarlyGet().length, 1 );
      test.identical( got, [ delay, delay * 2, 'str' ] );
      test.identical( err, undefined );
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

function AndTake( test )
{
  let context = this;
  let track;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    test.case = 'take take';
    let t = context.t1;
    track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = _.Consequence.AndTake( con1, con2 );

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( function( err, got )
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, 2 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.take' );
      con1.take( 1 );
    });
    _.time.out( t + t/2, () =>
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.take' );
      con2.take( 2 )
    });
    _.time.out( t * 2 + t/2, () =>
    {
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    return _.time.out( t * 4, function()
    {
      var exp = [ 'con1.take', 'con2.take', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
      con1.cancel();
      con2.cancel();
      return null;
    });

  })

  /* */

  .then( function( arg )
  {
    test.case = 'error take';
    let t = context.t1;
    track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = _.Consequence.AndTake( con1, con2 );
    let err1 = _.err( 'Error1' );

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    con.tap( function( err, got )
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
      test.true( !_.error.isAttended( err ) );
      test.true( _.error.isWary( err ) );
      test.true( !_.error.isSuspended( err ) );
      _.errAttend( err );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.error' );
      con1.error( err1 );
    });
    _.time.out( t + t/2, () =>
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.take' );
      con2.take( 2 )
    });
    _.time.out( t * 2 + t/2, () =>
    {
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    return _.time.out( t * 4, function()
    {
      var exp = [ 'con1.error', 'con2.take', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
      con1.cancel();
      con2.cancel();
      return null;
    });

  })

  /* */

  .then( function( arg )
  {
    test.case = 'take error';
    let t = context.t1;
    track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = _.Consequence.AndTake( con1, con2 );
    let err1 = _.err( 'Error1' );

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    con.tap( function( err, got )
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
      test.true( !_.error.isAttended( err ) );
      test.true( _.error.isWary( err ) );
      test.true( !_.error.isSuspended( err ) );
      _.errAttend( err );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.take' );
      con1.take( 1 );
    });
    _.time.out( t + t/2, () =>
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.error' );
      con2.error( err1 )
    });
    _.time.out( t * 2 + t/2, () =>
    {
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    return _.time.out( t * 4, function()
    {
      var exp = [ 'con1.take', 'con2.error', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
      con1.cancel();
      con2.cancel();
      return null;
    });

  })

  /* */

  return ready;

}

//

function AndTakeWithPromise( test )
{
  let context = this;
  let t = context.t1;
  let track;
  let ready = new _.Consequence().take( null );
  let err1, err2;

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - resolved, promise2 - resolved';
    track = [];
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( resolve2 );
    let con = _.Consequence.AndTake( promise1, promise2 );

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, 2 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.resolve', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - rejected, promise2 - resolved';
    track = [];
    err1 = _.errAttend( 'reject1' );
    let promise1 = new Promise( reject1 );
    let promise2 = new Promise( resolve2 );
    let con = _.Consequence.AndTake( promise1, promise2 );

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.reject', 'promise2.resolve', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - resolved, promise2 - rejected';
    track = [];
    err2 = _.errAttend( 'reject2' );
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( reject2 );
    let con = _.Consequence.AndTake( promise1, promise2 );

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err2 );
      test.identical( con.resourcesGet(), [ { 'error' : err2, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.reject', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err2, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - rejected, promise2 - rejected';
    track = [];
    err1 = _.errAttend( 'reject1' );
    err2 = _.errAttend( 'reject2' );
    let promise1 = new Promise( reject1 );
    let promise2 = new Promise( reject2 );
    let con = _.Consequence.AndTake( promise1, promise2 );

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.reject', 'promise2.reject', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  return ready;

  /* */

  function resolve1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.resolve' ); resolve( 1 ) } );
  }

  function resolve2( resolve, reject )
  {
    return _.time.out( t + t, () => { track.push( 'promise2.resolve' ); resolve( 2 ) } );
  }

  function reject1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.reject' ); reject( err1 ) } );
  }

  function reject2( resolve, reject )
  {
    return _.time.out( t + t, () => { track.push( 'promise2.reject' ); reject( _.errAttend( err2 ) ) } );
  }
}

//

function AndTakeWithPromiseAndConsequence( test )
{
  let context = this;
  let t = context.t1;
  let track;
  let ready = new _.Consequence().take( null );
  let err1, err2;

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - resolved, promise2 - resolved, con - take';
    track = [];
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( resolve2 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = _.Consequence.AndTake( promise1, promise2, con1 );

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, 2, 3 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.take' );
      con1.take( 3 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.resolve', 'con1.take', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );

      con1.cancel();
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - rejected, promise2 - resolved, con - take';
    track = [];
    err1 = _.errAttend( 'rejected1' );
    let promise1 = new Promise( reject1 );
    let promise2 = new Promise( resolve2 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = _.Consequence.AndTake( promise1, promise2, con1 );

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.take' );
      con1.take( 3 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.reject', 'promise2.resolve', 'con1.take', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );

      con1.cancel();
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - resolved, promise2 - resolved, con - error';
    track = [];
    err1 = _.errAttend( 'err1' );
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( resolve2 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = _.Consequence.AndTake( promise1, promise2, con1 );

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.error' );
      con1.error( err1 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.resolve', 'con1.error', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );

      con1.cancel();
      return null;
    });
  });

  /* */

  return ready;

  /* */

  function resolve1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.resolve' ); resolve( 1 ) } );
  }

  function resolve2( resolve, reject )
  {
    return _.time.out( t + t, () => { track.push( 'promise2.resolve' ); resolve( 2 ) } );
  }

  function reject1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.reject' ); reject( err1 ) } );
  }
}

//

function AndTakeWithMixedCompetitors( test )
{
  let context = this;
  let t = context.t1;
  let track;
  let ready = new _.Consequence().take( null );
  let err1, err2;

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'none of async competitors';
    track = [];
    let con = _.Consequence.AndTake( 'str', null, 1 );

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 'str', null, 1 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 'str', null, 1 ] } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t, () =>
    {
      var exp = [ 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 'str', null, 1 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'none of async competitors and error';
    track = [];
    err1 = _.errAttend( 'err' );
    let con = _.Consequence.AndTake( [], {}, 'str', err1 );

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ [], {}, 'str', err1 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ [], {}, 'str', err1 ] } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t, () =>
    {
      var exp = [ 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ [], {}, 'str', err1 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise, routine, string, consequence';
    track = [];
    let promise = new Promise( resolve1 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = _.Consequence.AndTake( promise, routineReturnsConsequence, 'str', con1 );

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, null, 'str', 3 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, null, 'str', 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.take' );
      con1.take( 3 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'routine.con', 'promise1.resolve', 'con1.take', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, null, 'str', 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );

      con1.cancel();
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'routine, string, consequence, promise, null';
    track = [];
    let promise = new Promise( resolve1 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = _.Consequence.AndTake( routineReturnsConsequence, 'str', con1, promise, null );

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ null, 'str', 3, 1, null ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ null, 'str', 3, 1, null ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.take' );
      con1.take( 3 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'routine.con', 'promise1.resolve', 'con1.take', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ null, 'str', 3, 1, null ] } ] );
      test.identical( con.competitorsCount(), 0 );

      con1.cancel();
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'routine, string, consequence, promise, null, consequence - error';
    track = [];
    err1 = _.errAttend( 'err' );
    let promise = new Promise( resolve1 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = _.Consequence.AndTake( routineReturnsConsequence, 'str', con1, promise, null );

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.error' );
      con1.error( err1 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'routine.con', 'promise1.resolve', 'con1.error', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );

      con1.cancel();
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'competitor - undefined, should throw error';
    return test.shouldThrowErrorOfAnyKind( () =>
    {
      _.Consequence.AndTake( routineReturnsConsequence, 'str', con1, promise, null );
    });
  });

  /* */

  return ready;

  /* */

  function routineReturnsConsequence()
  {
    track.push( 'routine.con' );
    return _.take( null );
  }

  function resolve1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.resolve' ); resolve( 1 ) } );
  }

  function reject1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.reject' ); reject( err1 ) } );
  }
}

//

function AndTakeWithSeveralIdenticalCompetitors( test )
{
  let context = this;
  let t = context.t1;
  let track;
  let ready = new _.Consequence().take( null );
  let err1, err2;

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'few identical consequences in queue';
    track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = _.Consequence.AndTake( con1, con2, con1, con2 );

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( got, 1 );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    con2.tap( ( err, got ) =>
    {
      track.push( 'con2.tap' );
      test.identical( got, 2 );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, 2, 1, 2 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.take' );
      con1.take( 1 );
    });

    _.time.out( t + t, () =>
    {
      track.push( 'con2.take' );
      con2.take( 2 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'con1.take', 'con2.take', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );

      con1.cancel();
      con2.cancel();
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'few identical promises in queue';
    track = [];
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( resolve2 );
    let con = _.Consequence.AndTake( promise2, promise1, promise1, promise2 );

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 2, 1, 1, 2 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 2, 1, 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.resolve', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 2, 1, 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  return ready;

  /* */

  function resolve1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.resolve' ); resolve( 1 ) } );
  }

  function resolve2( resolve, reject )
  {
    return _.time.out( t + t, () => { track.push( 'promise2.resolve' ); resolve( 2 ) } );
  }
}

//

function AndKeep( test )
{
  let context = this;
  let track;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    test.case = 'take take';
    let t = context.t1*2;
    track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = _.Consequence.AndKeep( con1, con2 );

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( function( err, got )
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, 2 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.take' );
      con1.take( 1 );
    });
    _.time.out( t + t/2, () =>
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.take' );
      con2.take( 2 )
    });
    _.time.out( t * 2 + t/2, () =>
    {
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    return _.time.out( t * 4, function()
    {
      var exp = [ 'con1.take', 'con2.take', 'con1.tap', 'con2.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  })

  /* */

  .then( function( arg )
  {
    test.case = 'error take';
    let t = context.t1*2;
    track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = _.Consequence.AndKeep( con1, con2 );
    let err1 = _.err( 'Error1' );

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( function( err, got )
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      test.true( !_.error.isAttended( err ) );
      test.true( _.error.isWary( err ) );
      test.true( !_.error.isSuspended( err ) );
      _.errAttend( err );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.error' );
      con1.error( err1 );
    });
    _.time.out( t + t/2, () =>
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.take' );
      con2.take( 2 )
    });
    _.time.out( t * 2 + t/2, () =>
    {
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    return _.time.out( t * 4, function()
    {
      var exp = [ 'con1.error', 'con2.take', 'con1.tap', 'con2.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  })

  /* */

  .then( function( arg )
  {
    test.case = 'take error';
    let t = context.t1*2;
    track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = _.Consequence.AndKeep( con1, con2 );
    let err1 = _.err( 'Error1' );

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( function( err, got )
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      test.true( !_.error.isAttended( err ) );
      test.true( _.error.isWary( err ) );
      test.true( !_.error.isSuspended( err ) );
      _.errAttend( err );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.take' );
      con1.take( 1 );
    });
    _.time.out( t + t/2, () =>
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.error' );
      con2.error( err1 )
    });
    _.time.out( t * 2 + t/2, () =>
    {
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    return _.time.out( t * 4, function()
    {
      var exp = [ 'con1.take', 'con2.error', 'con1.tap', 'con2.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  })

  /* */

  return ready;
}

//

function And( test )
{
  let context = this;
  let track;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    test.case = 'take take';
    let t = context.t1*2;
    track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = _.Consequence.And( con1, con2 );

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( function( err, got )
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, 2 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.take' );
      con1.take( 1 );
    });
    _.time.out( t + t/2, () =>
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.take' );
      con2.take( 2 )
    });
    _.time.out( t * 2 + t/2, () =>
    {
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    return _.time.out( t * 4, function()
    {
      var exp = [ 'con1.take', 'con2.take', 'con1.tap', 'con2.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  })

  /* */

  .then( function( arg )
  {
    test.case = 'error take';
    let t = context.t1*2;
    track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = _.Consequence.And( con1, con2 );
    let err1 = _.err( 'Error1' );

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( function( err, got )
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      test.true( !_.error.isAttended( err ) );
      test.true( _.error.isWary( err ) );
      test.true( !_.error.isSuspended( err ) );
      _.errAttend( err );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.error' );
      con1.error( err1 );
    });
    _.time.out( t + t/2, () =>
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.take' );
      con2.take( 2 )
    });
    _.time.out( t * 2 + t/2, () =>
    {
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    return _.time.out( t * 4, function()
    {
      var exp = [ 'con1.error', 'con2.take', 'con1.tap', 'con2.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  })

  /* */

  .then( function( arg )
  {
    test.case = 'take error';
    let t = context.t1*2;
    track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = _.Consequence.And( con1, con2 );
    let err1 = _.err( 'Error1' );

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( function( err, got )
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      test.true( !_.error.isAttended( err ) );
      test.true( _.error.isWary( err ) );
      test.true( !_.error.isSuspended( err ) );
      _.errAttend( err );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.take' );
      con1.take( 1 );
    });
    _.time.out( t + t/2, () =>
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [] );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.error' );
      con2.error( err1 )
    });
    _.time.out( t * 2 + t/2, () =>
    {
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    return _.time.out( t * 4, function()
    {
      var exp = [ 'con1.take', 'con2.error', 'con1.tap', 'con2.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  })

  /* */

  return ready;
}

//

function AndWithPromise( test )
{
  let context = this;
  let t = context.t1;
  let track;
  let ready = new _.Consequence().take( null );
  let err1, err2;

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - resolved, promise2 - resolved';
    track = [];
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( resolve2 );
    let con = _.Consequence.And( promise1, promise2 );

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, 2 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.resolve', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - rejected, promise2 - resolved';
    track = [];
    err1 = _.errAttend( 'reject1' );
    let promise1 = new Promise( reject1 );
    let promise2 = new Promise( resolve2 );
    let con = _.Consequence.And( promise1, promise2 );

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.reject', 'promise2.resolve', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - resolved, promise2 - rejected';
    track = [];
    err2 = _.errAttend( 'reject2' );
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( reject2 );
    let con = _.Consequence.And( promise1, promise2 );

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err2 );
      test.identical( con.resourcesGet(), [ { 'error' : err2, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.reject', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err2, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - rejected, promise2 - rejected';
    track = [];
    err1 = _.errAttend( 'reject1' );
    err2 = _.errAttend( 'reject2' );
    let promise1 = new Promise( reject1 );
    let promise2 = new Promise( reject2 );
    let con = _.Consequence.And( promise1, promise2 );

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.reject', 'promise2.reject', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  return ready;

  /* */

  function resolve1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.resolve' ); resolve( 1 ) } );
  }

  function resolve2( resolve, reject )
  {
    return _.time.out( t + t, () => { track.push( 'promise2.resolve' ); resolve( 2 ) } );
  }

  function reject1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.reject' ); reject( err1 ) } );
  }

  function reject2( resolve, reject )
  {
    return _.time.out( t + t, () => { track.push( 'promise2.reject' ); reject( _.errAttend( err2 ) ) } );
  }
}

//

function AndWithPromiseAndConsequence( test )
{
  let context = this;
  let t = context.t1;
  let track;
  let ready = new _.Consequence().take( null );
  let err1, err2;

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - resolved, promise2 - resolved, con - take';
    track = [];
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( resolve2 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = _.Consequence.And( promise1, promise2, con1 );

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, 2, 3 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.take' );
      con1.take( 3 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.resolve', 'con1.take', 'con1.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - rejected, promise2 - resolved, con - take';
    track = [];
    err1 = _.errAttend( 'rejected1' );
    let promise1 = new Promise( reject1 );
    let promise2 = new Promise( resolve2 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = _.Consequence.And( promise1, promise2, con1 );

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.take' );
      con1.take( 3 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.reject', 'promise2.resolve', 'con1.take', 'con1.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - resolved, promise2 - resolved, con - error';
    track = [];
    err1 = _.errAttend( 'err1' );
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( resolve2 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = _.Consequence.And( promise1, promise2, con1 );

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.error' );
      con1.error( err1 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.resolve', 'con1.error', 'con1.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  return ready;

  /* */

  function resolve1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.resolve' ); resolve( 1 ) } );
  }

  function resolve2( resolve, reject )
  {
    return _.time.out( t + t, () => { track.push( 'promise2.resolve' ); resolve( 2 ) } );
  }

  function reject1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.reject' ); reject( err1 ) } );
  }
}

//

function AndWithMixedCompetitors( test )
{
  let context = this;
  let t = context.t1;
  let track;
  let ready = new _.Consequence().take( null );
  let err1, err2;

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'none of async competitors';
    track = [];
    let con = _.Consequence.And( 'str', null, 1 );

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 'str', null, 1 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 'str', null, 1 ] } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t, () =>
    {
      var exp = [ 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 'str', null, 1 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'none of async competitors and error';
    track = [];
    err1 = _.errAttend( 'err' );
    let con = _.Consequence.And( [], {}, 'str', err1 );

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ [], {}, 'str', err1 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ [], {}, 'str', err1 ] } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t, () =>
    {
      var exp = [ 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ [], {}, 'str', err1 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise, routine, string, consequence';
    track = [];
    let promise = new Promise( resolve1 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = _.Consequence.And( promise, routineReturnsConsequence, 'str', con1 );

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, null, 'str', 3 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, null, 'str', 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.take' );
      con1.take( 3 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'routine.con', 'promise1.resolve', 'con1.take', 'con1.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, null, 'str', 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'routine, string, consequence, promise, null';
    track = [];
    let promise = new Promise( resolve1 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = _.Consequence.And( routineReturnsConsequence, 'str', con1, promise, null );

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ null, 'str', 3, 1, null ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ null, 'str', 3, 1, null ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.take' );
      con1.take( 3 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'routine.con', 'promise1.resolve', 'con1.take', 'con1.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ null, 'str', 3, 1, null ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'routine, string, consequence, promise, null, consequence - error';
    track = [];
    err1 = _.errAttend( 'err' );
    let promise = new Promise( resolve1 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = _.Consequence.And( routineReturnsConsequence, 'str', con1, promise, null );

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.error' );
      con1.error( err1 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'routine.con', 'promise1.resolve', 'con1.error', 'con1.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'competitor - undefined, should throw error';
    return test.shouldThrowErrorOfAnyKind( () =>
    {
      _.Consequence.And( routineReturnsConsequence, 'str', con1, promise, null );
    });
  });

  /* */

  return ready;

  /* */

  function routineReturnsConsequence()
  {
    track.push( 'routine.con' );
    return _.take( null );
  }

  function resolve1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.resolve' ); resolve( 1 ) } );
  }

  function reject1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.reject' ); reject( err1 ) } );
  }
}

//

function AndWithSeveralIdenticalCompetitors( test )
{
  let context = this;
  let t = context.t1;
  let track;
  let ready = new _.Consequence().take( null );
  let err1, err2;

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'few identical consequences in queue';
    track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = _.Consequence.And( con1, con2, con1, con2 );

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( got, 1 );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 1 );
    });

    con2.tap( ( err, got ) =>
    {
      track.push( 'con2.tap' );
      test.identical( got, 2 );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, 2, 1, 2 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.take' );
      con1.take( 1 );
    });

    _.time.out( t + t, () =>
    {
      track.push( 'con2.take' );
      con2.take( 2 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'con1.take', 'con2.take', 'con1.tap', 'con2.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'few identical promises in queue';
    track = [];
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( resolve2 );
    let con = _.Consequence.And( promise2, promise1, promise1, promise2 );

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 2, 1, 1, 2 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 2, 1, 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.resolve', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 2, 1, 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  return ready;

  /* */

  function resolve1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.resolve' ); resolve( 1 ) } );
  }

  function resolve2( resolve, reject )
  {
    return _.time.out( t + t, () => { track.push( 'promise2.resolve' ); resolve( 2 ) } );
  }
}

//

function AndUncaughtError( test )
{
  let context = this;
  let track;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    test.case = 'error take uncaughtError';
    let t = context.t1;
    track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = _.Consequence.AndImmediate( con1, con2 );
    let err1 = _.err( 'Error1' );

    _.process.on( 'uncaughtError', uncaughtError_functor( 'Error1' ) );

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
    });

    con.tap( function( err, got )
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.true( !_.error.isAttended( err ) );
      test.true( _.error.isWary( err ) );
      test.true( !_.error.isSuspended( err ) );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.error' );
      con1.error( err1 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.take' );
      con2.take( 2 )
    });

    // return _.time.out( t * 8, function()
    return _.time.out( t * 8, function()
    {
      var exp = [ 'con1.error', 'con1.tap', 'con2.take', 'con2.tap', 'con.tap', 'uncaughtError' ];
      test.identical( track, exp );
      return null;
    });

  })

  /* */

  .then( function( arg )
  {
    test.case = 'take error uncaughtError';
    let t = context.t1;
    track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = _.Consequence.AndImmediate( con1, con2 );
    let err1 = _.err( 'Error1' );

    _.process.on( 'uncaughtError', uncaughtError_functor( 'Error1' ) );

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
    });

    con.tap( function( err, got )
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.true( !_.error.isAttended( err ) );
      test.true( _.error.isWary( err ) );
      test.true( !_.error.isSuspended( err ) );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.error' );
      con1.take( 1 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.take' );
      con2.error( err1 )
    });

    // return _.time.out( t * 4, function()
    return _.time.out( t * 8, function()
    {
      var exp = [ 'con1.error', 'con1.tap', 'con2.take', 'con2.tap', 'con.tap', 'uncaughtError' ];
      test.identical( track, exp );
      return null;
    });

  })

  /* */

  .then( function( arg )
  {
    test.case = 'error-non-object take uncaughtError';
    let t = context.t1;
    track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = _.Consequence.AndImmediate( con1, con2 );

    _.process.on( 'uncaughtError', uncaughtError_functor( '1' ) );

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
    });

    con.tap( function( err, got )
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( _.errIs( err ) );
      test.true( !_.error.isAttended( err ) );
      test.true( _.error.isWary( err ) );
      test.true( !_.error.isSuspended( err ) );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.error' );
      con1.error( 1 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.take' );
      con2.take( 2 )
    });

    // return _.time.out( t * 4, function()
    return _.time.out( t * 8, function() /* Dmytro : not sure than MacOS NodeJS v10 depends on this time outs */
    {
      var exp = [ 'con1.error', 'con1.tap', 'con2.take', 'con2.tap', 'con.tap', 'uncaughtError' ];
      test.identical( track, exp );
      return null;
    });

  })

  /* */

  return ready;

  function uncaughtError_functor( originalMessage )
  {
    return function uncaughtError( e )
    {
      test.equivalent( e.err.originalMessage, originalMessage );
      _.errAttend( e.err );
      track.push( 'uncaughtError' );
      _.process.off( 'uncaughtError', uncaughtError );
    }
  }

}

//

/* xxx : add test case not attending errors */
function AndImmediate( test )
{
  let context = this;
  let track;
  let ready = new _.Consequence().take( null )

  /* */

  .then( function( arg )
  {
    test.case = 'take take';
    let t = context.t1;
    track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = _.Consequence.AndImmediate( con1, con2 );

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( function( err, got )
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, 2 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.take' );
      con1.take( 1 );
    });
    _.time.out( t + t/2, () =>
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.take' );
      con2.take( 2 )
    });
    _.time.out( t * 2 + t/2, () =>
    {
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    return _.time.out( t * 4, function()
    {
      var exp = [ 'con1.take', 'con1.tap', 'con2.take', 'con2.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  })

  /* */

  .then( function( arg )
  {
    test.case = 'error take';
    let t = context.t1;
    track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = _.Consequence.AndImmediate( con1, con2 );
    let err1 = _.err( 'Error1' );

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( function( err, got )
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      test.true( !_.error.isAttended( err ) );
      test.true( _.error.isWary( err ) );
      test.true( !_.error.isSuspended( err ) );
      _.errAttend( err );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.error' );
      con1.error( err1 );
    });
    _.time.out( t + t/2, () =>
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.take' );
      con2.take( 2 )
    });
    _.time.out( t * 2 + t/2, () =>
    {
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    return _.time.out( t * 4, function()
    {
      var exp = [ 'con1.error', 'con1.tap', 'con2.take', 'con2.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  })

  /* */

  .then( function( arg )
  {
    test.case = 'take error';
    let t = context.t1;
    track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = _.Consequence.AndImmediate( con1, con2 );
    let err1 = _.err( 'Error1' );

    con1.tap( ( err, arg ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });

    con2.tap( ( err, arg ) =>
    {
      track.push( 'con2.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( function( err, got )
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      test.true( !_.error.isAttended( err ) );
      test.true( _.error.isWary( err ) );
      test.true( !_.error.isSuspended( err ) );
      _.errAttend( err );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.take' );
      con1.take( 1 );
    });
    _.time.out( t + t/2, () =>
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });
    _.time.out( t * 2, () =>
    {
      track.push( 'con2.error' );
      con2.error( err1 )
    });
    _.time.out( t * 2 + t/2, () =>
    {
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    return _.time.out( t * 4, function()
    {
      var exp = [ 'con1.take', 'con1.tap', 'con2.error', 'con2.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

  })

  /* */

  return ready;
}

//

function AndImmediateWithPromise( test )
{
  let context = this;
  let t = context.t1;
  let track;
  let ready = new _.Consequence().take( null );
  let err1, err2;

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - resolved, promise2 - resolved';
    track = [];
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( resolve2 );
    let con = _.Consequence.AndImmediate( promise1, promise2 );

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, 2 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.resolve', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - rejected, promise2 - resolved';
    track = [];
    err1 = _.errAttend( 'reject1' );
    let promise1 = new Promise( reject1 );
    let promise2 = new Promise( resolve2 );
    let con = _.Consequence.AndImmediate( promise1, promise2 );

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.reject', 'promise2.resolve', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - resolved, promise2 - rejected';
    track = [];
    err2 = _.errAttend( 'reject2' );
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( reject2 );
    let con = _.Consequence.AndImmediate( promise1, promise2 );

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err2 );
      test.identical( con.resourcesGet(), [ { 'error' : err2, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.reject', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err2, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - rejected, promise2 - rejected';
    track = [];
    err1 = _.errAttend( 'reject1' );
    err2 = _.errAttend( 'reject2' );
    let promise1 = new Promise( reject1 );
    let promise2 = new Promise( reject2 );
    let con = _.Consequence.AndImmediate( promise1, promise2 );

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.reject', 'promise2.reject', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  return ready;

  /* */

  function resolve1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.resolve' ); resolve( 1 ) } );
  }

  function resolve2( resolve, reject )
  {
    return _.time.out( t + t, () => { track.push( 'promise2.resolve' ); resolve( 2 ) } );
  }

  function reject1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.reject' ); reject( err1 ) } );
  }

  function reject2( resolve, reject )
  {
    return _.time.out( t + t, () => { track.push( 'promise2.reject' ); reject( _.errAttend( err2 ) ) } );
  }
}

//

function AndImmediateWithPromiseAndConsequence( test )
{
  let context = this;
  let t = context.t1;
  let track;
  let ready = new _.Consequence().take( null );
  let err1, err2;

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - resolved, promise2 - resolved, con - take';
    track = [];
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( resolve2 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = _.Consequence.AndImmediate( promise1, promise2, con1 );

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, 2, 3 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.take' );
      con1.take( 3 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.resolve', 'con1.take', 'con1.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - rejected, promise2 - resolved, con - take';
    track = [];
    err1 = _.errAttend( 'rejected1' );
    let promise1 = new Promise( reject1 );
    let promise2 = new Promise( resolve2 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = _.Consequence.AndImmediate( promise1, promise2, con1 );

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.take' );
      con1.take( 3 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.reject', 'promise2.resolve', 'con1.take', 'con1.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise1 - resolved, promise2 - resolved, con - error';
    track = [];
    err1 = _.errAttend( 'err1' );
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( resolve2 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = _.Consequence.AndImmediate( promise1, promise2, con1 );

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.error' );
      con1.error( err1 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.resolve', 'con1.error', 'con1.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  return ready;

  /* */

  function resolve1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.resolve' ); resolve( 1 ) } );
  }

  function resolve2( resolve, reject )
  {
    return _.time.out( t + t, () => { track.push( 'promise2.resolve' ); resolve( 2 ) } );
  }

  function reject1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.reject' ); reject( err1 ) } );
  }
}

//

function AndImmediateWithMixedCompetitors( test )
{
  let context = this;
  let t = context.t1;
  let track;
  let ready = new _.Consequence().take( null );
  let err1, err2;

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'none of async competitors';
    track = [];
    let con = _.Consequence.AndImmediate( 'str', null, 1 );

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 'str', null, 1 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 'str', null, 1 ] } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t, () =>
    {
      var exp = [ 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 'str', null, 1 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'none of async competitors and error';
    track = [];
    err1 = _.errAttend( 'err' );
    let con = _.Consequence.AndImmediate( [], {}, 'str', err1 );

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ [], {}, 'str', err1 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ [], {}, 'str', err1 ] } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t, () =>
    {
      var exp = [ 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ [], {}, 'str', err1 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'promise, routine, string, consequence';
    track = [];
    let promise = new Promise( resolve1 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = _.Consequence.AndImmediate( promise, routineReturnsConsequence, 'str', con1 );

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, null, 'str', 3 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, null, 'str', 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.take' );
      con1.take( 3 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'routine.con', 'promise1.resolve', 'con1.take', 'con1.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, null, 'str', 3 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'routine, string, consequence, promise, null';
    track = [];
    let promise = new Promise( resolve1 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = _.Consequence.AndImmediate( routineReturnsConsequence, 'str', con1, promise, null );

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ null, 'str', 3, 1, null ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ null, 'str', 3, 1, null ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 3 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.take' );
      con1.take( 3 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'routine.con', 'promise1.resolve', 'con1.take', 'con1.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ null, 'str', 3, 1, null ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'routine, string, consequence, promise, null, consequence - error';
    track = [];
    err1 = _.errAttend( 'err' );
    let promise = new Promise( resolve1 );
    let con1 = new _.Consequence({ tag : 'con1' });
    let con = _.Consequence.AndImmediate( routineReturnsConsequence, 'str', con1, promise, null );

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, undefined );
      test.true( err === err1 );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t * 3, () =>
    {
      track.push( 'con1.error' );
      con1.error( err1 );
    })

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'routine.con', 'promise1.resolve', 'con1.error', 'con1.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : err1, 'argument' : undefined } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'competitor - undefined, should throw error';
    return test.shouldThrowErrorOfAnyKind( () =>
    {
      _.Consequence.AndImmediate( routineReturnsConsequence, 'str', con1, promise, null );
    });
  });

  /* */

  return ready;

  /* */

  function routineReturnsConsequence()
  {
    track.push( 'routine.con' );
    return _.take( null );
  }

  function resolve1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.resolve' ); resolve( 1 ) } );
  }

  function reject1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.reject' ); reject( err1 ) } );
  }
}

//

function AndImmediateWithSeveralIdenticalCompetitors( test )
{
  let context = this;
  let t = context.t1;
  let track;
  let ready = new _.Consequence().take( null );
  let err1, err2;

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'few identical consequences in queue';
    track = [];
    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });
    let con = _.Consequence.AndImmediate( con1, con2, con1, con2 );

    con1.tap( ( err, got ) =>
    {
      track.push( 'con1.tap' );
      test.identical( got, 1 );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [] );
      test.identical( con2.competitorsEarlyGet().length, 2 );
    });

    con2.tap( ( err, got ) =>
    {
      track.push( 'con2.tap' );
      test.identical( got, 2 );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsCount(), 2 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 1, 2, 1, 2 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
    });

    _.time.out( t, () =>
    {
      track.push( 'con1.take' );
      con1.take( 1 );
    });

    _.time.out( t + t, () =>
    {
      track.push( 'con2.take' );
      con2.take( 2 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'con1.take', 'con1.tap', 'con2.take', 'con2.tap', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 1, 2, 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      test.identical( con1.resourcesGet(), [ { 'error' : undefined, 'argument' : 1 } ] );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet(), [ { 'error' : undefined, 'argument' : 2 } ] );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });
  });

  /* */

  ready.then( ( arg ) =>
  {
    test.case = 'few identical promises in queue';
    track = [];
    let promise1 = new Promise( resolve1 );
    let promise2 = new Promise( resolve2 );
    let con = _.Consequence.AndImmediate( promise2, promise1, promise1, promise2 );

    con.tap( ( err, got ) =>
    {
      track.push( 'con.tap' );
      test.identical( got, [ 2, 1, 1, 2 ] );
      test.true( err === undefined );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 2, 1, 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
    });

    return _.time.out( t * 4, () =>
    {
      var exp = [ 'promise1.resolve', 'promise2.resolve', 'con.tap' ];
      test.identical( track, exp );
      test.identical( con.resourcesGet(), [ { 'error' : undefined, 'argument' : [ 2, 1, 1, 2 ] } ] );
      test.identical( con.competitorsCount(), 0 );
      return null;
    });
  });

  /* */

  return ready;

  /* */

  function resolve1( resolve, reject )
  {
    return _.time.out( t, () => { track.push( 'promise1.resolve' ); resolve( 1 ) } );
  }

  function resolve2( resolve, reject )
  {
    return _.time.out( t + t, () => { track.push( 'promise2.resolve' ); resolve( 2 ) } );
  }
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
    test.true( rcon === con );

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

    con.finally( () =>
    {
      test.true( false );
      return null;
    });

    return _.time.out( context.t2, function( timer )
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
      test.true( _.timerIs( timer ) );
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
    test.true( rcon === con );

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

    return _.time.out( context.t2, function( timer )
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

      test.true( _.timerIs( timer ) );
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
    test.true( rcon === con );

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

    return _.time.out( context.t2, function( timer )
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

      test.true( _.timerIs( timer ) );
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

    con.finally( () =>
    {
      test.true( false );
      return null;
    });

    return _.time.out( context.t1*2, function( timer )
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

      test.true( _.timerIs( timer ) );

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

    con.finally( () =>
    {
      test.true( false );
      return null;
    });

    con.take( 0 );

    return _.time.out( context.t1*2, function( timer )
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
      test.true( _.timerIs( timer ) );
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

    return _.time.out( context.t1*2, function( timer )
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
      test.true( _.timerIs( timer ) );
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

    return _.time.out( context.t1*2, function( timer )
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
      test.true( _.timerIs( timer ) );
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

    return _.time.out( context.t1*2, function( timer )
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
      test.true( _.timerIs( timer ) );
    });
  })

  /* - */

  return ready;
}

//

function orKeepingWithPromises( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )

  /* */

  .then( ( arg ) =>
  {
    test.case = 'resolve promise1, resolve promise2 after';
    let t = context.t1;
    let promise1 = new Promise( ( resolve, reject ) => { _.time.out( t / 2, () => resolve( 1 ) ) } );
    let promise2 = new Promise( ( resolve, reject ) => { _.time.out( t, () => resolve( 2 ) ) } );
    let con = new _.Consequence({ capacity : 2 });

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );

    con.orKeeping([ promise1, promise2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 1 );
    });

    return _.time.out( t * 2, () =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );

      return null;
    });

  });

  //

  ready.then( ( arg ) =>
  {
    test.case = 'reject promise1, resolve promise2 after';
    let t = context.t1;
    let promise1 = new Promise( ( resolve, reject ) => { _.time.out( t / 2, () => reject( _.errAttend( 'Error' ) ) ) } );
    let promise2 = new Promise( ( resolve, reject ) => { _.time.out( t, () => resolve( 2 ) ) } );
    let con = new _.Consequence({ capacity : 2 });

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );

    con.orKeeping([ promise1, promise2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );

      test.true( _.errIs( err ) );
      test.identical( arg, undefined );
      _.errAttend( err );
    });

    return _.time.out( t * 2, () =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );

      return null;
    });
  })

  //

  ready.then( ( arg ) =>
  {
    test.case = 'resolve promise1 after resolve promise2';
    let t = context.t1;
    let promise1 = new Promise( ( resolve, reject ) => { _.time.out( t, () => resolve( 1 ) ) } );
    let promise2 = new Promise( ( resolve, reject ) => { _.time.out( t / 2, () => resolve( 2 ) ) } );
    let con = new _.Consequence({ capacity : 2 });

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );

    con.orKeeping([ promise1, promise2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );

      test.identical( arg, 2 );
      test.identical( err, undefined );
      _.errAttend( err );
    });

    return _.time.out( t * 2, () =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );

      return null;
    });
  })

  /* */

  return ready;
}

//

function orKeepingCheckProcedureSourcePath( test )
{
  let context = this;

  test.case = 'check path';
  var con = new _.Consequence({ tag : 'con' });
  var con1 = new _.Consequence({ tag : 'con1' });
  var con2 = new _.Consequence({ tag : 'con2' });

  con.orKeeping([ con1, con2 ]);
  var competitor = con.competitorsGet()[ 0 ];
  var infoFromErr = _._err({ args : [ '' ], level : 1 });
  var number = infoFromErr.lineNumber - 2;
  var fileName = infoFromErr.location.fileName;
  var exp = `${ fileName }:${ number }`;
  test.true( _.strHas( competitor.procedure._sourcePath, exp ) );
  test.true( _.strHas( competitor.procedure._sourcePath, infoFromErr.location.routineName ) );

  con1.take( 1 );
  con2.take( 2 );
  _.time.out( context.t1, () =>
  {
    con.take( 0 );
  });

  con.finallyGive( ( err, arg ) =>
  {
    test.identical( err, undefined );
    test.identical( arg, 1 );
  });

  return _.time.out( context.t2, () =>
  {
    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
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
    test.true( rcon === con );

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

    con.finally( () =>
    {
      test.true( false );
      return null;
    });

    return _.time.out( context.t1*2, function( timer )
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
      test.true( _.timerIs( timer ) );
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
    test.true( rcon === con );

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

    return _.time.out( context.t1*2, function( timer )
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

      test.true( _.timerIs( timer ) );

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
    test.true( rcon === con );

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

    return _.time.out( context.t1*2, function( timer )
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

      test.true( _.timerIs( timer ) );
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

    con1.takeLater( context.t1*4, 1 );
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

    con.finally( () =>
    {
      test.true( false );
      return null;
    });

    return _.time.out( context.t1*8, function( timer )
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

      test.true( _.timerIs( timer ) );

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

    con1.takeLater( context.t1*4, 1 );
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

    con.finally( () =>
    {
      test.true( false );
      return null;
    });

    con.take( 0 );

    return _.time.out( context.t1*8, function( timer )
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
      test.true( _.timerIs( timer ) );
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

    con1.takeLater( context.t1*4, 1 );
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

    con.takeLater( context.t1*8, 0 );

    return _.time.out( context.t1*12, function( timer )
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
      test.true( _.timerIs( timer ) );
      con.competitorsCancel();
    });
  });

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

    return _.time.out( context.t1*2, function( timer )
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
      test.true( _.timerIs( timer ) );
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

    return _.time.out( context.t1*2, function( timer )
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
      test.true( _.timerIs( timer ) );
    });
  })

  /* */

  return ready;
}

//

function orTakingWithPromises( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )

  /* */

  .then( ( arg ) =>
  {
    test.case = 'resolve promise1, resolve promise2 after';
    let t = context.t1;
    let promise1 = new Promise( ( resolve, reject ) => { _.time.out( t / 2, () => resolve( 1 ) ) } );
    let promise2 = new Promise( ( resolve, reject ) => { _.time.out( t, () => resolve( 2 ) ) } );
    let con = new _.Consequence({ capacity : 2 });

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );

    con.orTaking([ promise1, promise2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );

      test.identical( err, undefined );
      test.identical( arg, 1 );
    });

    return _.time.out( t * 2, () =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );

      return null;
    });

  });

  //

  ready.then( ( arg ) =>
  {
    test.case = 'reject promise1, resolve promise2 after';
    let t = context.t1;
    let promise1 = new Promise( ( resolve, reject ) => { _.time.out( t / 2, () => reject( _.errAttend( 'Error' ) ) ) } );
    let promise2 = new Promise( ( resolve, reject ) => { _.time.out( t, () => resolve( 2 ) ) } );
    let con = new _.Consequence({ capacity : 2 });

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );

    con.orTaking([ promise1, promise2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );

      test.true( _.errIs( err ) );
      test.identical( arg, undefined );
      _.errAttend( err );
    });

    return _.time.out( t * 2, () =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );

      return null;
    });
  })

  //

  ready.then( ( arg ) =>
  {
    test.case = 'resolve promise1 after resolve promise2';
    let t = context.t1;
    let promise1 = new Promise( ( resolve, reject ) => { _.time.out( t, () => resolve( 1 ) ) } );
    let promise2 = new Promise( ( resolve, reject ) => { _.time.out( t / 2, () => resolve( 2 ) ) } );
    let con = new _.Consequence({ capacity : 2 });

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );

    con.orTaking([ promise1, promise2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );

    con.finallyGive( ( err, arg ) =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );

      test.identical( arg, 2 );
      test.identical( err, undefined );
      _.errAttend( err );
    });

    return _.time.out( t * 2, () =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 0 );

      return null;
    });
  })

  /* */

  return ready;
}

//

function orTakingCheckProcedureSourcePath( test )
{
  let context = this;

  test.case = 'check path';
  var con = new _.Consequence({ tag : 'con' });
  var con1 = new _.Consequence({ tag : 'con1' });
  var con2 = new _.Consequence({ tag : 'con2' });

  con.orTaking([ con1, con2 ]);
  var competitor = con.competitorsGet()[ 0 ];
  var infoFromErr = _._err({ args : [ '' ], level : 1 });
  var number = infoFromErr.lineNumber - 2;
  var fileName = infoFromErr.location.fileName;
  var exp = `${ fileName }:${ number }`;
  test.true( _.strHas( competitor.procedure._sourcePath, exp ) );
  test.true( _.strHas( competitor.procedure._sourcePath, infoFromErr.location.routineName ) );

  con1.take( 1 );
  con2.take( 2 );
  _.time.out( context.t1, () =>
  {
    con.take( 0 );
  });

  con.finallyGive( ( err, arg ) =>
  {
    test.identical( err, undefined );
    test.identical( arg, 1 );
  });

  return _.time.out( context.t2, () =>
  {
    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 1 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con1.resourcesGet( 0 ), undefined );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 1 );
    test.identical( con2.competitorsCount(), 0 );
    test.identical( con2.resourcesGet( 0 ), { argument : 2, error : undefined } );
    con.competitorsCancel();
  });
}

//

function orKeepingSplitCanceled( test )
{
  let context = this;
  let ready = _.take( null );

  /* */

  ready
  .then( function( arg )
  {
    test.case = 'cancel con0';

    let counter = 0;
    let con0 = new _.Consequence();
    let con1 = new _.Consequence();
    let con2 = new _.Consequence();
    // let con00 = con0.orKeepingSplit([ con1, con2 ]);
    let con00 = _.Consequence.OrKeep( con0, con1, con2 );

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

    _.time.out( context.t1, () =>
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

    return _.time.out( context.t1*2, () =>
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
    // let con00 = con0.orKeepingSplit([ con1, con2 ]);
    let con00 = _.Consequence.OrKeep( con0, con1, con2 );

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

    _.time.out( context.t1, () =>
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

    return _.time.out( context.t1*2, () =>
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
    // let con00 = con0.orKeepingSplit([ con1, con2 ]);
    let con00 = _.Consequence.OrKeep( con0, con1, con2 );

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

    _.time.out( context.t1, () =>
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

    return _.time.out( context.t1*2, () =>
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

function orKeepingSplitCanceledProcedure( test )
{
  let context = this;
  let ready = _.take( null );

  /* */

  ready
  .then( function( arg )
  {
    test.case = 'basic';

    _.time.out( context.t3 / 4, () =>
    {

      test.identical( _.Procedure.Counter - pcounter, 3 );
      pcounter = _.Procedure.Counter;

      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.argumentsCount(), 0 );
      test.identical( con0.competitorsCount(), 2 );

      test.identical( con00.errorsCount(), 0 );
      test.identical( con00.argumentsCount(), 0 );
      test.identical( con00.competitorsCount(), 0 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 1 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 1 );

      counter += 1;
    })

    _.time.out( context.t3, () =>
    {

      test.identical( _.Procedure.Counter - pcounter, 0 );
      pcounter = _.Procedure.Counter;

      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.argumentsCount(), 1 );
      test.identical( con0.competitorsCount(), 0 );

      test.identical( con00.errorsCount(), 0 );
      test.identical( con00.argumentsCount(), 1 );
      test.identical( con00.competitorsCount(), 0 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 1 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 0 );

      counter += 1;
    })

    let pcounter = _.Procedure.Counter;
    let counter = 0;
    let con0 = _.time.out( context.t3 / 2 );
    con0.tag = 'con0';
    test.identical( _.Procedure.Counter - pcounter, 2 );
    pcounter = _.Procedure.Counter;

    let con1 = new _.Consequence({ tag : 'con1' });
    let con2 = new _.Consequence({ tag : 'con2' });

    test.identical( _.Procedure.Counter - pcounter, 0 );
    con2.then( () => con1 );
    test.identical( _.Procedure.Counter - pcounter, 1 );
    pcounter = _.Procedure.Counter;
    con2.take( null )
    test.identical( _.Procedure.Counter - pcounter, 0 );
    pcounter = _.Procedure.Counter;

    test.identical( con0.errorsCount(), 0 );
    test.identical( con0.argumentsCount(), 0 );
    test.identical( con0.competitorsCount(), 1 );

    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 1 );

    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    // let con00 = con0.orKeepingSplit([ con2 ]);
    let con00 = _.Consequence.OrKeep( con0, con2 );

    test.identical( con0.errorsCount(), 0 );
    test.identical( con0.argumentsCount(), 0 );
    test.identical( con0.competitorsCount(), 2 );

    test.identical( con00.errorsCount(), 0 );
    test.identical( con00.argumentsCount(), 0 );
    test.identical( con00.competitorsCount(), 0 );

    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 1 );

    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 0 );
    test.identical( con2.competitorsCount(), 1 );

    test.identical( _.Procedure.Counter - pcounter, 3 );
    pcounter = _.Procedure.Counter;

    return _.time.out( context.t3*2, () =>
    {

      test.identical( _.Procedure.Counter - pcounter, 0 );
      pcounter = _.Procedure.Counter;

      test.identical( con0.errorsCount(), 0 );
      test.identical( con0.argumentsCount(), 1 );
      test.identical( con0.competitorsCount(), 0 );

      test.identical( con00.errorsCount(), 0 );
      test.identical( con00.argumentsCount(), 1 );
      test.identical( con00.competitorsCount(), 0 );

      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 0 );
      test.identical( con1.competitorsCount(), 1 );

      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 0 );
      test.identical( con2.competitorsCount(), 0 );

      test.identical( counter, 2 );

    });

  });

  /* */

  return ready;
}

orKeepingSplitCanceledProcedure.description =
`
 - consequence.then( consequence ) should produce no procedure
`

//

function orKeepingCanceled( test )
{
  let context = this;
  let ready = _.take( null );

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

    test.true( con0 === con00 );

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

    test.true( con0 === con00 );

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

    test.true( con0 === con00 );

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

    con.finally( () =>
    {
      test.true( false );
      return null;
    });

    return _.time.out( context.t1*2, function( timer )
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
      test.true( _.timerIs( timer ) );
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

    con.finally( () =>
    {
      test.true( false );
      return null;
    });

    _.time.begin( 1, () => con.take( 10 ) );

    return _.time.out( context.t1*2, function( timer )
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
      test.true( _.timerIs( timer ) );
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

    con.finally( () =>
    {
      test.true( false );
      return null;
    });

    return _.time.out( context.t1*2, function( timer )
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
      test.true( _.timerIs( timer ) );
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

      test.true( _.strHas( String( err ), 'error1' ) );
      test.identical( arg, undefined );
      got = err;
    });

    con.finally( () =>
    {
      test.true( false );
      return null;
    });

    return _.time.out( context.t1*2, function( timer )
    {
      test.true( _.strHas( String( got ), 'error1' ) );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      test.true( _.timerIs( timer ) );
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

    con.finally( () =>
    {
      test.true( false );
      return null;
    });

    return _.time.out( context.t1*2, function( timer )
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

      test.true( _.timerIs( timer ) );

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

    con.finally( () =>
    {
      test.true( false );
      return null;
    });

    return _.time.out( context.t1*2, function( timer )
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
      test.true( _.timerIs( timer ) );
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

    con.finally( () =>
    {
      test.true( false );
      return null;
    });

    con.take( 0 );

    return _.time.out( context.t1*2, function( timer )
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
      test.true( _.timerIs( timer ) );
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

    con.finally( () =>
    {
      test.true( false );
      return got;
    });

    con.takeLater( context.t1*3/2, 0 );

    return _.time.out( context.t1*2, function( timer )
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
      test.true( _.timerIs( timer ) );
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

    return _.time.out( context.t1*2, function( timer )
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
      test.true( _.timerIs( timer ) );
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

    return _.time.out( context.t1*2, function( timer )
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
      test.true( _.timerIs( timer ) );
    });
  })

  /* */

  return ready;
}

//

function afterOrKeepingCheckProcedureSourcePath( test )
{
  let context = this;

  test.case = 'check path';
  var con = new _.Consequence({ tag : 'con' });
  var con1 = new _.Consequence({ tag : 'con1' });
  var con2 = new _.Consequence({ tag : 'con2' });

  con.afterOrKeeping([ con1, con2 ]);
  var competitor = con.competitorsGet()[ 0 ];
  var infoFromErr = _._err({ args : [ '' ], level : 1 });
  var number = infoFromErr.lineNumber - 2;
  var fileName = infoFromErr.location.fileName;
  var exp = `${ fileName }:${ number }`;
  test.true( _.strHas( competitor.procedure._sourcePath, exp ) );
  test.true( _.strHas( competitor.procedure._sourcePath, infoFromErr.location.routineName ) );

  con1.take( 1 );
  con2.take( 2 );
  _.time.out( context.t1, () =>
  {
    con.take( 0 );
  });

  con.finallyGive( ( err, arg ) =>
  {
    test.identical( err, undefined );
    test.identical( arg, 1 );
  });

  return _.time.out( context.t2, () =>
  {
    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
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
}

//

function afterOrKeepingWithPromises( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )

  /* */

  .then( ( arg ) =>
  {
    test.case = 'resolve promise1, resolve promise2 after';
    let t = context.t1;
    let promise1 = new Promise( ( resolve, reject ) => { _.time.out( t / 2, () => resolve( 1 ) ) } );
    let promise2 = new Promise( ( resolve, reject ) => { _.time.out( t, () => resolve( 2 ) ) } );
    let con = new _.Consequence({ capacity : 2 });

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );

    con.afterOrKeeping([ promise1, promise2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );

    con.finallyGive( ( err, arg ) =>
    {
      test.case = 'should not give';
      test.true( false );
    });

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 2 );

    return _.time.out( t * 2, () =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 2 );
      con.competitorsCancel();

      return null;
    });

  });

  //

  ready.then( ( arg ) =>
  {
    test.case = 'reject promise1, resolve promise2 after';
    let t = context.t1;
    let promise1 = new Promise( ( resolve, reject ) => { _.time.out( t / 2, () => reject( _.errAttend( 'Error' ) ) ) } );
    let promise2 = new Promise( ( resolve, reject ) => { _.time.out( t, () => resolve( 2 ) ) } );
    let con = new _.Consequence({ capacity : 2 });

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );

    con.afterOrKeeping([ promise1, promise2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );

    con.finallyGive( ( err, arg ) =>
    {
      test.case = 'should not give';
      test.true( false );
    });

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 2 );

    return _.time.out( t * 2, () =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 2 );
      con.competitorsCancel();

      return null;
    });
  })

  //

  ready.then( ( arg ) =>
  {
    test.case = 'resolve promise1 after resolve promise2';
    let t = context.t1;
    let promise1 = new Promise( ( resolve, reject ) => { _.time.out( t, () => resolve( 1 ) ) } );
    let promise2 = new Promise( ( resolve, reject ) => { _.time.out( t / 2, () => resolve( 2 ) ) } );
    let con = new _.Consequence({ capacity : 2 });

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );

    con.afterOrKeeping([ promise1, promise2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );

    con.finallyGive( ( err, arg ) =>
    {
      test.case = 'should not give';
      test.true( false );
    });

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 2 );

    return _.time.out( t * 2, () =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 2 );
      con.competitorsCancel();

      return null;
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
      test.true( err === _.dont );
      return null;
    });

    return _.time.out( context.t1*2, function( timer )
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
      test.true( _.timerIs( timer ) );
      con.error( _.dont );
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

      test.true( _.strHas( String( err ), 'error1' ) );
      test.identical( arg, undefined );
      got = err;
    });

    con.finally( ( err, arg ) =>
    {
      test.true( err === _.dont );
      return null;
    });

    return _.time.out( context.t1*2, function( timer )
    {
      test.true( _.strHas( String( got ), 'error1' ) );
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 1 );
      test.identical( con1.errorsCount(), 0 );
      test.identical( con1.argumentsCount(), 1 );
      test.identical( con1.competitorsCount(), 0 );
      test.identical( con2.errorsCount(), 0 );
      test.identical( con2.argumentsCount(), 1 );
      test.identical( con2.competitorsCount(), 0 );
      test.true( _.timerIs( timer ) );
      con.error( _.dont );
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

    con.finally( () =>
    {
      test.true( false );
      return null;
    });

    return _.time.out( context.t1*2, function( timer )
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

      test.true( _.timerIs( timer ) );

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

    con.finally( () =>
    {
      test.true( false );
      return null;
    });

    return _.time.out( context.t1*2, function( timer )
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
      test.true( _.timerIs( timer ) );
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

    con.finally( () =>
    {
      test.true( false );
      return null;
    });

    con.take( 0 );

    return _.time.out( context.t1*2, function( timer )
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
      test.true( _.timerIs( timer ) );
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

    con.finally( () =>
    {
      test.true( false );
      return got;
    });

    con.takeLater( context.t1*3/2, 0 );

    return _.time.out( context.t1*2, function( timer )
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
      test.true( _.timerIs( timer ) );
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

    return _.time.out( context.t1*2, function( timer )
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
      test.true( _.timerIs( timer ) );
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

    return _.time.out( context.t1*2, function( timer )
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
      test.true( _.timerIs( timer ) );
    });
  })

  /* */

  return ready;
}

//

function afterOrTakingWithPromises( test )
{
  let context = this;
  let ready = new _.Consequence().take( null )

  /* */

  .then( ( arg ) =>
  {
    test.case = 'resolve promise1, resolve promise2 after';
    let t = context.t1;
    let promise1 = new Promise( ( resolve, reject ) => { _.time.out( t / 2, () => resolve( 1 ) ) } );
    let promise2 = new Promise( ( resolve, reject ) => { _.time.out( t, () => resolve( 2 ) ) } );
    let con = new _.Consequence({ capacity : 2 });

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );

    con.afterOrTaking([ promise1, promise2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );

    con.finallyGive( ( err, arg ) =>
    {
      test.case = 'should not give';
      test.true( false );
    });

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 2 );

    return _.time.out( t * 2, () =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 2 );
      con.competitorsCancel();

      return null;
    });

  });

  //

  ready.then( ( arg ) =>
  {
    test.case = 'reject promise1, resolve promise2 after';
    let t = context.t1;
    let promise1 = new Promise( ( resolve, reject ) => { _.time.out( t / 2, () => reject( _.errAttend( 'Error' ) ) ) } );
    let promise2 = new Promise( ( resolve, reject ) => { _.time.out( t, () => resolve( 2 ) ) } );
    let con = new _.Consequence({ capacity : 2 });

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );

    con.afterOrTaking([ promise1, promise2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );

    con.finallyGive( ( err, arg ) =>
    {
      test.case = 'should not give';
      test.true( false );
    });

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 2 );

    return _.time.out( t * 2, () =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 2 );
      con.competitorsCancel();

      return null;
    });
  })

  //

  ready.then( ( arg ) =>
  {
    test.case = 'resolve promise1 after resolve promise2';
    let t = context.t1;
    let promise1 = new Promise( ( resolve, reject ) => { _.time.out( t, () => resolve( 1 ) ) } );
    let promise2 = new Promise( ( resolve, reject ) => { _.time.out( t / 2, () => resolve( 2 ) ) } );
    let con = new _.Consequence({ capacity : 2 });

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );

    con.afterOrTaking([ promise1, promise2 ]);

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 1 );

    con.finallyGive( ( err, arg ) =>
    {
      test.case = 'should not give';
      test.true( false );
    });

    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 2 );

    return _.time.out( t * 2, () =>
    {
      test.identical( con.errorsCount(), 0 );
      test.identical( con.argumentsCount(), 0 );
      test.identical( con.competitorsCount(), 2 );
      con.competitorsCancel();

      return null;
    });
  })

  /* */

  return ready;
}

//


function afterOrTakingCheckProcedureSourcePath( test )
{
  let context = this;

  test.case = 'check path';
  var con = new _.Consequence({ tag : 'con' });
  var con1 = new _.Consequence({ tag : 'con1' });
  var con2 = new _.Consequence({ tag : 'con2' });

  con.afterOrTaking([ con1, con2 ]);
  var competitor = con.competitorsGet()[ 0 ];
  var infoFromErr = _._err({ args : [ '' ], level : 1 });
  var number = infoFromErr.lineNumber - 2;
  var fileName = infoFromErr.location.fileName;
  var exp = `${ fileName }:${ number }`;
  test.true( _.strHas( competitor.procedure._sourcePath, exp ) );
  test.true( _.strHas( competitor.procedure._sourcePath, infoFromErr.location.routineName ) );

  con1.take( 1 );
  con2.take( 2 );
  _.time.out( context.t1, () =>
  {
    con.take( 0 );
  });

  con.finallyGive( ( err, arg ) =>
  {
    test.identical( err, undefined );
    test.identical( arg, 1 );
  });

  return _.time.out( context.t2, () =>
  {
    test.identical( con.errorsCount(), 0 );
    test.identical( con.argumentsCount(), 0 );
    test.identical( con.competitorsCount(), 0 );
    test.identical( con1.errorsCount(), 0 );
    test.identical( con1.argumentsCount(), 0 );
    test.identical( con1.competitorsCount(), 0 );
    test.identical( con1.resourcesGet( 0 ), undefined );
    test.identical( con2.errorsCount(), 0 );
    test.identical( con2.argumentsCount(), 1 );
    test.identical( con2.competitorsCount(), 0 );
    test.identical( con2.resourcesGet( 0 ), { argument : 2, error : undefined } );
    con.competitorsCancel();
  });
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
      test.identical( err, undefined );
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
      test.identical( err, undefined );
      return null;
    });

    _.time.out( delay * 2, () => { con1.take( 1 ) });
    _.time.out( delay, () => { con2.take( 2 ) });

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
      test.identical( err, undefined );
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
      test.identical( err, undefined );
      return null;
    });

    _.time.out( delay * 2, () => { con1.take( 1 ) });
    _.time.out( delay, () => { con2.take( 2 ) });

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
      test.identical( err, undefined );
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

//

function OrTakeProcedure( test )
{
  let context = this;

  let ready = new _.Consequence().take( null );

  /* */

  ready.then( function OrTake1( arg )
  {
    test.case = 'OrTake';

    let delay = context.t1;
    var con1 = new _.Consequence({ tag : 'mainCon' });
    var con2 = new _.Consequence({ tag : 'con' });

    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    let conOwner = _.Consequence.OrTake( con1, con2 );

    con1.finally( function( err, got )
    {
      test.identical( con1.competitorsCount(), 0 );
      return null;
    });

    con2.finally( function( err, got )
    {
      test.identical( con2.competitorsCount(), 0 );
      return null;
    });

    conOwner.finally( function( err, got )
    {
      test.identical( conOwner.competitorsCount(), 0 );
      return null;
    });

    test.identical( con1.competitorsCount(), 2 );
    test.identical( con2.competitorsCount(), 2 );
    test.identical( conOwner.competitorsCount(), 1 );

    con1.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'OrTake1' ) );
    })

    con2.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'OrTake1' ) );
    })

    conOwner.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'OrTake1' ) );
    })

    con1.take( null );
    con2.take( null );

    return _.time.out( delay * 4, function()
    {
      con1.cancel();
      con2.cancel();
      return null;
    });

  })

  return ready;
}

//

function OrKeepProcedure( test )
{
  let context = this;

  let ready = new _.Consequence().take( null );

  /* */

  ready.then( function OrKeep1( arg )
  {
    test.case = 'OrKeep';

    let delay = context.t1;
    var con1 = new _.Consequence({ tag : 'mainCon' });
    var con2 = new _.Consequence({ tag : 'con' });

    test.identical( con1.competitorsCount(), 0 );
    test.identical( con2.competitorsCount(), 0 );

    let conOwner = _.Consequence.OrKeep( con1, con2 );

    con1.finally( function( err, got )
    {
      test.identical( con1.competitorsCount(), 0 );
      return null;
    });

    con2.finally( function( err, got )
    {
      test.identical( con2.competitorsCount(), 0 );
      return null;
    });

    conOwner.finally( function( err, got )
    {
      test.identical( conOwner.competitorsCount(), 0 );
      return null;
    });

    test.identical( con1.competitorsCount(), 2 );
    test.identical( con2.competitorsCount(), 2 );
    test.identical( conOwner.competitorsCount(), 1 );

    con1.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'OrKeep1' ) );
    })

    con2.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'OrKeep1' ) );
    })

    conOwner.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'OrKeep1' ) );
    })

    con1.take( null );
    con2.take( null );

    return _.time.out( delay * 4, function()
    {
      con1.cancel();
      con2.cancel();
      return null;
    });

  })

  return ready;
}

// --
// resource handling
// --

function take( test )
{
  test.case = 'take single argument - null';
  var con = new _.Consequence().take( null );
  var got = con.resourcesCount();
  test.identical( got, 1 );
  var got = con.resourcesGet()[ 0 ];
  test.identical( got, { 'error' : undefined, 'argument' : null } );

  test.case = 'take single argument - string';
  var con = new _.Consequence().take( 'str' );
  var got = con.resourcesCount();
  test.identical( got, 1 );
  var got = con.resourcesGet()[ 0 ];
  test.identical( got, { 'error' : undefined, 'argument' : 'str' } );

  test.case = 'take single argument - array';
  var con = new _.Consequence().take([ 1, 2 ]);
  var got = con.resourcesCount();
  test.identical( got, 1 );
  var got = con.resourcesGet()[ 0 ];
  test.identical( got, { 'error' : undefined, 'argument' : [ 1, 2 ] } );

  test.case = 'take single argument - error';
  var err = _._err({ args : [ 'err' ] });
  var con = new _.Consequence().take( err );
  var got = con.resourcesCount();
  test.identical( got, 1 );
  var got = con.resourcesGet()[ 0 ];
  test.identical( got, { 'error' : undefined, 'argument' : err } );

  /* */

  test.case = 'take two arguments - undefined and null';
  var con = new _.Consequence().take( undefined, null );
  var got = con.resourcesCount();
  test.identical( got, 1 );
  var got = con.resourcesGet()[ 0 ];
  test.identical( got, { 'error' : undefined, 'argument' : null } );

  test.case = 'take two arguments - undefined and error';
  var err = _._err({ args : [ 'err' ] });
  var con = new _.Consequence().take( undefined, err );
  var got = con.resourcesCount();
  test.identical( got, 1 );
  var got = con.resourcesGet()[ 0 ];
  test.identical( got, { 'error' : undefined, 'argument' : err } );

  /* */

  test.case = 'two arguments, error - error, argument - undefined';
  var err = _.errAttend( 'Error' );
  var con = new _.Consequence().take( err, undefined );
  var got = con.resourcesCount();
  test.identical( got, 1 );
  var got = con.resourcesGet()[ 0 ];
  test.identical( got, { 'error' : err, 'argument' : undefined } );

  test.case = 'two arguments, error - Symbol, argument - undefined';
  var symbolOk = Symbol.for( 'Ok' );
  var con = new _.Consequence().take( symbolOk, undefined );
  var got = con.resourcesCount();
  test.identical( got, 1 );
  var got = con.resourcesGet()[ 0 ];
  test.identical( got, { 'error' : symbolOk, 'argument' : undefined } );

  /* - */

  if( !Config.debug )
  return;

  test.case = 'without arguments';
  test.shouldThrowErrorSync( () => new _.Consequence().take() );

  test.case = 'extra arguments';
  test.shouldThrowErrorSync( () => new _.Consequence().take( undefined, null, 'extra' ) );

  test.case = 'error and argument have not defined values';
  test.shouldThrowErrorSync( () => new _.Consequence().take( undefined, undefined ) );

  test.case = 'error and argument have defined values';
  test.shouldThrowErrorSync( () =>
  {
    var err = _.errAttend( 'err' );
    new _.Consequence().take( err, null );
  });
}

//

function takeInToolsNamespace( test )
{
  test.case = 'without arguments';
  var con = _.take();
  var got = con.resourcesCount();
  test.identical( got, 1 );
  var got = con.resourcesGet()[ 0 ];
  test.identical( got, { 'error' : undefined, 'argument' : null } );

  test.case = 'take single argument - null';
  var con = _.take( null );
  var got = con.resourcesCount();
  test.identical( got, 1 );
  var got = con.resourcesGet()[ 0 ];
  test.identical( got, { 'error' : undefined, 'argument' : null } );

  test.case = 'take single argument - string';
  var con = _.take( 'str' );
  var got = con.resourcesCount();
  test.identical( got, 1 );
  var got = con.resourcesGet()[ 0 ];
  test.identical( got, { 'error' : undefined, 'argument' : 'str' } );

  test.case = 'take single argument - array';
  var con = _.take([ 1, 2 ]);
  var got = con.resourcesCount();
  test.identical( got, 1 );
  var got = con.resourcesGet()[ 0 ];
  test.identical( got, { 'error' : undefined, 'argument' : [ 1, 2 ] } );

  test.case = 'take single argument - error';
  var err = _._err({ args : [ 'err' ] });
  var con = _.take( err );
  var got = con.resourcesCount();
  test.identical( got, 1 );
  var got = con.resourcesGet()[ 0 ];
  test.identical( got, { 'error' : undefined, 'argument' : err } );

  /* */

  test.case = 'take two arguments - undefined and null';
  var con = _.take( undefined, null );
  var got = con.resourcesCount();
  test.identical( got, 1 );
  var got = con.resourcesGet()[ 0 ];
  test.identical( got, { 'error' : undefined, 'argument' : null } );

  test.case = 'take two arguments - undefined and error';
  var err = _._err({ args : [ 'err' ] });
  var con = _.take( undefined, err );
  var got = con.resourcesCount();
  test.identical( got, 1 );
  var got = con.resourcesGet()[ 0 ];
  test.identical( got, { 'error' : undefined, 'argument' : err } );

  /* */

  test.case = 'two arguments, error - error, argument - undefined';
  var err = _.errAttend( 'Error' );
  var con = _.take( err, undefined );
  var got = con.resourcesCount();
  test.identical( got, 1 );
  var got = con.resourcesGet()[ 0 ];
  test.identical( got, { 'error' : err, 'argument' : undefined } );

  test.case = 'two arguments, error - Symbol, argument - undefined';
  var symbolOk = Symbol.for( 'Ok' );
  var con = _.take( symbolOk, undefined );
  var got = con.resourcesCount();
  test.identical( got, 1 );
  var got = con.resourcesGet()[ 0 ];
  test.identical( got, { 'error' : symbolOk, 'argument' : undefined } );

  /* - */

  if( !Config.debug )
  return;

  test.case = 'extra arguments';
  test.shouldThrowErrorSync( () => _.take( undefined, null, 'extra' ) );

  test.case = 'error and argument have not defined values';
  test.shouldThrowErrorSync( () => _.take( undefined, undefined ) );

  test.case = 'error and argument have defined values';
  test.shouldThrowErrorSync( () =>
  {
    var err = _.errAttend( 'err' );
    _.take( err, null );
  });
}

//

function takeSymbolInErrorChanel( test )
{
  test.case = 'by method take';
  var symbolOk = Symbol.for( 'Ok' );
  var con = new _.Consequence().take( symbolOk, undefined );
  var got = con.resourcesCount();
  test.identical( got, 1 );
  var got = con.resourcesGet()[ 0 ];
  test.identical( got, { 'error' : symbolOk, 'argument' : undefined } );

  test.case = 'by method error';
  var symbolOk = Symbol.for( 'Ok' );
  var con = new _.Consequence().error( symbolOk );
  var got = con.resourcesCount();
  test.identical( got, 1 );
  var got = con.resourcesGet()[ 0 ];
  test.identical( got, { 'error' : symbolOk, 'argument' : undefined } );

  /* - */

  if( !Config.debug )
  return;

  test.case = 'not Symbol, not Error';
  test.shouldThrowErrorAsync( () => new _.Consequence().take( 'Ok', undefined ) );
  test.shouldThrowErrorAsync( () => new _.Consequence().error( 'Ok' ) );
}

// --
// competitor
// --

function competitorOwn( test )
{
  test.case = 'consequence has no competitors';
  var con = new _.Consequence().take( null );
  test.identical( con.competitorsCount(), 0 );
  test.identical( !!con.competitorOwn( competitorRoutine1 ), false );
  test.identical( !!con.competitorOwn( competitorRoutine2 ), false );

  test.case = 'consequence has one competitor routine';
  var con = new _.Consequence().take( null );
  con.give( competitorRoutine1 );
  con.give( competitorRoutine1 );
  test.identical( con.competitorsCount(), 1 );
  test.identical( !!con.competitorOwn( competitorRoutine1 ), true );
  test.identical( !!con.competitorOwn( competitorRoutine2 ), false );
  con.competitorsCancel( competitorRoutine1 );

  test.case = 'consequence has a few instances of single competitor routine';
  var con = new _.Consequence().take( null );
  con.give( competitorRoutine1 );
  con.give( competitorRoutine1 );
  con.give( competitorRoutine1 );
  con.give( competitorRoutine1 );
  test.identical( con.competitorsCount(), 3 );
  test.identical( !!con.competitorOwn( competitorRoutine1 ), true );
  test.identical( !!con.competitorOwn( competitorRoutine2 ), false );
  con.competitorsCancel( competitorRoutine1 );

  test.case = 'consequence has single instance of different competitor routines';
  var con = new _.Consequence().take( null );
  con.give( competitorRoutine1 );
  con.give( competitorRoutine1 );
  con.give( competitorRoutine2 );
  test.identical( con.competitorsCount(), 2 );
  test.identical( !!con.competitorOwn( competitorRoutine1 ), true );
  test.identical( !!con.competitorOwn( competitorRoutine2 ), true );
  con.competitorsCancel( competitorRoutine1 );
  con.competitorsCancel( competitorRoutine2 );

  test.case = 'consequence has a few instances of different competitor routines';
  var con = new _.Consequence().take( null );
  con.give( competitorRoutine1 );
  con.give( competitorRoutine1 );
  con.give( competitorRoutine1 );
  con.give( competitorRoutine2 );
  con.give( competitorRoutine2 );
  test.identical( con.competitorsCount(), 4 );
  test.identical( !!con.competitorOwn( competitorRoutine1 ), true );
  test.identical( !!con.competitorOwn( competitorRoutine2 ), true );
  con.competitorsCancel( competitorRoutine1 );
  con.competitorsCancel( competitorRoutine2 );

  /* */

  function competitorRoutine1(){}
  function competitorRoutine2(){}
}

//

function competitorsCount( test )
{
  test.open( 'without argument' );

  test.case = 'consequence has no competitors';
  var con = new _.Consequence().take( null );
  test.identical( con.competitorsCount(), 0 );

  test.case = 'consequence has no competitors';
  var con = new _.Consequence().take( null );
  con.give( competitorRoutine1 );
  test.identical( con.competitorsCount(), 0 );

  test.case = 'consequence has one competitor routine';
  var con = new _.Consequence().take( null );
  con.give( competitorRoutine1 );
  con.give( competitorRoutine1 );
  test.identical( con.competitorsCount(), 1 );
  con.competitorsCancel( competitorRoutine1 );

  test.case = 'consequence has a few instances of single competitor routine';
  var con = new _.Consequence().take( null );
  con.give( competitorRoutine1 );
  con.give( competitorRoutine1 );
  con.give( competitorRoutine1 );
  con.give( competitorRoutine1 );
  test.identical( con.competitorsCount(), 3 );
  con.competitorsCancel( competitorRoutine1 );

  test.case = 'consequence has single instance of different competitor routines';
  var con = new _.Consequence().take( null );
  con.give( competitorRoutine1 );
  con.give( competitorRoutine1 );
  con.give( competitorRoutine2 );
  test.identical( con.competitorsCount(), 2 );
  con.competitorsCancel( competitorRoutine1 );
  con.competitorsCancel( competitorRoutine2 );

  test.case = 'consequence has a few instances of different competitor routines';
  var con = new _.Consequence().take( null );
  con.give( competitorRoutine1 );
  con.give( competitorRoutine1 );
  con.give( competitorRoutine1 );
  con.give( competitorRoutine2 );
  con.give( competitorRoutine2 );
  test.identical( con.competitorsCount(), 4 );
  con.competitorsCancel( competitorRoutine1 );
  con.competitorsCancel( competitorRoutine2 );

  test.close( 'without argument' );

  /* - */

  test.open( 'with competitorRoutine' );

  test.case = 'consequence has no competitors';
  var con = new _.Consequence().take( null );
  test.identical( con.competitorsCount( competitorRoutine1 ), 0 );
  test.identical( con.competitorsCount( competitorRoutine2 ), 0 );

  test.case = 'consequence has no competitors';
  var con = new _.Consequence().take( null );
  con.give( competitorRoutine1 );
  test.identical( con.competitorsCount( competitorRoutine1 ), 0 );
  test.identical( con.competitorsCount( competitorRoutine2 ), 0 );

  test.case = 'consequence has one competitor routine';
  var con = new _.Consequence().take( null );
  con.give( competitorRoutine1 );
  con.give( competitorRoutine1 );
  test.identical( con.competitorsCount( competitorRoutine1 ), 1 );
  test.identical( con.competitorsCount( competitorRoutine2 ), 0 );
  con.competitorsCancel( competitorRoutine1 );

  test.case = 'consequence has a few instances of single competitor routine';
  var con = new _.Consequence().take( null );
  con.give( competitorRoutine1 );
  con.give( competitorRoutine1 );
  con.give( competitorRoutine1 );
  con.give( competitorRoutine1 );
  test.identical( con.competitorsCount( competitorRoutine1 ), 3 );
  test.identical( con.competitorsCount( competitorRoutine2 ), 0 );
  con.competitorsCancel( competitorRoutine1 );

  test.case = 'consequence has single instance of different competitor routines';
  var con = new _.Consequence().take( null );
  con.give( competitorRoutine1 );
  con.give( competitorRoutine1 );
  con.give( competitorRoutine2 );
  test.identical( con.competitorsCount( competitorRoutine1 ), 1 );
  test.identical( con.competitorsCount( competitorRoutine2 ), 1 );
  con.competitorsCancel( competitorRoutine1 );
  con.competitorsCancel( competitorRoutine2 );

  test.case = 'consequence has a few instances of different competitor routines';
  var con = new _.Consequence().take( null );
  con.give( competitorRoutine1 );
  con.give( competitorRoutine1 );
  con.give( competitorRoutine1 );
  con.give( competitorRoutine2 );
  con.give( competitorRoutine2 );
  test.identical( con.competitorsCount( competitorRoutine1 ), 2 );
  test.identical( con.competitorsCount( competitorRoutine2 ), 2 );
  con.competitorsCancel( competitorRoutine1 );
  con.competitorsCancel( competitorRoutine2 );

  test.close( 'with competitorRoutine' );

  /* - */

  if( Config.debug )
  {
    test.case = 'extra arguments';
    test.shouldThrowErrorSync( () =>
    {
      var con = new _.Consequence().take( null );
      con.competitorsCount( competitorRoutine1, competitorRoutine1 );
    });

    test.case = 'wrong type of competitorRoutine';
    test.shouldThrowErrorSync( () =>
    {
      var con = new _.Consequence().take( null );
      con.competitorsCount( 'wrong' );
    });
  }

  /* */

  function competitorRoutine1(){}
  function competitorRoutine2(){}
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

function competitorsCancel2( test )
{
  let context = this;
  let con = new _.Consequence();
  con.finally( end );

  var competitor = con.competitorHas( end );
  var procedure = competitor.procedure;
  test.true( !!competitor );
  test.true( !!competitor.procedure );
  test.true( procedure.isAlive() );

  test.identical( con.argumentsCount(), 0 );
  test.identical( con.errorsCount(), 0 );
  test.identical( con.competitorsCount(), 1 );

  con.competitorsCancel( end );

  test.identical( con.argumentsCount(), 0 );
  test.identical( con.errorsCount(), 0 );
  test.identical( con.competitorsCount(), 0 );

  var competitor = con.competitorHas( end );
  test.true( !competitor );
  test.true( !procedure.isAlive() );

  return _.time.out( context.t1 );

  function end( err, got )
  {
    console.log( 'error : ', err );
    console.log( 'end : ', got )
    return got;
  }
}

// --
// resources
// --

function argumentsCount( test )
{
  test.open( 'without arguments' );

  test.case = 'con without arguments, empty _resources';
  var con = new _.Consequence();
  test.identical( con.argumentsCount(), 0 );

  test.case = 'con without arguments, _resources has error';
  var con = new _.Consequence();
  con.error( _.errAttend( 'Error' ) );
  test.identical( con.argumentsCount(), 0 );

  test.case = 'con with single argument';
  var con = new _.Consequence().take( null );
  test.identical( con.argumentsCount(), 1 );

  test.case = 'con with single argument and single error';
  var con = new _.Consequence().take( null );
  con.error( _.errAttend( 'Error' ) );
  test.identical( con.argumentsCount(), 1 );

  /* */

  test.case = 'con with two arguments, capacity - 3';
  var con = new _.Consequence({ capacity : 3 }).take( null );
  con.take( 1 );
  test.identical( con.argumentsCount(), 2 );

  test.case = 'con with three arguments, capacity - 3';
  var con = new _.Consequence({ capacity : 3 }).take( null );
  con.take( 1 );
  con.take( 1 );
  test.identical( con.argumentsCount(), 3 );

  test.case = 'con with three arguments and a few errors, capacity - 3';
  var con = new _.Consequence({ capacity : 3 }).take( null );
  con.take( 1 );
  con.take( 1 );
  con.error( _.errAttend( 'Error' ) );
  con.error( _.errAttend( 'Error' ) );
  test.identical( con.argumentsCount(), 3 );

  test.close( 'without arguments' );

  /* - */

  test.open( 'with arg' );

  test.case = 'con without arguments, empty _resources';
  var con = new _.Consequence();
  test.identical( con.argumentsCount( null ), 0 );
  test.identical( con.argumentsCount( 1 ), 0 );

  test.case = 'con without arguments, _resources has error';
  var con = new _.Consequence();
  con.error( _.errAttend( 'Error' ) );
  test.identical( con.argumentsCount( null ), 0 );
  test.identical( con.argumentsCount( 1 ), 0 );

  test.case = 'con with single argument';
  var con = new _.Consequence().take( null );
  test.identical( con.argumentsCount( null ), 1 );
  test.identical( con.argumentsCount( 1 ), 0 );

  test.case = 'con with single argument and single error';
  var con = new _.Consequence().take( null );
  con.error( _.errAttend( 'Error' ) );
  test.identical( con.argumentsCount( null ), 1 );
  test.identical( con.argumentsCount( 1 ), 0 );

  /* */

  test.case = 'con with two arguments, capacity - 3';
  var con = new _.Consequence({ capacity : 3 }).take( null );
  con.take( 1 );
  test.identical( con.argumentsCount( null ), 1 );
  test.identical( con.argumentsCount( 1 ), 1 );

  test.case = 'con with three arguments, capacity - 3';
  var con = new _.Consequence({ capacity : 3 }).take( null );
  con.take( 1 );
  con.take( 1 );
  test.identical( con.argumentsCount( null ), 1 );
  test.identical( con.argumentsCount( 1 ), 2 );

  test.case = 'con with three arguments and a few errors, capacity - 3';
  var con = new _.Consequence({ capacity : 3 }).take( null );
  con.take( 1 );
  con.take( 1 );
  con.error( _.errAttend( 'Error' ) );
  con.error( _.errAttend( 'Error' ) );
  test.identical( con.argumentsCount( null ), 1 );
  test.identical( con.argumentsCount( 1 ), 2 );

  test.close( 'with arg' );

  /* - */

  if( !Config.debug )
  return;

  test.case = 'extra arguments';
  test.shouldThrowErrorSync( () =>
  {
    var con = new _.Consequence().take( null );
    con.argumentsCount( null, 1 );
  });
}

//

function errorsCount( test )
{
  test.open( 'without arguments' );

  test.case = 'con without errors, empty _resources';
  var con = new _.Consequence();
  test.identical( con.errorsCount(), 0 );

  test.case = 'con without errors, _resources has resource';
  var con = new _.Consequence().take( null );
  test.identical( con.errorsCount(), 0 );

  test.case = 'con with single error';
  var con = new _.Consequence().error( _.errAttend( 'Error' ) );
  test.identical( con.errorsCount(), 1 );

  test.case = 'con with single argument and single error';
  var con = new _.Consequence().take( null );
  con.error( _.errAttend( 'Error' ) );
  test.identical( con.errorsCount(), 1 );

  /* */

  test.case = 'con with two errors, capacity - 3';
  var err1 = _.errAttend( 'Error' );
  var err2 = _.errAttend( 'Error2' );
  var con = new _.Consequence({ capacity : 3 }).error( err1 );
  con.error( err2 );
  test.identical( con.errorsCount(), 2 );

  test.case = 'con with three errors, capacity - 3';
  var err1 = _.errAttend( 'Error' );
  var err2 = _.errAttend( 'Error2' );
  var con = new _.Consequence({ capacity : 3 }).error( err1 );
  con.error( err2 );
  con.error( err2 );
  test.identical( con.errorsCount(), 3 );

  test.case = 'con with three errors and a few arguments, capacity - 3';
  var err1 = _.errAttend( 'Error' );
  var err2 = _.errAttend( 'Error2' )
  var con = new _.Consequence({ capacity : 3 }).take( null );
  con.take( null );
  con.error( err1 );
  con.error( err2 );
  con.error( err2 );
  test.identical( con.errorsCount(), 3 );

  test.close( 'without arguments' );

  /* - */

  test.open( 'with err' );

  test.case = 'con without errors, empty _resources';
  var err1 = _.errAttend( 'Error' );
  var err2 = _.errAttend( 'Error2' )
  var con = new _.Consequence();
  test.identical( con.errorsCount( err1 ), 0 );
  test.identical( con.errorsCount( err2 ), 0 );

  test.case = 'con without errors, _resources has resource';
  var err1 = _.errAttend( 'Error' );
  var err2 = _.errAttend( 'Error2' )
  var con = new _.Consequence().take( null );
  test.identical( con.errorsCount( err1 ), 0 );
  test.identical( con.errorsCount( err2 ), 0 );

  test.case = 'con with single error';
  var err1 = _.errAttend( 'Error' );
  var err2 = _.errAttend( 'Error2' )
  var con = new _.Consequence().error( err1 );
  test.identical( con.errorsCount( err1 ), 1 );
  test.identical( con.errorsCount( err2 ), 0 );

  test.case = 'con with single argument and single error';
  var err1 = _.errAttend( 'Error' );
  var err2 = _.errAttend( 'Error2' )
  var con = new _.Consequence().take( null );
  con.error( err1 );
  test.identical( con.errorsCount( err1 ), 1 );
  test.identical( con.errorsCount( err2 ), 0 );

  /* */

  test.case = 'con with two errors, capacity - 3';
  var err1 = _.errAttend( 'Error' );
  var err2 = _.errAttend( 'Error2' );
  var con = new _.Consequence({ capacity : 3 }).error( err1 );
  con.error( err2 );
  test.identical( con.errorsCount( err1 ), 1 );
  test.identical( con.errorsCount( err2 ), 1 );

  test.case = 'con with three errors, capacity - 3';
  var err1 = _.errAttend( 'Error' );
  var err2 = _.errAttend( 'Error2' );
  var con = new _.Consequence({ capacity : 3 }).error( err1 );
  con.error( err2 );
  con.error( err2 );
  test.identical( con.errorsCount( err1 ), 1 );
  test.identical( con.errorsCount( err2 ), 2 );

  test.case = 'con with three errors and a few arguments, capacity - 3';
  var err1 = _.errAttend( 'Error' );
  var err2 = _.errAttend( 'Error2' )
  var con = new _.Consequence({ capacity : 3 }).take( null );
  con.take( null );
  con.error( err1 );
  con.error( err2 );
  con.error( err2 );
  test.identical( con.errorsCount( err1 ), 1 );
  test.identical( con.errorsCount( err2 ), 2 );

  test.close( 'with err' );

  /* - */

  if( !Config.debug )
  return;

  test.case = 'extra arguments';
  test.shouldThrowErrorSync( () =>
  {
    var err = _.errAttend( 'Error' );
    var con = new _.Consequence().error( err );
    con.errorsCount( err, _.errAttend( 'err' ) );
  });
}

//

function resourcesCount( test )
{
  test.open( 'without arguments' );

  test.case = 'con without arguments, empty _resources';
  var con = new _.Consequence();
  test.identical( con.resourcesCount(), 0 );

  test.case = 'con without arguments, _resources has error';
  var con = new _.Consequence();
  con.error( _.errAttend( 'Error' ) );
  test.identical( con.resourcesCount(), 1 );

  test.case = 'con with single argument';
  var con = new _.Consequence().take( null );
  test.identical( con.resourcesCount(), 1 );

  test.case = 'con with single argument and single error';
  var con = new _.Consequence().take( null );
  con.error( _.errAttend( 'Error' ) );
  test.identical( con.resourcesCount(), 2 );

  /* */

  test.case = 'con with two arguments, capacity - 3';
  var con = new _.Consequence({ capacity : 3 }).take( null );
  con.take( 1 );
  test.identical( con.resourcesCount(), 2 );

  test.case = 'con with three arguments, capacity - 3';
  var con = new _.Consequence({ capacity : 3 }).take( null );
  con.take( 1 );
  con.take( 1 );
  test.identical( con.resourcesCount(), 3 );

  test.case = 'con with three arguments and a few errors, capacity - 3';
  var con = new _.Consequence({ capacity : 3 }).take( null );
  con.take( 1 );
  con.take( 1 );
  con.error( _.errAttend( 'Error' ) );
  con.error( _.errAttend( 'Error' ) );
  test.identical( con.resourcesCount(), 5 );

  test.close( 'without arguments' );

  /* - */

  test.open( 'with arg' );

  test.case = 'con without arguments, empty _resources';
  var err1 = _.errAttend( 'Error' );
  var con = new _.Consequence();
  test.identical( con.resourcesCount( null ), 0 );
  test.identical( con.resourcesCount( 1 ), 0 );
  test.identical( con.resourcesCount( err1 ), 0 );

  test.case = 'con without arguments, _resources has error';
  var err1 = _.errAttend( 'Error' );
  var con = new _.Consequence();
  con.error( err1 );
  test.identical( con.resourcesCount( null ), 0 );
  test.identical( con.resourcesCount( 1 ), 0 );
  test.identical( con.resourcesCount( err1 ), 1 );

  test.case = 'con with single argument';
  var err1 = _.errAttend( 'Error' );
  var con = new _.Consequence().take( null );
  test.identical( con.resourcesCount( null ), 1 );
  test.identical( con.resourcesCount( 1 ), 0 );
  test.identical( con.resourcesCount( err1 ), 0 );

  test.case = 'con with single argument and single error';
  var err1 = _.errAttend( 'Error' );
  var con = new _.Consequence().take( null );
  con.error( err1 );
  test.identical( con.resourcesCount( null ), 1 );
  test.identical( con.resourcesCount( 1 ), 0 );
  test.identical( con.resourcesCount( err1 ), 1 );

  /* */

  test.case = 'con with two arguments, capacity - 3';
  var err1 = _.errAttend( 'Error' );
  var con = new _.Consequence({ capacity : 3 }).take( null );
  con.take( 1 );
  test.identical( con.resourcesCount( null ), 1 );
  test.identical( con.resourcesCount( 1 ), 1 );
  test.identical( con.resourcesCount( err1 ), 0 );

  test.case = 'con with three arguments, capacity - 3';
  var err1 = _.errAttend( 'Error' );
  var con = new _.Consequence({ capacity : 3 }).take( null );
  con.take( 1 );
  con.take( 1 );
  test.identical( con.resourcesCount( null ), 1 );
  test.identical( con.resourcesCount( 1 ), 2 );
  test.identical( con.resourcesCount( err1 ), 0 );

  test.case = 'con with three arguments and a few errors, capacity - 3';
  var err1 = _.errAttend( 'Error' );
  var err2 = _.errAttend( 'Error2' );
  var symbolOk = Symbol.for( 'Ok' );
  var con = new _.Consequence({ capacity : 3 }).take( null );
  con.take( symbolOk );
  con.take( symbolOk );
  con.error( err1 );
  con.error( err2 );
  con.error( symbolOk );
  test.identical( con.resourcesCount( null ), 1 );
  test.identical( con.resourcesCount( symbolOk ), 3 );
  test.identical( con.resourcesCount( err1 ), 1 );
  test.identical( con.resourcesCount( err2 ), 1 );

  test.close( 'with arg' );

  /* - */

  if( !Config.debug )
  return;

  test.case = 'extra arguments';
  test.shouldThrowErrorSync( () =>
  {
    var con = new _.Consequence().take( null );
    con.resourcesCount( null, 1 );
  });
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
    test.true( _.consequenceIs( context ) );
    context.finally( ( err, arg ) =>
    {
      test.true( err === undefined );
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
    {
      _.after( array[ a ]() )
      .putKeep( result, a )
      .participateGive( con );
    }

    con.wait()
    .take( result );

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
    {
      _.after( array[ a ]() )
      .putKeep( result, a )
      .participateGive( con );
    }
    con.wait()
    .take( result );

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

//

function putKeepProcedure( test )
{
  let context = this;

  let ready = new _.Consequence().take( null );

  /* */

  ready.then( function putKeep1( arg )
  {
    var result = [];
    var con = new _.Consequence({ tag : 'con' });

    con.putKeep( result, 1 );

    test.identical( con.competitorsCount(), 1 );
    con.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'putKeep1' ) );
    })

    con.wait()
    .take( result );

    return con.syncMaybe();
  })

  return ready;
}

//

function putGiveProcedure( test )
{
  let context = this;

  let ready = new _.Consequence().take( null );

  /* */

  ready.then( function putGive1( arg )
  {
    var result = [];
    var con = new _.Consequence({ tag : 'con' });

    con.putGive( result, 1 );

    test.identical( con.competitorsCount(), 1 );
    con.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'putGive1' ) );
    })

    con.take( null );

    con.wait()
    .take( result );

    return con.syncMaybe();
  })

  return ready;
}

//

function thenPutGiveProcedure( test )
{
  let context = this;

  let ready = new _.Consequence().take( null );

  /* */

  ready.then( function thenPutGive1( arg )
  {
    var result = [];
    var con = new _.Consequence({ tag : 'con' });

    con.thenPutGive( result, 1 );

    test.identical( con.competitorsCount(), 1 );
    con.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'thenPutGive1' ) );
    })

    con.take( null );

    con.wait()
    .take( result );

    return con.syncMaybe();
  })

  return ready;
}

//

function thenPutKeepProcedure( test )
{
  let context = this;

  let ready = new _.Consequence().take( null );

  /* */

  ready.then( function thenPutKeep1( arg )
  {
    var result = [];
    var con = new _.Consequence({ tag : 'con' });

    con.thenPutKeep( result, 1 );

    test.identical( con.competitorsCount(), 1 );
    con.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'thenPutKeep1' ) );
    })

    con.wait()
    .take( result );

    return con.syncMaybe();
  })

  return ready;
}

//--
// first
//--

function firstAsyncMode00( test )
{
  let context = this;
  let amode = _.Consequence.AsyncModeGet();
  let ready = new _.Consequence().take( null )

  // .finally( () =>
  // {
  //   _.Consequence.AsyncModeSet([ 0, 0 ]);
  //   test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );
  //   return null;
  // })

  /* */

  .then( function( arg )
  {
    test.case = 'simplest, empty routine';
    var con = new _.Consequence({ tag : 'con', capacity : 2 });
    con.first( () => null );
    con.take( 'str' );
    con.finally( function( err, got )
    {
      test.identical( got, null );
      test.identical( err, undefined );
      test.identical( con.resourcesGet(), [ { error : undefined, argument : 'str' } ] );
      return null;
    })
    return con;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'routine returns something';
    var con = new _.Consequence({ tag : 'con', capacity : 2 });
    con.first( () => 'str' );
    con.take( 'str' + 2 );
    con.finally( function( err, got )
    {
      test.identical( got, 'str' );
      test.identical( err, undefined );
      test.identical( con.resourcesGet(), [ { error : undefined, argument : 'str' + 2 } ] );
      return null;
    })
    return con;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'routine throws error';
    var con = new _.Consequence({ tag : 'con' });
    con.first( () => { throw _.errAttend( 'str' ) });
    con.finally( function( err, got )
    {
      test.true( _.errIs( err ) );
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
    con.first( () => new _.Consequence().take( 'str' ));
    con.finally( function( err, got )
    {
      test.identical( err, undefined );
      test.identical( got, 'str' );
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
    con.first( () => new _.Consequence().error( 'str' ));
    con.finally( function( err, got )
    {
      test.true( _.strHas( String( err ), 'str' ) );
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
    var con2 = new _.Consequence({ tag : 'con2' }).take( 'str' );

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
      test.identical( got, 'str' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con2.resourcesGet(), [ { error : undefined, argument : 'str' } ] );
      return null;
    })

    return con;
  })

  /* */

  .then( function( arg )
  {
    test.case = 'passed consequence shares own resource with timeout';
    var con = new _.Consequence({ tag : 'con' });
    var con2 = _.time.out( context.t1*3, () => 'str' );
    var timeBefore = _.time.now();
    con.first( con2 );
    con.finally( function( err, got )
    {
      let delay = _.time.now() - timeBefore;
      var description = test.case = 'delay ' + delay;
      test.ge( delay, context.t1*3 - context.timeAccuracy );
      test.case = description;
      test.identical( err, undefined );
      test.identical( got, 'str' );
      test.identical( con.resourcesGet(), [] );
      test.identical( con2.resourcesGet(), [ { error : undefined, argument : 'str' } ] );
      return null;
    })
    return con;
  })

  // .finally( ( err, arg ) =>
  // {
  //   test.close( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 0' );
  //   _.Consequence.AsyncModeSet( amode );
  //   if( err )
  //   throw err;
  //   return arg;
  // })

  return ready;
}

// //
//
// function firstAsyncMode10( test )
// {
//   let context = this;
//   let amode = _.Consequence.AsyncModeGet();
//
//   let ready = new _.Consequence().take( null )
//
//   .finally( () =>
//   {
//     _.Consequence.AsyncModeSet([ 1, 0 ]);
//     test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );
//     return null;
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'simplest, empty routine';
//     var con = new _.Consequence({ tag : 'con', capacity : 2 });
//     con.first( () => null );
//     con.take( 'str' );
//     con.give( function( err, got )
//     {
//       test.identical( got, null );
//       test.identical( err, undefined );
//       test.identical( con.resourcesGet(), [ { error : undefined, argument : 'str' } ] );
//       return null;
//     })
//
//     return _.time.out( 1, function()
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesCount(), 1 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'routine returns something';
//     var con = new _.Consequence({ tag : 'con', capacity : 2 });
//     con.first( () => 'str' );
//     con.take( 'str' + 2 );
//     con.give( function( err, got )
//     {
//       test.identical( got, 'str' );
//       test.identical( err, undefined );
//     })
//
//     return _.time.out( 1, function()
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesGet(), [ { error : undefined, argument : 'str' + 2 } ] );
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'routine throws error';
//     var con = new _.Consequence({ tag : 'con' });
//     con.first( () => { throw _.errAttend( 'str' ) });
//     con.give( function( err, got )
//     {
//       test.true( _.errIs( err ) );
//       if( err )
//       _.errAttend( err );
//       test.identical( got, undefined );
//       test.identical( con.resourcesGet(), [] );
//     })
//
//     return _.time.out( 1, function()
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesCount(), 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'routine returns consequence with resource';
//     var con = new _.Consequence({ tag : 'con' });
//     con.first( () => new _.Consequence().take( 'str' ));
//     con.give( function( err, got )
//     {
//       test.identical( err, undefined );
//       test.identical( got, 'str' );
//     })
//
//     return _.time.out( 1, function()
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesCount(), 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'routine returns consequence with err resource';
//     var con = new _.Consequence({ tag : 'con' });
//     con.first( () => new _.Consequence().error( 'str' ));
//     con.give( function( err, got )
//     {
//       test.true( _.strHas( String( err ), 'str' ) );
//       test.identical( got, undefined );
//       test.identical( con.resourcesGet(), [] );
//     })
//     return _.time.out( 1, function()
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesCount(), 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'routine returns consequence that gives resource with timeout';
//     var con = new _.Consequence({ tag : 'con' });
//     var timeBefore = _.time.now();
//     con.first( () => _.time.out( context.t1*3, () => null ));
//     con.give( function( err, got )
//     {
//       let delay = _.time.now() - timeBefore;
//       var description = test.case = 'delay ' + delay;
//       test.ge( delay, context.t1*3 - context.timeAccuracy );
//       test.case = description;
//       test.identical( err, undefined );
//       test.identical( got, null );
//       test.identical( con.resourcesGet(), [] );
//     })
//     return _.time.out( context.t1*3+1, function()
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesCount(), 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'passed consequence shares own resource';
//     var con = new _.Consequence({ tag : 'con' });
//     var con2 = new _.Consequence({ tag : 'con2' }).take( 'str' );
//
//     test.identical( con.errorsCount(), 0 );
//     test.identical( con.argumentsCount(), 0 );
//     test.identical( con2.errorsCount(), 0 );
//     test.identical( con2.argumentsCount(), 1 );
//
//     con.first( con2 );
//
//     test.identical( con.errorsCount(), 0 );
//     test.identical( con.argumentsCount(), 0 );
//     test.identical( con2.errorsCount(), 0 );
//     test.identical( con2.argumentsCount(), 1 );
//
//     con.give( function( err, got )
//     {
//
//       test.identical( con.errorsCount(), 0 );
//       test.identical( con.argumentsCount(), 0 );
//       test.identical( con2.errorsCount(), 0 );
//       test.identical( con2.argumentsCount(), 1 );
//
//       test.identical( err, undefined );
//       test.identical( got, 'str' );
//       test.identical( con.resourcesGet(), [] );
//       test.identical( con2.resourcesGet(), [ { error : undefined, argument : 'str' } ] );
//
//     })
//     return _.time.out( 1, function()
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesCount(), 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'passed consequence shares own resource with timeout';
//     var con = new _.Consequence({ tag : 'con' });
//     var con2 = _.time.out( context.t1*3, () => 'str' );
//     var timeBefore = _.time.now();
//     con.first( con2 );
//     con.give( function( err, got )
//     {
//       let delay = _.time.now() - timeBefore;
//       var description = test.case = 'delay ' + delay;
//       test.ge( delay, context.t1*3 - context.timeAccuracy );
//       test.case = description;
//       test.identical( err, undefined );
//       test.identical( got, 'str' );
//       test.identical( con.resourcesGet(), [] );
//       test.identical( con2.resourcesGet(), [ { error : undefined, argument : 'str' } ] );
//     })
//     return _.time.out( context.t1*3+1, function()
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesCount(), 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .finally( ( err, arg ) =>
//   {
//     test.close( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 0' );
//
//     _.Consequence.AsyncModeSet( amode );
//
//
//     if( err )
//     throw err;
//     return arg;
//
//   })
//   return ready;
// }
//
// //
//
// function firstAsyncMode01( test )
// {
//   let context = this;
//   let amode = _.Consequence.AsyncModeGet();
//
//   let ready = new _.Consequence().take( null )
//
//   .tap( () =>
//   {
//     _.Consequence.AsyncModeSet([ 0, 1 ]);
//     test.open( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'simplest, empty routine';
//     var con = new _.Consequence({ tag : 'con', capacity : 2 });
//     con.give( function( err, got )
//     {
//       test.identical( err, undefined );
//       test.identical( got, null );
//     });
//
//     test.identical( con.resourcesCount(), 0 );
//     test.identical( con.competitorsCount(), 1 );
//
//     con.first( () => null );
//
//     test.identical( con.resourcesCount(), 1 );
//     test.identical( con.competitorsCount(), 1 );
//
//     con.take( 'str' );
//
//     test.identical( con.resourcesCount(), 2 );
//     test.identical( con.competitorsCount(), 1 );
//
//     return _.time.out( 1, function()
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesGet(), [ { error : undefined, argument : 'str' } ] );
//       return null;
//     });
//
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'routine returns something';
//     var con = new _.Consequence({ tag : 'con', capacity : 2 });
//     con.give( function( err, got )
//     {
//       test.identical( got, 'str' );
//       test.identical( err, undefined );
//     })
//     con.first( () => 'str' );
//
//     con.take( 'str' + 2 );
//
//     test.identical( con.resourcesCount(), 2 );
//     test.identical( con.competitorsCount(), 1 );
//
//     return _.time.out( 1, function()
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesGet(), [ { error : undefined, argument : 'str' + 2 } ] );
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'routine throws error';
//     var con = new _.Consequence({ tag : 'con' });
//
//     con.first( () => { throw _.errAttend( 'str' ) } );
//     test.identical( con.resourcesCount(), 1 );
//     test.identical( con.errorsCount(), 1 );
//     test.identical( con.argumentsCount(), 0 );
//
//     return _.time.out( 1, function()
//     {
//       test.identical( con.resourcesCount(), 1 );
//       con.give( function( err, got )
//       {
//         test.true( _.errIs( err ) );
//         if( err )
//         _.errAttend( err );
//         test.identical( got, undefined );
//       });
//     })
//     .then( function( arg )
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesCount(), 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'routine returns consequence with resource';
//     var con = new _.Consequence({ tag : 'con' });
//     con.first( () => new _.Consequence().take( 'str' ) );
//
//     test.identical( con.resourcesCount(), 1 );
//
//     return _.time.out( 1, function()
//     {
//       test.identical( con.resourcesCount(), 1 );
//
//       con.give( function( err, got )
//       {
//         test.identical( err, undefined );
//         test.identical( got, 'str' );
//       })
//       return null;
//     })
//     .then( function( arg )
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesCount(), 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'routine returns consequence with err resource';
//     var con = new _.Consequence({ tag : 'con' });
//     debugger;
//     con.first( () => new _.Consequence().error( 'str' ));
//
//     test.identical( con.resourcesCount(), 1 );
//
//     return _.time.out( 1, function()
//     {
//       test.identical( con.resourcesCount(), 1 );
//
//       con.give( function( err, got )
//       {
//         test.true( _.strHas( String( err ), 'str' ) );
//         _.errAttend( err );
//         test.identical( got, undefined );
//       })
//       return null;
//     })
//     .then( function( arg )
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesCount(), 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'routine returns consequence that gives resource with timeout';
//     var con = new _.Consequence({ tag : 'con' });
//     var timeBefore = _.time.now();
//     con.first( () => _.time.out( context.t1, () => null ));
//
//     test.identical( con.resourcesCount(), 0 );
//
//     return _.time.out( context.t1*3, function()
//     {
//       test.identical( con.resourcesCount(), 1 );
//
//       con.give( function( err, got )
//       {
//         let delay = _.time.now() - timeBefore;
//         var description = test.case = 'delay ' + delay;
//         test.ge( delay, context.t1*3 - context.timeAccuracy );
//         test.case = description;
//         test.identical( err, undefined );
//         test.identical( got, null );
//       })
//       return null;
//     })
//     .then( function( arg )
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesCount(), 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'passed consequence shares own resource';
//     var con = new _.Consequence({ tag : 'con' });
//     var con2 = new _.Consequence({ tag : 'con2' }).take( 'str' );
//
//     test.identical( con.errorsCount(), 0 );
//     test.identical( con.argumentsCount(), 0 );
//     test.identical( con2.errorsCount(), 0 );
//     test.identical( con2.argumentsCount(), 1 );
//
//     con.first( con2 );
//
//     test.identical( con.errorsCount(), 0 );
//     test.identical( con.argumentsCount(), 1 );
//     test.identical( con2.errorsCount(), 0 );
//     test.identical( con2.argumentsCount(), 1 );
//
//     return _.time.out( 1, function()
//     {
//
//       test.identical( con.errorsCount(), 0 );
//       test.identical( con.argumentsCount(), 1 );
//       test.identical( con2.errorsCount(), 0 );
//       test.identical( con2.argumentsCount(), 1 );
//
//       test.identical( con.resourcesCount(), 1 );
//
//       con.give( function( err, got )
//       {
//         test.identical( err, undefined );
//         test.identical( got, 'str' );
//       })
//       return null;
//     })
//     .then( function( arg )
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesCount(), 0 );
//       test.identical( con2.resourcesCount(), 1 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'passed consequence shares own resource with timeout';
//     var con = new _.Consequence({ tag : 'con' });
//     var con2 = _.time.out( context.t1, () => 'str' );
//     var timeBefore = _.time.now();
//     con.first( con2 );
//
//     return _.time.out( context.t1*3, function()
//     {
//       test.identical( con.resourcesCount(), 1 );
//
//       con.give( function( err, got )
//       {
//         let delay = _.time.now() - timeBefore;
//         var description = test.case = 'delay ' + delay;
//         test.ge( delay, context.t1*3 - context.timeAccuracy );
//         test.case = description;
//         test.identical( err, undefined );
//         test.identical( got, 'str' );
//       })
//       return null;
//     })
//     .then( function( arg )
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesCount(), 0 );
//       test.identical( con2.resourcesCount(), 1 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .finally( ( err, arg ) =>
//   {
//     test.close( 'AsyncCompetitorHanding : 0, AsyncResourceAdding : 1' );
//     _.Consequence.AsyncModeSet( amode );
//     if( err )
//     throw err;
//     return arg;
//   })
//
//   /* */
//
//   return ready;
// }
//
// //
//
// function firstAsyncMode11( test )
// {
//   let context = this;
//   let amode = _.Consequence.AsyncModeGet();
//
//   let ready = new _.Consequence().take( null )
//
//   .finally( () =>
//   {
//     _.Consequence.AsyncModeSet([ 1, 1 ]);
//     test.open( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );
//     return null;
//   })
//
//   .then( function( arg )
//   {
//     test.case = 'simplest, empty routine';
//     var con = new _.Consequence({ tag : 'con', capacity : 2 });
//     con.give( function( err, got )
//     {
//       test.identical( got, null );
//       test.identical( err, undefined );
//     });
//     con.first( () => null );
//     con.take( 'str' );
//
//     test.identical( con.argumentsCount(), 2 );
//     test.identical( con.errorsCount(), 0 );
//     test.identical( con.competitorsCount(), 1 );
//
//     return _.time.out( 1, function()
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesGet(), [ { error : undefined, argument : 'str' } ] );
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'routine returns something';
//     var con = new _.Consequence({ tag : 'con', capacity : 2 });
//     con.give( function( err, got )
//     {
//       test.identical( got, 'str' );
//       test.identical( err, undefined );
//     })
//     con.first( () => 'str' );
//
//     con.take( 'str' + 2 );
//
//     test.identical( con.argumentsCount(), 2 );
//     test.identical( con.errorsCount(), 0 );
//     test.identical( con.competitorsCount(), 1 );
//
//     return _.time.out( 1, function()
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.resourcesGet(), [ { error : undefined, argument : 'str' + 2 } ] );
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'routine throws error';
//     var con = new _.Consequence({ tag : 'con' });
//     con.first( () => { throw _.errAttend( 'str' ) });
//     con.give( function( err, got )
//     {
//       test.true( _.errIs( err ) );
//       if( err )
//       _.errAttend( err );
//       test.identical( got, undefined );
//     });
//
//     test.identical( con.argumentsCount(), 0 );
//     test.identical( con.errorsCount(), 0 );
//
//     return _.time.out( 1, function()
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.argumentsCount(), 0 );
//       test.identical( con.errorsCount(), 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'routine returns consequence with resource';
//     var con = new _.Consequence({ tag : 'con' });
//     con.first( () => new _.Consequence().take( 'str' ));
//     con.give( function( err, got )
//     {
//       test.identical( err, undefined );
//       test.identical( got, 'str' );
//     })
//     test.identical( con.argumentsCount(), 0 );
//     test.identical( con.errorsCount(), 0 );
//
//     return _.time.out( 1, function()
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.argumentsCount(), 0 );
//       test.identical( con.errorsCount(), 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'routine returns consequence with err resource';
//     var con = new _.Consequence({ tag : 'con' });
//     con.first( () => new _.Consequence().error( 'str' ));
//     con.give( function( err, got )
//     {
//       test.true( _.strHas( String( err ), 'str' ) );
//       test.identical( got, undefined );
//     })
//     test.identical( con.argumentsCount(), 0 );
//     test.identical( con.errorsCount(), 0 );
//
//     return _.time.out( 1, function()
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.argumentsCount(), 0 );
//       test.identical( con.errorsCount(), 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'routine returns consequence that gives resource with timeout';
//     var con = new _.Consequence({ tag : 'con' });
//     var timeBefore = _.time.now();
//     con.first( () => _.time.out( context.t1*3, () => null ));
//     con.give( function( err, got )
//     {
//       let delay = _.time.now() - timeBefore;
//       var description = test.case = 'delay ' + delay;
//       test.ge( delay, context.t1*3 - context.timeAccuracy );
//       test.case = description;
//       test.identical( err, undefined );
//       test.identical( got, null );
//     })
//     test.identical( con.argumentsCount(), 0 );
//     test.identical( con.errorsCount(), 0 );
//
//     return _.time.out( context.t1*3+1, function()
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.argumentsCount(), 0 );
//       test.identical( con.errorsCount(), 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'passed consequence shares own resource';
//     var con = new _.Consequence({ tag : 'con' });
//     var con2 = new _.Consequence({ tag : 'con2' }).take( 'str' );
//
//     test.identical( con.errorsCount(), 0 );
//     test.identical( con.argumentsCount(), 0 );
//     test.identical( con2.errorsCount(), 0 );
//     test.identical( con2.argumentsCount(), 1 );
//
//     con.first( con2 );
//
//     test.identical( con.errorsCount(), 0 );
//     test.identical( con.argumentsCount(), 0 );
//     test.identical( con2.errorsCount(), 0 );
//     test.identical( con2.argumentsCount(), 1 );
//
//     con.finally( function( err, got )
//     {
//
//       test.identical( con.errorsCount(), 0 );
//       test.identical( con.argumentsCount(), 0 );
//       test.identical( con2.errorsCount(), 0 );
//       test.identical( con2.argumentsCount(), 1 );
//
//       test.identical( err, undefined );
//       test.identical( got, 'str' );
//
//       return got;
//     });
//
//     return _.time.out( 5, function()
//     {
//
//       test.identical( con.errorsCount(), 0 );
//       test.identical( con.argumentsCount(), 1 );
//       test.identical( con2.errorsCount(), 0 );
//       test.identical( con2.argumentsCount(), 1 );
//
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.argumentsCount(), 1 );
//       test.identical( con.errorsCount(), 0 );
//       test.identical( con2.argumentsCount(), 1 );
//       test.identical( con2.errorsCount(), 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .then( function( arg )
//   {
//     test.case = 'passed consequence shares own resource with timeout';
//     var con = new _.Consequence({ tag : 'con' });
//     var con2 = _.time.out( context.t1*3, () => 'str' );
//     var timeBefore = _.time.now();
//     con.first( con2 );
//     con.give( function( err, got )
//     {
//       let delay = _.time.now() - timeBefore;
//       var description = test.case = 'delay ' + delay;
//       test.ge( delay, context.t1*3 - context.timeAccuracy );
//       test.case = description;
//       test.identical( err, undefined );
//       test.identical( got, 'str' );
//     })
//     return _.time.out( context.t1*3+1, function()
//     {
//       test.identical( con.competitorsCount(), 0 );
//       test.identical( con.argumentsCount(), 0 );
//       test.identical( con.errorsCount(), 0 );
//       test.identical( con2.argumentsCount(), 1 );
//       test.identical( con2.errorsCount(), 0 );
//       return null;
//     })
//   })
//
//   /* */
//
//   .finally( ( err, arg ) =>
//   {
//     test.close( 'AsyncCompetitorHanding : 1, AsyncResourceAdding : 1' );
//
//     _.Consequence.AsyncModeSet( amode );
//
//
//     if( err )
//     throw err;
//     return arg;
//
//   })
//   return ready;
// }

// --
// experimental
// --

function thenSequenceSync( test )
{
  test.case = 'consequences in then has resources';
  var con = new _.Consequence({ tag : 'con' }).take( 0 );
  var con1 = new _.Consequence({ tag : 'con1', capacity : 2 })
  .take( 1 );
  var con2 = new _.Consequence({ tag : 'con2', capacity : 3 })
  .take( 2 )
  .take( 3 );

  con.then( con1 )
  .then( con2 );
  test.identical( _.select( con.resourcesGet(), '*/argument' ), [ 0 ] );
  test.identical( _.select( con1.resourcesGet(), '*/argument' ), [ 1, 0 ] );
  test.identical( _.select( con2.resourcesGet(), '*/argument' ), [ 2, 3, 0 ] );

  /* */

  test.case = 'consequences in then has competitors';
  var sequence = [];
  var con = new _.Consequence({ tag : 'con' });
  var con1 = new _.Consequence({ tag : 'con1' })
  .then( comp1 );
  var con2 = new _.Consequence({ tag : 'con2' })
  .then( comp2 )
  .then( comp3 );

  con.then( con1 )
  .then( con2 );
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
  var con1 = new _.Consequence({ tag : 'con1' })
  .then( comp1 );
  var con2 = new _.Consequence({ tag : 'con2' })
  .then( comp2 )
  .then( comp3 );

  con.then( con1 )
  .then( con2 );
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

//

function thenDelayProcedure( test )
{
  let context = this;

  let ready = new _.Consequence().take( null );

  /* */

  ready.then( function thenDelay1( arg )
  {
    var result = [];
    var con = new _.Consequence({ tag : 'con' });

    con.thenDelay( context.t1 );

    test.identical( con.competitorsCount(), 1 );
    con.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'thenDelay1' ) );
    })

    con.take( null );

    return _.time.out( context.t1 * 3 );
  })

  return ready;
}

//

function finallyDelayProcedure( test )
{
  let context = this;

  let ready = new _.Consequence().take( null );

  /* */

  ready.then( function finallyDelay1( arg )
  {
    var result = [];
    var con = new _.Consequence({ tag : 'con' });

    con.finallyDelay( context.t1 );

    test.identical( con.competitorsCount(), 1 );
    con.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'finallyDelay1' ) );
    })

    con.take( null );

    return _.time.out( context.t1 * 3 );
  })

  return ready;
}

//

function exceptDelayProcedure( test )
{
  let context = this;

  let ready = new _.Consequence().take( null );

  /* */

  ready.then( function exceptDelay1( arg )
  {
    var result = [];
    var con = new _.Consequence({ tag : 'con' });

    con.exceptDelay( context.t1 );

    test.identical( con.competitorsCount(), 1 );
    con.competitorsGet().forEach( ( competitor ) =>
    {
      test.true( !_.strHas( competitor.procedure._sourcePath, 'Routine.s' ) );
      test.true( _.strHas( competitor.procedure._sourcePath, 'exceptDelay1' ) );
    })

    con.take( null );

    return _.time.out( context.t1 * 3 );
  })

  return ready;
}


//

function bugFromProcessExperiment( test )
{
  let context = this;
  let con = _.take( null );

  con.then( () =>
  {
    let ready = new _.Consequence().take( null );

    console.log( ready );
    ready.delay( context.t3 );
    console.log( ready );
    ready.thenGive( ( arg ) => ready.take( arg ) );

    let got = ready;
    test.identical( got.toStr(), 'Consequence:: 0 / 1' );
    return ready;
  })

  con.then( ( op ) =>
  {
    let ready = new _.Consequence().take( null );

    console.log( ready );
    ready.delay( context.t3 );
    console.log( ready );
    ready.thenGive( ( arg ) => ready.take( arg ) );

    let got = ready.deasync();
    test.identical( got.toStr(), 'Consequence:: 1 / 0' );
    return ready;
  })

  return con;
}

bugFromProcessExperiment.experimental = 1;

//

function bugFromProcessExperimentReversed( test )
{
  let context = this;
  let con = _.take( null );

  con.then( ( op ) =>
  {
    let ready = new _.Consequence().take( null );

    console.log( ready );
    ready.delay( context.t3 );
    console.log( ready );
    ready.thenGive( ( arg ) => ready.take( arg ) );

    let got = ready.deasync();
    test.identical( got.toStr(), 'Consequence:: 1 / 0' );
    return ready;
  });

  con.then( () =>
  {
    let ready = new _.Consequence().take( null );

    console.log( ready );
    ready.delay( context.t3 );
    console.log( ready );
    ready.thenGive( ( arg ) => ready.take( arg ) );

    let got = ready;
    test.identical( got.toStr(), 'Consequence:: 0 / 1' );
    return ready;
  });

  return con;
}

bugFromProcessExperimentReversed.experimental = 1;

//

function bugFromProcessExperimentWithoutDeasync( test )
{
  let context = this;
  let con = _.take( null );

  con.then( ( op ) =>
  {
    let ready = new _.Consequence().take( null );

    console.log( ready );
    ready.delay( context.t3 );
    console.log( ready );
    ready.thenGive( ( arg ) => ready.take( arg ) );

    let got = ready;
    test.identical( got.toStr(), 'Consequence:: 0 / 1' );
    return ready;
  });

  con.then( () =>
  {
    let ready = new _.Consequence().take( null );

    console.log( ready );
    ready.delay( context.t3 );
    console.log( ready );
    ready.thenGive( ( arg ) => ready.take( arg ) );

    let got = ready;
    test.identical( got.toStr(), 'Consequence:: 0 / 1' );
    return ready;
  });

  return con;
}

bugFromProcessExperimentWithoutDeasync.experimental = 1;

//

function bugFromProcessExperimentWithDeasync( test )
{
  let context = this;
  let con = _.take( null );

  con.then( ( op ) =>
  {
    let ready = new _.Consequence().take( null );

    console.log( ready );
    ready.delay( context.t3 );
    console.log( ready );
    ready.thenGive( ( arg ) => ready.take( arg ) );

    let got = ready.deasync();
    test.identical( got.toStr(), 'Consequence:: 1 / 0' );
    return ready;
  });

  con.then( () =>
  {
    let ready = new _.Consequence().take( null );

    console.log( ready );
    ready.delay( context.t3 );
    console.log( ready );
    ready.thenGive( ( arg ) => ready.take( arg ) );

    let got = ready.deasync();
    test.identical( got.toStr(), 'Consequence:: 1 / 0' );
    return ready;
  });

  return con;
}

bugFromProcessExperimentWithDeasync.experimental = 1;

//

function bugFromProcessParallelExperiment( test )
{
  let context = this;
  let con1 = _.take( null );
  let con2 = _.take( null );

  con1.then( () =>
  {
    let ready = new _.Consequence().take( null );

    console.log( ready );
    ready.delay( context.t3 );
    console.log( ready );
    ready.thenGive( ( arg ) => ready.take( arg ) );

    let got = ready;
    test.identical( got.toStr(), 'Consequence:: 0 / 1' );
    return ready;
  })

  con2.then( () =>
  {
    let ready = new _.Consequence().take( null );

    console.log( ready );
    ready.delay( context.t3 );
    console.log( ready );
    ready.thenGive( ( arg ) => ready.take( arg ) );

    let got = ready.deasync();
    test.identical( got.toStr(), 'Consequence:: 1 / 0' );
    return ready;
  })

  return _.Consequence.And( con1, con2 );
}

bugFromProcessParallelExperiment.experimental = 1;

// --
// declare
// --

const Proto =
{

  name : 'Tools.consequence.Basic',
  silencing : 1,
  routineTimeOut : 30000,

  context :
  {
    timeAccuracy : 1,
    t1 : 100,
    t2 : 500,
    t3 : 2500,
  },

  tests :
  {

    // inter

    consequenceIs,
    consequenceLike,
    clone,

    // from

    fromAsyncMode00,
    // fromAsyncMode10,
    // fromAsyncMode01,
    // fromAsyncMode11,

    fromPromiseWithUndefined,
    fromCustomPromise,
    consequenceAwait,

    // export

    toStr,
    stringify,

    // take

    ordinarResourceAsyncMode00,
    // ordinarResourceAsyncMode10,
    // ordinarResourceAsyncMode01,
    // ordinarResourceAsyncMode11,

    takeAll,

    finallyPromiseGiveAsyncMode00,
    // finallyPromiseGiveAsyncMode10,
    // finallyPromiseGiveAsyncMode01,
    // finallyPromiseGiveAsyncMode11,

    _finallyAsyncMode00,
    // _finallyAsyncMode10,
    // _finallyAsyncMode01,
    // _finallyAsyncMode11,

    finallyPromiseKeepAsyncMode00,
    // finallyPromiseKeepAsyncMode10,
    // finallyPromiseKeepAsyncMode01,
    // finallyPromiseKeepAsyncMode11,

    // etc

    trivial,
    fields,

    deasync,

    split,
    tap,
    tapHandling,

    catchTestRoutine,
    thenGiveTrivial,
    thenGiveThrowing,
    keep,
    notDeadLock1,

    // time

    timeOut,

    timeLimitProcedure,
    timeLimitSplitProcedure,
    timeLimitErrorProcedure,
    timeLimitErrorSplitProcedure,
    TimeLimitProcedure,
    TimeLimitErrorProcedure,

    timeLimitSplit,
    timeLimitErrorSplit,
    timeLimitConsequence,
    timeLimitRoutine,
    timeLimitErrorRoutine,
    timeLimitErrorConsequence,

    // procedure

    procedureBasic,
    procedureThenKeepCallback,
    procedureForConsequence,
    procedureStatesThenKeep,
    procedureStatesTap,
    procedureOff,
    procedureOffOn,

    // and

    andTakeProcedure,
    andKeepProcedure,
    andKeepAccumulativeProcedure,
    andImmediateProcedure,
    AndTakeProcedure,
    AndKeepProcedure,
    AndImmediateProcedure,

    andTake,
    andTakeExtended,
    andTakeWithPromise,
    andTakeWithPromiseAndConsequence,
    andTakeWithMixedCompetitors,
    andTakeWithSeveralIdenticalCompetitors,

    andNotDeadLock,
    andConcurrent,
    andKeepRoutinesTakeFirst,
    andKeepRoutinesTakeLast,
    andKeepRoutinesDelayed,
    andKeepDuplicates,
    andKeepInstant,
    andKeep,
    andKeepExtended,
    andKeepWithPromise,
    andKeepWithPromiseAndConsequence,
    andKeepWithMixedCompetitors,
    andKeepWithSeveralIdenticalCompetitors,
    andKeepAccumulative,
    andKeepAccumulativeNonConsequence,

    andImmediate,
    andImmediateWithPromise,
    andImmediateWithPromiseAndConsequence,
    andImmediateWithMixedCompetitors,
    andImmediateWithSeveralIdenticalCompetitors,

    alsoKeepTrivialSyncBefore,
    alsoKeepTrivialSyncAfter,
    alsoKeepTrivialAsync,
    alsoKeep,
    alsoKeepExtended,
    alsoKeepThrowingBeforeSync,
    alsoKeepThrowingAfterSync,
    alsoKeepThrowingBeforeAsync,
    alsoKeepThrowingAfterAsync,
    alsoImmediate,

    // And

    _and,
    AndTake, /* aaa2 : implement very similar test for routine andTake, alsoTake */ /* Dmytro : implemented */
    AndTakeWithPromise,
    AndTakeWithPromiseAndConsequence,
    AndTakeWithMixedCompetitors,
    AndTakeWithSeveralIdenticalCompetitors,

    AndKeep, /* aaa2 : implement very similar test for routine andKeep, alsoKeep */ /* Dmytro : implemented */
    And,
    AndWithPromise,
    AndWithPromiseAndConsequence,
    AndWithMixedCompetitors,
    AndWithSeveralIdenticalCompetitors,
    AndUncaughtError,

    AndImmediate, /* aaa2 : implement very similar test for routine andImmediate, alsoImmediate */ /* Dmytro : implemented */
    AndImmediateWithPromise,
    AndImmediateWithPromiseAndConsequence,
    AndImmediateWithMixedCompetitors,
    AndImmediateWithSeveralIdenticalCompetitors,

    // or

    orKeepingWithSimple,
    orKeepingWithLater,
    orKeepingWithNow,
    orKeepingWithPromises,
    orKeepingCheckProcedureSourcePath,
    orTakingWithSimple,
    orTakingWithLater,
    orTakingWithNow,
    orTakingWithPromises,
    orTakingCheckProcedureSourcePath,
    orKeepingSplitCanceled,
    orKeepingSplitCanceledProcedure,
    orKeepingCanceled,

    afterOrKeepingNotFiring,
    afterOrKeepingWithSimple,
    afterOrKeepingWithLater,
    afterOrKeepingWithTwoTake0,
    afterOrKeepingWithPromises,
    afterOrKeepingCheckProcedureSourcePath,
    afterOrTakingWithSimple,
    afterOrTakingWithLater,
    afterOrTakingWithTwoTake0,
    afterOrTakingWithPromises,
    afterOrTakingCheckProcedureSourcePath,

    OrKeep,
    OrTake,
    Or,

    OrTakeProcedure,
    OrKeepProcedure,

    // resource handling

    take,
    takeInToolsNamespace,
    takeSymbolInErrorChanel,

    // competitor

    competitorOwn,
    competitorsCount,

    competitorsCancelSingle,
    competitorsCancel,
    competitorsCancel2,

    // resources

    argumentsCount,
    errorsCount,
    resourcesCount,

    // advanced

    put,

    putKeepProcedure,
    putGiveProcedure,
    thenPutGiveProcedure,
    thenPutKeepProcedure,

    firstAsyncMode00,
    // firstAsyncMode10,
    // firstAsyncMode01,
    // firstAsyncMode11,

    // experimental

    thenSequenceSync,
    // thenSequenceAsync,

    thenDelayProcedure,
    finallyDelayProcedure,
    exceptDelayProcedure,

    // experiment,

    bugFromProcessExperiment,
    bugFromProcessExperimentReversed,
    bugFromProcessExperimentWithoutDeasync,
    bugFromProcessExperimentWithDeasync,
    bugFromProcessParallelExperiment,

  },

};

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();

