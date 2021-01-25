
import XCTest
@testable import X3D

final class X3DPerformanceTests :
   XCTestCase
{
   override func setUpWithError () throws
   {
      // Put setup code here. This method is called before the invocation of each test method in the class.
   }

   override func tearDownWithError () throws
   {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
   }

   func testPerformanceExample () throws
   {
      // This is an example of a performance test case.
 
      self .measure
      {
         // Put the code you want to measure the time of here.
      }
   }
   
   func testPerformanceBrowserCreate () throws
   {
      // This is an example of a performance test case.
      self .measure
      {
         for _ in 0 ..< 10
         {
            let _ = X3DBrowser ()
         }
      }
   }
   
   func testParseBeethoven () throws
   {
      self .measure
      {
         let b   = X3DBrowser ()
         let url = Bundle .module .url (forResource: "beethoven-no-normals", withExtension: "x3dvz")

         _ = try! b .createX3DFromURL (url: [url!])
      }
   }
   
   func testParseForklift () throws
   {
      let options = XCTMeasureOptions .default
      
      options .iterationCount = 1
      
      self .measure (options: options)
      {
         let b   = X3DBrowser ()
         let url = Bundle .module .url (forResource: "forklift3", withExtension: "wrz")

         _ = try! b .createX3DFromURL (url: [url!])
      }
      
      // 12 sec, nur parsen
      // 70 sec
      // 65 sec / 25 fps
      // 45 sec / 25 fps
   }

   func testBeethovenToXMLString () throws
   {
      let b     = X3DBrowser ()
      let url   = Bundle .module .url (forResource: "beethoven-no-normals", withExtension: "x3dvz")
      let scene = try! b .createX3DFromURL (url: [url!])

      self .measure
      {
         _ = scene .toXMLString ()
      }
   }

   func testBeethovenToJSONString () throws
   {
      let b     = X3DBrowser ()
      let url   = Bundle .module .url (forResource: "beethoven-no-normals", withExtension: "x3dvz")
      let scene = try! b .createX3DFromURL (url: [url!])

      self .measure
      {
         _ = scene .toJSONString ()
      }
   }

   func testBeethovenToVRMLString () throws
   {
      let b     = X3DBrowser ()
      let url   = Bundle .module .url (forResource: "beethoven-no-normals", withExtension: "x3dvz")
      let scene = try! b .createX3DFromURL (url: [url!])

      self .measure
      {
         _ = scene .toVRMLString ()
      }
   }

   func testScannerFloat () throws
   {
      var s = "";
      
      for _ in 1 ... 10_000_000
      {
         s += Float .random (in: 0 ... 1) .description
         s += " "
      }
      
      let sc = Scanner (string: s)


      let d = Date ()
      var i = 0
      var a = ContiguousArray <Vector3f> ()
      
      while let x = sc .scanFloat (), let y = sc .scanFloat (), let z = sc .scanFloat ()
      {
         a .append (Vector3f (x, y, z))
         i += 1
      }
      
      debugPrint (i)
      debugPrint (Date () .timeIntervalSince (d))
   }
   
   func testCreateTransform () throws
   {
      let b = X3DBrowser ()
      
      self .measure
      {
         for _ in 0 ..< 10_000
         {
            _ = try! b .currentScene .createNode (typeName: "Transform")
         }
      }
   }
}
