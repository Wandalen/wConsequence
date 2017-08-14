Scenario :
- What is wConsequence
- How it works:
 -- Glossary, list of terms that will be used in current lecture
    --- message
    --- queue
    --- messanger
    --- chainer
    --- correspondent
 -- The principle of work, simplest explanation that gives user enought info to start learn first api methods
    --- ?
- First dive into api
 -- Messangers : give, error
    --- give
        ---- Implement routine that returns consequence with single message that represents successful operation.
        ---- Implement routine that creates two consequences. Message of first consequence must represent successful operation, message of the second - failed operation. Return consequences in array. Only give routine must be used.
    --- error
        ---- Implement routine that returns consequence with single message that represents failed operation.
        ---- Implement routine that creates two consequences. Message of first consequence must represent failed operation, message of the second - successful operation. Return consequences in array. Both give and error routines must be used.
 -- Chainers :  got



How scenario goes:
When user opens this lecture, first paragraph appears, the user presses some key when he is ready to read next paragraph or wants to go to the previous paragraph.
If paragraph have tasks, info about api is given first, then user presses some key, task info appears on screen,
then user writes implementation in some *.js file, then writes in console (for example ) "wconsequence-workshop run filePath" -
to only run the code,  "wconsequence-workshop verify filePath" - to check if implementation passes the check.
If task is completed user can move forward to the next task or paragraph.

P.S. in browser version user must put code in text field and press a button, for move forward/backward arrows will be added



Text :

#### What is wConsequence?
wConsequence is a synchronization mechanism that will make your work with asynchronous code a lot easier!. Mechanism uses an idea of Promise, but resolves all it disadvantages. Also it replaces and includes functionality of many other elements of synchronization, such as: Callback, Event, Signal, Mutex, Semaphore, Async.

#### How it works?
 First of all lets make simple glossary to understand all definitions that we will use further:
 * message - is a key component of the consequence. It represents the result of some operation.
   It is an object with two properties: error and argument. 'error' - for errors, 'argument' - for result of successful execution;
 * correspondent - is a routine that handles message taken from the queue.
 * queue - FIFO data structure that holds messages and correspondents. Each instance of consequence has 2 queues, queue of messages and queue of correspondents;
 * messanger - is a kind of routines that adds message to the queue;
 * chainer - is a kind of routines that adds correspondent to the queue;

 Core features:
- Can transit to another state
- Can hold more than one message
- Can hold more than one message handler
- Dont need callbacks to resolve/reject a value
- Instead of Promise, consequence is not limited to the function that creates it. All operations are avaible through object that holds consequence instance.

How to  create wConsequence instance:
``` var consequence = new wConsequence();```

    When consequence is created it becomes able to send and handle unlimited amount of messages. For this purpose each instance of consequence has 2 FIFO queues( queue of messages and queue of correspondents ) and several kinds of routines-helpers with different functionality. In this tutorial we will use only two of them: messanger and chainer.
    When messanger adds message into queue consequence looks if handler was added by chainer to the correspondents queue. If handler exists, consequence gives message to the handler, otherwise waits( in background ) until some correspondent appears in queue. Message and correspondent can be used only once.
#### First dive into api

As already mentioned consequence has different kinds of routines. The two main kinds are messager and chainer which will be reviwed in this chapter.

##### Messangers:

 Two mostly used routines messangers are: give and error.

`wConsequence.give`:
Params : ( optional, any ) message

The `give` routine takes message as first argument and puts it into messages queue. If arguments is no provided, function adds empty
message to the queue.

Task "First message" :
    Create routine named `task`, that returns consequence with a single message in queue.

 As was mentioned before, each message in queue contains two properties : 'error' and 'argument'. This feature gives us a opportunity to have several states: 'resolved' - message without error, 'rejected' - message with error. Also is allowed to use two states together.
 Giving messages with different states is dead simple - just pass two arguments.
 Now parameters list will be :
    ( required, any ) err - value of 'rejected' state, 'null' if no error
    ( required, any ) argument - value of 'resolved' state

Task "Different states" :

    Create routine named `task`, that returns consequence with a three messages in order :
    1) Message with 'resolved' state.
    2) Message with 'rejected' state.
    3) Message with both states combined.

---------------

`wConsequence.error`:
This routine is alternative and the common way to give 'rejected' message.
Params : ( optional, any ) error
Routine works same as `give` with two arguments, but requires only first one.

Task "Error alternative" :

    Create routine named `task`, that returns consequence with one 'rejected' message.

Conclusions about `give` and `error` :
The `give` is commonly used for giving 'resolved' messages, but also its able messages with values of two states combined together.
Common `give` use cases :
 - Puts single 'resolved' message if single argument was passed. If error passed as single argument routine considers it as resolve value.
 - Puts single 'rejected' message if two arguments passed.
 - Puts single empty 'resolved' message if no arguments passed.
The `error` is the shortest way to give 'rejected' messages.

##### Chainers:

Consequence contains alot of chainers, but for now we are looking for the common chainer - `wConsequence.got`.

"Routine as correspondent" :

Firs of all, lets see how common correspondent looks like.
It's a routine that takes two arguments: first the 'rejected' value, second the 'resolved' value and makes some operations with that values. The`got` routine ignores return value of the correspondent, so for now we dont worry about it.

`wConsequence.got`:
Params : ( optional, routine ) correspondent

Routine takes correspondent's routine from first argument and puts it into a queue. If nothing passed puts empty routine.

Task "Add first handler" :
    Create routine correspondent's routine named 'handler', which takes two arguments( err, got ) and prints their values.
    Create routine named 'task' that returns consequence instance with 'handler' routine into correspondents queue.


--- Work with messages









