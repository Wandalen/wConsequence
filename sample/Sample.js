require( 'wConsequence' );
let _ = wTools;
let con = new _.Consequence();
con.finallyGive( ( err, arg ) => console.log( 'Got :', arg ) );
con.take( 'Some arg' );
