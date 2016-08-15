if( typeof module !== 'undefined' )
{
  var _ = require( 'wTools' );
  /* require( 'wConsequence' ); */
  require( '../../staging/abase/syn/Consequence.s' );
  var Problem = require( './Problem.js' );
}

var waitingHackers = [],
  waitingEmployees = [];

Problem.hackerArrives = function( hacker )
{
  console.log( 'hacker ' + hacker.name + 'arrive to river' );
  waitingHackers.push( hacker );
  if( waitingHackers.length >= 2 )
  {
    while(waitingHackers.length)
      this.boardBoat( waitingHackers.shift() );
  }
};

Problem.employeeArrives = function( employee )
{
  console.log( 'employee ' + employee.name + 'arrive to river' );
  waitingEmployees.push( employee );
  if( waitingEmployees.length >= 2 )
  {
    while(waitingEmployees.length)
      this.boardBoat( waitingEmployees.shift() );
  }
};

Problem.peopleArrive();

