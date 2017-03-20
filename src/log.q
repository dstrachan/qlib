/ Author: David Strachan

////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////// LOG ////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

// TODO: Coloured logging

.require.loadLib["util"];

/////////////
// PRIVATE //
/////////////

.log.priv.level:`info
.log.priv.count:0
.log.priv.handle:-1
.log.priv.showMemory:0b // Set to 1b to show memory consumption on process exit

///
// Function to execute on process exit
.z.exit:{[]
  // Show memory stats
  if[1b~.log.priv.showMemory;
    .log.info("Peak memory usage:";.util.formatBytes[.Q.w[]`peak])];
  }

///
// Log the given message to stdout with the specified level
// @param level string Log level
// @param str any Message to log
.log.priv.write:{[level;str]
  .log.priv.count+:1;
  .log.priv.handle .util.stringify[(.z.Z;.log.priv.count;level;str)],$[0<.log.priv.handle;"\n";""];
  }

////////////
// PUBLIC //
////////////

///
// Log info message to stdout if .log.priv.level is set to `info
// @param str any Info message to log
.log.info:{[str]
  if[`info=.log.priv.level;
    .log.priv.write["INFO";str]];
  1b}

///
// Log warning message to stdout if .log.priv.level is set to `info or `warning
// @param str any Warning message to log
.log.warning:{[str]
  if[any`info`warning=.log.priv.level;
    .log.priv.write["WARNING";str]];
  0b}

///
// Log error message to stdout
// @param str any Error message to log
.log.error:{[str]
  .log.priv.write["ERROR";str];
  0b}

///
// Set log level as specified
// @param level symbol Log level to set - can be any of `info`warning`error
.log.setLogLevel:{[level]
  if[any`info`warning`error=level;
    .log.info("Setting logLevel to";level);
    .log.priv.level:level];
  }
