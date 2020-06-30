let _ = require( 'wTools' );
require( 'wConsequence' );

const con = new _.Consequence();

con.then(( arg ) => {
  console.log( arg + '1' );
  return null
})

con.catch(( err ) => {
  console.log( err );
  return null
})

// con.take('arg');
con.error('arg')
