
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
    informing : !!o.informing,
    name : name,
  });
  else
  self._taker.push
  ({
    onGot : taker,
    thenning : !!o.thenning,
    informing : !!o.informing,
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
// taker
// --

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

var thenClone = function thenClone()
{
  var self = this;

  _.assert( arguments.length === 0 );

  var result = new wConsequence();
  self.then_( result );

  return result;
}

//

var inform = function inform( taker )
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
    informing : true,
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
    // !!! temporary hack, to avoid RangeError: Maximum call stack size exceeded
    // thenning : true,
    thenning: false,
    persistent : true,
  });

}

// --
// giver
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

  self._given.push( given );
  var result = self._handleGot();

  return result;
}

//

var _handleGot = function()
{
  var self = this;
  var result;

  if( !self._taker.length )
  return;

  _.assert( self._given.length );

  var _given = self._given[ 0 ];
  self._given.splice( 0,1 );

  //

  var _giveToConsequence = function( _taker )
  {

    result = _taker.onGot.giveWithError.call( _taker.onGot,_given.error,_given.argument );
    if( _taker.thenning )
    {
      self.giveWithError( _given.error,_given.argument );
    }
    else if( _taker.informing )
    {
      debugger;
      self.giveWithError( _given.error,_given.argument );
    }

  }

  //

  var _giveToRoutine = function( _taker )
  {

    try
    {
      result = _taker.onGot.call( self,_given.error,_given.argument );
    }
    catch( err )
    {
      debugger;
      var err = _.err( err );
      err.needAttention = 1;
      result = new wConsequence().error( err );
      if( Config.debug )
      console.error( 'Consequence caught error' );
      if( Config.debug )
      {
        _.timeOut( 1, function()
        {
          if( err.needAttention )
          {
            console.error( 'Uncaught error caught by Consequence :' );
            _.errLog( err );
          }
        });
      }
    }

    /**/

    if( _taker.thenning )
    {
      if( result instanceof Self )
      result.then_( self ); // !!! got?
      else
      self.give( result );
    }
    else if( _taker.informing )
    {
      if( result instanceof Self )
      {
        debugger;
        result.then_( function _informing(){ debugger; self.give( _given.error,_given.argument ); } ); // !!! got?
      }
      else
      {
        self.give( _given.error,_given.argument );
      }
    }

  }

  //

  var _giveTo = function( _taker )
  {

    if( _taker.onGot === _onDebug )
    debugger;

    if( _taker.onGot instanceof Self )
    {
      _giveToConsequence( _taker );
    }
    else
    {
      _giveToRoutine( _taker );
    }

  }

  //

/*
  if( self.mode === 'promise' )
  {

    var _taker = self._taker[ 0 ];
    self._taker.splice( 0,1 );
    _giveTo( _taker );

  }
  else if( self.mode === 'event' )
  {

    for( var i = 0 ; i < self._taker.length ; i++ )
    _giveTo( self._taker[ i ] );

  }
  else throw _.err( 'unexepected' );
*/

//

  /* persistent */

  for( var i = 0 ; i < self._takerPersistent.length ; i++ )
  {
    // !!! maybe misstake
    // var _taker = self._taker[ i ];
    var _taker = self._takerPersistent[ i ];
    _giveTo( _taker );
  }

  /* ordinar */

  if( self._taker.length > 0 )
  {
    var _taker = self._taker[ 0 ];
    self._taker.splice( 0,1 );
    _giveTo( _taker );
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

var _onDebug = function()
{
  debugger;
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
  //mode : 'promise',
}

var Aggregates =
{
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


  // taker

  got : got,
  done : got,
  gotOnce : gotOnce,

  then_ : then_,
  thenOnce : thenOnce,
  thenClone : thenClone,

  inform : inform,
  ifErrorThen : ifErrorThen,
  ifNoErrorThen : ifNoErrorThen,
  thenDebug : thenDebug,
  timeOut : timeOut,

  persist : persist,


  // giver

  give : give,
  error : error,
  giveWithError : giveWithError,
  ping : ping,

  _handleGot : _handleGot,
  _give_class : _give_class,


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
  Aggregates : Aggregates,
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
    //mutex : 'mutex',
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
