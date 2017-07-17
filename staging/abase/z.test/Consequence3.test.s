( function _Consequence3_test_s_( ) {

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

function gotOnce( test )
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
    con.gotOnce( testTaker1 );
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
    con.gotOnce( testTaker1 );
    test.identical( gotSequence, expectedSequence );
  } )( testCases[ 1 ] );

  /**/

  test.description = 'test gotOnce in chain';

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

    con.gotOnce( testTaker1 );
    con.gotOnce( testTaker2 );
    test.identical( gotSequence, expectedSequence );
  } )( testCases[ 2 ] );

  /* test particular gotOnce features test. */

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

    con.gotOnce( testTaker1 );
    con.gotOnce( testTaker1 );
    con.gotOnce( testTaker2 );
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

    con.gotOnce( testTaker1 );
    con.gotOnce( testTaker1 );
    con.gotOnce( testTaker2 );

    for( let given of givSequence ) // pass all values in givSequence to consequenced
    {
      con.give( given );
    }

    test.identical( gotSequence, expectedSequence );
  } )( testCases[ 4 ] );

  /**/

  if( Config.debug )
  {
    var conDeb1 = wConsequence();

    test.description = 'try to pass as parameter anonymous function';
    test.shouldThrowError( function()
    {
      conDeb1.gotOnce( function( err, val) { logger.log( 'i em anonymous' ); } );
    } );

    var conDeb2 = wConsequence();

    test.description = 'try to pass as parameter anonymous function (defined in expression)';

    function testHandler( err, val) { logger.log( 'i em anonymous' ); }
    test.shouldThrowError( function()
    {
      conDeb2.gotOnce( testHandler );
    } );
  }

  conseqTester.give();
  return conseqTester;
}

//

function thenOnce( test )
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
      con.thenOnce( testTaker1 );
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
      con.thenOnce( testTaker1 );
    }
    catch( err )
    {
      got.throwErr = !! err;
    }
    test.identical( got, expected );
  } )( testCase2 );

  /**/

  test.description = 'test thenOnce in chain';

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
      con.thenOnce( testTaker1 );
      con.thenOnce( testTaker2 );
      con.got( testTaker3 );
    }
    catch( err )
    {
      got.throwErr = !! err;
    }
    test.identical( got, expected );
  } )( testCase3 );

  /* test particular thenOnce features test. */

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
      con.thenOnce( testTaker1 );
      con.thenOnce( testTaker1 );
      con.thenOnce( testTaker2 );

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
      conDeb1.thenOnce( function( err, val) { logger.log( 'i em anonymous' ); } );
    } );

    var conDeb2 = wConsequence();

    test.description = 'try to pass as parameter anonymous function (defined in expression)';

    function testHandler( err, val) { logger.log( 'i em anonymous' ); }
    test.shouldThrowError( function()
    {
      conDeb2.thenOnce( testHandler );
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
//   test.description = 'test thenOnce in chain';
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

  name : 'Consequence3',

  tests :
  {

    gotOnce : gotOnce,
    thenOnce : thenOnce,

  },

};

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self.name );

} )( );
