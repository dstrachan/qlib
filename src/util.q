/ Author: David Strachan

/////////////
// PRIVATE //
/////////////

.util.priv.types:`mixedList`boolean`booleanList`guid`guidList`byte`byteList`short`shortList`int`intList`long`longList,
  `real`realList`float`floatList`char`string`symbol`symbolList`timestamp`timestampList`month`monthList`date`dateList,
  `datetime`datetimeList`timespan`timespanList`minute`minuteList`second`secondList`time`timeList;

.util.priv.typeDict:.util.priv.types!`short$0,raze flip@[2#enlist 1 2,4+til 16;0;neg];

////////////
// PUBLIC //
////////////

/***********************/
/ File system functions /
/***********************/

///
// Checks if a given directory exists
// @param dir symbol Directory
.util.isDir:{[dir]
  (not()~k)&not dir~k:key dir:hsym dir}

///
// Checks if a given file exists
// @param file symbol File
.util.isFile:{[file]
  file~key file:hsym file}

/*************************/
/ Type checking functions /
/*************************/

///
// Checks if a given value is of the specified type(s)
// @param typeList symbol/symbolList List of types to be checked against
// @param val any Value to be compared against typeList
.util.isType:{[typeList;val]
  any(.util.priv.typeDict typeList)=/:type val}

///
// Checks if a given list of variable names exists in the global namespace
// @param variableList symbol/symbolList List of variables to be checked
.util.exists:{[variableList]
  all count@'key@/:variableList}

///
// Checks if a given value is a list
// @param val any Value to be checked
.util.isList:{[val]
  0<=type val}

///
// Checks if a given value is an atom
// @param val any Value to be checked
.util.isAtom:{[val]
  0>type val}

///
// Checks if a given value is a dictionary
// @param val any Value to be checked
.util.isDict:{[val]
  99=type val}

///
// Checks if a given value is a table
// @param val any Value to be checked
.util.isTable:{[val]
  98=type val}