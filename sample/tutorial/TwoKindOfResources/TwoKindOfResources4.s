let _ = require( 'wTools' );
require( 'wConsequence' );

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
// logs: then is invoked with:  my arg
// logs: finally is invoked with:  from then
