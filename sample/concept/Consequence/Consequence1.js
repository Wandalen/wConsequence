let _ = require( 'wTools' );
require( 'wConsequence' );

// here would be the `async fynction` syntax if using Promise
function foo()
{
  var con = new _.Consequence();

  _.time.out( 1000, () => con.take( 'my resource' ) );

  con.deasync(); // delay execution of .sync() till resource is passed into consequence
  return con.sync(); // .sync() retrieving a resource just passed into consequence
}

// here would be the `await foo()` syntax if using Promise
var result = foo();

// after 1 sec we get result
console.log( result ); // my resource
