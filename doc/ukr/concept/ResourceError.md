# Ресурс-`помилка`

Це об'єкт, один із двох видів [ресурсів](./Resource.md#ресурс), що передається у [наслідок](./Consequence.md#наслідок).

До `ресурсів-помилок` відносяться ресурси, які були передані у наслідок за допомогою рутини `.error(resource)`.
Значення такого ресурсу записується в поле `error`, об'єкта, що створюється і поміщається в чергу ресурсів, і представляє
собою переданий ресурс для подальшої з ним взаємодії. А його інше поле `argument` залишаєтьcя невизначеним.
```js
var con = new _.Consequence();

con.error( _.errAttend( 'my error' ) );

// .resourcesGet() returns an array of resources
console.log( con.resourcesGet().length ); // logs: 1

console.log( con.resourcesGet()[ 0 ] );
/* logs:
[Object: null prototype] {
  error:  = Message of error#1
      my error

   = Beautified calls stack
      ...

   = Throws stack
      ...
  ,
  argument: undefined
}
*/
```

Аналогом `ресурсу-помилки` є дані, які передаються у функцію `reject( data )` при використанні `Promise`.\
Важливо розуміти, що `ресурс-помилка` буде оброблятись тільки тими конкурентами, які призначені для його обробки.
```js
var con = new _.Consequence();

// the passed resource-error will not be processed by competitors that go before .catch() in the queue
con.then( ( arg ) =>
{
  console.log( arg );
  return 'from then1';
} );

// competitor that processes resource-error should return something
con.catch( ( err ) =>
{
  console.log( err );
  return 'from error';
} );

// next competitor after .catch() gets return value
con.then( ( arg ) =>
{
  console.log( arg );
  return 'from then2';
} );

con.thenGive( ( arg ) => console.log( arg ) );

con.error( _.errAttend( 'my error' ) );
/* logs:
 = Message of error#2
    my error

 = Beautified calls stack
    ...

 = Throws stack
    ...

from error
from then2
*/
```
В даному прикладі, в наслідок передається `ресурс-помилка`, який буде оброблений тільки конкурентом доданим за
допомогою `.catch()`.

Детальніше про особливості обробки різних видів ресурсів можна ознайомитись у туторіалі -
[Два види ресурсів](../tutorial/TwoKindOfResources.md#два-види-ресурсів).

**Підсумок:**

- `ресурс-помилка` це ресурс, що був переданий у наслідок за допомогою рутини `.error()`;
- у поле `error` об'єкта, що створюється при передачі у наслідок ресурса-помилки, записується його значення,
  а поле `argument` залишається невизначеним;
- `ресурс-помилка` буде оброблений тільки конкурентом, що був доданий за допомогою рутини `.catch()`;

[Повернутись до змісту](../README.md#концепції)
