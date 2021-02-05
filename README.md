# module::Consequence  [![status](https://github.com/Wandalen/wConsequence/workflows/publish/badge.svg)](https://github.com/Wandalen/wConsequence/actions?query=workflow%3Apublish) [![stable](https://img.shields.io/badge/stability-stable-brightgreen.svg)](https://github.com/emersion/stability-badges#stable)

Advanced synchronization mechanism. Asynchronous routines may use Consequence to wrap postponed result, what allows classify callback for such routines as output, not input, what improves analyzability of a program. Consequence may be used to make a queue for mutually exclusive access to a resource.

Algorithmically speaking Consequence is 2 queues ( FIFO ) and a customizable arbitrating algorithm. The first queue contains available resources, the second queue includes competitors for this resources. At any specific moment, one or another queue may be empty or full. Arbitrating algorithm makes resource available for a competitor as soon as possible. There are 2 kinds of resource: regular and erroneous. Unlike Promise, Consequence is much more customizable and can solve engineering problem which Promise cant. But have in mind with great power great responsibility comes. Consequence can coexist and interact with a Promise, getting fulfillment/rejection of a Promise or fulfilling it. Use Consequence to get more flexibility and improve readability of asynchronous aspect of your application.

### Try out from the repository
```
git clone https://github.com/Wandalen/wConsequence
cd wConsequence
npm install
node sample/trivial/Sample.s
```

## To add to your project
```
npm add 'wConsequence@alpha'
```
