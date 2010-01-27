//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   12 Jan 10  Andy Frank  Creation
//

/**
 * Env.
 */
fan.sys.Env = fan.sys.Obj.$extend(fan.sys.Obj);

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

fan.sys.Env.cur = function()
{
  if (fan.sys.Env.$cur == null) fan.sys.Env.$cur = new fan.sys.Env();
  return fan.sys.Env.$cur;
}

fan.sys.Env.prototype.$ctor = function()
{
}

//////////////////////////////////////////////////////////////////////////
// Non-Virtuals
//////////////////////////////////////////////////////////////////////////

fan.sys.Env.prototype.runtime = function() { return "js"; }
