let _ = require( 'wTools' );
require( 'wConsequence' );

// var con = new _.Consequence();

// con.thenGive( ( arg ) => console.log( arg + 1 ) );
// con.take( 'agr' );

// con.thenGive( ( arg ) => console.log( arg.name ) );
// con.take({ name : 'user1', age : 20 });

// con.thenGive( ( arg ) => console.log( arg + 1 ) );
// con.take( 123 );

/* */

// var con = new _.Consequence();

// con.thenGive( ( arg ) => console.log( arg ) );
// con.take( _.errAttend( 'Error!' ) );

/* */
var con = new _.Consequence();

con.thenGive( ( arg ) => console.log( arg + 1 ) );
con.catch( ( arg ) => console.log( arg ) );

con.take( _.errAttend( 'Error!' ) );

/* */

var con = new _.Consequence();

con.then( ( arg ) =>
{
  console.log( 'then is invoked with argument: ', arg );
  return 'new arg from then';
} );
con.catch( ( err ) =>
{
  console.log( 'catch is invoked with argument: ', err );
  return 'new arg from catch';
} );
con.finally( ( err, arg ) =>
{
  console.log( 'finally is invoked with argument: ', err ? err : arg );
  return null;
} );

// con.take( 'some resource' );
// console.log( con.argumentsGet() );
con.error( _.errAttend( 'Error!' ) );
console.log( con.argumentsGet() );

/* */


