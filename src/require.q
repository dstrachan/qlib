/ Author: David Strachan

// TODO: Should we use the util library here or keep it raw so we can load this straight into q.q without any
// additional dependencies?

/////////////
// PRIVATE //
/////////////

// TODO: Change .require.priv.loaded/.require.priv.loadedC to a table

.require.priv.isInitialized:0b

///
// Loads a given file and maintains a list of loaded libraries in .require.priv.loaded
// @param file string Full path to library to load
// @param force boolean Flag to force load of specified file
.require.priv.loadLib:{[file;force]
  if[(not force)and file in .require.priv.loaded;
    :0b];

  res:@[system;"l ",file;0b];
  if[0b~res;
    :0b];

  .require.priv.loaded:distinct .require.priv.loaded,:file;
  1b}

////////////
// PUBLIC //
////////////

///
// Configures require library by setting library root directory
// @param qLibraryRoot string Path to root of q library directory
// @param cLibraryRoot string Path to root of C library directory
.require.init:{[qLibraryRoot;cLibraryRoot]
  .require.priv.qRoot:qLibraryRoot;
  .require.priv.cRoot:cLibraryRoot;
  .require.priv.loaded:(); // TODO: enlist?
  .require.priv.loadedC:(); // TODO: enlist?
  .require.priv.isInitialized:1b;
  }

///
// Loads the specified library located in the root directory, only if not previously loaded
// @param lib string/mixedList List of libraries to load from root
.require.loadLib:{[lib]
  .require.priv.loadLib[lib;0b]}

///
// Loads the specified library located in the root directory, even if previously loaded
// @param lib string/mixedList List of libraries to load from root
.require.forceLoadLib:{[lib]
  .require.priv.loadLib[lib;1b]}

.require.loadFunction:{[func;argCount;namespace;lib]}

.require.unloadFunction:{[func;argCount;namespace;lib]}

///
// Checks if a given library has already been loaded
// @param lib symbol Library name
.require.isLibLoaded:{[lib]
  lib in`$first@'"."vs'last@'"/"vs'1_.require.priv.loaded}
