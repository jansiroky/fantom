//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   1 Feb 10  Brian Frank  Creation
//

**
** JarDist compiles a set of Fantom pods into a single Java JAR file.
**
class JarDist : JdkTask
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Construct uninitialized task
  **
  new make(BuildScript script)
    : super(script)
  {
  }

//////////////////////////////////////////////////////////////////////////
// Run
//////////////////////////////////////////////////////////////////////////

  **
  ** Run the javac task
  **
  override Void run()
  {
    // basic sanity checking
    if (podNames.isEmpty) throw fatal("Not configured: JarDist.podNames")
    if (podNames.contains("sys")) throw fatal("sys is implied in JarDist.podNames")
    if (outFile == null) throw fatal("Not configured: JarDist.outFile")
    if (mainMethod == null) throw fatal("Not configured: JarDist.mainMethod")

    log.info("JarDist")
    log.indent
    initTempDir
    sysClasses
    podNames.each |name| { podClasses(name) }
    etcFiles
    main
    manifest
    jar
    cleanupTempDir
    log.info("Success [$outFile]")
    log.unindent
  }

  private Void initTempDir()
  {
    tempDir = (Env.cur.tempDir + `jardist-$Int.random.toHex/`).create
    log.debug("TempDir [$tempDir]")
  }

  private Void cleanupTempDir()
  {
    tempDir.delete
    manifestFile.delete
  }

  private Void sysClasses()
  {
    log.info("Pod [sys]")
    extractToTemp(script.devHomeDir + `lib/java/sys.jar`)
    reflect("sys")
  }

  private Void podClasses(Str podName)
  {
    log.info("Pod [$podName]")

    // stub into Java classfiles using JStub
    Exec(script,
      [javaExe,
       "-cp", (script.devHomeDir + `lib/java/sys.jar`).osPath,
       "-Dfan.home=$Env.cur.workDir.osPath",
       "fanx.tools.Jstub",
       "-d", tempDir.osPath,
       podName]).run

    // stub is "tempDir/{pod}.jar" - extract to tempDir and then delete it
    jar := tempDir + `${podName}.jar`
    extractToTemp(jar)
    jar.delete

    reflect(podName)
  }

  private Void extractToTemp(File zipFile)
  {
    zip := Zip.open(zipFile)
    copyOpts := ["overwrite":true]
    zip.contents.each |f|
    {
      if (f.isDir) return
      if (f.name.lower == "manifest.mf") return
      path := f.uri.toStr[1..-1]
      dest := tempDir + path.toUri
      f.copyTo(dest, copyOpts)
    }
    zip.close
  }

  private Void reflect(Str podName)
  {
    copyOpts := ["overwrite":true]
    zip := Zip.open(script.devHomeDir + `lib/fan/${podName}.pod`)
    zip.contents.each |f|
    {
      if (f.isDir) return
      if (f.ext == "def" || f.ext == "fcode")
      {
        dest := tempDir + "reflect/${podName}/${f.name}".toUri
        f.copyTo(dest, copyOpts)
      }
      else if (f.ext == "props")
      {
        dest := tempDir + "etc/${podName}${f.pathStr}".toUri
        f.copyTo(dest, copyOpts)
      }
    }
  }

  private Void etcFiles()
  {
    copyEtcFile(`etc/sys/timezones.ftz`)
    copyEtcFile(`etc/sys/ext2mime.props`)
    copyEtcFile(`etc/sys/units.fog`)
  }

  private Void copyEtcFile(Uri uri)
  {
    src  := script.devHomeDir + uri
    dest := tempDir + uri
    src.copyTo(dest)
  }

  private Void manifest()
  {
    log.info("Manifest")
    this.manifestFile = Env.cur.workDir + `Manifest.mf`
    out := this.manifestFile.out
    out.printLine("Manifest-Version: 1.0")
    out.printLine("Main-Class: fanjardist.Main")
    out.printLine("Created-By: Fantom JarDist $typeof.pod.version")
    out.close
  }

  private Void main()
  {
    log.info("Main")

    // explicitly initialize all the pod constants
    podInits := StrBuf();
    podNames.each |podName|
    {
      podInits.add("""      Env.cur().loadPodClass(Pod.find("$podName"));\n""")
    }

    // write out Main Java class
    file := tempDir + `fanjardist/Main.java`
    file.out.print(
      """package fanjardist;
         import fan.sys.*;
         public class Main
         {
           public static void main(String[] args)
           {
             try
             {
               System.getProperties().put("fan.jardist", "true");
               System.getProperties().put("fan.home",    ".");
               Sys.boot();
               Sys.bootEnv.setArgs(args);
         $podInits
               Method m = Slot.findMethod("$mainMethod");
               m.call();
             }
             catch (Err.Val e) { e.err().trace(); }
             catch (Throwable e) { e.printStackTrace(); }
           }
         }
         """).close

    // compile main
    Exec(script,
      [javacExe,
       "-cp", tempDir.osPath,
       "-d", tempDir.osPath,
       file.osPath], tempDir).run

  }

  private Void jar()
  {
    // jar everything back up outFile
    log.info("Jar [$outFile]")
    Exec(script,
      [jarExe,
       "cfm", outFile.osPath, manifestFile.osPath,
       "-C", tempDir.osPath,
       "."], tempDir).run
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  ** Required output jar file to create
  File? outFile

  ** Qualified name of main method to run for JAR.
  ** This must be a static void method with no arguments.
  Str? mainMethod

  ** List of pods to compile into JAR; sys is always implied
  Str[] podNames := Str[,]

  private File? tempDir       // initTempDir
  private File? manifestFile  // manifest
}