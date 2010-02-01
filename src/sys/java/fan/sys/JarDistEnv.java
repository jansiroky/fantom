//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   01 Feb 10  Brian Frank  Creation
//
package fan.sys;

/**
 * JarDistEnv
 */
public class JarDistEnv
  extends Env
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  public static JarDistEnv make() { return new JarDistEnv(Env.cur()); }

  public JarDistEnv(Env parent) { super(parent); }

//////////////////////////////////////////////////////////////////////////
// Obj
//////////////////////////////////////////////////////////////////////////

  public Type typeof() { return Sys.JarDistEnvType; }

//////////////////////////////////////////////////////////////////////////
// Find Files
//////////////////////////////////////////////////////////////////////////

  public File findFile(Uri uri, boolean checked)
  {
System.out.println("TODO JarDistEnv.findFile " + uri);
    if (!checked) return null;
    throw UnresolvedErr.make("File not found in Env: " + uri).val;
  }

  public List findAllFiles(Uri uri)
  {
    File f = findFile(uri, false);
    if (f == null) return Sys.FileType.emptyList();
    return new List(Sys.FileType, new File[] { f });
  }

//////////////////////////////////////////////////////////////////////////
// Java Env
//////////////////////////////////////////////////////////////////////////

  public Class loadPodClass(Pod pod)
  {
    try
    {
      String classname = "fan." + pod.name() + ".$Pod";
      Class cls = getClass().getClassLoader().loadClass(classname);
      pod.precompiled(cls);
      return cls;
    }
    catch (Exception e)
    {
      return super.loadPodClass(pod);
    }
  }

  /**
   * Given a pod and a Fantom class formatted as its Java
   * dotted classname, emit to a Java classfile.
   */
  public Class[] loadTypeClasses(ClassType t)
  {
    try
    {
      String classname = "fan." + t.pod().name() + "." + t.name();
      Class cls = getClass().getClassLoader().loadClass(classname);
      t.precompiled(cls);
      return new Class[] { cls };
    }
    catch (Exception e)
    {
      return super.loadTypeClasses(t);
    }
  }

}

