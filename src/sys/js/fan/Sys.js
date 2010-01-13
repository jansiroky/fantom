//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   12 Jan 10  Andy Frank  Creation
//

/**
 * Sys.
 */
fan.sys.Sys = fan.sys.Obj.$extend(fan.sys.Obj);

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

fan.sys.Sys.prototype.$ctor = function()
{
}

//////////////////////////////////////////////////////////////////////////
// Environment
//////////////////////////////////////////////////////////////////////////

fan.sys.Sys.env = function()
{
  return fan.sys.Sys.m_env;
}
