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
// test part 2
// --

function ordinarMessage( test )
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

    sample.giveMethod = _.nameUnfielded( sample.giveMethod ).coded;

    /**/

    var con = new wConsequence();

    con.got( function( err,data )
    {

      test.identical( arguments[ sample.gotArgument ],1 );
      test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );

    });

    con.got( function( err,data )
    {

      test.identical( arguments[ sample.gotArgument ],2 );
      test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );

    });

    con[ sample.giveMethod ]( 1 );
    con[ sample.giveMethod ]( 2 );
    con[ sample.giveMethod ]( 3 );
    con[ sample.giveMethod ]( 4 );

    con.got( function( err,data )
    {

      test.identical( arguments[ sample.gotArgument ],3 );
      test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );

    });

    con.got( function( err,data )
    {

      test.identical( arguments[ sample.gotArgument ],4 );
      test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );

    });

    con.got( function( err,data )
    {

      test.identical( arguments[ sample.gotArgument ],5 );
      test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );

    });

    con.got( function( err,data )
    {

      test.identical( arguments[ sample.gotArgument ],6 );
      test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );

    });

    con[ sample.giveMethod ]( 5 );
    con[ sample.giveMethod ]( 6 );

    /**/

    var con = new wConsequence();

    con[ sample.giveMethod ]( 1 );
    con[ sample.giveMethod ]( 2 );

    con.got( function( err,data )
    {

      test.identical( arguments[ sample.gotArgument ],1 );
      test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );

    });

    con.got( function( err,data )
    {

      test.identical( arguments[ sample.gotArgument ],2 );
      test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );

    });

    con.got( function( err,data )
    {

      test.identical( arguments[ sample.gotArgument ],3 );
      test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );

    });

    con.got( function( err,data )
    {

      test.identical( arguments[ sample.gotArgument ],4 );
      test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );

    });

    con[ sample.giveMethod ]( 3 );
    con[ sample.giveMethod ]( 4 );
    con[ sample.giveMethod ]( 5 );
    con[ sample.giveMethod ]( 6 );

    con.got( function( err,data )
    {

      test.identical( arguments[ sample.gotArgument ],5 );
      test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );

    });

    con.got( function( err,data )
    {

      test.identical( arguments[ sample.gotArgument ],6 );
      test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );

    });

  }

}

//

function persistantMessage( test )
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

    sample.giveMethod = _.nameUnfielded( sample.giveMethod ).coded;

    /**/

    var con = new wConsequence();

    con.persist( ( function(){ var first = 1; return function( err,data )
    {

      debugger;
      test.description = 'first message got with persist';
      test.identical( arguments[ sample.gotArgument ],first );
      test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );
      //test.identical( arguments[ sample.gotArgument ] !== 3,true );
      first += 1;

    }}()) );

    con[ sample.giveMethod ]( 1 );
    con[ sample.giveMethod ]( 2 );
    con.correspondentsClear();

    /**/

    var got8 = 0;

    con.persist( ( function(){ var first = 3; return function( err,data )
    {

      test.description = 'second message got with persist';
      test.identical( arguments[ sample.gotArgument ],first );
      test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );
      first += 1;

      if( arguments[ sample.gotArgument ] === 8 )
      got8 += 1;

    }}()) );

    con.persist( ( function(){ var first = 3; return function( err,data )
    {

      test.description = 'third message got with persist';
      test.identical( arguments[ sample.gotArgument ],first );
      test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );
      first += 1;

      if( arguments[ sample.gotArgument ] === 8 )
      got8 += 1;

    }}()) );

    con[ sample.giveMethod ]( 3 );
    con[ sample.giveMethod ]( 4 );
    con[ sample.giveMethod ]( 5 );
    con[ sample.giveMethod ]( 6 );

    con.persist( ( function(){ var first = 7; return function( err,data )
    {

      test.description = 'got many messages with persist';
      test.identical( arguments[ sample.gotArgument ],first );
      test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );
      first += 1;

      if( arguments[ sample.gotArgument ] === 8 )
      got8 += 1;

    }}()) );

    con[ sample.giveMethod ]( 7 );
    con[ sample.giveMethod ]( 8 );

    test.identical( got8,3 );

    /**/

    var got2 = 0;
    var con = new wConsequence();

    con[ sample.giveMethod ]( 1 );
    con[ sample.giveMethod ]( 2 );

    con.persist( ( function(){ var first = 1; return function( err,data )
    {

      test.description = 'got two messages with persist';
      test.identical( arguments[ sample.gotArgument ],first );
      test.identical( arguments[ sample.anotherArgument ],sample.anotherArgumentValue );
      first += 1;

      if( arguments[ sample.gotArgument ] === 2 )
      got2 += 1;

    }}()) );

    con.persist( ( function(){ var first = 7; return function( err,data )
    {

      test.description = 'should never happened';
      test.identical( false,true );

    }}()) );

    _.timeOut( 25, function()
    {
      test.description = 'got one only messages';
      test.identical( got2,1 );
    });

  }

}

//

function then( test )
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

//

function thenSealed_( test )
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
          { err : null, value : 4, takerId : 'taker2' }
        ],
        throwErr : false
      }
    },
    testCase4 =
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
          {
            err : null,
            value : 5,
            takerId : 'taker1',
            context : 'ContextConstructor',
            sealed : 'bar' ,
            contVariable : 'foo'
          },
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
      con.thenSealed( null, testTaker1, [] );
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
      con.thenSealed( null, testTaker1, [] );
    }
    catch( err )
    {
      got.throwErr = !! err;
    }
    test.identical( got, expected );
  } )( testCase2 );

  /**/

  test.description = 'test thenSealed in chain';

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

    var con = wConsequence();
    for (let given of givSequence)
      con.give( given );

    try
    {
      con.thenSealed( null, testTaker1, [] );
      con.thenSealed( null, testTaker2, [] );
    }
    catch( err )
    {
      got.throwErr = !! err;
    }
    test.identical( got, expected );
  } )( testCase3 );

  /* test particular gotOnce features test. */

  test.description = 'thenSealed with sealed context and argument';
  ( function ( { givSequence, got, expected }  )
  {
    function testTaker1( sealed, err, value )
    {
      console.log( sealed + err + value )
      var takerId = 'taker1',
        context = this.constructor.name,
        contVariable = this.contVariable;
        got.gotSequence.push( { err, value, takerId, context, contVariable, sealed } );
    }

    function ContextConstructor()
    {
      this.contVariable = 'foo';
    }

    var con = wConsequence();

    for( let given of givSequence )
    {
      con.give( given );
    }

    try
    {
      con.thenSealed( new ContextConstructor(), testTaker1, [ 'bar' ] );
    }
    catch( err )
    {
      console.log(err);
      got.throwErr = !! err;
    }
    console.log(JSON.stringify(expected));
    test.identical( got, expected );
  } )( testCase4 );


  if( Config.debug )
  {
    var conDeb1 = wConsequence();

    test.description = 'missed context arguments';
    test.shouldThrowError( function()
    {
      conDeb1.thenSealed( function( err, val) { logger.log( 'foo' ); } );
    } );
  }

};

//

function thenClone( test )
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
        [ 5 ],
      got :
      {
        gotSequence : [],
        throwErr : false
      },
      expected :
      {
        gotSequence : [ ],
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
          ],
        throwErr : false
      }
    };


  /* common wConsequence corespondent tests. */

  test.description = 'then clone : run after resolve value';
  ( function ( { givSequence, got, expected }  )
  {
    function testTaker1( err, value )
    {
      var takerId = 'taker1';
      got.gotSequence.push( { err, value, takerId } );
    }

    var newCon;
    var con = wConsequence();
    con.give( givSequence.shift() );
    try
    {
      newCon = con.thenClone();
      newCon.got( testTaker1 )
    }
    catch( err )
    {
      got.throwErr = !! err;
    }
    test.identical( got, expected );
  } )( testCase1 );

  /**/

  test.description = 'then clone : run before resolve value';
  ( function ( { givSequence, got, expected }  )
  {
    function testTaker1( err, value )
    {
      var takerId = 'taker1';
      got.gotSequence.push( { err, value, takerId } );
    }

    var newCon;
    var con = wConsequence();
    try
    {
      newCon = con.thenClone();
      newCon.got( testTaker1 );
      con.give( givSequence.shift() );
    }
    catch( err )
    {
      got.throwErr = !! err;
    }
    test.identical( got, expected );
  } )( testCase2 );

  /**/

  test.description = 'test thenSealed in chain';

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

    var con = wConsequence();
    for (let given of givSequence)
      con.give( given );

    var newCon;
    try
    {
      newCon = con.thenClone();
      newCon.got( testTaker1 );
      newCon.got( testTaker2 );
    }
    catch( err )
    {
      got.throwErr = !! err;
    }
    test.identical( got, expected );
  } )( testCase3 );
};

//

function thenReportError( test )
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
          [],
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
            { err : null, value : 4, takerId : 'taker2' }
          ],
        throwErr : false
      }
    },
    testCase4 =
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
            { err : null, value : 4, takerId : 'taker2' }
          ],
        throwErr : false
      }
    };


  /* common wConsequence corespondent tests. */

  test.description = 'single value in give sequence';
  ( function ( { givSequence, got, expected }  )
  {
    var con = wConsequence();
    con.give( givSequence.shift() );
    try
    {
      con.thenReportError();
    }
    catch( err )
    {
      got.throwErr = !! err;
    }
    test.identical( got, expected );
  } )( testCase1 );

  /**/

  test.description = 'single err in give sequence';
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
      con.thenReportError();
    }
    catch( err )
    {
      got.throwErr = !! err;
    }
    test.identical( got, expected );
  } )( testCase2 );

  /**/

  test.description = 'test thenSealed in chain';

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

    var con = wConsequence();
    for (let given of givSequence)
      con.give( given );

    try
    {
      con.thenReportError();
      con.got( testTaker1 );
      con.got( testTaker2 );
    }
    catch( err )
    {
      got.throwErr = !! err;
    }
    test.identical( got, expected );
  } )( testCase3 );
  //
  /* test particular gotOnce features test. */

  test.description = 'test thenSealed in chain #2';
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

    var con = wConsequence();
    try
    {
      con.thenReportError();
      con.got( testTaker1 );
      con.got( testTaker2 );
    }
    catch( err )
    {
      got.throwErr = !! err;
    }

    for (let given of givSequence)
      con.give( given );

    test.identical( got, expected );
  } )( testCase4 );


  if( Config.debug )
  {
    var conDeb1 = wConsequence();

    test.description = 'called thenReportError with any argument';
    test.shouldThrowError( function()
    {
      conDeb1.thenReportError( function( err, val) { logger.log( 'foo' ); } );
    } );
  }

};

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

    var  conOwner = wConsequence();

    conOwner.give();

    con1.got( testTaker1 );
    con2.got( testTaker2 );

    try
    {
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

    // part 2

    ordinarMessage : ordinarMessage,
    // persistantMessage : persistantMessage,

    then : then,
    // thenSealed_ : thenSealed_,
    // thenReportError : thenReportError,
    // thenClone : thenClone,
    tap : tap,
    ifErrorThen : ifErrorThen,
    ifNoErrorThen : ifNoErrorThen,

    timeOutThen : timeOutThen,

    _and : _and

  },

};

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self.name );

} )( );
