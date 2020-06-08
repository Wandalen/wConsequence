#  Sleeping barber

  Sleeping barber Problem is classical synchronization problem

  Problem description:

  There are the barber shop with one barber one barber chair, and n sits in waiting room. When no clients are in barber
  shop, barber go to sleep. Clients visit shop in any time, independently each other. When client arrived to shop, he
  check if in waiting room are someones. If someone waiting, he try to place in queue if there are free seat. If waiting,
  room is empty, client go to barber and check, if barber chair is free, he wake up barber, and begin cut one's hair.
  Else place first seat in waiting room. When no places in waiting room, client go off.
  When barber end to cut client, he go to waiting room and take next client. If room is empty barber go to sleep again.

  The Sleeping Barber problem is a partial case of a Producer-Consumer problem (see appropriate sample).

  ![sleeping barber diagram]
  (./SleepingBarber.png)