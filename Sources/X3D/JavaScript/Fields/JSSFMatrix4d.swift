//
//  JSSFMatrix4d.swift
//
//
//  Created by Holger Seelig on 24.11.20.
//

import JavaScriptCore

@objc internal protocol SFMatrix4dExports :
   JSExport
{
   typealias Scalar     = Double
   typealias SFMatrix4d = JavaScript .SFMatrix4d
   typealias SFVec3d    = JavaScript .SFVec3d
   typealias SFRotation = JavaScript .SFRotation

   init ()
   
   func equals (_ color : SFMatrix4d) -> JSValue
   func assign (_ color : SFMatrix4d)
   
   func get1Value (_ column : Int, _ row : Int) -> Scalar
   func set1Value (_ column : Int, _ row : Int, _ value : Scalar)
   
   func getTransform (_ translation : SFVec3d?, _ rotation : SFRotation?, _ scale : SFVec3d?, _ scaleOrientation : SFRotation?, _ center : SFVec3d?)
   func setTransform (_ translation : SFVec3d?, _ rotation : SFRotation?, _ scale : SFVec3d?, _ scaleOrientation : SFRotation?, _ center : SFVec3d?)

   func determinant () -> Scalar
   func transpose () -> SFMatrix4d
   func inverse () -> SFMatrix4d
   func multLeft (_ matrix : SFMatrix4d) -> SFMatrix4d
   func multRight (_ matrix : SFMatrix4d) -> SFMatrix4d
   func multVecMatrix (_ vector : SFVec3d) -> SFVec3d
   func multMatrixVec (_ vector : SFVec3d) -> SFVec3d
   func multDirMatrix (_ vector : SFVec3d) -> SFVec3d
   func multMatrixDir (_ vector : SFVec3d) -> SFVec3d
}

extension JavaScript
{
   @objc internal final class SFMatrix4d :
      X3DField,
      SFMatrix4dExports
   {
      typealias Scalar   = Double
      typealias Internal = X3D .SFMatrix4d
      typealias Inner    = Internal .Value

      // Private properties
      
      internal private(set) var object : Internal
      internal final override func getObject () -> X3D .X3DField! { object }

      // Registration
      
      public final override class func register (_ context : JSContext)
      {
         context ["SFMatrix4d"] = Self .self
         
         context .evaluateScript ("""
(function ()
{
   const get1Value = SFMatrix4d .prototype .get1Value;
   const set1Value = SFMatrix4d .prototype .set1Value;

   delete SFMatrix4d .prototype .get1Value;
   delete SFMatrix4d .prototype .set1Value;

   const order = 4;

   function defineProperty (column, row)
   {
      Object .defineProperty (SFMatrix4d .prototype, column * order + row, {
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
         if let args = JSContext .currentArguments () as? [JSValue], args .count == 16
         {
            self .object = Internal (wrappedValue: Inner (columns: (Vector4d (args [ 0] .toDouble (),
                                                                              args [ 1] .toDouble (),
                                                                              args [ 2] .toDouble (),
                                                                              args [ 3] .toDouble ()),
                                                                    Vector4d (args [ 4] .toDouble (),
                                                                              args [ 5] .toDouble (),
                                                                              args [ 6] .toDouble (),
                                                                              args [ 7] .toDouble ()),
                                                                    Vector4d (args [ 8] .toDouble (),
                                                                              args [ 9] .toDouble (),
                                                                              args [10] .toDouble (),
                                                                              args [11] .toDouble ()),
                                                                    Vector4d (args [12] .toDouble (),
                                                                              args [13] .toDouble (),
                                                                              args [14] .toDouble (),
                                                                              args [15] .toDouble ()))))
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
      
      public final func equals (_ color : SFMatrix4d) -> JSValue
      {
         return JSValue (bool: object .wrappedValue == color .object .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ color : SFMatrix4d)
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
      
      public final func getTransform (_ translation : SFVec3d?, _ rotation : SFRotation?, _ scale : SFVec3d?, _ scaleOrientation : SFRotation?, _ center : SFVec3d?)
      {
         let m = decompose_transformation_matrix (object .wrappedValue, center: center? .object .wrappedValue ?? .zero)
         
         let ra = m .rotation .axis
         let r  = Rotation4f (Float (ra .x), Float (ra .y), Float (ra .z), Float (m .rotation .angle))
         let sa = m .scaleOrientation .axis
         let so = Rotation4f (Float (sa .x), Float (sa .y), Float (sa .z), Float (m .scaleOrientation .angle))

         translation?      .object .wrappedValue = m .translation
         rotation?         .object .wrappedValue = r
         scale?            .object .wrappedValue = m .scale
         scaleOrientation? .object .wrappedValue = so
      }
      
      public final func setTransform (_ translation : SFVec3d?, _ rotation : SFRotation?, _ scale : SFVec3d?, _ scaleOrientation : SFRotation?, _ center : SFVec3d?)
      {
         let ra = rotation? .object .wrappedValue .axis ?? .zAxis
         let r  = Rotation4d (Scalar (ra .x), Scalar (ra .y), Scalar (ra .z), Scalar (rotation? .object .wrappedValue .angle ?? 0))
         let sa = scaleOrientation? .object .wrappedValue .axis ?? .zAxis
         let so = Rotation4d (Scalar (sa .x), Scalar (sa .y), Scalar (sa .z), Scalar (scaleOrientation? .object .wrappedValue .angle ?? 0))

         let m = compose_transformation_matrix (translation: translation? .object .wrappedValue ?? .zero,
                                                rotation: r,
                                                scale: scale? .object .wrappedValue ?? .one,
                                                scaleOrientation: so,
                                                center: center? .object .wrappedValue ?? .zero)
         
         object .wrappedValue = m
      }
      
      // Functions

      public final func determinant () -> Scalar
      {
         return object .wrappedValue .determinant
      }
      
      public final func transpose () -> SFMatrix4d
      {
         return SFMatrix4d (object: Internal (wrappedValue: object .wrappedValue .transpose))
      }

      public final func inverse () -> SFMatrix4d
      {
         return SFMatrix4d (object: Internal (wrappedValue: object .wrappedValue .inverse))
      }
      
      public final func multLeft (_ matrix : SFMatrix4d) -> SFMatrix4d
      {
         return SFMatrix4d (object: Internal (wrappedValue: object .wrappedValue * matrix .object .wrappedValue))
      }
      
      public final func multRight (_ matrix : SFMatrix4d) -> SFMatrix4d
      {
         return SFMatrix4d (object: Internal (wrappedValue: matrix .object .wrappedValue * object .wrappedValue))
      }
      
      public final func multVecMatrix (_ vector : SFVec3d) -> SFVec3d
      {
         return SFVec3d (object: X3D .SFVec3d (wrappedValue: object .wrappedValue * vector .object .wrappedValue))
      }
      
      public final func multMatrixVec (_ vector : SFVec3d) -> SFVec3d
      {
         return SFVec3d (object: X3D .SFVec3d (wrappedValue: vector .object .wrappedValue * object .wrappedValue))
      }
      
      public final func multDirMatrix (_ vector : SFVec3d) -> SFVec3d
      {
         return SFVec3d (object: X3D .SFVec3d (wrappedValue: object .wrappedValue .submatrix * vector .object .wrappedValue))
      }
      
      public final func multMatrixDir (_ vector : SFVec3d) -> SFVec3d
      {
         return SFVec3d (object: X3D .SFVec3d (wrappedValue: vector .object .wrappedValue * object .wrappedValue .submatrix))
      }
   }
}
