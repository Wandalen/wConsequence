( function( ) {

  'use strict';

  if( typeof module !== 'undefined' )
  {
    try
    {
      require( 'wTesting' );
    }
    catch( err )
    {
      require( '../../amid/diagnostic/Testing.debug.s' );
    }
  }

  _global_.wTests = _global_.wTests === undefined ? {} : _global_.wTests;

  var _ = wTools;
  var Self = {};

  // --
  // test
  // --

  var gotOnce = function( test )
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
          givSequence: [ 5, 4  ],
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

      var testHandler = function( err, val) { logger.log( 'i em anonymous' ); }
      test.shouldThrowError( function()
      {
        conDeb2.gotOnce( testHandler );
      } );
    }

    conseqTester.give();
    return conseqTester;
  };

  // --
  // proto
  // --

  var Proto =
  {

    verbose : 1,
    tests :
    {

      gotOnce: gotOnce,

    },
    name : 'Consequence experimental features',

  };

  Object.setPrototypeOf( Self, Proto );
  wTests[ Self.name ] = Self;

  if( typeof module !== 'undefined' && !module.parent )
    _.testing.test( Self );

} )( );
