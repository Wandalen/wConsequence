# Два види `ресурсів`

Які бувають види [ресурсів](../concept/Resource.md#ресурс), що передаються у [наслідок](../concept/Consequence.md#наслідок)
та як правильно їх обробляти.

Наслідок працює всього з двома видами ресурсів: 
- [ресурс-аргумент](../concept/ResourceArgument.md#ресурс-аргумент);
- [ресурс-помилка](../concept/ResourceError.md#ресурс-помилка);

Аргументом вважається ресурс, який не є об'єктом помилки:
```js
var con = new _.Consequence();

con.thenGive( ( arg ) => console.log( arg + 1 ) );
con.take( 'agr' ); // logs: arg1

con.thenGive( ( arg ) => console.log( arg.name ) );
con.take({ name : 'user1', age : 20 }); // logs: user1

con.thenGive( ( arg ) => console.log( arg + 1 ) );
con.take( 123 ); // logs: 124
```

Тепер передамо у наслідок помилку:
```js
var con = new _.Consequence();

con.thenGive( ( arg ) => console.log( arg ) );

// _.errAttend( message ) - creating a processed error 
con.take( _.errAttend( 'Error!' ) );
// logs: error log
```

У прикладах вище було розглянено два види ресрусів, але різниця між ними не очевидна. Вони обоє обробляються конкурентом
`.thenGive()`, а це означає, що необхідно перевіряти вхідний параметр і в залежності від його виду - по-різному обробляти.
Такий підхід зовсім не зручний. 
Для перехоплення помилок використовується спеціальний конкурент .catch(), який опрацює ресурс-помилку.
```js

```

Далі наведено приклад, який показує, у якому випадку в наслідок передається відповідний ресурс - `аргумент` або `помилка`, та
яким чином можна їх по-різному обробити.
```js
var con = new _.Consequence();

con.then( ( arg ) =>
{
  console.log( 'then is invoked with argument: ', arg );
  return 'new arg from then';
} );
con.catch( ( err ) =>
{
  console.log( 'catch is invoked with argument: ', err );
  return 'new arg from catch';
} );
con.finally( ( err, arg ) =>
{
  console.log( 'finally is invoked with argument: ', err ? err : arg );
  return null;
} );
```