/*
There are four processes in this problem: three smoker processes and an agent process. Each of the smoker processes will
make a cigarette and smoke it. To make a cigarette requires tobacco, paper, and matches. Each smoker process has one of the
three items. I.e., one process has tobacco, another has paper, and a third has matches. The agent has an infinite supply of
all three. The agent places two of the three items on the table, and the smoker that has the third item makes the cigarette.
Synchronize the processes.

source : http://www.cs.umd.edu/~hollings/cs412/s96/synch/smokers.html
*/
let _;

if( typeof module !== 'undefined' )
{
  _ = require( 'wTools' );
  require( 'wConsequence' );
}

const startTime = _.time.now();

//

let Self =
{
  run
}

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
  if( !module.parent )
  Self.run();
}

//

function run()
{

}

//


/* qqq implement */
