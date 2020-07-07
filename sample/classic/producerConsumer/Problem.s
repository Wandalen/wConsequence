/*
* The problem describes two processes, the producer and the consumer, who share a common, fixed-size buffer used as a
* queue. The producer's job is to generate data, put it into the buffer, and start again. At the same time, the consumer
* is consuming the data (i.e., removing it from the buffer), one piece at a time. The problem is to make sure that the
* producer won't try to add data into the buffer if it's full and that the consumer won't try to remove data from an
* empty buffer.
*
* Consumer discard his product if he cant store it into buffer.
*
* source : https://en.wikipedia.org/wiki/Producer%E2%80%93consumer_problem
*/
/**
 * @file This sample demonstrates using wConsequence for synchronization the several asynchronous process by example of
 * 'Producer-Consumer' problem. In this example producing and consuming are asynchronous.
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
  run,
  produceGoods
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
  setInterval( this.produceGoods, 1500 );
  console.log( `producer starts to work - ${_.time.spent( startTime )}` );
}

//

function produceGoods()
{
  /* a producer created the goods */
  console.log( `+ producer added goods - ${_.time.spent( startTime )}` );
}

/* aaa Artem : done. rewrite */

/* */

// let _;

// if( typeof module !== 'undefined' )
// {
//   _ = require( 'wTools' );
// }

// //

// let eventList =
// [

//   { emitter : 'consumer', delay : 1000 },
//   { emitter : 'producer', item : '1', delay : 1500 },
//   { emitter : 'consumer', delay : 3000 },
//   { emitter : 'producer', item : '2', delay : 5000 },
//   { emitter : 'producer', item : '3', delay : 5000 },
//   { emitter : 'producer', item : '4', delay : 1500 },
//   { emitter : 'consumer', delay : 3000 },
//   { emitter : 'consumer', delay : 3500 },
//   { emitter : 'consumer', delay : 4000 },
//   { emitter : 'producer', item : '5', delay : 4500 },
//   { emitter : 'producer', item : '6', delay : 6500 },
//   { emitter : 'consumer', delay : 6000 },
//   { emitter : 'consumer', delay : 6500 },
//   { emitter : 'producer', item : '7', delay : 2500 },
//   { emitter : 'producer', item : '9', delay : 7000 },
//   { emitter : 'producer', item : '10', delay : 7500 },
//   { emitter : 'producer', item : '11', delay : 8000 },
//   { emitter : 'producer', item : '12', delay : 8500 },
//   { emitter : 'producer', item : '13', delay : 9500 },
//   { emitter : 'producer', item : '14', delay : 10000 },
//   { emitter : 'producer', item : '15', delay : 10500 },
//   { emitter : 'consumer', delay : 13000 },
//   { emitter : 'consumer', delay : 14000 },
//   { emitter : 'consumer', delay : 15000 },

// ];

// //

// function generateEvents()
// {
//   let i = 0;
//   let len = eventList.length;

//   for( ; i < len; i++ )
//   {
//     let event = eventList[ i ];
//     setTimeout( ( function( event )
//     {
//       if( event.emitter === 'producer' )
//       {
//         this.produce( event.item );
//       }
//       else if( event.emitter === 'consumer' )
//       {
//         this.consume();
//       }
//     } ).bind( this, event ), eventList[ i ].delay );
//   }
// }


// //

// function produce( item )
// {
//   console.log( 'producer wants to produce item' + _.time.spent( ' at', this.time ) );
// }

// //

// function consume()
// {
//   console.log( 'consumer wants to consume item' + _.time.spent( ' at', this.time ) );
// }

// //

// function init()
// {
//   this.time = _.time.now();;
//   this.generateEvents();
// }

// //

// let Self =
// {
//   //buffer : buffer,
//   generateEvents,
//   produce,
//   consume,
//   init,
// };

// //

// if( typeof module !== 'undefined' )
// {
//   module[ 'exports' ] = Self;
//   if( !module.parent )
//     Self.init();
// }
