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
  { name : 'Jon', hair : 'long', arrivedTime : 500 },
  { name : 'Alfred', hair : 'short', arrivedTime : 5000 },
  { name : 'Jane', hair : 'average', arrivedTime : 5000 },
  { name : 'Derek', hair : 'long', arrivedTime : 1500 },
  { name : 'Bob', hair : 'average', arrivedTime : 4500 },
  { name : 'Sean', hair : 'short', arrivedTime : 6500 },
  { name : 'Martin', hair : 'average', arrivedTime : 2500 },
  { name : 'Joe', hair : 'long', arrivedTime : 7000 },
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

/* aaa Artem : done. make sure routines goes after instructions */
/* aaa Artem : done. remove all bind in all samples */
/* aaa Artem : done. simplify maybe */

//

function run()
{
  let self = this;

  for( let i = 0; i < clientsList.length; i++ )
  {
    let client = { name : clientsList[ i ].name, hair : clientsList[ i ].hair }
    _.time.out( clientsList[ i ].arrivedTime, () => self.clientArrive( client ) );
  }
}

//

function clientArrive( client )
{
  /* clients arrived to barber shop */
  console.log( `new client is coming : ${client.name} ${_.time.spent( startTime )}` ); /* aaa Artem : done. replace such strings with `-strings */
}
