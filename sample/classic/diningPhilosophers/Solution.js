/* qqq : implement */
let _;

if( typeof module !== 'undefined' )
{
  _ = require( 'wTools' );
  require( 'wConsequence' );
}

const fork1 = { isAvailable : true }
const fork2 = { isAvailable : true }
const fork3 = { isAvailable : true }
const fork4 = { isAvailable : true }
const fork5 = { isAvailable : true }

const philosopher1 =
{
  leftFork : fork5,
  rightFork : fork1,
  leftHand : null,
  rightHand : null,
  getHungry : 2500,
  eatingTime : 5000
}
const philosopher2 =
{
  leftFork : fork1,
  rightFork : fork2,
  leftHand : null,
  rightHand : null,
  getHungry : 4500,
  eatingTime : 5000
}
const philosopher3 =
{
  leftFork : fork2,
  rightFork : fork3,
  leftHand : null,
  rightHand : null,
  getHungry : 5000,
  eatingTime : 5000
}
const philosopher4 =
{
  leftFork : fork3,
  rightFork : fork4,
  leftHand : null,
  rightHand : null,
  getHungry : 6500,
  eatingTime : 5000
}
const philosopher5 =
{
  leftFork : fork4,
  rightFork : fork5,
  leftHand : null,
  rightHand : null,
  getHungry : 3500,
  eatingTime : 5000
}
