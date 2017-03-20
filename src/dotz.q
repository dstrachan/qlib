/ Author: David Strachan

////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////// DOTZ ///////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////
// PRIVATE //
/////////////

.dotz.priv.handlers1:`$".z.",/:string`ac`bm`exit`pc`pg`ph`pi`pm`po`pp`ps`ts`wc`wo`ws
.dotz.priv.handlers2:`$".z.",/:string`pw`vs

///
// Sets the specified handler
// @param handler symbol .z event handler
// @param func function Function to set
.dotz.priv.set:{[handler;func]
  handler set func;
  1b}

///
// Appends a function with 1 parameter to the specified handler
// @param handler symbol .z event handler
// @param func function Function to append
.dotz.priv.append1:{[handler;func]
  if[not count key handler;:.dotz.priv.set[handler;func]];
  handler set{[x;old;new]
    old[x];
    new[x];
    }[;value handler;func];
  1b}

///
// Appends a function with 2 parameters to the specified handler
// @param handler symbol .z event handler
// @param func function Function to append
.dotz.priv.append2:{[handler;func]
  if[not count key handler;:.dotz.priv.set[handler;func]];
  handler set{[x;y;old;new]
    old[x;y];
    new[x;y];
    }[;;value handler;func];
  1b}

////////////
// PUBLIC //
////////////

///
// Sets one of the .z event handlers
// @param handler symbol .z event handler
// @param func function Function to set
.dotz.set:{[handler;func]
  res:$[handler in .dotz.priv.handlers1,.dotz.priv.handlers2;
    .dotz.priv.set[handler;func];
    0b];
  res}

///
// Appends a function to one of the .z event handlers
// @param handler symbol .z event handler
// @param func function Function to append
.dotz.append:{[handler;func]
  res:$[handler in .dotz.priv.handlers1;
    .dotz.priv.append1[handler;func];
    handler in .dotz.priv.handlers2;
    .dotz.priv.append2[handler;func];
    0b];
  res}
