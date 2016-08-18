# Producer-Consumer

  Producer-Consumer is classical synchronization problem...

  The problem describes the buffer which can ststore n items, the producer process which creates the items and put it into
buffer, one at a time, and consumer process which take items from buffer and processes them, one at time.

  A producer cannot produce unless there is an empty buffer slot to fill.
  
  A consumer cannot consume unless there is at least one produced item.

  The partial case of a Producer-Consumer problem is a Sleeping barber problem (see appropriate sample).

![diagram1]
(./producerConsumer1.png)
![diagram2]
(./producerConsumer2.png)
![diagram3]
(./producerConsumer3.png)