/* qqq : implement */
let _;

if( typeof module !== 'undefined' )
{
  _ = require( 'wTools' );
  require( 'wConsequence' );
}

const startTime = _.time.now();
const con = new _.Consequence();
const buffer = [];
const consumerStatus = 'sleep';
const producerStatus = 'awake';

run();

//

function run()
{
  console.log( 'hello world!' );
}

//

function status()
{

}

//

function changeStatus()
{
  
}

//

function produce()
{

}

//

function consume()
{

}
