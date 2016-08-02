( function _Consequence_s_() {

'use strict';

  /**
   * @file Consequence.s - Advanced synchronization mechanism. wConsequence is able to solve any asynchronous problem
     replacing and including functionality of many other mechanisms, such as: Callback, Event, Signal, Mutex, Semaphore,
     Async, Promise.
   */

/*

 !!! move promise / event property from object to correspondent

 !!! test difference :

    if( errs.length )
    return new wConsequence().error( errs[ 0 ] );

    if( errs.length )
    throw _.err( errs[ 0 ] );


*/

if( typeof module !== 'undefined' )
{

  try
  {
    require( '../wTools.s' );
  }
  catch( err )
  {
    require( 'wTools' );
  }

  try
  {
    require( '../mixin/Copyable.s' );
  }
  catch( err )
  {
    require( 'wCopyable' );
  }

  try
  {
    require( '../component/Proto.s' );
  }
  catch( err )
  {
    require( 'wProto' );
  }

}

//

var _ = wTools;
var Parent = null;

  /**
   * Class wConsequence creates objects that used for asynchronous computations. It represent the queue of results that
   * can computation asynchronously, and has a wide range of tools to implement this process.
   * @class wConsequence
   */

  /**
   * Function that accepts result of wConsequence value computation. Used as parameter in methods such as got(), then_(),
    etc.
   * @param {*} err Error object, or any other type, that represent or describe an error reason. If during resolving
      value no exception occurred, it will be set to null;
     @param {*} value resolved by wConsequence value;
   * @callback wConsequence~correspondent
   */

  /**
   * Creates instance of wConsequence
   * @example
     var con = new wConsequence();
     con.give( 'hello' ).got( function( err, value) { console.log( value ); } ); // hello

     var con = wConsequence();
     con.got( function( err, value) { console.log( value ); } ).give('world'); // world
   * @param {Object|Function|wConsequence} [options] initialization options
   * @returns {wConsequence}
   * @constructor
   * @see {@link wConsequence}
   */


var Self = function wConsequence( options )
{
  if( !( this instanceof Self ) )
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

//

  /**
   * Initialises instance of wConsequence
   * @param {Object|Function|wConsequence} [options] initialization options
   * @private
   * @method pathCurrent
   * @memberof wConsequence
   */

var init = function init( options )
{
  var self = this;

  if( _.routineIs( options ) )
  options = { all : options };

  _.mapExtendFiltering( _.filter.notAtomicCloningSrcOwn(),self,Composes );

  if( options )
  self.copy( options );

  //_.assert( self.mode === 'promise' || self.mode === 'event' );
  //_.constant( self,{ mode : self.mode } );

  if( self.constructor === Self )
  Object.preventExtensions( self );

}

// --
// mechanics
// --

  /**
   * Method created and appends correspondent object, based on passed options into wConsequence correspondents queue.
   *
   * @param {Object} o options object
   * @param {wConsequence~correspondent|wConsequence} o.onGot correspondent callback
   * @param {Object} [o.context] if defined, it uses as 'this' context in correspondent function.
   * @param {Array<*>|ArrayLike} [o.argument] values, that will be used as binding arguments in correspondent.
   * @param {string} [o.name=null] name for correspondent function
   * @param {boolean} [o.thenning=false] If sets to true, then result of current correspondent will be passed to the next correspondent
      in correspondents queue.
   * @param {boolean} [o.persistent=false] If sets to true, then correspondent will be work as queue listener ( it will be
   * processed every value resolved by wConsequence).
   * @param {boolean} [o.tapping=false] enabled some breakpoints in debug mode;
   * @returns {wConsequence}
   * @private
   * @method _correspondentAppend
   * @memberof wConsequence
   */

var _correspondentAppend = function( o )
{
  var self = this;
  var correspondent = o.correspondent;
  var name = o.name || correspondent ? correspondent.name : null || null;

  _.assert( arguments.length === 1 );
  _.assert( _.routineIs( correspondent ) || correspondent instanceof Self );

  if( _.routineIs( correspondent ) )
  {
    if( o.context !== undefined || o.argument !== undefined )
    correspondent = _.routineJoin( o.context,correspondent,o.argument );
  }
  else
  {
    _.assert( o.context === undefined && o.argument === undefined );
  }

  /* store */

  if( o.persistent )
  self._correspondentPersistent.push
  ({
    onGot : correspondent,
    name : name,
  });
  else
  self._correspondent.push
  ({
    onGot : correspondent,
    thenning : !!o.thenning,
    tapping : !!o.tapping,
    ifError :  !!o.ifError,
    ifNoError : !!o.ifNoError,
    debug : !!o.debug,
    name : name,
  });

  /* got */

  if( self.usingAsyncTaker )
  setTimeout( function()
  {

    if( self._message.length )
    self._handleGot();

  }, 0 );
  else
  {

    if( self._message.length )
    self._handleGot();

  }

  return self;
}

// --
// chainer
// --

  /**
   * Method appends resolved value and error handler to wConsequence correspondents sequence. That handler accept only one
      value or error reason only once, and don't pass result of it computation to next handler (unlike Promise 'then').
      if got() called without argument, an empty handler will be appended.
      After invocation, correspondent will be removed from correspondents queue.
      Returns current wConsequence instance.
   * @example
       var gotHandler1 = function( error, value )
       {
         console.log( 'handler 1: ' + value );
       };

       var gotHandler2 = function( error, value )
       {
         console.log( 'handler 2: ' + value );
       };

       var con1 = new wConsequence();

       con1.got( gotHandler1 );
       con1.give( 'hello' ).give( 'world' );

       // prints only " handler 1: hello ",

       var con2 = new wConsequence();

       con2.got( gotHandler1 ).got( gotHandler2 );
       con2.give( 'foo' );

       // prints only " handler 1: foo "

       var con3 = new wConsequence();

       con3.got( gotHandler1 ).got( gotHandler2 );
       con3.give( 'bar' ).give( 'baz' );

       // prints
       // handler 1: bar
       // handler 2: baz
       //
   * @param {wConsequence~correspondent|wConsequence} [correspondent] callback, that accepts resolved value or exception reason.
   * @returns {wConsequence}
   * @see {@link wConsequence~correspondent} correspondent callback
   * @throws {Error} if passed more than one argument.
   * @method got
   * @memberof wConsequence
   */

var got = function got( correspondent )
{
  var self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( arguments.length === 0 )
  {
    correspondent = function(){};
  }

  return self._correspondentAppend
  ({
    correspondent : correspondent,
    context : arguments[ 1 ],
    argument : arguments[ 2 ],
    thenning : false,
  });

}

//

  /**
   * Works like got() method, but adds correspondent to queue only if function with same name not exist in queue yet.
   * Note: this is experimental tool.
   * @example
   *

     function gotHandler1( error, value )
     {
       console.log( 'handler 1: ' + value );
     };

     function gotHandler2( error, value )
     {
       console.log( 'handler 2: ' + value );
     };

     var con1 = new wConsequence();

     con1.gotOnce( gotHandler1 ).gotOnce( gotHandler1 ).gotOnce( gotHandler2 );
     con1.give( 'foo' ).give( 'bar' );

     // logs:
     // handler 1: foo
     // handler 2: bar
     // correspondent gotHandler1 has ben invoked only once, because second correspondent was not added to correspondents queue.

     // but:

     var con2 = new wConsequence();

     con2.give( 'foo' ).give( 'bar' ).give('baz');
     con2.gotOnce( gotHandler1 ).gotOnce( gotHandler1 ).gotOnce( gotHandler2 );

     // logs:
     // handler 1: foo
     // handler 1: bar
     // handler 2: baz
     // in this case first gotHandler1 has been removed from correspondents queue immediately after the invocation, so adding
     // second gotHandler1 is legitimate.

   *
   * @param {wConsequence~correspondent|wConsequence} correspondent callback, that accepts resolved value or exception reason.
   * @returns {wConsequence}
   * @throws {Error} if passed more than one argument.
   * @throws {Error} if correspondent.name is not string.
   * @see {@link wConsequence~correspondent} correspondent callback
   * @see {@link wConsequence#got} got method
   * @method gotOnce
   * @memberof wConsequence
   */

var gotOnce = function gotOnce( correspondent )
{
  var self = this;
  var key = correspondent.name;

  _.assert( _.strIsNotEmpty( key ) );
  _.assert( arguments.length === 1 );

  var i = _.arrayLeftIndexOf( self._correspondent,key,function( a )
  {
    return a.name;
  });

  if( i >= 0 )
  return self;

  return self._correspondentAppend
  ({
    correspondent : correspondent,
    context : arguments[ 1 ],
    argument : arguments[ 2 ],
    thenning : false,
  });
}

//

  /**
   * Method accepts handler for resolved value/error. This handler method then_ adds to wConsequence correspondents sequence.
      After processing accepted value, correspondent return value will be pass to the next handler in correspondents queue.
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

     var con1 = new wConsequence();

     con1.then_( gotHandler1 ).then_( gotHandler1 ).got(gotHandler3);
     con1.give( 4 ).give( 10 );

     // prints:
     // handler 1: 4
     // handler 1: 5
     // handler 3: 6

   * @param {wConsequence~correspondent|wConsequence} correspondent callback, that accepts resolved value or exception reason.
   * @returns {wConsequence}
   * @throws {Error} if missed correspondent.
   * @throws {Error} if passed more than one argument.
   * @see {@link wConsequence~correspondent} correspondent callback
   * @see {@link wConsequence#got} got method
   * @method then_
   * @memberof wConsequence
   */

var then_ = function then_( correspondent )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assert( self instanceof Self )

  return self._correspondentAppend
  ({
    correspondent : correspondent,
    context : arguments[ 1 ],
    argument : arguments[ 2 ],
    thenning : true,
  });
}

//

var thenSealed = function thenSealed( context,correspondent,args )
{
  var self = this;

  _.assert( arguments.length === 2 || arguments.length === 3 );

  if( arguments.length === 2 )
  if( _.arrayLike( arguments[ 1 ] ) )
  {
    args = arguments[ 1 ];
    correspondent = arguments[ 0 ];
    context = undefined;
  }

  var correspondentJoined = _.routineSeal( context,correspondent,args );

  return self._correspondentAppend
  ({
    correspondent : correspondentJoined,
    ifNoError : true,
    thenning : true,
  });

}

//

var thenReportError = function thenReportError( context,correspondent,args )
{
  var self = this;

  _.assert( arguments.length === 0 );

  var correspondent = function reportError( err,data )
  {
    if( err )
    throw _.errLog( err );
    return data;
  }

  return self._correspondentAppend
  ({
    correspondent : correspondent,
    ifError : true,
    thenning : true,
  });

}

//

  /**
   * Works like then_() method, but adds correspondent to queue only if function with same name not exist in queue yet.
   * Note: this is an experimental tool.
   *
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

     function gotHandler3( error, value )
     {
       console.log( 'handler 3: ' + value );
     };

     var con1 = new wConsequence();

     con1.thenOnce( gotHandler1 ).thenOnce( gotHandler1 ).got(gotHandler3);
     con1.give( 4 ).give( 10 );

     // prints
     // handler 1: 4
     // handler 3: 5

   * @param {wConsequence~correspondent|wConsequence} correspondent callback, that accepts resolved value or exception
     reason.
   * @returns {*}
   * @throws {Error} if passed more than one argument.
   * @throws {Error} if correspondent is defined as anonymous function including anonymous function expression.
   * @see {@link wConsequence~correspondent} correspondent callback
   * @see {@link wConsequence#then_} then_ method
   * @see {@link wConsequence#gotOnce} gotOnce method
   * @method thenOnce
   * @memberof wConsequence
   */

var thenOnce = function thenOnce( correspondent )
{
  var self = this;
  var key = correspondent.name;

  _.assert( _.strIsNotEmpty( key ) );
  _.assert( arguments.length === 1 );

  var i = _.arrayLeftIndexOf( self._correspondent,key,function( a )
  {
    return a.name;
  });

  if( i >= 0 )
  {
    debugger;
    return self;
  }

  return self._correspondentAppend
  ({
    correspondent : correspondent,
    context : arguments[ 1 ],
    argument : arguments[ 2 ],
    thenning : true,
  });
}

//

  /**
   * Returns new wConsequence instance. If on cloning moment current wConsequence has unhandled resolved values in queue
     the first of them would be handled by new wConsequence. Else pass accepted
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

     var con1 = new wConsequence();
     con1.give(1).give(2).give(3);
     var con2 = con1.thenClone();
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
   * @method thenClone
   * @memberof wConsequence
   */

var thenClone = function thenClone()
{
  var self = this;

  _.assert( arguments.length === 0 );

  var result = new wConsequence();
  self.then_( result );

  return result;
}

//

  /**
   * Works like got() method, but value that accepts correspondent, passes to the next taker in takers queue without
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

     var con1 = new wConsequence();
     con1.give(1).give(4);

     // prints:
     // handler 1: 1
     // handler 2: 1
     // handler 3: 4

   * @param {wConsequence~correspondent|wConsequence} correspondent callback, that accepts resolved value or exception
     reason.
   * @returns {wConsequence}
   * @throws {Error} if passed more than one arguments
   * @see {@link wConsequence#got} got method
   * @method tap
   * @memberof wConsequence
   */

var tap = function tap( correspondent )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assert( self instanceof Self )

  return self._correspondentAppend
  ({
    correspondent : correspondent,
    context : undefined,
    argument : arguments[ 2 ],
    thenning : true,
    tapping : true,
  });

}

//

  /**
   * Method pushed `correspondent` callback into wConsequence correspondents queue. That callback will
     trigger only in that case if accepted error parameter will be null. Else accepted error will be passed to the next
     correspondent in queue. After handling accepted value, correspondent pass result to the next handler, like then_
     method.
   * @returns {wConsequence}
   * @throws {Error} if passed more than one arguments
   * @see {@link wConsequence#got} then_ method
   * @method ifErrorThen
   * @memberof wConsequence
   */

var ifNoErrorThen = function()
{

  _.assert( arguments.length === 1 );
  _.assert( this instanceof Self )
  _.assert( arguments.length <= 3 );

  return this._correspondentAppend
  ({
    //correspondent : Self.ifNoErrorThen( arguments[ 0 ] ),
    correspondent : arguments[ 0 ],
    context : arguments[ 1 ],
    argument : arguments[ 2 ],
    thenning : true,
    ifNoError : true,
  });

}

//

var ifNoErrorThenClass = function()
{

  _.assert( arguments.length === 1 );
  _.assert( this === Self );

  var onEnd = arguments[ 0 ];
  _.assert( arguments.length === 1 );
  _.assert( _.routineIs( onEnd ) );

  return function ifNoErrorThen( err,data )
  {

    _.assert( arguments.length === 2 );

    if( !err )
    {
      return onEnd( err,data );
    }
    else
    {
      return wConsequence().error( err );
    }

  }

}

//

var passThruClass = function passThru( err,data )
{
  if( err )
  throw _.err( err );
  return data;
}

//

  /**
   * ifErrorThen method pushed `correspondent` callback into wConsequence correspondents queue. That callback will
     trigger only in that case if accepted error parameter will be defined and not null. Else accepted parameters will
     be passed to the next correspondent in queue.
   * @example
   *
     function gotHandler1( error, value )
     {
       console.log( 'handler 1: ' + value );
       value++;
       return value;
     }

     function gotHandler3( error, value )
     {
       console.log( 'handler 3 err: ' + error );
       console.log( 'handler 3 val: ' + value );
     }

     var con2 = new wConsequence();

     con2._giveWithError( 'error msg', 8 ).give( 14 );
     con2.ifErrorThen( gotHandler3 ).got( gotHandler1 );

     // prints:
     // handler 3 err: error msg
     // handler 3 val: 8
     // handler 1: 14

   * @param {wConsequence~correspondent|wConsequence} correspondent callback, that accepts exception  reason and value .
   * @returns {wConsequence}
   * @throws {Error} if passed more than one arguments
   * @see {@link wConsequence#got} then_ method
   * @method ifErrorThen
   * @memberof wConsequence
   */

var ifErrorThen = function()
{

  _.assert( arguments.length === 1 );
  _.assert( this instanceof Self );

  return this._correspondentAppend
  ({
    //correspondent : Self.ifErrorThen( arguments[ 0 ] ),
    correspondent : arguments[ 0 ],
    context : arguments[ 1 ],
    argument : arguments[ 2 ],
    thenning : true,
    ifError : true,
  });

}

//

var ifErrorThenClass = function()
{

  _.assert( arguments.length === 1 );
  _.assert( this === Self );

  var onEnd = arguments[ 0 ];
  _.assert( arguments.length === 1 );
  _.assert( _.routineIs( onEnd ) );

  return function ifErrorThen( err,data )
  {

    _.assert( arguments.length === 2 );

    if( err )
    {
      return onEnd( err,data );
    }
    else
    {
      return wConsequence().give( data );
    }

  }

}

//

  /**
   * Using for debugging. Taps into wConsequence correspondents sequence predefined wConsequence correspondent callback, that contains
      'debugger' statement. If correspondent accepts non null `err` parameter, it generate and throw error based on
      `err` value. Else passed accepted `value` parameter to the next handler in correspondents sequence.
   * Note: this is experimental tool.
   * @returns {wConsequence}
   * @throws {Error} If try to call method with any argument.
   * @method thenDebug
   * @memberof wConsequence
   */

var thenDebug = function thenDebug()
{
  var self = this;

  _.assert( arguments.length === 0 );

  return self._correspondentAppend
  ({
    correspondent : _onDebug,
    thenning : true,
  });

}

//

  /**
   * Works like then_, but when correspondent accepts message from messages sequence, execution of correspondent will be
      delayed. The result of correspondent execution will be passed to the handler that is first in correspondent queue
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

     var con = new wConsequence();

     con.thenTimeOut(500, gotHandler1).got( gotHandler2 );
     con.give(90);
     //  prints:
     // handler 1: 90
     // handler 2: 91

   * @param {number} time delay in milliseconds
   * @param {wConsequence~correspondent|wConsequence} correspondent callback, that accepts exception reason and value.
   * @returns {wConsequence}
   * @throws {Error} if missed arguments.
   * @throws {Error} if passed extra arguments.
   * @see {@link wConsequence~then_} then_ method
   * @method thenTimeOut
   * @memberof wConsequence
   */

var thenTimeOut = function thenTimeOut( time,correspondent )
{
  var self = this;

  _.assert( arguments.length === 1 || arguments.length === 2 );
  //_.assert( arguments.length === 1 || _.routineIs( correspondent ),'not implemented' );

  /**/

  if( !correspondent )
  correspondent = Self.passThru;

  /**/

  var _correspondent;
  if( _.routineIs( correspondent ) )
  _correspondent = function __thenTimeOut( err,data )
  {
    return _.timeOut( time,self,correspondent,[ err,data ] );
  }
  else
  _correspondent = function __thenTimeOut( err,data )
  {
    return _.timeOut( time,function()
    {
      correspondent._giveWithError( err,data );
      if( err )
      throw _.err( err );
      return data;
    });
  }

  /**/

  return self._correspondentAppend
  ({
    correspondent : _correspondent,
    context : arguments[ 1 ],
    argument : arguments[ 2 ],
    thenning : true,
    /*debug : true,*/
  });

}

//

  /**
   * Correspondents added by persist method, will be accepted every messages resolved by wConsequence, like an event
      listener. Returns current wConsequence instance.
   * @example
     function gotHandler1( error, value )
     {
       console.log( 'message handler 1: ' + value );
       value++;
       return value;
     }

     function gotHandler2( error, value )
     {
       console.log( 'message handler 2: ' + value );
     }

     var con = new wConsequence();

     var messages = [ 'hello', 'world', 'foo', 'bar', 'baz' ],
     len = messages.length,
     i = 0;

     con.persist( gotHandler1).persist( gotHandler2 );

     for( ; i < len; i++) con.give( messages[i] );

     // prints:
     // message handler 1: hello
     // message handler 2: hello
     // message handler 1: world
     // message handler 2: world
     // message handler 1: foo
     // message handler 2: foo
     // message handler 1: bar
     // message handler 2: bar
     // message handler 1: baz
     // message handler 2: baz

   * @param {wConsequence~correspondent|wConsequence} correspondent callback, that accepts exception reason and value.
   * @returns {wConsequence}
   * @throws {Error} if missed arguments.
   * @throws {Error} if passed extra arguments.
   * @see {@link wConsequence~got} got method
   * @method persist
   * @memberof wConsequence
   */


var persist = function persist( correspondent )
{
  var self = this;

  _.assert( arguments.length === 1 );

  return self._correspondentAppend
  ({
    correspondent : correspondent,
    thenning : false,
    persistent : true,
  });

}

// --
// reverse chainer
// --


  /**
   * Method accepts array of wConsequences object. If current wConsequence instance ready to resolve message, it will be
     wait for all passed wConsequence instances will been resolved, then current wConsequence resolve own message.
     Returns current wConsequence.
   * @example
   *
     var handleGot1 = function(err, val)
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

     var con1 = new wConsequence();
     var con2 = new wConsequence();

     con1.got( function( err, value )
     {
       console.log( 'con1 handler executed with value: ' + value + 'and error: ' + err );
     } );

     con2.got( function( err, value )
     {
       console.log( 'con2 handler executed with value: ' + value + 'and error: ' + err );
     } );

     var conOwner = new  wConsequence();

     conOwner.and( [ con1, con2 ] );

     conOwner.give( 100 );
     conOwner.got( handleGot1 );

     con1.give( 'value1' );
     con2.error( 'ups' );
     // prints
     // con1 handler executed with value: value1and error: null
     // con2 handler executed with value: undefinedand error: ups
     // handleGot1 value: 100

   * @param {wConsequence[]|wConsequence} srcs array of wConsequence
   * @returns {wConsequence}
   * @throws {Error} if missed arguments.
   * @throws {Error} if passed extra arguments.
   * @method and
   * @memberof wConsequence
   */

var and = function and( srcs )
{
  var self = this;
  var got,anyErr;

  _.assert( arguments.length === 1 );

  if( !_.arrayIs( srcs ) )
  srcs = [ srcs ];

  /**/

  var give = function()
  {
    if( anyErr && !got[ 0 ] )
    self.error( anyErr );
    else
    self.give( got[ 0 ],got[ 1 ] );
  }

  /**/

  var count = srcs.length
  var collect = function( err,data )
  {
    count -= 1;
    if( err )
    anyErr = anyErr;
    if( count === 0 && got )
    setTimeout( give,0 );
    if( err )
    throw _.err( err );
    return data;
  }

  /**/

  self.got( function( err,data )
  {
    got = [ err,data ];
    if( count === 0 )
    give();
  });

  /**/

  for( var a = 0 ; a < srcs.length ; a++ )
  {
    var src = srcs[ a ];
    _.assert( _.objectIs( src ) && _.routineIs( src.then_ ) )
    src.then_( collect );
  }

  return self;
}

//

  /**
   * If type of `src` is function, the first method run it on begin, and if the result of `src` invocation is instance of
     wConsequence, the current wConsequence will be wait for it resolving, else method added result to messages sequence
     of the current instance.
   * If `src` is instance of wConsequence, the current wConsequence delegates to it his first corespondent.
   * Returns current wConsequence instance.
   * @example
   * var handleGot1 = function(err, val)
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

     var con = new  wConsequence();

     con.first( function() {
       return 'foo';
     } );

   con.give( 100 );
   con.got( handleGot1 );
   // prints: handleGot1 value: foo
  *
    var handleGot1 = function(err, val)
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

    var con = new  wConsequence();

    con.first( function() {
      return wConsequence().give(3);
    } );

   con.give(100);
   con.got( handleGot1 );
   * @param {wConsequence|Function} src wConsequence or routine.
   * @returns {wConsequence}
   * @throws {Error} if `src` has unexpected type.
   * @method first
   * @memberof wConsequence
   */

var first = function first( src )
{
  var self = this;

/*
  if( onReady )
  con.first( onReady );
  else
  con.give();
*/

  if( _.routineIs( src ) )
  {
    var result;

    try
    {
      result = src();
    }
    catch( err )
    {
      result = self._handleError( err );
    }

    if( result instanceof wConsequence )
    result.then_( self );
    else
    self.give( result );
  }
  else if( src instanceof wConsequence )
  {
    src.then_( self );
    src.give();
  }
  else throw _.err( 'unexpected' );

  return self;
}

// --
// messager
// --

  /**
   * Method pushes `message` into wConsequence messages queue.
   * Method also can accept two parameters: error, and
   * Returns current wConsequence instance.
   * @example
   * var gotHandler1 = function( error, value )
     {
       console.log( 'handler 1: ' + value );
     };

     var con1 = new wConsequence();

     con1.got( gotHandler1 );
     con1.give( 'hello' );

     // prints " handler 1: hello ",
   * @param {*} [message] Resolved value
   * @returns {wConsequence} consequence current wConsequence instance.
   * @throws {Error} if passed extra parameters.
   * @method give
   * @memberof wConsequence
   */

var give = function give( message )
{
  var self = this;
  _.assert( arguments.length === 2 || arguments.length === 1 || arguments.length === 0, 'expects 0, 1 or 2 arguments, got ' + arguments.length );
  if( arguments.length === 2 )
  return self._giveWithError( arguments[ 0 ],arguments[ 1 ] );
  else
  return self._giveWithError( null,message );
}

//

  /**
   * Using for adds to message queue error reason, that using for informing corespondent that will handle it, about
   * exception
   * @example
     var showResult = function(err, val)
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

     var con = new  wConsequence();

     var divade = function( x, y )
     {
       var result;
       if( y!== 0 )
       {
         result = x / y;
         con.give(result);
       }
       else
       {
         con.error( 'divide by zero' );
       }
     }

     con.got( showResult );
     divade( 3, 0 );

     // prints: handleGot1 error: divide by zero
   * @param {*|Error} error error, or value that represent error reason
   * @throws {Error} if passed extra parameters.
   * @method error
   * @memberof wConsequence
   */

var error = function( error )
{
  var self = this;
  _.assert( arguments.length === 1 || arguments.length === 0 );
  if( arguments.length === 0  )
  error = _.err();
  return self._giveWithError( error,undefined );
}

//

  /**
   * Method creates and pushes message object into wConsequence messages sequence.
   * Returns current wConsequence instance.
   * @param {*} error Error value
   * @param {*} argument resolved value
   * @returns {_giveWithError}
   * @private
   * @throws {Error} if missed arguments or passed extra arguments
   * @method _giveWithError
   * @memberof wConsequence
   */

var _giveWithError = function( error,argument )
{
  var self = this;

  _.assert( arguments.length === 2 );

  var message =
  {
    error : error,
    argument : argument,
  }

  self._message.push( message );
  self._handleGot();

  return self;
}

//

  /**
   * Creates and pushes message object into wConsequence messages sequence, and trying to get and return result of
      handling this message by appropriate correspondent.
   * @example
     var con = new  wConsequence();

     var increment = function( err, value )
     {
       return ++value;
     };


     con.got( increment );
     var result = con.ping( undefined, 4 );
     console.log( result );
     // prints 5;
   * @param {*} error
   * @param {*} argument
   * @returns {*} result
   * @throws {Error} if missed arguments or passed extra arguments
   * @method ping
   * @memberof wConsequence
   */

var ping = function( error,argument )
{
  var self = this;

  _.assert( arguments.length === 2 );

  var message =
  {
    error : error,
    argument : argument,
  }

  self._message.push( message );
  var result = self._handleGot();

  return result;
}

// --
// mechanism
// --

  /**
   * Creates and handles error object based on `err` parameter.
   * Returns new wConsequence instance with error in messages queue.
   * @param {*} err error value.
   * @returns {wConsequence}
   * @private
   * @method _handleError
   * @memberof wConsequence
   */

var _handleError = function _handleError( err )
{
  var self = this;
  var err = _.err( err );

  if( !err.attentionGiven )
  err.attentionNeeded = 1;

  var result = new wConsequence().error( err );

  if( Config.debug && err.attentionNeeded )
  {
    console.error( 'Consequence caught error' );
    debugger;

    _.timeOut( 0, function()
    {
      if( err.attentionNeeded )
      {
        console.error( 'Uncaught error caught by Consequence :' );
        _.errLog( err );
      }
    });
  }

  return result;
}

//

  /**
   * Method for processing corespondents and _message queue. Provides handling of resolved message values and errors by
      corespondents from correspondents value. Method takes first message from _message sequence and try to pass it to
      the first corespondent in corespondents sequence. Method returns the result of current corespondent execution.
      There are several cases of _handleGot behavior:
      - if corespondent is regular function:
        trying to pass messages error and argument values into corespondent and execute. If during execution exception
        occurred, it will be catch by _handleError method. If corespondent was not added by tap or persist method,
        _handleGot will remove message from head of queue.

        If corespondent was added by then_, thenOnce, ifErrorThen, or by other "thenable" method of wConsequence, then:

        1) if result of corespondents is ordinary value, then _handleGot method appends result of corespondent to the
        head of messages queue, and therefore pass it to the next handler in corespondents queue.
        2) if result of corespondents is instance of wConsequence, _handleGot will append current wConsequence instance
        to result instance corespondents sequence.

        After method try to handle next message in queue if exists.

      - if corespondent is instance of wConsequence:
        in that case _handleGot pass message into corespondent`s messages queue.

        If corespondent was added by tap, or one of then_, thenOnce, ifErrorThen, or by other "thenable" method of
        wConsequence then _handleGot try to pass current message to the next handler in corespondents sequence.

      - if in current wConsequence are present corespondents added by persist method, then _handleGot passes message to
        all of them, without removing them from sequence.

   * @returns {*}
   * @throws {Error} if on invocation moment the _message queue is empty.
   * @private
   * @method _handleGot
   * @memberof wConsequence
   */

var _handleGot = function _handleGot()
{
  var self = this;
  var result;
  var spliced = 0;

  if( !self._correspondent.length && !self._correspondentPersistent.length )
  return;

  _.assert( self._message.length );
  var message = self._message[ 0 ];

  /* give message to correspondent consequence */

  var __giveToConsequence = function( correspondent,ordinary )
  {

    result = correspondent.onGot._giveWithError( message.error,message.argument );

    if( ordinary )
    if( correspondent.thenning )
    {
      self._handleGot();
    }

  }

  /* give message to correspondent routine */

  var __giveToRoutine = function( correspondent,ordinary )
  {

    if( Config.debug )
    if( correspondent.debug )
    debugger;

    var execute = true;
    var execute = execute && ( !correspondent.ifError || ( correspondent.ifError && !!message.error ) );
    var execute = execute && ( !correspondent.ifNoError || ( correspondent.ifNoError && !message.error ) );

    if( !execute )
    return;

    var splice = true;
    splice = splice && !correspondent.tapping && ordinary;
    splice = splice && execute;

    if( splice )
    {
      spliced = 1;
      self._message.shift();
    }

    /**/

    try
    {
      result = correspondent.onGot.call( self,message.error,message.argument );
    }
    catch( err )
    {
      result = self._handleError( err );
    }

    /**/

    if( correspondent.thenning )
    {
      if( result instanceof Self )
      result.then_( self );
      else
      self.give( result );
    }

  }

  /* give to */

  var __giveTo = function( correspondent,ordinary )
  {

    if( correspondent.onGot instanceof Self )
    {
      __giveToConsequence( correspondent,ordinary );
    }
    else
    {
      __giveToRoutine( correspondent,ordinary );
    }

  }

  /* ordinary */

  var correspondent;
  if( self._correspondent.length > 0 )
  {
    correspondent = self._correspondent.shift();
    __giveTo( correspondent,1 );
  }

  /* persistent */

  if( !correspondent || ( correspondent && !correspondent.tapping ) )
  {

    for( var i = 0 ; i < self._correspondentPersistent.length ; i++ )
    {
      var pTaker = self._correspondentPersistent[ i ];
      __giveTo( pTaker,0 );
    }

    if( !spliced && self._correspondentPersistent.length )
    self._message.shift();

  }

  /* next message */

  if( self._message.length )
  self._handleGot();

  return result;
}

//

  /**
   * If `o.consequence` if instance of wConsequence, method pass o.args and o.error if defined, to it's message sequence.
   * If `o.consequence` is routine, method pass o.args as arguments to it and return result.
   * @param {Object} o parameters object.
   * @param {Function|wConsequence} o.consequence wConsequence or routine.
   * @param {Array} o.args values for wConsequence messages queue or arguments for routine.
   * @param {*|Error} o.error error value.
   * @returns {*}
   * @private
   * @throws {Error} if missed arguments.
   * @throws {Error} if passed argument is not object.
   * @throws {Error} if o.consequence has unexpected type.
   * @method _give_class
   * @memberof wConsequence
   */

var _give_class = function _give_class( o )
{
  var context;

  if( !( _.arrayIs( o.args ) && o.args.length <= 1 ) )
  debugger;

  _.assert( arguments.length );
  _.assert( _.objectIs( o ) );
  _.assert( _.arrayIs( o.args ) && o.args.length <= 1, 'not tested' );

  //

  if( o.consequence instanceof Self )
  {
/*
    if( o.error === undefined )
    give = o.consequence.give;
    else
    give = o.consequence._giveWithError;
*/
    _.assert( _.arrayIs( o.args ) && o.args.length <= 1 );

    context = o.consequence;

    if( o.error !== undefined )
    {
      o.consequence._giveWithError( o.error,o.args[ 0 ] );
    }
    else
    {
      o.consequence.give( o.args[ 0 ] );
    }
/*
    if( o.args )
    give.apply( context,o.args );
    else
    give.call( context,got );
*/
  }
  else if( _.routineIs( o.consequence ) )
  {

    _.assert( _.arrayIs( o.args ) && o.args.length <= 1 );

/*
    give = o.consequence;
    context = o.context;

    if( o.error !== undefined )
    {
      o.args = o.args || [];
      o.args.unshift( o.error );
    }

    if( o.args )
    o.consequence.apply( context,o.args );
    else
    o.consequence.call( context,got );
*/

    if( o.error !== undefined )
    {
      return o.consequence.call( context,o.error,o.args[ 0 ] );
    }
    else
    {
      return o.consequence.call( context,null,o.args[ 0 ] );
    }

  }
  else throw _.err( 'Unknown type of consequence : ' + _.strTypeOf( o.consequence ) );


}

//
/*
var giveWithContextTo = function giveWithContextTo( consequence,context,got )
{

  var args = [ got ];
  if( arguments.length > 3 )
  args = _.arraySlice( arguments,2 );

  return _give_class
  ({
    consequence : consequence,
    context : context,
    error : undefined,
    args : args,
  });

}
*/
//


  /**
   * If `consequence` if instance of wConsequence, method pass arg and error if defined to it's message sequence.
   * If `consequence` is routine, method pass arg as arguments to it and return result.
   * @example
   * var showResult = function(err, val)
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

     var con = new  wConsequence();

     con.got( showResult );

     wConsequence.give( con, 'hello world' );
     // prints: handleGot1 value: hello world
   * @param {Function|wConsequence} consequence
   * @param {*} arg argument value
   * @param {*} [error] error value
   * @returns {*}
   * @static
   * @method give
   * @memberof wConsequence
   */

var giveClass = function( consequence )
{

  _.assert( arguments.length === 2 || arguments.length === 3 );

  var err,got;
  if( arguments.length === 2 )
  {
    got = arguments[ 1 ];
  }
  else if( arguments.length === 3 )
  {
    err = arguments[ 1 ];
    got = arguments[ 2 ];
  }

  var args = [ got ];

  return _give_class
  ({
    consequence : consequence,
    context : undefined,
    error : err,
    args : args,
  });

}

//

  /**
   * If `consequence` if instance of wConsequence, method error to it's message sequence.
   * If `consequence` is routine, method pass error as arguments to it and return result.
   * @example
   * var showResult = function(err, val)
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

     var con = new  wConsequence();

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

var errorClass = function( consequence,error )
{

  _.assert( arguments.length === 2 );

  return _give_class
  ({
    consequence : consequence,
    context : undefined,
    error : error,
    args : [],
  });

}

//

var giveWithContextAndErrorTo = function giveWithContextAndErrorTo( consequence,context,err,got )
{

  if( err === undefined )
  err = null;

  var args = [ got ];
  if( arguments.length > 4 )
  args = _.arraySlice( arguments,3 );

  return _give_class
  ({
    consequence : consequence,
    context : context,
    error : err,
    args : args,
  });

}

// --
// correspondent
// --

  /**
   * The _corespondentMap object
   * @typedef {Object} _corespondentMap
   * @property {Function|wConsequence} onGot function or wConsequence instance, that accepts resolved messages from
   * messages queue.
   * @property {boolean} thenning determines if corespondent pass his result back into messages queue.
   * @property {boolean} tapping determines if corespondent return accepted message back into  messages queue.
   * @property {boolean} ifError turn on corespondent only if message represent error;
   * @property {boolean} ifNoError turn on corespondent only if message represent no error;
   * @property {boolean} debug enables debugging.
   * @property {string} name corespondent name.
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

     var con = wConsequence();

     con.tap( corespondent1 ).then_( corespondent2 ).got( corespondent3 );

     var corespondents = con.correspondentsGet();

     console.log( corespondents );

     // prints
     // [ {
     //  onGot: [Function: corespondent1],
     //  thenning: true,
     //  tapping: true,
     //  ifError: false,
     //  ifNoError: false,
     //  debug: false,
     //  name: 'corespondent1' },
     // { onGot: [Function: corespondent2],
     //   thenning: true,
     //   tapping: false,
     //   ifError: false,
     //   ifNoError: false,
     //   debug: false,
     //   name: 'corespondent2' },
     // { onGot: [Function: corespondent3],
     //   thenning: false,
     //   tapping: false,
     //   ifError: false,
     //   ifNoError: false,
     //   debug: false,
     //   name: 'corespondent3'
     // } ]
   * @returns {_corespondentMap[]}
   * @method correspondentsGet
   * @memberof wConsequence
   */

var correspondentsGet = function()
{
  var self = this;
  return self._correspondent;
}

//

  /**
   * If called without arguments, method correspondentsClear() removes all corespondents from wConsequence
   * correspondents queue.
   * If as argument passed routine, method correspondentsClear() removes it from corespondents queue if exists.
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

   var con = wConsequence();

   con.got( corespondent1 ).got( corespondent2 );
   con.correspondentsClear();

   con.got( corespondent3 );
   con.give( 'bar' );

   // prints
   // corespondent1 value: bar
   * @param [correspondent]
   * @method correspondentsClear
   * @memberof wConsequence
   */

var correspondentsClear = function correspondentsClear( correspondent )
{
  var self = this;

  _.assert( arguments.length === 0 || _.routineIs( correspondent ) );

  if( arguments.length === 0 )
  self._correspondent.splice( 0,self._correspondent.length );
  else
  {
    throw _.err( 'not tested' );
    _.arrayRemoveOnce( self._correspondent,correspondent );
  }

}

// --
// message
// --

  /**
   * The internal wConsequence view of message.
   * @typedef {Object} _messageObject
   * @property {*} error error value
   * @property {*} argument resolved value
   */

  /**
   * Returns messages queue.
   * @example
   * var con = wConsequence();

     con.give( 'foo' );
     con.give( 'bar ');
     con.error( 'baz' );


     var messages = con.messagesGet();

     console.log( messages );

     // prints
     // [ { error: null, argument: 'foo' },
     // { error: null, argument: 'bar ' },
     // { error: 'baz', argument: undefined } ]

   * @returns {_messageObject[]}
   * @method messagesGet
   * @memberof wConsequence
   */

var messagesGet = function()
{
  var self = this;
  return self._message;
}

//
  /**
   * If called without arguments, method removes all messages from wConsequence
   * correspondents queue.
   * If as argument passed value, method messagesClear() removes it from messages queue if messages queue contains it.
   * @example
   * var con = wConsequence();

     con.give( 'foo' );
     con.give( 'bar ');
     con.error( 'baz' );

     con.messagesClear();
     var messages = con.messagesGet();

     console.log( messages );
     // prints: []
   * @param {_messageObject} data message object for removing.
   * @throws {Error} If passed extra arguments.
   * @method correspondentsClear
   * @memberof wConsequence
   */

var messagesClear = function messagesClear( data )
{
  var self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( arguments.length === 0 )
  self._message.splice( 0,self._message.length );
  else
  {
    throw _.err( 'not tested' );
    _.arrayRemoveOnce( self._message,data );
  }

}

//

  /**
   * Returns number of messages in current messages queue.
   * @example
   * var con = wConsequence();

     var conLen = con.hasMessage();
     console.log( conLen );

     con.give( 'foo' );
     con.give( 'bar' );
     con.error( 'baz' );
     conLen = con.hasMessage();
     console.log( conLen );

     con.messagesClear();

     conLen = con.hasMessage();
     console.log( conLen );
     // prints: 0, 3, 0;

   * @returns {number}
   * @method hasMessage
   * @memberof wConsequence
   */

var hasMessage = function()
{
  var self = this;
  if( self._message.length <= self._correspondent.length )
  return 0;
  return self._message.length - self._correspondent.length;
}

// --
// etc
// --

  /**
   * Clears all messages and corespondents of wConsequence.
   * @method clear
   * @memberof wConsequence
   */

var clear = function clear( data )
{
  var self = this;
  _.assert( arguments.length === 0 );

  self.correspondentsClear();
  self.messagesClear();

}

//

  /**
   * Serializes current wConsequence instance.
   * @example
   * function corespondent1(err, val)
     {
       console.log( 'corespondent1 value: ' + val );
     };

     var con = wConsequence();
     con.got( corespondent1 );

     var conStr = con.toStr();

     console.log( conStr );

     con.give( 'foo' );
     con.give( 'bar' );
     con.error( 'baz' );

     conStr = con.toStr();

     console.log( conStr );
     // prints:

     // wConsequence( 0 )
     // message : 0
     // correspondents : 1
     // correspondent names : corespondent1

     // corespondent1 value: foo

     // wConsequence( 0 )
     // message : 2
     // correspondents : 0
     // correspondent names :

   * @returns {string}
   * @method toStr
   * @memberof wConsequenc
   */

var toStr = function()
{
  var self = this;
  var result = self.nickName;

  var names = _.entitySelect( self.correspondentsGet(),'*.name' );

  result += '\n  message : ' + self.messagesGet().length;
  result += '\n  correspondents : ' + self.correspondentsGet().length;
  result += '\n  correspondent names : ' + names.join( ' ' );

  return result;
}

//

var _onDebug = function( err,data )
{
  debugger;
  if( err )
  throw _.err( err );
  return data;
}

// --
// relationships
// --

var Composes =
{
  name : '',
  _correspondent : [],
  _correspondentPersistent : [],
  _message : [],
}

var Restricts =
{
}

// --
// proto
// --

var Proto =
{

  init : init,


  // mechanics

  _correspondentAppend : _correspondentAppend,


  // chainer

  got : got,
  done : got,
  gotOnce : gotOnce, /* experimental */

  then_ : then_,
  thenSealed : thenSealed,
  thenReportError : thenReportError, /* experimental */

  thenOnce : thenOnce, /* experimental */
  thenClone : thenClone,

  tap : tap,
  ifErrorThen : ifErrorThen,
  ifNoErrorThen : ifNoErrorThen,
  thenDebug : thenDebug, /* experimental */
  thenTimeOut : thenTimeOut,

  persist : persist, /* experimental */


  // advanced

  and : and,
  first : first,


  // messanger

  give : give,
  error : error,
  _giveWithError : _giveWithError,
  ping : ping, /* experimental */

  _give_class : _give_class,


  // mechanism

  _handleError : _handleError,
  _handleGot : _handleGot,


  // correspondent

  correspondentsGet : correspondentsGet,
  correspondentsClear : correspondentsClear,


  // message

  messagesGet : messagesGet,
  messagesClear : messagesClear,

  hasMessage : hasMessage,
  messageHas : hasMessage,


  // etc

  clear : clear,
  toStr : toStr,
  _onDebug : _onDebug,


  // class var

  usingAsyncTaker : 0,


  // ident

  constructor : Self,
  Composes : Composes,
  Restricts : Restricts,

}

//

var Static =
{

  give : giveClass,
  error : errorClass,

  giveWithContextAndErrorTo : giveWithContextAndErrorTo,

  ifErrorThen : ifErrorThenClass,
  ifNoErrorThen : ifNoErrorThenClass,

  passThru : passThruClass,

}

//

_.protoMake
({
  constructor : Self,
  parent : Parent,
  extend : Proto,
  static : Static,
});

//

if( _global_.wCopyable )
wCopyable.mixin( Self.prototype );

//

_.accessor
({
  object : Self.prototype,
  names :
  {
  }
});

//

_.accessorForbid( Self.prototype,
  {
    every : 'every',
    mutex : 'mutex',
    mode : 'mode',
  }
);

//

_.mapExtendFiltering( _.filter.atomicSrcOwn(),Self.prototype,Composes );

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}


_global_.wConsequence = wTools.Consequence = Self;
return Self;

})();
