
require( 'wConsequence' );
var _ = _global_.wTools;

var deasync = require('deasync');

function waitForCon( con )
{
  let ready = false;
  let result = {};
  con.got( ( err, data ) =>
  {
    result.err = err;
    result.data = data;
    ready = true;
  })

  deasync.loopWhile( () => !ready )

  if( result.err )
  throw result.err;

  return result.data;
}

// returns value

let con = _.timeOut( 1500, () => Math.random() );
var result = waitForCon( con );

console.log( 'Async func returned:' );
console.log( result );

// throws error

try
{
  waitForCon( _.timeOutError( 1000 ) );
}
catch ( err )
{
  console.log( '\n\n' )
  _.errLogOnce( err )
}
