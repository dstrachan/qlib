/ Author: David Strachan

.require.loadLib["util"];

/////////////
// PRIVATE //
/////////////

.log.priv.level:`info
.log.priv.count:0

///
// Log the given message to stdout with the specified level
// @param level string Logl level
// @param str any Message to log
.log.priv.write:{[level;str]
  .log.priv.count+:1;
  -1 .util.stringify(.z.Z;.log.priv.count;level;str);
  }

////////////
// PUBLIC //
////////////

///
// Log info message to stdout if .log.priv.level is set to `info
// @param str any Message to log
.log.info:{[str]
  if[`info=.log.priv.level;
    .log.priv.write["INFO";str]];
  1b}

///
// Log warning message to stdout if .log.priv.level is set to `info or `warning
// @param str any Message to log
.log.warning:{[str]
  if[max`info`warning=.log.priv.level;
    .log.priv.write["WARNING";str]];
  0b}

///
// Log error message to stdout
// @param str any Message to log
.log.error:{[str]
  .log.priv.write["ERROR";str];
  0b}

///
// Set log level as specified
// @param level symbol Log level to set - can be any of `info`warning`error
.log.setLogLevel:{[level]
  if[max`info`warning`error=level;
    .log.info("Setting logLevel to";level);
    .log.priv.level:level];
  }
