
import XCTest
@testable import X3D

final class X3DTests :
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
   
   func testExample () throws
   {
      // This is an example of a functional test case.
      // Use XCTAssert and related functions to verify your tests produce the correct results.
   }
   
   func testMatrixComposition () throws
   {
      let t  = Vector3f (1, 2, 3)
      let r  = Rotation4f (1, 2, 3, 4)
      let s  = Vector3f (1, 2, 3)
      let so = Rotation4f (1, 2, 3, 4)
      
      let m = compose_transformation_matrix (translation: t, rotation: r, scale: s, scaleOrientation: so)
      let d = decompose_transformation_matrix (m)
      let n = compose_transformation_matrix (translation: d .translation, rotation: d .rotation, scale: d .scale, scaleOrientation: d .scaleOrientation)

      debugPrint (m)
      debugPrint (n)
      debugPrint (t)
   }
   
   func testToString () throws
   {
      let b = X3DBrowser ()
      let r = try b .currentScene .createNode (typeName: "Rectangle2D")
      
      print (r .toString())
      XCTAssert (r .toString () == "Rectangle2D { }")
   }
   
   func testParseProto () throws
   {
      do
      {
         let string = """
PROTO P [
]
{ }
"""
      
         let b = X3DBrowser ()
         let s = try b .createX3DFromString (x3dSyntax: string)
      
         XCTAssert ((try? s .getProtoDeclaration (name: "P")) != nil)
      }

      do
      {
         let string = """
PROTO Cube [
   initializeOnly SFVec3f size 1 1 1
]
{
   PROTO Cube [
      initializeOnly SFVec3f size 1 1 1
   ]
   {
      Box {
         size IS size
      }
   }

   Cube {
      size IS size
   }
}

Shape {
   geometry DEF C Cube {
      size 1 2 3
   }
}
"""
      
         let b = X3DBrowser ()
         let s = try b .createX3DFromString (x3dSyntax: string)
         let p = try? s .getProtoDeclaration (name: "Cube")
      
         XCTAssert (p != nil)
         XCTAssert (try p! .getField (name: "size") .getType () == .SFVec3f)
         
         let c = try s .getNamedNode (name: "C")
         
         XCTAssert (c .innerNode! .getType () .contains (.Box))
         XCTAssert ((c .innerNode! as! Box) .size == Vector3f (1, 2, 3))
      }
      
      do
      {
         let string = """
PROTO P [
   inputOutput SFImage image 0 0 0
]
{
   Script {
      inputOutput SFImage image IS image
      inputOutput SFVec3f vec  1 2 3
   }
}

DEF P P { image 1 1 1 123 }
"""
      
         let b = X3DBrowser ()
         let s = try b .createX3DFromString (x3dSyntax: string)
      
         XCTAssert ((try? s .getProtoDeclaration (name: "P")) != nil)
         
         let c = try s .getNamedNode (name: "P")
         
         XCTAssert (c .innerNode! .getType () .contains (.Script))
         XCTAssert ((try (c .innerNode! as! Script) .getField (name: "image") as! SFImage) .wrappedValue .array [0] == 123)
         XCTAssert ((try (c .innerNode! as! Script) .getField (name: "vec") as! SFVec3f) .wrappedValue == Vector3f (1, 2, 3))
      }
      
      do
      {
         let string = """
PROTO P [
]
{
   DEF T1 Transform { }
   DEF T2 Transform { }

   ROUTE T1.translation TO T2.translation
   ROUTE T1.rotation_changed TO T2.set_rotation
}

DEF P P { }
"""
      
         let b = X3DBrowser ()
         let s = try b .createX3DFromString (x3dSyntax: string)
         
         let c = try s .getNamedNode (name: "P") as! X3DPrototypeInstance
         
         XCTAssert (c .innerNode! .getType () .contains (.Transform))
         XCTAssert (c .body! .getRoutes () .count == 2)
      }
   }
   
   func testParseScript () throws
   {
      let string = """
DEF S Script {
   initializeOnly SFBool bool TRUE
   inputOnly SFBool set_bool
   outputOnly SFBool bool_changed
   inputOutput SFColor color 1 1 1

   url "ecmascript:
function initialize ()
{
   print (\\"Hello, X3D!\\");
}
"
}
"""
      
      let b = X3DBrowser ()
      let s = try b .createX3DFromString (x3dSyntax: string)
      let n = try s .getNamedNode (name: "S")
      
      XCTAssert (n .getName () == "S")
      XCTAssert ((try n .getField (name: "bool") as! SFBool) .wrappedValue == true)
      XCTAssert ((try n .getField (name: "bool") as! SFBool) .getAccessType () == .initializeOnly)
      XCTAssert ((try n .getField (name: "bool") as! SFBool) .getName () == "bool")
      
      XCTAssert ((try n .getField (name: "set_bool") as! SFBool) .wrappedValue == false)
      XCTAssert ((try n .getField (name: "set_bool") as! SFBool) .getAccessType () == .inputOnly)
      XCTAssert ((try n .getField (name: "set_bool") as! SFBool) .getName () == "set_bool")
      
      XCTAssert ((try n .getField (name: "bool_changed") as! SFBool) .wrappedValue == false)
      XCTAssert ((try n .getField (name: "bool_changed") as! SFBool) .getAccessType () == .outputOnly)
      XCTAssert ((try n .getField (name: "bool_changed") as! SFBool) .getName () == "bool_changed")
      
      XCTAssert ((try n .getField (name: "color") as! SFColor) .wrappedValue == Color3f .one)
      XCTAssert ((try n .getField (name: "color") as! SFColor) .getAccessType () == .inputOutput)
      XCTAssert ((try n .getField (name: "color") as! SFColor) .getName () == "color")

      XCTAssert (try n .getField (name: "color") === n .getField (name: "set_color"))
      XCTAssert (try n .getField (name: "color") === n .getField (name: "color_changed"))
   }
   
   func testQueue () throws
   {
      // This is an example of a functional test case.
      // Use XCTAssert and related functions to verify your tests produce the correct results.
      
      print ("do")
      
      do
      {
         let queue = DispatchQueue (label: "create3000.X3D.X3DClassicParser.queue", qos: .userInteractive)

         print ("sync 1")
         
         queue .async {
            for _ in 1 ... 1000
            {
               print ("x")
            }
         }

         print ("sync 2")

         queue .async {
            for _ in 1 ... 1000
            {
               print ("o")
            }
         }

         print ("sync end")
      }
      
      print ("do end")
   }
   
   func testNamedNode () throws
   {
      let b = X3DBrowser ()
      let t = try b .currentScene .createNode (typeName: "Transform")
      
      try b .currentScene .addNamedNode (name: "T", node: t)
      XCTAssert(t.getName () == "T")
      try b .currentScene .updateNamedNode (name: "X", node: t)
      XCTAssert(t.getName () == "X")
      XCTAssert(b .currentScene .getUniqueName (for: "X") != "X")
   }

   func testFilter () throws
   {
      XCTAssert (remove_trailing_number ("bah") == "bah")
      XCTAssert (remove_trailing_number ("bah_12") == "bah")
      XCTAssert (remove_trailing_number ("_12") == "")
   }

   func testSFImage () throws
   {
      class C { @SFImage var image : SFImage .Value }
   
      let o = C ()

      XCTAssert (o .image .width == 0)
      XCTAssert (o .image .height == 0)
      XCTAssert (o .image .comp == 0)
      XCTAssert (o .image .array .count == 0)
      
      o .image .width = 2
      o .image .height = 4
      o .image .comp = 3
      XCTAssert (o .image .width == 2)
      XCTAssert (o .image .height == 4)
      XCTAssert (o .image .comp == 3)
      XCTAssert (o .image .array .count == 8)
      
      o .image .array [0] = 0
      o .image .array [1] = 1
      o .image .array [2] = 2
      o .image .array [3] = 3
      o .image .array [4] = 4
      o .image .array [5] = 5
      o .image .array [6] = 6
      o .image .array [7] = 7
      XCTAssert (o .image .array [0] == 0)
      XCTAssert (o .image .array [1] == 1)
      XCTAssert (o .image .array [2] == 2)
      XCTAssert (o .image .array [3] == 3)
      XCTAssert (o .image .array [4] == 4)
      XCTAssert (o .image .array [5] == 5)
      XCTAssert (o .image .array [6] == 6)
      XCTAssert (o .image .array [7] == 7)
      
      o .image .width = 1
      o .image .height = 2
      o .image .comp = 3
      XCTAssert (o .image .width == 1)
      XCTAssert (o .image .height == 2)
      XCTAssert (o .image .comp == 3)
      XCTAssert (o .image .array .count == 2)
      XCTAssert (o .image .array [0] == 0)
      XCTAssert (o .image .array [1] == 1)
   }

   func testSFNode () throws
   {
      let browser = X3DBrowser ()
      let box1    = Box (with: browser .currentScene)
      let box2    = Box (with: browser .currentScene)

      autoreleasepool
      {
         let node = SFNode <Box> (wrappedValue: box1)
         XCTAssert(node .wrappedValue === box1)
         debugPrint(box1 .parents .count)
         XCTAssert(box1 .parents .count == 1)
         node .wrappedValue = box2
         XCTAssert(node .wrappedValue === box2)
         debugPrint(box1 .parents .count)
         XCTAssert(box1 .parents .count == 0)
         debugPrint(box2 .parents .count)
         XCTAssert(box2 .parents .count == 1)
      }
      debugPrint(box1 .parents .count)
      XCTAssert(box1 .parents .count == 0)
      debugPrint(box2 .parents .count)
      for _ in box2 .parents .allObjects
      {
         XCTAssert(false)
      }
   }
   
   func testNumbers () throws
   {
      do
      {
         let o  = Vector3d .one
         let v1 = Vector3d (1, 2, 3)
         let v2 = Vector3d (2, 3, 4)
         
         debugPrint ("test0", o)
         debugPrint ("test0", v1 + v2)
         debugPrint ("test0", v1 * v2)
         debugPrint ("test0", dot (v1, v2))
         debugPrint ("test0", cross (v1 ,v2))
         debugPrint ("test0", normalize (v1))
         debugPrint ("test0", length (v1))
         debugPrint ("test0", mix (v1, v2, t: 0.5))
         
         let color = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)

         debugPrint ("test0", color)
      }

      do
      {
         let n = Matrix4d ()
         let m = Matrix4d (rows: [
            Vector4d (1, 0, 0, 1),
            Vector4d (0, 1, 0, 1),
            Vector4d (0, 0, 1, 1),
            Vector4d (0, 0, 0, 1),
         ])
         
         let v = Vector3d (1, 2, 3)
         
         debugPrint ("test0", normalize (Vector3d .zero))
         debugPrint ("test0", n .determinant, ~n)
         debugPrint ("test0", ~(!m))
         debugPrint ("test0", m .determinant)
         debugPrint ("test0", m * v)
         debugPrint ("test0", m .submatrix .determinant)
      }
      
      do
      {
         let m = Matrix4d .identity
         let i = Rotation4d .identity
         let q = Rotation4d (0, 0, 1, Double .pi / 2)
         let v = Vector3d (1, 0, 0)
         
         debugPrint ("test0", i)
         debugPrint ("test0", q .axis, q .angle)
         debugPrint ("test0", v * ~q * i * ~(!m))
      }
      
      do
      {
         //> new X3D.SFRotation(0,0,1,Math.PI/4).multVec(new X3D.SFVec3f(1,0,0)).toString()
         //< "0.7071067811865475 0.7071067811865476 0"
         
         let q  = Rotation4d (0, 0, 1, Double .pi / 4)
         let m3 = Matrix3d (q .quat)
         let m4 = Matrix4d (q .quat)
         let v  = Vector3d (1, 0, 0)
         
         debugPrint ("test0", q  * v)
         debugPrint ("test0", m3 * v)
         debugPrint ("test0", m4 * v)
      }
   }
   
   func testWrappedProperty () throws
   {
      @propertyWrapper
      class SFNode <Type : X3DBaseNode>
      {
         var projectedValue : SFNode { self }
         var wrappedValue : Type?

         init (wrappedValue : Type?)
         {
            self .wrappedValue = wrappedValue
         }
      }
      
      class Test
      {
         @SFNode var world : X3DWorld?
         @SFNode var scene : X3DScene?
      }
   }
   
   func testEnum () throws
   {
      enum Test :
         UInt8
      {
         case E1 = 0b01
         case E2 = 0b10
      }
      
      debugPrint (0b01 & 0b10)
      debugPrint (Test .E1 .rawValue & Test .E2 .rawValue)
   }
   
   func testGuard () throws
   {
      func foo (_ i : Int)
      {
         guard i != 0 else { return }
         
         debugPrint (i)
      }
      
      foo (1)
   }
   
   func testFields () throws
   {
      class O
      {
         @MFNode  public var rootNodes : MFNode <X3DNode> .Value
         @MFVec3f public var point     : MFVec3f .Value
      }
      
      let o = O ()
      
      o .point .append (contentsOf: [
         Vector3f (1, 2, 3),
      ])
       
      o .rootNodes .append (contentsOf: [nil])
       
      debugPrint (o .$point .getType ())
      debugPrint (o .$point .getTypeName ())

      XCTAssert (SFBool (wrappedValue: false) .getTypeName () == "SFBool")
      XCTAssert (SFColor (wrappedValue: Color3f ()) .getTypeName () == "SFColor")
      XCTAssert (SFColorRGBA (wrappedValue: Color4f ()) .getTypeName () == "SFColorRGBA")
      XCTAssert (SFDouble (wrappedValue: 0) .getTypeName () == "SFDouble")
      XCTAssert (SFFloat (wrappedValue: 0) .getTypeName () == "SFFloat")
      XCTAssert (SFImage () .getTypeName () == "SFImage")
      XCTAssert (SFInt32 (wrappedValue: 0) .getTypeName () == "SFInt32")
      XCTAssert (SFMatrix3d (wrappedValue: Matrix3d ()) .getTypeName () == "SFMatrix3d")
      XCTAssert (SFMatrix3f (wrappedValue: Matrix3f ()) .getTypeName () == "SFMatrix3f")
      XCTAssert (SFMatrix4d (wrappedValue: Matrix4d ()) .getTypeName () == "SFMatrix4d")
      XCTAssert (SFMatrix4f (wrappedValue: Matrix4f ()) .getTypeName () == "SFMatrix4f")
      XCTAssert (SFNode <X3DNode> (wrappedValue: nil) .getTypeName () == "SFNode")
      XCTAssert (SFRotation (wrappedValue: Rotation4f ()) .getTypeName () == "SFRotation")
      XCTAssert (SFString (wrappedValue: "") .getTypeName () == "SFString")
      XCTAssert (SFTime (wrappedValue: 0) .getTypeName () == "SFTime")
      XCTAssert (SFVec2d (wrappedValue: Vector2d ()) .getTypeName () == "SFVec2d")
      XCTAssert (SFVec2f (wrappedValue: Vector2f ()) .getTypeName () == "SFVec2f")
      XCTAssert (SFVec3d (wrappedValue: Vector3d ()) .getTypeName () == "SFVec3d")
      XCTAssert (SFVec3f (wrappedValue: Vector3f ()) .getTypeName () == "SFVec3f")
      XCTAssert (SFVec4d (wrappedValue: Vector4d ()) .getTypeName () == "SFVec4d")
      XCTAssert (SFVec4f (wrappedValue: Vector4f ()) .getTypeName () == "SFVec4f")

      XCTAssert (MFBool () .getTypeName () == "MFBool")
      XCTAssert (MFColor () .getTypeName () == "MFColor")
      XCTAssert (MFColorRGBA () .getTypeName () == "MFColorRGBA")
      XCTAssert (MFDouble () .getTypeName () == "MFDouble")
      XCTAssert (MFFloat () .getTypeName () == "MFFloat")
      XCTAssert (MFImage () .getTypeName () == "MFImage")
      XCTAssert (MFInt32 () .getTypeName () == "MFInt32")
      XCTAssert (MFMatrix3d () .getTypeName () == "MFMatrix3d")
      XCTAssert (MFMatrix3f () .getTypeName () == "MFMatrix3f")
      XCTAssert (MFMatrix4d () .getTypeName () == "MFMatrix4d")
      XCTAssert (MFMatrix4f () .getTypeName () == "MFMatrix4f")
      XCTAssert (MFNode () .getTypeName () == "MFNode")
      XCTAssert (MFRotation () .getTypeName () == "MFRotation")
      XCTAssert (MFString () .getTypeName () == "MFString")
      XCTAssert (MFTime () .getTypeName () == "MFTime")
      XCTAssert (MFVec2d () .getTypeName () == "MFVec2d")
      XCTAssert (MFVec2f () .getTypeName () == "MFVec2f")
      XCTAssert (MFVec3d () .getTypeName () == "MFVec3d")
      XCTAssert (MFVec3f () .getTypeName () == "MFVec3f")
      XCTAssert (MFVec4d () .getTypeName () == "MFVec4d")
      XCTAssert (MFVec4f () .getTypeName () == "MFVec4f")

      XCTAssert (SFBool (wrappedValue: false) .getType () == .SFBool)
      XCTAssert (SFColor (wrappedValue: Color3f ()) .getType () == .SFColor)
      XCTAssert (SFColorRGBA (wrappedValue: Color4f ()) .getType () == .SFColorRGBA)
      XCTAssert (SFDouble (wrappedValue: 0) .getType () == .SFDouble)
      XCTAssert (SFFloat (wrappedValue: 0) .getType () == .SFFloat)
      XCTAssert (SFImage () .getType () == .SFImage)
      XCTAssert (SFInt32 (wrappedValue: 0) .getType () == .SFInt32)
      XCTAssert (SFMatrix3d (wrappedValue: Matrix3d ()) .getType () == .SFMatrix3d)
      XCTAssert (SFMatrix3f (wrappedValue: Matrix3f ()) .getType () == .SFMatrix3f)
      XCTAssert (SFMatrix4d (wrappedValue: Matrix4d ()) .getType () == .SFMatrix4d)
      XCTAssert (SFMatrix4f (wrappedValue: Matrix4f ()) .getType () == .SFMatrix4f)
      XCTAssert (SFNode <X3DNode> (wrappedValue: nil) .getType () == .SFNode)
      XCTAssert (SFRotation (wrappedValue: Rotation4f ()) .getType () == .SFRotation)
      XCTAssert (SFString (wrappedValue: "") .getType () == .SFString)
      XCTAssert (SFTime (wrappedValue: 0) .getType () == .SFTime)
      XCTAssert (SFVec2d (wrappedValue: Vector2d ()) .getType () == .SFVec2d)
      XCTAssert (SFVec2f (wrappedValue: Vector2f ()) .getType () == .SFVec2f)
      XCTAssert (SFVec3d (wrappedValue: Vector3d ()) .getType () == .SFVec3d)
      XCTAssert (SFVec3f (wrappedValue: Vector3f ()) .getType () == .SFVec3f)
      XCTAssert (SFVec4d (wrappedValue: Vector4d ()) .getType () == .SFVec4d)
      XCTAssert (SFVec4f (wrappedValue: Vector4f ()) .getType () == .SFVec4f)

      XCTAssert (MFBool () .getType () == .MFBool)
      XCTAssert (MFColor () .getType () == .MFColor)
      XCTAssert (MFColorRGBA () .getType () == .MFColorRGBA)
      XCTAssert (MFDouble () .getType () == .MFDouble)
      XCTAssert (MFFloat () .getType () == .MFFloat)
      XCTAssert (MFImage () .getType () == .MFImage)
      XCTAssert (MFInt32 () .getType () == .MFInt32)
      XCTAssert (MFMatrix3d () .getType () == .MFMatrix3d)
      XCTAssert (MFMatrix3f () .getType () == .MFMatrix3f)
      XCTAssert (MFMatrix4d () .getType () == .MFMatrix4d)
      XCTAssert (MFMatrix4f () .getType () == .MFMatrix4f)
      XCTAssert (MFNode () .getType () == .MFNode)
      XCTAssert (MFRotation () .getType () == .MFRotation)
      XCTAssert (MFString () .getType () == .MFString)
      XCTAssert (MFTime () .getType () == .MFTime)
      XCTAssert (MFVec2d () .getType () == .MFVec2d)
      XCTAssert (MFVec2f () .getType () == .MFVec2f)
      XCTAssert (MFVec3d () .getType () == .MFVec3d)
      XCTAssert (MFVec3f () .getType () == .MFVec3f)
      XCTAssert (MFVec4d () .getType () == .MFVec4d)
      XCTAssert (MFVec4f () .getType () == .MFVec4f)
   }
   
   func testNodes () throws
   {
      let browser = X3DBrowser ()
      
      for typeName in browser .getSupportedNodes ()
      {
         let node = try browser .getExecutionContext () .createNode (typeName: typeName)
         debugPrint (name, node .getTypeName ())
         XCTAssert (name == node .getTypeName ())
      }
   }
   
   func testNodes2 () throws
   {
      let browser = X3DBrowser ()
      
      for typeName in browser .getSupportedNodes ()
      {
         let node = try browser .getExecutionContext () .createNode (typeName: typeName)
         debugPrint (typeName, node .getTypeName ())
         XCTAssert (typeName == node .getTypeName ())
      }
   }

   func testInterests () throws
   {
      class A : X3DInputOutput {
         func foo () { debugPrint ("A.foo") }
         func bah () { XCTAssert (false) }
         deinit { debugPrint ("A.deinit") }
      }
      
      class B : X3DInputOutput {
         func foo () { debugPrint("B.foo") }
         deinit { debugPrint ("B.deinit") }
      }
      
      do
      {
         var b : B? = B ()
         
         autoreleasepool
         {
            debugPrint ("-------")
            var a : A? = A ()
            
            a! .addInterest (B .foo, b!)
            b! .addInterest (A .foo, a!)
            b! .processInterests ()
            
            b! .addInterest (A .bah, a!)
            a = nil
         }
         
         b! .processInterests ()
         b = nil
      }
      
      autoreleasepool
      {
         debugPrint ("-------")
         var b : B? = B ()
         var a : A? = A ()
         
         a! .addInterest (B .foo, b!)
         a! .addInterest (A .foo, a!)
         b! .addInterest (A .foo, a!)
         a! .processInterests ()
         
         b = nil
         a! .processInterests ()
         a = nil
      }
      
      autoreleasepool
      {
         debugPrint ("-------")
         let a : A = A ()
         let b : B = B ()
         b .addInterest (A .foo, a)
         b .addInterest (A .bah, a)
         b .removeInterest (A .bah, a)
         b .processInterests ()
      }
   }
   
   func testMFNode () throws
   {
      do
      {
         let browser = X3DBrowser ()
         let a1 = MFNode ()
         let a2 = MFNode ()
         let b1 = Box (with: browser .currentScene)
         let b2 = Box (with: browser .currentScene)

         a1 .wrappedValue .append (b1)
         XCTAssert(a1 .wrappedValue .count == 1)
         a2 .wrappedValue .append (b2)
         XCTAssert(a2 .wrappedValue .count == 1)
         a2 .set (value: a1)
         XCTAssert(a2 .wrappedValue .count == 1)
         XCTAssert(a2 .wrappedValue [0] === b1)
         XCTAssert(b1 .parents .count == 2)
         XCTAssert(b2 .parents .count == 0)
      }
      
      do
      {
         let browser = X3DBrowser ()
         let a1 = MFNode ()
         let a2 = MFNode ()
         let b1 = try? browser .currentScene .createNode (typeName: "Box")
         let b2 = browser .currentScene .createNode (of: Box .self)

         a1 .wrappedValue .append (b1)
         a1 .wrappedValue .append (b2)
         XCTAssert(a1 .wrappedValue .count == 2)
         a2 .wrappedValue .append (b2)
         XCTAssert(a2 .wrappedValue .count == 1)
         a2 .set (value: a1)
         XCTAssert(a2 .wrappedValue .count == 2)
         XCTAssert(a2 .wrappedValue [0] === b1)
         XCTAssert(a2 .wrappedValue [1] === b2)
         XCTAssert(b1? .parents .count == 2)
         XCTAssert(b2 .parents .count == 2)
      }
   }
   
   static var allTests = [
      ("testExample", testExample),
   ]
}
