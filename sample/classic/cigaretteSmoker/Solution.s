/**
 *  * 'Cigarette Smoker'. In this example, agent puts items on the table asynchronously.
*/

let _,
  Problem;

if( typeof module !== 'undefined' )
{
  _ = require( 'wTools' );
  require( 'wConsequence' );
  Problem = require( './Problem.s' );
}

const con = new _.Consequence().take( null );
const startTime = _.time.now();
const smokers =
[
  { id : 1, smokingTime : 3000, item : 'tobacco', justSmoked : false },
  { id : 2, smokingTime : 3500, item : 'paper' },
  { id : 3, smokingTime : 2500, item : 'matches' },
];
let items = [];
let rounds = 10;

Problem.putItems = putItems;
Problem.run();

//

function status()
{
  return `time: ${_.time.spent( startTime )}, items on the table: ${items}`;
}

//

function putItems( justFinishedSmoker )
{
  if( justFinishedSmoker )
  {
    con.then( () =>
    {
      const nextSmokers = smokers.filter( ( s ) => s.id !== justFinishedSmoker.id );
      if( nextSmokers[ 0 ].id === 1 && nextSmokers[ 1 ].id === 2 )
      {
        items.push( justFinishedSmoker.item, nextSmokers[ 1 ].item );
        console.log( `agent puts items on the table - ${status()}` );
        return smoke( nextSmokers[ 0 ] );
      }
      else if( nextSmokers[ 0 ].id === 1 && nextSmokers[ 1 ].id === 3 )
      {
        items.push( justFinishedSmoker.item, nextSmokers[ 0 ].item );
        console.log( `agent puts items on the table - ${status()}` );
        return smoke( nextSmokers[ 1 ] );
      }
      else
      {
        items.push( justFinishedSmoker.item, nextSmokers[ 1 ].item );
        console.log( `agent puts items on the table - ${status()}` );
        return smoke( nextSmokers[ 0 ] );
      }
    });
  }
  else
  {
    con.then( () =>
    {
      items.push( smokers[ 1 ].item, smokers[ 2 ].item );
      console.log( `agent puts items on the table - ${status()}` );
      return smoke( smokers[ 0 ] );
    });
  }

  // if( !justFinishedSmoker )
  // {
  //   con.then( () =>
  //   {
  //     items.push( smokers[ 1 ].item, smokers[ 2 ].item );
  //     console.log( `agent puts items on the table - ${status()}` );
  //     return smoke( smokers[ 0 ] );
  //   });
  // }
  // else
  // {
  //   con.then( () =>
  //   {
  //     const nextSmokers = smokers.filter( ( s ) => s.id !== justFinishedSmoker.id );
  //     if( nextSmokers[ 0 ].id === 1 && nextSmokers[ 1 ].id === 2 )
  //     {
  //       items.push( justFinishedSmoker.item, nextSmokers[ 1 ].item );
  //       console.log( `agent puts items on the table - ${status()}` );
  //       return smoke( nextSmokers[ 0 ] );
  //     }
  //     else if( nextSmokers[ 0 ].id === 1 && nextSmokers[ 1 ].id === 3 )
  //     {
  //       items.push( justFinishedSmoker.item, nextSmokers[ 0 ].item );
  //       console.log( `agent puts items on the table - ${status()}` );
  //       return smoke( nextSmokers[ 1 ] );
  //     }
  //     else
  //     {
  //       items.push( justFinishedSmoker.item, nextSmokers[ 1 ].item );
  //       console.log( `agent puts items on the table - ${status()}` );
  //       return smoke( nextSmokers[ 0 ] );
  //     }
  //   });
  // }
}

//

function smoke( smoker )
{
  items = [];
  console.log( `+ smoker_${smoker.id} starts to smoke - ${status()}` );
  if( rounds > 0 )
  return _.time.out( smoker.smokingTime )
  .then( () =>
  {
    rounds--;
    let finished = finishSmoking( smoker );
    return finished ? finished : null;
  });
  return null;
}

//

function finishSmoking( smoker )
{
  console.log( `- smoker_${smoker.id} finished to smoke - ${status()}` );
  return putItems( smoker );
}

/* aaa Artem : done. implement */
