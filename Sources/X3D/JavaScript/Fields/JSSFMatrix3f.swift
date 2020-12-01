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
   
   func equals (_ matrix : SFMatrix3f?) -> Any?
   func assign (_ matrix : SFMatrix3f?)
   
   func get1Value (_ column : Int, _ row : Int) -> Scalar
   func set1Value (_ column : Int, _ row : Int, _ value : Scalar)
   
   func getTransform (_ translation : SFVec2f?, _ rotation : SFVec3f?, _ scale : SFVec2f?, _ scaleOrientation : SFVec3f?, _ center : SFVec2f?)
   func setTransform (_ translation : SFVec2f?, _ rotation : Scalar, _ scale : SFVec2f?, _ scaleOrientation : Scalar, _ center : SFVec2f?)

   func determinant () -> Scalar
   func transpose () -> SFMatrix3f
   func inverse () -> SFMatrix3f
   func multLeft (_ matrix : SFMatrix3f?) -> SFMatrix3f?
   func multRight (_ matrix : SFMatrix3f?) -> SFMatrix3f?
   func multVecMatrix (_ vector : SFVec2f?) -> SFVec2f?
   func multMatrixVec (_ vector : SFVec2f?) -> SFVec2f?
   func multDirMatrix (_ vector : SFVec2f?) -> SFVec2f?
   func multMatrixDir (_ vector : SFVec2f?) -> SFVec2f?
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
      
      internal private(set) final var field : Internal

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
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue], args .count == 9
         {
            self .field = Internal (wrappedValue: Inner (columns: (Vector3f (args [0] .toFloat (),
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
            self .field = Internal ()
         }
         
         super .init (field)
         
         JSContext .current () .fix (self)
      }
      
      internal init (_ context : JSContext? = nil, field : Internal)
      {
         self .field = field
         
         super .init (field)
         
         (context ?? JSContext .current ()) .fix (self)
      }

      // Common operators
      
      public final func equals (_ matrix : SFMatrix3f?) -> Any?
      {
         guard let matrix = matrix else { return exception (t("Invalid argument.")) }
         
         return field .wrappedValue == matrix .field .wrappedValue
      }

      public final func assign (_ matrix : SFMatrix3f?)
      {
         guard let matrix = matrix else { return exception (t("Invalid argument.")) }
         
         field .wrappedValue = matrix .field .wrappedValue
      }
      
      // Property access
      
      public final func get1Value (_ column : Int, _ row : Int) -> Scalar
      {
         return field .wrappedValue [column, row]
      }
      
      public final func set1Value (_ column : Int, _ row : Int, _ value : Scalar)
      {
         field .wrappedValue [column, row] = value
      }
      
      public final func getTransform (_ translation : SFVec2f?, _ rotation : SFVec3f?, _ scale : SFVec2f?, _ scaleOrientation : SFVec3f?, _ center : SFVec2f?)
      {
         let m = decompose_transformation_matrix (field .wrappedValue, center: center? .field .wrappedValue ?? .zero)
         
         let cr = Complex (length: 1, phase: m .rotation)
         let cs = Complex (length: 1, phase: m .scaleOrientation)

         translation?      .field .wrappedValue = m .translation
         rotation?         .field .wrappedValue = Vector3f (cr .real, cr .imaginary, m .rotation)
         scale?            .field .wrappedValue = m .scale
         scaleOrientation? .field .wrappedValue = Vector3f (cs .real, cs .imaginary, m .scaleOrientation)
      }
      
      public final func setTransform (_ translation : SFVec2f?, _ rotation : Scalar, _ scale : SFVec2f?, _ scaleOrientation : Scalar, _ center : SFVec2f?)
      {
         let m = compose_transformation_matrix (translation: translation? .field .wrappedValue ?? .zero,
                                                rotation: rotation,
                                                scale: scale? .field .wrappedValue ?? .one,
                                                scaleOrientation: scaleOrientation,
                                                center: center? .field .wrappedValue ?? .zero)
         
         field .wrappedValue = m
      }
      
      // Functions

      public final func determinant () -> Scalar
      {
         return field .wrappedValue .determinant
      }
      
      public final func transpose () -> SFMatrix3f
      {
         return SFMatrix3f (field: Internal (wrappedValue: field .wrappedValue .transpose))
      }

      public final func inverse () -> SFMatrix3f
      {
         return SFMatrix3f (field: Internal (wrappedValue: field .wrappedValue .inverse))
      }
      
      public final func multLeft (_ matrix : SFMatrix3f?) -> SFMatrix3f?
      {
         guard let matrix = matrix else { return exception (t("Invalid argument.")) }
         
         return SFMatrix3f (field: Internal (wrappedValue: field .wrappedValue * matrix .field .wrappedValue))
      }
      
      public final func multRight (_ matrix : SFMatrix3f?) -> SFMatrix3f?
      {
         guard let matrix = matrix else { return exception (t("Invalid argument.")) }
         
         return SFMatrix3f (field: Internal (wrappedValue: matrix .field .wrappedValue * field .wrappedValue))
      }
      
      public final func multVecMatrix (_ vector : SFVec2f?) -> SFVec2f?
      {
         guard let vector = vector else { return exception (t("Invalid argument.")) }
         
         return SFVec2f (field: X3D .SFVec2f (wrappedValue: field .wrappedValue * vector .field .wrappedValue))
      }
      
      public final func multMatrixVec (_ vector : SFVec2f?) -> SFVec2f?
      {
         guard let vector = vector else { return exception (t("Invalid argument.")) }
         
         return SFVec2f (field: X3D .SFVec2f (wrappedValue: vector .field .wrappedValue * field .wrappedValue))
      }
      
      public final func multDirMatrix (_ vector : SFVec2f?) -> SFVec2f?
      {
         guard let vector = vector else { return exception (t("Invalid argument.")) }
         
         return SFVec2f (field: X3D .SFVec2f (wrappedValue: field .wrappedValue .submatrix * vector .field .wrappedValue))
      }
      
      public final func multMatrixDir (_ vector : SFVec2f?) -> SFVec2f?
      {
         guard let vector = vector else { return exception (t("Invalid argument.")) }
         
         return SFVec2f (field: X3D .SFVec2f (wrappedValue: vector .field .wrappedValue * field .wrappedValue .submatrix))
      }
   }
}
