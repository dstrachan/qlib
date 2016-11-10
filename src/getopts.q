/ Author: David Strachan

/////////////
// PRIVATE //
/////////////

// TODO: Disallow duplicate required/optional argument names

.getopts.priv.defaults:(enlist`help)!enlist enlist@'("";"show this message and exit")
.getopts.priv.required:()
.getopts.priv.optional:enlist`help

///
// Adds an excepted command line argument with a specified default value and help message
// @param arg symbol Argument name
// @param val any Default value for argument
// @param help string Help message to output in usage details
// @param required boolean Flag to indicate if argument is required
.getopts.priv.addArg:{[arg;val;help;required]
  .getopts.priv.defaults,:(enlist arg)!enlist($[10=type val;enlist val;val];enlist help);
  .getopts.priv.required:distinct .getopts.priv.required,$[required;enlist arg;()];
  .getopts.priv.optional:distinct .getopts.priv.optional,$[not required;enlist arg;()];
  }

///
// Output usage message to stderr
.getopts.priv.showUsage:{[]
  formatUsage:{[x;y]
    x:" "sv'flip("-",/:x;
    upper x:string x except`help);
    " "sv$[y;x;"[",'x,'"]"]};
  formatArgs:{[x]
    x:-1_"\n"sv" ",/:"\n"vs .Q.s(`$"-",/:string x)!`$last@'.getopts.priv.defaults x;
    ssr[x;"|";"\t"]};

  // Format usage
  output:"\nusage: q ",(last"/"vs string .z.f)," [-help] ";
  output,:(" "sv(formatUsage[.getopts.priv.required;1b];formatUsage[.getopts.priv.optional;0b])),"\n";

  // Format required arguments
  if[count .getopts.priv.required;
    output,:"\nrequired arguments:\n";
    output,:formatArgs[.getopts.priv.required]];

  // Format optional arguments
  output,:"\noptional arguments:\n";
  output,:formatArgs[.getopts.priv.optional];

  -2 output;
  }

///
// Output missing required command line arguments to stderr
.getopts.priv.showMissingArgs:{[]
  output:(50#"-"),"\n\n";
  output,:"error: required arguments missing\n";
  output,:raze" -",/:(string .getopts.priv.required except key .Q.opt .z.x),\:"\n";
  -2 output;
  }

///
// Output unexpected additional command line arguments to stderr
.getopts.priv.showAdditionalArgs:{[]
  output:(50#"-"),"\n\n";
  output,:"error: additional arguments provided\n";
  output,:raze" -",/:(string(key .Q.opt .z.x)except .getopts.priv.required union .getopts.priv.optional),\:"\n";
  -2 output;
  }

///
// Parses command line arguments
.getopts.priv.parseArgs:{[]
  if[`help in key cmdline:.Q.opt .z.x;
    .getopts.priv.showUsage[];
    exit 1];
  missingArgs:0b;
  additionalArgs:0b;

  if[not all provided:.getopts.priv.required in key cmdline;
    missingArgs:1b];

  if[count(key cmdline)except .getopts.priv.required union .getopts.priv.optional;
    additionalArgs:1b];

  if[missingArgs or additionalArgs;
    .getopts.priv.showUsage[];
    if[missingArgs;.getopts.priv.showMissingArgs[]];
    if[additionalArgs;.getopts.priv.showAdditionalArgs[]];
    -2 (50#"-");
    exit 1];
  res:(.Q.def[first@'.getopts.priv.defaults]cmdline)_`help;

  res[i]:raze@'res[i:where 0=type each res];
  res}

////////////
// PUBLIC //
////////////

///
// Adds a required argument
// @param arg symbol Argument name
// @param val any Default value for argument
// @param help string Help message to output in usage details
.getopts.addArg:{[arg;val;help]
  .getopts.priv.addArg[arg;val;help;1b];
  }

///
// Adds an optional argument
// @param arg symbol Argument name
// @param val any Default value for argument
// @param help string Help message to output in usage details
.getopts.addOpt:{[arg;val;help]
  .getopts.priv.addArg[arg;val;help;0b];
  }

///
// Parses command line arguments
.getopts.parseArgs:{[]
  res:.getopts.priv.parseArgs[];
  res}
