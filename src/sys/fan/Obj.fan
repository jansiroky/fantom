//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2 Dec 05  Brian Frank  Creation
//

**
** Obj is the root class of all classes.
**
abstract class Obj
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Obj constructor for subclasses.
  **
  protected new make()

//////////////////////////////////////////////////////////////////////////
// Virtuals
//////////////////////////////////////////////////////////////////////////

  **
  ** Compare this object to the specified for equality.  This method may
  ** be accessed via the == and != shortcut operators.  If not overridden
  ** the default implementation compares for reference equality using
  ** the === operator.  If this method is overridden, then hash() must
  ** also be overridden such that any two objects which return true for
  ** equals() must return the same value for hash().  This method must
  ** accept 'null' and return false.
  **
  virtual Bool equals(Obj? that)

  **
  ** Return a negative integer, zero, or a positive integer if this object
  ** is less than, equal to, or greater than the specified object:
  **    this < that   =>  <0
  **    this == that  =>  0
  **    this > that   =>  >0
  **
  ** This method may also be accessed via the '<' '<=' '<=>' '>=' and '>'
  ** shortcut operators.  If not overridden the default implementation
  ** compares the `toStr` representations.  Also see
  ** [docLang]`docLang::Expressions#shortcuts`.
  **
  ** Examples:
  **   3.compare(8)  =>  -1
  **   8.compare(3)  =>  1
  **   8.compare(8)  =>  0
  **   3 <=> 8       =>  -1  // shortcut for 3.compare(8)
  **
  virtual Int compare(Obj that)

  **
  ** Return a unique hashcode for this object.  If a class overrides hash()
  ** then it must ensure if equals() returns true for any two objects then
  ** they have same hash code.
  **
  virtual Int hash()

  **
  ** Return a string representation of this object.
  **
  virtual Str toStr()

  **
  ** Trap a dynamic call for handling.  Dynamic calls are invoked
  ** with the -> shortcut operator:
  **   a->x        a.trap("x", [,])
  **   a->x = b    a.trap("x", [b])
  **   a->x(b)     a.trap("x", [b])
  **   a->x(b, c)  a.trap("x", [b, c])
  ** The default implementation provided by Obj attempts to use
  ** reflection.  If name maps to a method, it is invoked with the
  ** specified arguments.  If name maps to a field and args.size
  ** is zero, get the field.  If name maps to a field and args.size
  ** is one, set the field and return args[0].  Otherwise throw
  ** UnknownSlotErr.
  **
  virtual Obj? trap(Str name, Obj?[]? args)

  **
  ** This method called whenever an it-block is applied to
  ** an object.  The default implementation calls the function
  ** with 'this', and then returns 'this'.
  **
  virtual This with(|This| f)

//////////////////////////////////////////////////////////////////////////
// Type
//////////////////////////////////////////////////////////////////////////

  **
  ** Return if this Obj is [immutable]`docLang::Concurrency#immutability`
  ** and safe to share between threads:
  **   - an instance of a const class
  **   - the result of 'List.toImmutable' or 'Map.toImmutable'
  **   - a Func object may or may not be immutable - see `sys::Func`.
  **   - other instances are assumed mutable and return false
  **
  Bool isImmutable()

  **
  ** Get an immutable representation of this instance or throw
  ** NotImmutableErr if this object cannot be represented as an
  ** immutable:
  **   - if type is const, return this
  **   - if already an immutable List, Map, or Func return this
  **   - if a List, then attempt to perform a deep clone by
  **     calling toImmutable on all items
  **   - if a Map, then attempt to perform a deep clone by
  **     calling toImmutable on all values (keys are already immutable)
  **   - some Funcs can be made immutable - see `sys::Func`
  **   - any other object throws NotImmutableErr
  **
  This toImmutable()

  **
  ** Get the Type instance used to represent this object's type.
  ** This method is never overridden directly.
  **
  virtual Type type()

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  **
  ** Write 'x.toStr' to standard output.  If 'x' is
  ** null then print "null".
  **
  static Void echo(Obj? x)

}