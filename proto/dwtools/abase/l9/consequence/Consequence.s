( function _Consequence_s_() {

'use strict';

/**
 * Advanced synchronization mechanism. Asynchronous routines may use Consequence to wrap postponed result, what allows classify callback for such routines as output, not input, what improves analyzability of a program. Consequence may be used to make a queue for mutually exclusive access to a resource. Algorithmically speaking Consequence is 2 queues ( FIFO ) and a customizable arbitrating algorithm. The first queue contains available resources, the second queue includes competitors for this resources. At any specific moment, one or another queue may be empty or full. Arbitrating algorithm makes resource available for a competitor as soon as possible. There are 2 kinds of resource: regular and erroneous. Unlike Promise, Consequence is much more customizable and can solve engineering problem which Promise cant. But have in mind with great power great responsibility comes. Consequence can coexist and interact with a Promise, getting fulfillment/rejection of a Promise or fulfilling it. Use Consequence to get more flexibility and improve readability of asynchronous aspect of your application.
  @module Tools/base/Consequence
*/

/**
 * @file Consequence.s.
 */

/*

= Concepts

Consequence ::
Resource ::
Error of resource ::
Argument of resource ::
Competitor ::
Procedure ::

*/

/*

= Principles

1. Methods of Consequence should call callback instantly and synchronously if all necessary data provided, otherwise, Consequence should call callback asynchronously.
2. Handlers of keeping methods cannot return undefined. It is often a sign of a bug.
3. A resource of Consequence cannot have both an error and an argument but must have either one.

*/

/*

= Groups

1. then / except / finally
2. give / keep

*/

if( typeof module !== 'undefined' )
{
  let _ = require( '../../../../dwtools/Tools.s' );
  _.include( 'wProto' );
  _.include( 'wCopyable' );
  _.include( 'wProcedure' );
}

let _global = _global_;
let _ = _global_.wTools;
let Deasync = null;

_.assert( !_.Consequence, 'Consequence included several times' );

// relations

let KindOfResource =
{
  ErrorOnly : 1,
  ArgumentOnly : 2,
  Both : 3,
  BothWithCompetitor : 4,
}

//

/**

 */

/**
 * Function that accepts result of wConsequence value computation. Used as parameter in methods such as finallyGive(), finally(), etc.
 * @param {*} err Error object, or any other type, that represent or describe an error reason. If during resolving
    value no exception occurred, it will be set to null;
   @param {*} value resolved by wConsequence value;
 * @callback Competitor
 * @class wConsequence
 * @namespace Tools
 * @module Tools/base/Consequence
 */

 /**
 * @classdesc Class wConsequence creates objects that used for asynchronous computations. It represent the queue of results that
 * can computation asynchronously, and has a wide range of tools to implement this process.
 * @class wConsequence
 * @module Tools/base/Consequence
 */

/**
 * Creates instance of wConsequence
 * @param {Object|Function|wConsequence} [o] initialization options
 * @example
   let con = new _.Consequence();
   con.take( 'hello' ).finallyGive( function( err, value) { console.log( value ); } ); // hello

   let con = _.Consequence();
   con.finallyGive( function( err, value) { console.log( value ); } ).take('world'); // world
 * @constructor wConsequence
 * @class wConsequence
 * @module Tools/base/Consequence
 * @returns {wConsequence}
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
  apply : function apply( original, context, args )
  {
    let o = args[ 0 ];

    if( o )
    if( o instanceof Self )
    {
      o = _.mapOnly( o, Self.Composes );
    }

    if( Config.debug )
    {
      if( o === undefined )
      {
        o = Object.create( null );
        args[ 0 ] = o;
      }
    }

    return new original( ...args );
  },

  set : function set( original, name, value )
  {
    return Reflect.set( ... arguments );
  },

});

let Parent = null;
let Self = wConsequenceProxy;

wConsequence.shortName = 'Consequence';

// --
// inter
// --

/**
 * Initialises instance of wConsequence
 * @param {Object|wConsequence} [o] initialization options
 * @private
 * @method init
 * @module Tools/base/Consequence
 * @namespace Tools
 * @class wConsequence
 */

function init( o )
{
  let self = this;

  if( o )
  {
    if( !Config.debug )
    {
      delete o.tag;
      delete o.capacity;
    }
    if( o instanceof Self )
    {
      o = _.mapOnly( o, self.Composes );
    }
    else
    {
      _.assertMapHasOnly( o, self.Composes );
    }
    if( o._resources )
    o._resources = o._resources.slice();
    _.mapExtend( self, o );
  }

  _.assert( arguments.length === 0 || arguments.length === 1 );
}

//

function is( src )
{
  _.assert( arguments.length === 1 );
  return _.consequenceIs( src );
}

// --
// basic
// --

/**
 * Method appends resolved value and error competitor to wConsequence competitors sequence. That competitor accept only one
    value or error reason only once, and don't pass result of it computation to next competitor (unlike Promise 'finally').
    if finallyGive() called without argument, an empty competitor will be appended.
    After invocation, competitor will be removed from competitors queue.
    Returns current wConsequence instance.
 * @example
     function gotHandler1( error, value )
     {
       console.log( 'competitor 1: ' + value );
     };

     function gotHandler2( error, value )
     {
       console.log( 'competitor 2: ' + value );
     };

     let con1 = new _.Consequence();

     con1.finallyGive( gotHandler1 );
     con1.take( 'hello' ).take( 'world' );

     // prints only " competitor 1: hello ",

     let con2 = new _.Consequence();

     con2.finallyGive( gotHandler1 ).finallyGive( gotHandler2 );
     con2.take( 'foo' );

     // prints only " competitor 1: foo "

     let con3 = new _.Consequence();

     con3.finallyGive( gotHandler1 ).finallyGive( gotHandler2 );
     con3.take( 'bar' ).take( 'baz' );

     // prints
     // competitor 1: bar
     // competitor 2: baz
     //
 * @param {Competitor|wConsequence} [competitor] callback, that accepts resolved value or exception reason.
 * @returns {wConsequence}
 * @see {@link Competitor} competitor callback
 * @throws {Error} if passed more than one argument.
 * @method finallyGive
 * @module Tools/base/Consequence
 * @namespace Tools
 * @class wConsequence
 */

function finallyGive( competitorRoutine )
{
  let self = this;
  let times = 1;

  _.assert( arguments.length === 1, 'Expects none or single argument, but got', arguments.length, 'arguments' );

  if( _.numberIs( competitorRoutine ) )
  {
    times = competitorRoutine;
    competitorRoutine = function(){};
  }

  self._competitorAppend
  ({
    competitorRoutine,
    keeping : false,
    kindOfResource : Self.KindOfResource.Both,
    times,
    stack : 2,
  });

  self.__handleResourceSoon( false );

  return self;
}

finallyGive.having =
{
  consequizing : 1,
}

//

function finallyKeep( competitorRoutine )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  self._competitorAppend
  ({
    competitorRoutine,
    keeping : true,
    kindOfResource : Self.KindOfResource.Both,
    stack : 2,
    times : 1,
  });

  self.__handleResourceSoon( false );

  return self;
}

finallyKeep.having =
{
  consequizing : 1,
}

//

function thenGive( competitorRoutine )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  self._competitorAppend
  ({
    competitorRoutine,
    keeping : false,
    kindOfResource : Self.KindOfResource.ArgumentOnly,
    stack : 2,
  });

  self.__handleResourceSoon( false );

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
   competitor in queue. After handling accepted value, competitor pass result to the next competitor, like finally
   method.
 * @returns {wConsequence}
 * @throws {Error} if passed more than one arguments
 * @see {@link module:Tools/base/Consequence.wConsequence#finallyGive} finally method
 * @method thenKeep
 * @module Tools/base/Consequence
 * @namespace Tools
 * @class wConsequence
 */

function thenKeep( competitorRoutine )
{
  let self = this;

  _.assert( arguments.length === 1 || arguments.length === 2, 'Expects single argument' );

  if( arguments.length === 2 )
  return self._promiseThen( arguments[ 0 ], arguments[ 1 ] );

  self._competitorAppend
  ({
    competitorRoutine,
    keeping : true,
    kindOfResource : Self.KindOfResource.ArgumentOnly,
    stack : 2,
  });

  self.__handleResourceSoon( false );
  return self;
}

thenKeep.having =
{
  consequizing : 1,
}

//

function catchGive( competitorRoutine )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  self._competitorAppend
  ({
    competitorRoutine,
    keeping : false,
    kindOfResource : Self.KindOfResource.ErrorOnly,
    stack : 2,
  });

  self.__handleResourceSoon( false );
  return self;
}

catchGive.having =
{
  consequizing : 1,
}

//

/**
 * catchKeep method pushed `competitor` callback into wConsequence competitors queue. That callback will
   trigger only in that case if accepted error parameter will be defined and not null. Else accepted parameters will
   be passed to the next competitor in queue.

 * @param {Competitor|wConsequence} competitor callback, that accepts exception  reason and value .
 * @returns {wConsequence}
 * @throws {Error} if passed more than one arguments
 * @see {@link module:Tools/base/Consequence.wConsequence#finallyGive} finally method
 * @method catchKeep
 * @module Tools/base/Consequence
 * @namespace Tools
 * @class wConsequence
 */

function catchKeep( competitorRoutine )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  self._competitorAppend
  ({
    competitorRoutine,
    keeping : true,
    kindOfResource : Self.KindOfResource.ErrorOnly,
    stack : 2,
    // early : true,
  });

  self.__handleResourceSoon( false );

  return self;
}

catchKeep.having =
{
  consequizing : 1,
}

// --
// promise
// --

function _promiseThen( resolve, reject )
{
  let self = this;

  _.assert( arguments.length === 2 );
  _.assert( _.routineIs( resolve ) && _.routineIs( reject ) );
  _.assert( resolve.length === 1 && reject.length === 1 );

  return self.finallyGive( ( err, got ) =>
  {
    if( err )
    reject( err );
    else
    resolve( got );
  })

}

//

function _promise( o )
{
  let self = this;
  let keeping = o.keeping;
  let kindOfResource =  o.kindOfResource;
  // let procedure = self.procedure( 'promise' ).stackElse( 3 );
  let procedure = self.procedure( 3 ).nameElse( 'promise' );
  self.procedureDetach();

  _.assertRoutineOptions( _promise, arguments );

  let result = new Promise( function( resolve, reject )
  {
    self.procedure( procedure );

    self._competitorAppend
    ({
      keeping : 0,
      competitorRoutine,
      // kindOfResource : o.kindOfResource,
      kindOfResource : self.KindOfResource.Both,
      stack : 3,
    });

    self.__handleResourceSoon( false );

    function competitorRoutine( err, arg )
    {
      if( err )
      {
        if( kindOfResource === self.KindOfResource.Both || kindOfResource === self.KindOfResource.ErrorOnly )
        reject( err );
      }
      else
      {
        if( kindOfResource === self.KindOfResource.Both || kindOfResource === self.KindOfResource.ErrorOnly )
        resolve( arg );
      }
      if( keeping )
      self.take( err, arg );
    };

  });

  return result;
}

_promise.defaults =
{
  keeping : null,
  kindOfResource : null,
}

_promise.having =
{
  consequizing : 1,
}

//

function finallyPromiseGive()
{
  let self = this;
  _.assert( arguments.length === 0, 'Expects no arguments' );
  return self._promise
  ({
    keeping : 0,
    kindOfResource : self.KindOfResource.Both,
  });
}

finallyPromiseGive.having = Object.create( _promise.having );

//

/**
 * Method accepts competitor for resolved value/error. This competitor method finally adds to wConsequence competitors sequence.
    After processing accepted value, competitor return value will be pass to the next competitor in competitors queue.
    Returns current wConsequence instance.

 * @example
   function gotHandler1( error, value )
   {
     console.log( 'competitor 1: ' + value );
     value++;
     return value;
   };

   function gotHandler3( error, value )
   {
     console.log( 'competitor 3: ' + value );
   };

   let con1 = new _.Consequence();

   con1.finally( gotHandler1 ).finally( gotHandler1 ).finallyGive(gotHandler3);
   con1.take( 4 ).take( 10 );

   // prints:
   // competitor 1: 4
   // competitor 1: 5
   // competitor 3: 6

 * @param {Competitor|wConsequence} competitor callback, that accepts resolved value or exception reason.
 * @returns {wConsequence}
 * @throws {Error} if missed competitor.
 * @throws {Error} if passed more than one argument.
 * @see {@link Competitor} competitor callback
 * @see {@link module:Tools/base/Consequence.wConsequence#finallyGive} finallyGive method
 * @method finally
 * @module Tools/base/Consequence
 * @namespace Tools
 * @class wConsequence
 */

function finallyPromiseKeep()
{
  let self = this;
  _.assert( arguments.length === 0, 'Expects no arguments' );
  return self._promise
  ({
    keeping : 1,
    kindOfResource : self.KindOfResource.Both,
  });
}

finallyPromiseKeep.having = Object.create( _promise.having );

//

function thenPromiseGive()
{
  let self = this;
  _.assert( arguments.length === 0, 'Expects no arguments' );
  return self._promise
  ({
    keeping : 0,
    kindOfResource : self.KindOfResource.ArgumentOnly,
  });
}

thenPromiseGive.having = Object.create( _promise.having );

//

function thenPromiseKeep()
{
  let self = this;
  _.assert( arguments.length === 0, 'Expects no arguments' );
  return self._promise
  ({
    keeping : 1,
    kindOfResource : self.KindOfResource.ArgumentOnly,
  });
}

thenPromiseKeep.having = Object.create( _promise.having );

//

function catchPromiseGive()
{
  let self = this;
  _.assert( arguments.length === 0, 'Expects no arguments' );
  return self._promise
  ({
    keeping : 0,
    kindOfResource : self.KindOfResource.ErrorOnly,
  });
}

catchPromiseGive.having = Object.create( _promise.having );

//

function catchPromiseKeep()
{
  let self = this;
  _.assert( arguments.length === 0, 'Expects no arguments' );
  return self._promise
  ({
    keeping : 1,
    kindOfResource : self.KindOfResource.ErrorOnly,
  });
}

catchPromiseKeep.having = Object.create( _promise.having );

// --
// deasync
// --

function _deasync( o )
{
  let self = this;
  let procedure = self.procedure( 3 ).nameElse( 'deasync' );
  let keeping = o.keeping;
  let result = Object.create( null );
  let ready = false;

  _.assertRoutineOptions( _deasync, arguments );
  _.assert
  (
       o.kindOfResource === 0
    || o.kindOfResource === self.KindOfResource.Both
    || o.kindOfResource === self.KindOfResource.ArgumentOnly
    || o.kindOfResource === self.KindOfResource.ErrorOnly
  );

  self._competitorAppend
  ({
    competitorRoutine,
    kindOfResource : self.KindOfResource.Both,
    keeping : 0,
    stack : 3,
  });

  self.__handleResourceSoon( false );

  if( Deasync === null )
  Deasync = require( 'deasync' );
  Deasync.loopWhile( () => !ready )

  if( result.err )
  if( o.kindOfResource === self.KindOfResource.Both || o.kindOfResource === self.KindOfResource.ErrorOnly )
  throw result.err;
  else
  return new _.Consequence().error( result.err );

  if( o.kindOfResource === self.KindOfResource.Both || o.kindOfResource === self.KindOfResource.ArgumentOnly )
  return result.arg;
  else
  return new _.Consequence().take( result.arg );

  return self;

  function competitorRoutine( err, arg )
  {
    result.err = err;
    result.arg = arg;
    ready = true;
    if( keeping )
    self.take( err, arg );
  };

}

_deasync.defaults =
{
  keeping : null,
  kindOfResource : null,
}

_deasync.having =
{
  consequizing : 1,
}

//

function deasync()
{
  let self = this;
  _.assert( arguments.length === 0, 'Expects no arguments' );
  return self._deasync
  ({
    keeping : 1,
    kindOfResource : 0,
  });
}

deasync.having = Object.create( _deasync.having );

// --
// advanced
// --

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
      if( result === undefined )
      throw self.ErrNoReturn( src );
    }
    catch( err )
    {
      result = new _.Consequence().error( self.__handleError( err ) );
    }

    if( _.consequenceIs( result ) )
    {
      result.finally( self );
    }
    else if( _.promiseLike( result ) )
    {
      debugger;
      result.finally( Self.From( result ) );
    }
    else
    {
      self.take( result );
    }

  }
  else _.assert( 0, 'first expects consequence of routine, but got', _.strType( src ) );

  return self;
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
 con.finallyGive( handleGot1 );
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
 con.finallyGive( handleGot1 );
 * @param {wConsequence|Function} src wConsequence or routine.
 * @returns {wConsequence}
 * @throws {Error} if `src` has unexpected type.
 * @method first
 * @module Tools/base/Consequence
 * @namespace Tools
 * @class wConsequence
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

/**
 * Returns new _.Consequence instance. If on cloning moment current wConsequence has uncaught resolved values in queue
   the first of them would be handled by new _.Consequence. Else pass accepted
 * @example
   function gotHandler1( error, value )
   {
     console.log( 'competitor 1: ' + value );
     value++;
     return value;
   };

   function gotHandler2( error, value )
   {
     console.log( 'competitor 2: ' + value );
   };

   let con1 = new _.Consequence();
   con1.take(1).take(2).take(3);
   let con2 = con1.split();
   con2.finallyGive( gotHandler2 );
   con2.finallyGive( gotHandler2 );
   con1.finallyGive( gotHandler1 );
   con1.finallyGive( gotHandler1 );

    // prints:
    // competitor 2: 1 // only first value copied into cloned wConsequence
    // competitor 1: 1
    // competitor 1: 2

 * @returns {wConsequence}
 * @throws {Error} if passed any argument.
 * @method splitKeep
 * @module Tools/base/Consequence
 * @namespace Tools
 * @class wConsequence
 */

function splitKeep( first )
{
  let self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  let result = new Self();

  if( first ) // xxx : remove, maybe argument?
  {
    result.finally( first );
    self.give( function( err, arg )
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

splitKeep.having =
{
  consequizing : 1,
}

//

function splitGive( first )
{
  let self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  let result = new Self();

  if( first ) // xxx : remove, maybe argument?
  {
    result.finally( first );
    self.give( function( err, arg )
    {
      result.take( err, arg );
    });
  }
  else
  {
    self.finallyGive( result );
  }

  return result;
}

splitGive.having =
{
  consequizing : 1,
}

//

/**
 * Works like finallyGive() method, but value that accepts competitor, passes to the next taker in takers queue without
   modification.
 * @example
 *
   function gotHandler1( error, value )
   {
     console.log( 'competitor 1: ' + value );
     value++;
     return value;
   }

   function gotHandler2( error, value )
   {
     console.log( 'competitor 2: ' + value );
   }

   function gotHandler3( error, value )
   {
     console.log( 'competitor 3: ' + value );
   }

   let con1 = new _.Consequence();
   con1.take(1).take(4);

   // prints:
   // competitor 1: 1
   // competitor 2: 1
   // competitor 3: 4

 * @param {Competitor|wConsequence} competitor callback, that accepts resolved value or exception
   reason.
 * @returns {wConsequence}
 * @throws {Error} if passed more than one arguments
 * @see {@link module:Tools/base/Consequence.wConsequence#finallyGive} finallyGive method
 * @method tap
 * @module Tools/base/Consequence
 * @namespace Tools
 * @class wConsequence
 */

function tap( competitorRoutine )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  self._competitorAppend
  ({
    competitorRoutine,
    keeping : false,
    tapping : true,
    kindOfResource : Self.KindOfResource.Both,
    stack : 2,
  });

  self.__handleResourceSoon( false );

  return self;
}

tap.having =
{
  consequizing : 1,
}

//

/**
 * Creates and adds to corespondents sequence error competitor. If handled resource contains error, corespondent logs it.
 * @returns {wConsequence}
 * @throws {Error} If called with any argument.
 * @method catchLog
 * @module Tools/base/Consequence
 * @namespace Tools
 * @class wConsequence
 */

function catchLog()
{
  let self = this;

  _.assert( arguments.length === 0, 'Expects no arguments' );

  self._competitorAppend
  ({
    competitorRoutine : errorLog,
    keeping : true,
    kindOfResource : Self.KindOfResource.ErrorOnly,
    stack : 2,
  });

  self.__handleResourceSoon( false );

  return self;

  /* - */

  function errorLog( err )
  {
    err = _.err( err );
    logger.log( _.errOnce( err ) );
    return null;
  }

}

catchLog.having =
{
  consequizing : 1,
}

//

/**
 * Creates and adds to corespondents sequence error competitor. If handled resource contains error, corespondent logs it.
 * @returns {wConsequence}
 * @throws {Error} If called with any argument.
 * @method catchBrief
 * @module Tools/base/Consequence
 * @namespace Tools
 * @class wConsequence
 */

function catchBrief()
{
  let self = this;

  _.assert( arguments.length === 0, 'Expects no arguments' );

  self._competitorAppend
  ({
    competitorRoutine : errorLog,
    keeping : true,
    kindOfResource : Self.KindOfResource.ErrorOnly,
    stack : 2,
  });

  self.__handleResourceSoon( false );

  return self;

  /* - */

  function errorLog( err )
  {
    err = _.errBrief( err );
    logger.log( _.errOnce( err ) );
    // throw err;
    return null;
  }

}

catchBrief.having =
{
  consequizing : 1,
}

//

function syncMaybe()
{
  let self = this;

  if( self._resources.length === 1 )
  {
    let resource = self._resources[ 0 ];
    if( resource.error !== undefined )
    {
      _.assert( resource.argument === undefined );
      throw _.err( resource.error );
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

function sync()
{
  let self = this;

  _.assert( self._resources.length <= 1, () => 'Cant return resource of consequence because it has ' + self._resources.length + ' of such!' );
  _.assert( self._resources.length >= 1, () => 'Cant return resource of consequence because it has none of such!' );

  return self.syncMaybe();
}

// --
// experimental
// --

function _competitorFinally( competitorRoutine )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  self._competitorAppend
  ({
    competitorRoutine,
    keeping : true,
    kindOfResource : Self.KindOfResource.BothWithCompetitor,
    stack : 2,
  });

  self.__handleResourceSoon( false );

  return self;
}

//

function wait()
{
  let self = this;
  let result = new _.Consequence();

  _.assert( arguments.length === 0, 'Expects no arguments' );

  self.finallyGive( function __wait( err, arg )
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

function participateGive( con )
{
  let self = this;

  _.assert( _.consequenceIs( con ) );
  _.assert( arguments.length === 1 );

  debugger;

  con.finallyGive( 1 );
  self.finallyGive( con );
  // con.take( self );

  return con;
}

//

function participateKeep( con )
{
  let self = this;

  _.assert( _.consequenceIs( con ) );
  _.assert( arguments.length === 1 );

  con.finallyGive( 1 );
  self.finallyKeep( con );

  return con;
}

//

function ErrNoReturn( routine )
{
  let err = _.err( `Callback of then of consequence should return something, but callback::${routine.name} returned undefined` )
  err = _.err( routine.toString(), '\n', err );
  return err;
}

// --
// put
// --

function _put( o )
{
  let self = this;
  let key = o.key;
  let container = o.container;
  let keeping = o.keeping;

  _.assert( !_.primitiveIs( o.container ), 'Expects one or two argument, container for resource or key and container' );
  _.assert( o.key === null || _.numberIs( o.key ) || _.strIs( o.key ), () => 'Key should be number or string, but it is ' + _.strType( o.key ) );

  if( o.key !== null )
  {
    self._competitorAppend
    ({
      keeping,
      kindOfResource : o.kindOfResource,
      competitorRoutine : __onPutWithKey,
      stack : 3,
    });

    self.__handleResourceSoon( false );
    return self;
  }
  else if( _.arrayLike( o.container ) )
  {
    debugger;
    self._competitorAppend
    ({
      keeping,
      kindOfResource : o.kindOfResource,
      competitorRoutine : __onPutToArray,
      stack : 3,
    });
    self.__handleResourceSoon( false );
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
  kindOfResource : null,
  keeping  : null,
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
defaults.kindOfResource = KindOfResource.Both;
defaults.keeping = false;

let putKeep = _.routineFromPreAndBody( put_pre, _put, 'putKeep' );
var defaults = putKeep.defaults;
defaults.kindOfResource = KindOfResource.Both;
defaults.keeping = true;

let thenPutGive = _.routineFromPreAndBody( put_pre, _put, 'thenPutGive' );
var defaults = thenPutGive.defaults;
defaults.kindOfResource = KindOfResource.ArgumentOnly;
defaults.keeping = false;

let thenPutKeep = _.routineFromPreAndBody( put_pre, _put, 'thenPutKeep' );
var defaults = thenPutKeep.defaults;
defaults.kindOfResource = KindOfResource.ArgumentOnly;
defaults.keeping = true;

// --
// time
// --

/**
 * Works like finally, but when competitor accepts resource from resources sequence, execution of competitor will be
    delayed. The result of competitor execution will be passed to the competitor that is first in competitor queue
    on execution end moment.

 * @example
 *
   function gotHandler1( error, value )
   {
     console.log( 'competitor 1: ' + value );
     value++;
     return value;
   }

   function gotHandler2( error, value )
   {
     console.log( 'competitor 2: ' + value );
   }

   let con = new _.Consequence();

   con.timeOut(500, gotHandler1).finallyGive( gotHandler2 );
   con.take(90);
   //  prints:
   // competitor 1: 90
   // competitor 2: 91

 * @param {number} time delay in milliseconds
 * @param {Competitor|wConsequence} competitor callback, that accepts exception reason and value.
 * @returns {wConsequence}
 * @throws {Error} if missed arguments.
 * @throws {Error} if passed extra arguments.
 * @see {@link module:Tools/base/Consequence.wConsequence#finally} finally method
 * @method timeOut
 * @module Tools/base/Consequence
 * @namespace Tools
 * @class wConsequence
 */

//

function timeOut_pre( routine, args )
{
  // let o = { time : args[ 0 ], callback : args[ 1 ] };
  let o = { time : args[ 0 ] };
  _.routineOptions( routine, o );
  _.assert( arguments.length === 2 );
  _.assert( args.length === 1, 'Expects single argument' );
  _.assert( _.numberIs( o.time ) );
  return o;
}

//

function _timeOut( o )
{
  let self = this;
  let time = o.time;

  /* */

  let competitorRoutine;
  if( o.kindOfResource === Self.KindOfResource.Both )
  competitorRoutine = __timeOutFinally;
  else if( o.kindOfResource === Self.KindOfResource.ArgumentOnly )
  competitorRoutine = __timeOutThen;
  else if( o.kindOfResource === Self.KindOfResource.ErrorOnly )
  competitorRoutine = __timeOutCatch;
  else _.assert( 0 );

  /* */

  self._competitorAppend
  ({
    keeping : false,
    competitorRoutine : competitorRoutine,
    kindOfResource : o.kindOfResource,
    stack : 3,
  });

  self.__handleResourceSoon( false );

  return self;

  /**/

  function __timeOutFinally( err, arg )
  {

    _.time.begin( o.time, () => self.take( err, arg ) );

    // _.time.out( o.time ).tap( () =>
    // {
    //   self.take( err, arg );
    // });

  }

  /**/

  function __timeOutCatch( err )
  {

    _.time.begin( o.time, () => self.take( undefined, err ) );

    // _.time.out( o.time ).tap( () =>
    // {
    //   self.take( undefined, err );
    // });

  }

  /**/

  function __timeOutThen( arg )
  {

    _.time.begin( o.time, () => self.take( arg ) );

    // _.time.out( o.time ).tap( () =>
    // {
    //   self.take( arg );
    // });

  }

  /**/

}

_timeOut.defaults =
{
  time : null,
  kindOfResource : null,
}

_timeOut.having =
{
  consequizing : 1,
}

let finallyTimeOut = _.routineFromPreAndBody( timeOut_pre, _timeOut, 'finallyTimeOut' );
var defaults = finallyTimeOut.defaults;
defaults.kindOfResource = KindOfResource.Both;

let thenTimeOut = _.routineFromPreAndBody( timeOut_pre, _timeOut, 'thenTimeOut' );
var defaults = thenTimeOut.defaults;
defaults.kindOfResource = KindOfResource.ArgumentOnly;

let exceptTimeOut = _.routineFromPreAndBody( timeOut_pre, _timeOut, 'exceptTimeOut' );
var defaults = exceptTimeOut.defaults;
defaults.kindOfResource = KindOfResource.ErrorOnly;

//

function timeLimit_pre( routine, args )
{
  let o = { time : args[ 0 ], callback : args[ 1 ] };
  if( o.callback === undefined )
  o.callback = _.nothing;
  _.routineOptions( routine, o );
  _.assert( arguments.length === 2 );
  _.assert( args.length === 1 || args.length === 2 );
  _.assert( _.numberIs( o.time ) );
  return o;
}

//

function _timeLimit( o )
{
  let self = this;
  let time = o.time;
  let callback = o.callback;
  let callbackConsequence = callback;
  let throwing = o.throwing;
  let timeOutConsequence = new _.Consequence();
  let done = false;
  let timer;
  let procedure = self.procedureDetach() || _.Procedure( 2 );

  _.assert( arguments.length === 1 );
  _.assert( callback !== undefined && callback !== _.nothing, 'Expects callback or consequnce to time limit it' );

  if( !_.consequenceIs( callbackConsequence ) )
  {
    if( !_.routineIs( callbackConsequence ) )
    callback = callbackConsequence = _.Consequence.From( callbackConsequence );
    else
    callbackConsequence = new _.Consequence();
  }

  let c = self._competitorAppend
  ({
    keeping : false,
    competitorRoutine : _timeLimitCallback,
    kindOfResource : KindOfResource.Both,
    stack : 3,
  });

  self.procedure( () => procedure.clone() ).nameElse( 'timeLimit' );
  self.orKeeping([ callbackConsequence, timeOutConsequence ]);
  self.procedure( () => procedure.clone() ).nameElse( 'timeLimit' );
  self.tap( () =>
  {
    done = true;
    if( timer )
    _.time.cancel( timer );
  });

  self.__handleResourceSoon( false );

  return self;

  /* */

  function _timeLimitCallback( err, arg )
  {

    if( err )
    {
      _.assert( !done, 'not tested' );
      procedure.finit();
      if( !done )
      timeOutConsequence.error( err );
      return;
    }

    _.assert( !done, 'not tested' );
    if( !_.consequenceIs( callback ) )
    {
      callback = _.Consequence.Try( () => callback() )
      callback.procedure( () => procedure.clone() );
      callback.finally( callbackConsequence );
    }

    timer = _.time.begin( o.time, procedure, () =>
    {
      if( done )
      return;
      if( throwing )
      timeOutConsequence.error( _.time._errTimeOut({ procedure, reason : 'time limit', consequnce : self }) );
      else
      timeOutConsequence.take( _.time.out );
    })

  }

  /* */

}

_timeLimit.defaults =
{
  time : null,
  callback : null,
  throwing : 0,
}

_timeLimit.having =
{
  consequizing : 1,
}

let timeLimit = _.routineFromPreAndBody( timeLimit_pre, _timeLimit, 'timeLimit' );
var defaults = timeLimit.defaults;
defaults.kindOfResource = KindOfResource.Both;
defaults.throwing = 0;

let timeLimitThrowing = _.routineFromPreAndBody( timeLimit_pre, _timeLimit, 'timeLimitThrowing' );
var defaults = timeLimitThrowing.defaults;
defaults.kindOfResource = KindOfResource.Both;
defaults.throwing = 1;

//

function timeLimitSplit( time )
{
  let self = this;
  let result = new _.Consequence();

  _.assert( arguments.length === 1 );

  result._timeLimit
  ({
    time,
    callback : self,
    kindOfResource : KindOfResource.Both,
    throwing : 0,
  });

  result.take( null );

  return result;
}

//

function timeLimitThrowingSplit( time )
{
  let self = this;
  let result = new _.Consequence();

  _.assert( arguments.length === 1 );

  result._timeLimit
  ({
    time,
    callback : self,
    kindOfResource : KindOfResource.Both,
    throwing : 1,
  });

  result.take( null );

  return result;
}

// --
// and
// --

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

function _and( o )
{
  let self = this;
  let errs = [];
  let args = [];
  let anyErr;
  let competitors = o.competitors;
  let keeping = o.keeping;
  let accumulative = o.accumulative;
  let waiting = o.waiting;
  let procedure = self.procedure( o.stack + 1 ).nameElse( 'and' );
  let escaped = 0;
  let errId = {};

  _.assertRoutineOptions( _and, arguments );

  /* */

  if( _.arrayLike( competitors ) )
  competitors = _.longSlice( competitors );
  else
  competitors = [ competitors ];

  if( o.waiting )
  competitors.push( self );
  else
  competitors.unshift( self );

  let left = competitors.length;
  let first = o.waiting ? 0 : 1;
  let last = o.waiting ? competitors.length-1 : competitors.length;

  /* */

  if( Config.debug && self.Diagnostics )
  {
    let competitors2 = [];

    for( let s = first ; s < last ; s++ )
    {
      let competitor = competitors[ s ];
      _.assert
      (
          _.consequenceIs( competitor ) || _.routineIs( competitor ) || competitor === null /* yyy */
        , () => 'Consequence.and expects consequence, routine or null, but got ' + _.strType( competitor )
      );
      if( !_.consequenceIs( competitor ) )
      continue;
      if( _.longHas( competitors2, competitor ) )
      continue;
      competitor.assertNoDeadLockWith( self );
      _.arrayAppendOnceStrictly( self._dependsOf, competitor );
      competitors2.push( competitor );
    }

  }

  /* */

  if( o.waiting )
  self.finallyGive( start );
  else
  start();

  escaped = 1;
  return self;

  /* - */

  function start( err, arg )
  {

    callbacksStart();

    if( o.waiting )
    {
      __got.call( self, err, arg );
    }
    else
    self.finallyGive( ( err, arg ) =>
    {
      __got.call( self, err, arg );
    });

  }

  /* - */

  function callbacksStart()
  {
    let competitors2 = []; /* xxx : renames */

    for( let c = first ; c < last ; c++ ) (function( c )
    {
      let competitor = competitors[ c ];
      let originalCompetitor = competitor;
      let wasRoutine = false;

      if( !_.consequenceIs( competitor ) && _.routineIs( competitor ) )
      try
      {
        wasRoutine = true;
        competitor = competitors[ c ] = competitor();
      }
      catch( err )
      {
        competitor = competitors[ c ] = new _.Consequence().error( _.err( err ) );
      }

      if( _.promiseLike( competitor ) )
      competitor = competitors[ c ] = _.Consequence.From( competitor );

      if( o.waiting )
      _.assert
      (
          _.consequenceIs( competitor ) /*|| competitor === null*/ /* yyy */
        , () => `Expects consequence or null, but got ${_.strType( competitor )}`
      );
      else
      _.assert
      (
          competitor !== undefined
        , () => `Expects defined value, but got ${_.strType( competitor )}`
              + `${ _.routineIs( originalCompetitor ) ? '\n' + originalCompetitor.toString() : ''}`
      );

      if( o.waiting )
      {

        if( competitor === null ) /* xxx : teach And to accept non-consequence */
        {
          __got.call( c, undefined, null );
          return;
        }
        else if( _.longHas( competitors2, competitor ) )
        {
          return;
        }

      }
      else
      {

        if( _.consequenceIs( competitor ) )
        {
          if( _.longHas( competitors2, competitor ) )
          return;
        }
        else
        {
          __got.call( c, undefined, competitor );
          return;
        }

      }

      /*
      accounting of dependencies of routines
      consequences have already been accounted
      */

      competitors2.push( competitor );

      if( wasRoutine )
      if( _.consequenceIs( competitor ) )
      if( Config.debug && self.Diagnostics )
      {
        competitor.assertNoDeadLockWith( self );
        _.assert( !_.longHas( self._dependsOf, competitor ) );
        _.arrayAppendOnceStrictly( self._dependsOf, competitor );
      }

      competitor.procedure({ _stack : procedure.stack() }).nameElse( 'andVariant' );
      competitor.finallyGive( __got );

    })( c );

  }

  /* */

  function __got( err, arg )
  {
    let firstIndex = -1;

    if( err && !anyErr )
    anyErr = err;

    if( _.numberIs( this ) )
    {
      account( this )
    }
    else for( let c = 0 ; c < competitors.length ; c++ )
    {
      let competitor = competitors[ c ];
      if( competitor === this )
      account( c );
    }

    if( Config.debug && self.Diagnostics )
    if( first <= firstIndex && firstIndex < last )
    if( _.consequenceIs( this ) )
    {
      _.arrayRemoveElementOnceStrictly( self._dependsOf, this );
    }

    _.assert( left >= 0 );

    if( left === 0 )
    {
      if( escaped && o.waiting )
      _.time.soon( __take );
      else
      __take();
    }

    function account( c )
    {
      if( err )
      {
        err = _.errSuspend( err, errId );
        _.assert( err.suspended === errId );
      }
      errs[ c ] = err;
      args[ c ] = arg;
      left -= 1;
      if( firstIndex === -1 )
      firstIndex = c;
    }

  }

  /* */

  function __take()
  {
    let competitors2 = [];

    if( keeping )
    for( let i = first ; i < last ; i++ )
    if( competitors[ i ] )
    {
      let competitor = competitors[ i ];
      if( _.longHas( competitors2, competitor ) )
      continue;
      if( !_.consequenceIs( competitor ) )
      continue;

      let err = errs[ i ];
      if( err && err.suspended === errId )
      {
        err = _.errSuspend( err, false );
      }

      competitor.take( err, args[ i ] );
      competitors2.push( competitor );
    }

    if( accumulative )
    args = _.arrayFlatten( args );

    if( anyErr )
    self.error( anyErr );
    else
    self.take( args );

  }

  /* */

}

_and.defaults =
{
  competitors : null,
  keeping : 0,
  accumulative : 0,
  waiting : 1,
  stack : 2,
}

var having = _and.having = Object.create( null );
having.consequizing = 1;
having.andLike = 1;

//

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

   con1.finallyGive( function( err, value )
   {
     console.log( 'con1 competitor executed with value: ' + value + 'and error: ' + err );
   } );

   con2.finallyGive( function( err, value )
   {
     console.log( 'con2 competitor executed with value: ' + value + 'and error: ' + err );
   } );

   let conOwner = new  _.Consequence();

   conOwner.andTake( [ con1, con2 ] );

   conOwner.take( 100 );
   conOwner.finallyGive( handleGot1 );

   con1.take( 'value1' );
   con2.error( 'ups' );
   // prints
   // con1 competitor executed with value: value1and error: null
   // con2 competitor executed with value: undefinedand error: ups
   // handleGot1 value: 100

 * @param {wConsequence[]|wConsequence} competitors array of wConsequence
 * @returns {wConsequence}
 * @throws {Error} if missed arguments.
 * @throws {Error} if passed extra arguments.
 * @method andTake
 * @module Tools/base/Consequence
 * @namespace Tools
 * @class wConsequence
 */

let andTake = _.routineFromPreAndBody( and_pre, _and, 'andTake' );
var defaults = andTake.defaults;
defaults.keeping = false;

//

/**
 * Works like andTake() method, but unlike andTake() andKeep() take back massages to src consequences once all come.
 * @see {@link module:Tools/base/Consequence.wConsequence#andTake}
 * @param {wConsequence[]|wConsequence} competitors Array of wConsequence objects
 * @throws {Error} If missed or passed extra argument.
 * @method andKeep
 * @module Tools/base/Consequence
 * @namespace Tools
 * @class wConsequence
 */

let andKeep = _.routineFromPreAndBody( and_pre, _and, 'andKeep' );
var defaults = andKeep.defaults;
defaults.keeping = true;

/* qqq : jsdoc, please */

let andKeepAccumulative = _.routineFromPreAndBody( and_pre, _and, 'andKeepAccumulative' );
var defaults = andKeepAccumulative.defaults;
defaults.keeping = true;
defaults.accumulative = true;

//

/**
 * Call passed callback without waiting for resource and collect result of the call into an array.
 * To convert serial code to parallel replace methods {then}/{finally} by methods {also*}, without need to change structure of the code, what methods {and*} require.
 * First element of returned array has a resource which the consequence have had before call of ${also} or the first which the consequence will get later.
 * Returned by callback passed to ${also*} put into returned array in the same sequence as ${also*} were called.
 *
 * @see {@link module:Tools/base/Consequence.wConsequence#alsoTake}
 * @param {Anything} callbacks Single callback or element to put in result array or array of such things.
 * @method alsoKeep
 * @module Tools/base/Consequence
 * @namespace Tools
 * @class wConsequence
 */

let alsoKeep = _.routineFromPreAndBody( and_pre, _and, 'alsoKeep' );
var defaults = alsoKeep.defaults;
defaults.keeping = true;
defaults.accumulative = true;
defaults.waiting = false;

//

/**
 * Call passed callback without waiting for resource and collect result of the call into an array.
 * To convert serial code to parallel replace methods {then}/{finally} by methods {also*}, without need to change structure of the code, what methods {and*} require.
 * First element of returned array has a resource which the consequence have had before call of ${also} or the first which the consequence will get later.
 * Returned by callback passed to ${also*} put into returned array in the same sequence as ${also*} were called.
 *
 * @see {@link module:Tools/base/Consequence.wConsequence#alsoKeep}
 * @param {Anything} callbacks Single callback or element to put in result array or array of such things.
 * @method alsoTake
 * @module Tools/base/Consequence
 * @namespace Tools
 * @class wConsequence
 */

let alsoTake = _.routineFromPreAndBody( and_pre, _and, 'alsoTake' );
var defaults = alsoTake.defaults;
defaults.keeping = false;
defaults.accumulative = true;
defaults.waiting = false;

//

function AndTake_()
{
  _.assert( !_.instanceIs( this ) )
  // _.assert( arguments.length === 1 );
  // srcs = _.arrayFlatten( _.arrayAs( srcs ) );

  return _.Consequence().take( null ).andTake( arguments ).then( ( arg ) =>
  {
    _.assert( arg[ arg.length - 1 ] === null );
    arg.splice( arg.length - 1, 1 );
    return arg;
  });
}

//

// function AndKeep( srcs )
function AndKeep_()
{
  _.assert( !_.instanceIs( this ) )
  // _.assert( arguments.length === 1 );
  // srcs = _.arrayFlatten( _.arrayAs( srcs ) );

  return _.Consequence().take( null ).andKeep( arguments ).then( ( arg ) =>
  {
    _.assert( arg[ arg.length - 1 ] === null );
    arg.splice( arg.length - 1, 1 );
    return arg;
  });
}

// --
// or
// --

function _or( o )
{
  let self = this;
  let count = 0;
  let procedure = self.procedure( o.stack + 1 ).nameElse( 'or' );
  let competitors = o.competitors;
  let competitorRoutines = [];

  _.assertRoutineOptions( _or, arguments );

  if( _.arrayLike( competitors ) )
  competitors = _.longSlice( competitors );
  else
  competitors = [ competitors ];

  /* xxx qqq : implement tests: arguments are promises */

  for( let c = competitors.length-1 ; c >= 0 ; c-- )
  {
    let competitorRoutine = competitors[ c ];
    if( _.promiseLike( competitorRoutine ) )
    competitorRoutine = _.Consequence.From( competitorRoutine );
    _.assert( _.consequenceIs( competitorRoutine ) || competitorRoutine === null );
    if( competitorRoutine === null )
    competitors.splice( c, 1 );
  }

  /* */

  if( o.gettingReadyFirst )
  {
    self.thenGive( function( arg )
    {
      _take();
    });
  }
  else
  {
    competitors.unshift( self );
    _take();
  }

  return self;

  /* - */

  function _take()
  {

    for( let c = 0 ; c < competitors.length ; c++ )
    {
      let competitor = competitors[ c ];

      _.assert( _.consequenceIs( competitor ) );

      let competitorRoutine = competitorRoutines[ c ] = _.routineJoin( undefined, _got, [ c ] );
      competitor.procedure({ _stack : procedure.stack() }).nameElse( 'orVariant' );
      competitor.finallyGive( competitorRoutine );

      if( count )
      break;
    }

  }

  /* - */

  function _got( index, err, arg )
  {

    count += 1;

    _.assert( count === 1 );

    for( let c = 0 ; c < competitors.length ; c++ )
    {
      let competitor = competitors[ c ];
      let competitorRoutine = competitorRoutines[ c ];
      _.assert( !!competitor );
      if( competitorRoutine )
      if( competitor.competitorOwn( competitorRoutine ) )
      competitor.competitorsCancel( competitorRoutine );
    }

    if( o.keeping )
    if( o.gettingReadyFirst || index !== 0 )
    competitors[ index ].take( err, arg );

    if( count === 1 )
    self.take( err, arg );

    // if( o.keeping )
    // if( o.gettingReadyFirst || index !== 0 )
    // competitors[ index ].take( err, arg );

  }

  /* - */

}

_or.defaults =
{
  competitors : null,
  keeping : null,
  gettingReadyFirst : null,
  stack : 2,
}

_or.having =
{
  consequizing : 1,
  orLike : 1,
}

//

function afterOrTaking( competitors )
{
  let self = this;
  _.assert( arguments.length === 1, 'Expects single argument' );
  return self._or
  ({
    competitors,
    keeping : false,
    gettingReadyFirst : true,
    stack : 2,
  });
}

afterOrTaking.having = Object.create( _or.having );

//

function afterOrKeeping( competitors )
{
  let self = this;
  _.assert( arguments.length === 1, 'Expects single argument' );
  return self._or
  ({
    competitors,
    keeping : true,
    gettingReadyFirst : true,
    stack : 2,
  });
}

afterOrKeeping.having = Object.create( _or.having );

//

function orKeepingSplit( competitors )
{
  let self = this;
  _.assert( arguments.length === 1, 'Expects single argument' );

  if( _.arrayLike( competitors ) )
  competitors = _.longSlice( competitors );
  else
  competitors = [ competitors ];

  competitors.unshift( self );

  let con = new Self().take( null );

  con.procedure( 2 ).nameElse( 'orKeepingSplit' );
  con.afterOrKeeping( competitors );

  return con;
}

orKeepingSplit.having = Object.create( _or.having );

//

function orTaking( competitors )
{
  let self = this;
  _.assert( arguments.length === 1, 'Expects single argument' );
  return self._or
  ({
    competitors,
    keeping : false,
    gettingReadyFirst : false,
    stack : 2,
  });
}

orTaking.having = Object.create( _or.having );

//

function orKeeping( competitors )
{
  let self = this;
  _.assert( arguments.length === 1, 'Expects single argument' );
  return self._or
  ({
    competitors,
    keeping : true,
    gettingReadyFirst : false,
    stack : 2,
  });
}

orKeeping.having = Object.create( _or.having );

//

function OrTake( srcs )
{
  _.assert( !_.instanceIs( this ) )
  return _.Consequence().orTaking( arguments ).then( ( arg ) =>
  {
    return arg;
  });
}

//

function OrKeep( srcs )
{
  _.assert( !_.instanceIs( this ) )
  return _.Consequence().orKeeping( arguments ).then( ( arg ) =>
  {
    return arg;
  });
}

//

function tolerantCallback()
{
  let self = this;
  _.assert( arguments.length === 0, 'Expects no arguments' );
  return function tolerantCallback( err, arg )
  {
    if( !err )
    err = undefined;
    if( arg === null || err )
    arg = undefined;
    return self( err, arg );
  }
}

// --
// resource
// --

function takeLater( timeOut, error, argument )
{
  let self = this;

  _.assert( arguments.length === 2 || arguments.length === 3 );
  _.assert( _.numberIs( timeOut ) );

  if( argument === undefined )
  {
    argument = arguments[ 1 ];
    error = undefined;
  }

  if( error === null )
  error = undefined;

  _.assert( error !== undefined || argument !== undefined, 'Argument of take should be something, not undefined' );
  _.assert( error === undefined || argument === undefined, 'Cant take both error and argument, one should be undefined' );

  /* */

  _.time.begin( timeOut, function now()
  {
    self.take( error, argument );
  });

  return self;
}

takeLater.having =
{
  consequizing : 1,
}

//

function takeSoon( error, argument )
{
  let self = this;

  if( arguments.length === 1 )
  {
    argument = error;
    error = undefined;
  }

  if( error === null )
  error = undefined;

  _.assert( arguments.length === 2 || arguments.length === 1, 'Expects 1 or 2 arguments, but got ' + arguments.length );
  _.assert( error !== undefined || argument !== undefined, 'Argument of take should be something, not undefined' );
  _.assert( error === undefined || argument === undefined, 'Cant take both error and argument, one should be undefined' );

  // self.__onTake( error, argument );

  _.time.begin( 1, () =>
  {
    self.take( error, argument );
  });

  return self;
}

//

function takeAll()
{
  let self = this;

  for( let a = 0 ; a < arguments.length ; a++ )
  self.take( arguments[ a ] );

  return self;
}

//

/**
 * Method pushes `resource` into wConsequence resources queue.
 * Method also can accept two parameters: error, and
 * Returns current wConsequence instance.
 * @example
 * function gotHandler1( error, value )
   {
     console.log( 'competitor 1: ' + value );
   };

   let con1 = new _.Consequence();

   con1.finallyGive( gotHandler1 );
   con1.take( 'hello' );

   // prints " competitor 1: hello ",
 * @param {*} [resource] Resolved value
 * @returns {wConsequence} consequence current wConsequence instance.
 * @throws {Error} if passed extra parameters.
 * @method take
 * @module Tools/base/Consequence
 * @namespace Tools
 * @class wConsequence
 */

function take( error, argument )
{
  let self = this;

  if( arguments.length === 1 )
  {
    argument = error;
    error = undefined;
  }

  if( error === null )
  error = undefined;

  _.assert( arguments.length === 2 || arguments.length === 1, 'Expects 1 or 2 arguments, but got ' + arguments.length );
  _.assert( error !== undefined || argument !== undefined, 'Argument of take should be something, not undefined' );
  _.assert( error === undefined || argument === undefined, 'Cant take both error and argument, one should be undefined' );

  if( error !== undefined )
  error = self.__handleError( error )

  self.__take( error, argument );

  if( self.AsyncCompetitorHanding || self.AsyncResourceAdding )
  self.__handleResourceSoon( true );
  else
  self.__handleResourceNow();

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

   con.finallyGive( showResult );
   divade( 3, 0 );

   // prints : handleGot1 error: divide by zero
 * @param {*|Error} error error, or value that represent error reason
 * @throws {Error} if passed extra parameters.
 * @method error
 * @module Tools/base/Consequence
 * @namespace Tools
 * @class wConsequence
 */

function error( error )
{
  let self = this;

  _.assert( arguments.length === 1 || arguments.length === 0 );

  if( arguments.length === 0  )
  error = _.err();

  if( error !== undefined )
  error = self.__handleError( error )

  self.__take( error, undefined );

  if( self.AsyncCompetitorHanding || self.AsyncResourceAdding )
  self.__handleResourceSoon( true );
  else
  self.__handleResourceNow();

  return self;
}

error.having =
{
  consequizing : 1,
}

//

function __take( error, argument )
{
  let self = this;

  let resource = Object.create( null );
  resource.error = error;
  resource.argument = argument;

  _.assert( error !== undefined || argument !== undefined, 'Argument of take should be something, not undefined' );
  _.assert( error === undefined || argument === undefined, 'Cant take both error and argument, one should be undefined' );
  _.assert( arguments.length === 2 );

  self.__onTake( error, argument );

  if( _.consequenceIs( argument ) )
  {
    debugger;
    argument.finallyGive( self );
    return self;
  }
  else if( _.promiseLike( argument ) )
  {
    debugger;
    Self.From( argument ).finallyGive( self );
    return self;
  }

  if( Config.debug )
  {
    if( error === undefined )
    if( !( !self.capacity || self._resources.length < self.capacity ) )
    {
      let args =
      [
        `Resource capacity of ${self.qualifiedName} set to ${self.capacity}, but got more resources.`
        + `\nConsider resetting : "{ capacity : 0 }"`
      ]
      debugger;
      throw _._err({ args : args, stackRemovingBeginExcluding : /\bConsequence.s\b/ });
    }
    if( !( error === undefined || argument === undefined ) )
    {
      let args =
      [
        '{-error-} and {-argument-} channels should not be in use simultaneously\n'
        + '{-error-} or {-argument-} should be undefined, but currently '
        + '\n{-error-} is ' + _.strType( error )
        + '\n{-argument-} is ' + _.strType( argument )
      ]
      debugger;
      throw _._err({ args : args, stackRemovingBeginExcluding : /\bConsequence.s\b/ });
    }
  }

  self._resources.push( resource );

  return self;
}

//

function __onTake( err, arg )
{
  let self = this;

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
//    con.finallyGive( increment );
//    let result = con.ping( undefined, 4 );
//    console.log( result );
//    // prints 5;
//  * @param {*} error
//  * @param {*} argument
//  * @returns {*} result
//  * @throws {Error} if missed arguments or passed extra arguments
//  * @method ping
//  * @module Tools/base/Consequence
// * @namespace Tools
// * @class wConsequence
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
//     error,
//     argument,
//   }
//
//   self._resources.push( resource );
//   let result = self.__handleResourceSoon();
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
 * @module Tools/base/Consequence
 * @namespace Tools
 * @class wConsequence
 */

function __handleError( err, competitor )
{
  let self = this;

  if( Config.debug && competitor && err && !err.asyncCallsStack )
  {
    err = _._err
    ({
      args : [ err ],
      level : 3,
      asyncCallsStack : competitor.procedure ? [ competitor.procedure.stack() ] : null,
    });
  }
  else
  {
    if( !_.errIsStandard( err ) )
    err = _._err
    ({
      args : [ err ],
      level : 3,
    });
  }

  if( _.errIsAttended( err ) )
  return err;

  let timer = _.time.finally( self.UncaughtTimeOut, function uncaught()
  {
    // debugger;
    // if( err.id === 2 ) // xxx
    // debugger;

    // console.log( `err.id : ${err.id}` );
    // console.log( `timer.state : ${timer.state}` );
    // console.log( `timerIsCancelBegun : ${_.time.timerIsCancelBegun( timer )}` );
    // console.log( `errIsSuspended : ${_.errIsSuspended( err )}` );
    // debugger;

    if( !_.time.timerIsCancelBegun( timer ) && _.errIsSuspended( err ) )
    return;

    if( _.errIsAttended( err ) )
    return;

    _.setup._errUncaughtHandler2( err, 'uncaught asynchronous error' );
    return null;
  });

  return err;
}

//

/**
 * Method for processing corespondents and _resources queue. Provides handling of resolved resource values and errors by
    corespondents from competitors value. Method takes first resource from _resources sequence and try to pass it to
    the first corespondent in corespondents sequence. Method returns the result of current corespondent execution.
    There are several cases of __handleResourceSoon behavior:
    - if corespondent is regular function:
      trying to pass resources error and argument values into corespondent and executing. If during execution exception
      occurred, it will be catch by __handleError method. If corespondent was not added by tap or persist method,
      __handleResourceSoon will remove resource from head of queue.

      If corespondent was added by finally, _onceThen, catchKeep, or by other "thenable" method of wConsequence, finally:

      1) if result of corespondents is ordinary value, finally __handleResourceSoon method appends result of corespondent to the
      head of resources queue, and therefore pass it to the next competitor in corespondents queue.
      2) if result of corespondents is instance of wConsequence, __handleResourceSoon will append current wConsequence instance
      to result instance corespondents sequence.

      After method try to handle next resource in queue if exists.

    - if corespondent is instance of wConsequence:
      in that case __handleResourceSoon pass resource into corespondent`s resources queue.

      If corespondent was added by tap, or one of finally, _onceThen, catchKeep, or by other "thenable" method of
      wConsequence finally __handleResourceSoon try to pass current resource to the next competitor in corespondents sequence.

    - if in current wConsequence are present corespondents added by persist method, finally __handleResourceSoon passes resource to
      all of them, without removing them from sequence.

 * @returns {*}
 * @throws {Error} if on invocation moment the _resources queue is empty.
 * @private
 * @method __handleResourceSoon
 * @module Tools/base/Consequence
 * @namespace Tools
 * @class wConsequence
 */

function __handleResourceSoon( isResource )
{
  let self = this;
  let async = isResource ? self.AsyncResourceAdding : self.AsyncCompetitorHanding;

  _.assert( _.boolIs( isResource ) );

  if( async )
  {

    if( !self._competitorsEarly.length && !self._competitorsLate.length )
    return;
    if( !self._resources.length )
    return;

    _.time.soon( () => self.__handleResourceNow() );

  }
  else
  {
    self.__handleResourceNow();
  }

}

//

function __handleResourceNow()
{
  let self = this;
  let counter = 0;
  let consequences = [];

  do
  {
    while( __iteration() );
    self = consequences.pop();
  }
  while( self );

  function __iteration()
  {

    if( !self._resources.length )
    return false;
    if( !self._competitorsEarly.length && !self._competitorsLate.length )
    return false;

    /* */

    let resource = self._resources[ 0 ];
    let competitor;
    let isEarly;

    if( self._competitorsEarly.length > 0 )
    {
      competitor = self._competitorsEarly.shift();
      isEarly = true;
    }
    else
    {
      competitor = self._competitorsLate.shift();
      isEarly = false;
    }

    let isConsequence = _.consequenceIs( competitor.competitorRoutine )
    let errorOnly = competitor.kindOfResource === Self.KindOfResource.ErrorOnly;
    let argumentOnly = competitor.kindOfResource === Self.KindOfResource.ArgumentOnly;

    let executing = true;
    executing = executing && ( !errorOnly || ( errorOnly && !!resource.error ) );
    executing = executing && ( !argumentOnly || ( argumentOnly && !resource.error ) );

    if( !executing )
    {
      if( competitor.procedure )
      competitor.procedure.end();
      return true;
    }

    /* resourceReusing */

    _.assert( !!competitor.instant, 'not implemented' );

    let resourceReusing = false;
    resourceReusing = resourceReusing || !executing;
    resourceReusing = resourceReusing || competitor.tapping;
    if( isConsequence && competitor.keeping && competitor.instant )
    resourceReusing = true;

    if( !resourceReusing )
    self._resources.shift();

    /* debug */

    if( Config.debug )
    if( self.Diagnostics )
    {
      if( isConsequence )
      _.arrayRemoveElementOnceStrictly( competitor.competitorRoutine._dependsOf, self );
    }

    if( isConsequence )
    {

      competitor.competitorRoutine.__take( resource.error, resource.argument );

      if( competitor.procedure )
      competitor.procedure.end();

      // if( !competitor.instant && competitor.keeping )
      // debugger;
      // if( !competitor.instant && competitor.keeping )
      // competitor.competitorRoutine._competitorAppend
      // ({
      //   competitorRoutine : self,
      //   keeping : true,
      //   kindOfResource : Self.KindOfResource.Both,
      //   stack : 3,
      //   instant : 1,
      //   late : 1,
      // });

      if( competitor.competitorRoutine.AsyncCompetitorHanding || competitor.competitorRoutine.AsyncResourceAdding )
      {
        competitor.competitorRoutine.__handleResourceSoon( true );
      }
      else
      {
        consequences.push( self );
        self = competitor.competitorRoutine;
        // competitor.competitorRoutine.__handleResourceNow();
      }

    }
    else
    {

      /* call routine */

      let throwenErr = 0;
      let result;
      // let isActivated = false;

      if( competitor.procedure )
      {

        // if( competitor.procedure.id === 30 )
        // debugger;

        // isActivated = competitor.procedure.isActivated();
        // if( !competitor.procedure.isTopMost() )
        // if( !isActivated )
        if( !competitor.procedure.use() )
        competitor.procedure.activate( true );
        _.assert( competitor.procedure.isActivated() );
      }

      try
      {
        if( errorOnly )
        result = competitor.competitorRoutine.call( self, resource.error );
        else if( argumentOnly )
        result = competitor.competitorRoutine.call( self, resource.argument );
        else
        result = competitor.competitorRoutine.call( self, resource.error, resource.argument );
      }
      catch( err )
      {
        throwenErr = self.__handleError( err, competitor );
      }

      if( competitor.procedure )
      {

        // if( competitor.procedure.id === 30 )
        // debugger;

        // if( !isActivated )
        {
          competitor.procedure.unuse();
          if( !competitor.procedure.isUsed() )
          {
            competitor.procedure.activate( false );
            // _.assert( !competitor.procedure.isActivated() );
            // if( !competitor.procedure.isActivated() )
            competitor.procedure.end();
          }
        }
        // competitor.procedure.end();
      }

      if( !throwenErr )
      if( competitor.keeping && result === undefined )
      {
        debugger;
        // logger.log( 'inspector', require( 'inspector' ) );
        let err = self.ErrNoReturn( competitor.competitorRoutine );
        throwenErr = self.__handleError( err, competitor )
      }

      /* keeping */

      if( throwenErr )
      {

        self.__take( throwenErr, undefined );

      }
      else if( competitor.keeping )
      {

        if( _.consequenceIs( result ) )
        {
          result.finally( self );
        }
        else if( _.promiseLike( result ) )
        {
          Self.From( result ).finally( self );
        }
        else
        {
          self.__take( undefined, result );
        }

      }

    }

    if( self.AsyncCompetitorHanding || self.AsyncResourceAdding )
    return self.__handleResourceSoon( true );

    counter += 1;
    return true;
  }

}

//

/**
 * Method created and appends competitor object, based on passed options into wConsequence competitors queue.
 *
 * @param {Object} o options map
 * @param {Competitor|wConsequence} o.competitorRoutine callback
 * @param {Object} [o.context] if defined, it uses as 'this' context in competitor function.
 * @param {Array<*>|ArrayLike} [o.argument] values, that will be used as binding arguments in competitor.
 * @param {boolean} [o.keeping=false] If sets to true, finally result of current competitor will be passed to the next competitor
    in competitors queue.
 * @param {boolean} [o.persistent=false] If sets to true, finally competitor will be work as queue listener ( it will be
 * processed every value resolved by wConsequence).
 * @param {boolean} [o.tapping=false] enabled some breakpoints in debug mode;
 * @returns {wConsequence}
 * @private
 * @method _competitorAppend
 * @module Tools/base/Consequence
 * @namespace Tools
 * @class wConsequence
 */

function _competitorAppend( o )
{
  let self = this;
  let competitorRoutine = o.competitorRoutine;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.consequenceIs( self ) );
  _.assert( _.routineIs( competitorRoutine ) || _.consequenceIs( competitorRoutine ), () => 'Expects routine or consequence, but got ' + _.strType( competitorRoutine ) );
  _.assert( o.kindOfResource >= 1 );
  _.assert( competitorRoutine !== self, 'Consquence cant depend on itself' );
  _.assert( o.stack >= 0, 'Competitor should have stack level greater or equal to zero' );
  _.routineOptions( _competitorAppend, o );

  /* */

  if( o.times !== 1 )
  {
    let o2 = _.mapExtend( null, o );
    o2.times = 1;
    for( let t = 0 ; t < o.times ; t++ )
    self._competitorAppend( o2 );
    return;
  }

  let stack = o.stack;
  let competitorDescriptor = o;
  delete competitorDescriptor.times;
  delete competitorDescriptor.stack;

  /* */

  if( Config.debug )
  {

    if( !_.consequenceIs( competitorRoutine ) )
    {
      if( o.kindOfResource === Self.KindOfResource.ErrorOnly )
      _.assert( competitorRoutine.length <= 1, 'ErrorOnly competitor should expect single argument' );
      else if( o.kindOfResource === Self.KindOfResource.ArgumentOnly )
      _.assert( competitorRoutine.length <= 1, 'ArgumentOnly competitor should expect single argument' );
      else if( o.kindOfResource === Self.KindOfResource.Both )
      _.assert( competitorRoutine.length === 0 || competitorRoutine.length === 2, 'Finally competitor should expect two arguments' );
    }

    if( _.consequenceIs( competitorRoutine ) )
    if( self.Diagnostics )
    {
      self.assertNoDeadLockWith( competitorRoutine );
      competitorRoutine._dependsOf.push( self );
    }

    // if( self.Diagnostics && self.Stacking )
    // {
    //   competitorDescriptor.stack = _.introspector.stack([ stack, Infinity ]); /* deprecate, procedure has stack! */
    // }

  }

  /* procedure */

  /* xxx qqq : cover consequence with _procedure : false */
  if( self._procedure === null )
  self._procedure = new _.Procedure({ _stack : stack });

  _.assert( _.routineIs( o.competitorRoutine ) );

  if( !self._procedure.name() )
  self._procedure.name( o.competitorRoutine.name || '' );

  _.assert( self._procedure._routine === null || self._procedure._routine === o.competitorRoutine );

  if( !self._procedure._routine )
  self._procedure._routine = o.competitorRoutine;
  if( !self._procedure._object )
  self._procedure._object = competitorDescriptor;

  self._procedure.begin();

  competitorDescriptor.procedure = self._procedure;

  if( self._procedure )
  self._procedure = null;

  /* */

  // if( o.late === null )
  // o.late = _.consequenceIs( o.competitorRoutine );
  // if( o.late )
  // zzz : implement con1.then( con )

  if( o.late )
  self._competitorsLate.unshift( competitorDescriptor );
  else
  self._competitorsEarly.push( competitorDescriptor );

  return competitorDescriptor;
}

_competitorAppend.defaults =
{
  competitorRoutine : null,
  keeping : null,
  tapping : null,
  kindOfResource : null,
  late : false,
  instant : true,
  // instant : false, // zzz : implement con1.then( con )

  times : 1,
  stack : null, /* xxx : use procedure instead */
  // procedure : null,
}

// --
// accounter
// --

function dependencyChainFor( competitor )
{
  let self = this;

  _.assert( _.consequenceIs( competitor ) );

  return look( self, competitor, [] );

  /* */

  function look( con1, con2, visited )
  {

    if( _.longHas( visited, con1 ) )
    return null;
    visited.push( con1 );

    _.assert( _.consequenceIs( con1 ) );

    if( !con1._dependsOf )
    return null;
    if( con1 === con2 )
    return [ con1 ];

    for( let c = 0 ; c < con1._dependsOf.length ; c++ )
    {
      let con1b = con1._dependsOf[ c ];
      if( _.consequenceIs( con1b ) )
      {
        let chain = look( con1b, con2, visited );
        if( chain )
        {
          chain.unshift( con1 );
          return chain;
        }
      }
    }

    return null;
  }

}

//

function doesDependOf( competitor )
{
  let self = this;

  _.assert( _.consequenceIs( competitor ) );

  let chain = self.dependencyChainFor( competitor );

  return !!chain;

  // if( !self._dependsOf )
  // return false;
  //
  // for( let c = 0 ; c < self._dependsOf.length ; c++ )
  // {
  //   let cor = self._dependsOf[ c ];
  //   if( cor === competitor )
  //   return true;
  //   if( _.consequenceIs( cor ) )
  //   if( cor.doesDependOf( competitor ) )
  //   return true;
  // }
  //
  // return false;
}

//

function assertNoDeadLockWith( competitor )
{
  let self = this;

  _.assert( _.consequenceIs( competitor ) );

  let result = self.doesDependOf( competitor );

  if( !result )
  return !result;

  return true;
  // logger.log( self.deadLockReport( competitor ) );
  //
  // let msg = 'Dead lock!\n';
  //
  // _.assert( !result, msg );
  //
  // return result;
}

//

function deadLockReport( competitor )
{
  let self = this;

  _.assert( _.consequenceIs( competitor ) );

  let chain = self.dependencyChainFor( competitor );

  if( !chain )
  return '';

  let log = '';

  debugger;
  chain.forEach( ( con ) =>
  {
    if( log )
    log += '\n';
    log += con.qualifiedName ;
  });

  return log;
}

//

function isEmpty()
{
  let self = this;
  if( self.resourcesCount() )
  return false;
  if( self.competitorsCount() )
  return false;
  return true;
}

//

/**
 * Clears all resources and corespondents of wConsequence.
 * @method cancel
 * @module Tools/base/Consequence
 * @namespace Tools
 * @class wConsequence
 */

function cancel()
{
  let self = this;
  _.assert( arguments.length === 0, 'Expects no arguments' );

  self.competitorsCancel();
  self.resourcesCancel();

  return self;
}

// --
// competitors
// --

function competitorOwn( competitorRoutine )
{
  let self = this;

  _.assert( _.routineIs( competitorRoutine ) );

  for( let c = 0 ; c < self._competitorsEarly.length ; c++ )
  {
    let competitor = self._competitorsEarly[ c ];
    if( competitor.competitorRoutine === competitorRoutine )
    return competitor;
  }

  for( let c = 0 ; c < self._competitorsLate.length ; c++ )
  {
    let competitor = self._competitorsLate[ c ];
    if( competitor.competitorRoutine === competitorRoutine )
    return competitor;
  }

  return false;
}

//

function competitorHas( competitorRoutine )
{
  let self = this;

  _.assert( _.routineIs( competitorRoutine ) );

  for( let c = 0 ; c < self._competitorsEarly.length ; c++ )
  {
    let competitor = self._competitorsEarly[ c ];
    if( competitor.competitorRoutine === competitorRoutine )
    return competitor;
    if( _.consequenceIs( competitor ) )
    if( competitor.competitorHas( competitorRoutine ) )
    return competitor;
  }

  for( let c = 0 ; c < self._competitorsLate.length ; c++ )
  {
    let competitor = self._competitorsLate[ c ];
    if( competitor.competitorRoutine === competitorRoutine )
    return competitor;
    if( _.consequenceIs( competitor ) )
    if( competitor.competitorHas( competitorRoutine ) )
    return competitor;
  }

  return false;
}

//

function competitorsCount()
{
  let self = this;
  _.assert( arguments.length === 0, 'Expects no arguments' );
  return self._competitorsEarly.length + self._competitorsLate.length;
}

//

/**
 * The _corespondentMap object
 * @typedef {Object} _corespondentMap
 * @property {Function|wConsequence} competitor function or wConsequence instance, that accepts resolved resources from
 * resources queue.
 * @property {boolean} keeping determines if corespondent pass his result back into resources queue.
 * @property {boolean} tapping determines if corespondent return accepted resource back into  resources queue.
 * @property {boolean} errorOnly turn on corespondent only if resource represent error;
 * @property {boolean} argumentOnly turn on corespondent only if resource represent no error;
 * @property {boolean} debug enables debugging.
 * @property {string} id corespondent id.
 * @class wConsequence
 * @namespace Tools
 * @module Tools/base/Consequence
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

   con.tap( corespondent1 ).finally( corespondent2 ).finallyGive( corespondent3 );

   let corespondents = con.competitorsEarlyGet();

   console.log( corespondents );

 * @returns {_corespondentMap}
 * @method competitorsEarlyGet
 * @module Tools/base/Consequence
 * @namespace Tools
 * @class wConsequence
 */

function competitorsEarlyGet()
{
  let self = this;
  _.assert( arguments.length === 0, 'Expects no arguments' );
  return self._competitorsEarly;
}

//

function competitorsLateGet()
{
  let self = this;
  _.assert( arguments.length === 0, 'Expects no arguments' );
  return self._competitorsLate;
}

//

function competitorsGet()
{
  let self = this;
  let r = [];
  _.assert( arguments.length === 0, 'Expects no arguments' );
  if( self._competitorsEarly.length )
  _.arrayAppendArray( r, self._competitorsEarly );
  if( self._competitorsLate.length )
  _.arrayAppendArray( r, self._competitorsLate );
  return r;
}

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

 con.finallyGive( corespondent1 ).finallyGive( corespondent2 );
 con.competitorsCancel();

 con.finallyGive( corespondent3 );
 con.take( 'bar' );

 // prints
 // corespondent1 value: bar
 * @param {Routine} [competitor]
 * @method competitorsCancel
 * @module Tools/base/Consequence
 * @namespace Tools
 * @class wConsequence
 */

function competitorsCancel( competitorRoutine )
{
  let self = this;
  let r = 0;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( arguments.length === 0 || _.routineIs( competitorRoutine ) );

  if( arguments.length === 0 )
  {

    for( let c = self._competitorsEarly.length - 1 ; c >= 0 ; c-- )
    {
      let competitorDescriptor = self._competitorsEarly[ c ];
      if( competitorDescriptor.procedure )
      competitorDescriptor.procedure.end();
      self._competitorsEarly.splice( c, 1 );
      r += 1;
    }

    for( let c = self._competitorsLate.length - 1 ; c >= 0 ; c-- )
    {
      let competitorDescriptor = self._competitorsLate[ c ];
      if( competitorDescriptor.procedure )
      competitorDescriptor.procedure.end();
      self._competitorsLate.splice( c, 1 );
      r += 1;
    }

  }
  else
  {

    let found = _.longLeft( self._competitorsEarly, competitorRoutine, ( c ) => c.competitorRoutine, ( c ) => c );
    while( found.element )
    {
      _.assert( found.element.competitorRoutine === competitorRoutine );
      if( found.element.procedure )
      found.element.procedure.end();
      self._competitorsEarly.splice( found.index, 1 )
      found = _.longLeft( self._competitorsEarly, competitorRoutine, ( c ) => c.competitorRoutine, ( c ) => c );
      r += 1;
    }

    found = _.longLeft( self._competitorsLate, competitorRoutine, ( c ) => c.competitorRoutine, ( c ) => c );
    while( found.element )
    {
      _.assert( found.element.competitorRoutine === competitorRoutine );
      if( found.element.procedure )
      found.element.procedure.end();
      self._competitorsLate.splice( found.index, 1 )
      found = _.longLeft( self._competitorsLate, competitorRoutine, ( c ) => c.competitorRoutine, ( c ) => c );
      r += 1;
    }

    _.assert( r > 0, `Found no competitor ${competitorRoutine.name}` );

  }

  return self;
}

//

function argumentsCount()
{
  let self = this;
  return self._resources.filter( ( e ) => e.argument !== undefined ).length;
}

//

function errorsCount()
{
  let self = this;
  return self._resources.filter( ( e ) => e.error !== undefined ).length;
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
 * @module Tools/base/Consequence
 * @namespace Tools
 * @class wConsequence
 */

function resourcesCount()
{
  let self = this;
  return self._resources.length;
}

//
//

/**
 * The internal wConsequence view of resource.
 * @typedef {Object} _resourceObject
 * @property {*} error error value
 * @property {*} argument resolved value
 * @class wConsequence
 * @namespace Tools
 * @module Tools/base/Consequence
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
 * @module Tools/base/Consequence
 * @namespace Tools
 * @class wConsequence
 */

function resourcesGet( index )
{
  let self = this;
  _.assert( arguments.length === 0 || arguments.length === 1 )
  _.assert( index === undefined || _.numberIs( index ) );
  if( index !== undefined )
  return self._resources[ index ];
  else
  return self._resources;
}

//

function argumentsGet( index )
{
  let self = this;
  _.assert( arguments.length === 0 || arguments.length === 1 )
  _.assert( index === undefined || _.numberIs( index ) );
  if( index !== undefined )
  return self._resources[ index ].argument;
  else
  return _.filter( self._resources, ( r ) => r.argument ? r.argument : undefined );
}

//

function errorsGet( index )
{
  let self = this;
  _.assert( arguments.length === 0 || arguments.length === 1 )
  _.assert( index === undefined || _.numberIs( index ) );
  if( index !== undefined )
  return self._resources[ index ].error;
  else
  return _.filter( self._resources, ( r ) => r.error ? r.error : undefined );
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
 * @module Tools/base/Consequence
 * @namespace Tools
 * @class wConsequence
 */

function resourcesCancel( arg )
{
  let self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( arguments.length === 0 )
  {
    self._resources.splice( 0, self._resources.length );
  }
  else
  {
    throw _.err( 'not tested' );
    _.arrayRemoveElement( self._resources, arg );
  }

}

// --
// procedure
// --

function procedure( arg )
{
  let self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( self._procedure )
  return self._procedure;

  if( self._procedure === false )
  return self._procedure;

  if( _.routineIs( arg ) )
  arg = arg();

  if( _.procedureIs( arg ) )
  {
    self._procedure = arg;
    return arg;
  }
  else if( _.numberIs( arg ) )
  {
    self._procedure = _.Procedure({ _stack : arg });
  }
  else if( _.strIs( arg ) )
  {
    self._procedure = _.Procedure({ _name : arg, _stack : 2 });
  }
  else if( _.mapIs( arg ) )
  {
    _.assert( arg._stack !== undefined );
    self._procedure = _.Procedure( arg );
  }
  else _.assert( 0 );

  return self._procedure;
}

//

function procedureDetach()
{
  let self = this;

  _.assert( arguments.length === 0, 'Expects no arguments' );

  let procedure = self._procedure;

  if( self._procedure )
  self._procedure = null;

  return procedure;
}

// --
// exporter
// --

function _exportString( o )
{
  let self = this;
  let result = '';

  _.assertRoutineOptions( _exportString, arguments );

  if( o.verbosity >= 2 )
  {
    result += self.qualifiedName;

    // let names = _.select( self.competitorsEarlyGet(), '*/tag' );
    // if( self.id )
    // result += '\n  id : ' + self.id;

    result += '\n  argument resources : ' + self.argumentsCount();
    result += '\n  error resources : ' + self.errorsCount();
    result += '\n  early competitors : ' + self.competitorsEarlyGet().length;
    result += '\n  late competitors : ' + self.competitorsLateGet().length;
    // result += '\n  AsyncCompetitorHanding : ' + self.AsyncCompetitorHanding;
    // result += '\n  AsyncResourceAdding : ' + self.AsyncResourceAdding;

  }
  else
  {
    if( o.verbosity >= 1 )
    result += self.qualifiedName;
    result += ' ' + self.resourcesCount() + ' / ' + self.competitorsCount();
  }

  return result;
}

_exportString.defaults =
{
  verbosity : 1,
}

//

function exportString( o )
{
  let self = this;
  o = _.routineOptions( exportString, arguments );
  return self._exportString( o );
}

_.routineExtend( exportString, _exportString );

//

function _callbacksInfoLog()
{
  let self = this;

  self._competitorsEarly.forEach( ( competitor ) =>
  {
    console.log( competitor.competitorRoutine );
  });

  self._competitorsLate.forEach( ( competitor ) =>
  {
    console.log( competitor.competitorRoutine );
  });

  return self.exportString();
}

//

/**
 * Serializes current wConsequence instance.
 * @example
 * function corespondent1(err, val)
   {
     console.log( 'corespondent1 value: ' + val );
   };

   let con = _.Consequence();
   con.finallyGive( corespondent1 );

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
 * @module Tools/base/Consequence
 * @namespace Tools
 * @class wConsequence
 */

function toStr( o )
{
  let self = this;
  return self.exportString( o );
}

//

function toString( o )
{
  let self = this;
  return self.exportString( o );
}

//

function _inspectCustom()
{
  let self = this;
  return self.exportString();
}

//

function _toPrimitive()
{
  let self = this;
  return self.exportString();
}

//

// /**
//  * Can use as competitor. If `err` is not null, throws exception based on `err`. Returns `arg`.
//  * @callback wConsequence._onDebug
//  * @param {*} err Error object, or any other type, that represent or describe an error reason. If during resolving
//  value no exception occurred, it will be set to null;
//  * @param {*} arg resolved by wConsequence value;
//  * @returns {*}
//  * @module Tools/base/Consequence
// * @namespace Tools
// * @class wConsequence
//  */
//
// function _onDebug( err, arg )
// {
//   debugger;
//   if( err )
//   throw _.err( err );
//   return arg;
// }

// --
// accessor
// --

function AsyncModeSet( mode )
{
  let constr = this.Self;
  _.assert( constr.AsyncCompetitorHanding !== undefined );
  _.assert( mode.length === 2 );
  _.assert( arguments.length === 1, 'Expects single argument' );
  constr.AsyncCompetitorHanding = !!mode[ 0 ];
  constr.AsyncResourceAdding = !!mode[ 1 ];
  return [ constr.AsyncCompetitorHanding, constr.AsyncResourceAdding ];
}

//

function AsyncModeGet( mode )
{
  let constr = this.Self;
  _.assert( constr.AsyncCompetitorHanding !== undefined );
  return [ constr.AsyncCompetitorHanding, constr.AsyncResourceAdding ];
}

//

function qualifiedNameGet()
{
  let result = this.shortName;
  if( this.tag )
  result = result + '::' + this.tag;
  else
  result = result + '::';
  return result;
}

//

function _arrayGetter_functor( name )
{
  let symbol = Symbol.for( name );
  return function _get()
  {
    var self = this;
    if( self[ symbol ] === undefined )
    self[ symbol ] = [];
    return self[ symbol ];
  }
}

//

function _defGetter_functor( name, def )
{
  let symbol = Symbol.for( name );
  return function _get()
  {
    var self = this;
    if( self[ symbol ] === undefined )
    return def;
    return self[ symbol ];
  }
}

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

// --
// static
// --

/* xxx : remove second argument */
function From( src, timeLimit )
{
  let con = src;

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assert( timeLimit === undefined || _.numberIs( timeLimit ) );

  if( _.promiseLike( src ) )
  {
    con = new Self();
    let onFulfilled = ( arg ) => { arg === undefined ? con.take( null ) : con.take( arg ); }
    let onRejected = ( err ) => { con.error( err ); }
    src.then( onFulfilled, onRejected );
  }

  if( _.consequenceIs( con ) )
  {
    // if( timeLimit !== undefined )
    // {
    //   return con.orKeepingSplit( _.time.outError( timeLimit ) );
    // }
    // debugger;
    // con.tag = 'aaa';
    let con2 = con;
    if( timeLimit !== undefined )
    con2 = new _.Consequence().take( null ).timeLimitThrowing( timeLimit, con );
    // con.tag = 'bbb';
    return con2;
  }

  if( _.errIs( src ) )
  return new Self().error( src );
  return new Self().take( src );
}

//

function FromCalling( src )
{
  if( !_.consequenceIs( src ) && _.routineIs( src ) )
  src = src();
  src = this.From( src );
  return src;
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

   con.finallyGive( showResult );

   _.Consequence.take( con, 'hello world' );
   // prints: handleGot1 value: hello world
 * @param {Function|wConsequence} consequence
 * @param {*} arg argument value
 * @param {*} [error] error value
 * @returns {*}
 * @static
 * @method take
 * @module Tools/base/Consequence
 * @namespace wConsequence
 */

function Take( consequence ) /* xxx : review */
{

  _.assert( arguments.length === 2 || arguments.length === 3, 'Expects two or three arguments' );

  let err, finallyGive;
  if( arguments.length === 2 )
  {
    finallyGive = arguments[ 1 ];
  }
  else if( arguments.length === 3 )
  {
    err = arguments[ 1 ];
    finallyGive = arguments[ 2 ];
  }

  let args = [ finallyGive ];

  return _Take
  ({
    consequence,
    context : undefined,
    error : err,
    args,
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
   * @module Tools/base/Consequence
 * @namespace Tools
 * @class wConsequence
   */

/* zzz : deprecate? */
function _Take( o )
{
  let context;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.objectIs( o ) );
  _.assert( _.arrayLike( o.args ) && o.args.length <= 1, 'not tested' );
  _.assertRoutineOptionsPreservingUndefines( _Take, arguments );

  /* */

  if( _.arrayLike( o.consequence ) )
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

    _.assert( _.arrayLike( o.args ) && o.args.length <= 1 );

    context = o.consequence;

    o.consequence.take( o.error, o.args[ 0 ] );

  }
  else if( _.routineIs( o.consequence ) )
  {

    _.assert( _.arrayLike( o.args ) && o.args.length <= 1 );

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

    con.finallyGive( showResult );

    wConsequence.error( con, 'something wrong' );
  // prints: handleGot1 error: something wrong
* @param {Function|wConsequence} consequence
* @param {*} error error value
* @returns {*}
* @static
* @method error
* @module Tools/base/Consequence
* @namespace wConsequence
*/

function Error( consequence, error )
{

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );

  return _Take
  ({
    consequence,
    context : undefined,
    error,
    args : [],
  });

}

//

function Try( routine )
{

  _.assert( arguments.length === 1 );
  _.assert( _.routineIs( routine ) );

  try
  {
    let r = routine();
    return Self.From( r );
  }
  catch( err )
  {
    err = _.err( err );
    return new Self().error( err );
  }

}

//

/**
 * Can use as competitor. If `err` is not null, throws exception based on `err`. Returns `arg`.
 * @callback PassThru
 * @param {*} err Error object, or any other type, that represent or describe an error reason. If during resolving
 value no exception occurred, it will be set to null;
 * @param {*} arg resolved by wConsequence value;
 * @returns {*}
 * @class wConsequence
 * @namespace Tools
 * @module Tools/base/Consequence
 */

function FinallyPass( err, arg )
{
  _.assert( err !== undefined || arg !== undefined, 'Argument of take should be something, not undefined' );
  _.assert( err === undefined || arg === undefined, 'Cant take both error and argument, one should be undefined' );
  if( err )
  throw err;
  return arg;
}

//

function ThenPass( err, arg )
{
  _.assert( arg !== undefined, 'Expects non-undefined argument' );
  return arg;
}

//

function CatchPass( err, arg )
{
  _.assert( err !== undefined, 'Expects non-undefined error' );
  throw err;
}

// --
// meta
// --

function _metaDefine( how, key, value )
{
  let opts =
  {
    enumerable : false,
    configurable : false,
  }

  if( how === 'get' )
  {
    opts.get = value;
    Object.defineProperty( Self.prototype, key, opts );
  }
  else if( how === 'field' )
  {
    opts.value = value;
    Object.defineProperty( Self.prototype, key, opts );
  }
  else if( how === 'static' )
  {
    opts.get = value;
    Object.defineProperty( Self, key, opts );
    Object.defineProperty( Self.prototype, key, opts );
  }
  else _.assert( 0 );

}

// --
// experimental
// --

// function FunctionWithin( consequence )
// {
//   let routine = this;
//   let args;
//   let context;
//
//   _.assert( arguments.length === 1, 'Expects single argument' );
//   _.assert( _.consequenceIs( consequence ) );
//
//   consequence.finally( function( err, arg )
//   {
//
//     return routine.apply( context, args );
//
//   });
//
//   return function()
//   {
//     context = this;
//     args = arguments;
//     return consequence;
//   }
//
// }
//
// //
//
// function FunctionThereafter()
// {
//   let con = new Self();
//   let routine = this;
//   let args = arguments
//
//   con.finally( function( err, arg )
//   {
//
//     return routine.apply( null, args );
//
//   });
//
//   return con;
// }

//

// if( 0 )
// {
//   Function.prototype.within = FunctionWithin;
//   Function.prototype.thereafter = FunctionThereafter;
// }

// //
//
// function experimentThereafter()
// {
//   debugger;
//
//   function f()
//   {
//     debugger;
//     console.log( 'done2' );
//   }
//
//   _.time.out( 5000, console.log.thereafter( 'done' ) );
//   _.time.out( 5000, f.thereafter() );
//
//   debugger;
//
// }
//
// //
//
// function experimentWithin()
// {
//
//   debugger;
//   let con = _.time.out( 30000 );
//   console.log.within( con ).call( console, 'done' );
//   con.finally( function()
//   {
//
//     debugger;
//     console.log( 'done2' );
//
//   });
//
// }
//
// //
//
// function experimentCall()
// {
//
//   let con = new Self();
//   con( 123 );
//   con.finally( function( err, arg )
//   {
//
//     console.log( 'finallyGive :', arg );
//
//   });
//
//   debugger;
//
// }

//

function Now()
{
  _.assert( arguments.length === 0, 'Expects no arguments' );
  return new _.Consequence().take( null );
}

//

function After( resource )
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
// function Before( consequence )
// {
//   _.assert( arguments.length === 1 );
//   _.assert( arguments.length === 0 || consequence !== undefined );
//   _.assert( 0, 'not tested' );
//
//   let result;
//   if( _.consequenceLike( consequence ) )
//   {
//     consequence = _.Consequence.From( consequence );
//   }
//
//   let result = _.Consequence();
//   result.lateFinally( consequence );
//
//   return result;
// }

/**
 * @typedef {Object} Fields
 * @property {Array} [_competitorsEarly=[]] Queue of competitor that are penging for resource.
 * @property {Array} [_resources=[]] Queue of messages that are penging for competitor.
 * @property {wProcedure} [_procedure=null] Instance of wProcedure.
 * @property {String} tag
 * @property {Number} id Id of current instance
 * @property {Array} [_dependsOf=[]]
 * @property {Number} [capacity=0] Maximal number of resources. Unlimited by default.
 * @class wConsequence
 * @namespace Tools
 * @module Tools/base/Consequence
*/

// --
// meta
// --

function _Extend( dstGlobal, srcGlobal )
{
  _.assert( _.routineIs( srcGlobal.wConsequence.After ) );
  _.assert( _.mapIs( srcGlobal.wConsequence.Tools ) );
  _.mapExtend( dstGlobal.wTools, srcGlobal.wConsequence.Tools );
  let Self = srcGlobal.wConsequence;
  dstGlobal.wTools[ Self.shortName ] = Self;
  if( typeof module !== 'undefined' )
  module[ 'exports' ] = Self;
  return;
}

// --
// relations
// --

let Tools =
{
  now : Now,
  async : Now,
  after : After,
  // before : Before,
}

let Composes =
{
  capacity : 1,
  _resources : null,
}

let ComposesDebug =
{
  tag : '',
}

if( Config.debug )
_.mapExtend( Composes, ComposesDebug );

let Aggregates =
{
}

let Restricts =
{
  _competitorsEarly : null,
  _competitorsLate : null,
  _procedure : null,
}

let RestrictsDebug =
{
  _dependsOf : null,
}

if( Config.debug )
_.mapExtend( Restricts, RestrictsDebug );

let Medials =
{
  tag : '',
}

let Statics =
{

  Now,
  Async : Now,
  After,
  From, /* qqq : cover please */
  FromCalling,
  Take,
  Error,
  ErrNoReturn,
  Try, /* qqq : cover please */

  AndTake_,
  AndKeep_,
  And_ : AndKeep_,

  OrTake,
  OrKeep,
  Or : OrKeep,

  FinallyPass,
  ThenPass,
  CatchPass,

  AsyncModeSet,
  AsyncModeGet,

  Tools,
  KindOfResource,

  _Extend,

  //

  UncaughtTimeOut : 100,
  Diagnostics : 1,
  // Stacking : 0,
  AsyncCompetitorHanding : 0,
  AsyncResourceAdding : 0,

  shortName : 'Consequence',

}

let Forbids =
{
  every : 'every',
  mutex : 'mutex',
  mode : 'mode',
  resourcesCounter : 'resourcesCounter',
  _competitor : '_competitor',
  _competitorPersistent : '_competitorPersistent',
  id : 'id',
  dependsOf : 'dependsOf',
}

let Accessors =
{
  competitorNext : 'competitorNext',
  _competitorsEarly : { get : _arrayGetter_functor( '_competitorsEarly' ) },
  _competitorsLate : { get : _arrayGetter_functor( '_competitorsLate' ) },
  _resources : { get : _arrayGetter_functor( '_resources' ) },
  _procedure : { get : _defGetter_functor( '_procedure', null ) },
  capacity : { get : _defGetter_functor( 'capacity', 1 ) },
}

let DebugAccessors =
{
  tag : { get : _defGetter_functor( 'tag', null ) },
  _dependsOf : { get : _arrayGetter_functor( '_dependsOf' ) },
}

if( Config.debug )
_.mapExtend( Accessors, DebugAccessors );

// --
// declare
// --

let Extension =
{

  init,
  is,

  // basic

  finallyGive,
  give : finallyGive,
  finallyKeep,
  finally : finallyKeep,

  thenGive,
  ifNoErrorGot : thenGive,
  got : thenGive,
  thenKeep,
  then : thenKeep,
  ifNoErrorThen : thenKeep,

  catchGive,
  catchKeep,
  catch : catchKeep,
  ifErrorThen : catchGive,

  // to promise // qqq : cover please

  _promiseThen,
  _promise,
  finallyPromiseGive,
  finallyPromiseKeep,
  promise : finallyPromiseKeep,
  thenPromiseGive,
  thenPromiseKeep,
  catchPromiseGive,
  catchPromiseKeep,

  // deasync // qqq : cover please

  _deasync,
  deasync,

  // advanced

  _first,
  first,

  split : splitKeep,
  splitKeep,
  splitGive,
  tap,
  catchLog,
  catchBrief,
  syncMaybe,
  sync,

  // experimental

  _competitorFinally,
  wait,
  participateGive,
  participateKeep,

  // etc

  ErrNoReturn,

  // put

  _put,
  put : thenPutGive,
  putGive,
  putKeep,
  thenPutGive,
  thenPutKeep,

  // time

  _timeOut,
  finallyTimeOut,
  thenTimeOut,
  exceptTimeOut,
  timeOut : finallyTimeOut,

  _timeLimit,
  timeLimit,
  timeLimitThrowing,
  timeLimitSplit,
  timeLimitThrowingSplit,

  // and

  _and,
  andTake,
  andKeep,
  andKeepAccumulative, /* qqq : cover routine andKeepAccumulative */
  // and : andKeepAccumulative,

  alsoKeep,
  alsoTake,
  also : alsoKeep,

  AndTake_,
  AndKeep_,
  And_ : AndKeep_,

  // or

  _or,
  afterOrTaking,
  afterOrKeeping,
  orKeepingSplit,
  orTaking,
  orKeeping,
  or : orKeeping, /* xxx : introduce static routine Or */

  OrTake,
  OrKeep,
  Or : OrKeep,

  // adapter

  tolerantCallback,

  // resource

  takeLater,
  takeSoon,
  takeAll,
  take,
  error,
  __take,
  __onTake,

  // handling mechanism

  __handleError,
  __handleResourceSoon,
  __handleResourceNow,
  _competitorAppend,

  // accounter

  doesDependOf,
  dependencyChainFor,
  assertNoDeadLockWith,
  deadLockReport,

  isEmpty,
  cancel,

  // competitor

  competitorOwn,
  competitorHas,
  competitorsCount,
  competitorsEarlyGet,
  competitorsLateGet,
  competitorsGet,
  competitorsCancel,

  // resource

  argumentsCount,
  errorsCount,
  resourcesCount,
  resourcesGet,
  argumentsGet,
  errorsGet,
  resourcesCancel,

  // procedure

  procedure,
  procedureDetach,

  // exporter

  _exportString,
  exportString,
  _callbacksInfoLog,
  toStr,
  toString,
  _inspectCustom,
  _toPrimitive,

  // accessor

  AsyncModeSet,
  AsyncModeGet,
  qualifiedNameGet,

  __call__,

  // relations

  Composes,
  Aggregates,
  Restricts,
  Medials,
  Forbids,
  Accessors,

}

//

/* statics should be supplemental not extending */

let Supplement =
{
  Statics,
}

//

_.classDeclare
({
  cls : wConsequence,
  parent : null,
  extend : Extension,
  supplement : Supplement,
  usingOriginalPrototype : 1,
});

_.Copyable.mixin( wConsequence ); /* zzz : remove the mixin, maybe */

_metaDefine( 'field', Symbol.toPrimitive, _toPrimitive );
_metaDefine( 'field', Symbol.for( 'nodejs.util.inspect.custom' ), _inspectCustom );

_.mapExtend( _, Tools );
_.mapExtend( _realGlobal_.wTools, Tools );

//

_.assert( _.routineIs( wConsequence.prototype.FinallyPass ) );
_.assert( _.routineIs( wConsequence.FinallyPass ) );
_.assert( _.objectIs( wConsequence.prototype.KindOfResource ) );
_.assert( _.objectIs( wConsequence.KindOfResource ) );
_.assert( _.strDefined( wConsequence.name ) );
_.assert( _.strDefined( wConsequence.shortName ) );
_.assert( _.routineIs( wConsequence.prototype.take ) );

_.assert( _.routineIs( wConsequenceProxy.prototype.FinallyPass ) );
_.assert( _.routineIs( wConsequenceProxy.FinallyPass ) );
_.assert( _.objectIs( wConsequenceProxy.prototype.KindOfResource ) );
_.assert( _.objectIs( wConsequenceProxy.KindOfResource ) );
_.assert( _.strDefined( wConsequenceProxy.name ) );
_.assert( _.strDefined( wConsequenceProxy.shortName ) );
_.assert( _.routineIs( wConsequenceProxy.prototype.take ) );

_.assert( wConsequenceProxy.shortName === 'Consequence' );

_.assert( !!Self.FieldsOfRelationsGroupsGet );
_.assert( !!Self.prototype.FieldsOfRelationsGroupsGet );
_.assert( !!Self.FieldsOfRelationsGroups );
_.assert( !!Self.prototype.FieldsOfRelationsGroups );
_.assert( _.mapKeys( Self.FieldsOfRelationsGroups ).length );

_.assert( _.mapIs( Self.KindOfResource ) );
_.assert( _.mapIs( Self.prototype.KindOfResource ) );
_.assert( Self.AsyncCompetitorHanding === 0 );
_.assert( Self.prototype.AsyncCompetitorHanding === 0 );

_global_[ Self.name ] = _[ Self.shortName ] = Self;
if( !_global_.__GLOBAL_PRIVATE_CONSEQUENCE__ )
_realGlobal_[ Self.name ] = Self;

// --
// export
// --

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();
