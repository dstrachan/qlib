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

.util.isType:{[typeList;val]
  any(.util.priv.typeDict typeList)=/:type val}

.util.isDict:{[val]
  99=type val}

.util.isTable:{[val]
  98=type val}

.util.isAtom:{[val]
  0>type val}

.util.isList:{[val]
  0<=type val}

.util.exists:{[ref]
  `boolean$count key ref}
