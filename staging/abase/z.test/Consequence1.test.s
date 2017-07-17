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

function ordinarMessage( test )
{
  var self = this;

  var samples =
  [

    {
      giveMethod : 'give',
      argIndex : 1,
      anotherIndex : 0,
      anotherValue : null,
    },

    {
      giveMethod : 'error',
      argIndex : 0,
      anotherIndex : 1,
      anotherValue : undefined,
    },

  ];

  //

  for( var s = 0 ; s < samples.length ; s++ )
  {
    var sample = samples[ s ];

    test.description = sample.giveMethod;

    /**/

    var con = new wConsequence();

    con.got( function( err,data )
    {

      test.identical( arguments[ sample.argIndex ],1 );
      test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );

    });

    con.got( function( err,data )
    {

      test.identical( arguments[ sample.argIndex ],2 );
      test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );

    });

    con[ sample.giveMethod ]( 1 );
    con[ sample.giveMethod ]( 2 );
    con[ sample.giveMethod ]( 3 );
    con[ sample.giveMethod ]( 4 );

    con.got( function( err,data )
    {

      test.identical( arguments[ sample.argIndex ],3 );
      test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );

    });

    con.got( function( err,data )
    {

      test.identical( arguments[ sample.argIndex ],4 );
      test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );

    });

    con.got( function( err,data )
    {

      test.identical( arguments[ sample.argIndex ],5 );
      test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );

    });

    con.got( function( err,data )
    {

      test.identical( arguments[ sample.argIndex ],6 );
      test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );

    });

    con[ sample.giveMethod ]( 5 );
    con[ sample.giveMethod ]( 6 );

    /**/

    var con = new wConsequence();

    con[ sample.giveMethod ]( 1 );
    con[ sample.giveMethod ]( 2 );

    con.got( function( err,data )
    {

      test.identical( arguments[ sample.argIndex ],1 );
      test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );

    });

    con.got( function( err,data )
    {

      test.identical( arguments[ sample.argIndex ],2 );
      test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );

    });

    con.got( function( err,data )
    {

      test.identical( arguments[ sample.argIndex ],3 );
      test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );

    });

    con.got( function( err,data )
    {

      test.identical( arguments[ sample.argIndex ],4 );
      test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );

    });

    con[ sample.giveMethod ]( 3 );
    con[ sample.giveMethod ]( 4 );
    con[ sample.giveMethod ]( 5 );
    con[ sample.giveMethod ]( 6 );

    con.got( function( err,data )
    {

      test.identical( arguments[ sample.argIndex ],5 );
      test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );

    });

    con.got( function( err,data )
    {

      test.identical( arguments[ sample.argIndex ],6 );
      test.identical( arguments[ sample.anotherIndex ],sample.anotherValue );

    });

  }

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

function then( test )
{
  var self = this;

  var samples =
  [

    {
      giveMethod : { give : 'give' },
      argIndex : 1,
      anotherIndex : 0,
      anotherValue : null,
    },

    {
      giveMethod : { error : 'error' },
      argIndex : 0,
      anotherIndex : 1,
      anotherValue : undefined,
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
    then : then,
    andThen : andThen,

  },

};

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self.name );

} )( );
