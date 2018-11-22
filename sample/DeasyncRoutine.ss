var fs = require( 'fs' );
var deasync = require( 'deasync' );

//Use case of deasync for functions with conventional API signature function(p1,...pn,function cb(error,result){})

function asyncRoutine( data, cb )
{
  setTimeout( () =>
  {
    if( data !== __filename )
    cb( new Error( 'invalid value of argument' )  )
    else
    cb( null,data )

  },1500 )
}

var syncRoutine = deasync( asyncRoutine );

// returns value

var result = syncRoutine( __filename );
console.log( 'Async func returned:',  result );

// throws error
try
{
  syncRoutine( __dirname );
}
catch ( err )
{
  console.log( '\n\nError thrown:' )
  console.log( err )
}
