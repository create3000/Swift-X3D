//
//  JSSFMatrix3d.swift
//
//
//  Created by Holger Seelig on 24.11.20.
//

import JavaScriptCore
import ComplexModule

@objc internal protocol SFMatrix3dExports :
   JSExport
{
   typealias Scalar     = Double
   typealias SFMatrix3d = JavaScript .SFMatrix3d
   typealias SFVec2d    = JavaScript .SFVec2d
   typealias SFVec3d    = JavaScript .SFVec3d
   typealias SFRotation = JavaScript .SFRotation

   init ()
   
   func equals (_ color : SFMatrix3d) -> JSValue
   func assign (_ color : SFMatrix3d)
   
   func get1Value (_ column : Int, _ row : Int) -> Scalar
   func set1Value (_ column : Int, _ row : Int, _ value : Scalar)
   
   func getTransform (_ translation : SFVec2d?, _ rotation : SFVec3d?, _ scale : SFVec2d?, _ scaleOrientation : SFVec3d?, _ center : SFVec2d?)
   func setTransform (_ translation : SFVec2d?, _ rotation : Scalar, _ scale : SFVec2d?, _ scaleOrientation : Scalar, _ center : SFVec2d?)

   func determinant () -> Scalar
   func transpose () -> SFMatrix3d
   func inverse () -> SFMatrix3d
   func multLeft (_ matrix : SFMatrix3d) -> SFMatrix3d
   func multRight (_ matrix : SFMatrix3d) -> SFMatrix3d
   func multVecMatrix (_ vector : SFVec2d) -> SFVec2d
   func multMatrixVec (_ vector : SFVec2d) -> SFVec2d
   func multDirMatrix (_ vector : SFVec2d) -> SFVec2d
   func multMatrixDir (_ vector : SFVec2d) -> SFVec2d
}

extension JavaScript
{
   @objc internal final class SFMatrix3d :
      X3DField,
      SFMatrix3dExports
   {
      typealias Scalar   = Double
      typealias Internal = X3D .SFMatrix3d
      typealias Inner    = Internal .Value

      // Private properties
      
      internal private(set) var object : Internal
      internal final override func getObject () -> X3D .X3DField! { object }

      // Registration
      
      public final override class func register (_ context : JSContext)
      {
         context ["SFMatrix3d"] = Self .self
         
         context .evaluateScript ("""
(function ()
{
   const get1Value = SFMatrix3d .prototype .get1Value;
   const set1Value = SFMatrix3d .prototype .set1Value;

   delete SFMatrix3d .prototype .get1Value;
   delete SFMatrix3d .prototype .set1Value;

   const order = 3;

   function defineProperty (column, row)
   {
      Object .defineProperty (SFMatrix3d .prototype, column * order + row, {
         get: function () { return get1Value .call (this, column, row); },
         set: function (newValue) { set1Value .call (this, column, row, newValue); },
         enumerable: true,
         configurable: false,
      });
   }

   for (var column = 0; column < order; ++ column)
   {
      for (var row = 0; row < order; ++ row)
      {
         defineProperty (column, row);
      }
   }
})()
""")
      }
      
      // Construction
      
      public override init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue], args .count == 9
         {
            self .object = Internal (wrappedValue: Inner (columns: (Vector3d (args [0] .toDouble (),
                                                                              args [1] .toDouble (),
                                                                              args [2] .toDouble ()),
                                                                    Vector3d (args [3] .toDouble (),
                                                                              args [4] .toDouble (),
                                                                              args [5] .toDouble ()),
                                                                    Vector3d (args [6] .toDouble (),
                                                                              args [7] .toDouble (),
                                                                              args [8] .toDouble ()))))
         }
         else
         {
            self .object = Internal ()
         }
         
         super .init ()
         
         JSContext .current () .fix (self)
      }
      
      internal init (_ context : JSContext? = nil, object : Internal)
      {
         self .object = object
         
         super .init ()
         
         (context ?? JSContext .current ()) .fix (self)
      }

      // Common operators
      
      public final func equals (_ color : SFMatrix3d) -> JSValue
      {
         return JSValue (bool: object .wrappedValue == color .object .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ color : SFMatrix3d)
      {
         object .wrappedValue = color .object .wrappedValue
      }
      
      // Property access
      
      public final func get1Value (_ column : Int, _ row : Int) -> Scalar
      {
         return object .wrappedValue [column, row]
      }
      
      public final func set1Value (_ column : Int, _ row : Int, _ value : Scalar)
      {
         object .wrappedValue [column, row] = value
      }
      
      public final func getTransform (_ translation : SFVec2d?, _ rotation : SFVec3d?, _ scale : SFVec2d?, _ scaleOrientation : SFVec3d?, _ center : SFVec2d?)
      {
         let m = decompose_transformation_matrix (object .wrappedValue, center: center? .object .wrappedValue ?? .zero)
         
         let cr = Complex (length: 1, phase: m .rotation)
         let cs = Complex (length: 1, phase: m .scaleOrientation)

         translation?      .object .wrappedValue = m .translation
         rotation?         .object .wrappedValue = Vector3d (cr .real, cr .imaginary, m .rotation)
         scale?            .object .wrappedValue = m .scale
         scaleOrientation? .object .wrappedValue = Vector3d (cs .real, cs .imaginary, m .scaleOrientation)
      }
      
      public final func setTransform (_ translation : SFVec2d?, _ rotation : Scalar, _ scale : SFVec2d?, _ scaleOrientation : Scalar, _ center : SFVec2d?)
      {
         let m = compose_transformation_matrix (translation: translation? .object .wrappedValue ?? .zero,
                                                rotation: rotation,
                                                scale: scale? .object .wrappedValue ?? .one,
                                                scaleOrientation: scaleOrientation,
                                                center: center? .object .wrappedValue ?? .zero)
         
         object .wrappedValue = m
      }
      
      // Functions

      public final func determinant () -> Scalar
      {
         return object .wrappedValue .determinant
      }
      
      public final func transpose () -> SFMatrix3d
      {
         return SFMatrix3d (object: Internal (wrappedValue: object .wrappedValue .transpose))
      }

      public final func inverse () -> SFMatrix3d
      {
         return SFMatrix3d (object: Internal (wrappedValue: object .wrappedValue .inverse))
      }
      
      public final func multLeft (_ matrix : SFMatrix3d) -> SFMatrix3d
      {
         return SFMatrix3d (object: Internal (wrappedValue: object .wrappedValue * matrix .object .wrappedValue))
      }
      
      public final func multRight (_ matrix : SFMatrix3d) -> SFMatrix3d
      {
         return SFMatrix3d (object: Internal (wrappedValue: matrix .object .wrappedValue * object .wrappedValue))
      }
      
      public final func multVecMatrix (_ vector : SFVec2d) -> SFVec2d
      {
         return SFVec2d (object: X3D .SFVec2d (wrappedValue: object .wrappedValue * vector .object .wrappedValue))
      }
      
      public final func multMatrixVec (_ vector : SFVec2d) -> SFVec2d
      {
         return SFVec2d (object: X3D .SFVec2d (wrappedValue: vector .object .wrappedValue * object .wrappedValue))
      }
      
      public final func multDirMatrix (_ vector : SFVec2d) -> SFVec2d
      {
         return SFVec2d (object: X3D .SFVec2d (wrappedValue: object .wrappedValue .submatrix * vector .object .wrappedValue))
      }
      
      public final func multMatrixDir (_ vector : SFVec2d) -> SFVec2d
      {
         return SFVec2d (object: X3D .SFVec2d (wrappedValue: vector .object .wrappedValue * object .wrappedValue .submatrix))
      }
   }
}
