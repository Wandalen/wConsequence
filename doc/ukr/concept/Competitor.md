# Конкурент

Одним із двох видів даних, що можуть міститись у [наслідку](./Consequence.md#наслідок) є `конкурент` - рутина-обробник
[ресурсу](./Resource.md#ресурс), що передається у `наслідок`.

По своїй суті, конкурент це об'єкт, що містить велику кількість властивостей різного призначення.
Сама ж рутина-обробник, яку ми самостійно додаємо в [чергу конкурентів](../CompetitorsQue.md#черга-конкурентів), записується у
поле `competitorRoutine` об'єкта, що додається у цю чергу в якості конкурента.
```js
var con = new _.Consequence();

// .competitorsGet() returns an array of competitors
console.log( con.competitorsGet().length ); // logs: 0

con.then( ( resource ) =>
{
  console.log( resource );
  return 'new resource from then';
} );

con.thenGive( ( resource ) => console.log( resource ) );

console.log( con.competitorsGet().length ); // logs: 2

con.take( 'my resource' );

console.log( con.competitorsGet().length ); // logs: 0
```

Приклад вище показує ідею взаємодії `ресурсів` та `конкурентів`. Якщо на момент передачі ресурсу у наслідок черга конкурентів(масив)
не порожня, то конкурент під індексом `0` викликається із передачею в нього цього ресурсу. Далі, в залежності від виду,
конкурент або повертає результат, що буде переданий наступному конкуренту для обробки, або завершує ланцюжок обробки.
У прикладі, конкурент `.then()` повинен повернути якийсь результат та передати його наступному конкуренту, а `.thenGive()`
не може цього зробити в принципі. Тому він розташований у черзі останнім.\
Важливо пам'ятати, що як тільки конкурент був викликаний і завершив обробку ресурсу - він видаляється із черги конкурентів.
Тому останній вивід показує `0` конкурентів у черзі.

Тепер подивимось, що таке конкурент і перевіримо чи у властивості `competitorRoutine` записана рутина-обробник, яку ми передали
в якості callback рутини у `.thenGive()`.
```js
var con = new _.Consequence();

con.thenGive( ( resource ) => console.log( resource ) );
console.log( con.competitorsGet()[ 0 ] ); // logs: { a lot of properties... }

con.competitorsGet()[ 0 ][ 'competitorRoutine' ]( 'from competitorRoutine prop' ); // logs: from competitorRoutine prop
con.take( 'my resource' ); // logs: my resource
```

Важливо розуміти, що поки черга конкурентів не порожня, доти процес не завершиться і наслідок очікуватиме на ресурс, який
буде оброблений тими конкурентами, що залишались у черзі.
```js
var con = new _.Consequence();

con.thenGive( ( resource ) => console.log( resource ) );

// if there is at least one competitor in the queue, the process will not stop, the consequence will be waiting for the resource
console.log( con.competitorsGet().length ); // logs: 1
```

**Підсумок:**
- `конкурент` - це об'єкт, що знаходиться у черзі конкурентів(масиві) та може обробляти переданий у наслідок ресурс;
- обробка ресурсу виконується шляхом передачі його у рутину, яку ми самостійно описуємо, та яка є значенням властивості
  `competitorRoutine` об'єкта, що є конкурентом;
- після обробки ресурсу `конкурент` видаляється із черги;
- якщо у черзі конкурентів залишається хоча б один конкурент, то процес не завершиться і наслідок очікуватиме на ресурс.

[Повернутись до змісту](../README.md#концепції)
