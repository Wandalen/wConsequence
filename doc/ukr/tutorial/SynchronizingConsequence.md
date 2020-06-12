# Синхронізація наслідку

Як виконати синхронізацію [наслідку](../concept/Consequence.md#наслідок) в синхронному коді.

У синхронному коді, ми можемо після передачі у наслідок ресурсу дістати його в необхідному нам місці. Для цього скористаємось
рутиною `.sync()`.
```js
var con = new _.Consequence();

function isEven( number, showResult )
{
  number % 2 ? showResult( _.errAttend( 'Number is not even!' ) ) : showResult( 'Іs even' );
}

isEven( 14, con );

console.log( con.sync() ); // logs: Іs even

var con = new _.Consequence();

isEven( 11, con )

console.log( con.sync() ); // logs error: Number is not even! and error log...
```
Як бачимо, рутина `.sync()`, повертає попередньо переданий, як ресурс-аргумент, так і ресурс-помилку.
Також, як можна помітити, після першої передачі ресурсу ми заново створюємо `наслідок`.
Якщо використати той самий наслідок, то отримаємо помилку.
```js
var con = new _.Consequence();

function isEven( number, showResult )
{
  number % 2 ? showResult( _.errAttend( 'Number is not even!' ) ) : showResult( 'Іs even' );
}

isEven( 14, con );

console.log( con.sync() ); // logs: Іs even

isEven( 11, con )

console.log( con.sync() ); // logs error: Cant return resource of consequence because it has 2 of such! and error log...
```
Отже, рутина `.sync()` може повернути щойно переданий ресурс тільки якщо він буде у черзі єдиним.

[Повернутись до змісту](../README.md#туторіали)
