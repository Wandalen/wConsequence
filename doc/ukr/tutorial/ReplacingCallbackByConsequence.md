# Заміна callback функції на `Consequence`

Як правильно використати `Consequence` у рутинах, що приймають в якості аргументу callback функцію, 
передавши замість неї `Consequence`.

У JavaScript дуже поширеним є використання callback функції в якості параметра іншої. Це робиться для того, щоб
викликати callback функцію з передачею в неї(або без) результату виконная рутини, у яку вона була передана як параметр.
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
Як бачимо, рутина `resolve4`, як результат свого виконання передає у передану їй рутину `callback` помилку або 
результат та викликає її.

Тепер реалізуємо аналогічну логіку з допомогою `Consequence`.
```js
let conseuqence = new _.Consequence();

Dns.resolve4( uri, conseuqence );
conseuqence.thenGive( ( addresses ) => console.log( `Ips of ${uri} are ${JSON.stringify( addresses )}` ) );
```

[Повернутись до змісту](../README.md#туторіали)
