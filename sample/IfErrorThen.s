let _ = require( 'wTools' );
require( 'wConsequence' );

/* correspondents */

function gotHandler1( value )
{
  console.log( '  gotHandler1 : ' + value );
}

function gotHandler2( value )
{
  console.log( '  gotHandler2 : ' + value );
}

function errorHandler( error )
{
  console.log( '  errorHandler : ' + error );
}

/* the passed resource is an argument(not error) */

console.log( 'case 1' );

var con1 = new _.Consequence({ capacity : 0 });

// the passed callback in `.ifErrorThen()` is not called with passed argument in `.take()`
con1.ifErrorThen( errorHandler )

// only one passed callback in `.thenGive()` is called for every argument passing in `.take()`
.thenGive( gotHandler1 )
.thenGive( gotHandler2 );

con1.take( 1 ).take( 4 );
console.log( ' ', con1.toStr() );

/* the passed resource is an error */

console.log( 'case 2' );

var con1 = new _.Consequence({ capacity : 0 });

con1.error( _.errAttend( 'error msg' ) ).take( 14 );

// the passed callback in `.ifErrorThen()` is called with the passed error in `.error()`
con1.ifErrorThen( errorHandler )

// the passed callback in `.thenGive()` is called with the passed argument in `.take()`
.thenGive( gotHandler1 );
console.log( ' ', con1.toStr() );

/* aaa Artem : done. simplify */
