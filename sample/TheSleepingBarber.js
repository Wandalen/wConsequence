
if( typeof module !== 'undefined' )
{
  var _ = require( 'wTools' );
  /* require( 'wConsequence' ); */
  require( '../staging/abase/syn/Consequence.s' );
}

class Barber {
  constructor()
  {
    this.sleep();
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
      this._queue.con.then_( (err, client) => { // if someone waiting, barber take him and start cutting despite resistance
        console.log( '->>>>>>>>>>>>' + JSON.stringify( client ) );
        console.log( `Waiting room: ${client.name} leave queue` );
        this._queue.shopQueueLength--; // place in the queue is freed
        console.log( `begins haircut client ${client.name}` );
        var delayed = _.timeOut( this._getDelay() ); // process take some time;
        delayed.then_( () => {
          this.cutClient( null, client ); // finish with current client
        } )
        .got( () => // after that, barber got to waiting room for next client.
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

  _setStateToSleep() {
    this._state = Barber.SLEEP_STATE;
  }

  _getDelay() {
    var [ max, min ] = Barber.DURATION_OF_WORK_RANGE;
    return Math.floor( Math.random() * (max - min + 1)) + min;
  }

  cutClient( err, client )
  {
    console.log( `client ${client.name} cutted` );
    client.state = Customer.HAIRCUT_FINISHED_STATE;
  }

  serveQueue( con ) {
    this._queue = con;
  }
}

Barber.SLEEP_STATE = 'sleep';
Barber.WORKING_STATE = 'work';
Barber.DURATION_OF_WORK_RANGE = [ 500, 3000 ];

class Customer {
  constructor(name) {
    this.name = name;
    this.state = Customer.HAIRCUT_NO_STATE;
  }
}

Customer.HAIRCUT_FINISHED_STATE = 1;
Customer.HAIRCUT_NO_STATE = 0

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
      this.con.give( client );
      return true;
    }
    return false;
  }
}

WhaitingRoomQueue.BARBER_NUM_SITS = 4;

;

var customersList =  // test finite list, in generally we must TODO: create infinity customers generation
  [
    { name: 'Jon', arrived: 500 },
    { name: 'Alfred', arrived: 5000 },
    { name: 'Jane', arrived: 5000 },
    { name: 'Derek', arrived: 1500 },
    { name: 'Bob', arrived: 4500 },
    { name: 'Sean', arrived: 6500 },
    { name: 'Martin', arrived: 2500 },
    { name: 'Joe', arrived: 9000 },
  ];

function custromerGenerator( con )  // used to simulate customers visiting hairdresser (draft version)
                                    // TODO: make customer generation with using wConsequence synchronisation, without
                                    // unnecessary actions
{
  for ( let customer of customersList )
  {
    let cust = new Customer( customer.name );
    let delayCon = wConsequence();
    delayCon.thenTimeOut( customer.arrived, (err, value) => {
      console.log( 'customer send: ' + value.name );
      con.give(value)
    } );
    delayCon.give( cust );
  }
  return con;
}

var clientSequence = wConsequence();
var waitingRoomQueue = new WhaitingRoomQueue();
var barber = new Barber();
barber.serveQueue( waitingRoomQueue );



clientSequence.persist( ( err, client ) =>
{
  if( err ) throw new Error( err );

  // clients arrived to barber shop
  console.log( 'new customer is coming: ' + client.name );

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

custromerGenerator( clientSequence );