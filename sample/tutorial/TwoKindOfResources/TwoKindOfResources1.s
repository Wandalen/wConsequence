let _ = require( 'wTools' );
require( 'wConsequence' );

var con = new _.Consequence();

con.thenGive( ( arg ) => console.log( arg + 1 ) ); // logs: arg1
con.take( 'agr' );

con.thenGive( ( arg ) => console.log( arg.name ) ); // logs: user1
con.take({ name : 'user1', age : 20 });

con.thenGive( ( arg ) => console.log( arg + 1 ) ); // logs: 124
con.take( 123 );
