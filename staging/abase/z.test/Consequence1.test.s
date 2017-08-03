( function _Consequence1_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  //if( typeof wBase === 'undefined' )
  try
  {
    require( '../../abase/wTools.s' );
  }
  catch( err )
  {
    require( 'wTools' );
  }

  var _ = wTools;

  _.include( 'wTesting' );

}

var _ = wTools;

// --
// test
// --

function simple( test )
{
  var self = this;

  test.description = 'class checks'; //

  test.shouldBe( _.routineIs( wConsequence.prototype.passThru ) );
  test.shouldBe( _.routineIs( wConsequence.passThru ) );
  test.shouldBe( _.objectIs( wConsequence.prototype.KindOfArguments ) );
  test.shouldBe( _.objectIs( wConsequence.KindOfArguments ) );
  test.shouldBe( wConsequence.name === 'wConsequence' );
  test.shouldBe( wConsequence.nameShort === 'Consequence' );

  test.description = 'construction'; //

  debugger;
  var con1 = new wConsequence().give( 1 );
  var con2 = wConsequence().give( 2 );
  var con3 = con2.clone();

  test.identical( con1.messagesGet().length,1 );
  test.identical( con2.messagesGet().length,1 );
  test.identical( con3.messagesGet().length,1 );

  test.description = 'class test'; //

  test.shouldBe( _.consequenceIs( con1 ) );
  test.shouldBe( con1 instanceof wConsequence );
  test.shouldBe( _.consequenceIs( con2 ) );
  test.shouldBe( con2 instanceof wConsequence );
  test.shouldBe( _.consequenceIs( con3 ) );
  test.shouldBe( con3 instanceof wConsequence );

  con3.give( 3 );
  con3( 4 );
  con3( 5 );

  con3.got( ( err,arg ) => test.identical( arg,2 ) );
  con3.got( ( err,arg ) => test.identical( arg,3 ) );
  con3.got( ( err,arg ) => test.identical( arg,4 ) );
  con3.doThen( ( err,arg ) => test.identical( con3.messagesGet().length,0 ) );

  return con3;
}

//

// function ordinarMessage( test )
// {
//   var self = this;
//
//   var samples =
//   [
//
//     {
//       giveMethod : 'give',
//       argIndex : 1,
//       anotherIndex : 0,
//       anotherValue : null,
//     },
//
//     {
//       giveMethod : 'error',
//       argIndex : 0,
//       anotherIndex : 1,
//       anotherValue : undefined,
//     },
//
//   ];
//
//   //
//
//   for( var s = 0 ; s < samples.length ; s++ )
//   {
//     var sample = samples[ s ];
//
//     test.description = sample.giveMethod;
//
//     /**/
//
//     var con = new wConsequence();
//
//     con.got( function( err,data )
//     {
//
//       test.identical( arguments[ sample.argIndex ],1 );
//       test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );
//
//     });
//
//     con.got( function( err,data )
//     {
//
//       test.identical( arguments[ sample.argIndex ],2 );
//       test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );
//
//     });
//
//     con[ sample.giveMethod ]( 1 );
//     con[ sample.giveMethod ]( 2 );
//     con[ sample.giveMethod ]( 3 );
//     con[ sample.giveMethod ]( 4 );
//
//     con.got( function( err,data )
//     {
//
//       test.identical( arguments[ sample.argIndex ],3 );
//       test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );
//
//     });
//
//     con.got( function( err,data )
//     {
//
//       test.identical( arguments[ sample.argIndex ],4 );
//       test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );
//
//     });
//
//     con.got( function( err,data )
//     {
//
//       test.identical( arguments[ sample.argIndex ],5 );
//       test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );
//
//     });
//
//     con.got( function( err,data )
//     {
//
//       test.identical( arguments[ sample.argIndex ],6 );
//       test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );
//
//     });
//
//     con[ sample.giveMethod ]( 5 );
//     con[ sample.giveMethod ]( 6 );
//
//     /**/
//
//     var con = new wConsequence();
//
//     con[ sample.giveMethod ]( 1 );
//     con[ sample.giveMethod ]( 2 );
//
//     con.got( function( err,data )
//     {
//
//       test.identical( arguments[ sample.argIndex ],1 );
//       test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );
//
//     });
//
//     con.got( function( err,data )
//     {
//
//       test.identical( arguments[ sample.argIndex ],2 );
//       test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );
//
//     });
//
//     con.got( function( err,data )
//     {
//
//       test.identical( arguments[ sample.argIndex ],3 );
//       test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );
//
//     });
//
//     con.got( function( err,data )
//     {
//
//       test.identical( arguments[ sample.argIndex ],4 );
//       test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );
//
//     });
//
//     con[ sample.giveMethod ]( 3 );
//     con[ sample.giveMethod ]( 4 );
//     con[ sample.giveMethod ]( 5 );
//     con[ sample.giveMethod ]( 6 );
//
//     con.got( function( err,data )
//     {
//
//       test.identical( arguments[ sample.argIndex ],5 );
//       test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );
//
//     });
//
//     con.got( function( err,data )
//     {
//
//       test.identical( arguments[ sample.argIndex ],6 );
//       test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );
//
//     });
//
//   }
//
// }

//

// function persistantMessage( test )
// {
//   var self = this;
//
//   var samples =
//   [
//
//     {
//       giveMethod : { give : 'give' },
//       argIndex : 1,
//       anotherIndex : 0,
//       anotherValue : null,
//     },
//
//     {
//       giveMethod : { error : 'error' },
//       argIndex : 0,
//       anotherIndex : 1,
//       anotherValue : undefined,
//     },
//
//   ];
//
//   //
//
//   for( var s = 0 ; s < samples.length ; s++ )
//   {
//     var sample = samples[ s ];
//
//     sample.giveMethod = _.nameUnfielded( sample.giveMethod ).coded;
//
//     /**/
//
//     var con = new wConsequence();
//
//     con.persist( ( function(){ var first = 1; return function( err,data )
//     {
//
//       test.description = 'first message got with persist';
//       test.identical( arguments[ sample.argIndex ],first );
//       test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );
//       //test.identical( arguments[ sample.argIndex ] !== 3,true );
//       first += 1;
//
//     }}()) );
//
//     con[ sample.giveMethod ]( 1 );
//     con[ sample.giveMethod ]( 2 );
//     con.correspondentsCancel();
//
//     /**/
//
//     var got8 = 0;
//
//     con.persist( ( function(){ var first = 3; return function( err,data )
//     {
//
//       test.description = 'second message got with persist';
//       test.identical( arguments[ sample.argIndex ],first );
//       test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );
//       first += 1;
//
//       if( arguments[ sample.argIndex ] === 8 )
//       got8 += 1;
//
//     }}()) );
//
//     con.persist( ( function(){ var first = 3; return function( err,data )
//     {
//
//       test.description = 'third message got with persist';
//       test.identical( arguments[ sample.argIndex ],first );
//       test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );
//       first += 1;
//
//       if( arguments[ sample.argIndex ] === 8 )
//       got8 += 1;
//
//     }}()) );
//
//     con[ sample.giveMethod ]( 3 );
//     con[ sample.giveMethod ]( 4 );
//     con[ sample.giveMethod ]( 5 );
//     con[ sample.giveMethod ]( 6 );
//
//     con.persist( ( function(){ var first = 7; return function( err,data )
//     {
//
//       test.description = 'got many messages with persist';
//       test.identical( arguments[ sample.argIndex ],first );
//       test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );
//       first += 1;
//
//       if( arguments[ sample.argIndex ] === 8 )
//       got8 += 1;
//
//     }}()) );
//
//     con[ sample.giveMethod ]( 7 );
//     con[ sample.giveMethod ]( 8 );
//
//     test.identical( got8,3 );
//
//     /**/
//
//     var got2 = 0;
//     var con = new wConsequence();
//
//     con[ sample.giveMethod ]( 1 );
//     con[ sample.giveMethod ]( 2 );
//
//     con.persist( ( function(){ var first = 1; return function( err,data )
//     {
//
//       test.description = 'got two messages with persist';
//       test.identical( arguments[ sample.argIndex ],first );
//       test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );
//       first += 1;
//
//       if( arguments[ sample.argIndex ] === 2 )
//       got2 += 1;
//
//     }}()) );
//
//     con.persist( ( function(){ var first = 7; return function( err,data )
//     {
//
//       test.description = 'should never happened';
//       test.identical( false,true );
//
//     }}()) );
//
//     _.timeOut( 25, function()
//     {
//       test.description = 'got one only messages';
//       test.identical( got2,1 );
//     });
//
//   }
//
// }

//

// function then( test )
// {
//   var self = this;
//
//   var samples =
//   [
//
//     {
//       giveMethod : { give : 'give' },
//       argIndex : 1,
//       anotherIndex : 0,
//       anotherValue : null,
//     },
//
//     {
//       giveMethod : { error : 'error' },
//       argIndex : 0,
//       anotherIndex : 1,
//       anotherValue : undefined,
//     },
//
//   ];
//
//   //
//
//   for( var s = 0 ; s < samples.length ; s++ )
//   {
//     var sample = samples[ s ];
//
//     var con = new wConsequence();
//     var counter = 0;
//
//     con.doThen( function()
//     {
//
//       test.identical( counter,0 );
//       counter = 2;
//
//     });
//
//     test.identical( counter,0 );
//     con.give();
//
//     con.got( function()
//     {
//
//       test.identical( counter,2 );
//       counter = 4;
//
//     });
//
//     con.doThen( function()
//     {
//
//       test.identical( counter,4 );
//       counter = 6;
//
//     });
//
//     con.doThen( function()
//     {
//
//       test.identical( counter,6 );
//       counter = 8;
//
//     });
//
//     test.identical( counter,4 );
//     con.give();
//     test.identical( counter,8 );
//
//   }
//
// }

//

function andThen( test )
{
  var con1 = new wConsequence();
  var con2 = new wConsequence();

  var gotCounter = 0;
  function shouldGotData( expected )
  {

    return function( err,data )
    {

      gotCounter += 1;
      test.identical( err,null );
      test.identical( data,expected );

    }

  }

  //

  test.description = 'andThen should take over';

  con1.give( 1 );
  con1.got( shouldGotData( 1 ) );
  con1.got( shouldGotData( 2 ) );

  con2.andThen( con1 );
  con2.got( shouldGotData( '4b' ) );

  con1.got( shouldGotData( 3 ) ); // got 4a
  con1.got( shouldGotData( '4a' ) ); // got 3
  con1.give( 2 );
  con1.give( 3 );
  con1.give( '4a' );

  con2.give( '4b' );

}

// --
// test part 2
// --

// function ordinarMessage( test )
// {
//   var self = this;
//
//   var samples =
//   [
//
//     {
//       giveMethod : { give : 'give' },
//       gotArgument : 1,
//       anotherArgument : 0,
//       anotherArgumentValue : null,
//     },
//
//     {
//       giveMethod : { error : 'error' },
//       gotArgument : 0,
//       anotherArgument : 1,
//       anotherArgumentValue : undefined,
//     },
//
//   ];
//
//
//   //
//
//   for( var s = 0 ; s < samples.length ; s++ )
//   {
//     var sample = samples[ s ];
//
//     sample.giveMethod = _.nameUnfielded( sample.giveMethod ).coded;
//
//     /**/
//
//     var con = new wConsequence();
//
//     con.got( function( err,data )
//     {
//
//       test.identical( arguments[ sample.gotArgument ],1 );
//       test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );
//
//     });
//
//     con.got( function( err,data )
//     {
//
//       test.identical( arguments[ sample.gotArgument ],2 );
//       test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );
//
//     });
//
//     con[ sample.giveMethod ]( 1 );
//     con[ sample.giveMethod ]( 2 );
//     con[ sample.giveMethod ]( 3 );
//     con[ sample.giveMethod ]( 4 );
//
//     con.got( function( err,data )
//     {
//
//       test.identical( arguments[ sample.gotArgument ],3 );
//       test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );
//
//     });
//
//     con.got( function( err,data )
//     {
//
//       test.identical( arguments[ sample.gotArgument ],4 );
//       test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );
//
//     });
//
//     con.got( function( err,data )
//     {
//
//       test.identical( arguments[ sample.gotArgument ],5 );
//       test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );
//
//     });
//
//     con.got( function( err,data )
//     {
//
//       test.identical( arguments[ sample.gotArgument ],6 );
//       test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );
//
//     });
//
//     con[ sample.giveMethod ]( 5 );
//     con[ sample.giveMethod ]( 6 );
//
//     /**/
//
//     var con = new wConsequence();
//
//     con[ sample.giveMethod ]( 1 );
//     con[ sample.giveMethod ]( 2 );
//
//     con.got( function( err,data )
//     {
//
//       test.identical( arguments[ sample.gotArgument ],1 );
//       test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );
//
//     });
//
//     con.got( function( err,data )
//     {
//
//       test.identical( arguments[ sample.gotArgument ],2 );
//       test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );
//
//     });
//
//     con.got( function( err,data )
//     {
//
//       test.identical( arguments[ sample.gotArgument ],3 );
//       test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );
//
//     });
//
//     con.got( function( err,data )
//     {
//
//       test.identical( arguments[ sample.gotArgument ],4 );
//       test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );
//
//     });
//
//     con[ sample.giveMethod ]( 3 );
//     con[ sample.giveMethod ]( 4 );
//     con[ sample.giveMethod ]( 5 );
//     con[ sample.giveMethod ]( 6 );
//
//     con.got( function( err,data )
//     {
//
//       test.identical( arguments[ sample.gotArgument ],5 );
//       test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );
//
//     });
//
//     con.got( function( err,data )
//     {
//
//       test.identical( arguments[ sample.gotArgument ],6 );
//       test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );
//
//     });
//
//   }
//
// }

//

function ordinarMessage( test )
{
  var setAsync = function( taking, giving )
  {
    wConsequence.prototype.asyncTaking = taking;
    wConsequence.prototype.asyncGiving = giving;
  }

  test.description = 'give single message'

  var testCon = new wConsequence().give()

   /* asyncTaking : 0, asyncGiving : 0 */

  .doThen( () => setAsync( 0, 0 ) )
  .doThen( function ()
  {
    var con = new wConsequence();
    con.give( 1 );
    test.identical( con.messagesGet().length, 1 );
    con.got( function ( err, got )
    {
      test.identical( err, null )
      test.identical( got, 1 );
    })
    test.identical( con.messagesGet().length, 0 );
    test.identical( con.correspondentsGet().length, 0 );
  })

  /* asyncTaking : 1, asyncGiving : 0 */

  .doThen( () => setAsync( 1, 0 ) )
  .doThen( function ()
  {
    var con = new wConsequence();
    con.give( 1 );
    test.identical( con.messagesGet().length, 1 );
    con.got( function ( err, got )
    {
      test.identical( err, null )
      test.identical( got, 1 );
    })
    test.identical( con.messagesGet().length, 1 );
    test.identical( con.correspondentsGet().length, 1 );
    return _.timeOut( 1, function ()
    {
      test.identical( con.messagesGet().length, 0 );
      test.identical( con.correspondentsGet().length, 0 );
    })
  })

  /* asyncTaking : 0, asyncGiving : 1 */

  .doThen( () => setAsync( 0, 1 ) )
  .doThen( function ()
  {
    var con = new wConsequence();
    con.give( 1 );
    con.got( function ( err, got )
    {
      test.identical( err, null )
      test.identical( got, 1 );
    })
    test.identical( con.messagesGet().length, 1 );
    test.identical( con.correspondentsGet().length, 1 );
    return _.timeOut( 1, function ()
    {
      test.identical( con.messagesGet().length, 0 );
      test.identical( con.correspondentsGet().length, 0 );
    })
  })

  /* asyncTaking : 1, asyncGiving : 1 */

  .doThen( () => setAsync( 1, 1 ) )
  .doThen( function ()
  {
    var con = new wConsequence();
    con.give( 1 );
    con.got( function ( err, got )
    {
      test.identical( err, null )
      test.identical( got, 1 );
    })
    test.identical( con.messagesGet().length, 1 );
    test.identical( con.correspondentsGet().length, 1 );
    return _.timeOut( 1, function ()
    {
      test.identical( con.messagesGet().length, 0 );
      test.identical( con.correspondentsGet().length, 0 );
    })
  });

  test.description = 'give several messages';

  /* asyncTaking : 0, asyncGiving : 0 */

  testCon.doThen( () => setAsync( 0, 0 ) )
  .doThen( function ()
  {
    var con = new wConsequence();
    con.give( 1 ).give( 2 ).give( 3 );
    test.identical( con.messagesGet().length, 3 );
    con.got( ( err, got ) => test.identical( got, 1 ) );
    con.got( ( err, got ) => test.identical( got, 2 ) );
    con.got( ( err, got ) => test.identical( got, 3 ) );
    test.identical( con.correspondentsGet().length, 0 );
    test.identical( con.messagesGet().length, 0 );
  })

  /* asyncTaking : 1, asyncGiving : 0 */

  testCon.doThen( () => setAsync( 1, 0 ) )
  .doThen( function ()
  {
    var con = new wConsequence();
    con.give( 1 ).give( 2 ).give( 3 );
    con.got( ( err, got ) => test.identical( got, 1 ) );
    con.got( ( err, got ) => test.identical( got, 2 ) );
    con.got( ( err, got ) => test.identical( got, 3 ) );
    test.identical( con.correspondentsGet().length, 3 );
    test.identical( con.messagesGet().length, 3 );
    return _.timeOut( 1, function ()
    {
      test.identical( con.correspondentsGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
    })
  })

  /* asyncTaking : 0, asyncGiving : 1 */

  testCon.doThen( () => setAsync( 0, 1 ) )
  .doThen( function ()
  {
    var con = new wConsequence();
    con.give( 1 ).give( 2 ).give( 3 );
    con.got( ( err, got ) => test.identical( got, 1 ) );
    con.got( ( err, got ) => test.identical( got, 2 ) );
    con.got( ( err, got ) => test.identical( got, 3 ) );
    test.identical( con.correspondentsGet().length, 3 );
    test.identical( con.messagesGet().length, 3 );
    return _.timeOut( 1, function ()
    {
      test.identical( con.correspondentsGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
    })
  })

  /* asyncTaking : 1, asyncGiving : 1 */

  testCon.doThen( () => setAsync( 1, 1 ) )
  .doThen( function ()
  {
    var con = new wConsequence();
    con.give( 1 ).give( 2 ).give( 3 );
    con.got( ( err, got ) => test.identical( got, 1 ) );
    con.got( ( err, got ) => test.identical( got, 2 ) );
    con.got( ( err, got ) => test.identical( got, 3 ) );
    test.identical( con.correspondentsGet().length, 3 );
    test.identical( con.messagesGet().length, 3 );
    return _.timeOut( 1, function ()
    {
      test.identical( con.correspondentsGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
    })
  });

  test.description = 'give single error';

  /* asyncTaking : 0, asyncGiving : 0 */

  testCon.doThen( () => setAsync( 0, 0 ) )
  .doThen( function ()
  {
    var con = new wConsequence();
    con.error( 'err' );
    test.identical( con.messagesGet().length, 1 );
    con.got( function ( err, got )
    {
      test.identical( err, 'err' )
      test.identical( got, undefined );
    })
    test.identical( con.messagesGet().length, 0 );
    test.identical( con.correspondentsGet().length, 0 );
  })

  /* asyncTaking : 1, asyncGiving : 0 */

  .doThen( () => setAsync( 1, 0 ) )
  .doThen( function ()
  {
    var con = new wConsequence();
    con.error( 'err' );
    test.identical( con.messagesGet().length, 1 );
    con.got( function ( err, got )
    {
      test.identical( err, 'err' )
      test.identical( got, undefined );
    })
    test.identical( con.messagesGet().length, 1 );
    test.identical( con.correspondentsGet().length, 1 );
    return _.timeOut( 1, function ()
    {
      test.identical( con.messagesGet().length, 0 );
      test.identical( con.correspondentsGet().length, 0 );
    })
  })

  /* asyncTaking : 0, asyncGiving : 1 */

  .doThen( () => setAsync( 0, 1 ) )
  .doThen( function ()
  {
    var con = new wConsequence();
    con.error( 'err' );
    con.got( function ( err, got )
    {
      test.identical( err, 'err' )
      test.identical( got, undefined );
    })
    test.identical( con.messagesGet().length, 1 );
    test.identical( con.correspondentsGet().length, 1 );
    return _.timeOut( 1, function ()
    {
      test.identical( con.messagesGet().length, 0 );
      test.identical( con.correspondentsGet().length, 0 );
    })
  })

  /* asyncTaking : 1, asyncGiving : 1 */

  .doThen( () => setAsync( 1, 1 ) )
  .doThen( function ()
  {
    var con = new wConsequence();
    con.error( 'err' );
    con.got( function ( err, got )
    {
      test.identical( err, 'err' )
      test.identical( got, undefined );
    })
    test.identical( con.messagesGet().length, 1 );
    test.identical( con.correspondentsGet().length, 1 );
    return _.timeOut( 1, function ()
    {
      test.identical( con.messagesGet().length, 0 );
      test.identical( con.correspondentsGet().length, 0 );
    })
  });

  test.description = 'give several error messages';

  /* asyncTaking : 0, asyncGiving : 0 */

  testCon.doThen( () => setAsync( 0, 0 ) )
  .doThen( function ()
  {
    var con = new wConsequence();
    con.error( 'err1' ).error( 'err2' ).error( 'err3' );
    test.identical( con.messagesGet().length, 3 );
    con.got( ( err, got ) => test.identical( err, 'err1' ) );
    con.got( ( err, got ) => test.identical( err, 'err2' ) );
    con.got( ( err, got ) => test.identical( err, 'err3' ) );
    test.identical( con.correspondentsGet().length, 0 );
    test.identical( con.messagesGet().length, 0 );
  })

  /* asyncTaking : 1, asyncGiving : 0 */

  testCon.doThen( () => setAsync( 1, 0 ) )
  .doThen( function ()
  {
    var con = new wConsequence();
    con.error( 'err1' ).error( 'err2' ).error( 'err3' );
    con.got( ( err, got ) => test.identical( err, 'err1' ) );
    con.got( ( err, got ) => test.identical( err, 'err2' ) );
    con.got( ( err, got ) => test.identical( err, 'err3' ) );
    test.identical( con.correspondentsGet().length, 3 );
    test.identical( con.messagesGet().length, 3 );
    return _.timeOut( 1, function ()
    {
      test.identical( con.correspondentsGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
    })
  })

  /* asyncTaking : 0, asyncGiving : 1 */

  testCon.doThen( () => setAsync( 0, 1 ) )
  .doThen( function ()
  {
    var con = new wConsequence();
    con.error( 'err1' ).error( 'err2' ).error( 'err3' );
    con.got( ( err, got ) => test.identical( err, 'err1' ) );
    con.got( ( err, got ) => test.identical( err, 'err2' ) );
    con.got( ( err, got ) => test.identical( err, 'err3' ) );
    test.identical( con.correspondentsGet().length, 3 );
    test.identical( con.messagesGet().length, 3 );
    return _.timeOut( 1, function ()
    {
      test.identical( con.correspondentsGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
    })
  })

  /* asyncTaking : 1, asyncGiving : 1 */

  testCon.doThen( () => setAsync( 1, 1 ) )
  .doThen( function ()
  {
    var con = new wConsequence();
    con.error( 'err1' ).error( 'err2' ).error( 'err3' );
    con.got( ( err, got ) => test.identical( err, 'err1' ) );
    con.got( ( err, got ) => test.identical( err, 'err2' ) );
    con.got( ( err, got ) => test.identical( err, 'err3' ) );
    test.identical( con.correspondentsGet().length, 3 );
    test.identical( con.messagesGet().length, 3 );
    return _.timeOut( 1, function ()
    {
      test.identical( con.correspondentsGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
    })
  });

  testCon.doThen( () => setAsync( 0, 0 ) )
  return testCon;
}

//

// function persistantMessage( test )
// {
//   var self = this;
//
//   var samples =
//   [
//
//     {
//       giveMethod : { give : 'give' },
//       gotArgument : 1,
//       anotherArgument : 0,
//       anotherArgumentValue : null,
//     },
//
//     {
//       giveMethod : { error : 'error' },
//       gotArgument : 0,
//       anotherArgument : 1,
//       anotherArgumentValue : undefined,
//     },
//
//   ];
//
//   //
//
//   for( var s = 0 ; s < samples.length ; s++ )
//   {
//     var sample = samples[ s ];
//
//     sample.giveMethod = _.nameUnfielded( sample.giveMethod ).coded;
//
//     /**/
//
//     var con = new wConsequence();
//
//     con.persist( ( function(){ var first = 1; return function( err,data )
//     {
//
//       debugger;
//       test.description = 'first message got with persist';
//       test.identical( arguments[ sample.gotArgument ],first );
//       test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );
//       //test.identical( arguments[ sample.gotArgument ] !== 3,true );
//       first += 1;
//
//     }}()) );
//
//     con[ sample.giveMethod ]( 1 );
//     con[ sample.giveMethod ]( 2 );
//     con.correspondentsClear();
//
//     /**/
//
//     var got8 = 0;
//
//     con.persist( ( function(){ var first = 3; return function( err,data )
//     {
//
//       test.description = 'second message got with persist';
//       test.identical( arguments[ sample.gotArgument ],first );
//       test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );
//       first += 1;
//
//       if( arguments[ sample.gotArgument ] === 8 )
//       got8 += 1;
//
//     }}()) );
//
//     con.persist( ( function(){ var first = 3; return function( err,data )
//     {
//
//       test.description = 'third message got with persist';
//       test.identical( arguments[ sample.gotArgument ],first );
//       test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );
//       first += 1;
//
//       if( arguments[ sample.gotArgument ] === 8 )
//       got8 += 1;
//
//     }}()) );
//
//     con[ sample.giveMethod ]( 3 );
//     con[ sample.giveMethod ]( 4 );
//     con[ sample.giveMethod ]( 5 );
//     con[ sample.giveMethod ]( 6 );
//
//     con.persist( ( function(){ var first = 7; return function( err,data )
//     {
//
//       test.description = 'got many messages with persist';
//       test.identical( arguments[ sample.gotArgument ],first );
//       test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );
//       first += 1;
//
//       if( arguments[ sample.gotArgument ] === 8 )
//       got8 += 1;
//
//     }}()) );
//
//     con[ sample.giveMethod ]( 7 );
//     con[ sample.giveMethod ]( 8 );
//
//     test.identical( got8,3 );
//
//     /**/
//
//     var got2 = 0;
//     var con = new wConsequence();
//
//     con[ sample.giveMethod ]( 1 );
//     con[ sample.giveMethod ]( 2 );
//
//     con.persist( ( function(){ var first = 1; return function( err,data )
//     {
//
//       test.description = 'got two messages with persist';
//       test.identical( arguments[ sample.gotArgument ],first );
//       test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );
//       first += 1;
//
//       if( arguments[ sample.gotArgument ] === 2 )
//       got2 += 1;
//
//     }}()) );
//
//     con.persist( ( function(){ var first = 7; return function( err,data )
//     {
//
//       test.description = 'should never happened';
//       test.identical( false,true );
//
//     }}()) );
//
//     _.timeOut( 25, function()
//     {
//       test.description = 'got one only messages';
//       test.identical( got2,1 );
//     });
//
//   }
//
// }

//

function doThen( test )
{
  var self = this;

  var samples =
  [

    {
      giveMethod : { give : 'give' },
      gotArgument : 1,
      anotherArgument : 0,
      anotherArgumentValue : null,
    },

    {
      giveMethod : { error : 'error' },
      gotArgument : 0,
      anotherArgument : 1,
      anotherArgumentValue : undefined,
    },

  ];

  //

  for( var s = 0 ; s < samples.length ; s++ )
  {
    var sample = samples[ s ];

    var con = new wConsequence();
    var counter = 0;

    con.doThen( function()
    {

      test.identical( counter,0 );
      counter = 2;

    });

    test.identical( counter,0 );
    con.give();

    con.got( function()
    {

      test.identical( counter,2 );
      counter = 4;

    });

    con.doThen( function()
    {

      test.identical( counter,4 );
      counter = 6;

    });

    con.doThen( function()
    {

      test.identical( counter,6 );
      counter = 8;

    });

    test.identical( counter,4 );
    con.give();
    test.identical( counter,8 );

  }

}

function doThenAsync( test )
{
  var currentTick = 0;
  var testMsg = 'msg';

  var setAsync = function( taking, giving )
  {
    wConsequence.prototype.asyncTaking = taking;
    wConsequence.prototype.asyncGiving = giving;
    test.description = 'asyncTaking : ' + taking + ' asyncGiving : ' + giving;
  }

  var testCon = new wConsequence().give()

  /* asyncTaking : 0, asyncGiving : 0 */

  .doThen( () => setAsync( 0, 0 ) )
  .doThen( function ()
  {
    function correspondent( err, got )
    {
      test.identical( err , null )
      test.identical( got , testMsg );
    }
    var con = new wConsequence();
    con.give( testMsg );
    test.identical( con.messagesGet().length, 1 )
    test.identical( con.messagesGet()[ 0 ], { error : null, argument : testMsg } )
    con.doThen( correspondent );
    test.identical( con.correspondentsGet().length, 0 );
    test.identical( con.messagesGet().length, 1 )
    test.identical( con.messagesGet()[ 0 ], { error : null, argument : undefined } );

    return con;
  })

  /* asyncTaking : 1, asyncGiving : 0 */

  .doThen( () => setAsync( 1, 0 ) )
  .doThen( function ()
  {
    function correspondent( err, got )
    {
      test.identical( err , null )
      test.identical( got , testMsg );
    }
    var con = new wConsequence();
    con.give( testMsg );
    con.doThen( correspondent );
    test.identical( con.messagesGet().length, 1 )
    test.identical( con.messagesGet()[ 0 ], { error : null, argument : testMsg } )
    test.identical( con.correspondentsGet().length, 1 );

    return _.timeOut( 1, function ()
    {
      test.identical( con.correspondentsGet().length, 0 );
      test.identical( con.messagesGet().length, 1 )
      test.identical( con.messagesGet()[ 0 ], { error : null, argument : undefined } )
    })
  })

  /* asyncTaking : 0, asyncGiving : 1 */

  .doThen( () => setAsync( 0, 1 ) )
  .doThen( function ()
  {
    function correspondent( err, got )
    {
      test.identical( err , null )
      test.identical( got , testMsg );
    }
    var con = new wConsequence();
    con.give( testMsg );
    con.doThen( correspondent );
    test.identical( con.messagesGet().length, 1 )
    test.identical( con.messagesGet()[ 0 ], { error : null, argument : testMsg } )
    test.identical( con.correspondentsGet().length, 1 );

    return _.timeOut( 1, function ()
    {
      test.identical( con.correspondentsGet().length, 0 )
      test.identical( con.messagesGet().length, 1 )
      test.identical( con.messagesGet()[ 0 ], { error : null, argument : undefined } )
    })
  })

  /* asyncTaking : 1, asyncGiving : 1 */

  .doThen( () => setAsync( 1, 1 ) )
  .doThen( function ()
  {
    function correspondent( err, got )
    {
      test.identical( err , null )
      test.identical( got , testMsg );
    }
    var con = new wConsequence();
    con.give( testMsg );
    con.doThen( correspondent );
    test.identical( con.correspondentsGet().length, 1 )
    test.identical( con.messagesGet().length, 1 )
    test.identical( con.messagesGet()[ 0 ], { error : null, argument : testMsg } )
    return _.timeOut( 1, function ()
    {
      test.identical( con.correspondentsGet().length, 0 )
      test.identical( con.messagesGet().length, 1 )
      test.identical( con.messagesGet()[ 0 ], { error : null, argument : undefined } )
    })

  })

  testCon.doThen( () => setAsync( 0, 0 ) );

  return testCon;
}

//

// function thenSealed_( test )
// {
//
//   var testCase1 =
//
//     {
//       givSequence : [ 5 ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//         [
//           { err : null, value : 5, takerId : 'taker1' }
//         ],
//         throwErr : false
//       }
//     },
//     testCase2 =
//     {
//       givSequence :
//       [
//         'err msg'
//       ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//         [
//           { err : 'err msg', value : void 0, takerId : 'taker1' }
//         ],
//         throwErr : false
//       }
//     },
//     testCase3 =
//     {
//       givSequence : [ 5, 4 ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//         [
//           { err : null, value : 5, takerId : 'taker1' },
//           { err : null, value : 4, takerId : 'taker2' }
//         ],
//         throwErr : false
//       }
//     },
//     testCase4 =
//     {
//       givSequence : [ 5 ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//         [
//           {
//             err : null,
//             value : 5,
//             takerId : 'taker1',
//             context : 'ContextConstructor',
//             sealed : 'bar' ,
//             contVariable : 'foo'
//           },
//         ],
//         throwErr : false
//       }
//     };
//
//
//   /* common wConsequence corespondent tests. */
//
//   test.description = 'single value in give sequence, and single taker : attached taker after value resolved';
//   ( function ( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }
//
//     var con = wConsequence();
//     con.give( givSequence.shift() );
//     try
//     {
//       con.thenSealed( null, testTaker1, [] );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCase1 );
//
//   /**/
//
//   test.description = 'single err in give sequence, and single taker : attached taker after value resolved';
//   ( function ( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }
//
//     var con = wConsequence();
//     try
//     {
//       con.error( givSequence.shift() );
//       con.thenSealed( null, testTaker1, [] );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCase2 );
//
//   /**/
//
//   test.description = 'test thenSealed in chain';
//
//   ( function ( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//       value++;
//       return value;
//     }
//
//     function testTaker2( err, value )
//     {
//       var takerId = 'taker2';
//       got.gotSequence.push( { err, value, takerId } );
//     }
//
//     var con = wConsequence();
//     for (let given of givSequence)
//       con.give( given );
//
//     try
//     {
//       con.thenSealed( null, testTaker1, [] );
//       con.thenSealed( null, testTaker2, [] );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCase3 );
//
//   /* test particular onceGot features test. */
//
//   test.description = 'thenSealed with sealed context and argument';
//   ( function ( { givSequence, got, expected }  )
//   {
//     function testTaker1( sealed, err, value )
//     {
//       console.log( sealed + err + value )
//       var takerId = 'taker1',
//         context = this.constructor.name,
//         contVariable = this.contVariable;
//         got.gotSequence.push( { err, value, takerId, context, contVariable, sealed } );
//     }
//
//     function ContextConstructor()
//     {
//       this.contVariable = 'foo';
//     }
//
//     var con = wConsequence();
//
//     for( let given of givSequence )
//     {
//       con.give( given );
//     }
//
//     try
//     {
//       con.thenSealed( new ContextConstructor(), testTaker1, [ 'bar' ] );
//     }
//     catch( err )
//     {
//       console.log(err);
//       got.throwErr = !! err;
//     }
//     console.log(JSON.stringify(expected));
//     test.identical( got, expected );
//   } )( testCase4 );
//
//
//   if( Config.debug )
//   {
//     var conDeb1 = wConsequence();
//
//     test.description = 'missed context arguments';
//     test.shouldThrowError( function()
//     {
//       conDeb1.thenSealed( function( err, val) { logger.log( 'foo' ); } );
//     } );
//   }
//
// };

//

// function split( test )
// {
//   var testCase1 =
//
//     {
//       givSequence : [ 5 ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//           [
//             { err : null, value : 5, takerId : 'taker1' }
//           ],
//         throwErr : false
//       }
//     },
//     testCase2 =
//     {
//       givSequence :
//         [ 5 ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//           [
//             { err : null, value : 5, takerId : 'taker1' }
//           ],
//         throwErr : false
//       }
//     },
//     testCase3 =
//     {
//       givSequence : [ 5, 4 ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//           [
//             { err : null, value : 5, takerId : 'taker1' },
//           ],
//         throwErr : false
//       }
//     };
//
//
//   /* common wConsequence corespondent tests. */
//
//   test.description = 'then clone : run after resolve value';
//   ( function ( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }
//
//     var newCon;
//     var con = wConsequence();
//     con.give( givSequence.shift() );
//     try
//     {
//       newCon = con.split();
//       newCon.got( testTaker1 )
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCase1 );
//
//   /**/
//
//   test.description = 'then clone : run before resolve value';
//   ( function ( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }
//
//     var newCon;
//     var con = wConsequence();
//     try
//     {
//       newCon = con.split();
//       newCon.got( testTaker1 );
//       con.give( givSequence.shift() );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCase2 );
//
//   /**/
//
//   test.description = 'test thenSealed in chain';
//
//   ( function ( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//       value++;
//       return value;
//     }
//
//     function testTaker2( err, value )
//     {
//       var takerId = 'taker2';
//       got.gotSequence.push( { err, value, takerId } );
//     }
//
//     var con = wConsequence();
//     for (let given of givSequence)
//       con.give( given );
//
//     var newCon;
//     try
//     {
//       newCon = con.split();
//       newCon.got( testTaker1 );
//       newCon.got( testTaker2 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCase3 );
// };

//

function split( test )
{
  var testCon = new wConsequence().give()

  .doThen( function ()
  {
    test.description = 'split : run after resolve value';
    var con = new wConsequence().give( 5 );
    var con2 = con.split();
    test.identical( con2.messagesGet().length, 1 );
    con2.got( function( err, got )
    {
      test.identical( got, 5 );
      test.identical( err, null );
    });

    test.identical( con.messagesGet().length, 1 );
    test.identical( con2.messagesGet().length, 0 );
  })

  .doThen( function ()
  {
    test.description = 'split : run before resolve value';
    var con = new wConsequence();
    var con2 = con.split();
    con2.got( function( err, got )
    {
      test.identical( got, 5 );
      test.identical( err, null );
    });
    con.give( 5 );
    test.identical( con.messagesGet().length, 1 );
    test.identical( con2.messagesGet().length, 0 );
  })

  .doThen( function ()
  {
    test.description = 'test split in chain';
    var _got = [];
    var _err = [];
    function correspondent( err, got )
    {
      _got.push( got );
      _err.push( err );
    }

    var con = new wConsequence();
    con.give( 5 );
    con.give( 6 );
    test.identical( con.messagesGet().length, 2 );
    var con2 = con.split();
    test.identical( con2.messagesGet().length, 1 );
    con2.got( correspondent );
    con2.got( correspondent );

    test.identical( con2.messagesGet().length, 0 );
    test.identical( con2.correspondentsGet().length, 1 );
    test.identical( con.messagesGet().length, 2 );
    test.identical( _got, [ 5 ] )
    test.identical( _err, [ null ] )
  })

  .doThen( function ()
  {
    test.description = 'passing correspondent as argument';
    var _got = [];
    var _err = [];
    function correspondent( err, got )
    {
      _got.push( got );
      _err.push( err );
    }

    var con = new wConsequence();
    con.give( 5 );
    con.give( 6 );
    test.identical( con.messagesGet().length, 2 );
    var con2 = con.split( correspondent );

    test.identical( con2.messagesGet().length, 1 );
    test.identical( con2.messagesGet()[ 0 ], { error : null, argument : undefined } );
    test.identical( con2.correspondentsGet().length, 0 );
    test.identical( con.messagesGet().length, 2 );
    test.identical( _got, [ 5 ] )
    test.identical( _err, [ null ] )
  })

  return testCon;
}

//

// function thenReportError( test )
// {
//
//   var testCase1 =
//
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
//     testCase2 =
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
//           [],
//         throwErr : false
//       }
//     },
//     testCase3 =
//     {
//       givSequence : [ 5, 4 ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//           [
//             { err : null, value : 5, takerId : 'taker1' },
//             { err : null, value : 4, takerId : 'taker2' }
//           ],
//         throwErr : false
//       }
//     },
//     testCase4 =
//     {
//       givSequence : [ 5, 4 ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//           [
//             { err : null, value : 5, takerId : 'taker1' },
//             { err : null, value : 4, takerId : 'taker2' }
//           ],
//         throwErr : false
//       }
//     };
//
//
//   /* common wConsequence corespondent tests. */
//
//   test.description = 'single value in give sequence';
//   ( function ( { givSequence, got, expected }  )
//   {
//     var con = wConsequence();
//     con.give( givSequence.shift() );
//     try
//     {
//       con.thenReportError();
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCase1 );
//
//   /**/
//
//   test.description = 'single err in give sequence';
//   ( function ( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }
//
//     var con = wConsequence();
//     try
//     {
//       con.error( givSequence.shift() );
//       con.thenReportError();
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCase2 );
//
//   /**/
//
//   test.description = 'test thenSealed in chain';
//
//   ( function ( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//       value++;
//       return value;
//     }
//
//     function testTaker2( err, value )
//     {
//       var takerId = 'taker2';
//       got.gotSequence.push( { err, value, takerId } );
//     }
//
//     var con = wConsequence();
//     for (let given of givSequence)
//       con.give( given );
//
//     try
//     {
//       con.thenReportError();
//       con.got( testTaker1 );
//       con.got( testTaker2 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCase3 );
//   //
//   /* test particular onceGot features test. */
//
//   test.description = 'test thenSealed in chain #2';
//   ( function ( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//       value++;
//       return value;
//     }
//
//     function testTaker2( err, value )
//     {
//       var takerId = 'taker2';
//       got.gotSequence.push( { err, value, takerId } );
//     }
//
//     var con = wConsequence();
//     try
//     {
//       con.thenReportError();
//       con.got( testTaker1 );
//       con.got( testTaker2 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//
//     for (let given of givSequence)
//       con.give( given );
//
//     test.identical( got, expected );
//   } )( testCase4 );
//
//
//   if( Config.debug )
//   {
//     var conDeb1 = wConsequence();
//
//     test.description = 'called thenReportError with any argument';
//     test.shouldThrowError( function()
//     {
//       conDeb1.thenReportError( function( err, val) { logger.log( 'foo' ); } );
//     } );
//   }
//
// };

//

function tap( test )
{

  var testCase1 =

    {
      givSequence : [ 5 ],
      got :
      {
        gotSequence : [],
        throwErr : false
      },
      expected :
      {
        gotSequence :
          [
            { err : null, value : 5, takerId : 'taker1' }
          ],
        throwErr : false
      }
    },
    testCase2 =
    {
      givSequence :
        [
          'err msg'
        ],
      got :
      {
        gotSequence : [],
        throwErr : false
      },
      expected :
      {
        gotSequence :
          [
            { err : 'err msg', value : void 0, takerId : 'taker1' }
          ],
        throwErr : false
      }
    },
    testCase3 =
    {
      givSequence : [ 5, 4 ],
      got :
      {
        gotSequence : [],
        throwErr : false
      },
      expected :
      {
        gotSequence :
          [
            { err : null, value : 5, takerId : 'taker1' },
            { err : null, value : 5, takerId : 'taker2' },
            { err : null, value : 5, takerId : 'taker3' }
          ],
        throwErr : false
      }
    };


  /* common wConsequence corespondent tests. */

  test.description = 'single value in give sequence, and single taker : attached taker after value resolved';
  ( function ( { givSequence, got, expected }  )
  {
    function testTaker1( err, value )
    {
      var takerId = 'taker1';
      got.gotSequence.push( { err, value, takerId } );
    }

    var con = wConsequence();
    con.give( givSequence.shift() );
    try
    {
      con.tap( testTaker1 );
    }
    catch( err )
    {
      got.throwErr = !! err;
    }
    test.identical( got, expected );
  } )( testCase1 );

  /**/

  test.description = 'single err in give sequence, and single taker : attached taker after value resolved';
  ( function ( { givSequence, got, expected }  )
  {
    function testTaker1( err, value )
    {
      var takerId = 'taker1';
      got.gotSequence.push( { err, value, takerId } );
    }

    var con = wConsequence();
    try
    {
      con.error( givSequence.shift() );
      con.tap( testTaker1 );
    }
    catch( err )
    {
      got.throwErr = !! err;
    }
    test.identical( got, expected );
  } )( testCase2 );

  /**/

  test.description = 'test tap in chain';

  ( function ( { givSequence, got, expected }  )
  {
    function testTaker1( err, value )
    {
      var takerId = 'taker1';
      got.gotSequence.push( { err, value, takerId } );
      value++;
      return value;
    }

    function testTaker2( err, value )
    {
      var takerId = 'taker2';
      got.gotSequence.push( { err, value, takerId } );
    }

    function testTaker3( err, value )
    {
      var takerId = 'taker3';
      got.gotSequence.push( { err, value, takerId } );
    }

    var con = wConsequence();
    for (let given of givSequence)
      con.give( given );

    try
    {
      con.tap( testTaker1 );
      con.tap( testTaker2 );
      con.got( testTaker3 );

    }
    catch( err )
    {
      got.throwErr = !! err;
    }
    test.identical( got, expected );
  } )( testCase3 );

  if( Config.debug )
  {
    var conDeb1 = wConsequence();

    test.description = 'missed arguments';
    test.shouldThrowError( function()
    {
      conDeb1.tap();
    } );
  }

};

//

function ifErrorThen( test )
{

  var testCase1 =

    {
      givSequence : [ 5 ],
      got :
      {
        gotSequence : [],
        throwErr : false
      },
      expected :
      {
        gotSequence : [],
        throwErr : false
      }
    },
    testCase2 =
    {
      givSequence :
        [
          'err msg'
        ],
      got :
      {
        gotSequence : [],
        throwErr : false
      },
      expected :
      {
        gotSequence :
          [
            { err : 'err msg', takerId : 'taker1' }
          ],
        throwErr : false
      }
    },
    testCase3 =
    {
      givSequence : [ 5, 'err msg',  4 ],
      got :
      {
        gotSequence : [],
        throwErr : false
      },
      expected :
      {
        gotSequence :
          [
            { err : null, value : 5, takerId : 'taker3' },
          ],
        throwErr : false
      }
    };


  /* common wConsequence corespondent tests. */

  test.description = 'single value in give sequence, and single taker : attached taker after value resolved';
  ( function ( { givSequence, got, expected }  )
  {
    function testTaker1( err )
    {
      var takerId = 'taker1';
      got.gotSequence.push( { err, takerId } );
    }

    var con = wConsequence();
    con.give( givSequence.shift() );
    try
    {
      con.ifErrorThen( testTaker1 );
    }
    catch( err )
    {
      got.throwErr = !! err;
    }
    test.identical( got, expected );
  } )( testCase1 );

  /**/

  test.description = 'single err in give sequence, and single taker : attached taker after value resolved';
  ( function ( { givSequence, got, expected }  )
  {
    function testTaker1( err )
    {
      var takerId = 'taker1';
      got.gotSequence.push( { err, takerId } );
    }

    var con = wConsequence();
    try
    {
      con.error( givSequence.shift() );
      con.ifErrorThen( testTaker1 );
    }
    catch( err )
    {
      got.throwErr = !! err;
    }
    test.identical( got, expected );
  } )( testCase2 );

  /**/

  test.description = 'test tap in chain';

  ( function ( { givSequence, got, expected }  )
  {
    function testTaker1( err )
    {
      var takerId = 'taker1';
      got.gotSequence.push( { err,takerId } );
      value++;
      return value;
    }

    function testTaker2( err )
    {
      var takerId = 'taker2';
      got.gotSequence.push( { err,takerId } );
    }

    function testTaker3( err, value )
    {
      var takerId = 'taker3';
      got.gotSequence.push( { err, value, takerId } );
    }

    var con = wConsequence();

    con.give( givSequence.shift() );
    con.error( givSequence.shift() );
    con.give( givSequence.shift() );

    try
    {
      con.ifErrorThen( testTaker1 );
      con.ifErrorThen( testTaker2 );
      con.got( testTaker3 );

    }
    catch( err )
    {
      got.throwErr = !! err;
    }
    test.identical( got, expected );
  } )( testCase3 );

  if( Config.debug )
  {
    var conDeb1 = wConsequence();

    test.description = 'missed arguments';
    test.shouldThrowError( function()
    {
      conDeb1.ifErrorThen();
    } );
  }

};

//

function ifNoErrorThen( test )
{

  var testCase1 =

    {
      givSequence : [ 5 ],
      got :
      {
        gotSequence : [],
        throwErr : false
      },
      expected :
      {
        gotSequence :
        [
          { value : 5, takerId : 'taker1' }
        ],
        throwErr : false
      }
    },
    testCase2 =
    {
      givSequence :
        [
          'err msg'
        ],
      got :
      {
        gotSequence : [],
        throwErr : false
      },
      expected :
      {
        gotSequence :
          [ ],
        throwErr : false
      }
    },
    testCase3 =
    {
      givSequence : [ 5, 'err msg',  4 ],
      got :
      {
        gotSequence : [],
        throwErr : false
      },
      expected :
      {
        gotSequence :
          [
            { value : 5, takerId : 'taker1' },
            { err : 'err msg', value : void 0, takerId : 'taker3' },
          ],
        throwErr : false
      }
    };


  /* common wConsequence corespondent tests. */

  test.description = 'single value in give sequence, and single taker : attached taker after value resolved';
  ( function ( { givSequence, got, expected }  )
  {
    function testTaker1( value )
    {
      var takerId = 'taker1';
      got.gotSequence.push( { value, takerId } );
    }

    var con = wConsequence();
    con.give( givSequence.shift() );
    try
    {
      con.ifNoErrorThen( testTaker1 );
    }
    catch( err )
    {
      got.throwErr = !! err;
    }
    test.identical( got, expected );
  } )( testCase1 );

  /**/

  test.description = 'single err in give sequence, and single taker : attached taker after value resolved';
  ( function ( { givSequence, got, expected }  )
  {
    function testTaker1( value )
    {
      var takerId = 'taker1';
      got.gotSequence.push( { value, takerId } );
    }

    var con = wConsequence();
    try
    {
      con.error( givSequence.shift() );
      con.ifNoErrorThen( testTaker1 );
    }
    catch( err )
    {
      got.throwErr = !! err;
    }
    test.identical( got, expected );
  } )( testCase2 );

  /**/

  test.description = 'test ifNoErrorThen in chain';

  ( function ( { givSequence, got, expected }  )
  {
    function testTaker1( value )
    {
      var takerId = 'taker1';
      got.gotSequence.push( { value, takerId } );
      value++;
      return value;
    }

    function testTaker2( value )
    {
      var takerId = 'taker2';
      got.gotSequence.push( {  value, takerId } );
    }

    function testTaker3( err, value )
    {
      var takerId = 'taker3';
      got.gotSequence.push( { err, value, takerId } );
    }

    var con = wConsequence();

    con.give( givSequence.shift() );
    con.error( givSequence.shift() );
    con.give( givSequence.shift() );

    try
    {
      con.ifNoErrorThen( testTaker1 );
      con.ifNoErrorThen( testTaker2 );
      con.got( testTaker3 );

    }
    catch( err )
    {
      got.throwErr = !! err;
    }
    test.identical( got, expected );
  } )( testCase3 );

  if( Config.debug )
  {
    var conDeb1 = wConsequence();

    test.description = 'missed arguments';
    test.shouldThrowError( function()
    {
      conDeb1.ifNoErrorThen();
    } );
  }

};

function timeOutThen( test )
{

  var testCase1 =

    {
      givSequence : [ 5 ],
      got :
      {
        gotSequence :
        [
          { err : null, value : 5, takerId : 'taker1' }
        ],
        throwErr : false
      },
      expected :
      {
        gotSequence :
          [
            { err : null, value : 5, takerId : 'taker1' }
          ],
        throwErr : false
      }
    },
    testCase2 =
    {
      givSequence :
        [
          'err msg'
        ],
      got :
      {
        gotSequence : [],
        throwErr : false
      },
      expected :
      {
        gotSequence :
          [ ],
        throwErr : false
      }
    },
    testCase3 =
    {
      givSequence : [ 5, 3,  4 ],
      got :
      {
        gotSequence : [],
        throwErr : false
      },
      expected :
      {
        gotSequence :
          [
            { err : null, value : 4, takerId : 'taker3' },
            { err : null, value : 3, takerId : 'taker2' },
          ],
        throwErr : false
      }
    };


  /* common wConsequence corespondent tests. */

  test.description = 'single value in give sequence, and single taker : attached taker after value resolved';
  ( function ( { givSequence, got, expected }  )
  {
    function testTaker1( err, value )
    {
      var takerId = 'taker1';
      got.gotSequence.push( { err, value, takerId } );
    }

    var con = wConsequence();
    con.give( givSequence.shift() );
    try
    {
      con.timeOutThen( 0, testTaker1 );
    }
    catch( err )
    {
      got.throwErr = !! err;
    }
    test.identical( got, expected );
  } )( testCase1 );

  /**/

  test.description = 'single err in give sequence, and single taker : attached taker after value resolved';
  ( function ( { givSequence, got, expected }  )
  {
    function testTaker1( err, value )
    {
      var takerId = 'taker1';
      got.gotSequence.push( { err, value, takerId } );
    }

    var con = wConsequence();
    try
    {
      con.error( givSequence.shift() );
      con.timeOutThen( 0, testTaker1 );
    }
    catch( err )
    {
      got.throwErr = !! err;
    }
    test.identical( got, expected );
  } )( testCase2 );

  /**/

  test.description = 'test timeOutThen in chain';

  ( function ( { givSequence, got, expected }  )
  {
    function testTaker1( err, value )
    {
      var takerId = 'taker1';
      got.gotSequence.push( { err, value, takerId } );
      value++;
      return value;
    }

    function testTaker2( err, value )
    {
      var takerId = 'taker2';
      got.gotSequence.push( { err, value, takerId } );
    }

    function testTaker3( err, value )
    {
      var takerId = 'taker3';
      got.gotSequence.push( { err, value, takerId } );
    }

    var con = wConsequence();

    for (let given of givSequence)
      con.give( given );

    con.timeOutThen( 20, testTaker1 );
    con.timeOutThen( 10, testTaker2 );
    con.got( testTaker3 )
    .got( function() {
      test.identical( got, expected );
    } );



  } )( testCase3 );

  if( Config.debug )
  {
    var conDeb1 = wConsequence();

    test.description = 'missed arguments';
    test.shouldThrowError( function()
    {
      conDeb1.timeOutThen();
    } );
  }

};

//

function _and( test )
{
  var testCase1 =
    {
      givSequence : [ 5, 4 ],
      got :
      {
        gotSequence : [ ],
        throwErr : false
      },
      expected :
      {
        gotSequence :
          [ ],
        throwErr : false
      }
    },
    testCase2 =
    {
      givSequence : [ 5, 4 ],
      got :
      {
        gotSequence : [],
        throwErr : false
      },
      expected :
      {
        gotSequence :
          [
            { err : null, value : 5, takerId : 'taker1' },
            { err : null, value : 4, takerId : 'taker2' },
          ],
        throwErr : false
      }
    },
    testCase3 =
    {
      givSequence : [ 5, 3,  4 ],
      got :
      {
        gotSequence : [],
        throwErr : false
      },
      expected :
      {
        gotSequence :
          [
            { err : null, value : 4, takerId : 'taker3' },
            { err : null, value : 3, takerId : 'taker2' },
          ],
        throwErr : false
      }
    };


  /* common wConsequence corespondent tests. */

  test.description = 'do not give back messages to src consequences';
  ( function ( { givSequence, got, expected }  )
  {
    var con1 = wConsequence(),
      con2 = wConsequence();


    function testTaker1( err, value )
    {
      var takerId = 'taker1';
      got.gotSequence.push( { err, value, takerId } );
    }

    function testTaker2( err, value )
    {
      var takerId = 'taker2';
      got.gotSequence.push( { err, value, takerId } );
    }

    var  conOwner = new wConsequence();

    conOwner.give();

    con1.got( testTaker1 );
    con2.got( testTaker2 );

    try
    {
      debugger
      conOwner._and( [con1, con2], true );
    }
    catch( err )
    {
      got.throwErr = !! err;
    }

    conOwner.got( function()
    {
      test.identical( got, expected );
    } );


    con1.give( givSequence.shift() );
    con2.give( givSequence.shift() );
  } )( testCase1 );

  /**/

  test.description = 'give back massages to src consequences once all come';
  ( function ( { givSequence, got, expected }  )
  {
    var con1 = wConsequence(),
      con2 = wConsequence();


    function testTaker1( err, value )
    {
      var takerId = 'taker1';
      got.gotSequence.push( { err, value, takerId } );
    }

    function testTaker2( err, value )
    {
      var takerId = 'taker2';
      got.gotSequence.push( { err, value, takerId } );
    }

    var  conOwner = wConsequence();

    conOwner.give();

    con1.got( testTaker1 );
    con2.got( testTaker2 );

    try
    {
      conOwner._and( [con1, con2], false );
    }
    catch( err )
    {
      got.throwErr = !! err;
    }

    conOwner.got( function()
    {
      test.identical( got, expected );
    } );

    con1.give( givSequence.shift() );
    con2.give( givSequence.shift() );
  } )( testCase2 );


  if( Config.debug )
  {
    var conDeb1 = wConsequence();

    test.description = 'missed arguments';
    test.shouldThrowError( function()
    {
      conDeb1._and();
    } );
  }
};

// --
// test part 3
// --

function onceGot( test )
{

  var conseqTester = wConsequence(); // for correct testing async aspects of wConsequence

  var testCases =
    [
      {
        givSequence: [ 5 ],
        gotSequence: [],
        expectedSequence:
        [
         { err: null, value: 5, takerId: 'taker1' }
        ],
      },
      {
        givSequence: [
          'err msg'
        ],
        gotSequence: [],
        expectedSequence:
        [
          { err: 'err msg', value: void 0, takerId: 'taker1' }
        ]
      },
      {
        givSequence: [ 5, 4 ],
        gotSequence: [],
        expectedSequence:
          [
            { err: null, value: 5, takerId: 'taker1' },
            { err: null, value: 4, takerId: 'taker2' }
          ],
      },
      {
        givSequence: [ 5, 4, 6 ],
        gotSequence: [],
        expectedSequence:
        [
          { err: null, value: 5, takerId: 'taker1' },
          { err: null, value: 4, takerId: 'taker1' },
          { err: null, value: 6, takerId: 'taker2' }
        ],
      },
      {
        givSequence: [ 5, 4, 6 ],
        gotSequence: [],
        expectedSequence:
        [
          { err: null, value: 5, takerId: 'taker1' },
          { err: null, value: 4, takerId: 'taker2' },
        ],
      },
    ];

  /* common wConsequence goter tests. */

  test.description = 'single value in give sequence, and single taker: attached taker after value resolved';
  ( function ( { givSequence, gotSequence, expectedSequence }  )
  {
    function testTaker1( err, value )
    {
      var takerId = 'taker1';
      gotSequence.push( { err, value, takerId } );
    }

    var con = wConsequence();
    con.give( givSequence.shift() );
    con.onceGot( testTaker1 );
    test.identical( gotSequence, expectedSequence );
  } )( testCases[ 0 ] );

  /**/

  test.description = 'single err in give sequence, and single taker: attached taker after value resolved';
  ( function ( { givSequence, gotSequence, expectedSequence }  )
  {
    function testTaker1( err, value )
    {
      var takerId = 'taker1';
      gotSequence.push( { err, value, takerId } );
    }

    var con = wConsequence();
    con.error( givSequence.shift() );
    con.onceGot( testTaker1 );
    test.identical( gotSequence, expectedSequence );
  } )( testCases[ 1 ] );

  /**/

  test.description = 'test onceGot in chain';

  ( function ( { givSequence, gotSequence, expectedSequence }  )
  {
    function testTaker1( err, value )
    {
      var takerId = 'taker1';
      gotSequence.push( { err, value, takerId } );
      value++;
      return value;
    }

    function testTaker2( err, value )
    {
      var takerId = 'taker2';
      gotSequence.push( { err, value, takerId } );
    }

    var con = wConsequence();
    for (let given of givSequence)
    con.give( given );

    con.onceGot( testTaker1 );
    con.onceGot( testTaker2 );
    test.identical( gotSequence, expectedSequence );
  } )( testCases[ 2 ] );

  /* test particular onceGot features test. */

  test.description = 'several takers with same name: appending after given values are resolved';
  ( function ( { givSequence, gotSequence, expectedSequence }  )
  {
    function testTaker1( err, value )
    {
      var takerId = 'taker1';
      gotSequence.push( { err, value, takerId } );
    }

    function testTaker2( err, value )
    {
      var takerId = 'taker2';
      gotSequence.push( { err, value, takerId } );
    }

    var con = wConsequence();

    for( let given of givSequence ) // pass all values in givSequence to consequenced
    {
      con.give( given );
    }

    con.onceGot( testTaker1 );
    con.onceGot( testTaker1 );
    con.onceGot( testTaker2 );
    test.identical( gotSequence, expectedSequence );
  } )( testCases[ 3 ] );

  /**/

  test.description = 'several takers with same name: appending before given values are resolved';
  ( function ( { givSequence, gotSequence, expectedSequence }  )
  {
    function testTaker1( err, value )
    {
      var takerId = 'taker1';
      gotSequence.push( { err, value, takerId } );
    }

    function testTaker2( err, value )
    {
      var takerId = 'taker2';
      gotSequence.push( { err, value, takerId } );
    }

    var con = new wConsequence();
    var testCon = new wConsequence().give();

    con.onceGot( testTaker1 );
    con.onceGot( testTaker1 );
    con.onceGot( testTaker2 );

    for( let given of givSequence ) // pass all values in givSequence to consequenced
    {
      testCon.doThen( () => con.give( given ) );
    }

    testCon.doThen( () => test.identical( gotSequence, expectedSequence ) );
  } )( testCases[ 4 ] );

  /**/

  if( Config.debug )
  {
    var conDeb1 = wConsequence();

    test.description = 'try to pass as parameter anonymous function';
    test.shouldThrowError( function()
    {
      conDeb1.onceGot( function( err, val) { logger.log( 'i em anonymous' ); } );
    } );

    var conDeb2 = wConsequence();

    test.description = 'try to pass as parameter anonymous function (defined in expression)';

    function testHandler( err, val) { logger.log( 'i em anonymous' ); }
    test.shouldThrowError( function()
    {
      conDeb2.onceGot( testHandler );
    } );
  }

  conseqTester.give();
  return conseqTester;
}

//

function onceThen( test )
{

  var testCase1 =

    {
      givSequence: [ 5 ],
      got:
      {
        gotSequence: [],
        throwErr: false
      },
      expected:
      {
        gotSequence:
          [
            { err: null, value: 5, takerId: 'taker1' }
          ],
        throwErr: false
      }
    },
    testCase2 =
    {
      givSequence:
        [
          'err msg'
        ],
      got:
      {
        gotSequence: [],
        throwErr: false
      },
      expected:
      {
        gotSequence:
          [
            { err: 'err msg', value: void 0, takerId: 'taker1' }
          ],
        throwErr: false
      }
    },
    testCase3 =
    {
      givSequence: [ 5, 4 ],
      got:
      {
        gotSequence: [],
        throwErr: false
      },
      expected:
      {
        gotSequence:
          [
            { err: null, value: 5, takerId: 'taker1' },
            { err: null, value: 4, takerId: 'taker2' },
            { err: null, value: 6, takerId: 'taker3' }
          ],
        throwErr: false
      }
    },
    testCase4 =
    {
      givSequence: [ 5 ],
      got:
      {
        gotSequence: [],
        throwErr: false
      },
      expected:
      {
        gotSequence:
          [
            { err: null, value: 5, takerId: 'taker1' },
            { err: null, value: 6, takerId: 'taker2' },
          ],
        throwErr: false
      }
    };


  /* common wConsequence corespondent tests. */

  test.description = 'single value in give sequence, and single taker: attached taker after value resolved';
  ( function ( { givSequence, got, expected }  )
  {
    function testTaker1( err, value )
    {
      var takerId = 'taker1';
      got.gotSequence.push( { err, value, takerId } );
    }

    var con = wConsequence();
    con.give( givSequence.shift() );
    try
    {
      con.onceThen( testTaker1 );
    }
    catch( err )
    {
      got.throwErr = !! err;
    }
    test.identical( got, expected );
  } )( testCase1 );

  /**/

  test.description = 'single err in give sequence, and single taker: attached taker after value resolved';
  ( function ( { givSequence, got, expected }  )
  {
    function testTaker1( err, value )
    {
      var takerId = 'taker1';
      got.gotSequence.push( { err, value, takerId } );
    }

    var con = wConsequence();
    try
    {
      con.error( givSequence.shift() );
      con.onceThen( testTaker1 );
    }
    catch( err )
    {
      got.throwErr = !! err;
    }
    test.identical( got, expected );
  } )( testCase2 );

  /**/

  test.description = 'test onceThen in chain';

  ( function ( { givSequence, got, expected }  )
  {
    function testTaker1( err, value )
    {
      var takerId = 'taker1';
      got.gotSequence.push( { err, value, takerId } );
      value++;
      return value;
    }

    function testTaker2( err, value )
    {
      var takerId = 'taker2';
      got.gotSequence.push( { err, value, takerId } );
    }

    function testTaker3( err, value )
    {
      var takerId = 'taker3';
      got.gotSequence.push( { err, value, takerId } );
    }

    var con = wConsequence();
    for (let given of givSequence)
      con.give( given );

    try
    {
      con.onceThen( testTaker1 );
      con.onceThen( testTaker2 );
      con.got( testTaker3 );
    }
    catch( err )
    {
      got.throwErr = !! err;
    }
    test.identical( got, expected );
  } )( testCase3 );

  /* test particular onceThen features test. */

  test.description = 'added several corespondents with same name';
  ( function ( { givSequence, got, expected }  )
  {
    function testTaker1( err, value )
    {
      var takerId = 'taker1';
      got.gotSequence.push( { err, value, takerId } );
      value++;
      return value;
    }

    function testTaker2( err, value )
    {
      var takerId = 'taker2';
      got.gotSequence.push( { err, value, takerId } );
    }

    function testTaker3( err, value )
    {
      var takerId = 'taker3';
      got.gotSequence.push( { err, value, takerId } );
    }

    var con = wConsequence();

    try
    {
      debugger
      con.onceThen( testTaker1 );
      con.onceThen( testTaker1 );
      con.onceThen( testTaker2 );

      for( let given of givSequence )
      {
        con.give( given );
      }
    }
    catch( err )
    {
      console.log(err);
      got.throwErr = !! err;
    }

    test.identical( got, expected );
  } )( testCase4 );


  if( Config.debug )
  {
    var conDeb1 = wConsequence();

    test.description = 'try to pass as parameter anonymous function';
    test.shouldThrowError( function()
    {
      conDeb1.onceThen( function( err, val) { logger.log( 'i em anonymous' ); } );
    } );

    var conDeb2 = wConsequence();

    test.description = 'try to pass as parameter anonymous function (defined in expression)';

    function testHandler( err, val) { logger.log( 'i em anonymous' ); }
    test.shouldThrowError( function()
    {
      conDeb2.onceThen( testHandler );
    } );
  }

};

//

// function persist( test )
// {
//
//   var testCase1 =
//
//     {
//       givSequence: [ 5 ],
//       got:
//       {
//         gotSequence: [],
//         throwErr: false
//       },
//       expected:
//       {
//         gotSequence:
//           [
//             { err: null, value: 5, takerId: 'taker1' }
//           ],
//         throwErr: false
//       }
//     },
//     testCase2 =
//     {
//       givSequence:
//         [
//           'err msg'
//         ],
//       got:
//       {
//         gotSequence: [],
//         throwErr: false
//       },
//       expected:
//       {
//         gotSequence:
//           [
//             { err: 'err msg', value: void 0, takerId: 'taker1' }
//           ],
//         throwErr: false
//       }
//     },
//     testCase3 =
//     {
//       givSequence: [ 5, 4 ],
//       got:
//       {
//         gotSequence: [],
//         throwErr: false
//       },
//       expected:
//       {
//         gotSequence:
//           [
//             { err: null, value: 5, takerId: 'taker3' },
//             { err: null, value: 5, takerId: 'taker1' },
//             { err: null, value: 5, takerId: 'taker2' },
//
//             { err: null, value: 4, takerId: 'taker1' },
//             { err: null, value: 4, takerId: 'taker2' },
//           ],
//         throwErr: false
//       }
//     },
//     testCase4 =
//     {
//       givSequence: [ 5 ],
//       got:
//       {
//         gotSequence: [],
//         throwErr: false
//       },
//       expected:
//       {
//         gotSequence:
//           [
//             { err: null, value: 5, takerId: 'taker1' },
//             { err: null, value: 6, takerId: 'taker2' },
//           ],
//         throwErr: false
//       }
//     };
//
//
//   /* common wConsequence corespondent tests. */
//
//   test.description = 'single value in give sequence, and single taker: attached taker after value resolved';
//   ( function ( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }
//
//     var con = wConsequence();
//     con.give( givSequence.shift() );
//     try
//     {
//       con.persist( testTaker1 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCase1 );
//
//   /**/
//
//   test.description = 'single err in give sequence, and single taker: attached taker after value resolved';
//   ( function ( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }
//
//     var con = wConsequence();
//     try
//     {
//       con.error( givSequence.shift() );
//       con.persist( testTaker1 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCase2 );
//
//   /**/
//
//   test.description = 'test onceThen in chain';
//
//   ( function ( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//       value++;
//       return value;
//     }
//
//     function testTaker2( err, value )
//     {
//       var takerId = 'taker2';
//       got.gotSequence.push( { err, value, takerId } );
//     }
//
//     function testTaker3( err, value )
//     {
//       var takerId = 'taker3';
//       got.gotSequence.push( { err, value, takerId } );
//     }
//
//     var con = wConsequence();
//
//
//     try
//     {
//       con.persist( testTaker1 );
//       con.persist( testTaker2 );
//       con.got( testTaker3 );
//
//       for (let given of givSequence)
//         con.give( given );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//
//     test.identical( got, expected );
//
//   } )( testCase3 );
//
//   if( Config.debug )
//   {
//     var conDeb1 = wConsequence();
//
//     test.description = 'missed arguments';
//     test.shouldThrowError( function()
//     {
//       conDeb1.persist();
//     } );
//   }
//
// };

// --
// proto
// --

var Self =
{

  name : 'Consequence1',
  // verbosity : 7,

  tests :
  {
    simple : simple,
    ordinarMessage : ordinarMessage,

    doThen : doThen,
    doThenAsync : doThenAsync,

    onceGot : onceGot,
    onceThen : onceThen,

    split : split,
    tap : tap,

    ifNoErrorThen : ifNoErrorThen,
    ifErrorThen : ifErrorThen,

    timeOutThen : timeOutThen,

    andThen : andThen,
    _and : _and,
  },

};

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self.name );

} )( );