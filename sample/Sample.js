
if( typeof module !== 'undefined' )
require( 'wConsequence' );
var _ = wTools;
_.Consequence.UnhandledTimeOut = 1;
var t1 = _.time.now();
var con = new _.Consequence().error( 'x' )
con.catch( err => 
{ 
  var t2 = _.time.now();
  _.errAttend( err );
  console.log( 'Error attended in:', t2 - t1 )
  return null;
})


