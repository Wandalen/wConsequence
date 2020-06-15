# Деасинхронізація `наслідку`

Як виконати деасинхронізацію [наслідку](../concept/Consequence.md#наслідок) в асинхронному коді.

Коли наслідок отримує ресурс ми можемо негайно його забрати у потрібному нас місці з допомогою рутини `.sync()`.
Проте, якщо код асинхронний, як у прикладі нижче, то ми отримаємо помилку.
```js
var Dns = require( 'dns' );

var uri = 'google.com';
var con = new _.Consequence();

Dns.resolve4( uri, con );

console.log( `Ips of ${uri} are ${JSON.stringify( con.sync() )}` );
// logs error: Cant return resource of consequence because it has none of such!" and error log...
```
Такий результат передбачуваний, адже в одному рядку ми виконуємо запит на сервер, а уже в наступному ми намагаємось використати
його результат, який, на цей момент, ще не прийшов. Проте, використовуючи наслідок, можливо писати подібний код.
Можна легко привести код до, візуально, до синхронного виду. Достатньо перед використанням рутини `.sync()` викликати
рутину - `.deasync()`. Це відтермінує виконання `.sync()` до моменту, коли `наслідок` отримає ресурс - [аргумент](../concept/ResourceArgument.md#ресурс-аргумент) або
[помилку](../concept/ResourceError.md#ресурс-помилка).
```js
let Dns = require( 'dns' );

let uri = 'google.com';
let con = new _.Consequence();

Dns.resolve4( uri, con );
con.deasync();
console.log( `Ips of ${uri} are ${JSON.stringify( con.sync() )}` );
// logs: Ips of google.com are ["000.00.000.000"]
```

[Повернутись до змісту](../README.md#туторіали)
