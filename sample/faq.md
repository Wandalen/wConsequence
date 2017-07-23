##### 1.How to return index of each iteration from function assigned to element of array.

<b>Problem</b> - variable `i` from each of anonymous functions is bound to the same variable from outer scope.
In this case anonymous function will always return `3`:
```javascript
var fs = []
for( var i = 0; i < 3 ; i++ )
fs[ i ] = function(){ return i };

console.log( 'f1',fs[ 0 ]() );
console.log( 'f2',fs[ 1 ]() );
console.log( 'f3',fs[ 2 ]() );

// f1 3
// f2 3
// f3 3
```

<b>Solution:</b>

Closure means that variables created inside of function scope are locked in and can not be accessed directly from outside.
It makes possible for a function to have "private" variables.
```javascript
function a()
{
  var v = 1;
  console.log( v );  // 1 (functional scope)
};
//(global scope)
console.log( v );// ReferenceError: v is not defined
```
```javascript
var v = 0;
function a()
{
  var v = 1;
  console.log( v );  // 1 (functional scope)
};
console.log( v );// 0 (global scope)  
```

Create each function inside it own closure( in scope of anonymous function ) with a copy of variable `i` (`_i` is independent from `i`) and assign it to array element.
```javascript
var fs = []
for( var i = 0; i < 3 ; i++ ) ( function()
{
 var _i = i;
 fs[ _i ] = function(){ return _i };
})();

console.log( 'f1',fs[ 0 ]() );
console.log( 'f2',fs[ 1 ]() );
console.log( 'f3',fs[ 2 ]() );

// f1 0
// f2 1
// f3 2
```
