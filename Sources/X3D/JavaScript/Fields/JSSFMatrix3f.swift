//
//  JSSFMatrix3f.swift
//
//
//  Created by Holger Seelig on 24.11.20.
//

import JavaScriptCore
import ComplexModule

@objc internal protocol SFMatrix3fExports :
   JSExport
{
   typealias Scalar     = Float
   typealias SFMatrix3f = JavaScript .SFMatrix3f
   typealias SFVec2f    = JavaScript .SFVec2f
   typealias SFVec3f    = JavaScript .SFVec3f
   typealias SFRotation = JavaScript .SFRotation

   init ()
   
   func equals (_ color : SFMatrix3f) -> JSValue
   func assign (_ color : SFMatrix3f)
   
   func get1Value (_ column : Int, _ row : Int) -> Scalar
   func set1Value (_ column : Int, _ row : Int, _ value : Scalar)
   
   func getTransform (_ translation : SFVec2f?, _ rotation : SFVec3f?, _ scale : SFVec2f?, _ scaleOrientation : SFVec3f?, _ center : SFVec2f?)
   func setTransform (_ translation : SFVec2f?, _ rotation : Scalar, _ scale : SFVec2f?, _ scaleOrientation : Scalar, _ center : SFVec2f?)

   func determinant () -> Scalar
   func transpose () -> SFMatrix3f
   func inverse () -> SFMatrix3f
   func multLeft (_ matrix : SFMatrix3f) -> SFMatrix3f
   func multRight (_ matrix : SFMatrix3f) -> SFMatrix3f
   func multVecMatrix (_ vector : SFVec2f) -> SFVec2f
   func multMatrixVec (_ vector : SFVec2f) -> SFVec2f
   func multDirMatrix (_ vector : SFVec2f) -> SFVec2f
   func multMatrixDir (_ vector : SFVec2f) -> SFVec2f
}

extension JavaScript
{
   @objc internal final class SFMatrix3f :
      X3DField,
      SFMatrix3fExports
   {
      typealias Scalar   = Float
      typealias Internal = X3D .SFMatrix3f
      typealias Inner    = Internal .Value

      // Private properties
      
      internal private(set) var object : Internal
      internal final override func getObject () -> X3D .X3DField! { object }

      // Registration
      
      public final override class func register (_ context : JSContext)
      {
         context ["SFMatrix3f"] = Self .self
         
         context .evaluateScript ("""
(function ()
{
   const get1Value = SFMatrix3f .prototype .get1Value;
   const set1Value = SFMatrix3f .prototype .set1Value;

   delete SFMatrix3f .prototype .get1Value;
   delete SFMatrix3f .prototype .set1Value;

   const order = 3;

   function defineProperty (column, row)
   {
      Object .defineProperty (SFMatrix3f .prototype, column * order + row, {
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
            self .object = Internal (wrappedValue: Inner (columns: (Vector3f (args [0] .toFloat (),
                                                                              args [1] .toFloat (),
                                                                              args [2] .toFloat ()),
                                                                    Vector3f (args [3] .toFloat (),
                                                                              args [4] .toFloat (),
                                                                              args [5] .toFloat ()),
                                                                    Vector3f (args [6] .toFloat (),
                                                                              args [7] .toFloat (),
                                                                              args [8] .toFloat ()))))
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
      
      public final func equals (_ color : SFMatrix3f) -> JSValue
      {
         return JSValue (bool: object .wrappedValue == color .object .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ color : SFMatrix3f)
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
      
      public final func getTransform (_ translation : SFVec2f?, _ rotation : SFVec3f?, _ scale : SFVec2f?, _ scaleOrientation : SFVec3f?, _ center : SFVec2f?)
      {
         let m = decompose_transformation_matrix (object .wrappedValue, center: center? .object .wrappedValue ?? .zero)
         
         let cr = Complex (length: 1, phase: m .rotation)
         let cs = Complex (length: 1, phase: m .scaleOrientation)

         translation?      .object .wrappedValue = m .translation
         rotation?         .object .wrappedValue = Vector3f (cr .real, cr .imaginary, m .rotation)
         scale?            .object .wrappedValue = m .scale
         scaleOrientation? .object .wrappedValue = Vector3f (cs .real, cs .imaginary, m .scaleOrientation)
      }
      
      public final func setTransform (_ translation : SFVec2f?, _ rotation : Scalar, _ scale : SFVec2f?, _ scaleOrientation : Scalar, _ center : SFVec2f?)
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
      
      public final func transpose () -> SFMatrix3f
      {
         return SFMatrix3f (object: Internal (wrappedValue: object .wrappedValue .transpose))
      }

      public final func inverse () -> SFMatrix3f
      {
         return SFMatrix3f (object: Internal (wrappedValue: object .wrappedValue .inverse))
      }
      
      public final func multLeft (_ matrix : SFMatrix3f) -> SFMatrix3f
      {
         return SFMatrix3f (object: Internal (wrappedValue: object .wrappedValue * matrix .object .wrappedValue))
      }
      
      public final func multRight (_ matrix : SFMatrix3f) -> SFMatrix3f
      {
         return SFMatrix3f (object: Internal (wrappedValue: matrix .object .wrappedValue * object .wrappedValue))
      }
      
      public final func multVecMatrix (_ vector : SFVec2f) -> SFVec2f
      {
         return SFVec2f (object: X3D .SFVec2f (wrappedValue: object .wrappedValue * vector .object .wrappedValue))
      }
      
      public final func multMatrixVec (_ vector : SFVec2f) -> SFVec2f
      {
         return SFVec2f (object: X3D .SFVec2f (wrappedValue: vector .object .wrappedValue * object .wrappedValue))
      }
      
      public final func multDirMatrix (_ vector : SFVec2f) -> SFVec2f
      {
         return SFVec2f (object: X3D .SFVec2f (wrappedValue: object .wrappedValue .submatrix * vector .object .wrappedValue))
      }
      
      public final func multMatrixDir (_ vector : SFVec2f) -> SFVec2f
      {
         return SFVec2f (object: X3D .SFVec2f (wrappedValue: vector .object .wrappedValue * object .wrappedValue .submatrix))
      }
   }
}
