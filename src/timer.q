/ Author: David Strachan

////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////// TIMER //////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

.require.loadLib["dotz"];

/////////////
// PRIVATE //
/////////////

.timer.priv.timers:([tag:`symbol$()]
  nextrun:`timestamp$();
  time:();
  repeat:`boolean$();
  func:())

.dotz.append[`.z.ts;{[timestamp]
    data:0!select from .timer.priv.timers where nextrun<timestamp;
    {[timer]
      .timer.priv.updateNextRun[timer`tag];
      if[not timer`repeat;
        ![`.timer.priv.timers;enlist(=;`tag;enlist timer`tag);0b;`symbol$()];
        .log.info("Timer:";timer`tag;"destroyed")];
      (timer`func)[];
      }'[data];
    }];

if[not system"t";system"t 1000"]

///
// Update nextrun value for a given timer tag
// @param tag symbol Tag to uniquely identify timer
.timer.priv.updateNextRun:{[tag]
  time:.timer.priv.timers[tag;`time];
  // Find closest time after now
  nextrun:.z.D+time first where time>.z.P;
  if[null nextrun;
    nextrun:(.z.D+1)+first time];
  .timer.priv.timers[tag;`nextrun]:nextrun;
  }

///
// Sets a timer with a given tag to execute a function periodically
// @param tag symbol Tag to uniquely identify timer
// @param time secondList List of times to execute function
// @param func function Function to execute
// @param repeat boolean Flag to repeat timer
.timer.priv.set:{[tag;time;func;repeat]
  if[tag in key .timer.priv.timers;
    :0b];

  // Convert 24:00:00 to 00:00:00
  time:asc distinct?[24:00:00=time;00:00:00;time];

  .timer.priv.timers,:(tag;0Np;time;repeat;func);

  .timer.priv.updateNextRun[tag];

  1b}

///
// Calls the specified timer function
// @param tag symbol Tag to uniquely identify timer
.timer.priv.call:{[tag]
  ?[`.timer.priv.timers;enlist(=;`tag;enlist tag);();(first;`func)][];
  }

////////////
// PUBLIC //
////////////

///
// Sets a one-shot timer to be executed in a specified number of seconds
// @param tag symbol Tag to uniquely identify timer
// @param time second Time in seconds until function will be executed
// @param func function Function to execute
.timer.in:{[tag;time;func]
  if[not time within 00:00:01,24:00:00;
    :0b];
  
  time:`second$.z.P+time;
  .timer.priv.set[tag;(),time;func;0b]}

///
// Sets a one-shot timer to be executed at a specified time
// @param tag symbol Tag to uniquely identify timer
// @param time second Time in seconds at which function will be executed
// @param func function Function to execute
.timer.at:{[tag;time;func]
  if[not time within 00:00:00,23:59:59;
    :0b];

  .timer.priv.set[tag;(),time;func;0b]}

///
// Sets a repeating timer to be executed periodically at a specified interval
// @param tag symbol Tag to uniquely identify timer
// @param time second Time in seconds until function will be executed
// @param func function Function to execute
.timer.every:{[tag;time;func]
  if[not time within 00:00:01,24:00:00;
    :0b];

  time:`second$.z.P+`second$a where 0=(a:1+til 1440*60)mod time;
  .timer.priv.set[tag;(),time;func;1b]}

///
// Sets a repeating timer to be executed periodically at a specified time
// @param tag symbol Tag to uniquely identify timer
// @param time second Time in seconds at which function will be executed
// @param func function Function to execute
.timer.atEvery:{[tag;time;func]
  if[not time within 00:00:00,23:59:59;
    :0b];

  .timer.priv.set[tag;(),time;func;1b]}

///
// Manually call a timer function as identified by tag
// @param tag symbol Tag to uniquely identify timer
.timer.call:{[tag]
  if[not tag in key .timer.priv.timers;
    :0b];

  .timer.priv.call[tag];
  1b}
