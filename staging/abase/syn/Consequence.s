( function _Consequence_s_(){

'use strict';

  /**
   * @file Consequence.s - Advanced synchronization mechanism. wConsequence is able to solve any asynchronous problem
     replacing and including functionality of many other mechanisms, such as: Callback, Event, Signal, Mutex, Semaphore,
     Async, Promise.
   */

/*

 !!! move promise / event property from object to taker

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
    require( 'wTools' );
  }
  catch( err )
  {
    require( '../wTools.s' );
  }

  try
  {
    require( 'wCopyable' );
  }
  catch( err )
  {
    require( '../mixin/Copyable.s' );
  }

  try
  {
    require( 'wProto' );
  }
  catch( err )
  {
    require( '../component/Proto.s' );
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
   * @callback wConsequence~taker
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
   * Method created and appends taker object, based on passed options into wConsequence takers queue.
   *
   * @param {Object} o options object
   * @param {wConsequence~taker|wConsequence} o.onGot taker callback
   * @param {Object} [o.context] if defined, it uses as 'this' context in taker function.
   * @param {Array<*>|ArrayLike} [o.argument] values, that will be used as binding arguments in taker.
   * @param {string} [o.name=null] name for taker function
   * @param {boolean} [o.thenning=false] If sets to true, then result of current taker will be passed to the next taker
      in takers queue.
   * @param {boolean} [o.persistent=false] If sets to true, then taker will be work as queue listener ( it will be
   * processed every value resolved by wConsequence).
   * @param {boolean} [o.tapping=false] enabled some breakpoints in debug mode;
   * @returns {wConsequence}
   * @private
   * @method _takerAppend
   * @memberof wConsequence
   */

var _takerAppend = function( o )
{
  var self = this;
  var taker = o.taker;
  var name = o.name || taker ? taker.name : null || null;

  _.assert( arguments.length === 1 );
  _.assert( _.routineIs( taker ) || taker instanceof Self );

  if( _.routineIs( taker ) )
  {
    if( o.context !== undefined || o.argument !== undefined )
    taker = _.routineJoin( o.context,taker,o.argument );
  }
  else
  {
    _.assert( o.context === undefined && o.argument === undefined );
  }

  /* store */

  if( o.persistent )
  self._takerPersistent.push
  ({
    onGot : taker,
    thenning : !!o.thenning,
    tapping : !!o.tapping,
    name : name,
  });
  else
  self._taker.push
  ({
    onGot : taker,
    thenning : !!o.thenning,
    tapping : !!o.tapping,
    name : name,
  });

  /* got */

  if( self.usingAsyncTaker )
  setTimeout( function()
  {

    if( self._given.length )
    self._handleGot();

  }, 0 );
  else
  {

    if( self._given.length )
    self._handleGot();

  }

  return self;
}

// --
// chainer
// --

  /**
   * Method appends resolved value and error handler to wConsequence takers sequence. That handler accept only one
      value or error reason only once, and don't pass result of it computation to next handler (unlike Promise 'then').
      if got() called without argument, an empty handler will be appended.
      After invocation, taker will be removed from takers queue.
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
   * @param {wConsequence~taker|wConsequence} [taker] callback, that accepts resolved value or exception reason.
   * @returns {wConsequence}
   * @see {@link wConsequence~taker} taker callback
   * @throws {Error} if passed more than one argument.
   * @method got
   * @memberof wConsequence
   */

var got = function got( taker )
{
  var self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( arguments.length === 0 )
  {
    taker = function(){};
  }

  return self._takerAppend
  ({
    taker : taker,
    context : arguments[ 1 ],
    argument : arguments[ 2 ],
    thenning : false,
  });

}

//

  /**
   * Works like got() method, but adds taker to queue only if function with same name not exist in queue yet.
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
     // taker gotHandler1 has ben invoked only once, because second taker was not added to takers queue.

     // but:

     var con2 = new wConsequence();

     con2.give( 'foo' ).give( 'bar' ).give('baz');
     con2.gotOnce( gotHandler1 ).gotOnce( gotHandler1 ).gotOnce( gotHandler2 );

     // logs:
     // handler 1: foo
     // handler 1: bar
     // handler 2: baz
     // in this case first gotHandler1 has been removed from takers queue immediately after the invocation, so adding
     // second gotHandler1 is legitimate.

   *
   * @param {wConsequence~taker|wConsequence} taker callback, that accepts resolved value or exception reason.
   * @returns {wConsequence}
   * @throws {Error} if passed more than one argument.
   * @throws {Error} if taker.name is not string.
   * @see {@link wConsequence~taker} taker callback
   * @see {@link wConsequence#got} got method
   * @method gotOnce
   * @memberof wConsequence
   */

var gotOnce = function gotOnce( taker )
{
  var self = this;
  var key = taker.name;

  _.assert( _.strIsNotEmpty( key ) );
  _.assert( arguments.length === 1 );

  var i = _.arrayLeftIndexOf( self._taker,key,function( a )
  {
    return a.name;
  });

  if( i >= 0 )
  return self;

  return self._takerAppend
  ({
    taker : taker,
    context : arguments[ 1 ],
    argument : arguments[ 2 ],
    thenning : false,
  });
}

//

  /**
   * Method accepts handler for resolved value/error. This handler method then_ adds to wConsequence takers sequence.
      After processing accepted value, taker return value will be pass to the next handler in takers queue.
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

   * @param {wConsequence~taker|wConsequence} taker callback, that accepts resolved value or exception reason.
   * @returns {wConsequence}
   * @throws {Error} if missed taker.
   * @throws {Error} if passed more than one argument.
   * @see {@link wConsequence~taker} taker callback
   * @see {@link wConsequence#got} got method
   * @method then_
   * @memberof wConsequence
   */

var then_ = function then_( taker )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assert( self instanceof Self )

  return self._takerAppend
  ({
    taker : taker,
    context : arguments[ 1 ],
    argument : arguments[ 2 ],
    thenning : true,
  });
}

//

  /**
   * Works like then_() method, but adds taker to queue only if function with same name not exist in queue yet.
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

   * @param {wConsequence~taker|wConsequence} taker callback, that accepts resolved value or exception reason.
   * @returns {*}
   * @throws {Error} if passed more than one argument.
   * @throws {Error} if taker is defined as anonymous function including anonymous function expression.
   * @see {@link wConsequence~taker} taker callback
   * @see {@link wConsequence#then_} then_ method
   * @see {@link wConsequence#gotOnce} gotOnce method
   * @method thenOnce
   * @memberof wConsequence
   */

var thenOnce = function thenOnce( taker )
{
  var self = this;
  var key = taker.name;

  _.assert( _.strIsNotEmpty( key ) );
  _.assert( arguments.length === 1 );

  debugger;
  var i = _.arrayLeftIndexOf( self._taker,key,function( a )
  {
    return a.name;
  });

  if( i >= 0 )
  {
    debugger;
    return self;
  }

  return self._takerAppend
  ({
    taker : taker,
    context : arguments[ 1 ],
    argument : arguments[ 2 ],
    thenning : true,
  });
}

//

  /**
   * Returns new wConsequence instance. If on cloning moment current wConsequence has unhandled resolved values in queue
     the first of them would be handled by new wConsequence.
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
   * Works like got() method, but value that accepts taker, passes to the next taker in takers queue without modification.
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

   * @param {wConsequence~taker|wConsequence} taker callback, that accepts resolved value or exception reason.
   * @returns {wConsequence}
   * @throws {Error} if passed more than one arguments
   * @see {@link wConsequence#got} got method
   * @method tap
   * @memberof wConsequenc
   */

var tap = function tap( taker )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assert( self instanceof Self )

  return self._takerAppend
  ({
    taker : taker,
    context : undefined,
    argument : arguments[ 2 ],
    thenning : false,
    tapping : true,
  });

}

//

var ifNoErrorThen = function()
{

  _.assert( arguments.length === 1 );
  _.assert( this instanceof Self )
  _.assert( arguments.length <= 3 );

  return this._takerAppend
  ({
    taker : Self.ifNoErrorThen( arguments[ 0 ] ),
    context : arguments[ 1 ],
    argument : arguments[ 2 ],
    thenning : true,
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

var ifErrorThen = function()
{

  _.assert( arguments.length === 1 );
  _.assert( this instanceof Self );

  return this._takerAppend
  ({
    taker : Self.ifErrorThen( arguments[ 0 ] ),
    context : arguments[ 1 ],
    argument : arguments[ 2 ],
    thenning : true,
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

var thenDebug = function thenDebug()
{
  var self = this;

  _.assert( arguments.length === 0 );

  return self._takerAppend
  ({
    taker : _onDebug,
    thenning : true,
  });

}

//

var timeOut = function timeOut( time,taker )
{
  var self = this;

  _.assert( arguments.length === 2 );
  _.assert( _.routineIs( taker ),'not implemented' );

  return self._takerAppend
  ({
    taker : function( err,data ){
      return _.timeOut( time,self,taker,[ err,data ] );
    },
    context : arguments[ 1 ],
    argument : arguments[ 2 ],
    thenning : true,
  });

}

//

var persist = function persist( taker )
{
  var self = this;

  _.assert( arguments.length === 1 );

  return self._takerAppend
  ({
    taker : taker,
    thenning : false,
    persistent : true,
  });

}

// --
// reverse chainer
// --

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
    _.timeOut( 1,give );
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

// --
// messager
// --

var give = function give( given )
{
  var self = this;
  _.assert( arguments.length === 2 || arguments.length === 1 || arguments.length === 0, 'expects 0, 1 or 2 arguments, got ' + arguments.length );
  if( arguments.length === 2 )
  return self.giveWithError( arguments[ 0 ],arguments[ 1 ] );
  else
  return self.giveWithError( null,given );
}

//

var error = function( error )
{
  var self = this;
  _.assert( arguments.length === 1 || arguments.length === 0 );
  if( arguments.length === 0  )
  error = _.err();
  return self.giveWithError( error,undefined );
}

//

var giveWithError = function( error,argument )
{
  var self = this;

  _.assert( arguments.length === 2 );

  var given =
  {
    error : error,
    argument : argument,
  }

  self._given.push( given );
  self._handleGot();

  return self;
}

//

var ping = function( error,argument )
{
  var self = this;

  _.assert( arguments.length === 2 );

  var given =
  {
    error : error,
    argument : argument,
  }

  debugger;

  self._given.push( given );
  var result = self._handleGot();

  return result;
}

// --
// mechanism
// --

var _handleError = function _handleError( err )
{
  var self = this;

  debugger;

  var err = _.err( err );

  if( !err.attentionGiven )
  err.attentionNeeded = 1;

  var result = new wConsequence().error( err );

  if( Config.debug )
  console.error( 'Consequence caught error' );

  if( Config.debug )
  {
    _.timeOut( 1, function()
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

var _handleGot = function _handleGot()
{
  var self = this;
  var result;

  if( !self._taker.length && !self._takerPersistent.length )
  return;

  _.assert( self._given.length );
  var _given = self._given[ 0 ];

  /**/

  var _giveToConsequence = function( _taker,ordinary )
  {

    /* need to have massage in the first consequence before executing the second one */
/*
    if( _taker.thenning )
    {
      self._given.unshift( _given );
    }
*/

    result = _taker.onGot.giveWithError.call( _taker.onGot,_given.error,_given.argument );

    if( ordinary )
    if( _taker.thenning || _taker.tapping )
    {
      self._handleGot();
    }

  }

  /**/

  var _giveToRoutine = function( _taker,ordinary )
  {

    if( !_taker.tapping && ordinary )
    self._given.splice( 0,1 );

    try
    {
      result = _taker.onGot.call( self,_given.error,_given.argument );
    }
    catch( err )
    {
      result = self._handleError( err );
    }

    /**/

    if( _taker.thenning )
    {
      if( result instanceof Self )
      result.then_( self );
      else
      self.give( result );
    }
    else if( _taker.tapping )
    {
      // if( result instanceof Self )
      // {
      //   //debugger;
      //   //throw _.err( 'not implemented' ); /* have not seen use case yet */
      //   //result.then_( function _tapping(){ debugger; self.give( _given.error,_given.argument ); } );
      // }
      // else
      // {
      //   self.give( _given.error,_given.argument );
      // }
    }

  }

  /**/

  var _giveTo = function( _taker,ordinary )
  {

    if( _taker.onGot instanceof Self )
    {
      _giveToConsequence( _taker,ordinary );
    }
    else
    {
      _giveToRoutine( _taker,ordinary );
    }

  }

  /* persistent */

  for( var i = 0 ; i < self._takerPersistent.length ; i++ )
  {
    var _taker = self._takerPersistent[ i ];
    _giveTo( _taker,0 );
  }

  /* ordinary */

  if( self._taker.length > 0 )
  {
    var _taker = self._taker[ 0 ];
    self._taker.splice( 0,1 );
    _giveTo( _taker,1 );
  }

  /**/

  if( self._given.length )
  self._handleGot();

  return result;
}

//

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
    give = o.consequence.giveWithError;
*/
    _.assert( _.arrayIs( o.args ) && o.args.length <= 1 );

    context = o.consequence;

    if( o.error !== undefined )
    {
      o.consequence.giveWithError( o.error,o.args[ 0 ] );
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
// clear
// --

var clearTakers = function clearTakers( taker )
{
  var self = this;

  _.assert( arguments.length === 0 || _.routineIs( taker ) );

  if( arguments.length === 0 )
  self._taker.splice( 0,self._taker.length );
  else
  {
    throw _.err( 'not tested' );
    _.arrayRemoveOnce( self._taker,taker );
  }

}

//

var clearGiven = function clearGiven( data )
{
  var self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( arguments.length === 0 )
  self._given.splice( 0,self._given.length );
  else
  {
    throw _.err( 'not tested' );
    _.arrayRemoveOnce( self._given,data );
  }

}

//

var clear = function clear( data )
{
  var self = this;
  _.assert( arguments.length === 0 );

  self.clearTakers();
  self.clearGiven();

}

// --
// etc
// --

var hasGiven = function()
{
  var self = this;
  if( self._given.length <= self._taker.length )
  return 0;
  return self._given.length - self._taker.length;
}

//

var takersGet = function()
{
  var self = this;
  return self._taker;
}

//

var givenGet = function()
{
  var self = this;
  return self._given;
}

//

var toStr = function()
{
  var self = this;
  var result = self.nickName;

  var names = _.entitySelect( self.takersGet(),'*.name' );

  result += '\n  given : ' + self.givenGet().length;
  result += '\n  takers : ' + self.takersGet().length;
  result += '\n  takers : ' + names.join( ' ' );

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
  _taker : [],
  _takerPersistent : [],
  _given : [],
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

  _takerAppend : _takerAppend,


  // chainer

  got : got,
  done : got,
  gotOnce : gotOnce, /* experimental */

  then_ : then_,
  thenOnce : thenOnce, /* experimental */
  thenClone : thenClone,

  tap : tap,
  ifErrorThen : ifErrorThen,
  ifNoErrorThen : ifNoErrorThen,
  thenDebug : thenDebug, /* experimental */
  timeOut : timeOut,

  persist : persist, /* experimental */


  // reverse chainer

  and : and,


  // messanger

  give : give,
  error : error,
  giveWithError : giveWithError,
  ping : ping, /* experimental */

  _give_class : _give_class,


  // mechanism

  _handleError : _handleError,
  _handleGot : _handleGot,


  // clear

  clearTakers : clearTakers,
  clearGiven : clearGiven,
  clear : clear,


  // etc

  hasGiven : hasGiven,
  takersGet : takersGet,
  givenGet : givenGet,
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
