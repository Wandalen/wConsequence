#  Readers-Writers

  The Readers-Writers Problem is classical synchronization problem

  Problem description:

  There are some shared data item between several processes. Each process is classified as either a reader or writer.
Multiple readers may access the file simultaneously. A writer must have exclusive access (i.e., cannot share with either
a reader or another writer).

  ![readers diagram]
  (./readersWriters1.png)

  ![writers diagram]
  (./readersWriters2.png)