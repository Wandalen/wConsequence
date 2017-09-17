if( typeof module !== 'undefined' )
{
  var _ = require( 'wTools' );
  /* require( 'wConsequence' ); */
  require( '../staging/dwtools/abase/syn/Consequence.s' );
  var Problem = require( './ProducerConsumerProblem.js' );
}

//

Problem.capacity = 2;
Problem.produced = wConsequence();

//

Problem.printInfo = function printInfo( item )
{
  console.log( 'buffer : ' + this.produced.messagesGet().length + ' / ' + Problem.capacity );
}

//

Problem.produce = function produce( item )
{

  console.log( 'producer wants to produce item' + _.timeSpent( ' at',this.time ) );

  if( this.produced.messagesGet().length === this.capacity )
  {
    console.log( 'too many products, producer discards his product' );
    return;
  }

  this.produced.give( item );
  console.log( 'producer produce item ' + item + _.timeSpent( ' at',this.time ) );

  this.printInfo();

}

//

Problem.consume = function( item )
{

  console.log( 'consumer wants to consume item' + _.timeSpent( ' at',this.time ) );
  this.produced.got( ( function( err,item )
  {

    console.log( 'consumer consumes item', item, _.timeSpent( 'at',this.time ) );
    this.printInfo();

  }).bind( this ) );

}

//

Problem.init();
