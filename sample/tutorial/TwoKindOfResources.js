let _ = require( 'wTools' );
require( 'wConsequence' );

var con = new _.Consequence();

con.thenGive( ( arg ) => console.log( arg + 1 ) );
con.take( 'agr' );

con.thenGive( ( arg ) => console.log( arg.name ) );
con.take({ name : 'user1', age : 20 });

con.thenGive( ( arg ) => console.log( arg + 1 ) );
con.take( 123 );

/* */

var con = new _.Consequence();

con.thenGive( ( arg ) => console.log( arg ) );
con.take( _.errAttend( 'Error!' ) );

/* */

var con = new _.Consequence();

con.thenGive( ( arg ) => console.log( 'thenGive1 is invoked with: ', arg ) );
con.catch( ( arg ) =>
{
  console.log( 'catch is invoked with: ', arg );
  return null;
} );
con.thenGive( ( arg ) => console.log( 'thenGive2 is invoked with: ', arg ) );

con.error( _.errAttend( 'Error!' ) );
console.log( con );

/* */

var con = new _.Consequence();

con.then( ( arg ) =>
{
  console.log( 'then is invoked with: ', arg );
  return 'from then';
} );
con.finally( ( err, arg ) =>
{
  console.log( 'finally is invoked with: ', err ? err : arg );
  return null;
} );

con.take( 'my arg' );

/* */

var con = new _.Consequence();

con.then( ( arg ) =>
{
  console.log( 'then is invoked with: ', arg );
  return 'from then';
} );
con.finally( ( err, arg ) =>
{
  console.log( 'finally is invoked with: ', err ? err : arg );
  return null;
} );

con.error( _.errAttend( 'Error!' ) );
console.log( con );

/* */
