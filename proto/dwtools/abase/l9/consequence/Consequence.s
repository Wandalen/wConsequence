( function _Consequence_s_() {

'use strict';

/**
  @module Tools/base/mixin/Consequence - Advanced synchronization mechanism. Asynchronous routines may use Consequence to wrap postponed result, what allows classify callback for such routines as output, not input, what improves analyzability of a program. Consequence may be used to make a queue for mutually exclusive access to a resource. Algorithmically speaking Consequence is 2 queues ( FIFO ) and a customizable arbitrating algorithm. The first queue contains available resources, the second queue includes competitors for this resources. At any specific moment, one or another queue may be empty or full. Arbitrating algorithm makes resource available for a competitor as soon as possible. There are 2 kinds of resource: regular and erroneous. Unlike Promise, Consequence is much more customizable and can solve engineering problem which Promise cant. But have in mind with great power great responsibility comes. Consequence can coexist and interact with a Promise, getting fulfillment/rejection of a Promise or fulfilling it. Use Consequence to get more flexibility and improve readability of asynchronous aspect of your application.
*/

/**
 * @file Consequence.s.
 */

/*

chainer :

1. ignore / use returned
2. append / prepend returned
3.

*/

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../Tools.s' );

  _.include( 'wProto' );
  _.include( 'wCopyable' );

}

let _global = _global_;
let _ = _global_.wTools;

if( _realGlobal_.wTools && _realGlobal_.wConsequence )
{
  _.assert( _.routineIs( _realGlobal_.wConsequence.After ) );
  let Tools =
  {
    after : _realGlobal_.wConsequence.After,
    // before : _realGlobal_.wTools.before,
  }
  _.mapExtend( _, Tools );
  let Self = _realGlobal_.wConsequence;
  _[ Self.shortName ] = Self;
  if( typeof module !== 'undefined' && module !== null )
  module[ 'exports' ] = Self;
  return;
}

_.assert( !_global_.wConsequence, 'Consequence included several times' );
_.assert( !_.Consequence, 'Consequence included several times' );

//

/**
 * Class wConsequence creates objects that used for asynchronous computations. It represent the queue of results that
 * can computation asynchronously, and has a wide range of tools to implement this process.
 * @class wConsequence
 */

/**
 * Function that accepts result of wConsequence value computation. Used as parameter in methods such as got(), finally(),
  etc.
 * @param {*} err Error object, or any other type, that represent or describe an error reason. If during resolving
    value no exception occurred, it will be set to null;
   @param {*} value resolved by wConsequence value;
 * @callback wConsequence~Competitor
 */

/**
 * Creates instance of wConsequence
 * @example
   let con = new _.Consequence();
   con.take( 'hello' ).got( function( err, value) { console.log( value ); } ); // hello

   let con = _.Consequence();
   con.got( function( err, value) { console.log( value ); } ).take('world'); // world
 * @param {Object|Function|wConsequence} [o] initialization options
 * @returns {wConsequence}
 * @constructor
 * @see {@link wConsequence}
 */

/* heavy optimization */

class wConsequence extends _.CallableObject
{
  constructor()
  {
    let self = super();
    Self.prototype.init.apply( self, arguments );
    return self;
  }
}

let wConsequenceProxy = new Proxy( wConsequence,
{
  apply( original, context, args )
  {
    return new original( ...args );
  }
});

let Parent = null;
let Self = wConsequenceProxy;

wConsequence.shortName = 'Consequence';

//

/**
 * Initialises instance of wConsequence
 * @param {Object|Function|wConsequence} [o] initialization options
 * @private
 * @method init
 * @memberof wConsequence#
 */

function init( o )
{
  let self = this;

  self._competitorEarly = [];
  // self._competitorLate = [];
  self._resource = [];

  if( Config.debug )
  {
    self.tag = self.Composes.tag;
    // self.debug = self.Composes.debug;
    self.resourceLimit = self.Composes.resourceLimit;
    self.dependsOf = [];
  }

  Object.preventExtensions( self );

  if( o )
  {
    if( !Config.debug )
    {
      delete o.tag;
      // delete o.debug;
      delete o.resourceLimit;
      delete o.dependsOf;
    }
    self.copy( o );
  }

}

//

function is( src )
{
  _.assert( arguments.length === 1 );
  return _.consequenceIs( src );
}

//

function isJoinedWithConsequence( src )
{
  _.assert( arguments.length === 1 );
  debugger;
  let result = _.subOf( src, JoinedWithConsequence );
  if( result )
  debugger;
  return result;
}

// --
// chainer
// --

// function sleep()
// {
//   let self = this;
//
//   debugger;
//   _.timeSleepUntil( resourcesCount );
//   debugger;
//
//   function resourcesCount()
//   {
//     if( self.resourcesCount() )
//     return true;
//     return false;
//   }
//
// }

//

/**
 * Method appends resolved value and error handler to wConsequence competitors sequence. That handler accept only one
    value or error reason only once, and don't pass result of it computation to next handler (unlike Promise 'finally').
    if got() called without argument, an empty handler will be appended.
    After invocation, competitor will be removed from competitors queue.
    Returns current wConsequence instance.
 * @example
     function gotHandler1( error, value )
     {
       console.log( 'handler 1: ' + value );
     };

     function gotHandler2( error, value )
     {
       console.log( 'handler 2: ' + value );
     };

     let con1 = new _.Consequence();

     con1.got( gotHandler1 );
     con1.take( 'hello' ).take( 'world' );

     // prints only " handler 1: hello ",

     let con2 = new _.Consequence();

     con2.got( gotHandler1 ).got( gotHandler2 );
     con2.take( 'foo' );

     // prints only " handler 1: foo "

     let con3 = new _.Consequence();

     con3.got( gotHandler1 ).got( gotHandler2 );
     con3.take( 'bar' ).take( 'baz' );

     // prints
     // handler 1: bar
     // handler 2: baz
     //
 * @param {wConsequence~Competitor|wConsequence} [competitor] callback, that accepts resolved value or exception reason.
 * @returns {wConsequence}
 * @see {@link wConsequence~Competitor} competitor callback
 * @throws {Error} if passed more than one argument.
 * @method got
 * @memberof wConsequence#
 */

function got( competitor )
{
  let self = this;
  let times = 1;

  _.assert( arguments.length === 1, 'Expects none or single argument, but got', arguments.length, 'arguments' );

  if( _.numberIs( competitor ) )
  {
    times = competitor;
    competitor = function(){};
  }

  self.__competitorAppend
  ({
    competitor : competitor,
    keeping : false,
    kindOfArguments : Self.KindOfArguments.Both,
    times : times,
    early : true,
  });

  self.__handleResource( false );

  return self;
}

got.having =
{
  consequizing : 1,
}

// //
//
// function lateGot( competitor )
// {
//   let self = this;
//   let times = 1;
//
//   _.assert( arguments.length === 1, 'lateGot : expects none or single argument, lateGot', arguments.length );
//
//   if( _.numberIs( competitor ) )
//   {
//     times = competitor;
//     competitor = function(){};
//   }
//
//   self.__competitorAppend
//   ({
//     competitor : competitor,
//     keeping : false,
//     kindOfArguments : Self.KindOfArguments.Both,
//     times : times,
//     early : false,
//   });
//
//   self.__handleResource( false );
//
//   return self;
// }
//
// lateGot.having =
// {
//   consequizing : 1,
// }

//

function promiseGot()
{
  let self = this;

  return new Promise( function( resolve, reject )
  {
    self.got( function( err, got )
    {
      if( err )
      reject( err );
      else
      resolve( got );
    })
  });

}

promiseGot.having =
{
  consequizing : 1,
}

//

/**
 * Method accepts handler for resolved value/error. This handler method finally adds to wConsequence competitors sequence.
    After processing accepted value, competitor return value will be pass to the next handler in competitors queue.
    Returns current wConsequence instance.

 * @example
   function gotHandler1( error, value )
   {
     console.log( 'handler 1: ' + value );
     value++;
     return value;
   };

   function gotHandler3( error, value )
   {
     console.log( 'handler 3: ' + value );
   };

   let con1 = new _.Consequence();

   con1.finally( gotHandler1 ).finally( gotHandler1 ).got(gotHandler3);
   con1.take( 4 ).take( 10 );

   // prints:
   // handler 1: 4
   // handler 1: 5
   // handler 3: 6

 * @param {wConsequence~Competitor|wConsequence} competitor callback, that accepts resolved value or exception reason.
 * @returns {wConsequence}
 * @throws {Error} if missed competitor.
 * @throws {Error} if passed more than one argument.
 * @see {@link wConsequence~Competitor} competitor callback
 * @see {@link wConsequence#got} got method
 * @method finally
 * @memberof wConsequence#
 */

function _finally( competitor )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  self.__competitorAppend
  ({
    competitor : competitor,
    keeping : true,
    kindOfArguments : Self.KindOfArguments.Both,
    early : true,
  });

  self.__handleResource( false );

  return self;
}

_finally.having =
{
  consequizing : 1,
}

//

function _competitorFinally( competitor ) // xxx
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  self.__competitorAppend
  ({
    competitor : competitor,
    keeping : true,
    kindOfArguments : Self.KindOfArguments.BothWithCompetitor,
    early : true,
  });

  self.__handleResource( false );

  return self;
}

// //
//
// function lateFinally( competitor )
// {
//   let self = this;
//
//   _.assert( arguments.length === 1, 'Expects single argument' );
//
//   self.__competitorAppend
//   ({
//     competitor : competitor,
//     keeping : true,
//     kindOfArguments : Self.KindOfArguments.Both,
//     early : false,
//   });
//
//   self.__handleResource( false );
//
//   return self;
// }
//
// lateFinally.having =
// {
//   consequizing : 1,
// }

//

function promiseFinally()
{
  let self = this;

  _.assert( arguments.length === 0 );

  return new Promise( function( resolve, reject )
  {
    self.got( function( err, got )
    {
      self.take( err, got );
      if( err )
      reject( err );
      else
      resolve( got );
    });
  });

}

promiseFinally.having =
{
  consequizing : 1,
}

//

/**
 * If type of `src` is function, the first method run it on begin, if the result of `src` invocation is instance of
   wConsequence, the current wConsequence will be wait for it resolving, else method added result to resources sequence
   of the current instance.
 * If `src` is instance of wConsequence, the current wConsequence delegates to it his first corespondent.
 * Returns current wConsequence instance.
 * @example
 * function handleGot1(err, val)
   {
     if( err )
     {
       console.log( 'handleGot1 error: ' + err );
     }
     else
     {
       console.log( 'handleGot1 value: ' + val );
     }
   };

   let con = new  _.Consequence();

   con.first( function()
   {
     return 'foo';
   });

 con.take( 100 );
 con.got( handleGot1 );
 // prints: handleGot1 value: foo
*
  function handleGot1(err, val)
  {
    if( err )
    {
      console.log( 'handleGot1 error: ' + err );
    }
    else
    {
      console.log( 'handleGot1 value: ' + val );
    }
  };

  let con = new  _.Consequence();

  con.first( function()
  {
    return _.Consequence().take(3);
  });

 con.take(100);
 con.got( handleGot1 );
 * @param {wConsequence|Function} src wConsequence or routine.
 * @returns {wConsequence}
 * @throws {Error} if `src` has unexpected type.
 * @method first
 * @memberof wConsequence#
 */

function first( src )
{
  let self = this;
  return self._first( src, null );
}

first.having =
{
  consequizing : 1,
}

//

function _first( src, stack )
{
  let self = this;

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );

  if( _.consequenceIs( src ) )
  {
    src.finally( self );
  }
  else if( _.routineIs( src ) )
  {
    let result;

    try
    {
      result = src();
      _.assert( result !== undefined, 'Competitor for consequence.first should return something, not undefined' );
    }
    catch( err )
    {
      debugger;
      result = self.__handleError( err );
    }

    if( _.consequenceIs( result ) ) // xxx
    result.finally( self );
    else
    self.take( result );

  }
  else _.assert( 0, 'first expects consequence of routine, but got', _.strType( src ) );

  return self;
}

//

function _put( o )
{
  let self = this;
  let key = o.key;
  let container = o.container;
  let keeping = o.keeping;
  let argumentOnly = o.argumentOnly;

  _.assert( !_.primitiveIs( o.container ), 'Expects one or two argument, container for resource or key and container' );
  _.assert( o.key === null || _.numberIs( o.key ) || _.strIs( o.key ), () => 'Key should be number or string, but it is ' + _.strType( o.key ) );

  if( o.key !== null )
  {
    self.__competitorAppend
    ({
      keeping : keeping,
      kindOfArguments : argumentOnly ? Self.KindOfArguments.ArgumentOnly : Self.KindOfArguments.Both,
      early : true,
      competitor : __onPutWithKey,
    });

    self.__handleResource( false );
    return self;
  }
  else if( _.arrayIs( o.container ) )
  {
    debugger;
    self.__competitorAppend
    ({
      keeping : keeping,
      kindOfArguments : argumentOnly ? Self.KindOfArguments.ArgumentOnly : Self.KindOfArguments.Both,
      early : true,
      competitor : __onPutToArray,
    });
    self.__handleResource( false );
    return self;
  }
  else
  {
    _.assert( 0, 'Expects key for to put to objects or fixed-size long' );
  }

  /* */

  function __onPutWithKey( err, arg )
  {
    if( err !== undefined )
    container[ key ] = err;
    else
    container[ key ] = arg;
    if( !keeping )
    return;
    if( err )
    throw err;
    return arg;
  }

  /* */

  function __onPutToArray( err, arg )
  {
    debugger;
    _.assert( 0, 'not tested' );
    if( err !== undefined )
    container.push( err );
    else
    container.push( arg );
    if( !keeping )
    return;
    if( err )
    throw err;
    return arg;
  }

}

_put.defaults =
{
  key : null,
  container :  null,
  argumentOnly : 0,
  keeping  : 0,
}

//

function put_pre( routine, args )
{
  let self = this;
  let o = Object.create( null );

  if( args[ 1 ] === undefined )
  {
    o = { container : args[ 0 ] }
  }
  else
  {
    o = { container : args[ 0 ], key : args[ 1 ] }
  }

  _.assert( args.length === 1 || args.length === 2, 'Expects one or two argument, container for resource or key and container' );
  _.routineOptions( routine, o );

  return o;
}

//

let putGive = _.routineFromPreAndBody( put_pre, _put, 'putGive' );
var defaults = putGive.defaults;
defaults.argumentOnly = false;
defaults.keeping = false;

let putKeep = _.routineFromPreAndBody( put_pre, _put, 'putKeep' );
var defaults = putKeep.defaults;
defaults.argumentOnly = false;
defaults.keeping = true;

let thenPutGive = _.routineFromPreAndBody( put_pre, _put, 'thenPutGive' );
var defaults = thenPutGive.defaults;
defaults.argumentOnly = true;
defaults.keeping = false;

let thenPutKeep = _.routineFromPreAndBody( put_pre, _put, 'thenPutKeep' );
var defaults = thenPutKeep.defaults;
defaults.argumentOnly = true;
defaults.keeping = true;

// //
//
// function choke( times )
// {
//   let self = this;
//
//   _.assert( arguments.length === 0 || arguments.length === 1 );
//
//   if( times !== undefined )
//   {
//     _.assert( _.numberIsFinite( times ) );
//     for( let t = 0 ; t < times ; t++ )
//     {
//       self.__competitorAppend
//       ({
//         competitor : function(){},
//         keeping : false,
//         kindOfArguments : Self.KindOfArguments.Both,
//         early : true,
//       });
//       self.__handleResource();
//     }
//   }
//   else
//   {
//     self.__competitorAppend
//     ({
//       competitor : function(){},
//       keeping : false,
//       kindOfArguments : Self.KindOfArguments.Both,
//       early : true,
//     });
//     self.__handleResource();
//   }
//
//   return self;
// }
//
// choke.having =
// {
//   consequizing : 1,
// }
//
// //
//
// function chokeThen( times )
// {
//   let self = this;
//
//   _.assert( arguments.length === 0 || arguments.length === 1 );
//
//   if( times !== undefined )
//   {
//     _.assert( _.numberIsFinite( times ) );
//     for( let t = 0 ; t < times ; t++ )
//     {
//       self.__competitorAppend
//       ({
//         competitor : onChokeThen,
//         keeping : true,
//         kindOfArguments : Self.KindOfArguments.Both,
//         early : true,
//       });
//       self.__handleResource();
//     }
//   }
//   else
//   {
//     self.__competitorAppend
//     ({
//       competitor : onChokeThen,
//       keeping : true,
//       kindOfArguments : Self.KindOfArguments.Both,
//       early : true,
//     });
//     self.__handleResource();
//   }
//
//   return self;
//
//   /* */
//
//   function onChokeThen( err, arg )
//   {
//     debugger;
//     if( err )
//     throw err;
//     return arg;
//   }
//
// }
//
// chokeThen.having =
// {
//   consequizing : 1,
// }

// //
//
// /**
//  * Works like got() method, but adds competitor to queue only if function with same id not exist in queue yet.
//  * Note: this is experimental tool.
//  * @example
//  *
//
//    function gotHandler1( error, value )
//    {
//      console.log( 'handler 1: ' + value );
//    };
//
//    function gotHandler2( error, value )
//    {
//      console.log( 'handler 2: ' + value );
//    };
//
//    let con1 = new _.Consequence();
//
//    con1._onceGot( gotHandler1 )._onceGot( gotHandler1 )._onceGot( gotHandler2 );
//    con1.take( 'foo' ).take( 'bar' );
//
//    // logs:
//    // handler 1: foo
//    // handler 2: bar
//    // competitor gotHandler1 has ben invoked only once, because second competitor was not added to competitors queue.
//
//    // but:
//
//    let con2 = new _.Consequence();
//
//    con2.take( 'foo' ).take( 'bar' ).take('baz');
//    con2._onceGot( gotHandler1 )._onceGot( gotHandler1 )._onceGot( gotHandler2 );
//
//    // logs:
//    // handler 1: foo
//    // handler 1: bar
//    // handler 2: baz
//    // in this case first gotHandler1 has been removed from competitors queue immediately after the invocation, so adding
//    // second gotHandler1 is legitimate.
//
//  *
//  * @param {wConsequence~Competitor|wConsequence} competitor callback, that accepts resolved value or exception reason.
//  * @returns {wConsequence}
//  * @throws {Error} if passed more than one argument.
//  * @throws {Error} if competitor.id is not string.
//  * @see {@link wConsequence~Competitor} competitor callback
//  * @see {@link wConsequence#got} got method
//  * @method _onceGot
//  * @memberof wConsequence#
//  */
//
// function _onceGot( competitor )
// {
//   let self = this;
//   let key = competitor.name ? competitor.name : competitor;
//
//   _.assert( _.strDefined( key ) );
//   _.assert( arguments.length === 1, 'Expects single argument' );
//
//   // xxx
//   let i = _.arrayRightIndex( self._competitorEarly, key, ( e ) => e.id || competitor.name, ( e ) => e );
//
//   if( i >= 0 )
//   return self;
//
//   i = _.arrayRightIndex( self._competitorLate, key, ( e ) => e.id || competitor.name, ( e ) => e );
//
//   if( i >= 0 )
//   return self;
//
//   self.__competitorAppend
//   ({
//     competitor : competitor,
//     keeping : false,
//     kindOfArguments : Self.KindOfArguments.Both,
//     early : true,
//   });
//
//   self.__handleResource( false );
//   return self;
// }
//
// //
//
// /**
//  * Works like finally() method, but adds competitor to queue only if function with same id not exist in queue yet.
//  * Note: this is an experimental tool.
//  *
//  * @example
//    function gotHandler1( error, value )
//    {
//      console.log( 'handler 1: ' + value );
//      value++;
//      return value;
//    };
//
//    function gotHandler2( error, value )
//    {
//      console.log( 'handler 2: ' + value );
//    };
//
//    function gotHandler3( error, value )
//    {
//      console.log( 'handler 3: ' + value );
//    };
//
//    let con1 = new _.Consequence();
//
//    con1._onceThen( gotHandler1 )._onceThen( gotHandler1 ).got(gotHandler3);
//    con1.take( 4 ).take( 10 );
//
//    // prints
//    // handler 1: 4
//    // handler 3: 5
//
//  * @param {wConsequence~Competitor|wConsequence} competitor callback, that accepts resolved value or exception
//    reason.
//  * @returns {*}
//  * @throws {Error} if passed more than one argument.
//  * @throws {Error} if competitor is defined as anonymous function including anonymous function expression.
//  * @see {@link wConsequence~Competitor} competitor callback
//  * @see {@link wConsequence#finally} finally method
//  * @see {@link wConsequence#_onceGot} _onceGot method
//  * @method _onceThen
//  * @memberof wConsequence#
//  */
//
// function _onceThen( competitor )
// {
//   let self = this;
//   let key = competitor.name ? competitor.name : competitor;
//
//   _.assert( _.strDefined( key ) );
//   _.assert( arguments.length === 1, 'Expects single argument' );
//
//   // xxx
//   let i = _.arrayRightIndex( self._competitorEarly, key, ( e ) => e.id, ( e ) => e );
//
//   if( i >= 0 )
//   {
//     debugger;
//     return self;
//   }
//
//   i = _.arrayRightIndex( self._competitorLate, key, ( e ) => e.id || competitor.name, ( e ) => e );
//
//   if( i >= 0 )
//   {
//     debugger;
//     return self;
//   }
//
//   self.__competitorAppend
//   ({
//     competitor : competitor,
//     keeping : true,
//     kindOfArguments : Self.KindOfArguments.Both,
//     early : true,
//   });
//
//   self.__handleResource( false );
//   return self;
// }

//

/**
 * Returns new _.Consequence instance. If on cloning moment current wConsequence has unhandled resolved values in queue
   the first of them would be handled by new _.Consequence. Else pass accepted
 * @example
   function gotHandler1( error, value )
   {
     console.log( 'handler 1: ' + value );
     value++;
     return value;
   };

   function gotHandler2( error, value )
   {
     console.log( 'handler 2: ' + value );
   };

   let con1 = new _.Consequence();
   con1.take(1).take(2).take(3);
   let con2 = con1.split();
   con2.got( gotHandler2 );
   con2.got( gotHandler2 );
   con1.got( gotHandler1 );
   con1.got( gotHandler1 );

    // prints:
    // handler 2: 1 // only first value copied into cloned wConsequence
    // handler 1: 1
    // handler 1: 2

 * @returns {wConsequence}
 * @throws {Error} if passed any argument.
 * @method split
 * @memberof wConsequence#
 */

function split( first )
{
  let self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  let result = new Self();

  if( first ) // xxx
  {
    result.finally( first );
    self.done( function( err, arg )
    {
      result.take( err, arg );
      this.take( err, arg );
    });
  }
  else
  {
    self.finally( result );
  }

  return result;
}

split.having =
{
  consequizing : 1,
}

//

/**
 * Works like got() method, but value that accepts competitor, passes to the next taker in takers queue without
   modification.
 * @example
 *
   function gotHandler1( error, value )
   {
     console.log( 'handler 1: ' + value );
     value++;
     return value;
   }

   function gotHandler2( error, value )
   {
     console.log( 'handler 2: ' + value );
   }

   function gotHandler3( error, value )
   {
     console.log( 'handler 3: ' + value );
   }

   let con1 = new _.Consequence();
   con1.take(1).take(4);

   // prints:
   // handler 1: 1
   // handler 2: 1
   // handler 3: 4

 * @param {wConsequence~Competitor|wConsequence} competitor callback, that accepts resolved value or exception
   reason.
 * @returns {wConsequence}
 * @throws {Error} if passed more than one arguments
 * @see {@link wConsequence#got} got method
 * @method tap
 * @memberof wConsequence#
 */

function tap( competitor )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  self.__competitorAppend
  ({
    competitor : competitor,
    keeping : false,
    tapping : true,
    kindOfArguments : Self.KindOfArguments.Both,
    early : true,
  });

  self.__handleResource( false );

  return self;
}

tap.having =
{
  consequizing : 1,
}

//

function thenGive()
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  self.__competitorAppend
  ({
    competitor : arguments[ 0 ],
    keeping : false,
    kindOfArguments : Self.KindOfArguments.ArgumentOnly,
    early : true,
  });

  self.__handleResource( false );

  return self;
}

thenGive.having =
{
  consequizing : 1,
}

//

/**
 * Method pushed `competitor` callback into wConsequence competitors queue. That callback will
   trigger only in that case if accepted error parameter will be null. Else accepted error will be passed to the next
   competitor in queue. After handling accepted value, competitor pass result to the next handler, like finally
   method.
 * @returns {wConsequence}
 * @throws {Error} if passed more than one arguments
 * @see {@link wConsequence#got} finally method
 * @method thenKeep
 * @memberof wConsequence#
 */

function thenKeep()
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  self.__competitorAppend
  ({
    competitor : arguments[ 0 ],
    keeping : true,
    kindOfArguments : Self.KindOfArguments.ArgumentOnly,
    early : true,
  });

  self.__handleResource( false );
  return self;
}

thenKeep.having =
{
  consequizing : 1,
}

//

function exceptGive()
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  self.__competitorAppend
  ({
    competitor : arguments[ 0 ],
    keeping : false,
    kindOfArguments : Self.KindOfArguments.ErrorOnly,
    early : true,
  });

  self.__handleResource( false );
  return self;
}

exceptGive.having =
{
  consequizing : 1,
}

//

/**
 * exceptKeep method pushed `competitor` callback into wConsequence competitors queue. That callback will
   trigger only in that case if accepted error parameter will be defined and not null. Else accepted parameters will
   be passed to the next competitor in queue.

 * @param {wConsequence~Competitor|wConsequence} competitor callback, that accepts exception  reason and value .
 * @returns {wConsequence}
 * @throws {Error} if passed more than one arguments
 * @see {@link wConsequence#got} finally method
 * @method exceptKeep
 * @memberof wConsequence#
 */

function exceptKeep()
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  self.__competitorAppend
  ({
    competitor : arguments[ 0 ],
    keeping : true,
    kindOfArguments : Self.KindOfArguments.ErrorOnly,
    early : true,
  });

  self.__handleResource( false );

  return self;
}

exceptKeep.having =
{
  consequizing : 1,
}

//

/**
 * Creates and adds to corespondents sequence error handler. If handled resource contains error, corespondent logs it.
 * @returns {wConsequence}
 * @throws {Error} If called with any argument.
 * @method exceptLog
 * @memberof wConsequence#
 */

function exceptLog()
{
  let self = this;

  _.assert( arguments.length === 0 );

  function reportError( err )
  {
    throw _.errLogOnce( err );
  }

  self.__competitorAppend
  ({
    competitor : reportError,
    keeping : true,
    kindOfArguments : Self.KindOfArguments.ErrorOnly,
    early : true,
  });

  self.__handleResource( false );

  return self;
}

exceptLog.having =
{
  consequizing : 1,
}

//

function timeOut_pre( routine, args )
{
  let o = { time : args[ 0 ], competitor : args[ 1 ] };
  _.routineOptions( routine, o );
  _.assert( arguments.length === 2 );
  _.assert( args.length === 1 || args.length === 2 );
  _.assert( _.numberIs( o.time ) );
  return o;
}

//

// function _timeOut( time, competitor )
function _timeOut( o )
{
  let self = this;
  let time = o.time;
  let competitor = o.competitor;

  _.assert( arguments.length === 1 );

  /* */

  if( !competitor )
  if( o.argumentOnly )
  competitor = Self.PassThruArgument;
  else
  competitor = Self.PassThruBoth;

  /* */

  let cor;
  if( _.consequenceIs( competitor ) )
  cor = function __timeOutThen()
  {
    debugger;
    return _.timeOut( o.time, function onTimeOut( err, arg )
    {
      debugger;
      competitor.take.apply( competitor, arguments );
      if( err )
      throw _.err( err );
      return arg;
    });
  }
  else
  cor = function __timeOutThen()
  {
    return _.timeOut( o.time, self, competitor, arguments );
  }

  /* */

  self.__competitorAppend
  ({
    keeping : true,
    competitor : cor,
    kindOfArguments : o.argumentOnly ? Self.KindOfArguments.ArgumentOnly : Self.KindOfArguments.Both,
    early : true,
  });

  self.__handleResource( false );

  return self;
}

_timeOut.defaults =
{
  time : null,
  competitor : null,
  argumentOnly : 1,
}

_timeOut.having =
{
  consequizing : 1,
}

//


//

/**
 * Works like finally, but when competitor accepts resource from resources sequence, execution of competitor will be
    delayed. The result of competitor execution will be passed to the handler that is first in competitor queue
    on execution end moment.

 * @example
 *
   function gotHandler1( error, value )
   {
     console.log( 'handler 1: ' + value );
     value++;
     return value;
   }

   function gotHandler2( error, value )
   {
     console.log( 'handler 2: ' + value );
   }

   let con = new _.Consequence();

   con.timeOut(500, gotHandler1).got( gotHandler2 );
   con.take(90);
   //  prints:
   // handler 1: 90
   // handler 2: 91

 * @param {number} time delay in milliseconds
 * @param {wConsequence~Competitor|wConsequence} competitor callback, that accepts exception reason and value.
 * @returns {wConsequence}
 * @throws {Error} if missed arguments.
 * @throws {Error} if passed extra arguments.
 * @see {@link wConsequence~finally} finally method
 * @method timeOut
 * @memberof wConsequence#
 */

let timeOut = _.routineFromPreAndBody( timeOut_pre, _timeOut, 'timeOut' );
var defaults = timeOut.defaults;
defaults.argumentOnly = false;

let thenTimeOut = _.routineFromPreAndBody( timeOut_pre, _timeOut, 'thenTimeOut' );
var defaults = thenTimeOut.defaults;
defaults.argumentOnly = true;

//

// function timeOut( time, competitor )
// {
//   let self = this;
//
//   _.assert( arguments.length === 1 || arguments.length === 2 );
//   // _.assert( arguments.length === 1, 'Two arguments timeOut is deprecated' );
//
//   /* */
//
//   if( !competitor )
//   competitor = Self.PassThru;
//
//   /* */
//
//   let cor;
//   if( _.consequenceIs( competitor ) )
//   cor = function __timeOutThen( err, arg )
//   {
//     debugger;
//     return _.timeOut( time, function onTimeOut()
//     {
//       debugger;
//       competitor.take( err, arg );
//       if( err )
//       throw _.err( err );
//       return arg;
//     });
//   }
//   else
//   cor = function __timeOutThen( err, arg )
//   {
//     return _.timeOut( time, self, competitor, [ err, arg ] );
//   }
//
//   /* */
//
//   self.__competitorAppend
//   ({
//     keeping : true,
//     competitor : cor,
//     // kindOfArguments : Self.KindOfArguments.Both,
//     kindOfArguments : Self.KindOfArguments.ArgumentOnly,
//     early : true,
//   });
//
//   self.__handleResource( false );
//
//   return self;
// }
//
// timeOut.having =
// {
//   consequizing : 1,
// }

// --
// advanced
// --

//

function wait()
{
  let self = this;
  let result = new _.Consequence();

  _.assert( arguments.length === 0 );

  self.got( function __waitGot( err, arg )
  {
    if( err )
    self.error( err );
    else
    self.take( result );
  });

  self.take( null );

  return result;
}

//

function participate( con )
{
  let self = this;

  _.assert( _.consequenceIs( con ) );
  _.assert( arguments.length === 1 );

  debugger;

  con.got( 1 );
  con.take( self );
  // self.got( con );

  return con;
}

//

function participateThen( con )
{
  let self = this;

  _.assert( _.consequenceIs( con ) );
  _.assert( arguments.length === 1 );

  con.got( 1 );
  self.finally( con );

  return con;
}

//

function and_pre( routine, args )
{
  let o = args[ 0 ];

  if( !_.mapIs( o ) )
  o = { competitors : args[ 0 ] };

  _.routineOptions( routine, o );
  _.assert( arguments.length === 2 );
  _.assert( args.length === 1 );

  return o;
}

//

// function _and( srcs, taking )
function _and( o )
{
  let self = this;
  let errs = [];
  let args = [];
  let anyErr;
  let competitors = o.competitors;
  let keeping = o.keeping;

  _.assertRoutineOptions( _and, arguments );

  if( !_.arrayIs( competitors ) )
  competitors = [ competitors ];
  else
  competitors = competitors.slice();

  competitors.push( self );

  /* */

  let count = competitors.length;

  /* */

  if( Config.debug )
  if( self.diagnostics )
  {

    for( let s = 0 ; s < competitors.length-1 ; s++ )
    {
      let src = competitors[ s ];
      _.assert( _.consequenceIs( src ) || _.routineIs( src ) || src === null, () => 'Consequence.and expects consequence, routine or null, but got ' + _.strType( src ) );
      if( !_.consequenceIs( src ) )
      continue;
      src.assertNoDeadLockWith( self );
      self.dependsOf.push( src );
    }

  }

  /* */

  self.got( start );

  return self;

  /* - */

  function start( err, arg )
  {

    for( let s = 0 ; s < competitors.length-1 ; s++ )
    {
      let src = competitors[ s ];

      if( !_.consequenceIs( src ) && _.routineIs( src ) )
      {
        src = competitors[ s ] = src();
        if( Config.debug )
        if( self.diagnostics )
        self.dependsOf.push( src );
      }

      if( Config.debug )
      if( self.diagnostics )
      if( _.consequenceIs( competitors[ s ] ) )
      src.assertNoDeadLockWith( self );

      _.assert( _.consequenceIs( src ) || src === null, () => 'Expects consequence or null, but got ' + _.strType( src ) );

      if( src === null )
      {
        __got( s, undefined, null );
        continue;
      }

      let r = _.routineJoin( undefined, __got, [ s ] );
      src.got( r );

    }

    __got( competitors.length-1, err, arg );

  }

  /* */

  function __got( index, err, arg )
  {

    // console.log( 'and', index, ':', count, -1, ' = ', count-1, '-', arg && arg.argsStr ? arg.argsStr : arg );
    count -= 1;

    if( err && !anyErr )
    anyErr = err;

    errs[ index ] = err;
    args[ index ] = arg;

    if( Config.debug )
    if( self.diagnostics )
    if( index < competitors.length-1 )
    if( _.consequenceIs( competitors[ index ] ) )
    {
      _.arrayRemoveElementOnceStrictly( self.dependsOf, competitors[ index ] );
    }

    if( count === 0 )
    _.timeSoon( __give );

  }

  /* */

  function __give()
  {

    // console.log( 'and :', 'take' );

    if( keeping )
    for( let i = 0 ; i < competitors.length-1 ; i++ )
    if( competitors[ i ] )
    competitors[ i ].take( errs[ i ], args[ i ] );

    if( anyErr )
    self.error( anyErr );
    else
    self.take( args );

  }

}

_and.defaults =
{
  competitors : null,
  keeping : 1,
}

var having = _and.having = Object.create( null );
having.consequizing = 1;
having.andLike = 1;

/**
 * Method accepts array of wConsequences object. If current wConsequence instance ready to resolve resource, it will be
   wait for all passed wConsequence instances will been resolved, finally current wConsequence resolve own resource.
   Returns current wConsequence.
 * @example
 *
   function handleGot1(err, val)
   {
     if( err )
     {
       console.log( 'handleGot1 error: ' + err );
     }
     else
     {
       console.log( 'handleGot1 value: ' + val );
     }
   };

   let con1 = new _.Consequence();
   let con2 = new _.Consequence();

   con1.got( function( err, value )
   {
     console.log( 'con1 handler executed with value: ' + value + 'and error: ' + err );
   } );

   con2.got( function( err, value )
   {
     console.log( 'con2 handler executed with value: ' + value + 'and error: ' + err );
   } );

   let conOwner = new  _.Consequence();

   conOwner.andTake( [ con1, con2 ] );

   conOwner.take( 100 );
   conOwner.got( handleGot1 );

   con1.take( 'value1' );
   con2.error( 'ups' );
   // prints
   // con1 handler executed with value: value1and error: null
   // con2 handler executed with value: undefinedand error: ups
   // handleGot1 value: 100

 * @param {wConsequence[]|wConsequence} srcs array of wConsequence
 * @returns {wConsequence}
 * @throws {Error} if missed arguments.
 * @throws {Error} if passed extra arguments.
 * @method andTake
 * @memberof wConsequence#
 */

// function andTake( srcs )
// {
//   let self = this;
//   _.assert( arguments.length === 1, 'Expects single argument' );
//   return self._and( srcs, false );
// }

let andTake = _.routineFromPreAndBody( and_pre, _and, 'andTake' );
var defaults = andTake.defaults;
defaults.keeping = false;

//

/**
 * Works like andTake() method, but unlike andTake() andKeep() take back massages to src consequences once all come.
 * @see wConsequence#andTake
 * @param {wConsequence[]|wConsequence} srcs Array of wConsequence objects
 * @throws {Error} If missed or passed extra argument.
 * @method andKeep
 * @memberof wConsequence#
 */

let andKeep = _.routineFromPreAndBody( and_pre, _and, 'andKeep' );
var defaults = andKeep.defaults;
defaults.keeping = true;

// function andKeep( srcs )
// {
//   let self = this;
//   _.assert( arguments.length === 1, 'Expects single argument' );
//   return self._and
//   ({
//     competitors : srcs,
//     keeping : true,
//   });
// }
//
// andKeep.having =
// {
//   consequizing : 1,
//   andLike : 1,
// }

//

function eitherKeepSplit( srcs )
{
  let self = this;
  _.assert( arguments.length === 1, 'Expects single argument' );

  if( !_.arrayIs( srcs ) )
  srcs = [ srcs ];
  else
  srcs = srcs.slice();
  srcs.unshift( self );

  let con = new Self().take( null );
  con.eitherKeep( srcs );
  return con;
}

eitherKeepSplit.having =
{
  consequizing : 1,
  andLike : 1,
}

//

function eitherTake( srcs )
{
  let self = this;
  _.assert( arguments.length === 1, 'Expects single argument' );
  return self._either( srcs, true );
}

eitherTake.having =
{
  consequizing : 1,
}

//

function eitherKeep( srcs )
{
  let self = this;
  _.assert( arguments.length === 1, 'Expects single argument' );
  return self._either( srcs, false );
}

eitherKeep.having =
{
  consequizing : 1,
  andLike : 1,
}

//

function _either( srcs, taking )
{
  let self = this;

  if( !_.arrayIs( srcs ) )
  srcs = [ srcs ];

  /* */

  let count = 0;

  /* */

  self.got( function( err, arg )
  {

    for( let a = 0 ; a < srcs.length ; a++ )
    {
      let src = srcs[ a ];
      _.assert( _.consequenceIs( src ) || src === null );
      if( src === null )
      continue;
      src.got( _.routineJoin( undefined, got, [ a ] ) );
    }

  });

  return self;

  /* - */

  function got( index, err, arg )
  {

    count += 1;

    if( count === 1 )
    self.take( err, arg );

    if( !taking )
    srcs[ index ].take( err, arg );

  }

}

//

let JoinedWithConsequence = Object.create( null );
JoinedWithConsequence.routineJoin = _.routineSeal;
JoinedWithConsequence.context = null;
JoinedWithConsequence.method = null;
JoinedWithConsequence.consequence = null;
JoinedWithConsequence.constructor = function JoinedWithConsequence()
{
  debugger;
};

//

function _prepareJoinedWithConsequence()
{

  for( let r in Self.prototype ) ( function( r )
  {
    if( Self.prototype._Accessors[ r ] )
    return;
    let routine = Self.prototype[ r ];
    if( !routine.having || !routine.having.consequizing )
    return;

    if( routine.having.andLike )
    JoinedWithConsequence[ r ] = function()
    {
      let args = arguments;
      let method = [];
      _.assert( arguments.length === 1, 'Expects single argument' );
      _.assert( _.longIs( args[ 0 ] ) );
      for( let i = 0 ; i < args[ 0 ].length ; i++ )
      {
        method.push( this.routineJoin( this.context, this.method, [ args[ 0 ][ i ] ] ) );
      }
      this.consequence[ r ]( method );
      return this;
    }
    else
    JoinedWithConsequence[ r ] = function()
    {
      let args = arguments;
      let method = this.routineJoin( this.context, this.method, args );
      this.consequence[ r ]( method );
      return this;
    }

  })( r );

}


//

function _join( routineJoin, args )
{
  let self = this;
  let result = Object.create( JoinedWithConsequence );

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( args.length === 1 || args.length === 2 );
  _.assert( _.consequenceIs( this ) );

  result.routineJoin = routineJoin;
  result.consequence = self;

  if( args[ 1 ] !== undefined )
  {
    result.context = args[ 0 ];
    result.method = args[ 1 ];
  }
  else
  {
    result.method = args[ 0 ];
  }

  return result;
}

//

function join( context, method )
{
  let self = this;
  return self._join( _.routineJoin, arguments );
}

//

function seal( context, method )
{
  let self = this;
  return self._join( _.routineSeal, arguments );
}

//

function tolerantCallback()
{
  let self = this;
  _.assert( arguments.length === 0 );
  return function tolerantCallback( err, arg )
  {
    if( !err )
    err = undefined;
    if( arg === null || err )
    arg = undefined;
    return self( err, arg );
  }
}

// function seal( context, method )
// {
//   let self = this;
//   let result = Object.create( null );
//
//   _.assert( arguments.length === 1 || arguments.length === 2 );
//   _.assert( _.consequenceIs( this ) );
//
//   result.consequence = self;
//
//   result.thenKeep = function thenKeep( _method )
//   {
//     let args = method ? arguments : arguments[ 1 ];
//     let c = _.routineSeal( context, method || _method, args );
//     self.thenKeep( c );
//     return this;
//   }
//
//   result.exceptKeep = function exceptKeep( _method )
//   {
//     let args = method ? arguments : arguments[ 1 ];
//     let c = _.routineSeal( context, method || _method, args );
//     self.exceptKeep( c );
//     return this;
//   }
//
//   result.finally = function finally( _method )
//   {
//     let args = method ? arguments : arguments[ 1 ];
//     let c = _.routineSeal( context, method || _method, args );
//     self.finally( c );
//     return this;
//   }
//
//   result.got = function got( _method )
//   {
//     let args = method ? arguments : arguments[ 2 ];
//     let c = _.routineSeal( context, method || _method, args );
//     self.got( c );
//     return this;
//   }
//
//   return result;
// }

// --
// resource
// --

/**
 * Method pushes `resource` into wConsequence resources queue.
 * Method also can accept two parameters: error, and
 * Returns current wConsequence instance.
 * @example
 * function gotHandler1( error, value )
   {
     console.log( 'handler 1: ' + value );
   };

   let con1 = new _.Consequence();

   con1.got( gotHandler1 );
   con1.take( 'hello' );

   // prints " handler 1: hello ",
 * @param {*} [resource] Resolved value
 * @returns {wConsequence} consequence current wConsequence instance.
 * @throws {Error} if passed extra parameters.
 * @method take
 * @memberof wConsequence#
 */

function take( resource )
{
  let self = this;
  _.assert( arguments.length === 2 || arguments.length === 1 || arguments.length === 0, 'Expects 0, 1 or 2 arguments, got ' + arguments.length );

  if( arguments.length === 2 )
  self.__take( arguments[ 0 ], arguments[ 1 ] );
  else
  self.__take( undefined, resource );

  if( self.asyncCompetitorHanding || self.asyncResourceAdding )
  self.__handleResource( true );
  else
  self.__handleResourceAct();

  return self;
}

take.having =
{
  consequizing : 1,
}

//

/**
 * Using for adds to resource queue error reason, that using for informing corespondent that will handle it, about
 * exception
 * @example
   function showResult(err, val)
   {
     if( err )
     {
       console.log( 'handleGot1 error: ' + err );
     }
     else
     {
       console.log( 'handleGot1 value: ' + val );
     }
   };

   let con = new  _.Consequence();

   function divade( x, y )
   {
     let result;
     if( y!== 0 )
     {
       result = x / y;
       con.take(result);
     }
     else
     {
       con.error( 'divide by zero' );
     }
   }

   con.got( showResult );
   divade( 3, 0 );

   // prints : handleGot1 error: divide by zero
 * @param {*|Error} error error, or value that represent error reason
 * @throws {Error} if passed extra parameters.
 * @method error
 * @memberof wConsequence#
 */

function error( error )
{
  let self = this;

  _.assert( arguments.length === 1 || arguments.length === 0 );

  if( arguments.length === 0  )
  error = _.err();

  self.__take( error, undefined );

  if( self.asyncCompetitorHanding || self.asyncResourceAdding )
  self.__handleResource( true );
  else
  self.__handleResourceAct();

  return self;
}

error.having =
{
  consequizing : 1,
}

// //
//
// /**
//  * Method creates and pushes resource object into wConsequence resources sequence.
//  * Returns current wConsequence instance.
//  * @param {*} error Error value
//  * @param {*} argument resolved value
//  * @returns {_giveWithError}
//  * @private
//  * @throws {Error} if missed arguments or passed extra arguments
//  * @method _giveWithError
//  * @memberof wConsequence#
//  */
//
// function _giveWithError( error, argument )
// {
//   let self = this;
//
//   _.assert( arguments.length === 2, 'Expects exactly two arguments' );
//
//   return self.__take( error, argument );
// }

//

function __take( error, argument )
{
  let self = this;

  let resource =
  {
    error : error,
    argument : argument,
  }

  _.assert( error !== undefined || argument !== undefined, 'Argument of take should be something, not undefined' );
  _.assert( error === undefined || argument === undefined, 'Cant take both error and argument, one should be undefined' );

  if( _.consequenceIs( argument ) )
  {
    debugger;
    argument.got( self );
    return self;
  }

  if( Config.debug )
  {
    _.assert( !self.resourceLimit || self._resource.length < self.resourceLimit, () => 'Resource limit' + ( self.tag ? ' of ' + self.tag + ' ' : ' ' ) + 'set to ' + self.resourceLimit + ', but got more resources' );
    let msg = '{-error-} and {-argument-} channels should not be in use simultaneously\n' +
      '{-error-} or {-argument-} should be undefined, but currently ' +
      '{-error-} is ' + _.strType( error ) +
      '{-argument-} is ' + _.strType( argument );
    _.assert( error === undefined || argument === undefined, msg );
  }

  self._resource.push( resource );

  return self;
}

//

// /**
//  * Creates and pushes resource object into wConsequence resources sequence, and trying to get and return result of
//     handling this resource by appropriate competitor.
//  * @example
//    let con = new  _.Consequence();
//
//    function increment( err, value )
//    {
//      return ++value;
//    };
//
//
//    con.got( increment );
//    let result = con.ping( undefined, 4 );
//    console.log( result );
//    // prints 5;
//  * @param {*} error
//  * @param {*} argument
//  * @returns {*} result
//  * @throws {Error} if missed arguments or passed extra arguments
//  * @method ping
//  * @memberof wConsequence#
//  */
//
// function _ping( error, argument )
// {
//   let self = this;
//
//   throw _.err( 'deprecated' );
//
//   _.assert( arguments.length === 2, 'Expects exactly two arguments' );
//
//   let resource =
//   {
//     error : error,
//     argument : argument,
//   }
//
//   self._resource.push( resource );
//   let result = self.__handleResource();
//
//   return result;
// }

// --
// handling mechanism
// --

/**
 * Creates and handles error object based on `err` parameter.
 * Returns new _.Consequence instance with error in resources queue.
 * @param {*} err error value.
 * @returns {wConsequence}
 * @private
 * @method __handleError
 * @memberof wConsequence#
 */

function __handleError( err, competitor )
{
  let self = this;
  err = _._err
  ({
    args : [ err ],
    level : 2,
  });

  if( Config.debug )
  if( competitor && self.diagnostics && self.stacking )
  err.stack = err.stack + '\n+\n' + competitor.stack;

  if( !_.errIsAttended( err ) )
  _.errAttentionRequest( err );

  let result = new Self().error( err );

  if( err.attentionRequested )
  {

    // if( Config.debug )
    // _global.logger.error( ' Consequence caught error, details come later' );

    _.timeOut( 250, function _unhandledError()
    {
      if( !_.errIsAttended( err ) )
      {
        _global.logger.error( 'Unhandled error caught by Consequence' );
        _.errLog( err );
        debugger;
      }
      return null;
    });

  }

  return result;
}

//

/**
 * Method for processing corespondents and _resource queue. Provides handling of resolved resource values and errors by
    corespondents from competitors value. Method takes first resource from _resource sequence and try to pass it to
    the first corespondent in corespondents sequence. Method returns the result of current corespondent execution.
    There are several cases of __handleResource behavior:
    - if corespondent is regular function:
      trying to pass resources error and argument values into corespondent and executing. If during execution exception
      occurred, it will be catch by __handleError method. If corespondent was not added by tap or persist method,
      __handleResource will remove resource from head of queue.

      If corespondent was added by finally, _onceThen, exceptKeep, or by other "thenable" method of wConsequence, finally:

      1) if result of corespondents is ordinary value, finally __handleResource method appends result of corespondent to the
      head of resources queue, and therefore pass it to the next handler in corespondents queue.
      2) if result of corespondents is instance of wConsequence, __handleResource will append current wConsequence instance
      to result instance corespondents sequence.

      After method try to handle next resource in queue if exists.

    - if corespondent is instance of wConsequence:
      in that case __handleResource pass resource into corespondent`s resources queue.

      If corespondent was added by tap, or one of finally, _onceThen, exceptKeep, or by other "thenable" method of
      wConsequence finally __handleResource try to pass current resource to the next handler in corespondents sequence.

    - if in current wConsequence are present corespondents added by persist method, finally __handleResource passes resource to
      all of them, without removing them from sequence.

 * @returns {*}
 * @throws {Error} if on invocation moment the _resource queue is empty.
 * @private
 * @method __handleResource
 * @memberof wConsequence#
 */

function __handleResource( isResource )
{
  let self = this;
  let async = isResource ? self.asyncResourceAdding : self.asyncCompetitorHanding;

  _.assert( _.boolIs( isResource ) );

  if( async )
  {

    if( !self._competitorEarly.length /*&& !self._competitorLate.length*/ )
    return;
    if( !self._resource.length )
    return;

    _.timeSoon( () => self.__handleResourceAct() );

  }
  else
  {
    self.__handleResourceAct();
  }

}

//

function __handleResourceAct()
{
  let self = this;

  while( true )
  {

    if( !self._competitorEarly.length /*&& !self._competitorLate.length*/ )
    return;
    if( !self._resource.length )
    return;

    let resource = self._resource[ 0 ];
    let competitor;
    let isEarly;
    let isConsequence;

    /* */

    if( self._competitorEarly.length > 0 )
    {
      competitor = self._competitorEarly.shift();
      isConsequence = _.consequenceIs( competitor.handler )
      isEarly = true;
    }
    // else if( self._competitorLate.length > 0 )
    // {
    //   competitor = self._competitorLate.shift();
    //   isConsequence = _.consequenceIs( competitor.handler )
    //   isEarly = false;
    // }

    /* */

    let errThrowen = 0;
    let errorOnly = competitor.kindOfArguments === Self.KindOfArguments.ErrorOnly;
    let argumentOnly = competitor.kindOfArguments === Self.KindOfArguments.ArgumentOnly;

    let executing = true;
    executing = executing && ( !errorOnly || ( errorOnly && !!resource.error ) );
    executing = executing && ( !argumentOnly || ( argumentOnly && !resource.error ) );

    if( !executing )
    debugger;
    if( !executing )
    continue;

    /* resourceReusing */

    let resourceReusing = false;
    resourceReusing = resourceReusing || !executing;
    resourceReusing = resourceReusing || competitor.tapping;
    if( isConsequence )
    resourceReusing = resourceReusing || competitor.keeping;

    if( !resourceReusing )
    self._resource.shift();

    /* debug */

    if( Config.debug )
    if( self.diagnostics )
    {
      if( isConsequence )
      _.arrayRemoveElementOnceStrictly( competitor.handler.dependsOf, self );
    }

    if( isConsequence )
    {

      competitor.handler.__take( resource.error, resource.argument ); /* should be async, maybe */

      if( competitor.handler.asyncCompetitorHanding || competitor.handler.asyncResourceAdding )
      competitor.handler.__handleResource( true );
      else
      competitor.handler.__handleResourceAct();

    }
    else
    {

      /* call routine */

      let result;

      try
      {
        if( errorOnly )
        result = competitor.handler.call( self, resource.error );
        else if( argumentOnly )
        result = competitor.handler.call( self, resource.argument );
        else
        result = competitor.handler.call( self, resource.error, resource.argument );
      }
      catch( err )
      {
        errThrowen = 1;
        result = self.__handleError( err, competitor );
      }

      /* keeping */

      if( competitor.keeping || errThrowen )
      {

        if( result === undefined )
        {
          debugger;
          result = self.__handleError( _.err( 'Thenning competitor of consequence should return something, not undefined' ), competitor.handler )
        }

        if( _.consequenceIs( result ) )
        {
          result.finally( self );
        }
        else
        {
          self.__take( undefined, result );
        }

      }

    }

    if( self.asyncCompetitorHanding || self.asyncResourceAdding )
    return self.__handleResource( true );

  }

}

//

/**
 * Method created and appends competitor object, based on passed options into wConsequence competitors queue.
 *
 * @param {Object} o options object
 * @param {wConsequence~Competitor|wConsequence} o.handler competitor callback
 * @param {Object} [o.context] if defined, it uses as 'this' context in competitor function.
 * @param {Array<*>|ArrayLike} [o.argument] values, that will be used as binding arguments in competitor.
 * @param {boolean} [o.keeping=false] If sets to true, finally result of current competitor will be passed to the next competitor
    in competitors queue.
 * @param {boolean} [o.persistent=false] If sets to true, finally competitor will be work as queue listener ( it will be
 * processed every value resolved by wConsequence).
 * @param {boolean} [o.tapping=false] enabled some breakpoints in debug mode;
 * @returns {wConsequence}
 * @private
 * @method __competitorAppend
 * @memberof wConsequence#
 */

function __competitorAppend( o )
{
  let self = this;
  let competitor = o.competitor;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.consequenceIs( self ) );
  _.assert( _.routineIs( competitor ) || _.consequenceIs( competitor ) );
  _.assert( o.kindOfArguments >= 1 );
  _.assert( competitor !== self, 'consquence cant depend of itself' );
  _.assert( o.early !== undefined, 'Expects { o.early }' );
  _.routineOptions( __competitorAppend, o );

  /* */

  if( o.times !== 1 )
  {
    let optionsForAppend = _.mapExtend( null, o );
    optionsForAppend.times = 1;
    for( let t = 0 ; t < o.times ; t++ )
    self.__competitorAppend( optionsForAppend );
    return self;
  }

  /* */

  if( Config.debug )
  if( !_.consequenceIs( competitor ) )
  {

    // if( o.kindOfArguments === Self.KindOfArguments.ErrorOnly || o.kindOfArguments === Self.KindOfArguments.ArgumentOnly )

    if( o.kindOfArguments === Self.KindOfArguments.ErrorOnly )
    _.assert( competitor.length <= 1, 'ErrorOnly competitor should expect single argument' );
    else if( o.kindOfArguments === Self.KindOfArguments.ArgumentOnly )
    _.assert( competitor.length <= 1, 'ArgumentOnly competitor should expect single argument' );
    else if( o.kindOfArguments === Self.KindOfArguments.Both )
    _.assert( competitor.length === 0 || competitor.length === 2, 'Finally competitor should expect two arguments' );

  }

  /* store */

  if( Config.debug )
  if( self.diagnostics )
  if( _.consequenceIs( competitor ) )
  {

    self.assertNoDeadLockWith( competitor );
    competitor.dependsOf.push( self );

  }

  let competitorDescriptor =
  {
    consequence : self,
    handler : competitor,
    keeping : !!o.keeping,
    tapping : !!o.tapping,
    kindOfArguments : o.kindOfArguments,
    early : o.early,
  }

  if( Config.debug )
  if( self.diagnostics && self.stacking )
  competitorDescriptor.stack = _.diagnosticStack( 2 );

  // if( o.early )
  self._competitorEarly.push( competitorDescriptor );
  // else
  // self._competitorLate.unshift( competitorDescriptor );

  /* */

  return self;
}

__competitorAppend.defaults =
{
  competitor : null,
  keeping : null,
  tapping : null,
  kindOfArguments : null,
  times : 1,
  early : 1,
}

// --
// accounting
// --

function competitorHas( competitor )
{
  let self = this;

  _.assert( _.consequenceIs( competitor ) );

  for( let c = 0 ; c < self._competitorEarly.length ; c++ )
  {
    let cor = self._competitorEarly[ c ].handler;
    if( cor === competitor )
    return true;
    if( _.consequenceIs( cor ) )
    if( cor.competitorHas( competitor ) )
    return true;
  }

  // for( let c = 0 ; c < self._competitorLate.length ; c++ )
  // {
  //   let cor = self._competitorLate[ c ].handler;
  //   if( cor === competitor )
  //   return true;
  //   if( _.consequenceIs( cor ) )
  //   if( cor.competitorHas( competitor ) )
  //   return true;
  // }

  return false;
}

//

function doesDependOf( competitor )
{
  let self = this;

  _.assert( _.consequenceIs( competitor ) );

  if( !self.dependsOf )
  return false;

  for( let c = 0 ; c < self.dependsOf.length ; c++ )
  {
    let cor = self.dependsOf[ c ];
    if( cor === competitor )
    return true;
    if( _.consequenceIs( cor ) )
    if( cor.doesDependOf( competitor ) )
    return true;
  }

  return false;
}

//

function assertNoDeadLockWith( competitor )
{
  let self = this;

  _.assert( _.consequenceIs( competitor ) );
  // _.assert( !competitor.competitorHas( self ), 'dead lock!' );

  let result = self.doesDependOf( competitor );
  let msg = '';

  if( result )
  {
    msg += 'Dead lock!\n';
    // msg += 'with consequence :\n' + competitor.stack;
  }

  _.assert( !result, msg );

  return result;
}

// --
// competitors
// --

function competitorsCount()
{
  let self = this;
  _.assert( arguments.length === 0 );
  return self._competitorEarly.length /*+ self._competitorLate.length*/;
}

//

/**
 * The _corespondentMap object
 * @typedef {Object} _corespondentMap
 * @property {Function|wConsequence} handler function or wConsequence instance, that accepts resolved resources from
 * resources queue.
 * @property {boolean} keeping determines if corespondent pass his result back into resources queue.
 * @property {boolean} tapping determines if corespondent return accepted resource back into  resources queue.
 * @property {boolean} errorOnly turn on corespondent only if resource represent error;
 * @property {boolean} argumentOnly turn on corespondent only if resource represent no error;
 * @property {boolean} debug enables debugging.
 * @property {string} id corespondent id.
 */

/**
 * Returns array of corespondents
 * @example
 * function corespondent1(err, val)
   {
     console.log( 'corespondent1 value: ' + val );
   };

   function corespondent2(err, val)
   {
     console.log( 'corespondent2 value: ' + val );
   };

   function corespondent3(err, val)
   {
     console.log( 'corespondent1 value: ' + val );
   };

   let con = _.Consequence();

   con.tap( corespondent1 ).finally( corespondent2 ).got( corespondent3 );

   let corespondents = con.competitorsEarlyGet();

   console.log( corespondents );

   // prints
   // [ {
   //  handler: [Function: corespondent1],
   //  keeping: true,
   //  tapping: true,
   //  errorOnly: false,
   //  argumentOnly: false,
   //  debug: false,
   //  id: 'corespondent1' },
   // { handler: [Function: corespondent2],
   //   keeping: true,
   //   tapping: false,
   //   errorOnly: false,
   //   argumentOnly: false,
   //   debug: false,
   //   id: 'corespondent2' },
   // { handler: [Function: corespondent3],
   //   keeping: false,
   //   tapping: false,
   //   errorOnly: false,
   //   argumentOnly: false,
   //   debug: false,
   //   id: 'corespondent3'
   // } ]
 * @returns {_corespondentMap[]}
 * @method competitorsEarlyGet
 * @memberof wConsequence
 */

function competitorsEarlyGet()
{
  let self = this;
  return self._competitorEarly;
}

// //
//
// function competitorsLateGet()
// {
//   let self = this;
//   return self._competitorLate;
// }

//

/**
 * If called without arguments, method competitorsCancel() removes all corespondents from wConsequence
 * competitors queue.
 * If as argument passed routine, method competitorsCancel() removes it from corespondents queue if exists.
 * @example
 function corespondent1(err, val)
 {
   console.log( 'corespondent1 value: ' + val );
 };

 function corespondent2(err, val)
 {
   console.log( 'corespondent2 value: ' + val );
 };

 function corespondent3(err, val)
 {
   console.log( 'corespondent1 value: ' + val );
 };

 let con = _.Consequence();

 con.got( corespondent1 ).got( corespondent2 );
 con.competitorsCancel();

 con.got( corespondent3 );
 con.take( 'bar' );

 // prints
 // corespondent1 value: bar
 * @param [competitor]
 * @method competitorsCancel
 * @memberof wConsequence
 */

function competitorsCancel( competitor )
{
  let self = this;

  _.assert( arguments.length === 0 || _.routineIs( competitor ) );

  if( arguments.length === 0 )
  {
    self._competitorEarly.splice( 0, self._competitorEarly.length );
    // self._competitorLate.splice( 0, self._competitorLate.length );
  }
  else
  {
    throw _.err( 'not tested' );
    _.arrayRemoveElementOnce( self._competitorEarly, competitor );
    // _.arrayRemoveElementOnce( self._competitorLate, competitor );
  }

}

// //
//
// function _competitorNextGet()
// {
//   let self = this;
//
//   if( !self._competitorEarly[ 0 ] )
//   {
//     if( !self._competitorLate[ 0 ] )
//     return;
//     else
//     return self._competitorLate[ 0 ].handler;
//   }
//   else
//   {
//     return self._competitorEarly[ 0 ].handler;
//   }
//
// }

//

function argumentsCount()
{
  let self = this;
  return self._resource.filter( ( e ) => e.argument !== undefined ).length;
}

//

function errorsCount()
{
  let self = this;
  return self._resource.filter( ( e ) => e.error !== undefined ).length;
}

//

/**
 * Returns number of resources in current resources queue.
 * @example
 * let con = _.Consequence();

   let conLen = con.resourcesCount();
   console.log( conLen );

   con.take( 'foo' );
   con.take( 'bar' );
   con.error( 'baz' );
   conLen = con.resourcesCount();
   console.log( conLen );

   con.resourcesCancel();

   conLen = con.resourcesCount();
   console.log( conLen );
   // prints: 0, 3, 0;

 * @returns {number}
 * @method resourcesCount
 * @memberof wConsequence
 */

function resourcesCount()
{
  let self = this;
  return self._resource.length;
}

//
//

/**
 * The internal wConsequence view of resource.
 * @typedef {Object} _resourceObject
 * @property {*} error error value
 * @property {*} argument resolved value
 */

/**
 * Returns resources queue.
 * @example
 * let con = _.Consequence();

   con.take( 'foo' );
   con.take( 'bar ');
   con.error( 'baz' );


   let resources = con.resourcesGet();

   console.log( resources );

   // prints
   // [ { error: null, argument: 'foo' },
   // { error: null, argument: 'bar ' },
   // { error: 'baz', argument: undefined } ]

 * @returns {_resourceObject[]}
 * @method resourcesGet
 * @memberof wConsequence
 */

function resourcesGet( index )
{
  let self = this;
  _.assert( arguments.length === 0 || arguments.length === 1 )
  _.assert( index === undefined || _.numberIs( index ) );
  if( index !== undefined )
  return self._resource[ index ];
  else
  return self._resource;
}

//

/**
 * If called without arguments, method removes all resources from wConsequence
 * competitors queue.
 * If as argument passed value, method resourcesCancel() removes it from resources queue if resources queue contains it.
 * @example
 * let con = _.Consequence();

   con.take( 'foo' );
   con.take( 'bar ');
   con.error( 'baz' );

   con.resourcesCancel();
   let resources = con.resourcesGet();

   console.log( resources );
   // prints: []
 * @param {_resourceObject} arg resource object for removing.
 * @throws {Error} If passed extra arguments.
 * @method competitorsCancel
 * @memberof wConsequence
 */

function resourcesCancel( arg )
{
  let self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( arguments.length === 0 )
  self._resource.splice( 0, self._resource.length );
  else
  {
    throw _.err( 'not tested' );
    _.arrayRemoveElementOnce( self._resource, arg );
  }

}


function toResourceMaybe()
{
  let self = this;
  _.assert( self._resource.length <= 1, 'Cant convert consequence back to resource if it has several of such!' );

  if( self._resource.length === 1 )
  {
    debugger;
    let resource = self._resource[ 0 ];
    if( resource.error !== undefined )
    {
      debugger;
      _.assert( resource.argument === undefined );
      throw resource.error;
    }
    else
    {
      _.assert( resource.error === undefined );
      return resource.argument;
    }
  }

  return self;
}

//

function isEmpty()
{
  let self = this;
  if( self.resourcesGet().length )
  return false;
  if( self.competitorsEarlyGet().length )
  return false;
  // if( self.competitorsLateGet().length )
  // return false;
  return true;
}

//

/**
 * Clears all resources and corespondents of wConsequence.
 * @method clear
 * @memberof wConsequence
 */

function clear( arg )
{
  let self = this;
  _.assert( arguments.length === 0 );

  self.competitorsCancel();
  self.resourcesCancel();

}

//

function cancel()
{
  let self = this;
  _.assert( arguments.length === 0 );

  self.clear();

  return self;
}

// --
// etc
// --

//

function _infoExport( o )
{
  let self = this;
  let result = '';

  _.assertRoutineOptions( _infoExport, arguments );

  if( o.detailing >= 2 )
  {
    result += self.nickName;

    let names = _.select( self.competitorsEarlyGet(), '*/tag' );

    if( self.tag )
    result += '\n  tag : ' + self.tag;
    result += '\n  argument resources : ' + self.argumentsCount();
    result += '\n  error resources : ' + self.errorsCount();
    result += '\n  early competitors : ' + self.competitorsEarlyGet().length;
    // result += '\n  late competitors : ' + self.competitorsLateGet().length;
    result += '\n  asyncCompetitorHanding : ' + self.asyncCompetitorHanding;
    result += '\n  asyncResourceAdding : ' + self.asyncResourceAdding;
    // result += '\n  competitor names : ' + names.join( ' ' );

  }
  else
  {
    if( o.detailing >= 1 )
    result += self.nickName + ' ';

    result += self.resourcesGet().length + ' / ' + ( self.competitorsEarlyGet().length /*+ self.competitorsLateGet().length*/ );
  }

  return result;
}

_infoExport.defaults =
{
  detailing : 2,
}

//

function infoExport( o )
{
  let self = this;
  o = _.routineOptions( infoExport, arguments );
  return self._infoExport( o );
}

_.routineExtend( infoExport, _infoExport );

//

/**
 * Serializes current wConsequence instance.
 * @example
 * function corespondent1(err, val)
   {
     console.log( 'corespondent1 value: ' + val );
   };

   let con = _.Consequence();
   con.got( corespondent1 );

   let conStr = con.toStr();

   console.log( conStr );

   con.take( 'foo' );
   con.take( 'bar' );
   con.error( 'baz' );

   conStr = con.toStr();

   console.log( conStr );
   // prints:

   // wConsequence( 0 )
   // resource : 0
   // competitors : 1
   // competitor names : corespondent1

   // corespondent1 value: foo

   // wConsequence( 0 )
   // resource : 2
   // competitors : 0
   // competitor names :

 * @returns {string}
 * @method toStr
 * @memberof wConsequence
 */

function toStr()
{
  let self = this;
  return self.infoExport({ detailing : 9 });
}

//

function toString()
{
  let self = this;
  return self.toStr();
}

//

// /**
//  * Can use as competitor. If `err` is not null, throws exception based on `err`. Returns `arg`.
//  * @callback wConsequence._onDebug
//  * @param {*} err Error object, or any other type, that represent or describe an error reason. If during resolving
//  value no exception occurred, it will be set to null;
//  * @param {*} arg resolved by wConsequence value;
//  * @returns {*}
//  * @memberof wConsequence
//  */
//
// function _onDebug( err, arg )
// {
//   debugger;
//   if( err )
//   throw _.err( err );
//   return arg;
// }

//

function __call__()
{
  let self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 || arguments.length === 2 );
  if( arguments.length === 2 )
  self.take( arguments[ 0 ], arguments[ 1 ] );
  else
  self.take( arguments[ 0 ] );

}

//

function asyncModeSet( mode )
{
  let constr = this.Self;
  _.assert( constr.asyncCompetitorHanding !== undefined );
  _.assert( mode.length === 2 );
  _.assert( arguments.length === 1, 'Expects single argument' );
  constr.asyncCompetitorHanding = !!mode[ 0 ];
  constr.asyncResourceAdding = !!mode[ 1 ];
  return [ constr.asyncCompetitorHanding, constr.asyncResourceAdding ];
}

//

function asyncModeGet( mode )
{
  let constr = this.Self;
  _.assert( constr.asyncCompetitorHanding !== undefined );
  return [ constr.asyncCompetitorHanding, constr.asyncResourceAdding ];
}

//

function nickNameGet()
{
  let result = this.shortName;
  if( this.tag )
  result = result + '::' + this.tag;
  else
  result = result + '::';
  // if( this.tag )
  // result = result + ' ' + this.tag;
  // return '{- ' + result + ' -}';
  return result;
}

// --
// static
// --

function From( src, timeOut )
{
  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assert( timeOut === undefined || _.numberIs( timeOut ) );

  let con = src;

  if( _.promiseLike( src ) )
  {
    con = new Self();
    let onFulfilled = ( got ) => { con.take( got ); }
    let onRejected = ( err ) => { con.error( err ); }
    src.then( onFulfilled, onRejected );
  }

  if( _.consequenceIs( con ) )
  {
    if( timeOut !== undefined )
    return con.eitherKeepSplit( _.timeOutError( timeOut ) );
    return con;
  }

  if( _.errIs( src ) )
  return new Self().error( src );

  return new Self().take( src );
}

//

/**
 * If `consequence` if instance of wConsequence, method pass arg and error if defined to it's resource sequence.
 * If `consequence` is routine, method pass arg as arguments to it and return result.
 * @example
 * function showResult(err, val)
   {
     if( err )
     {
       console.log( 'handleGot1 error: ' + err );
     }
     else
     {
       console.log( 'handleGot1 value: ' + val );
     }
   };

   let con = new  _.Consequence();

   con.got( showResult );

   _.Consequence.take( con, 'hello world' );
   // prints: handleGot1 value: hello world
 * @param {Function|wConsequence} consequence
 * @param {*} arg argument value
 * @param {*} [error] error value
 * @returns {*}
 * @static
 * @method take
 * @memberof wConsequence
 */

function Take( consequence )
{

  _.assert( arguments.length === 2 || arguments.length === 3, 'Expects two or three arguments' );

  let err, got;
  if( arguments.length === 2 )
  {
    got = arguments[ 1 ];
  }
  else if( arguments.length === 3 )
  {
    err = arguments[ 1 ];
    got = arguments[ 2 ];
  }

  let args = [ got ];

  return _Take
  ({
    consequence : consequence,
    context : null,
    error : err,
    args : args,
  });

}

//

  /**
   * If `o.consequence` is instance of wConsequence, method pass o.args and o.error if defined, to it's resource sequence.
   * If `o.consequence` is routine, method pass o.args as arguments to it and return result.
   * @param {Object} o parameters object.
   * @param {Function|wConsequence} o.consequence wConsequence or routine.
   * @param {Array} o.args values for wConsequence resources queue or arguments for routine.
   * @param {*|Error} o.error error value.
   * @returns {*}
   * @private
   * @throws {Error} if missed arguments.
   * @throws {Error} if passed argument is not object.
   * @throws {Error} if o.consequence has unexpected type.
   * @method _Take
   * @memberof wConsequence
   */

function _Take( o )
{
  let context;

  if( !( _.arrayIs( o.args ) && o.args.length <= 1 ) )
  debugger;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.objectIs( o ) );
  _.assert( _.arrayIs( o.args ) && o.args.length <= 1, 'not tested' );
  // _.assertRoutineOptions( _Take, arguments );
  _.assertMapHasAll( o, _Take.defaults );

  /* */

  if( _.arrayIs( o.consequence ) )
  {

    for( let i = 0 ; i < o.consequence.length ; i++ )
    {
      let optionsGive = _.mapExtend( null, o );
      optionsGive.consequence = o.consequence[ i ];
      _Take( optionsGive );
    }

  }
  else if( _.consequenceIs( o.consequence ) )
  {

    _.assert( _.arrayIs( o.args ) && o.args.length <= 1 );

    context = o.consequence;

    o.consequence.take( o.error, o.args[ 0 ] );

  }
  else if( _.routineIs( o.consequence ) )
  {

    _.assert( _.arrayIs( o.args ) && o.args.length <= 1 );

    return o.consequence.call( context, o.error, o.args[ 0 ] );

  }
  else throw _.err( 'Unknown type of consequence : ' + _.strType( o.consequence ) );

}

_Take.defaults =
{
  consequence : null,
  context : null,
  error : null,
  args : null,

}

//

  /**
   * If `consequence` if instance of wConsequence, method error to it's resource sequence.
   * If `consequence` is routine, method pass error as arguments to it and return result.
   * @example
   * function showResult(err, val)
     {
       if( err )
       {
         console.log( 'handleGot1 error: ' + err );
       }
       else
       {
         console.log( 'handleGot1 value: ' + val );
       }
     };

     let con = new  _.Consequence();

     con.got( showResult );

     wConsequence.error( con, 'something wrong' );
   // prints: handleGot1 error: something wrong
   * @param {Function|wConsequence} consequence
   * @param {*} error error value
   * @returns {*}
   * @static
   * @method error
   * @memberof wConsequence
   */

function Error( consequence, error )
{

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );

  return _Take
  ({
    consequence : consequence,
    context : null,
    error : error,
    args : [],
  });

}

// //
//
// /**
//  * Works like [take]{@link _.Consequence.take} but accepts also context, that will be sealed to competitor.
//  * @see _.Consequence.take
//  * @param {Function|wConsequence} consequence wConsequence or routine.
//  * @param {Object} context sealed context
//  * @param {*} err error reason
//  * @param {*} got arguments
//  * @returns {*}
//  * @method GiveWithContextAndError
//  * @memberof wConsequence
//  */
//
// function GiveWithContextAndError( consequence, context, err, got )
// {
//
//   if( err === undefined )
//   err = null;
//
//   console.warn( 'deprecated' );
//   //debugger;
//
//   let args = [ got ];
//   if( arguments.length > 4 )
//   args = _.longSlice( arguments, 3 );
//
//   return _Take
//   ({
//     consequence : consequence,
//     context : context,
//     error : err,
//     args : args,
//   });
//
// }

//

/**
 * Method accepts competitor callback. Returns special competitor that wrap passed one. Passed corespondent will
 * be invoked only if handling resource contains error value. Else given resource will be delegate to the next handler
 * in wConsequence, to the which result competitor was added.
 * @param {competitor} errHandler handler for error
 * @returns {competitor}
 * @static
 * @thorws If missed arguments or passed extra ones.
 * @method exceptKeep
 * @memberof wConsequence
 * @see {@link wConsequence#exceptKeep}
 */

function IfErrorThen()
{

  let onEnd = arguments[ 0 ];

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( this === Self );
  _.assert( _.routineIs( onEnd ) );

  return function exceptKeep( err, arg )
  {

    _.assert( arguments.length === 2, 'Expects exactly two arguments' );

    if( err )
    {
      return onEnd( err, arg );
    }
    else
    {
      return new Self().take( arg );
    }

  }

}

//

/**
 * Method accepts competitor callback. Returns special competitor that wrap passed one. Passed corespondent will
 * be invoked only if handling resource does not contain error value. Else given resource with error will be delegate to
 * the next handler in wConsequence, to the which result competitor was added.
 * @param {competitor} vallueHandler resolved resource handler
 * @returns {corespondent}
 * @static
 * @throws {Error} If missed arguments or passed extra one;
 * @method thenKeep
 * @memberof wConsequence
 */

function IfNoErrorThen()
{

  let onEnd = arguments[ 0 ];

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( this === Self );
  _.assert( _.routineIs( onEnd ) );

  return function thenKeep( err, arg )
  {

    _.assert( arguments.length === 2, 'Expects exactly two arguments' );

    if( !err )
    {
      return onEnd( err, arg );
    }
    else
    {
      return new Self().error( err );
    }

  }

}

//

/**
 * Can use as competitor. If `err` is not null, throws exception based on `err`. Returns `arg`.
 * @callback wConsequence.PassThru
 * @param {*} err Error object, or any other type, that represent or describe an error reason. If during resolving
 value no exception occurred, it will be set to null;
 * @param {*} arg resolved by wConsequence value;
 * @returns {*}
 * @memberof wConsequence
 */

function PassThruBoth( err, arg )
{
  _.assert( err !== undefined || arg !== undefined, 'Argument of take should be something, not undefined' );
  _.assert( err === undefined || arg === undefined, 'Cant take both error and argument, one should be undefined' );
  if( err )
  throw _.err( err );
  return arg;
}

//

function PassThruError( err, arg )
{
  _.assert( err !== undefined, 'Expects non-undefined error' );
  throw _.err( err );
}

//

function PassThruArgument( err, arg )
{
  _.assert( arg !== undefined, 'Expects non-undefined argument' );
  return arg;
}

// --
// experimental
// --

function FunctionWithin( consequence )
{
  let routine = this;
  let args;
  let context;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.consequenceIs( consequence ) );

  consequence.finally( function( err, arg )
  {

    return routine.apply( context, args );

  });

  return function()
  {
    context = this;
    args = arguments;
    return consequence;
  }

}

//

function FunctionThereafter()
{
  let con = new Self();
  let routine = this;
  let args = arguments

  con.finally( function( err, arg )
  {

    return routine.apply( null, args );

  });

  return con;
}

//

if( 0 )
{
  Function.prototype.within = FunctionWithin;
  Function.prototype.thereafter = FunctionThereafter;
}

//

function experimentThereafter()
{
  debugger;

  function f()
  {
    debugger;
    console.log( 'done2' );
  }

  _.timeOut( 5000, console.log.thereafter( 'done' ) );
  _.timeOut( 5000, f.thereafter() );

  debugger;

}

//

function experimentWithin()
{

  debugger;
  let con = _.timeOut( 30000 );
  console.log.within( con ).call( console, 'done' );
  con.finally( function()
  {

    debugger;
    console.log( 'done2' );

  });

}

//

function experimentCall()
{

  let con = new Self();
  con( 123 );
  con.finally( function( err, arg )
  {

    console.log( 'got :', arg );

  });

  debugger;

}

//

function after( resource )
{
  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( arguments.length === 0 || resource !== undefined );

  if( resource !== undefined )
  return _.Consequence.From( resource );
  else
  return new _.Consequence().take( null );

}

// //
//
// function before( competitor )
// {
//   _.assert( arguments.length === 1 );
//   _.assert( arguments.length === 0 || competitor !== undefined );
//   _.assert( 0, 'not tested' );
//
//   let result;
//   if( _.consequenceLike( competitor ) )
//   {
//     competitor = _.Consequence.From( competitor );
//   }
//
//   let result = _.Consequence();
//   result.lateFinally( competitor );
//
//   return result;
// }

// --
// type
// --

let KindOfArguments =
{
  ErrorOnly : 1,
  ArgumentOnly : 2,
  Both : 3,
  BothWithCompetitor : 4,
}

// --
// relations
// --

let Composes =
{
  _competitorEarly : [],
  // _competitorLate : [],
  _resource : [],
}

let ComposesDebug =
{
  tag : '',
  dependsOf : [],
  // debug : 0,
  resourceLimit : 0,
}

if( Config.debug )
_.mapExtend( Composes, ComposesDebug );

let Restricts =
{
}

let Medials =
{
  tag : '',
  dependsOf : [],
  // debug : 0,
  resourceLimit : 0,
}

let Statics =
{

  After : after,
  From,
  Take,
  Error,

  IfErrorThen,
  IfNoErrorThen,

  PassThruBoth,
  PassThruError,
  PassThruArgument,

  asyncModeSet : asyncModeSet,
  asyncModeGet : asyncModeGet,

  KindOfArguments : KindOfArguments,
  diagnostics : 1,
  stacking : 0,
  asyncCompetitorHanding : 0,
  asyncResourceAdding : 0,

  shortName : 'Consequence',

}

let Forbids =
{
  give : 'give',
  every : 'every',
  mutex : 'mutex',
  mode : 'mode',
  resourcesCounter : 'resourcesCounter',
  _competitor : '_competitor',
  _competitorPersistent : '_competitorPersistent',
}

let Accessors =
{
  competitorNext : 'competitorNext',
  // nickName : { readOnly : 1, combining : 'rewrite' },
}

// --
// declare
// --

let Extend =
{

  init,
  is,
  isJoinedWithConsequence,

  // chainer

  got,
  done : got,
  // lateGot,
  promiseGot,

  finally : _finally,

  _competitorFinally,
  // lateFinally,
  promiseFinally,

  first,
  _first,

  _put,
  put : thenPutGive,
  putGive,
  putKeep,
  thenPutGive,
  thenPutKeep,

  // choke,
  // chokeThen,

  // _onceGot, /* experimental */
  // _onceThen, /* experimental */

  split,
  tap,

  thenGive, // ifNoErrorGot
  thenGot : thenGive,
  ifNoErrorGot : thenGive,

  thenKeep, // ifNoErrorThen
  keep : thenKeep,
  ifNoErrorThen : thenKeep,

  exceptGive, // ifErrorGot
  exceptGot : exceptGive,
  ifErrorGot : exceptGive,

  exceptKeep, // ifErrorThen
  except : exceptKeep,
  ifErrorThen : exceptGive,

  exceptLog,
  _timeOut,
  timeOut,
  thenTimeOut,

  // advanced

  wait,
  participate,
  participateThen,

  andTake, // andGot
  andKeep, // andThen
  _and,

  eitherKeepSplit,
  eitherTake,
  eitherKeep,
  _either,

  _join,
  join,
  seal,
  tolerantCallback,

  // resource

  take,
  error,
  __take,

  // handling mechanism

  __handleError,
  __handleResource,
  __handleResourceAct,
  __competitorAppend,

  // accounting

  competitorHas,
  doesDependOf,
  assertNoDeadLockWith,

  // competitor

  competitorsCount,
  competitorsEarlyGet,
  // competitorsLateGet,
  competitorsCancel,
  // _competitorNextGet,

  // resource

  argumentsCount,
  errorsCount,
  resourcesCount,
  resourcesGet,
  resourcesCancel,
  toResourceMaybe,

  isEmpty,
  clear, /* experimental */
  cancel, /* experimental */

  // etc

  _infoExport,
  infoExport,
  toStr,
  toString,
  __call__ : __call__,

  asyncModeSet,
  asyncModeGet,
  nickNameGet,

  // relations

  Composes,
  Restricts,
  Medials,
  Forbids,
  Accessors,

}

//

/* statics should be supplemental not extending */

let Supplement =
{
  Statics : Statics,
}

let Tools =
{
  after,
  // before,
}

//

_.classDeclare
({
  cls : wConsequence,
  parent : null,
  extend : Extend,
  supplement : Supplement,
  usingOriginalPrototype : 1,
});

_.Copyable.mixin( wConsequence );

_.mapExtend( _, Tools );
_.mapExtend( _realGlobal_.wTools, Tools );

//

_.assert( _.routineIs( wConsequence.prototype.PassThruBoth ) );
_.assert( _.routineIs( wConsequence.PassThruBoth ) );
_.assert( _.objectIs( wConsequence.prototype.KindOfArguments ) );
_.assert( _.objectIs( wConsequence.KindOfArguments ) );
_.assert( _.strDefined( wConsequence.name ) );
_.assert( _.strDefined( wConsequence.shortName ) );
_.assert( _.routineIs( wConsequence.prototype.take ) );

_.assert( _.routineIs( wConsequenceProxy.prototype.PassThruBoth ) );
_.assert( _.routineIs( wConsequenceProxy.PassThruBoth ) );
_.assert( _.objectIs( wConsequenceProxy.prototype.KindOfArguments ) );
_.assert( _.objectIs( wConsequenceProxy.KindOfArguments ) );
_.assert( _.strDefined( wConsequenceProxy.name ) );
_.assert( _.strDefined( wConsequenceProxy.shortName ) );
_.assert( _.routineIs( wConsequenceProxy.prototype.take ) );

_.assert( wConsequenceProxy.shortName === 'Consequence' );

//

// _.accessor.declare
// ({
//   object : Self.prototype,
//   names : Accessors,
// });

// _.accessor.forbid( Self.prototype, Forbids );

_prepareJoinedWithConsequence();

_.assert( !!Self._fieldsOfRelationsGroupsGet );
_.assert( !!Self.prototype._fieldsOfRelationsGroupsGet );
_.assert( !!Self.fieldsOfRelationsGroups );
_.assert( !!Self.prototype.fieldsOfRelationsGroups );
_.assert( _.mapKeys( Self.fieldsOfRelationsGroups ).length );

_global_[ Self.name ] = _[ Self.shortName ] = Self;
if( !_global_.WTOOLS_PRIVATE_CONSEQUENCE )
_realGlobal_[ Self.name ] = Self;

// --
// export
// --

// if( typeof module !== 'undefined' )
// if( _global_.WTOOLS_PRIVATE )
// { /* delete require.cache[ module.id ]; */ }

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
