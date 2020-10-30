let _ = require( 'wTools' );
require( 'wConsequence' );

/* correspondents */

function tapHandler( error, value )
{
  console.log( '  tapHandler value : ' + value );
  console.log( '  tapHandler error : ' + error );
}

function gotHandler2( value )
{
  console.log( '  gotHandler2 : ' + value );
}

function gotHandler3( value )
{
  console.log( '  gotHandler3 : ' + value );
}

/* the passed resource is an argument(not error) */

console.log( 'case 1' );

var con1 = new _.Consequence({ capacity : 0 });

// the callback passed in `.tap()` is called with the argument passed in the first `.take()`
con1.tap( tapHandler );

// the callback passed in the first `.thenGive()` after `.tap()` is called with the same argument too
con1.thenGive( gotHandler2 );

// the callback passed in the next `.thenGive()` is called with the argument passed in the next `.take()`
con1.thenGive( gotHandler3 );

con1.take( 1 )
.take( 4 );

/* the passed resource is an error */

console.log( 'case 2' );

var con1 = new _.Consequence({ capacity : 0 });

// the callback passed in `.tap ()` is called with an error passed in `.error()`
con1.tap( tapHandler );

// if `.tap()` preceding `.thenGive()` in the competitors queue received an error - the following competitors will not call
con1.thenGive( gotHandler2 );
con1.thenGive( gotHandler3 );

con1.error( _.errAttend( 'error msg' ) )
.take( 4 );

/* aaa Artem : done. simplify */
