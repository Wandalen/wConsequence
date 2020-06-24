require( 'wConsequence' );
let _ = wTools;

var con = new _.Consequence();
console.log( con ); // Consequence:: 0 / 0

con.then( () => null );
console.log( con ); // Consequence:: 0 / 1

con.catch( ( err ) => err );
console.log( con ); // Consequence:: 0 / 2

con.take( 'myArg' );
console.log( con ); // Consequence:: 1 / 0

/* */

var con1 = new _.Consequence({ tag : 'con1' });
var con2 = new _.Consequence({ tag : 'con2' });

console.log( con1 ); // Consequence::con1 0 / 0

console.log( con2 ); // Consequence::con2 0 / 0

/* */

var con = new _.Consequence( { capacity : 0 } );

con.then( ( arg ) => arg + 'fromThen' );
con.catch( ( err ) => err );

// routine .competitorsGet() returns an array of competitor objects
console.log( con.competitorsGet()[ 1 ] ); // { competitor settings... }

con.take( 'myArg1' );

// routine .resourcesGet() returns an array of resource objects
console.log( con.resourcesGet() );
/*
[
  [Object: null prototype] { error: undefined, argument: 'myArg1fromThen' }
]
*/

con.take( 'myArg2' );

// routine .argumentsGet() returns an array of "argument" property values
// every resource is an object that has "argument" property in which the value of the passed resource is written
console.log( con.argumentsGet() ); // [ 'myArg1fromThen', 'myArg2' ]

/* */

var con = _.Consequence();

// .toStr and .toString routines take map with "verbosity" property which determines the detail of the output
console.log( con.toStr({ verbosity : 2 }) );
console.log( con.toString({ verbosity : 2 }) );