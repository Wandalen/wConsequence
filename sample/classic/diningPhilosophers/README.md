#  Dining philosophers

  The Dining philosophers Problem is classical synchronization problem.

  - Problem description:

  5 (N in common case) philosophers sit around a table thinking and eating. Periodically, a philosopher gets hungry and
  tries to pick up the forks on his left and on his right. A philosopher may only pick up one fork at a time and,
  obviously, cannot pick up a chopstick already in the hand of neighbor philosopher.

  ![An illustration of the dining philosophers problem]
  (./An_illustration_of_the_dining_philosophers_problem.png)

  image source: https://en.wikipedia.org/wiki/Dining_philosophers_problem

  The solution based on wConsequence offer the next:
  1. ech fork represents its onw wConsequence
     - when fork wConsequence is resolved by message, we consider that its fork is free.
     - when philosopher get fork, he got its wConsequence message, and we consider that without message fork is locked
     for other philosophers
  2. When philosopher gets hungry he queue up for both of his forks;
     - for that using _.Consequence().andGet() method with both fork`s wConsequences as arguments.
     - when become philosopher`s turn in both fork`s queue, the andGet() invokes, and then philosopher gets both forks,
     and start eat.
     - after eating philosopher take messages for wConsequences of forks, that signals to the next philosophers in
     forks queues that they are free.