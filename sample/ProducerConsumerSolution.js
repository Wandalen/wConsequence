if( typeof module !== 'undefined' )
{
  var _ = require( 'wTools' );
  /* require( 'wConsequence' ); */
  require( '../staging/abase/syn/Consequence.s' );
  var ProducerConsumerProblem = require( './ProducerConsumerProblem.js' );
}

function SProducerConsumerProblem()
{
  this.producerLock = wConsequence();
  for( var i = 0; i < this.buffer.size; i++)
    this.producerLock.give();

  this.consumerLock = wConsequence();
}

//

SProducerConsumerProblem.prototype = Object.create(ProducerConsumerProblem,
{

  producerAppend :
  {
    value : function( item )
    {

      this.producerLock.got( (function() {
        this.buffer.appendItem( item );
        this.consumerLock.give();
      }).bind( this ) )
    }
  },
  consumerGet :
  {
    value : function( item )
    {
      this.consumerLock.got( ( function() {
        var item = this.buffer.getItem( item );
        console.log( 'handled item ' + item );
        this.producerLock.give();
      }).bind( this ) )

    }
  }
});

var producerConsumerProblem = new SProducerConsumerProblem();

producerConsumerProblem.init();
