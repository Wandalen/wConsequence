/**
 * @file This sample demonstrates using wConsequence for synchronization the several asynchronous process by example of
 * sleeping barber problem. In this example appending clients in barber shop and servicing them by barber are
 * asynchronous.
 */

if( typeof module !== 'undefined' )
{
  var _ = require( 'wTools' );
  /* require( 'wConsequence' ); */
  require( '../staging/abase/syn/Consequence.s' );
}

/**
 * Class barber simulate work barber in barber shop.
 * @class Barber
 */

class Barber
{

  constructor()
  {
    this.sleep(); /* on begin barber open barber shop, but clients */
    this._workSequence = wConsequence();
  }

  get state()
  {
    return this._state;
  }

  sleep()
  {
    this._stateSet( Barber.SLEEP_STATE );
  };

  wakeUp( client )
  {
    this._stateSet( Barber.WORKING );
    console.log( `begins haircut client ${client.name}` );
    var con = _.timeOut( this._getDelay() ); /* process takes some time; */
    con.then_( () =>
    {
      this.cutClient( null, client );
    }).got( () =>
    {
      this.takeNextClient(); /* after finish, barber got to waiting room and check for client in queue. */
    })
  }

  takeNextClient()
  {

    /* barber check if someone waiting in queue; */
    if( this._waitingRoom.messagesGet().length === 0 )
    return this._stateSet( Barber.SLEEP_STATE );

    /* if someone waiting, barber take him and start cutting despite resistance */
    this._waitingRoom.got( (err, client) =>
    {
      console.log( `Waiting room: ${client.name} leave queue` );
      console.log(`Waiting room: ${this._waitingRoom.messagesGet().length} places is occupied;` );
      console.log( `begins haircut client ${client.name}` );
      var delayed = _.timeOut( this._getDelay() ); /* process take some time; */
      delayed.then_( () =>
      {
        this.cutClient( null, client ); /* finish with current client */
      })
      .got( () => /* after that, barber go to waiting room for next client. */
      {
        this.takeNextClient()
      });
    })

  }

  _stateSet( state )
  {

    if( state === Barber.WORKING_STATE && this._state === Barber.SLEEP_STATE )
    console.log( 'waking up' ); /* barber wakes up and start haircut client, who wakes him. */
    else if( state === Barber.SLEEP_STATE && this._state === Barber.WORKING_STATE )
    console.log( 'slep zzzzzzzzzz' );

    this._state = state;
  }

  _getDelay()
  {
    var [ max, min ] = Barber.DURATION_OF_WORK_RANGE;
    return Math.floor( Math.random() * (max - min + 1)) + min;
  }

  cutClient( err, client )
  {
    console.log( `client ${client.name} cutted` );
    client.state = Client.HAIRCUT_FINISHED_STATE;
  }

  waitingRoomSet( con )
  {
    this._waitingRoom = con;
  }

  meet( client )
  {

    if ( barber.state === Barber.SLEEP_STATE ) /* if no client and barber sleep, client wakes him */
    {
      barber.wakeUp( client );
      return true;
    }
    else if( !this._waitingRoom.messagesGet().length < Barber.BARBER_NUM_SITS ) /* else client try to place client in queue */
    {
      this._waitingRoom.give( client );
      return true;
    }

    console.log( `all seats in waiting room are occupied, so client ${client.name} leave shop` );
    return false;
  }

}

Barber.SLEEP_STATE = 'sleep';
Barber.WORKING_STATE = 'work';
Barber.DURATION_OF_WORK_RANGE = [ 500, 3000 ];
Barber.BARBER_NUM_SITS = 3;

//

/**
 * Represent barber client
 * @class Customer
 */

class Client
{
  constructor(name)
  {
    this.name = name;
    this.state = Client.HAIRCUT_NO_STATE;
  }
}

Client.HAIRCUT_FINISHED_STATE = 1;
Client.HAIRCUT_NO_STATE = 0

//

/**
 * Class container for wConsequence that represent queue in waiting room.
 * Main goal of this class is to limit places in queue.
 * @class WaitingRoom
 */
/*
class WaitingRoom
{
  constructor()
  {
    this.shopQueueLength = 0;
    this.con = wConsequence();
  }

  push( client )
  {
    if( this.shopQueueLength < WaitingRoom.BARBER_NUM_SITS ) // if in queue is free sit, client occupied it.
    {
      this.shopQueueLength++;
      console.log( `Waiting room: ${client.name} take place in queue;` );
      console.log( `Waiting room: ${this.shopQueueLength} places is occupied;` );
      this.con.give( client );
      return true;
    }
    return false;
  }
}

WaitingRoom.BARBER_NUM_SITS = 4;
waitingRoom = new WaitingRoom();
*/

waitingRoom = new wConsequence();
barber = new Barber();
barber.waitingRoomSet( waitingRoom );

var clientsList = // list of clients
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

/**
 * Used to simulate clients visiting hairdresser
 * @param {wConsequence} con - this parameter represent sequence of clients that go to barber shop
 * @returns {wConsequence}
 */

function clientsGenerator( con )
{
  var i = 0,
    len = clientsList.length;

  for( ; i < len; i++ )
  {
    var client = { name : clientsList[ i ].name };
    setTimeout(( function( client )
    {
      /* sending clients to shop */
      con.give( client );
    }).bind( null, client ), clientsList[ i ].arrivedTime );
  }

  return con;
}

//

/* initializing */

var clientSequence = wConsequence();
var time = _.timeNow();

/* listening for client appending in shop */

clientSequence.persist( ( err, client ) =>
{

  if( err )
  throw _.errLog( err );

  /* clients arrived to barber shop */
  console.log( 'new client is coming : ' + client.name + _.timeSpent( ' ',time ) );

  barber.meet( client );

});

/* send clients to barber shop. */

clientsGenerator( clientSequence );
