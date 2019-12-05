( function _Ext_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../Tools.s' );
  require( '../../l9/consequence/Consequence.s' );
  _.include( 'wTesting' );

  _.include( 'wLogger' );
  _.include( 'wAppBasic' );

}

let _ = _global_.wTools;
let fileProvider = _testerGlobal_.wTools.fileProvider;
let path = fileProvider.path;

// --
// context
// --

function onSuiteBegin()
{
  let self = this;

  self.suiteTempPath = path.pathDirTempOpen( path.join( __dirname, '../..'  ), 'ConsequenceExternal' );
  self.assetsOriginalSuitePath = path.join( __dirname, '_asset' );
}

//

function onSuiteEnd()
{
  let self = this;
  _.assert( _.strHas( self.suiteTempPath, '/ConsequenceExternal-' ) )
  path.pathDirTempClose( self.suiteTempPath );
}

// --
// tests
// --

function unhandledAsyncErrorOnExit( test )
{
  let context = this;
  let a = test.assetFor( false );
  let toolsPath = _testerGlobal_.wTools.strEscape( a.path.nativize( a.path.join( __dirname, '../../../Tools.s' ) ) );
  let programSourceCode =
`
var toolsPath = '${toolsPath}';
${program.toString()}
program();
`

  a.fileProvider.fileWrite( a.abs( 'Program.js' ), programSourceCode );
  a.jsNonThrowing({ execPath : a.abs( 'Program.js' ) })
  .then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.is( _.strHas( op.output, 'unhandled asynchronous error' ) );
    test.is( _.strHas( op.output, 'Test error' ) );
    return null;
  });

  return a.ready;

  function program()
  {
    var _ = require( toolsPath );
    _.include( 'wAppBasic' );
    
    let con = new _.Consequence();
    
    _.process.exitHandlerOnce( () => 
    { 
      debugger
      con.error( 'Test error' )
    })
  }
}

// --
// declare
// --

var Self =
{

  name : 'Tools.base.Consequence.Ext',
  silencing : 1,

  onSuiteBegin,
  onSuiteEnd,

  context :
  {
    nameOfFile : 'Ext.test.s',
    suiteTempPath : null,
    assetsOriginalSuitePath : null,
    defaultJsPath : null,
  },

  tests :
  {
    unhandledAsyncErrorOnExit,
  }

}

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();