require( 'wConsequence' );
let _ = wTools;

// The `capacity` option indicates the maximum number of resources in the resource queue at a time, by default 1
// if `capacity` : 0 - not limited
let con = new _.Consequence( { capacity : 0 } );

con.then( ( arg ) => arg + '1' );
con.then( ( arg ) => arg + '2' );
con.then( ( arg ) => arg + '3' );

// argumentsGet() returns an array with all the resources that the consequence currently contains
console.log( con.argumentsGet() );
/* log : [] */

// competitorsGet() returns an array with all the competitors that the consequence currently contains
console.log( con.competitorsGet() );
/* log : [ {}, {}, {} ] */

// toString() method of consequence logs number of all the resources and all the competitors
// in fact, these numbers is a `length` property of both the resources array and the competitors array
// it logs - Consequence:: resources / competitors
console.log( con );
/* log : Consequence:: 0 / 3 */

// passing the first resource to the consequence
// when the resource was passed all the competitors(that was added before this moment to consequence) start to execute in turn
con.take( 'a' );

// now the consequence contains one resource that was processed through the all competitors
console.log( con.argumentsGet() );
/* log : [ 'a123' ] */

// Pay attention to the quantity of the competitors - 0
// very important to understand that competitors will invoked only one time, after passing the resource they will disappear
console.log( con );
/* log : Consequence:: 1 / 0 */

// passing the second resource to the consequence
con.take( 'b' );

// every next resource is pushed to the resource queue array
console.log( con.argumentsGet() );
/* log : [ 'a123', 'b' ] */
console.log( con );
/* log : Consequence:: 2 / 0 */

/* aaa Artem : done. add comments, add log output */
/* aaa Artem : done. make tutorial from this */
