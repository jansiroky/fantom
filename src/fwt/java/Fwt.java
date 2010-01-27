//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   12 Jun 08  Brian Frank  Creation
//
package fan.fwt;

import java.io.*;
import java.lang.reflect.Method;
import java.util.*;
import fan.sys.*;
import fan.sys.List;
import org.eclipse.swt.*;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.widgets.*;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Monitor;

/**
 * Fwt manages the display resources.
 */
public class Fwt
{

//////////////////////////////////////////////////////////////////////////
// Lookup
//////////////////////////////////////////////////////////////////////////

  /**
   * Get the Fwt for the current thread.
   */
  public static Fwt get()
  {
    return (Fwt)threadlocal.get();
  }

  /**
   * Get the main UI thread display.
   */
  public static Fwt main()
  {
    if (mainFwt == null) throw new IllegalStateException("Main UI thread not running");
    return mainFwt;
  }

  private static volatile Fwt mainFwt;
  private static ThreadLocal threadlocal = new ThreadLocal()
  {
    protected Object initialValue()
    {
      Fwt fwt = new Fwt();
      Actor.locals().add("gfx.env", FwtEnv.make());
      if (mainFwt == null) mainFwt = fwt;
      return fwt;
    }
  };

  private Fwt() {}

//////////////////////////////////////////////////////////////////////////
// Display
//////////////////////////////////////////////////////////////////////////

  public void mainEventLoop(Shell shell)
  {
    eventLoop(shell);
    display.dispose();
    disposeAllColors();
    disposeAllFonts();
    disposeAllImages();
    disposeScratchGC();
  }

  public void eventLoop(Shell shell)
  {
    while (!shell.isDisposed())
    {
      try
      {
        if (!display.readAndDispatch())
          display.sleep();
      }
      catch (Throwable e)
      {
        e.printStackTrace();
      }
    }
  }

//////////////////////////////////////////////////////////////////////////
// Color
//////////////////////////////////////////////////////////////////////////

  /**
   * Map a Fan Color to an SWT color.
   */
  public Color color(fan.gfx.Color c)
  {
    if (c == null) return null;
    Color x = (Color)colors.get(c.argb);
    if (x == null)
    {
      int argb = (int)c.argb;
      x = new Color(display, (argb >> 16) & 0xff, (argb >> 8) & 0xff, argb & 0xff);
      colors.put(c.argb, x);
    }
    return x;
  }

  /**
   * Dispose the SWT color for the Fan Color.
   */
  public void dispose(fan.gfx.Color c)
  {
    if (c == null) return;
    Color x = (Color)colors.get(c.argb);
    if (x != null)
    {
      x.dispose();
      colors.remove(c.argb);
    }
  }

  /**
   * Dispose all cached colors.
   */
  public void disposeAllColors()
  {
    Iterator it = (Iterator)colors.values().iterator();
    while (it.hasNext()) ((Color)it.next()).dispose();
    colors.clear();
  }

//////////////////////////////////////////////////////////////////////////
// Font
//////////////////////////////////////////////////////////////////////////

  /**
   * Map a Fan Font to an SWT Font.
   */
  public Font font(fan.gfx.Font f)
  {
    if (f == null) return null;
    Font x = (Font)fonts.get(f);
    if (x == null)
    {
      int style = SWT.NORMAL;
      if (f.bold) style |= SWT.BOLD;
      if (f.italic) style |= SWT.ITALIC;
      x = new Font(display, f.name, (int)f.size, style);
      fonts.put(f, x);
    }
    return x;
  }

  /**
   * Dispose the SWT font for the Fan Font.
   */
  public void dispose(fan.gfx.Font f)
  {
    if (f == null) return;
    Font x = (Font)fonts.get(f);
    if (x != null)
    {
      x.dispose();
      fonts.remove(f);
    }
  }

  /**
   * Dispose all cached fonts.
   */
  public void disposeAllFonts()
  {
    Iterator it = (Iterator)fonts.values().iterator();
    while (it.hasNext()) ((Font)it.next()).dispose();
    fonts.clear();
  }

//////////////////////////////////////////////////////////////////////////
// Images
//////////////////////////////////////////////////////////////////////////

  /**
   * Map a Fan Image to an SWT Image.
   */
  public Image image(fan.gfx.Image i)
  {
    if (i == null) return null;
    Image x = (Image)images.get(i.uri);
    if (x == null)
    {
      if (i.file == null)
      {
        System.out.println("ERROR: image has no file: " + i);
        return null;
      }

      InputStream in = SysInStream.java(i.file.in());
      try
      {
        x = new Image(display, in);
        images.put(i.uri, x);
      }
      catch (Exception e)
      {
        System.out.println("ERROR: Cannot load image: " + i);
        e.printStackTrace();
        return null;
      }
      finally
      {
        try { in.close(); } catch (Exception e) {}
      }
    }
    return x;
  }

  /**
   * Dispose the SWT image for the Fan Image.
   */
  public void dispose(fan.gfx.Image i)
  {
    if (i == null) return;
    Image x = (Image)images.get(i.uri);
    if (x != null)
    {
      x.dispose();
      images.remove(i.uri);
    }
  }

  /**
   * Dispose all cached images.
   */
  public void disposeAllImages()
  {
    Iterator it = (Iterator)images.values().iterator();
    while (it.hasNext()) ((Image)it.next()).dispose();
    images.clear();
  }

//////////////////////////////////////////////////////////////////////////
// Scratch GC
//////////////////////////////////////////////////////////////////////////

  /**
   * SWT makes it extremely paintful to work with font metrics,
   * so we use a scratch GC to do font metrics conveniently.
   */
  public GC scratchGC()
  {
    if (scratchGC == null) scratchGC = new GC(display);
    return scratchGC;
  }

  /**
   * Dispose the scratchGC if we've allocated one.
   */
  void disposeScratchGC()
  {
    if (scratchGC != null)
    {
      scratchGC.dispose();
      scratchGC = null;
    }
  }

//////////////////////////////////////////////////////////////////////////
// Monitors
//////////////////////////////////////////////////////////////////////////

  public List monitors()
  {
    if (monitors == null)
    {
      Monitor[] m = display.getMonitors();
      Monitor pm = display.getPrimaryMonitor();
      List acc = new List(Type.find("fwt::Monitor"));
      for (int i=0; i<m.length; ++i)
      {
        fan.fwt.Monitor f = MonitorPeer.make(m[i]);
        acc.add(f);
        if (pm.equals(m[i])) primaryMonitor = f;
      }
      monitors = acc.ro();
    }
    return monitors;
  }

  public fan.fwt.Monitor primaryMonitor()
  {
    if (primaryMonitor == null) monitors();
    return primaryMonitor;
  }

//////////////////////////////////////////////////////////////////////////
// Platform
//////////////////////////////////////////////////////////////////////////

  public static boolean isWindows() { return Sys.os().equals("win32"); }
  public static boolean isMac() { return Sys.os().equals("macosx"); }

  public static int os(String name)
  {
    try
    {
      Class c = Class.forName("org.eclipse.swt.internal." + SWT.getPlatform() + ".OS");
      return c.getField(name).getInt(null);
    }
    catch (Exception e)
    {
      e.printStackTrace();
      return 0;
    }
  }

  public static int osGet(Control w, int k)
  {
    try
    {
      Class c = Class.forName("org.eclipse.swt.internal." + SWT.getPlatform() + ".OS");
      Method m = c.getMethod("GetWindowLong", new Class[] { int.class, int.class });
      int h = osHandle(w);
      return ((Integer)m.invoke(null, new Object[] {h, new Integer(k)})).intValue();
    }
    catch (Exception e)
    {
      e.printStackTrace();
      return 0;
    }
  }

  public static void osSet(Control w, int k, int v)
  {
    try
    {
      Class c = Class.forName("org.eclipse.swt.internal." + SWT.getPlatform() + ".OS");
      Method m = c.getMethod("SetWindowLong", new Class[] { int.class, int.class, int.class });
      int h = osHandle(w);
      m.invoke(null, new Object[] {h, new Integer(k), new Integer(v)});
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }

  public static int osHandle(Control w)
  {
    try
    {
      return w.getClass().getField("handle").getInt(w);
    }
    catch (Exception e)
    {
      return 0;
    }
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  Display display = new Display(); // SWT display
  HashMap colors = new HashMap();  // Int rgb   -> Color
  HashMap fonts = new HashMap();   // fwt::Font  -> Font
  HashMap images = new HashMap();  // Uri -> Image
  GC scratchGC;
  List monitors;
  fan.fwt.Monitor primaryMonitor;

}