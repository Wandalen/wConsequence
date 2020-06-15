# Різниця між `give` та `keep` конкурентами

Коли використовувати `give`, а коли `keep` [конкурент](../concept/Competitor.md#конкурент).

Всі конкуренти із суфіксом `Keep` ідентичні за призначенням та поведінкою тим, назва яких утвориться після відкидання
цього суфіксу - `.thenKeep()` -> `.then()`.
Інакша ситуація із конкурентами, що мають суфікс `Give`. Далі продемонстровано різницю у роботі між 
`.thenKeep()` та `.thenGive()` конкурентами.
```js
var con = new _.Consequence({ capacity : 2 });

con.take( 'a' );
con.take( 'b' );

// check number of resources
console.log( con ); // Consequence:: 2 / 0

// check what resources are available
console.log( con.argumentsGet() ); // [ 'a', 'b' ]

con.then( ( arg ) => arg + '2' );
console.log( con.argumentsGet() ); // [ 'b', 'a2' ]

con.thenKeep( ( arg ) => arg + '3' );
console.log( con.argumentsGet() ); // [ 'a2', 'b3' ]

con.thenGive( ( arg ) => arg + '4' );
console.log( con.argumentsGet() ); // [ 'b3' ]

con.thenGive( ( arg ) => console.log( arg ) );
/* log : 'b3' */

console.log( con.argumentsGet() ); // []
```

З прикладу вище, бачимо, що:
- кожен новий ресурс попадає у кінець черги;
- кожен конкурент бере ресурс не з кінця черги, а з початку. При цьому видаляє його на період обробки;
- після завершення обробки ресурсу конкуренти, із суфіксом `Keep` у назві, повертають його у чергу, але не на попереднє
  місце, а у кінець черги;
- після завершення обробки ресурсу конкуренти, із суфіксом `Give` у назві не повертають ресурс у чергу. 

[Повернутись до змісту](../README.md#туторіали)
