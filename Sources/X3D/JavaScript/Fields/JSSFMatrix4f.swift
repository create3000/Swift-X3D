//
//  JSSFMatrix4f.swift
//
//
//  Created by Holger Seelig on 24.11.20.
//

import JavaScriptCore

@objc internal protocol SFMatrix4fExports :
   JSExport
{
   typealias Scalar     = Float
   typealias SFMatrix4f = JavaScript .SFMatrix4f
   typealias SFVec3f    = JavaScript .SFVec3f
   typealias SFRotation = JavaScript .SFRotation

   init ()
   
   func equals (_ color : SFMatrix4f) -> JSValue
   func assign (_ color : SFMatrix4f)
   
   func get1Value (_ column : Int, _ row : Int) -> Scalar
   func set1Value (_ column : Int, _ row : Int, _ value : Scalar)
   
   func getTransform (_ translation : SFVec3f?, _ rotation : SFRotation?, _ scale : SFVec3f?, _ scaleOrientation : SFRotation?, _ center : SFVec3f?)
   func setTransform (_ translation : SFVec3f?, _ rotation : SFRotation?, _ scale : SFVec3f?, _ scaleOrientation : SFRotation?, _ center : SFVec3f?)

   func determinant () -> Scalar
   func transpose () -> SFMatrix4f
   func inverse () -> SFMatrix4f
   func multLeft (_ matrix : SFMatrix4f) -> SFMatrix4f
   func multRight (_ matrix : SFMatrix4f) -> SFMatrix4f
   func multVecMatrix (_ vector : SFVec3f) -> SFVec3f
   func multMatrixVec (_ vector : SFVec3f) -> SFVec3f
   func multDirMatrix (_ vector : SFVec3f) -> SFVec3f
   func multMatrixDir (_ vector : SFVec3f) -> SFVec3f
}

extension JavaScript
{
   @objc internal final class SFMatrix4f :
      X3DField,
      SFMatrix4fExports
   {
      typealias Scalar   = Float
      typealias Internal = X3D .SFMatrix4f
      typealias Inner    = Internal .Value

      // Private properties
      
      internal private(set) final var object : Internal

      // Registration
      
      public final override class func register (_ context : JSContext)
      {
         context ["SFMatrix4f"] = Self .self
         
         context .evaluateScript ("""
(function ()
{
   const get1Value = SFMatrix4f .prototype .get1Value;
   const set1Value = SFMatrix4f .prototype .set1Value;

   delete SFMatrix4f .prototype .get1Value;
   delete SFMatrix4f .prototype .set1Value;

   const order = 4;

   function defineProperty (column, row)
   {
      Object .defineProperty (SFMatrix4f .prototype, column * order + row, {
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
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue], args .count == 16
         {
            self .object = Internal (wrappedValue: Inner (columns: (Vector4f (args [ 0] .toFloat (),
                                                                              args [ 1] .toFloat (),
                                                                              args [ 2] .toFloat (),
                                                                              args [ 3] .toFloat ()),
                                                                    Vector4f (args [ 4] .toFloat (),
                                                                              args [ 5] .toFloat (),
                                                                              args [ 6] .toFloat (),
                                                                              args [ 7] .toFloat ()),
                                                                    Vector4f (args [ 8] .toFloat (),
                                                                              args [ 9] .toFloat (),
                                                                              args [10] .toFloat (),
                                                                              args [11] .toFloat ()),
                                                                    Vector4f (args [12] .toFloat (),
                                                                              args [13] .toFloat (),
                                                                              args [14] .toFloat (),
                                                                              args [15] .toFloat ()))))
         }
         else
         {
            self .object = Internal ()
         }
         
         super .init (object)
         
         JSContext .current () .fix (self)
      }
      
      internal init (_ context : JSContext? = nil, object : Internal)
      {
         self .object = object
         
         super .init (object)
         
         (context ?? JSContext .current ()) .fix (self)
      }

      // Common operators
      
      public final func equals (_ color : SFMatrix4f) -> JSValue
      {
         return JSValue (bool: object .wrappedValue == color .object .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ color : SFMatrix4f)
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
      
      public final func getTransform (_ translation : SFVec3f?, _ rotation : SFRotation?, _ scale : SFVec3f?, _ scaleOrientation : SFRotation?, _ center : SFVec3f?)
      {
         let m = decompose_transformation_matrix (object .wrappedValue, center: center? .object .wrappedValue ?? .zero)
         
         translation?      .object .wrappedValue = m .translation
         rotation?         .object .wrappedValue = m .rotation
         scale?            .object .wrappedValue = m .scale
         scaleOrientation? .object .wrappedValue = m .scaleOrientation
      }
      
      public final func setTransform (_ translation : SFVec3f?, _ rotation : SFRotation?, _ scale : SFVec3f?, _ scaleOrientation : SFRotation?, _ center : SFVec3f?)
      {
         let m = compose_transformation_matrix (translation: translation? .object .wrappedValue ?? .zero,
                                                rotation: rotation? .object .wrappedValue ?? .identity,
                                                scale: scale? .object .wrappedValue ?? .one,
                                                scaleOrientation: scaleOrientation? .object .wrappedValue ?? .identity,
                                                center: center? .object .wrappedValue ?? .zero)
         
         object .wrappedValue = m
      }
      
      // Functions

      public final func determinant () -> Scalar
      {
         return object .wrappedValue .determinant
      }
      
      public final func transpose () -> SFMatrix4f
      {
         return SFMatrix4f (object: Internal (wrappedValue: object .wrappedValue .transpose))
      }

      public final func inverse () -> SFMatrix4f
      {
         return SFMatrix4f (object: Internal (wrappedValue: object .wrappedValue .inverse))
      }
      
      public final func multLeft (_ matrix : SFMatrix4f) -> SFMatrix4f
      {
         return SFMatrix4f (object: Internal (wrappedValue: object .wrappedValue * matrix .object .wrappedValue))
      }
      
      public final func multRight (_ matrix : SFMatrix4f) -> SFMatrix4f
      {
         return SFMatrix4f (object: Internal (wrappedValue: matrix .object .wrappedValue * object .wrappedValue))
      }
      
      public final func multVecMatrix (_ vector : SFVec3f) -> SFVec3f
      {
         return SFVec3f (object: X3D .SFVec3f (wrappedValue: object .wrappedValue * vector .object .wrappedValue))
      }
      
      public final func multMatrixVec (_ vector : SFVec3f) -> SFVec3f
      {
         return SFVec3f (object: X3D .SFVec3f (wrappedValue: vector .object .wrappedValue * object .wrappedValue))
      }
      
      public final func multDirMatrix (_ vector : SFVec3f) -> SFVec3f
      {
         return SFVec3f (object: X3D .SFVec3f (wrappedValue: object .wrappedValue .submatrix * vector .object .wrappedValue))
      }
      
      public final func multMatrixDir (_ vector : SFVec3f) -> SFVec3f
      {
         return SFVec3f (object: X3D .SFVec3f (wrappedValue: vector .object .wrappedValue * object .wrappedValue .submatrix))
      }
   }
}
