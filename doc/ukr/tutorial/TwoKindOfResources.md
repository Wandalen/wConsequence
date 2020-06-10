# Два види `ресурсів`

Які бувають види [ресурсів](../concept/Resource.md#ресурс), що передаються у [наслідок](../concept/Consequence.md#наслідок)
та як правильно їх обробляти.

Все ресурси, що передаються у наслідок можна умовно поділити на два види: 
- [аргумент](../concept/ResourceArgument.md#ресурс-аргумент);
- [помилка](../concept/ResourceError.md#ресурс-помилка);

Поділ умовний тому, що будь-який ресурс, переданий у наслідок може оброблятись конкурентом.


Далі наведено приклад, який показує, у якому випадку в наслідок передається відповідний ресурс - `аргумент` або `помилка`, та
яким чином можна їх по-різному обробити.
```js
let con = new _.Consequence();

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