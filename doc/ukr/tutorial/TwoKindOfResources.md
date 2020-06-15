# Два види `ресурсів`

Які бувають види [ресурсів](../concept/Resource.md#ресурс), що передаються у [наслідок](../concept/Consequence.md#наслідок)
та як правильно їх обробляти.

Наслідок працює всього з двома видами ресурсів: 
- [ресурс-аргумент](../concept/ResourceArgument.md#ресурс-аргумент);
- [ресурс-помилка](../concept/ResourceError.md#ресурс-помилка);

Аргументом вважається будь-який ресурс, який не є об'єктом помилки:
```js
var con = new _.Consequence();

con.thenGive( ( arg ) => console.log( arg + 1 ) );
con.take( 'agr' ); // logs: arg1

con.thenGive( ( arg ) => console.log( arg.name ) );
con.take({ name : 'user1', age : 20 }); // logs: user1

con.thenGive( ( arg ) => console.log( arg + 1 ) );
con.take( 123 ); // logs: 124
```

Тепер передамо у наслідок об'єкт помилки:
```js
var con = new _.Consequence();

con.thenGive( ( arg ) => console.log( arg ) );

// _.errAttend( message ) - creating a processed error 
con.take( _.errAttend( 'Error!' ) );
// logs: error log...
```

У прикладах вище було розглянуто два види ресурсів, але різниця між ними не очевидна. Вони обоє обробляються конкурентом
`.thenGive()`, а це означає, що необхідно перевіряти вхідний параметр і в залежності від його виду - по-різному обробляти.
Такий підхід зовсім не зручний.

Для перехоплення помилок використовується спеціальний конкурент `.catch()`, який обробляє ресурс-помилку.
Для того, щоб `.catch()` був викликаний для обробки помилки, її необхідно передати у наслідок із допомогою `.error( err )`.
В такому разі першим із черги конкурентів опрацює передану помилку `.catch()`, він обов'язково повинен повернути значення,
яке буде передано наступному в черзі конкуренту.
```js
var con = new _.Consequence();

con.thenGive( ( arg ) => console.log( 'thenGive1 is invoked with: ', arg ) );
con.catch( ( arg ) =>
{
  console.log( 'catch is invoked with: ', arg );
  return 'from catch';
} );
con.thenGive( ( arg ) => console.log( 'thenGive2 is invoked with: ', arg ) );

con.error( _.errAttend( 'Error!' ) );
// logs: catch is invoked with:  error log...
// logs: thenGive2 is invoked with:  from catch

console.log( con ); // logs: Consequence:: 0 / 0
```
Важливо розуміти, що ті конкуренти, котрі були у черзі перед `.catch()` - не викличуться, проте все одно будуть видалені з
черги, і наступний переданий ресурс нікому буде опрацювати.

Корисним у використанні є конкурент `.finally()`, який може обробляти як `ресурс-помилку` так і `ресурс-аргумент`.
```js
var con = new _.Consequence();

con.then( ( arg ) =>
{
  console.log( 'then is invoked with: ', arg );
  return 'from then';
} );
con.finally( ( err, arg ) =>
{
  console.log( 'finally is invoked with: ', err ? err : arg );
  return null;
} );

con.take( 'my arg' );
// logs: then is invoked with:  my arg
// logs: finally is invoked with:  from then
```

```js
var con = new _.Consequence();

con.then( ( arg ) =>
{
  console.log( 'then is invoked with: ', arg );
  return 'from then';
} );
con.finally( ( err, arg ) =>
{
  console.log( 'finally is invoked with: ', err ? err : arg );
  return null;
} );

con.error( _.errAttend( 'Error!' ) );
// logs: finally is invoked with:  error log...
console.log( con ); // logs: Consequence:: 1 / 0
```
У випадку передачі `помилки` конкурент `.then()` також, попри те, що не був викликаний - видалиться із черги конкурентів.

[Повернутись до змісту](../README.md#туторіали)
