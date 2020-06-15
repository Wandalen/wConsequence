# Ресурс

Одним із двох видів данних, що можуть міститись у [наслідку](./Consequence.md#наслідок) є `ресурс` - дані, що передаються
у `наслідок` для подальшої обробки.

По своїй суті, ресурс це об'єкт, що містить дві властивості - `error` та `argument`, в одну з яких записується значення
переданого ресурсу.
Ресурси поділяються на два види - [аргумент](./ResourceArgument.md#ресурс-аргумент) або [помилка](./ResourceError.md#ресурс-помилка).
Якщо переданий у наслідок ресурс є `ресурсом-аргументом`, то його значення записується у поле `argument`, а поле `error`
залишаєтьcя невизначеним - `undefined`, якщо ж ресурс є `ресурсом-помилкою` - все навпаки.\
Щоб наслідок розрізняв види ресрусів, необхідно по-різному їх передати у наслідок, а саме - використати
відповідні для кожного виду ресурсу рутини.
```js
// The `capacity` property determines how many resources can be in the resource queue at a time.
// value 0 - removes restrictions, by default is 1.
var con = new _.Consequence({ capacity : 0 });

// the resource passed using .take() is perceived as a resource-argument
con.take( 'my resource1' );
con.take( 'my resource2' );

// the resource passed using .error() is perceived as a resource-error
con.error( _.errAttend( 'my error' ) );

// .resourcesGet() returns an array of resources
console.log( con.resourcesGet().length ); // logs: 3

console.log( con.resourcesGet()[ 0 ] ); // logs: [Object: null prototype] { error: undefined, argument: 'my resource1' }
console.log( con.resourcesGet()[ 2 ] ); /* logs:
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

Після появи ресурсу в черзі ресурсів, перевіряється наявність конкурентів у черзі конкурентів. Якщо такі є, то
викликається перший із черги із передачею в нього ресурсу. Якщо конкурентів немає, то наслідок не буде очікувати на їх появу.
```js
var con = new _.Consequence();

// .take() passes the resource to the queue.
con.take( 'my resource1' );
console.log( con.resourcesGet().length ); // logs: 1

// right after the resource appears in the queue, the callback function that was passed
// to .thenGive()is invoked with this resource as a parameter
con.thenGive( ( argument ) => console.log( argument ) ); // logs: my resource1
console.log( con.resourcesGet().length ); // logs: 0
```

**Підсумок:**

- `ресурс` - це об'єкт, що знаходиться у черзі ресурсів та передається у рутин конкурента, як параметр;
- `ресурс` може бути повернений у чергу, або ні;


[Повернутись до змісту](../README.md#концепції)
