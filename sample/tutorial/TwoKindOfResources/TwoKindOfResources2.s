let _ = require( 'wTools' );
require( 'wConsequence' );

var con = new _.Consequence();

con.thenGive( ( arg ) => console.log( arg ) );

// _.errAttend( message ) - creating a processed error
con.take( _.errAttend( 'Error!' ) );
// logs: error log...
