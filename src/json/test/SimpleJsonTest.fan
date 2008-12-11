//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Sep 08  Kevin McIntire  Creation
//

**
** SimpleJsonTest
**
class SimpleJsonTest : Test
{

  Void testSuite()
  {
    suite := JsonTestSuite.make
    suite.tests.each |JsonTestCase tc|
    {
      echo("Running "+tc.description)
      map := doTest(tc.map)
    }
  }

  Void testRawJson()
  {
    ins := InStream.makeForStr(makeRawJson)
    map := Json.read(ins)
    verifyRawJson(map)
  }

  Void testRawUtfJson()
  {
    buf := StrBuf.make
    out := OutStream.makeForStrBuf(buf)
    out.charset = Charset.utf16BE
    out.writeChars(makeRawJson)
    out.close
    
    ins := InStream.makeForStr(buf.toStr)
    ins.charset = Charset.utf16BE
    map := Json.read(ins)
    verifyRawJson(map)
  }
          
  private Str:Obj doTest(Str:Obj map)
  {
    buf := StrBuf.make
    stream := OutStream.makeForStrBuf(buf)
    Json.write(map, stream)
    stream.close
    //echo(buf.toStr)
    ins := InStream.makeForStr(buf.toStr)
    newMap := Json.read(ins)
    validate(map, newMap)
    return newMap
  }

  private Void validate(Str:Obj obj, Str:Obj newObj)
  {
    verify(obj.size == newObj.size)
    newObj.each |Obj? val, Str key|
    {
      verify(newObj[key] == val)
    }
  }

  private Str makeRawJson()
  {
    buf := StrBuf.make
    buf.add("\n{\n  \"type\"\n:\n\"Foobar\",\n \n\n\"age\"\n:\n34,    \n\n\n\n")
    buf.add("\t\"nested\"\t:  \n{\t \"ids\":[3.28, 3.14, 2.14],  \t\t\"dead\":false\n\n,")
    buf.add("\t\n \"friends\"\t:\n null\t  \n}\n\t\n}")
    return buf.toStr
  }

  private Void verifyRawJson(Str:Obj? map)
  {
    verifyEq(map["type"], "Foobar")    
    verifyEq(map["age"], 34)    
    inner := (Str:Obj?) map["nested"]
    verifyNotEq(inner, null)
    verifyEq(inner["dead"], false)
    verifyEq(inner["friends"], null)
    list := (List)inner["ids"]
    verifyNotEq(list, null)
    verifyEq(list.size, 3)
    verifyEq(map["friends"], null)    
  }

}
