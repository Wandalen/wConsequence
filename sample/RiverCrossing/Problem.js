/*
  A particular river crossing is shared by both Linux hackers and Microsoft employees. A boat is used to cross the river,
 but it only seats four people, and must always carry a full load. In order to guarantee the safety of the hackers, you
 cannot put three employees and one hacker in the same boat; similarly, you cannot put three hackers in the same boat
 as an employee. To further complicate matters, there is room to board only one boat at a time; a boat must be taken
 across the river in order to start boarding the next boat. All other combination are safe. Two procedures are needed,
 HackerArrives and EmployeeArrives, called by a hacker or employee when he/she arrives at the river bank. The
 procedures arrange the arriving hackers and employees into safe boatloads. To get into a boat, a thread calls
 BoardBoat(); once the boat is full, one thread calls RowBoat(). RowBoat() does not return until the boat has left
 the dock.
  Assume BoardBoat() and RowBoat() are already written. Implement HackerArrives() and EmployeeArrives(). These methods
 should not return until after RowBoat() has been called for the boatload. Any order is acceptable (again, don't worry
 about starvation), and there should be no busy-waiting and no undue waiting (hackers and employees should not wait if
 there are enough of them for a safe boatload).

  source: https://inst.eecs.berkeley.edu/~cs162/sp10/hand-outs/synch-problems.html
 */

if( typeof module !== 'undefined' )
{
  var _ = require( 'wTools' );
}

var hackersEmployeesArrive =
  [
    { name : 'Alfred', fraction: 'employee', delay: 1000 },
    { name : 'Jane',   fraction: 'hacker',   delay: 1000 },
    { name : 'Derek',  fraction: 'hacker', delay: 2000 },
    { name : 'Bob',    fraction: 'hacker',   delay: 2500 },
    { name : 'Sean',   fraction: 'hacker',   delay: 3000 },
    { name : 'Martin', fraction: 'employee', delay: 3000 },
    { name : 'Joe',    fraction: 'employee', delay: 4000 },
    { name : 'Jon',    fraction: 'hacker',   delay: 4500 },
    { name : 'Bet',    fraction: 'employee',   delay: 5000 },
    { name : 'Patric', fraction: 'hacker',   delay: 5000 },
    { name : 'Lina',   fraction: 'employee', delay: 6000 },
    { name : 'Tim',    fraction: 'employee', delay: 6000 },
  ];

var peopleOnBoard = [];

function peopleArrive()
{
  var i = 0,
    len = hackersEmployeesArrive.length;

  for( ; i < len; i++ )
  {
    var person = hackersEmployeesArrive[ i ];

    setTimeout( ( function( person )
    {
      if( person.fraction === 'hacker' )
      {
        this.hackerArrives( person );
      }
      else if( person.fraction === 'employee' )
      {
        this.employeeArrives( person );
      }
    }).bind( this, person ),  hackersEmployeesArrive[ i ].delay );
  }
}

function hackerArrives( hacker )
{
  console.log( 'hacker ' + hacker.name + 'arrive to river' );
  this.boardBoat( hacker );
}

function employeeArrives( employee )
{
  console.log( 'employee ' + employee.name + 'arrive to river' );
  this.boardBoat( employee );
}

function boardBoat( person )
{
  peopleOnBoard.push( person );
  if( peopleOnBoard.length === 4 )
  {
    this.rowBoat();
  }
}

function rowBoat()
{
  var employeers = 0,
    l = 4;
  while( l-- )
  {
    if ( peopleOnBoard[ l ].fraction === 'employee' )
      employeers++;
  }
  if (employeers === 1 || employeers === 3)
  {
    console.log( 'problem: safety not guaranteed' );
  }
  else
  {
    console.log( 'row boat: safety on board guaranteed' );
  }
  peopleOnBoard = [];
}

var Self =
{
  peopleArrive: peopleArrive,
  hackerArrives: hackerArrives,
  employeeArrives: employeeArrives,
  boardBoat: boardBoat,
  rowBoat: rowBoat
};

//

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
  if( !module.parent )
    Self.peopleArrive();
}