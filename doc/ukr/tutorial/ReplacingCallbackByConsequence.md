# Заміна callback функції на `наслідок`

Як правильно використати [наслідок](../concept/Consequence.md#наслідок) у рутинах, що приймають як аргумент callback
функцію, передавши замість неї об'єкт класу `Consequence`.

У JavaScript дуже поширеним є використання callback функції в якості параметра іншої. Це робиться для того, щоб
викликати callback функцію з передачею в неї(або без) результату виконання рутини, у яку вона була передана як параметр.
```js
let Dns = require( 'dns' );

let uri = 'google.com';

Dns.resolve4( uri, callback ); // logs - Ips of google.com are ["172.217.16.14"]

function callback( err, addresses )
{
  if( err ) console.log( err );
  console.log( `Ips of ${uri} are ${JSON.stringify( addresses )}` );
}
```
Рутина `resolve4`, як результат свого виконання передає у передану їй рутину `callback` помилку або 
результат та викликає її.

Тепер реалізуємо аналогічну логіку з допомогою `наслідку`.
```js
let conseuqence = new _.Consequence();

Dns.resolve4( uri, conseuqence );
conseuqence.thenGive( ( addresses ) => console.log( `Ips of ${uri} are ${JSON.stringify( addresses )}` ) );
```
В даному прикладі ми передали в якості callback - об'єкт класу `Consequence`. Він є тимчасовим контейнером для даних,
що мали передатись як параметр у callback функцію.
Тобто по завершенню роботи рутини `resolve4`, у `наслідок` передасться або аргумент `addresses` або помилка `err`, 
які далі можливо опрацювати в рутинах-конкурентах цього `наслідку`. У прикладі такою є `thenGive`.
Часто використовується [черга конкурентів](./CompetitorsQue.md#черга-конкурентів), що дозволяє послідовно опрацювати
отримані дані.

[Повернутись до змісту](../README.md#туторіали)
