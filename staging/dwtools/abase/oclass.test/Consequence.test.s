( function _Consequence_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../dwtools/Base.s';
    let toolsExternal = 0;
    try
    {
      toolsPath = require.resolve( toolsPath );
    }
    catch( err )
    {
      toolsExternal = 1;
      require( 'wTools' );
    }
    if( !toolsExternal )
    require( toolsPath );
  }

  var _ = _global_.wTools;

  require( '../oclass/Consequence.s' );

  _.include( 'wTesting' );

}

var _global = _global_;
var _ = _global_.wTools;

// --
// test
// --

function simple( test )
{
  var self = this;

  test.description = 'class checks'; //

  test.is( _.routineIs( wConsequence.prototype.passThru ) );
  test.is( _.routineIs( wConsequence.passThru ) );
  test.is( _.objectIs( wConsequence.prototype.KindOfArguments ) );
  test.is( _.objectIs( wConsequence.KindOfArguments ) );
  test.is( wConsequence.name === 'wConsequence' );
  test.is( wConsequence.nameShort === 'Consequence' );

  test.description = 'construction'; //

  debugger;
  var con1 = new _.Consequence().give( 1 );
  var con2 = _.Consequence().give( 2 );
  var con3 = con2.clone();

  test.identical( con1.messagesGet().length,1 );
  test.identical( con2.messagesGet().length,1 );
  test.identical( con3.messagesGet().length,1 );

  test.description = 'class test'; //

  test.is( _.consequenceIs( con1 ) );
  test.is( con1 instanceof wConsequence );
  test.is( _.consequenceIs( con2 ) );
  test.is( con2 instanceof wConsequence );
  test.is( _.consequenceIs( con3 ) );
  test.is( con3 instanceof wConsequence );

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

function andGot( test )
{
  var testMsg = 'msg';
  var testCon = new _.Consequence().give()

   /* */

  .doThen( function()
  {
    test.description = 'andGot waits only for first message, dont return the message';
    var delay = 100;
    var mainCon = new _.Consequence();
    var con = new _.Consequence();

    mainCon.give( testMsg );

    mainCon.andGot( con );

    mainCon.doThen( function( err, got )
    {
      test.identical( got, [ delay, testMsg ] )
      test.identical( mainCon.messagesGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
      test.identical( con.correspondentsEarlyGet().length, 0 );
    });

    _.timeOut( delay, () => { con.give( delay ) });
    _.timeOut( delay * 2, () => { con.give( delay * 2 ) });

    return _.timeOut( delay * 2, function()
    {
      test.identical( con.messagesGet().length, 1 );
      test.identical( con.messagesGet()[ 0 ].argument, delay * 2 );
    })
  })

  /* */

  .doThen( function()
  {
    test.description = 'dont give message back to single consequence returned from passed routine';
    var delay = 100;
    var mainCon = new _.Consequence();
    var con = new _.Consequence();

    mainCon.give( testMsg );

    mainCon.andGot( () => con );

    mainCon.doThen( function( err, got )
    {
      test.identical( got, [ delay, testMsg ] );
      test.identical( mainCon.messagesGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
      test.identical( con.correspondentsEarlyGet().length, 0 );
    });

    _.timeOut( delay, () => { con.give( delay ) });

    return mainCon;
  })

  /* */

  .doThen( function()
  {
    test.description = 'dont give messages back to several consequences with different delays';
    var delay = 100;
    var mainCon = new _.Consequence();
    var con1 = new _.Consequence();
    var con2 = new _.Consequence();
    var con3 = new _.Consequence();

    var srcs = [ con1, con2, con3 ];

    mainCon.give( testMsg );

    mainCon.andGot( srcs );

    mainCon.doThen( function( err, got )
    {
      test.identical( got, [ delay, delay * 2, testMsg + testMsg, testMsg ] );

      test.identical( mainCon.messagesGet().length, 0 );

      test.identical( con1.messagesGet(), []);
      test.identical( con1.correspondentsEarlyGet().length, 0 );

      test.identical( con2.messagesGet(), []);
      test.identical( con2.correspondentsEarlyGet().length, 0 );

      test.identical( con3.messagesGet(), []);
      test.identical( con3.correspondentsEarlyGet().length, 0 );
    });

    _.timeOut( delay, () => { con1.give( delay ) });
    _.timeOut( delay * 2, () => { con2.give( delay * 2 ) });
    con3.give( testMsg + testMsg );

    return mainCon;
  })

  /* */

  .doThen( function()
  {
    test.description = 'each con gives several messages, order of provided consequence is important';
    var delay = 100;
    var mainCon = new _.Consequence();
    var con1 = new _.Consequence();
    var con2 = new _.Consequence();
    var con3 = new _.Consequence();

    var srcs = [ con3, con1, con2  ];

    mainCon.give( testMsg );

    mainCon.andGot( srcs );

    mainCon.doThen( function( err, got )
    {
      test.identical( got, [ 'con3', 'con1', 'con2', testMsg ] );

      test.identical( mainCon.messagesGet().length, 0 );

      test.identical( con1.messagesGet().length, 2 );
      test.identical( con1.correspondentsEarlyGet().length, 0 );

      test.identical( con2.messagesGet().length, 2 );
      test.identical( con2.correspondentsEarlyGet().length, 0 );

      test.identical( con3.messagesGet().length, 2 );
      test.identical( con3.correspondentsEarlyGet().length, 0 );
    });

    _.timeOut( delay, () =>
    {
      con1.give( 'con1' );
      con1.give( 'con1' );
      con1.give( 'con1' );
    });

    _.timeOut( delay * 2, () =>
    {
      con2.give( 'con2' );
      con2.give( 'con2' );
      con2.give( 'con2' );
    });

    _.timeOut( delay / 2, () =>
    {
      con3.give( 'con3' );
      con3.give( 'con3' );
      con3.give( 'con3' );
    });

    return mainCon;
  })

  /* */

  .doThen( function()
  {
    test.description = 'one of provided cons waits for another one to resolve';
    var delay = 100;
    var mainCon = new _.Consequence();
    var con1 = new _.Consequence();
    var con2 = new _.Consequence();

    var srcs = [ con1, con2  ];

    con1.give();
    con1.doThen( () => con2 );
    con1.doThen( () => 'con1' );

    mainCon.give( testMsg );

    mainCon.andGot( srcs );

    mainCon.doThen( function( err, got )
    {
      test.identical( got, [ 'con1', 'con2', testMsg ] );

      test.identical( mainCon.messagesGet().length, 0 );

      test.identical( con1.messagesGet().length, 0 );
      test.identical( con1.correspondentsEarlyGet().length, 0 );

      test.identical( con2.messagesGet().length, 0 );
      test.identical( con2.correspondentsEarlyGet().length, 0 );

    });

    _.timeOut( delay * 2, () => { con2.give( 'con2' )  } )

    return mainCon;
  })

  .doThen( function()
  {
    test.description = 'consequence gives an error, only first error is taken into account';

    var delay = 100;
    var mainCon = new _.Consequence();
    var con1 = new _.Consequence();
    var con2 = new _.Consequence();

    var srcs = [ con1, con2  ];

    mainCon.give( testMsg );

    mainCon.andGot( srcs );

    mainCon.doThen( function( err, got )
    {
      test.identical( err, 'con1' );
      test.identical( got, undefined );

      test.identical( mainCon.messagesGet().length, 0 );

      test.identical( con1.messagesGet().length, 0 );
      test.identical( con1.correspondentsEarlyGet().length, 0 );

      test.identical( con2.messagesGet().length, 0 );
      test.identical( con2.correspondentsEarlyGet().length, 0 );
    });

    _.timeOut( delay, () => { con1.error( 'con1' )  } )
    var t = _.timeOut( delay * 2, () => { con2.give( 'con2' )  } )

    t.doThen( () =>
    {
      test.identical( con2.messagesGet().length, 0 );
      test.identical( con2.correspondentsEarlyGet().length, 0 );
      return mainCon;
    })

    return t;
  })

  /* */

  .doThen( function()
  {
    test.description = 'passed consequence dont give any message';
    var mainCon = new _.Consequence();
    var con = new _.Consequence();
    mainCon.give();
    mainCon.andGot( con );
    mainCon.doThen( () => test.identical( 0, 1 ) );
    test.identical( mainCon.messagesGet().length, 0 );
    test.identical( mainCon.correspondentsEarlyGet().length, 1 );
    test.identical( con.messagesGet().length, 0 );
  })

  /* */

  .doThen( function()
  {
    test.description = 'returned consequence dont give any message';
    var mainCon = new _.Consequence();
    var con = new _.Consequence();
    mainCon.give();
    mainCon.andGot( () => con );
    mainCon.doThen( () => test.identical( 0, 1 ) );
    test.identical( mainCon.messagesGet().length, 0 );
    test.identical( mainCon.correspondentsEarlyGet().length, 1 );
    test.identical( con.messagesGet().length, 0 );
  })

  /* */

  .doThen( function()
  {
    test.description = 'one of srcs dont give any message';
    var delay = 100;
    var mainCon = new _.Consequence();
    var con1 = new _.Consequence();
    var con2 = new _.Consequence();
    var con3 = new _.Consequence();

    var srcs = [ con1, con2, con3 ];

    mainCon.give( testMsg );

    mainCon.andGot( srcs );

    mainCon.doThen( () => test.identical( 0, 1) );

    _.timeOut( delay, () => { con1.give( delay ) });
    _.timeOut( delay * 2, () => { con2.give( delay * 2 ) });

    return _.timeOut( delay * 2, function()
    {
      test.identical( mainCon.messagesGet().length, 0 );
      test.identical( mainCon.correspondentsEarlyGet().length, 1 );

      test.identical( con1.messagesGet().length, 0);
      test.identical( con2.messagesGet().length, 0);
      test.identical( con3.messagesGet().length, 0);
    });

  })

  return testCon;
}

//

function andThen( test )
{
  var testMsg = 'msg';
  var testCon = new _.Consequence().give()

  /* */

  .doThen( function()
  {
    test.description = 'andThen waits only for first message and return it back';
    var delay = 100;
    var mainCon = new _.Consequence();
    var con = new _.Consequence();

    mainCon.give( testMsg );

    mainCon.andThen( con );

    mainCon.doThen( function( err, got )
    {
      test.identical( got, [ delay, testMsg ] );
      test.identical( mainCon.messagesGet().length, 0 );
      test.identical( con.messagesGet(), [{ error : undefined, argument : delay }] );
      test.identical( con.correspondentsEarlyGet().length, 0 );
    });

    _.timeOut( delay, () => { con.give( delay ) });
    _.timeOut( delay * 2, () => { con.give( delay * 2 ) });

    return _.timeOut( delay * 2, function()
    {
      test.identical( con.messagesGet().length, 2 );
      test.identical( con.messagesGet()[ 1 ].argument, delay * 2 );
    })
  })

  /* */

  .doThen( function()
  {
    test.description = 'andThen waits for first message from consequence returned by routine call and returns message back';
    var delay = 100;
    var mainCon = new _.Consequence();
    var con = new _.Consequence();

    mainCon.give( testMsg );

    mainCon.andThen( () => con );

    mainCon.doThen( function( err, got )
    {
      test.identical( got, [ delay, testMsg ] );
      test.identical( mainCon.messagesGet().length, 0 );
      test.identical( con.messagesGet().length, 1 );
      test.identical( con.messagesGet()[ 0 ], { error : undefined, argument : delay } );
      test.identical( con.correspondentsEarlyGet().length, 0 );
    });

    _.timeOut( delay, () => { con.give( delay ) });
    _.timeOut( delay * 2, () => { con.give( delay * 2 ) });

    return _.timeOut( delay * 2, function()
    {
      test.identical( con.messagesGet().length, 2 );
      test.identical( con.messagesGet()[ 1 ], { error : undefined, argument : delay * 2 } );
    })
  })

  /* */

  .doThen( function()
  {
    test.description = 'give back messages to several consequences, different delays';
    var delay = 100;
    var mainCon = new _.Consequence();
    var con1 = new _.Consequence();
    var con2 = new _.Consequence();
    var con3 = new _.Consequence();

    var srcs = [ con1, con2, con3 ];

    mainCon.give( testMsg );

    mainCon.andThen( srcs );

    mainCon.doThen( function( err, got )
    {
      test.identical( got, [ delay, delay * 2, testMsg + testMsg, testMsg ] )
      test.identical( mainCon.messagesGet().length, 0 );

      test.identical( con1.messagesGet(), [ { error : undefined, argument : delay } ]);
      test.identical( con1.correspondentsEarlyGet().length, 0 );

      test.identical( con2.messagesGet(), [ { error : undefined, argument : delay * 2 } ]);
      test.identical( con2.correspondentsEarlyGet().length, 0 );

      test.identical( con3.messagesGet(), [ { error : undefined, argument : testMsg + testMsg } ]);
      test.identical( con3.correspondentsEarlyGet().length, 0 );
    });

    _.timeOut( delay, () => { con1.give( delay ) });
    _.timeOut( delay * 2, () => { con2.give( delay * 2 ) });
    con3.give( testMsg + testMsg );

    return mainCon;
  })

  /* */

  .doThen( function()
  {
    test.description = 'each con gives several messages, order of provided consequence is important';
    var delay = 100;
    var mainCon = new _.Consequence();
    var con1 = new _.Consequence();
    var con2 = new _.Consequence();
    var con3 = new _.Consequence();

    var srcs = [ con3, con1, con2  ];

    mainCon.give( testMsg );

    mainCon.andThen( srcs );

    mainCon.doThen( function( err, got )
    {
      test.identical( got, [ 'con3', 'con1', 'con2', testMsg ] );
      test.identical( mainCon.messagesGet().length, 0 );

      test.identical( con1.messagesGet().length, 3 );
      test.identical( con1.correspondentsEarlyGet().length, 0 );

      test.identical( con2.messagesGet().length, 3 );
      test.identical( con2.correspondentsEarlyGet().length, 0 );

      test.identical( con3.messagesGet().length, 3 );
      test.identical( con3.correspondentsEarlyGet().length, 0 );
    });

    _.timeOut( delay, () =>
    {
      con1.give( 'con1' );
      con1.give( 'con1' );
      con1.give( 'con1' );
    });

    _.timeOut( delay * 2, () =>
    {
      con2.give( 'con2' );
      con2.give( 'con2' );
      con2.give( 'con2' );
    });

    _.timeOut( delay / 2, () =>
    {
      con3.give( 'con3' );
      con3.give( 'con3' );
      con3.give( 'con3' );
    });

    return mainCon;
  })

  /* */

  .doThen( function()
  {
    test.description = 'one of provided cons waits for another one to resolve';
    var delay = 100;
    var mainCon = new _.Consequence();
    var con1 = new _.Consequence();
    var con2 = new _.Consequence();

    var srcs = [ con1, con2  ];

    con1.give();
    con1.doThen( () => con2 );
    con1.doThen( () => 'con1' );

    mainCon.give( testMsg );

    mainCon.andGot( srcs );

    mainCon.doThen( function( err, got )
    {
      test.identical( got, [ 'con1', 'con2', testMsg ] );

      test.identical( mainCon.messagesGet().length, 0 );

      test.identical( con1.messagesGet().length, 0 );
      test.identical( con1.correspondentsEarlyGet().length, 0 );

      test.identical( con2.messagesGet().length, 0 );
      test.identical( con2.correspondentsEarlyGet().length, 0 );

    });

    _.timeOut( delay * 2, () => { con2.give( 'con2' )  } )

    return mainCon;
  })

  .doThen( function()
  {
    test.description =
    `consequence gives an error, only first error is taken into account
     other consequences are receiving their messages back`;

    var delay = 100;
    var mainCon = new _.Consequence();
    var con1 = new _.Consequence();
    var con2 = new _.Consequence();

    var srcs = [ con1, con2  ];

    mainCon.give( testMsg );

    mainCon.andThen( srcs );

    mainCon.doThen( function( err, got )
    {
      test.identical( err, 'con1' );
      test.identical( got, undefined );

      test.identical( mainCon.messagesGet().length, 0 );

      test.identical( con1.messagesGet().length, 1 );
      test.identical( con1.correspondentsEarlyGet().length, 0 );

      test.identical( con2.messagesGet().length, 1 );
      test.identical( con2.correspondentsEarlyGet().length, 0 );
    });

    _.timeOut( delay, () => { con1.error( 'con1' )  } )
    var t = _.timeOut( delay * 2, () => { con2.give( 'con2' )  } )

    t.doThen( () =>
    {
      test.identical( con2.messagesGet().length, 0 );
      test.identical( con2.correspondentsEarlyGet().length, 0 );
      return mainCon;
    })

    return t;
  })

  /* */

  .doThen( function()
  {
    test.description = 'passed consequence dont give any message';
    var mainCon = new _.Consequence();
    var con = new _.Consequence();
    mainCon.give();
    mainCon.andThen( con );
    mainCon.doThen( () => test.identical( 0, 1 ) );
    test.identical( mainCon.messagesGet().length, 0 );
    test.identical( mainCon.correspondentsEarlyGet().length, 1 );
    test.identical( con.messagesGet().length, 0 );
  })

  /* */

  .doThen( function()
  {
    test.description = 'returned consequence dont give any message';
    var mainCon = new _.Consequence();
    var con = new _.Consequence();
    mainCon.give();
    mainCon.andThen( () => con );
    mainCon.doThen( () => test.identical( 0, 1 ) );
    test.identical( mainCon.messagesGet().length, 0 );
    test.identical( mainCon.correspondentsEarlyGet().length, 1 );
    test.identical( con.messagesGet().length, 0 );
  })

  /* */

  .doThen( function()
  {
    test.description = 'one of srcs dont give any message';
    var delay = 100;
    var mainCon = new _.Consequence();
    var con1 = new _.Consequence();
    var con2 = new _.Consequence();
    var con3 = new _.Consequence();

    var srcs = [ con1, con2, con3 ];

    mainCon.give( testMsg );

    mainCon.andThen( srcs );

    mainCon.doThen( () => test.identical( 0, 1) );

    _.timeOut( delay, () => { con1.give( delay ) });
    _.timeOut( delay * 2, () => { con2.give( delay * 2 ) });

    return _.timeOut( delay * 2, function()
    {
      test.identical( mainCon.messagesGet().length, 0 );
      test.identical( mainCon.correspondentsEarlyGet().length, 1 );

      test.identical( con1.messagesGet().length, 0);
      test.identical( con2.messagesGet().length, 0);
      test.identical( con3.messagesGet().length, 0);
    });

  })

  return testCon;
}

//

function ordinarMessage( test )
{
  var c = this;
  var amode = _.Consequence.asyncModeGet();

  test.description = 'give single message';

  var testCon = new _.Consequence().give()

   /* asyncTaking : 0, asyncGiving : 0 */

  .doThen( () => _.Consequence.asyncModeSet([ 0, 0 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.give( 1 );
    test.identical( con.messagesGet().length, 1 );
    con.got( function( err, got )
    {
      test.identical( err, undefined )
      test.identical( got, 1 );
    })
    test.identical( con.messagesGet().length, 0 );
    test.identical( con.correspondentsEarlyGet().length, 0 );
  })

  /* asyncTaking : 1, asyncGiving : 0 */

  .doThen( () => _.Consequence.asyncModeSet([ 1, 0 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.give( 1 );
    test.identical( con.messagesGet().length, 1 );
    con.got( function( err, got )
    {
      test.identical( err, undefined )
      test.identical( got, 1 );
    })
    test.identical( con.messagesGet().length, 1 );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet().length, 0 );
      test.identical( con.correspondentsEarlyGet().length, 0 );
    })
  })

  /* asyncTaking : 0, asyncGiving : 1 */

  .doThen( () => _.Consequence.asyncModeSet([ 0, 1 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.give( 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet().length, 1 );
      test.identical( con.correspondentsEarlyGet().length, 0 );

      con.got( function( err, got )
      {
        test.identical( err, undefined )
        test.identical( got, 1 );
      })
    })
    .doThen( function()
    {
      test.identical( con.messagesGet().length, 0 );
      test.identical( con.correspondentsEarlyGet().length, 0 );
    })
  })

  /* asyncTaking : 1, asyncGiving : 1 */

  .doThen( () => _.Consequence.asyncModeSet([ 1, 1 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.give( 1 );
    con.got( function( err, got )
    {
      test.identical( err, undefined )
      test.identical( got, 1 );
    })
    test.identical( con.messagesGet().length, 1 );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet().length, 0 );
      test.identical( con.correspondentsEarlyGet().length, 0 );
    })
  });

  test.description = 'give several messages';

  /* asyncTaking : 0, asyncGiving : 0 */

  testCon.doThen( () => _.Consequence.asyncModeSet([ 0, 0 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.give( 1 ).give( 2 ).give( 3 );
    test.identical( con.messagesGet().length, 3 );
    con.got( ( err, got ) => test.identical( got, 1 ) );
    con.got( ( err, got ) => test.identical( got, 2 ) );
    con.got( ( err, got ) => test.identical( got, 3 ) );
    test.identical( con.correspondentsEarlyGet().length, 0 );
    test.identical( con.messagesGet().length, 0 );
  })

  /* asyncTaking : 1, asyncGiving : 0 */

  testCon.doThen( () => _.Consequence.asyncModeSet([ 1, 0 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.give( 1 ).give( 2 ).give( 3 );
    con.got( ( err, got ) => test.identical( got, 1 ) );
    con.got( ( err, got ) => test.identical( got, 2 ) );
    con.got( ( err, got ) => test.identical( got, 3 ) );
    test.identical( con.correspondentsEarlyGet().length, 3 );
    test.identical( con.messagesGet().length, 3 );
    return _.timeOut( 1, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
    })
  })

  /* asyncTaking : 0, asyncGiving : 1 */

  testCon.doThen( () => _.Consequence.asyncModeSet([ 0, 1 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.give( 1 ).give( 2 ).give( 3 );

    return _.timeOut( 1, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 3 );

      con.got( ( err, got ) => test.identical( got, 1 ) );
      con.got( ( err, got ) => test.identical( got, 2 ) );
      con.got( ( err, got ) => test.identical( got, 3 ) );
    })
    .doThen( function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
    })
  })

  /* asyncTaking : 1, asyncGiving : 1 */

  testCon.doThen( () => _.Consequence.asyncModeSet([ 1, 1 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.give( 1 ).give( 2 ).give( 3 );
    con.got( ( err, got ) => test.identical( got, 1 ) );
    con.got( ( err, got ) => test.identical( got, 2 ) );
    con.got( ( err, got ) => test.identical( got, 3 ) );
    test.identical( con.correspondentsEarlyGet().length, 3 );
    test.identical( con.messagesGet().length, 3 );
    return _.timeOut( 1, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
    })
  });

  test.description = 'give single error';

  /* asyncTaking : 0, asyncGiving : 0 */

  testCon.doThen( () => _.Consequence.asyncModeSet([ 0, 0 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.error( 'err' );
    test.identical( con.messagesGet().length, 1 );
    con.got( function( err, got )
    {
      test.identical( err, 'err' )
      test.identical( got, undefined );
    })
    test.identical( con.messagesGet().length, 0 );
    test.identical( con.correspondentsEarlyGet().length, 0 );
  })

  /* asyncTaking : 1, asyncGiving : 0 */

  .doThen( () => _.Consequence.asyncModeSet([ 1, 0 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.error( 'err' );
    test.identical( con.messagesGet().length, 1 );
    con.got( function( err, got )
    {
      test.identical( err, 'err' )
      test.identical( got, undefined );
    })
    test.identical( con.messagesGet().length, 1 );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet().length, 0 );
      test.identical( con.correspondentsEarlyGet().length, 0 );
    })
  })

  /* asyncTaking : 0, asyncGiving : 1 */

  .doThen( () => _.Consequence.asyncModeSet([ 0, 1 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.error( 'err' );

    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet().length, 1 );
      test.identical( con.correspondentsEarlyGet().length, 0 );

      con.got( function( err, got )
      {
        test.identical( err, 'err' )
        test.identical( got, undefined );
      })
    })
    .doThen( function()
    {
      test.identical( con.messagesGet().length, 0 );
      test.identical( con.correspondentsEarlyGet().length, 0 );
    })
  })

  /* asyncTaking : 1, asyncGiving : 1 */

  .doThen( () => _.Consequence.asyncModeSet([ 1, 1 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.error( 'err' );
    con.got( function( err, got )
    {
      test.identical( err, 'err' )
      test.identical( got, undefined );
    })
    test.identical( con.messagesGet().length, 1 );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet().length, 0 );
      test.identical( con.correspondentsEarlyGet().length, 0 );
    })
  });

  test.description = 'give several error messages';

  /* asyncTaking : 0, asyncGiving : 0 */

  testCon.doThen( () => _.Consequence.asyncModeSet([ 0, 0 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.error( 'err1' ).error( 'err2' ).error( 'err3' );
    test.identical( con.messagesGet().length, 3 );
    con.got( ( err, got ) => test.identical( err, 'err1' ) );
    con.got( ( err, got ) => test.identical( err, 'err2' ) );
    con.got( ( err, got ) => test.identical( err, 'err3' ) );
    test.identical( con.correspondentsEarlyGet().length, 0 );
    test.identical( con.messagesGet().length, 0 );
  })

  /* asyncTaking : 1, asyncGiving : 0 */

  testCon.doThen( () => _.Consequence.asyncModeSet([ 1, 0 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.error( 'err1' ).error( 'err2' ).error( 'err3' );
    con.got( ( err, got ) => test.identical( err, 'err1' ) );
    con.got( ( err, got ) => test.identical( err, 'err2' ) );
    con.got( ( err, got ) => test.identical( err, 'err3' ) );
    test.identical( con.correspondentsEarlyGet().length, 3 );
    test.identical( con.messagesGet().length, 3 );
    return _.timeOut( 1, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
    })
  })

  /* asyncTaking : 0, asyncGiving : 1 */

  testCon.doThen( () => _.Consequence.asyncModeSet([ 0, 1 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.error( 'err1' ).error( 'err2' ).error( 'err3' );

    return _.timeOut( 1, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 3 );

      con.got( ( err, got ) => test.identical( err, 'err1' ) );
      con.got( ( err, got ) => test.identical( err, 'err2' ) );
      con.got( ( err, got ) => test.identical( err, 'err3' ) );
    })
    .doThen( function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
    })
  })

  /* asyncTaking : 1, asyncGiving : 1 */

  testCon.doThen( () => _.Consequence.asyncModeSet([ 1, 1 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.error( 'err1' ).error( 'err2' ).error( 'err3' );
    con.got( ( err, got ) => test.identical( err, 'err1' ) );
    con.got( ( err, got ) => test.identical( err, 'err2' ) );
    con.got( ( err, got ) => test.identical( err, 'err3' ) );
    test.identical( con.correspondentsEarlyGet().length, 3 );
    test.identical( con.messagesGet().length, 3 );
    return _.timeOut( 1, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
    })
  });

  /* */

  testCon.doThen( () => _.Consequence.asyncModeSet( amode ) );
  return testCon;
}

//

function promiseGot( test )
{
  var testMsg = 'testMsg';
  var testCon = new _.Consequence().give()

  /* */

  .doThen( function()
  {
    test.description = 'no message';
    var con = new _.Consequence();
    var promise = con.promiseGot();
    test.identical( con.messagesGet().length, 0 );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    promise.then( function( got )
    {
      test.identical( 0, 1 );
    })
  })

  /* */

  .doThen( function()
  {
    test.description = 'single message';
    var con = new _.Consequence();
    con.give( testMsg );
    test.identical( con.messagesGet().length, 1 );
    var promise = con.promiseGot();
    promise.then( function( got )
    {
      test.identical( got, testMsg );
      test.is( _.promiseIs( promise ) );
      test.identical( con.messagesGet().length, 0 );
      test.identical( con.correspondentsEarlyGet().length, 0 );
    })
    return wConsequence.from( promise );
  })

  /* */

  .doThen( function()
  {
    test.description = 'single error';
    var con = new _.Consequence();
    con.error( testMsg );
    test.identical( con.messagesGet().length, 1 );
    var promise = con.promiseGot();
    promise.catch( function( err )
    {
      test.identical( err, testMsg );
      test.is( _.promiseIs( promise ) );
      test.identical( con.messagesGet().length, 0 );
      test.identical( con.correspondentsEarlyGet().length, 0 );
    })
    return wConsequence.from( promise );
  })

  /* */

  .doThen( function()
  {
    test.description = 'several messages';
    var con = new _.Consequence();
    con.give( testMsg  + 1 );
    con.give( testMsg  + 2 );
    con.give( testMsg  + 3 );
    test.identical( con.messagesGet().length, 3 );
    var promise = con.promiseGot();
    promise.then( function( got )
    {
      test.identical( got, testMsg + 1 );
      test.is( _.promiseIs( promise ) );
      test.identical( con.messagesGet().length, 2 );
      test.identical( con.correspondentsEarlyGet().length, 0 );
    })
    return wConsequence.from( promise );
  })

  /* */

  .doThen( function()
  {
    wConsequence.prototype.asyncGiving = 1;
    wConsequence.prototype.asyncTaking = 0;
  })

  /* */

  .doThen( function()
  {
    test.description = 'async giving, single message';
    var con = new _.Consequence();
    var promise = con.promiseGot();
    con.give( testMsg );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    test.identical( con.messagesGet().length, 1 );
    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg );
        test.is( _.promiseIs( promise ) );
        test.identical( con.messagesGet().length, 0 );
        test.identical( con.correspondentsEarlyGet().length, 0 );
      });
      return wConsequence.from( promise );
    })
  })

  /* */

  .doThen( function()
  {
    test.description = 'async giving, single error';
    var con = new _.Consequence();
    var promise = con.promiseGot();
    con.error( testMsg );
    promise.catch( function( err )
    {
      test.identical( err, testMsg );
      test.is( _.promiseIs( promise ) );
    });
    test.identical( con.messagesGet().length, 1 );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet().length, 0 );
      test.identical( con.correspondentsEarlyGet().length, 0 );
      return wConsequence.from( promise );
    });
  })


  /* */

  .doThen( function()
  {
    test.description = 'async giving, several messages';
    var con = new _.Consequence();
    var promise = con.promiseGot();
    con.give( testMsg  + 1 );
    con.give( testMsg  + 2 );
    con.give( testMsg  + 3 );
    test.identical( con.messagesGet().length, 3 );
    test.identical( con.correspondentsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg + 1 );
        test.is( _.promiseIs( promise ) );
        test.identical( con.messagesGet().length, 2 );
        test.identical( con.correspondentsEarlyGet().length, 0 );
      })
      return wConsequence.from( promise );
    })
  })

  /* */

  .doThen( function()
  {
    wConsequence.prototype.asyncGiving = 0;
    wConsequence.prototype.asyncTaking = 1;
  })

  /* */

  .doThen( function()
  {
    test.description = 'async taking, single message';
    var con = new _.Consequence();
    con.give( testMsg );
    var promise = con.promiseGot();
    test.identical( con.correspondentsEarlyGet().length, 1 );
    test.identical( con.messagesGet().length, 1 );
    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg );
        test.is( _.promiseIs( promise ) );
        test.identical( con.messagesGet().length, 0 );
        test.identical( con.correspondentsEarlyGet().length, 0 );
      });
      return wConsequence.from( promise );
    })
  })

  /* */

  .doThen( function()
  {
    test.description = 'async taking, error message';
    var con = new _.Consequence();
    con.error( testMsg );
    var promise = con.promiseGot();
    promise.catch( function( err )
    {
      test.identical( err, testMsg );
      test.is( _.promiseIs( promise ) );
    });
    test.identical( con.messagesGet().length, 1 );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet().length, 0 );
      test.identical( con.correspondentsEarlyGet().length, 0 );
      return wConsequence.from( promise );
    });
  })

  /* */

  .doThen( function()
  {
    test.description = 'async taking, several messages';
    var con = new _.Consequence();
    con.give( testMsg  + 1 );
    con.give( testMsg  + 2 );
    con.give( testMsg  + 3 );
    var promise = con.promiseGot();
    test.identical( con.messagesGet().length, 3 );
    test.identical( con.correspondentsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg + 1 );
        test.is( _.promiseIs( promise ) );
        test.identical( con.messagesGet().length, 2 );
        test.identical( con.correspondentsEarlyGet().length, 0 );
      })
      return wConsequence.from( promise );
    })
  })

  /* */

  .doThen( function()
  {
    wConsequence.prototype.asyncGiving = 1;
    wConsequence.prototype.asyncTaking = 1;
  })

  /* */

  .doThen( function()
  {
    test.description = 'async taking+giving signle message';
    var con = new _.Consequence();
    con.give( testMsg );
    var promise = con.promiseGot();
    test.identical( con.correspondentsEarlyGet().length, 1 );
    test.identical( con.messagesGet().length, 1 );
    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg );
        test.is( _.promiseIs( promise ) );
        test.identical( con.messagesGet().length, 0 );
        test.identical( con.correspondentsEarlyGet().length, 0 );
      });
      return wConsequence.from( promise );
    })
  })

  /* */

  .doThen( function()
  {
    test.description = 'async taking+giving error message';
    var con = new _.Consequence();
    con.error( testMsg );
    var promise = con.promiseGot();
    promise.catch( function( err )
    {
      test.identical( err, testMsg );
      test.is( _.promiseIs( promise ) );
    });
    test.identical( con.messagesGet().length, 1 );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet().length, 0 );
      test.identical( con.correspondentsEarlyGet().length, 0 );
      return wConsequence.from( promise );
    });
  })

  /* */

  .doThen( function()
  {
    test.description = 'async taking+giving several messages';
    var con = new _.Consequence();
    con.give( testMsg  + 1 );
    con.give( testMsg  + 2 );
    con.give( testMsg  + 3 );
    var promise = con.promiseGot();
    test.identical( con.messagesGet().length, 3 );
    test.identical( con.correspondentsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg + 1 );
        test.is( _.promiseIs( promise ) );
        test.identical( con.messagesGet().length, 2 );
        test.identical( con.correspondentsEarlyGet().length, 0 );
      })
      return wConsequence.from( promise );
    })
  })
  .doThen( function()
  {
    wConsequence.prototype.asyncGiving = 0;
    wConsequence.prototype.asyncTaking = 0;
  })

  return testCon;
}

//

function doThen( test )
{
  var c = this;
  var amode = _.Consequence.asyncModeGet();
  var testMsg = 'msg';
  var testCon = new _.Consequence().give()

  .doThen( function()
  {
    _.Consequence.asyncModeSet([ 0, 0 ]);
    test.description += ', no message'
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    con.doThen( () => test.identical( 0, 1 ) );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    test.identical( con.messagesGet().length, 0 );
  })

  .doThen( function()
  {
    _.Consequence.asyncModeSet([ 1, 0 ]);
    test.description += ', no message'
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    con.doThen( () => test.identical( 0, 1 ) );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    test.identical( con.messagesGet().length, 0 );
  })

  .doThen( function()
  {
    _.Consequence.asyncModeSet([ 0, 1 ]);
    test.description += ', no message'
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    con.doThen( () => test.identical( 0, 1 ) );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    test.identical( con.messagesGet().length, 0 );
  })

  .doThen( function()
  {
    _.Consequence.asyncModeSet([ 1, 1 ]);
    test.description += ', no message'
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    con.doThen( () => test.identical( 0, 1 ) );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    test.identical( con.messagesGet().length, 0 );
  })

   /* asyncTaking : 0, asyncGiving : 0 */

  .doThen( function()
  {
    _.Consequence.asyncModeSet([ 0, 0 ]);
    test.description += ', single message, correspondent is a routine'
  })
  .doThen( function()
  {
    function correspondent( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg );
    }
    var con = new _.Consequence();
    con.give( testMsg );
    test.identical( con.messagesGet().length, 1 )
    test.identical( con.messagesGet()[ 0 ], { error : undefined, argument : testMsg } )
    con.doThen( correspondent );
    test.identical( con.correspondentsEarlyGet().length, 0 );
    test.identical( con.messagesGet().length, 1 )
    test.identical( con.messagesGet()[ 0 ], { error : undefined, argument : undefined } );

    return con;
  })

  /* asyncTaking : 1, asyncGiving : 0 */

  .doThen( function()
  {
    _.Consequence.asyncModeSet([ 1, 0 ]);
    test.description += ', single message, correspondent is a routine'
  })
  .doThen( function()
  {
    function correspondent( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg );
    }
    var con = new _.Consequence();
    con.give( testMsg );
    con.doThen( correspondent );
    test.identical( con.messagesGet().length, 1 )
    test.identical( con.messagesGet()[ 0 ], { error : undefined, argument : testMsg } )
    test.identical( con.correspondentsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 1 )
      test.identical( con.messagesGet()[ 0 ], { error : undefined, argument : undefined } )
    })
  })

  /* asyncTaking : 0, asyncGiving : 1 */

  .doThen( function()
  {
    _.Consequence.asyncModeSet([ 0, 1 ]);
    test.description += ', single message, correspondent is a routine'
  })
  .doThen( function()
  {
    function correspondent( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg );
    }
    var con = new _.Consequence();
    con.give( testMsg );

    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet().length, 1 )
      test.identical( con.messagesGet()[ 0 ], { error : undefined, argument : testMsg } )
      test.identical( con.correspondentsEarlyGet().length, 0 );

      con.doThen( correspondent );
    })
    .doThen( function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 )
      test.identical( con.messagesGet().length, 1 )
      test.identical( con.messagesGet()[ 0 ], { error : undefined, argument : undefined } )
    })
  })

  /* asyncTaking : 1, asyncGiving : 1 */

   .doThen( function()
  {
    _.Consequence.asyncModeSet([ 1, 1 ]);
    test.description += ', single message, correspondent is a routine'
  })
  .doThen( function()
  {
    function correspondent( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg );
    }
    var con = new _.Consequence();
    con.give( testMsg );
    con.doThen( correspondent );
    test.identical( con.correspondentsEarlyGet().length, 1 )
    test.identical( con.messagesGet().length, 1 )
    test.identical( con.messagesGet()[ 0 ], { error : undefined, argument : testMsg } )
    return _.timeOut( 1, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 )
      test.identical( con.messagesGet().length, 1 )
      test.identical( con.messagesGet()[ 0 ], { error : undefined, argument : undefined } )
    })

  })

  /* asyncTaking : 0, asyncGiving : 0 */

   .doThen( function()
  {
    _.Consequence.asyncModeSet([ 0, 0 ]);
    test.description += ', several doThen, correspondent is a routine';
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    con.give( testMsg );
    con.doThen( function( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg );
      return testMsg + 1;
    });
    con.doThen( function( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg + 1);
      return testMsg + 2;
    });
    con.doThen( function( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg + 2);
      return testMsg + 3;
    });
    test.identical( con.correspondentsEarlyGet().length, 0 )
    test.identical( con.messagesGet().length, 1 )
    test.identical( con.messagesGet()[ 0 ], { error : undefined, argument : testMsg + 3 } );

  })

  /* asyncTaking : 1, asyncGiving : 0 */

   .doThen( function()
  {
    _.Consequence.asyncModeSet([ 1, 0 ]);
    test.description += ', several doThen, correspondent is a routine';
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    con.give( testMsg );
    con.doThen( function( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg );
      return testMsg + 1;
    });
    con.doThen( function( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg + 1);
      return testMsg + 2;
    });
    con.doThen( function( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg + 2);
      return testMsg + 3;
    });
    test.identical( con.correspondentsEarlyGet().length, 3 )
    test.identical( con.messagesGet().length, 1 )
    test.identical( con.messagesGet()[ 0 ], { error : undefined, argument : testMsg } );

    return _.timeOut( 1, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 )
      test.identical( con.messagesGet().length, 1 )
      test.identical( con.messagesGet()[ 0 ], { error : undefined, argument : testMsg + 3 } );
    })

  })

  /* asyncTaking : 0, asyncGiving : 1 */

   .doThen( function()
  {
    _.Consequence.asyncModeSet([ 0, 1 ]);
    test.description += ', several doThen, correspondent is a routine';
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    con.give( testMsg );

    return _.timeOut( 1, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 )
      test.identical( con.messagesGet().length, 1 )
      test.identical( con.messagesGet()[ 0 ], { error : undefined, argument : testMsg } );

      con.doThen( function( err, got )
      {
        test.identical( err , undefined )
        test.identical( got , testMsg );
        return testMsg + 1;
      });
      con.doThen( function( err, got )
      {
        test.identical( err , undefined )
        test.identical( got , testMsg + 1);
        return testMsg + 2;
      });
      con.doThen( function( err, got )
      {
        test.identical( err , undefined )
        test.identical( got , testMsg + 2);
        return testMsg + 3;
      });

      return con;
    })
    .doThen( function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 )
      test.identical( con.messagesGet().length, 1 )
      test.identical( con.messagesGet()[ 0 ], { error : undefined, argument : testMsg + 3 } );
    })

  })

  /* asyncTaking : 1, asyncGiving : 1 */

   .doThen( function()
  {
    _.Consequence.asyncModeSet([ 1, 1 ]);
    test.description += ', several doThen, correspondent is a routine';
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    con.give( testMsg );

    con.doThen( function( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg );
      return testMsg + 1;
    });
    con.doThen( function( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg + 1);
      return testMsg + 2;
    });
    con.doThen( function( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg + 2);
      return testMsg + 3;
    });

    test.identical( con.correspondentsEarlyGet().length, 3 );
    test.identical( con.messagesGet().length, 1 );
    test.identical( con.messagesGet()[ 0 ], { error : undefined, argument : testMsg } );

    return _.timeOut( 1, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 1 );
      test.identical( con.messagesGet()[ 0 ], { error : undefined, argument : testMsg + 3} );
    })

  })

   /* asyncTaking : 0, asyncGiving : 0 */

   .doThen( function()
  {
    _.Consequence.asyncModeSet([ 0, 0 ]);
    test.description += ', single message, consequence as a correspondent';
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    var con2 = new _.Consequence();
    var con2TakerFired = false;
    con.give( testMsg );
    /* doThen only transfers the copy of messsage to the correspondent without waiting for response */
    con.doThen( con2 );
    con.got( function( err, got )
    {
      test.identical( got, testMsg );
      test.identical( con2TakerFired, false );
      test.identical( con2.messagesGet().length, 1 );
    });

    con2.doThen( function( err, got )
    {
      test.identical( got, testMsg )
      con2TakerFired = true;
    });

    con2.doThen( function()
    {
      test.identical( con2TakerFired, true );
      test.identical( con.messagesGet().length, 0 );
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con2.messagesGet().length, 0 );
      test.identical( con2.correspondentsEarlyGet().length, 0 );
    });

    return con2;
  })

  /* asyncTaking : 1, asyncGiving : 0 */

   .doThen( function()
  {
    _.Consequence.asyncModeSet([ 1, 0 ]);
    test.description += ', single message, consequence as a correspondent';
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    var con2 = new _.Consequence();
    var con2TakerFired = false;
    con.give( testMsg );
    con.doThen( con2 );
    con.got( function( err, got )
    {
      test.identical( got, testMsg );
      test.identical( con2TakerFired, true );
      test.identical( con2.messagesGet().length, 0 );
    });

    con2.got( function( err, got )
    {
      test.identical( got, testMsg )
      con2TakerFired = true;
    });

    test.identical( con2TakerFired, false );
    test.identical( con.messagesGet().length, 1 );
    test.identical( con.correspondentsEarlyGet().length, 2 );
    test.identical( con2.correspondentsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con2TakerFired, true );
      test.identical( con.messagesGet().length, 0 );
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con2.messagesGet().length, 0 );
      test.identical( con2.correspondentsEarlyGet().length, 0 );
    })

  })

  /* asyncTaking : 0, asyncGiving : 1 */

   .doThen( function()
  {
    _.Consequence.asyncModeSet([ 0, 1 ]);
    test.description += ', single message, consequence as a correspondent';
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    var con2 = new _.Consequence();
    var con2TakerFired = false;
    con.give( testMsg );

    test.identical( con2TakerFired, false );
    test.identical( con.messagesGet().length, 1 );
    test.identical( con.correspondentsEarlyGet().length, 0 );
    test.identical( con2.correspondentsEarlyGet().length, 0 );

    return _.timeOut( 1, function()
    {
      con.doThen( con2 );
      con.got( function( err, got )
      {
        test.identical( got, testMsg );
        test.identical( con2TakerFired, false );
        test.identical( con2.messagesGet().length, 1 );
      });

      con2.doThen( function( err, got )
      {
        test.identical( got, testMsg );
        con2TakerFired = true;
      });

      return con2;
    })
    .doThen( function()
    {
      test.identical( con2TakerFired, true );
      test.identical( con.messagesGet().length, 0 );
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con2.messagesGet().length, 1 );
      test.identical( con2.correspondentsEarlyGet().length, 0 );
    })
  })

  /* asyncTaking : 1, asyncGiving : 1 */

   .doThen( function()
  {
    _.Consequence.asyncModeSet([ 1, 1 ]);
    test.description += ', single message, consequence as a correspondent';
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    var con2 = new _.Consequence();
    var con2TakerFired = false;
    con.give( testMsg );
    con.doThen( con2 );
    con.got( function( err, got )
    {
      test.identical( got, testMsg );
      test.identical( con2TakerFired, false );
      test.identical( con2.messagesGet().length, 1 );
    });

    con2.got( function( err, got )
    {
      test.identical( got, testMsg );
      con2TakerFired = true;
    });

    test.identical( con2TakerFired, false );
    test.identical( con.messagesGet().length, 1 );
    test.identical( con.correspondentsEarlyGet().length, 2 );
    test.identical( con2.correspondentsEarlyGet().length, 1 );
    test.identical( con2.messagesGet().length, 0 );

    return _.timeOut( 1, function()
    {
      test.identical( con2TakerFired, true );
      test.identical( con.messagesGet().length, 0 );
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con2.messagesGet().length, 0 );
      test.identical( con2.correspondentsEarlyGet().length, 0 );
    })
  })

  /* asyncTaking : 0, asyncGiving : 0 */

   .doThen( function()
  {
    _.Consequence.asyncModeSet([ 0, 0 ]);
    test.description += 'correspondent returns consequence with msg';
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    var con2 = new _.Consequence();
    con.give();
    con.doThen( function()
    {
      return con2.give( testMsg );
    });

    test.identical( con.correspondentsEarlyGet().length, 0 );
    test.identical( con.messagesGet().length, 1 );
    test.identical( con.messagesGet()[ 0 ].argument, testMsg );

    test.identical( con2.messagesGet().length, 1 );
    test.identical( con2.messagesGet()[ 0 ].argument, testMsg );

  })

  /* asyncTaking : 1, asyncGiving : 0 */

   .doThen( function()
  {
    _.Consequence.asyncModeSet([ 1, 0 ]);
    test.description += 'correspondent returns consequence with msg';
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    var con2 = new _.Consequence();
    con.give();
    con.doThen( function()
    {
      return con2.give( testMsg );
    });

    test.identical( con.correspondentsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 1 );
      test.identical( con.messagesGet()[ 0 ].argument, testMsg );

      test.identical( con2.messagesGet().length, 1 );
      test.identical( con2.messagesGet()[ 0 ].argument, testMsg );
    })
  })

  /* asyncTaking : 0, asyncGiving : 1 */

   .doThen( function()
  {
    _.Consequence.asyncModeSet([ 0, 1 ]);
    test.description += 'correspondent returns consequence with msg';
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    var con2 = new _.Consequence();
    con.give();

    test.identical( con.messagesGet().length, 1 );

    return _.timeOut( 1, function()
    {
      con.doThen( function()
      {
        return con2.give( testMsg );
      });

      return con;
    })
    .doThen( function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 1 );
      test.identical( con.messagesGet()[ 0 ].argument, testMsg );

      test.identical( con2.messagesGet().length, 1 );
      test.identical( con2.messagesGet()[ 0 ].argument, testMsg );
    })
  })

  /* asyncTaking : 1, asyncGiving : 1 */

   .doThen( function()
  {
    _.Consequence.asyncModeSet([ 1, 1 ]);
    test.description += 'correspondent returns consequence with msg';
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    var con2 = new _.Consequence();
    con.give();
    con.doThen( function()
    {
      return con2.give( testMsg );
    });

    test.identical( con.messagesGet().length, 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 1 );
      test.identical( con.messagesGet()[ 0 ].argument, testMsg );

      test.identical( con2.messagesGet().length, 1 );
      test.identical( con2.messagesGet()[ 0 ].argument, testMsg );
    })
  })

  /* */

  testCon.doThen( () => _.Consequence.asyncModeSet( amode ) );

  return testCon;
}

//

function promiseThen( test )
{
  var testMsg = 'testMsg';
  var testCon = new _.Consequence().give()

  /* */

  .doThen( function()
  {
    test.description = 'no message';
    var con = new _.Consequence();
    var promise = con.promiseThen();
    test.identical( con.messagesGet().length, 0 );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    promise.then( function( got )
    {
      test.identical( 0, 1 );
    })
  })

  /* */

  .doThen( function()
  {
    test.description = 'single message';
    var con = new _.Consequence();
    con.give( testMsg );
    test.identical( con.messagesGet().length, 1 );
    var promise = con.promiseThen();
    promise.then( function( got )
    {
      test.identical( got, testMsg );
      test.is( _.promiseIs( promise ) );
      test.identical( con.messagesGet(), [{ error : undefined, argument : testMsg }] );
      test.identical( con.correspondentsEarlyGet().length, 0 );
    })

    return wConsequence.from( promise );
  })

  /* */

  .doThen( function()
  {
    test.description = 'error message';
    var con = new _.Consequence();
    con.error( testMsg );
    test.identical( con.messagesGet().length, 1 );
    var promise = con.promiseThen();
    promise.catch( function( err )
    {
      test.identical( err, testMsg );
      test.is( _.promiseIs( promise ) );
      test.identical( con.messagesGet(), [{ error : testMsg, argument : undefined }] );
      test.identical( con.correspondentsEarlyGet().length, 0 );
    })
    return wConsequence.from( promise );
  })

  /* */

  .doThen( function()
  {
    test.description = 'several messages';
    var con = new _.Consequence();
    con.give( testMsg  + 1 );
    con.give( testMsg  + 2 );
    con.give( testMsg  + 3 );
    test.identical( con.messagesGet().length, 3 );
    var promise = con.promiseThen();
    promise.then( function( got )
    {
      test.identical( got, testMsg + 1 );
      test.is( _.promiseIs( promise ) );
      test.identical( con.messagesGet().length, 3 );
      test.identical( con.correspondentsEarlyGet().length, 0 );
    })
    return wConsequence.from( promise );
  })

  /* */

  .doThen( function()
  {
    wConsequence.prototype.asyncGiving = 1;
    wConsequence.prototype.asyncTaking = 0;
  })

  /* */

  .doThen( function()
  {
    test.description = 'async giving, single message';
    var con = new _.Consequence();
    var promise = con.promiseThen();
    con.give( testMsg );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    test.identical( con.messagesGet().length, 1 );
    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg );
        test.is( _.promiseIs( promise ) );
        test.identical( con.messagesGet(), [{ error : undefined, argument : testMsg }] );
        test.identical( con.correspondentsEarlyGet().length, 0 );
      });
      return wConsequence.from( promise );
    })
  })

  /* */

  .doThen( function()
  {
    test.description = 'async giving, error message';
    var con = new _.Consequence();
    var promise = con.promiseThen();
    promise.catch( function( err )
    {
      test.identical( err, testMsg );
      test.is( _.promiseIs( promise ) );
    });
    con.error( testMsg );
    test.identical( con.messagesGet().length, 1 );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet(), [{ error : testMsg, argument : undefined }] );
      test.identical( con.correspondentsEarlyGet().length, 0 );
      return wConsequence.from( promise );
    });
  })

  /* */

  .doThen( function()
  {
    test.description = 'async giving, several messages';
    var con = new _.Consequence();
    var promise = con.promiseThen();
    con.give( testMsg  + 1 );
    con.give( testMsg  + 2 );
    con.give( testMsg  + 3 );
    test.identical( con.messagesGet().length, 3 );
    test.identical( con.correspondentsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg + 1 );
        test.is( _.promiseIs( promise ) );
        test.identical( con.messagesGet().length, 3 );
        test.identical( con.correspondentsEarlyGet().length, 0 );
      })
      return wConsequence.from( promise );
    })
  })

  /* */

  .doThen( function()
  {
    wConsequence.prototype.asyncGiving = 0;
    wConsequence.prototype.asyncTaking = 1;
  })

  /* */

  .doThen( function()
  {
    test.description = 'async taking, single message';
    var con = new _.Consequence();
    con.give( testMsg );
    var promise = con.promiseThen();
    test.identical( con.correspondentsEarlyGet().length, 1 );
    test.identical( con.messagesGet().length, 1 );
    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg );
        test.is( _.promiseIs( promise ) );
        test.identical( con.messagesGet(), [{ error : undefined, argument : testMsg }] );
        test.identical( con.correspondentsEarlyGet().length, 0 );
      });
      return wConsequence.from( promise );
    })
  })

  /* */

  .doThen( function()
  {
    test.description = 'async taking, error message';
    var con = new _.Consequence();
    con.error( testMsg );
    var promise = con.promiseThen();
    promise.catch( function( err )
    {
      test.identical( err, testMsg );
      test.is( _.promiseIs( promise ) );
    });
    test.identical( con.messagesGet().length, 1 );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet(), [{ error : testMsg, argument : undefined }] );
      test.identical( con.correspondentsEarlyGet().length, 0 );
      return wConsequence.from( promise );
    });
  })

  /* */

  .doThen( function()
  {
    test.description = 'async taking, several messages';
    var con = new _.Consequence();
    con.give( testMsg  + 1 );
    con.give( testMsg  + 2 );
    con.give( testMsg  + 3 );
    var promise = con.promiseThen();
    test.identical( con.messagesGet().length, 3 );
    test.identical( con.correspondentsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg + 1 );
        test.is( _.promiseIs( promise ) );
        test.identical( con.messagesGet().length, 3 );
        test.identical( con.correspondentsEarlyGet().length, 0 );
      })
      return wConsequence.from( promise );
    })
  })

  /* */

  .doThen( function()
  {
    wConsequence.prototype.asyncGiving = 1;
    wConsequence.prototype.asyncTaking = 1;
  })

  /* */

  .doThen( function()
  {
    test.description = 'async taking+giving, single message';
    var con = new _.Consequence();
    con.give( testMsg );
    var promise = con.promiseThen();
    test.identical( con.correspondentsEarlyGet().length, 1 );
    test.identical( con.messagesGet().length, 1 );
    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg );
        test.is( _.promiseIs( promise ) );
        test.identical( con.messagesGet(), [{ error : undefined, argument : testMsg }] );
        test.identical( con.correspondentsEarlyGet().length, 0 );
      });
      return wConsequence.from( promise );
    })
  })

  /* */

  .doThen( function()
  {
    test.description = 'async taking+giving, error message';
    var con = new _.Consequence();
    con.error( testMsg );
    var promise = con.promiseThen();
    promise.catch( function( err )
    {
      test.identical( err, testMsg );
      test.is( _.promiseIs( promise ) );
    });
    test.identical( con.messagesGet().length, 1 );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet(), [{ error : testMsg, argument : undefined }] );
      test.identical( con.correspondentsEarlyGet().length, 0 );
      return wConsequence.from( promise );
    });
  })

  /* */

  .doThen( function()
  {
    test.description = 'async taking+giving, several messages';
    var con = new _.Consequence();
    con.give( testMsg  + 1 );
    con.give( testMsg  + 2 );
    con.give( testMsg  + 3 );
    var promise = con.promiseThen();
    test.identical( con.messagesGet().length, 3 );
    test.identical( con.correspondentsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg + 1 );
        test.is( _.promiseIs( promise ) );
        test.identical( con.messagesGet().length, 3 );
        test.identical( con.correspondentsEarlyGet().length, 0 );
      })
      return wConsequence.from( promise );
    })
  })
  .doThen( function()
  {
    wConsequence.prototype.asyncGiving = 0;
    wConsequence.prototype.asyncTaking = 0;
  })

  return testCon;
}

//

// function thenSealed_( test )
// {
//
//   var testCheck1 =
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
//           { err : undefined, value : 5, takerId : 'taker1' }
//         ],
//         throwErr : false
//       }
//     },
//     testCheck2 =
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
//     testCheck3 =
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
//           { err : undefined, value : 5, takerId : 'taker1' },
//           { err : undefined, value : 4, takerId : 'taker2' }
//         ],
//         throwErr : false
//       }
//     },
//     testCheck4 =
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
//             err : undefined,
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
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }
//
//     var con = _.Consequence();
//     con.give( givSequence.shift() );
//     try
//     {
//       con.thenSealed( undefined, testTaker1, [] );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck1 );
//
//   /**/
//
//   test.description = 'single err in give sequence, and single taker : attached taker after value resolved';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }
//
//     var con = _.Consequence();
//     try
//     {
//       con.error( givSequence.shift() );
//       con.thenSealed( undefined, testTaker1, [] );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck2 );
//
//   /**/
//
//   test.description = 'test thenSealed in chain';
//
//   ( function( { givSequence, got, expected }  )
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
//     var con = _.Consequence();
//     for (let given of givSequence)
//       con.give( given );
//
//     try
//     {
//       con.thenSealed( undefined, testTaker1, [] );
//       con.thenSealed( undefined, testTaker2, [] );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck3 );
//
//   /* test particular _onceGot features test. */
//
//   test.description = 'thenSealed with sealed context and argument';
//   ( function( { givSequence, got, expected }  )
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
//     var con = _.Consequence();
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
//   } )( testCheck4 );
//
//
//   if( Config.debug )
//   {
//     var conDeb1 = _.Consequence();
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
//   var testCheck1 =
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
//             { err : undefined, value : 5, takerId : 'taker1' }
//           ],
//         throwErr : false
//       }
//     },
//     testCheck2 =
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
//             { err : undefined, value : 5, takerId : 'taker1' }
//           ],
//         throwErr : false
//       }
//     },
//     testCheck3 =
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
//             { err : undefined, value : 5, takerId : 'taker1' },
//           ],
//         throwErr : false
//       }
//     };
//
//
//   /* common wConsequence corespondent tests. */
//
//   test.description = 'then clone : run after resolve value';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }
//
//     var newCon;
//     var con = _.Consequence();
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
//   } )( testCheck1 );
//
//   /**/
//
//   test.description = 'then clone : run before resolve value';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }
//
//     var newCon;
//     var con = _.Consequence();
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
//   } )( testCheck2 );
//
//   /**/
//
//   test.description = 'test thenSealed in chain';
//
//   ( function( { givSequence, got, expected }  )
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
//     var con = _.Consequence();
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
//   } )( testCheck3 );
// };

//

function split( test )
{
  var testCon = new _.Consequence().give()

  .doThen( function()
  {
    test.description = 'split : run after resolve value';
    var con = new _.Consequence().give( 5 );
    var con2 = con.split();
    test.identical( con2.messagesGet().length, 1 );
    con2.got( function( err, got )
    {
      test.identical( got, 5 );
      test.identical( err, undefined );
    });

    test.identical( con.messagesGet().length, 1 );
    test.identical( con2.messagesGet().length, 0 );
  })

  .doThen( function()
  {
    test.description = 'split : run before resolve value';
    var con = new _.Consequence();
    var con2 = con.split();
    con2.got( function( err, got )
    {
      test.identical( got, 5 );
      test.identical( err, undefined );
    });
    con.give( 5 );
    test.identical( con.messagesGet().length, 1 );
    test.identical( con2.messagesGet().length, 0 );
  })

  .doThen( function()
  {
    test.description = 'test split in chain';
    var _got = [];
    var _err = [];
    function correspondent( err, got )
    {
      _got.push( got );
      _err.push( err );
    }

    var con = new _.Consequence();
    con.give( 5 );
    con.give( 6 );
    test.identical( con.messagesGet().length, 2 );
    var con2 = con.split();
    test.identical( con2.messagesGet().length, 1 );
    con2.got( correspondent );
    con2.got( correspondent );

    test.identical( con2.messagesGet().length, 0 );
    test.identical( con2.correspondentsEarlyGet().length, 1 );
    test.identical( con.messagesGet().length, 2 );
    test.identical( _got, [ 5 ] )
    test.identical( _err, [ undefined ] )
  })

  .doThen( function()
  {
    test.description = 'passing correspondent as argument';
    var _got = [];
    var _err = [];
    function correspondent( err, got )
    {
      _got.push( got );
      _err.push( err );
    }

    var con = new _.Consequence();
    con.give( 5 );
    con.give( 6 );
    test.identical( con.messagesGet().length, 2 );
    var con2 = con.split( correspondent );

    test.identical( con2.messagesGet().length, 1 );
    test.identical( con2.messagesGet()[ 0 ], { error : undefined, argument : undefined } );
    test.identical( con2.correspondentsEarlyGet().length, 0 );
    test.identical( con.messagesGet().length, 2 );
    test.identical( _got, [ 5 ] )
    test.identical( _err, [ undefined ] )
  })

  return testCon;
}

//

// function thenReportError( test )
// {
//
//   var testCheck1 =
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
//           [],
//         throwErr : false
//       }
//     },
//     testCheck3 =
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
//             { err : undefined, value : 5, takerId : 'taker1' },
//             { err : undefined, value : 4, takerId : 'taker2' }
//           ],
//         throwErr : false
//       }
//     },
//     testCheck4 =
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
//             { err : undefined, value : 5, takerId : 'taker1' },
//             { err : undefined, value : 4, takerId : 'taker2' }
//           ],
//         throwErr : false
//       }
//     };
//
//
//   /* common wConsequence corespondent tests. */
//
//   test.description = 'single value in give sequence';
//   ( function( { givSequence, got, expected }  )
//   {
//     var con = _.Consequence();
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
//   } )( testCheck1 );
//
//   /**/
//
//   test.description = 'single err in give sequence';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }
//
//     var con = _.Consequence();
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
//   } )( testCheck2 );
//
//   /**/
//
//   test.description = 'test thenSealed in chain';
//
//   ( function( { givSequence, got, expected }  )
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
//     var con = _.Consequence();
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
//   } )( testCheck3 );
//   //
//   /* test particular _onceGot features test. */
//
//   test.description = 'test thenSealed in chain #2';
//   ( function( { givSequence, got, expected }  )
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
//     var con = _.Consequence();
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
//   } )( testCheck4 );
//
//
//   if( Config.debug )
//   {
//     var conDeb1 = _.Consequence();
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

// function tap( test )
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
//         gotSequence :
//           [
//             { err : undefined, value : 5, takerId : 'taker1' }
//           ],
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
//             { err : 'err msg', value : void 0, takerId : 'taker1' }
//           ],
//         throwErr : false
//       }
//     },
//     testCheck3 =
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
//             { err : undefined, value : 5, takerId : 'taker1' },
//             { err : undefined, value : 5, takerId : 'taker2' },
//             { err : undefined, value : 5, takerId : 'taker3' }
//           ],
//         throwErr : false
//       }
//     };


//   /* common wConsequence corespondent tests. */

//   test.description = 'single value in give sequence, and single taker : attached taker after value resolved';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();
//     con.give( givSequence.shift() );
//     try
//     {
//       con.tap( testTaker1 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck1 );

//   /**/

//   test.description = 'single err in give sequence, and single taker : attached taker after value resolved';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();
//     try
//     {
//       con.error( givSequence.shift() );
//       con.tap( testTaker1 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck2 );

//   /**/

//   test.description = 'test tap in chain';

//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//       value++;
//       return value;
//     }

//     function testTaker2( err, value )
//     {
//       var takerId = 'taker2';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     function testTaker3( err, value )
//     {
//       var takerId = 'taker3';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();
//     for (let given of givSequence)
//       con.give( given );

//     try
//     {
//       con.tap( testTaker1 );
//       con.tap( testTaker2 );
//       con.got( testTaker3 );

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

//     test.description = 'missed arguments';
//     test.shouldThrowError( function()
//     {
//       conDeb1.tap();
//     } );
//   }

// };

//

function tap( test )
{
  var testMsg = 'msg';
  var testCon = new _.Consequence().give()

  /* */

  .doThen( function()
  {
    test.description = 'single value in give sequence, and single taker : attached taker after value resolved';

    var con = new _.Consequence();
    con.give( testMsg );
    con.tap( ( err, got ) => test.identical( got, testMsg ) );
    con.got( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.correspondentsEarlyGet().length, 0 );
    test.identical( con.messagesGet().length, 0 );
  })

  /* */

  .doThen( function()
  {
    test.description = 'single error and single taker : attached taker after value resolved';

    var con = new _.Consequence();
    con.error( testMsg );
    con.tap( ( err, got ) => test.identical( err, testMsg ) );
    con.got( ( err, got ) => test.identical( err, testMsg ) );
    test.identical( con.correspondentsEarlyGet().length, 0 );
    test.identical( con.messagesGet().length, 0 );
  })

  /* */

  .doThen( function()
  {
    test.description = 'test tap in chain';

    var con = new _.Consequence();
    con.give( testMsg );
    con.tap( ( err, got ) => test.identical( got, testMsg ) );
    con.tap( ( err, got ) => test.identical( got, testMsg ) );
    con.got( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.correspondentsEarlyGet().length, 0 );
    test.identical( con.messagesGet().length, 0 );
  })

   /* */

  .doThen( function()
  {
    if( !Config.debug )
    return;

    test.description = 'missed arguments';

    var con = _.Consequence();

    test.shouldThrowError( function()
    {
      con.tap();
    });
  })

  return testCon;
}

//

// function ifErrorThen( test )
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

//   test.description = 'single value in give sequence, and single taker : attached taker after value resolved';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, takerId } );
//     }

//     var con = _.Consequence();
//     con.give( givSequence.shift() );
//     try
//     {
//       con.ifErrorThen( testTaker1 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck1 );

//   /**/

//   test.description = 'single err in give sequence, and single taker : attached taker after value resolved';
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
//       con.ifErrorThen( testTaker1 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck2 );

//   /**/

//   test.description = 'test tap in chain';

//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err,takerId } );
//       value++;
//       return value;
//     }

//     function testTaker2( err )
//     {
//       var takerId = 'taker2';
//       got.gotSequence.push( { err,takerId } );
//     }

//     function testTaker3( err, value )
//     {
//       var takerId = 'taker3';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();

//     con.give( givSequence.shift() );
//     con.error( givSequence.shift() );
//     con.give( givSequence.shift() );

//     try
//     {
//       con.ifErrorThen( testTaker1 );
//       con.ifErrorThen( testTaker2 );
//       con.got( testTaker3 );

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

//     test.description = 'missed arguments';
//     test.shouldThrowError( function()
//     {
//       conDeb1.ifErrorThen();
//     } );
//   }

// };

//

function ifErrorThen( test )
{
  var testMsg = 'msg';
  var testCon = new _.Consequence().give()

  /* common wConsequence corespondent tests. */

  .doThen( function()
  {
    test.description = 'single value in give sequence, and single taker : attached taker after value resolved';

    var con = new _.Consequence();
    con.give( testMsg );
    con.ifErrorThen( ( err ) => test.identical( 0, 1 ) );
    con.got( ( err, got ) => test.identical( got, testMsg ));

    test.identical( con.correspondentsEarlyGet().length, 0 );
    test.identical( con.messagesGet().length, 0 );
  })

  /* */

  .doThen( function()
  {
    test.description = 'single err in give sequence, and single taker : attached taker after value resolved';

    var con = new _.Consequence();
    con.error( testMsg );
    con.ifErrorThen( ( err ) => { test.identical( err,testMsg ) });
    con.got( ( err, got ) => test.identical( got, undefined ) );

    test.identical( con.correspondentsEarlyGet().length, 0 );
    test.identical( con.messagesGet().length, 0 );
  })

  /* */

  .doThen( function()
  {
    test.description = 'test ifErrorThen in chain, regular message is given before error';

    var con = new _.Consequence();
    con.give( testMsg );
    con.error( testMsg + 1 );
    con.error( testMsg + 2 );

    con.ifErrorThen( ( err ) => { test.identical( 0, 1 ) });
    con.ifErrorThen( ( err ) => { test.identical( 0, 1 ) });
    con.got( ( err, got ) => test.identical( got, testMsg ) );

    test.identical( con.messagesGet().length, 2 );
    test.identical( con.messagesGet()[ 0 ].error, testMsg + 1 );
    test.identical( con.messagesGet()[ 1 ].error, testMsg + 2 );
    test.identical( con.correspondentsEarlyGet().length, 0 );
  })

  /* */

  .doThen( function()
  {
    test.description = 'test ifErrorThen in chain, regular message is given after error';

    var con = new _.Consequence();
    con.error( testMsg + 1 );
    con.error( testMsg + 2 );
    con.give( testMsg );

    con.ifErrorThen( ( err ) => { test.identical( err, testMsg + 1 ) });
    con.ifErrorThen( ( err ) => { test.identical( err, testMsg + 2 ) });
    con.got( ( err, got ) => test.identical( got, testMsg ) );

    test.identical( con.messagesGet().length, 2 );
    test.identical( con.messagesGet()[ 0 ], { error : undefined, argument : undefined } );
    test.identical( con.messagesGet()[ 1 ], { error : undefined, argument : undefined } );
    test.identical( con.correspondentsEarlyGet().length, 0 );
  })

   /* */

  .doThen( function()
  {
    if( !Config.debug )
    return;

    test.description = 'missed arguments';

    var con = _.Consequence();

    test.shouldThrowError( function()
    {
      con.ifErrorThen();
    });
  })

  return testCon;
}

//

// function ifNoErrorThen( test )
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
//         gotSequence :
//         [
//           { value : 5, takerId : 'taker1' }
//         ],
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
//           [ ],
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
//             { value : 5, takerId : 'taker1' },
//             { err : 'err msg', value : void 0, takerId : 'taker3' },
//           ],
//         throwErr : false
//       }
//     };


//   /* common wConsequence corespondent tests. */

//   test.description = 'single value in give sequence, and single taker : attached taker after value resolved';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { value, takerId } );
//     }

//     var con = _.Consequence();
//     con.give( givSequence.shift() );
//     try
//     {
//       con.ifNoErrorThen( testTaker1 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck1 );

//   /**/

//   test.description = 'single err in give sequence, and single taker : attached taker after value resolved';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { value, takerId } );
//     }

//     var con = _.Consequence();
//     try
//     {
//       con.error( givSequence.shift() );
//       con.ifNoErrorThen( testTaker1 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck2 );

//   /**/

//   test.description = 'test ifNoErrorThen in chain';

//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { value, takerId } );
//       value++;
//       return value;
//     }

//     function testTaker2( value )
//     {
//       var takerId = 'taker2';
//       got.gotSequence.push( {  value, takerId } );
//     }

//     function testTaker3( err, value )
//     {
//       var takerId = 'taker3';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();

//     con.give( givSequence.shift() );
//     con.error( givSequence.shift() );
//     con.give( givSequence.shift() );

//     try
//     {
//       con.ifNoErrorThen( testTaker1 );
//       con.ifNoErrorThen( testTaker2 );
//       con.got( testTaker3 );

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

//     test.description = 'missed arguments';
//     test.shouldThrowError( function()
//     {
//       conDeb1.ifNoErrorThen();
//     });
//   }

// };

//

function ifNoErrorThen( test )
{
  var testMsg = 'msg';
  var testCon = new _.Consequence().give()

  /* common wConsequence corespondent tests. */

  .doThen( function()
  {
    test.description = 'single value in give sequence, and single taker : attached taker after value resolved';

    var con = new _.Consequence();
    con.give( testMsg );
    con.ifNoErrorThen( ( got ) => { test.identical( got, testMsg ) } );
    con.got( ( err, got ) => test.identical( got, undefined ) );

    test.identical( con.correspondentsEarlyGet().length, 0 );
    test.identical( con.messagesGet().length, 0 );
  })

  /* */

  .doThen( function()
  {
    test.description = 'single err in give sequence, and single taker : attached taker after value resolved';

    var con = new _.Consequence();
    con.error( testMsg );
    con.ifNoErrorThen( ( got ) => { test.identical( 0, 1 ) });
    con.got( ( err, got ) => test.identical( err, testMsg ) );

    test.identical( con.correspondentsEarlyGet().length, 0 );
    test.identical( con.messagesGet().length, 0 );
  })

  /* */

  .doThen( function()
  {
    test.description = 'test ifNoErrorThen in chain, regular message is given before error';

    var con = new _.Consequence();
    con.give( testMsg );
    con.give( testMsg );
    con.error( testMsg );

    con.ifNoErrorThen( ( got ) => { test.identical( got, testMsg ) });
    con.ifNoErrorThen( ( got ) => { test.identical( got, testMsg ) });

    test.identical( con.messagesGet().length, 3 );
    test.identical( con.messagesGet()[ 0 ].error, testMsg );
    test.identical( con.messagesGet()[ 1 ], { error : undefined, argument : undefined } );
    test.identical( con.messagesGet()[ 2 ], { error : undefined, argument : undefined } );
    test.identical( con.correspondentsEarlyGet().length, 0 );
  })

  /* */

  .doThen( function()
  {
    test.description = 'test ifNoErrorThen in chain, regular message is given after error';

    var con = new _.Consequence();
    con.error( testMsg );
    con.give( testMsg );
    con.give( testMsg );

    con.ifNoErrorThen( ( got ) => { test.identical( 0, 1 ) });
    con.ifNoErrorThen( ( got ) => { test.identical( 0, 1 ) });

    test.identical( con.messagesGet().length, 3 );
    test.identical( con.messagesGet()[ 0 ].error, testMsg );
    test.identical( con.messagesGet()[ 1 ], { error : undefined, argument : testMsg } );
    test.identical( con.messagesGet()[ 2 ], { error : undefined, argument : testMsg } );
    test.identical( con.correspondentsEarlyGet().length, 0 );
  })

  /* */

  .doThen( function()
  {
    test.description = 'test ifNoErrorThen in chain serveral messages';

    var con = new _.Consequence();
    con.give( testMsg );
    con.give( testMsg );

    con.ifNoErrorThen( ( got ) => { test.identical( got, testMsg ) });
    con.ifNoErrorThen( ( got ) => { test.identical( got, testMsg ) });

    test.identical( con.messagesGet().length, 2 );
    test.identical( con.messagesGet()[ 0 ], { error : undefined, argument : undefined } );
    test.identical( con.messagesGet()[ 1 ], { error : undefined, argument : undefined } );
    test.identical( con.correspondentsEarlyGet().length, 0 );
  })

   /* */

  .doThen( function()
  {
    if( !Config.debug )
    return;

    test.description = 'missed arguments';

    var con = _.Consequence();

    test.shouldThrowError( function()
    {
      con.ifNoErrorThen();
    });
  })

  return testCon;
}

//

// function timeOutThen( test )
// {

//   var testCheck1 =

//     {
//       givSequence : [ 5 ],
//       got :
//       {
//         gotSequence :
//         [
//           { err : undefined, value : 5, takerId : 'taker1' }
//         ],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//           [
//             { err : undefined, value : 5, takerId : 'taker1' }
//           ],
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
//           [ ],
//         throwErr : false
//       }
//     },
//     testCheck3 =
//     {
//       givSequence : [ 5, 3,  4 ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//           [
//             { err : undefined, value : 4, takerId : 'taker3' },
//             { err : undefined, value : 3, takerId : 'taker2' },
//           ],
//         throwErr : false
//       }
//     };


//   /* common wConsequence corespondent tests. */

//   test.description = 'single value in give sequence, and single taker : attached taker after value resolved';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();
//     con.give( givSequence.shift() );
//     try
//     {
//       con.timeOutThen( 0, testTaker1 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck1 );

//   /**/

//   test.description = 'single err in give sequence, and single taker : attached taker after value resolved';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();
//     try
//     {
//       con.error( givSequence.shift() );
//       con.timeOutThen( 0, testTaker1 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck2 );

//   /**/

//   test.description = 'test timeOutThen in chain';

//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//       value++;
//       return value;
//     }

//     function testTaker2( err, value )
//     {
//       var takerId = 'taker2';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     function testTaker3( err, value )
//     {
//       var takerId = 'taker3';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();

//     for (let given of givSequence)
//       con.give( given );

//     con.timeOutThen( 20, testTaker1 );
//     con.timeOutThen( 10, testTaker2 );
//     con.got( testTaker3 )
//     .got( function() {
//       test.identical( got, expected );
//     } );



//   } )( testCheck3 );

//   if( Config.debug )
//   {
//     var conDeb1 = _.Consequence();

//     test.description = 'missed arguments';
//     test.shouldThrowError( function()
//     {
//       conDeb1.timeOutThen();
//     } );
//   }

// };

//

function timeOutThen( test )
{
  var testMsg = 'msg';
  var testCon = new _.Consequence().give()

  /* common wConsequence corespondent tests. */

  .doThen( function()
  {
    test.description = 'single value in give sequence, and single taker : attached taker after value resolved';

    var con = new _.Consequence();
    con.give( testMsg );
    con.timeOutThen( 0, ( err, got ) => { test.identical( got, testMsg ) } );
    con.got( ( err, got ) => test.identical( got, undefined ) );

    return _.timeOut( 0, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
    })
  })

  /* */

  .doThen( function()
  {
    test.description = 'single err in give sequence, and single taker : attached taker after value resolved';

    var con = new _.Consequence();
    con.error( testMsg );
    con.timeOutThen( 0, ( err, got ) => { test.identical( err, testMsg ) } );
    con.got( ( err, got ) => test.identical( got, undefined ) );

    return _.timeOut( 0, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
    })
  })

  /* */

  .doThen( function()
  {
    test.description = 'test timeOutThen in chain';
    var delay = 0;
    var con = new _.Consequence();
    con.give( testMsg );
    con.give( testMsg + 1 );
    con.give( testMsg + 2 );
    con.timeOutThen( delay, ( err, got ) => { test.identical( got, testMsg ) } );
    con.timeOutThen( ++delay, ( err, got ) => { test.identical( got, testMsg + 1 ) } );
    con.timeOutThen( ++delay, ( err, got ) => { test.identical( got, testMsg + 2 ) } );

    return _.timeOut( delay, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 3 );
      con.messagesGet()
      .every( ( msg ) => test.identical( msg, { error : undefined, argument : undefined } ) )
    })
  })

  /* */

  .doThen( function()
  {
    if( !Config.debug )
    return;

    var con = _.Consequence();

    test.description = 'missed arguments';
    test.shouldThrowError( function()
    {
      con.timeOutThen();
    });
  })

  return testCon;
}

//

// function _and( test )
// {
//   var testCheck1 =
//     {
//       givSequence : [ 5, 4 ],
//       got :
//       {
//         gotSequence : [ ],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//           [ ],
//         throwErr : false
//       }
//     },
//     testCheck2 =
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
//             { err : undefined, value : 5, takerId : 'taker1' },
//             { err : undefined, value : 4, takerId : 'taker2' },
//           ],
//         throwErr : false
//       }
//     },
//     testCheck3 =
//     {
//       givSequence : [ 5, 3,  4 ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//           [
//             { err : undefined, value : 4, takerId : 'taker3' },
//             { err : undefined, value : 3, takerId : 'taker2' },
//           ],
//         throwErr : false
//       }
//     };


//   /* common wConsequence corespondent tests. */

//   test.description = 'do not give back messages to src consequences';
//   ( function( { givSequence, got, expected }  )
//   {
//     var con1 = _.Consequence(),
//       con2 = _.Consequence();


//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     function testTaker2( err, value )
//     {
//       var takerId = 'taker2';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     var  conOwner = new _.Consequence();

//     conOwner.give();

//     con1.got( testTaker1 );
//     con2.got( testTaker2 );

//     try
//     {
//       debugger
//       conOwner._and( [con1, con2], true );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }

//     conOwner.got( function()
//     {
//       test.identical( got, expected );
//     } );


//     con1.give( givSequence.shift() );
//     con2.give( givSequence.shift() );
//   } )( testCheck1 );

//   /**/

//   test.description = 'give back massages to src consequences once all come';
//   ( function( { givSequence, got, expected }  )
//   {
//     var con1 = _.Consequence(),
//       con2 = _.Consequence();


//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     function testTaker2( err, value )
//     {
//       var takerId = 'taker2';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     var  conOwner = _.Consequence();

//     conOwner.give();

//     con1.got( testTaker1 );
//     con2.got( testTaker2 );

//     try
//     {
//       conOwner._and( [con1, con2], false );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }

//     conOwner.got( function()
//     {
//       test.identical( got, expected );
//     } );

//     con1.give( givSequence.shift() );
//     con2.give( givSequence.shift() );
//   } )( testCheck2 );


//   if( Config.debug )
//   {
//     var conDeb1 = _.Consequence();

//     test.description = 'missed arguments';
//     test.shouldThrowError( function()
//     {
//       conDeb1._and();
//     } );
//   }
// };

//

function _and( test )
{
  var testMsg = 'msg';
  var delay = 500;
  var testCon = new _.Consequence().give()

  /* common wConsequence corespondent tests. */

  .doThen( function()
  {
    test.description = 'give back messages to src consequences';

    var mainCon = new _.Consequence();
    var con1 = new _.Consequence();
    var con2 = new _.Consequence();

    mainCon.give( testMsg );

    mainCon._and( [ con1, con2 ], true );

    con1.got( ( err, got ) => test.identical( got, delay ) );
    con2.got( ( err, got ) => test.identical( got, delay * 2 ) );

    mainCon.doThen( function( err, got )
    {
      //at that moment all messages from srcs are processed
      test.identical( con1.messagesGet().length, 0 );
      test.identical( con1.correspondentsEarlyGet().length, 0 );
      test.identical( con2.messagesGet().length, 0 );
      test.identical( con2.correspondentsEarlyGet().length, 0 );
      test.identical( got, [ delay, delay * 2, testMsg ] );
    });

    _.timeOut( delay, () => { con1.give( delay ) } );
    _.timeOut( delay * 2, () => { con2.give( delay * 2 ) } );

    return mainCon;
  })

  /* */

   .doThen( function()
  {
    test.description = 'dont give back messages to src consequences';

    var mainCon = new _.Consequence();
    var con1 = new _.Consequence();
    var con2 = new _.Consequence();

    mainCon.give( testMsg );

    debugger
    mainCon._and( [ con1, con2 ], false );

    con1.got( ( err, got ) => test.identical( 0, 1 ) );
    con2.got( ( err, got ) => test.identical( 0, 1 ) );

    mainCon.doThen( function( err, got )
    {
      /* no messages returned back to srcs, their correspondents must not be invoked */
      test.identical( con1.messagesGet().length, 0 );
      test.identical( con1.correspondentsEarlyGet().length, 1 );
      test.identical( con2.messagesGet().length, 0 );
      test.identical( con2.correspondentsEarlyGet().length, 1 );
      test.identical( got, [ delay, delay * 2, testMsg ] );
    });

    _.timeOut( delay, () => { con1.give( delay ) } );
    _.timeOut( delay * 2, () => { con2.give( delay * 2 ) } );

    return mainCon;
  })

  return testCon;
}

// --
// test part 3
// --

// function _onceGot( test )
// {

//   var conseqTester = _.Consequence(); // for correct testing async aspects of wConsequence

//   var testChecks =
//     [
//       {
//         givSequence: [ 5 ],
//         gotSequence: [],
//         expectedSequence:
//         [
//          { err: undefined, value: 5, takerId: 'taker1' }
//         ],
//       },
//       {
//         givSequence: [
//           'err msg'
//         ],
//         gotSequence: [],
//         expectedSequence:
//         [
//           { err: 'err msg', value: void 0, takerId: 'taker1' }
//         ]
//       },
//       {
//         givSequence: [ 5, 4 ],
//         gotSequence: [],
//         expectedSequence:
//           [
//             { err: undefined, value: 5, takerId: 'taker1' },
//             { err: undefined, value: 4, takerId: 'taker2' }
//           ],
//       },
//       {
//         givSequence: [ 5, 4, 6 ],
//         gotSequence: [],
//         expectedSequence:
//         [
//           { err: undefined, value: 5, takerId: 'taker1' },
//           { err: undefined, value: 4, takerId: 'taker1' },
//           { err: undefined, value: 6, takerId: 'taker2' }
//         ],
//       },
//       {
//         givSequence: [ 5, 4, 6 ],
//         gotSequence: [],
//         expectedSequence:
//         [
//           { err: undefined, value: 5, takerId: 'taker1' },
//           { err: undefined, value: 4, takerId: 'taker2' },
//         ],
//       },
//     ];

//   /* common wConsequence goter tests. */

//   test.description = 'single value in give sequence, and single taker: attached taker after value resolved';
//   ( function( { givSequence, gotSequence, expectedSequence }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();
//     con.give( givSequence.shift() );
//     con._onceGot( testTaker1 );
//     test.identical( gotSequence, expectedSequence );
//   } )( testChecks[ 0 ] );

//   /**/

//   test.description = 'single err in give sequence, and single taker: attached taker after value resolved';
//   ( function( { givSequence, gotSequence, expectedSequence }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();
//     con.error( givSequence.shift() );
//     con._onceGot( testTaker1 );
//     test.identical( gotSequence, expectedSequence );
//   } )( testChecks[ 1 ] );

//   /**/

//   test.description = 'test _onceGot in chain';

//   ( function( { givSequence, gotSequence, expectedSequence }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       gotSequence.push( { err, value, takerId } );
//       value++;
//       return value;
//     }

//     function testTaker2( err, value )
//     {
//       var takerId = 'taker2';
//       gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();
//     for (let given of givSequence)
//     con.give( given );

//     con._onceGot( testTaker1 );
//     con._onceGot( testTaker2 );
//     test.identical( gotSequence, expectedSequence );
//   } )( testChecks[ 2 ] );

//   /* test particular _onceGot features test. */

//   test.description = 'several takers with same name: appending after given values are resolved';
//   ( function( { givSequence, gotSequence, expectedSequence }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       gotSequence.push( { err, value, takerId } );
//     }

//     function testTaker2( err, value )
//     {
//       var takerId = 'taker2';
//       gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();

//     for( let given of givSequence ) // pass all values in givSequence to consequenced
//     {
//       con.give( given );
//     }

//     con._onceGot( testTaker1 );
//     con._onceGot( testTaker1 );
//     con._onceGot( testTaker2 );
//     test.identical( gotSequence, expectedSequence );
//   } )( testChecks[ 3 ] );

//   /**/

//   test.description = 'several takers with same name: appending before given values are resolved';
//   ( function( { givSequence, gotSequence, expectedSequence }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       gotSequence.push( { err, value, takerId } );
//     }

//     function testTaker2( err, value )
//     {
//       var takerId = 'taker2';
//       gotSequence.push( { err, value, takerId } );
//     }

//     var con = new _.Consequence();
//     var testCon = new _.Consequence().give();

//     con._onceGot( testTaker1 );
//     con._onceGot( testTaker1 );
//     con._onceGot( testTaker2 );

//     for( let given of givSequence ) // pass all values in givSequence to consequenced
//     {
//       testCon.doThen( () => con.give( given ) );
//     }

//     testCon.doThen( () => test.identical( gotSequence, expectedSequence ) );
//   } )( testChecks[ 4 ] );

//   /**/

//   if( Config.debug )
//   {
//     var conDeb1 = _.Consequence();

//     test.description = 'try to pass as parameter anonymous function';
//     test.shouldThrowError( function()
//     {
//       conDeb1._onceGot( function( err, val) { logger.log( 'i am anonymous' ); } );
//     });

//     var conDeb2 = _.Consequence();

//     test.description = 'try to pass as parameter anonymous function(defined in expression)';

//     function testHandler( err, val) { logger.log( 'i am anonymous' ); }
//     test.shouldThrowError( function()
//     {
//       conDeb2._onceGot( testHandler );
//     } );
//   }

//   conseqTester.give();
//   return conseqTester;
// }

//

function _onceGot( test )
{
  var testMsg = 'msg';
  var testCon = new _.Consequence().give()

  /* common wConsequence goter tests. */

  .doThen( function()
  {
    test.description = 'single value in give sequence, and single taker: attached taker after value resolved';
    function correspondent( err, got )
    {
      test.identical( got, testMsg );
      test.identical( err, undefined );
    }
    var con = new _.Consequence();
    con.give( testMsg );
    con._onceGot( correspondent );
  })

  /* */

  .doThen( function()
  {
    test.description = 'single err in give sequence, and single taker: attached taker after value resolved';

    function correspondent( err, got )
    {
      test.identical( err, testMsg );
      test.identical( got, undefined );
    }
    var con = new _.Consequence();
    con.error( testMsg );
    con._onceGot( correspondent );
  })

  /* */

  .doThen( function()
  {
    test.description = 'test _onceGot in chain';

    function correspondent1( err, got )
    {
      test.identical( got, testMsg + 1 );
      return testMsg + 3;
    }
    function correspondent2( err, got )
    {
      test.identical( got, testMsg + 2 );
    }
    var con = new _.Consequence();
    con.give( testMsg + 1 );
    con.give( testMsg + 2 );
    con._onceGot( correspondent1 );
    con._onceGot( correspondent2 );
  })

  /* test particular _onceGot features test. */

  .doThen( function()
  {
    test.description = 'several takers with same name: appending after given values are resolved';
    var correspondent1Count = 0;
    var correspondent2Count = 0;
    function correspondent1( err, got )
    {
      test.identical( got, testMsg );
      correspondent1Count++;
    }
    function correspondent2( err, got )
    {
      test.identical( got, testMsg );
      correspondent2Count++;
    }
    var con = new _.Consequence();

    con.give( testMsg );
    con.give( testMsg );
    con.give( testMsg );
    con._onceGot( correspondent1 );
    con._onceGot( correspondent1 );
    con._onceGot( correspondent2 );

    test.identical( correspondent1Count, 2 );
    test.identical( correspondent2Count, 1 );
  })

  /* */

  .doThen( function()
  {
    test.description = 'several takers with same name: appending before given values are resolved';
    var correspondent1Count = 0;
    var correspondent2Count = 0;
    function correspondent1( err, got )
    {
      test.identical( got, testMsg );
      correspondent1Count++;
    }
    function correspondent2( err, got )
    {
      test.identical( got, testMsg );
      correspondent2Count++;
    }
    var con = new _.Consequence();

    con._onceGot( correspondent1 );
    con._onceGot( correspondent1 );
    con._onceGot( correspondent2 );

    con.give( testMsg );
    con.give( testMsg );
    con.give( testMsg );

    test.identical( correspondent1Count, 1 );
    test.identical( correspondent2Count, 1 );
  })

  /* */

  .doThen( function()
  {
    if( !Config.debug )
    return;

    var con = new _.Consequence();

    test.description = 'try to pass as parameter anonymous function';
    test.shouldThrowError( function()
    {
      con._onceGot( function( err, val) { logger.log( 'i am anonymous' ); } );
    });

    /* */

    test.description = 'try to pass as parameter anonymous function(defined in expression)';
    function testHandler( err, val ) { logger.log( 'i am anonymous' ); }
    test.shouldThrowError( function()
    {
      debugger;
      con._onceGot( testHandler );
    });
  })

  return testCon;
}

//

// function _onceThen( test )
// {

//   var testCheck1 =

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
//             { err: undefined, value: 5, takerId: 'taker1' }
//           ],
//         throwErr: false
//       }
//     },
//     testCheck2 =
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
//     testCheck3 =
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
//             { err: undefined, value: 5, takerId: 'taker1' },
//             { err: undefined, value: 4, takerId: 'taker2' },
//             { err: undefined, value: 6, takerId: 'taker3' }
//           ],
//         throwErr: false
//       }
//     },
//     testCheck4 =
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
//             { err: undefined, value: 5, takerId: 'taker1' },
//             { err: undefined, value: 6, takerId: 'taker2' },
//           ],
//         throwErr: false
//       }
//     };


//   /* common wConsequence corespondent tests. */

//   test.description = 'single value in give sequence, and single taker: attached taker after value resolved';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();
//     con.give( givSequence.shift() );
//     try
//     {
//       con._onceThen( testTaker1 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck1 );

//   /**/

//   test.description = 'single err in give sequence, and single taker: attached taker after value resolved';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();
//     try
//     {
//       con.error( givSequence.shift() );
//       con._onceThen( testTaker1 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck2 );

//   /**/

//   test.description = 'test _onceThen in chain';

//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//       value++;
//       return value;
//     }

//     function testTaker2( err, value )
//     {
//       var takerId = 'taker2';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     function testTaker3( err, value )
//     {
//       var takerId = 'taker3';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();
//     for (let given of givSequence)
//       con.give( given );

//     try
//     {
//       con._onceThen( testTaker1 );
//       con._onceThen( testTaker2 );
//       con.got( testTaker3 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck3 );

//   /* test particular _onceThen features test. */

//   test.description = 'added several corespondents with same name';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//       value++;
//       return value;
//     }

//     function testTaker2( err, value )
//     {
//       var takerId = 'taker2';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     function testTaker3( err, value )
//     {
//       var takerId = 'taker3';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();

//     try
//     {
//       debugger
//       con._onceThen( testTaker1 );
//       con._onceThen( testTaker1 );
//       con._onceThen( testTaker2 );

//       for( let given of givSequence )
//       {
//         con.give( given );
//       }
//     }
//     catch( err )
//     {
//       console.log(err);
//       got.throwErr = !! err;
//     }

//     test.identical( got, expected );
//   } )( testCheck4 );


//   if( Config.debug )
//   {
//     var conDeb1 = _.Consequence();

//     test.description = 'try to pass as parameter anonymous function';
//     test.shouldThrowError( function()
//     {
//       conDeb1._onceThen( function( err, val) { logger.log( 'i am anonymous' ); } );
//     } );

//     var conDeb2 = _.Consequence();

//     test.description = 'try to pass as parameter anonymous function(defined in expression)';

//     function testHandler( err, val) { logger.log( 'i am anonymous' ); }
//     test.shouldThrowError( function()
//     {
//       conDeb2._onceThen( testHandler );
//     } );
//   }

// };

//

function _onceThen( test )
{
  var testMsg = 'msg';
  var testCon = new _.Consequence().give()

  /* common wConsequence corespondent tests. */

  .doThen( function()
  {
    test.description = 'single value in give sequence, and single taker: attached taker after value resolved';
    function correspondent( err, got )
    {
      test.identical( got, testMsg );
      test.identical( err, undefined );
      return got;
    }
    var con = new _.Consequence();
    con.give( testMsg );
    con._onceThen( correspondent );
    con.got( ( err, got ) => test.identical( got, testMsg ) );
  })

  /* */

  .doThen( function()
  {
    test.description = 'single err in give sequence, and single taker: attached taker after value resolved';

    function correspondent( err, got )
    {
      test.identical( err, testMsg );
      test.identical( got, undefined );
      return err;
    }
    var con = new _.Consequence();
    con.error( testMsg );
    con._onceThen( correspondent );
    con.got( ( err, got ) => test.identical( got, testMsg ) );
  })

  /* */

  .doThen( function()
  {
    test.description = 'test _onceThen in chain';

    function correspondent1( err, got )
    {
      test.identical( got, testMsg );
      return testMsg + 1;
    }
    function correspondent2( err, got )
    {
      test.identical( got, testMsg );
      return testMsg + 2;
    }
    var con = new _.Consequence();
    con.give( testMsg );
    con.give( testMsg );
    con._onceThen( correspondent1 );
    con._onceThen( correspondent2 );
    con.got( ( err, got ) => test.identical( got, testMsg + 1 ) );
    con.got( ( err, got ) => test.identical( got, testMsg + 2 ) );
  })

  /* test particular _onceGot features test. */

  .doThen( function()
  {
    test.description = 'added several corespondents with same name';
    var correspondent1Count = 0;
    var correspondent2Count = 0;
    function correspondent1( err, got )
    {
      test.identical( got, testMsg );
      correspondent1Count++;
      return got;
    }
    function correspondent2( err, got )
    {
      test.identical( got, testMsg );
      correspondent2Count++;
      return got;
    }
    var con = new _.Consequence();

    con._onceThen( correspondent1 );
    con._onceThen( correspondent1 );
    con._onceThen( correspondent2 );

    test.identical( con.correspondentsEarlyGet().length, 2 );

    con.give( testMsg );

    test.identical( correspondent1Count, 1 );
    test.identical( correspondent2Count, 1 );

    test.identical( con.messagesGet().length, 1 );
    test.identical( con.correspondentsEarlyGet().length, 0 );
    test.identical( con.messagesGet()[ 0 ].argument, testMsg );

  })

  /* */

  .doThen( function()
  {
    if( !Config.debug )
    return;

    var con = new _.Consequence();

    test.description = 'try to pass as parameter anonymous function';
    test.shouldThrowError( function()
    {
      con._onceThen( function( err, val) { logger.log( 'i am anonymous' ); } );
    });

    /* */

    test.description = 'try to pass as parameter anonymous function(defined in expression)';
    function testHandler( err, val) { logger.log( 'i am anonymous' ); }
    test.shouldThrowError( function()
    {
      con._onceThen( testHandler );
    });
  })

  return testCon;
}

//

function first( test )
{
  var c = this;
  var amode = _.Consequence.asyncModeGet();
  var testMsg = 'msg';
  var testCon = new _.Consequence().give()

  /**/

  .doThen( function()
  {
    test.description = 'simplest, empty routine';
    var con = new _.Consequence();
    con.first( () => {} );
    con.give( testMsg );
    con.doThen( function( err, got )
    {
      test.identical( got, undefined );
      test.identical( con.messagesGet(), [{ error : undefined, argument : testMsg }] );
    })
    return con;
  })

  /**/

  .doThen( function()
  {
    test.description = 'routine returns something';
    var con = new _.Consequence();
    con.first( () => testMsg );
    con.give( testMsg + 2 );
    con.doThen( function( err, got )
    {
      test.identical( got, testMsg );
      test.identical( con.messagesGet(), [{ error : undefined, argument : testMsg + 2 }] );
    })
    return con;
  })

  /**/

  .doThen( function()
  {
    test.description = 'routine throws error';
    var con = new _.Consequence();
    con.first( () => { throw testMsg });
    con.doThen( function( err, got )
    {
      test.is( _.errIs( err ) );
      test.identical( got, undefined );
      test.identical( con.messagesGet(),[] );
    })
    return con;
  })

  /**/

  .doThen( function()
  {
    test.description = 'routine returns consequence with message';
    var con = new _.Consequence();
    con.first( () => new _.Consequence().give( testMsg ));
    con.doThen( function( err, got )
    {
      test.identical( err, undefined );
      test.identical( got, testMsg );
      test.identical( con.messagesGet(),[] );
    })
    return con;
  })

  /**/

  .doThen( function()
  {
    test.description = 'routine returns consequence with err message';
    var con = new _.Consequence();
    con.first( () => new _.Consequence().error( testMsg ));
    con.doThen( function( err, got )
    {
      test.identical( err, testMsg );
      test.identical( got, undefined );
      test.identical( con.messagesGet(),[] );
    })
    return con;
  })

  /**/

  .doThen( function()
  {
    test.description = 'routine returns consequence that gives message with timeout';
    var con = new _.Consequence();
    var timeBefore = _.timeNow();
    con.first( () => _.timeOut( 1000, () => {} ));
    con.doThen( function( err, got )
    {
      var delay = _.timeNow() - timeBefore;
      var description = test.description = 'delay ' + delay;
      test.is( delay >= 1000 );
      test.description = description;
      test.identical( err, undefined );
      test.identical( got, undefined );
      test.identical( con.messagesGet(),[] );
    })
    return con;
  })

  /**/

  .doThen( function()
  {
    test.description = 'passed consequence shares own message';
    var con = new _.Consequence();
    var con2 = new _.Consequence().give( testMsg );
    con.first( con2 );
    con.doThen( function( err, got )
    {
      test.identical( err, undefined );
      test.identical( got, testMsg );
      test.identical( con.messagesGet(),[] );
      test.identical( con2.messagesGet(), [{ error : undefined, argument : testMsg }] );
    })
    return con;
  })

  /**/

  .doThen( function()
  {
    test.description = 'passed consequence shares own message with timeout';
    var con = new _.Consequence();
    var con2 = _.timeOut( 1000, () => testMsg );
    var timeBefore = _.timeNow();
    con.first( con2 );
    con.doThen( function( err, got )
    {
      var delay = _.timeNow() - timeBefore;
      var description = test.description = 'delay ' + delay;
      test.is( delay >= 1000 );
      test.description = description;
      test.identical( err, undefined );
      test.identical( got, testMsg );
      test.identical( con.messagesGet(),[] );
      test.identical( con2.messagesGet(),[{ error : undefined, argument : testMsg }] );
    })
    return con;
  })

  /* Async taking, Sync giving */

  testCon.doThen( () => _.Consequence.asyncModeSet([ 1, 0 ]) )

   .doThen( function()
  {
    test.description = 'simplest, empty routine';
    var con = new _.Consequence();
    con.first( () => {} );
    con.give( testMsg );
    con.got( function( err, got )
    {
      test.identical( got, undefined );
      test.identical( con.messagesGet(), [{ error : undefined, argument : testMsg }] );
    })

    return _.timeOut( 1, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 1 );
    })
  })

  /**/

  .doThen( function()
  {
    test.description = 'routine returns something';
    var con = new _.Consequence();
    con.first( () => testMsg );
    con.give( testMsg + 2 );
    con.got( function( err, got )
    {
      test.identical( got, testMsg );
    })

    return _.timeOut( 1, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet(), [{ error : undefined, argument : testMsg + 2 }] );
    })
  })

  /**/

  .doThen( function()
  {
    test.description = 'routine throws error';
    var con = new _.Consequence();
    con.first( () => { throw testMsg });
    con.got( function( err, got )
    {
      test.is( _.errIs( err ) );
      test.identical( got, undefined );
      test.identical( con.messagesGet(),[] );
    })

    return _.timeOut( 1, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
    })
  })

  /**/

  .doThen( function()
  {
    test.description = 'routine returns consequence with message';
    var con = new _.Consequence();
    con.first( () => new _.Consequence().give( testMsg ));
    con.got( function( err, got )
    {
      test.identical( err, undefined );
      test.identical( got, testMsg );
    })

    return _.timeOut( 1, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
    })
  })

  /**/

  .doThen( function()
  {
    test.description = 'routine returns consequence with err message';
    var con = new _.Consequence();
    con.first( () => new _.Consequence().error( testMsg ));
    con.got( function( err, got )
    {
      test.identical( err, testMsg );
      test.identical( got, undefined );
      test.identical( con.messagesGet(),[] );
    })
    return _.timeOut( 1, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
    })
  })

  /**/

  .doThen( function()
  {
    test.description = 'routine returns consequence that gives message with timeout';
    var con = new _.Consequence();
    var timeBefore = _.timeNow();
    con.first( () => _.timeOut( 1000, () => {} ));
    con.got( function( err, got )
    {
      var delay = _.timeNow() - timeBefore;
      var description = test.description = 'delay ' + delay;
      test.is( delay >= 1000 );
      test.description = description;
      test.identical( err, undefined );
      test.identical( got, undefined );
      test.identical( con.messagesGet(),[] );
    })
    return _.timeOut( 1001, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
    })
  })

  /**/

  .doThen( function()
  {
    test.description = 'passed consequence shares own message';
    var con = new _.Consequence();
    var con2 = new _.Consequence().give( testMsg );
    con.first( con2 );
    con.got( function( err, got )
    {
      test.identical( err, undefined );
      test.identical( got, testMsg );
      test.identical( con.messagesGet(),[] );
      test.identical( con2.messagesGet(), [{ error : undefined, argument : testMsg }] );
    })
    return _.timeOut( 1, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
    })
  })

  /**/

  .doThen( function()
  {
    test.description = 'passed consequence shares own message with timeout';
    var con = new _.Consequence();
    var con2 = _.timeOut( 1000, () => testMsg );
    var timeBefore = _.timeNow();
    con.first( con2 );
    con.got( function( err, got )
    {
      var delay = _.timeNow() - timeBefore;
      var description = test.description = 'delay ' + delay;
      test.is( delay >= 1000 );
      test.description = description;
      test.identical( err, undefined );
      test.identical( got, testMsg );
      test.identical( con.messagesGet(),[] );
      test.identical( con2.messagesGet(),[{ error : undefined, argument : testMsg }] );
    })
    return _.timeOut( 1001, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
    })
  })

  /* Sync taking, Async giving */

  testCon.doThen( () => _.Consequence.asyncModeSet([ 0, 1 ]) )

   .doThen( function()
  {
    test.description = 'simplest, empty routine';
    var con = new _.Consequence();
    con.got( function( err, got )
    {
      test.identical( got, undefined );
    });
    con.first( () => {} );

    con.give( testMsg );

    test.identical( con.messagesGet().length, 2 );
    test.identical( con.correspondentsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet(), [{ error : undefined, argument : testMsg }] );
    })
  })

  /**/

  .doThen( function()
  {
    test.description = 'routine returns something';
    var con = new _.Consequence();
    con.got( function( err, got )
    {
      test.identical( got, testMsg );
    })
    con.first( () => testMsg );

    con.give( testMsg + 2 );

    test.identical( con.messagesGet().length, 2 );
    test.identical( con.correspondentsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet(), [{ error : undefined, argument : testMsg + 2 }] );
    })
  })

  /**/

  .doThen( function()
  {
    test.description = 'routine throws error';
    var con = new _.Consequence();
    con.first( () => { throw testMsg });

    test.identical( con.messagesGet().length, 0 );

    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet().length, 1 );
      con.got( function( err, got )
      {
        test.is( _.errIs( err ) );
        test.identical( got, undefined );
      });
    })
    .doThen( function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
    })
  })

  /**/

  .doThen( function()
  {
    test.description = 'routine returns consequence with message';
    var con = new _.Consequence();
    con.first( () => new _.Consequence().give( testMsg ));

    test.identical( con.messagesGet().length, 0 );

    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet().length, 1 );

      con.got( function( err, got )
      {
        test.identical( err, undefined );
        test.identical( got, testMsg );
      })
    })
    .doThen( function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
    })
  })

  /**/

  .doThen( function()
  {
    test.description = 'routine returns consequence with err message';
    var con = new _.Consequence();
    con.first( () => new _.Consequence().error( testMsg ));

    test.identical( con.messagesGet().length, 0 );

    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet().length, 1 );

      con.got( function( err, got )
      {
        test.identical( err, testMsg );
        test.identical( got, undefined );
      })
    })
    .doThen( function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
    })
  })

  /**/

  .doThen( function()
  {
    test.description = 'routine returns consequence that gives message with timeout';
    var con = new _.Consequence();
    var timeBefore = _.timeNow();
    con.first( () => _.timeOut( 1000, () => {} ));

    test.identical( con.messagesGet().length, 0 );

    return _.timeOut( 1001, function()
    {
      test.identical( con.messagesGet().length, 1 );

      con.got( function( err, got )
      {
        var delay = _.timeNow() - timeBefore;
        var description = test.description = 'delay ' + delay;
        test.is( delay >= 1000 );
        test.description = description;
        test.identical( err, undefined );
        test.identical( got, undefined );
      })
    })
    .doThen( function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
    })
  })

  /**/

  .doThen( function()
  {
    test.description = 'passed consequence shares own message';
    var con = new _.Consequence();
    var con2 = new _.Consequence().give( testMsg );
    con.first( con2 );

    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet().length, 1 );

      con.got( function( err, got )
      {
        test.identical( err, undefined );
        test.identical( got, testMsg );
      })
    })
    .doThen( function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
      test.identical( con2.messagesGet().length, 1 );
    })
  })

  /**/

  .doThen( function()
  {
    test.description = 'passed consequence shares own message with timeout';
    var con = new _.Consequence();
    var con2 = _.timeOut( 1000, () => testMsg );
    var timeBefore = _.timeNow();
    con.first( con2 );

    return _.timeOut( 1001, function()
    {
      test.identical( con.messagesGet().length, 1 );

      con.got( function( err, got )
      {
        var delay = _.timeNow() - timeBefore;
        var description = test.description = 'delay ' + delay;
        test.is( delay >= 1000 );
        test.description = description;
        test.identical( err, undefined );
        test.identical( got, testMsg );
      })
    })
    .doThen( function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
      test.identical( con2.messagesGet().length, 1 );
    })
  })

  /* Async taking, Async giving */

  testCon.doThen( () => _.Consequence.asyncModeSet([ 1, 1 ]) )

   .doThen( function()
  {
    test.description = 'simplest, empty routine';
    var con = new _.Consequence();
    con.got( function( err, got )
    {
      test.identical( got, undefined );
    });
    con.first( () => {} );
    con.give( testMsg );

    test.identical( con.messagesGet().length, 2 );
    test.identical( con.correspondentsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet(), [{ error : undefined, argument : testMsg }] );
    })
  })

  /**/

  .doThen( function()
  {
    test.description = 'routine returns something';
    var con = new _.Consequence();
    con.got( function( err, got )
    {
      test.identical( got, testMsg );
    })
    con.first( () => testMsg );

    con.give( testMsg + 2 );

    test.identical( con.messagesGet().length, 2 );
    test.identical( con.correspondentsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet(), [{ error : undefined, argument : testMsg + 2 }] );
    })
  })

  /**/

  .doThen( function()
  {
    test.description = 'routine throws error';
    var con = new _.Consequence();
    con.first( () => { throw testMsg });
    con.got( function( err, got )
    {
      test.is( _.errIs( err ) );
      test.identical( got, undefined );
    });

    test.identical( con.messagesGet().length, 0 );

    return _.timeOut( 1, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
    })
  })

  /**/

  .doThen( function()
  {
    test.description = 'routine returns consequence with message';
    var con = new _.Consequence();
    con.first( () => new _.Consequence().give( testMsg ));
    con.got( function( err, got )
    {
      test.identical( err, undefined );
      test.identical( got, testMsg );
    })
    test.identical( con.messagesGet().length, 0 );

    return _.timeOut( 1, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
    })
  })

  /**/

  .doThen( function()
  {
    test.description = 'routine returns consequence with err message';
    var con = new _.Consequence();
    con.first( () => new _.Consequence().error( testMsg ));
    con.got( function( err, got )
    {
      test.identical( err, testMsg );
      test.identical( got, undefined );
    })
    test.identical( con.messagesGet().length, 0 );

    return _.timeOut( 1, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
    })
  })

  /**/

  .doThen( function()
  {
    test.description = 'routine returns consequence that gives message with timeout';
    var con = new _.Consequence();
    var timeBefore = _.timeNow();
    con.first( () => _.timeOut( 1000, () => {} ));
    con.got( function( err, got )
    {
      var delay = _.timeNow() - timeBefore;
      var description = test.description = 'delay ' + delay;
      test.is( delay >= 1000 );
      test.description = description;
      test.identical( err, undefined );
      test.identical( got, undefined );
    })
    test.identical( con.messagesGet().length, 0 );

    return _.timeOut( 1001, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
    })
  })

  /**/

  .doThen( function()
  {
    test.description = 'passed consequence shares own message';
    var con = new _.Consequence();
    var con2 = new _.Consequence().give( testMsg );
    con.first( con2 );
    con.got( function( err, got )
    {
      test.identical( err, undefined );
      test.identical( got, testMsg );
    })
    return _.timeOut( 1, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
      test.identical( con2.messagesGet().length, 1 );
    })
  })

  /**/

  .doThen( function()
  {
    test.description = 'passed consequence shares own message with timeout';
    var con = new _.Consequence();
    var con2 = _.timeOut( 1000, () => testMsg );
    var timeBefore = _.timeNow();
    con.first( con2 );
    con.got( function( err, got )
    {
      var delay = _.timeNow() - timeBefore;
      var description = test.description = 'delay ' + delay;
      test.is( delay >= 1000 );
      test.description = description;
      test.identical( err, undefined );
      test.identical( got, testMsg );
    })
    return _.timeOut( 1001, function()
    {
      test.identical( con.correspondentsEarlyGet().length, 0 );
      test.identical( con.messagesGet().length, 0 );
      test.identical( con2.messagesGet().length, 1 );
    })
  });

  /* */

  testCon.doThen( () => _.Consequence.asyncModeSet( amode ) );

  return testCon;
}

first.timeOut = 20000;

//

function from( test )
{
  var testMsg = 'value';
  var testCon = new _.Consequence().give()

  /**/

  .doThen( function()
  {
    test.description = 'passing value';
    var con = wConsequence.from( testMsg );
    test.identical( con.messagesGet(), [ { error : undefined, argument : testMsg } ] );
    test.identical( con.correspondentsEarlyGet(), [] );
    return con;
  })

  /**/

  .doThen( function()
  {
    test.description = 'passing an error';
    var err = _.err( testMsg );
    var con = wConsequence.from( err );
    test.identical( con.messagesGet(), [ { error : err, argument : undefined } ] );
    test.identical( con.correspondentsEarlyGet(), [] );
    return con;
  })

  /**/

  .doThen( function()
  {
    test.description = 'passing consequence';
    var src = new _.Consequence().give( testMsg );
    var con = wConsequence.from( src );
    test.identical( con, src );
    test.identical( con.messagesGet(), [ { error : undefined, argument : testMsg } ] );
    test.identical( con.correspondentsEarlyGet(), [] );
    return con;
  })

  /**/

  .doThen( function()
  {
    test.description = 'passing resolved promise';
    var src = Promise.resolve( testMsg );
    var con = wConsequence.from( src );
    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet(), [ { error : undefined, argument : testMsg } ] );
      test.identical( con.correspondentsEarlyGet(), [] );
    })
  })

  /**/

  .doThen( function()
  {
    test.description = 'passing rejected promise';
    var src = Promise.reject( testMsg );
    var con = wConsequence.from( src );
    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet(), [ { error : testMsg, argument : undefined } ] );
      test.identical( con.correspondentsEarlyGet(), [] );
    })
  })

  /**/

  .doThen( function()
  {
    wConsequence.prototype.asyncTaking = 0;
    wConsequence.prototype.asyncGiving = 1;
  })

  /**/

  .doThen( function()
  {
    test.description = 'async giving passing value';
    var con = wConsequence.from( testMsg );
    con.got( ( err, got ) => test.identical( got, testMsg ) )
    test.identical( con.messagesGet(), [ { error : undefined, argument : testMsg } ] );
    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet(), [] );
      test.identical( con.correspondentsEarlyGet(), [] );
    })

    return con;
  })

  /**/

  .doThen( function()
  {
    test.description = 'passing an error';
    var src = _.err( testMsg );
    var con = wConsequence.from( src );
    con.got( ( err, got ) => test.identical( err, src ) )
    test.identical( con.messagesGet(), [ { error : src, argument : undefined } ] );
    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet(), [] );
      test.identical( con.correspondentsEarlyGet(), [] );
    })

    return con;
  })

  /**/

  .doThen( function()
  {
    test.description = 'passing consequence';
    var src = new _.Consequence().give( testMsg );
    var con = wConsequence.from( src );
    con.got( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( src.messagesGet(), [ { error : undefined, argument : testMsg } ] );
    test.identical( con, src );
    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet(), [] );
      test.identical( con.correspondentsEarlyGet(), [] );
    })

    return con;
  })

  /**/

  .doThen( function()
  {
    test.description = 'passing resolved promise';
    var src = Promise.resolve( testMsg );
    var con = wConsequence.from( src );
    con.got( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.messagesGet().length, 0 )
    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet().length, 0 )
      test.identical( con.correspondentsEarlyGet().length, 0 )
    })
  })

  /**/

  .doThen( function()
  {
    test.description = 'passing rejected promise';
    var src = Promise.reject( testMsg );
    var con = wConsequence.from( src );
    con.got( ( err, got ) => test.identical( err, testMsg ) );
    test.identical( con.messagesGet().length, 0 )
    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet().length, 0 )
      test.identical( con.correspondentsEarlyGet().length, 0 )
    })
  })

  /**/

  .doThen( function()
  {
    wConsequence.prototype.asyncTaking = 1;
    wConsequence.prototype.asyncGiving = 0;
  })

  /**/

  .doThen( function()
  {
    test.description = 'async taking, passing value';
    var con = wConsequence.from( testMsg );
    con.got( ( err, got ) => test.identical( got, testMsg ) )
    test.identical( con.messagesGet(), [ { error : undefined, argument : testMsg } ] );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet(), [] );
      test.identical( con.correspondentsEarlyGet(), [] );
    })

    return con;
  })

  /**/

  .doThen( function()
  {
    test.description = 'async taking,passing an error';
    var src = _.err( testMsg );
    var con = wConsequence.from( src );
    con.got( ( err, got ) => test.identical( err, src ) )
    test.identical( con.messagesGet(), [ { error : src, argument : undefined } ] );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet(), [] );
      test.identical( con.correspondentsEarlyGet(), [] );
    })

    return con;
  })

  /**/

  .doThen( function()
  {
    test.description = 'async taking,passing consequence';
    var src = new _.Consequence().give( testMsg );
    var con = wConsequence.from( src );
    con.got( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( src.messagesGet(), [ { error : undefined, argument : testMsg } ] );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    test.identical( con, src );
    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet(), [] );
      test.identical( con.correspondentsEarlyGet(), [] );
    })

    return con;
  })

  /**/

  .doThen( function()
  {
    test.description = 'async taking,passing resolved promise';
    var src = Promise.resolve( testMsg );
    var con = wConsequence.from( src );
    con.got( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    test.identical( con.messagesGet().length, 0 )
    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet().length, 0 )
      test.identical( con.correspondentsEarlyGet().length, 0 )
    })
  })

  /**/

  .doThen( function()
  {
    test.description = 'async taking,passing rejected promise';
    var src = Promise.reject( testMsg );
    var con = wConsequence.from( src );
    con.got( ( err, got ) => test.identical( err, testMsg ) );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    test.identical( con.messagesGet().length, 0 )
    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet().length, 0 )
      test.identical( con.correspondentsEarlyGet().length, 0 )
    })
  })

  /**/

  .doThen( function()
  {
    wConsequence.prototype.asyncTaking = 1;
    wConsequence.prototype.asyncGiving = 1;
  })

  /**/

  .doThen( function()
  {
    test.description = 'async, passing value';
    var con = wConsequence.from( testMsg );
    con.got( ( err, got ) => test.identical( got, testMsg ) )
    test.identical( con.messagesGet(), [ { error : undefined, argument : testMsg } ] );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet(), [] );
      test.identical( con.correspondentsEarlyGet(), [] );
    })

    return con;
  })

  /**/

  .doThen( function()
  {
    test.description = 'async,passing an error';
    var src = _.err( testMsg );
    var con = wConsequence.from( src );
    con.got( ( err, got ) => test.identical( err, src ) )
    test.identical( con.messagesGet(), [ { error : src, argument : undefined } ] );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet(), [] );
      test.identical( con.correspondentsEarlyGet(), [] );
    })

    return con;
  })

  /**/

  .doThen( function()
  {
    test.description = 'async,passing consequence';
    var src = new _.Consequence().give( testMsg );
    var con = wConsequence.from( src );
    con.got( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( src.messagesGet(), [ { error : undefined, argument : testMsg } ] );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    test.identical( con, src );
    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet(), [] );
      test.identical( con.correspondentsEarlyGet(), [] );
    })

    return con;
  })

  /**/

  .doThen( function()
  {
    test.description = 'async,passing resolved promise';
    var src = Promise.resolve( testMsg );
    var con = wConsequence.from( src );
    con.got( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    test.identical( con.messagesGet().length, 0 )
    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet().length, 0 )
      test.identical( con.correspondentsEarlyGet().length, 0 )
    })
  })

  /**/

  .doThen( function()
  {
    test.description = 'async,passing rejected promise';
    var src = Promise.reject( testMsg );
    var con = wConsequence.from( src );
    con.got( ( err, got ) => test.identical( err, testMsg ) );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    test.identical( con.messagesGet().length, 0 )
    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet().length, 0 )
      test.identical( con.correspondentsEarlyGet().length, 0 )
    })
  })

  /**/

  .doThen( function()
  {
    wConsequence.prototype.asyncTaking = 0;
    wConsequence.prototype.asyncGiving = 0;
  })
  .doThen( function()
  {
    test.description = 'sync, resolved promise, timeout';
    var src = Promise.resolve( testMsg );
    var con = wConsequence.from( src, 500 );
    con.got( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    test.identical( con.messagesGet().length, 0 )
    return _.timeOut( 1, function()
    {
      test.identical( con.messagesGet().length, 0 )
      test.identical( con.correspondentsEarlyGet().length, 0 )
    })
  })

  /**/

  .doThen( function()
  {
    test.description = 'sync, promise resolved with timeout';
    var src = new Promise( ( resolve ) =>
    {
      setTimeout( () => resolve( testMsg ), 600 );
    })
    var con = wConsequence.from( src, 500 );
    con.got( ( err, got ) => test.is( _.errIs( err ) ) );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    test.identical( con.messagesGet().length, 0 )
    return _.timeOut( 600, function()
    {
      test.identical( con.messagesGet().length, 0 )
      test.identical( con.correspondentsEarlyGet().length, 0 )
    })
  })

  /**/

  .doThen( function()
  {
    test.description = 'sync, timeout, src is a consequence';
    var con = new _.Consequence().give( testMsg );
    con = wConsequence.from( con , 500 );
    con.got( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.correspondentsEarlyGet().length, 0 );
    test.identical( con.messagesGet().length, 0 );
  })

  /**/

  .doThen( function()
  {
    test.description = 'sync, timeout, src is a consequence';
    var con = _.timeOut( 600, () => testMsg );
    con = wConsequence.from( con , 500 );
    con.got( ( err, got ) => test.is( _.errIs( err ) ) );
    test.identical( con.correspondentsEarlyGet().length, 1 );
    test.identical( con.messagesGet().length, 0 );
    return _.timeOut( 600, function()
    {
      test.identical( con.messagesGet().length, 0 )
      test.identical( con.correspondentsEarlyGet().length, 0 )
    })
  })

  /**/

  .doThen( function()
  {
    wConsequence.prototype.asyncTaking = 0;
    wConsequence.prototype.asyncGiving = 0;
  })

  return testCon;
}

// --
// define class
// --

var Self =
{

  name : 'Tools/base/Consequence',
  silencing : 1,
  // verbosity : 7,

  tests :
  {

    simple : simple,
    ordinarMessage : ordinarMessage,
    promiseGot : promiseGot,

    doThen : doThen,
    promiseThen : promiseThen,

    // _onceGot : _onceGot,
    // _onceThen : _onceThen,

    split : split,
    tap : tap,

    ifNoErrorThen : ifNoErrorThen,
    ifErrorThen : ifErrorThen,

    timeOutThen : timeOutThen,

    andGot : andGot,
    andThen : andThen,
    _and : _and,

    first : first,

    from : from,

  },

};

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

})();
