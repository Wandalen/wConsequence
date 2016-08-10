/*
* The problem describes two processes, the producer and the consumer, who share a common, fixed-size buffer used as a
* queue. The producer's job is to generate data, put it into the buffer, and start again. At the same time, the consumer
* is consuming the data (i.e., removing it from the buffer), one piece at a time. The problem is to make sure that the
* producer won't try to add data into the buffer if it's full and that the consumer won't try to remove data from an
* empty buffer.
*
* source: https://en.wikipedia.org/wiki/Producer%E2%80%93consumer_problem
*/

if( typeof module !== 'undefined' )
{
  var _ = require( 'wTools' );
}

//

var eventList =
[
  { emitter: 'consumer', delay : 1000 },
  { emitter: 'producer', item : '1', delay : 1500 },
  { emitter: 'consumer', delay : 3000 },
  { emitter: 'producer', item : '2', delay : 5000 },
  { emitter: 'producer', item : '3', delay : 5000 },
  { emitter: 'producer', item : '4', delay : 1500 },
  { emitter: 'consumer', delay : 3500 },
  { emitter: 'consumer', delay : 5500 },
  { emitter: 'producer', item : '5', delay : 4500 },
  { emitter: 'producer', item : '6', delay : 6500 },
  { emitter: 'consumer', delay : 6000 },
  { emitter: 'consumer', delay : 6500 },
  { emitter: 'consumer', delay : 7500 },
  { emitter: 'consumer', delay : 8000 },
  { emitter: 'producer', item : '7', delay : 2500 },
  { emitter: 'producer', item : '8', delay : 7000 },
];

//

var buffer =
{
  size: 3,
  _items: [],
  appendItem: function( item )
  {
    if( this._items.length === this.size )
    {
      console.log( 'PROBLEM: buffer is overflow' );
    }
    else
    {
      this._items.push( item );
    }
  },
  getItem: function()
  {
    if( this._items.length === 0 )
    {
      console.log( 'PROBLEM: buffer is empty' );
    }
    else {
      return this._items.shift();
    }
  }
};

//

function eventGenerator(  )
{
  var i = 0,
    len = eventList.length;

  for( ; i < len; i++ )
  {
    var event = eventList[ i ];
    setTimeout( ( function( event )
    {
      if( event.emitter === 'producer' )
      {
        this.producerAppend( event.item );
      }
      else if( event.emitter === 'consumer' )
      {
        this.consumerGet();
      }
    } ).bind( this, event ),  eventList[ i ].delay );
  }
}


//

function producerAppend( item )
{
  buffer.appendItem( item );
}

//

function consumerGet()
{
  var item = buffer.getItem( item );
  console.log( 'handled item ' + item );
}

//

function init()
{
  this.eventGenerator();
}

//

var Self =
{
  buffer : buffer,
  eventGenerator : eventGenerator,
  producerAppend : producerAppend,
  consumerGet : consumerGet,
  init : init,
};

//

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
  if( !module.parent )
    Self.init();
}
