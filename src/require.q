/ Author: David Strachan

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////// REQUIRE /////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////
// PRIVATE //
/////////////

// TODO: Change .require.priv.loaded a table

.require.priv.loaded:enlist()
.require.priv.loadedC:enlist()

.require.priv.qRoot:.require.priv.cRoot:system$["w"=first string .z.o;"cd";"pwd"]

///
// Builds a file path from a given file and a root directory
// @param file string Filename
// @param root string Root directory
.require.priv.buildPath:{[file;root]
  // Windows actually works with both "/" and "\", so let's normalize the string
  ("/"sv f where 0<count@'f:"/"vs f),$["/"in f:ssr[root;"\\";"/"];"/";""],file}

///
// Loads a given file and maintains a list of loaded libraries in .require.priv.loaded
// @param file string File to load
// @param force boolean Flag to force load of specified file
.require.priv.loadLib:{[file;force]
  file:.require.priv.buildPath[file,".q";.require.priv.qRoot];
  if[(not force)and file in .require.priv.loaded;
    :0b];

  res:@[system;"l ",file;0b];
  if[0b~res;
    :0b];

  .require.priv.loaded:distinct .require.priv.loaded,:enlist file;
  1b}

///
// Loads a given C function defined in the specified shared object
// @param func symbol Function to load
// @param argCount long Number of arguments as defined in function prototype
// @param namespace symbol Namespace used to hold loaded function
// @param lib symbol Shared object filename (excluding .so/.dll extension)
.require.priv.loadC:{[func;argCount;namespace;file]
  file:.require.priv.buildPath[file;.require.priv.cRoot];

  code:.[2:;(file;(func;argCount));0b];
  if[0b~code;
    :0b];

  // Ensure namespace begins with "."
  if[not"."=first string namespace;namespace:`$".",string namespace];
  @[value;namespace;{(`$x)set()!()}];

  // Set function name in namespace
  @[namespace;func;:;code];
  1b}

////////////
// PUBLIC //
////////////

///
// Sets the root directory for loading q libraries
// @param root string Root directory
.require.setQRoot:{[root]
  .require.priv.qRoot:(),root;
  }

///
// Sets the root directory for loading C libraries
// @param root string Root directory
.require.setCRoot:{[root]
  .require.priv.cRoot:(),root;
  }

///
// Loads the specified library located in the root directory, only if not previously loaded
// @param lib string Library to load from root
.require.loadLib:{[lib]
  .require.priv.loadLib[lib;0b]}

///
// Loads the specified library located in the root directory, even if previously loaded
// @param lib string Library to load from root
.require.forceLoadLib:{[lib]
  .require.priv.loadLib[lib;1b]}

///
// Loads a function into the specified namespace from a given shared object located in the root directory
// @param func symbol Function to load
// @param argCount long Number of arguments as defined in function prototype
// @param namespace symbol Namespace used to hold loaded function
// @param lib symbol Shared object filename (excluding .so/.dll extension)
.require.loadFunction:{[func;argCount;namespace;lib]
  .require.priv.loadC[func;argCount;namespace;lib]}

///
// Checks if a given library has already been loaded
// @param lib symbol Library name
.require.isLibLoaded:{[lib]
  lib in`$first@'"."vs'last@'"/"vs'.require.priv.loaded}
