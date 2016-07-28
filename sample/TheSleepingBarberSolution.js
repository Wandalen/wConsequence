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

class Barber {
  constructor()
  {
    this.sleep(); // on begin barber open barber shop, but clients
    this._workSequence = wConsequence();
  }

  get state() {
    return this._state;
  }

  sleep() {
    console.log( 'slep zzzzzzzzzz' );
    this._setStateToSleep();
  };

  wakeUp( client ) {
    console.log( 'waking up' ); // barber wakes up and start haircut client, who wakes him.
    this._setStateToToWorking(Barber.WORKING);
    console.log( `begins haircut client ${client.name}` );
    var con = _.timeOut( this._getDelay() ); // process takes some time;
    con.then_( () =>
    {
      this.cutClient( null, client );
    }).got( () =>
    {
      this.takeNextClient(); // after finish, barber got to waiting room and check for client in queue.
    } )
  }

  takeNextClient()
  {
    if( this._queue.shopQueueLength > 0 ) // barber check if someone waiting in queue;
    {
      this._queue.con.got( (err, client) => { // if someone waiting, barber take him and start cutting despite resistance
        console.log( `Waiting room: ${client.name} leave queue` );
        this._queue.shopQueueLength--; // place in the queue is freed
        console.log(`Waiting room: ${this._queue.shopQueueLength} places is occupied;` );
        console.log( `begins haircut client ${client.name}` );
        var delayed = _.timeOut( this._getDelay() ); // process take some time;
        delayed.then_( () => {
          this.cutClient( null, client ); // finish with current client
        } )
        .got( () => // after that, barber go to waiting room for next client.
        {
          this.takeNextClient()
        });
      })
    }
    else // if room is empty got to sleep.
    {
      this._setStateToSleep();
    }
  }

  _setStateToToWorking()
  {
    this._state = Barber.WORKING_STATE;
  }

  _setStateToSleep()
  {
    this._state = Barber.SLEEP_STATE;
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

  serveQueue( con )
  {
    this._queue = con;
  }
}

Barber.SLEEP_STATE = 'sleep';
Barber.WORKING_STATE = 'work';
Barber.DURATION_OF_WORK_RANGE = [ 500, 3000 ];

/**
 * Represent barber client
 * @class Customer
 */

class Client {
  constructor(name)
  {
    this.name = name;
    this.state = Client.HAIRCUT_NO_STATE;
  }
}

Client.HAIRCUT_FINISHED_STATE = 1;
Client.HAIRCUT_NO_STATE = 0

/**
 * Class container for wConsequence that represent queue in waiting room.
 * Main goal of this class is to limit places in queue.
 * @class WhaitingRoomQueue
 */

class WhaitingRoomQueue {
  constructor()
  {
    this.shopQueueLength = 0;
    this.con = wConsequence();
  }

  push( client ) {
    if( this.shopQueueLength < WhaitingRoomQueue.BARBER_NUM_SITS ) // if in queue is free sit, client occupied it.
    {
      this.shopQueueLength++;
      console.log(`Waiting room: ${client.name} take place in queue;` );
      console.log(`Waiting room: ${this.shopQueueLength} places is occupied;` );
      this.con.give( client );
      return true;
    }
    return false;
  }
}

WhaitingRoomQueue.BARBER_NUM_SITS = 4;

var clientsList =  // test finite list, in generally we must TODO: create infinity customers generation
  [
    { name: 'Jon', arrivedTime: 500 },
    { name: 'Alfred', arrivedTime: 5000 },
    { name: 'Jane', arrivedTime: 5000 },
    { name: 'Derek', arrivedTime: 1500 },
    { name: 'Bob', arrivedTime: 4500 },
    { name: 'Sean', arrivedTime: 6500 },
    { name: 'Martin', arrivedTime: 2500 },
    { name: 'Joe', arrivedTime: 9000 },
  ];

/**
 * Used to simulate customers visiting hairdresser
 * @param {wConsequence} con this parameter represent sequence of clients that go to barber shop
 * @returns {wConsequence}
 */

function clientsGenerator( con )  // used to simulate customers visiting hairdresser (draft version)
                                    // TODO: make customer generation with using wConsequence synchronisation, without
                                    // unnecessary actions
{
  for ( let client of clientsList )
  {
    let clientObj = new Client( client.name );
    setTimeout( ( ( client ) =>
    {
      // sending clients to shop
      con.give (client );
    } ).bind(this, clientObj), client.arrivedTime );
  }
  return con;
}

// start process

// initializing
var clientSequence = wConsequence();
var waitingRoomQueue = new WhaitingRoomQueue();
var barber = new Barber();
barber.serveQueue( waitingRoomQueue );


// listening for client appending in shop
clientSequence.persist( ( err, client ) =>
{
  if( err ) throw new Error( err );

  // clients arrived to barber shop
  console.log( 'new client is coming: ' + client.name );

    if ( barber.state === Barber.SLEEP_STATE ) // if no client and barber sleep, client wakes him
    {
      barber.wakeUp( client );
    }
    else
    {
      if( !waitingRoomQueue.push(client) ) // else client try to place sit in queue
      {
        console.log( `all seats in waiting room are occupied, so client ${client.name} leave shop` );
      }
    }

});

// send clients to barber shop.
clientsGenerator( clientSequence );