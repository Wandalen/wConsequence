# Інспектування `наслідку`

Як правильно перевірити стан [наслідку](../concept/Consequence.md#наслідок) та взаємодіяти із його
вмістом([ресурсами](../concept/Resource.md#ресурс) і [конкурентами](../concept/Competitor.md#конкурент)),
в ході виконання програми.

Вміст `наслідку` не залишається сталим, а змінюється, тому важливо розуміти як саме і за яких обставин.
Нас цікавлять `ресурси` та `конкуренти`, їх наявність чи відсутність, кількість і тип, а також дії, що викликають
зміни цих показників в ході виконання програми.

В ході написання коду часто виникає необхідність виконати дебаг. Швидко це можна зробити за допомогою приведення `наслідку`
в рядок та виведення його в консоль.
В результаті отримаємо вивід вигляду - Consequence:: numberOfResources / numberOfCompetitors.
```js
var con = new _.Consequence();
console.log( con ); // Consequence:: 0 / 0

con.then( () => null );
console.log( con ); // Consequence:: 0 / 1

con.catch( ( err ) => err );
console.log( con ); // Consequence:: 0 / 2

con.take( 'myArg' );
console.log( con ); // Consequence:: 1 / 0
```
При передачі `наслідку` аргументом у `.console.log()` автоматично викликається його рутина `.toString()` із налаштуваннями за
замовчуванням. Існує аналогічна їй рутина `.toStr()`. Вони обидві можуть приймати мапу з опцією `verbosity`, яка встановлює
детальність виводу. За замовчуванням - `{ verbosity : 1 }`. Можемо отримати більш детальний опис `наслідку`.
```js
var con = _.Consequence();

console.log( con.toStr({ verbosity : 2 }) );
/*
Consequence::
  argument resources : 0
  error resources : 0
  early competitors : 0
  late competitors : 0
*/
```

Якщо маємо декілька `наслідків`, то для зручності задамо кожному з них `tag`, за яким зможемо ідентифікувати вивід.
```js
var con1 = new _.Consequence({ tag : 'con1' });
var con2 = new _.Consequence({ tag : 'con2' });

console.log( con1 );// Consequence::con1 0 / 0

console.log( con2 ); // Consequence::con2 0 / 0
```

Також можна перевірити не тільки кількість ресурсів та конкурентів, а й подивитись значення будь-якого з них.
```js
var con = new _.Consequence( { capacity : 0 } );

con.then( ( arg ) => arg + 'fromThen' );
con.catch( ( err ) => err );

// routine .competitorsGet() returns an array of competitor objects
console.log( con.competitorsGet()[ 1 ] ); // { competitor settings... }

con.take( 'myArg1' );

// routine .resourcesGet() returns an array of resource objects
console.log( con.resourcesGet() );
/*
[
  [Object: null prototype] { error: undefined, argument: 'myArg1fromThen' }
]
*/

con.take( 'myArg2' );

// routine .argumentsGet() returns an array of "argument" property values
// every resource is an object that has "argument" property in which the value of the passed resource is written
console.log( con.argumentsGet() ); // [ 'myArg1fromThen', 'myArg2' ]
```

[Повернутись до змісту](../README.md#туторіали)
