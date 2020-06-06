/**
 * @file This sample demonstrates simulation of visiting barber shop by clients.
 */

if( typeof module !== 'undefined' )
{
  let _ = require( 'wTools' );
  require( 'wConsequence' );
}

let _ = _global_.wTools;
let startTime = _.time.now();
let clientsList =
[
  { name : 'Jon', arrivedTime : 500 },
  { name : 'Alfred', arrivedTime : 5000 },
  { name : 'Jane', arrivedTime : 5000 },
  { name : 'Derek', arrivedTime : 1500 },
  { name : 'Bob', arrivedTime : 4500 },
  { name : 'Sean', arrivedTime : 6500 },
  { name : 'Martin', arrivedTime : 2500 },
  { name : 'Joe', arrivedTime : 7000 },
];

//

let Self =
{
  run,
  clientArrive,
}

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
  if( !module.parent )
  Self.run();
}

/* qqq : make sure routines goes after instructions */

//

function run()
{
  let self = this;
  let i = 0;
  let len = clientsList.length;

  for( ; i < len; i++ )
  {
    let client = { name : clientsList[ i ].name };
    // let time = _.time.now();
    _.time.out( clientsList[ i ].arrivedTime, () => self.clientArrive( client ) );
  }
}

/* qqq : remove all bind in all samples */
/* qqq : simplify maybe */

//

function clientArrive( client )
{
  /* clients arrived to barber shop */
  console.log( 'new client is coming : ' + client.name + _.time.spent( startTime ) ); /* qqq : replace such strings with `-strings */
}
