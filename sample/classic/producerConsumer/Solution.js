/* aaa Artem : done. implement */
let _;

if( typeof module !== 'undefined' )
{
  _ = require( 'wTools' );
  require( 'wConsequence' );
}

const startTime = _.time.now();
const producerSwitcher = new _.Consequence().take( null );
const consumerSwitcher = new _.Consequence().take( null );
const bufferSize = 5;
const buffer = [];
const producer = { status : 'sleep', speed : 1500 }
const consumer = { status : 'sleep', speed : 3000 }
let producerTimerId,
  consumerTimerId;

run();

//

function run()
{
  producerSwitcher.then( () =>
  {
    producer.status = 'awake';
    producerTimerId = setInterval( produceGoods, producer.speed );
    console.log( `producer starts to work - ${status()}` );
    return null;
  } );
}

//

function status()
{
  return `${_.time.spent( startTime )}, bufferStatus: ${buffer.length}/${bufferSize}, producerStatus: ${producer.status}, consumerStatus: ${consumer.status}`
}

//

function produceGoods()
{
  buffer.push( 'goods' );
  console.log( `+ producer added goods - ${status()}` );

  if( buffer.length === 1 )
  consumerSwitcher.then( () =>
  {
    consumerTimerId = setInterval( consumeGoods, consumer.speed );
    consumer.status = 'awake';
    console.log( `consumer starts consumption - ${status()}` );
    return null;
  } );
  else if( buffer.length === bufferSize )
  producerSwitcher.then( () =>
  {
    clearInterval( producerTimerId );
    producer.status = 'sleep';
    console.log( `buffer is full, producer has stopped working - ${status()}` );
    return null;
  } );
}

//

function consumeGoods()
{
  buffer.pop();
  console.log( `- consumer took goods - ${status()}` );

  if( buffer.length === 0 )
  {
    consumerSwitcher.then( () =>
    {
      clearInterval( consumerTimerId );
      consumer.status = 'sleep';
      console.log( `buffer is empty, consumer has stopped consumption - ${status()}` );
      return null;
    } );

    if( producer.status === 'sleep' )
    producerSwitcher.then( () =>
    {
      producer.status = 'awake';
      producerTimerId = setInterval( produceGoods, producer.speed );
      console.log( `producer starts to work - ${status()}` );
      return null;
    } )
  }
}
