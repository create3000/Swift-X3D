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
      
      internal private(set) final var field : Internal

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
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue], args .count == 9
         {
            self .field = Internal (wrappedValue: Inner (columns: (Vector3d (args [0] .toDouble (),
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
      
      public final func equals (_ color : SFMatrix3d) -> JSValue
      {
         return JSValue (bool: field .wrappedValue == color .field .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ color : SFMatrix3d)
      {
         field .wrappedValue = color .field .wrappedValue
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
      
      public final func getTransform (_ translation : SFVec2d?, _ rotation : SFVec3d?, _ scale : SFVec2d?, _ scaleOrientation : SFVec3d?, _ center : SFVec2d?)
      {
         let m = decompose_transformation_matrix (field .wrappedValue, center: center? .field .wrappedValue ?? .zero)
         
         let cr = Complex (length: 1, phase: m .rotation)
         let cs = Complex (length: 1, phase: m .scaleOrientation)

         translation?      .field .wrappedValue = m .translation
         rotation?         .field .wrappedValue = Vector3d (cr .real, cr .imaginary, m .rotation)
         scale?            .field .wrappedValue = m .scale
         scaleOrientation? .field .wrappedValue = Vector3d (cs .real, cs .imaginary, m .scaleOrientation)
      }
      
      public final func setTransform (_ translation : SFVec2d?, _ rotation : Scalar, _ scale : SFVec2d?, _ scaleOrientation : Scalar, _ center : SFVec2d?)
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
      
      public final func transpose () -> SFMatrix3d
      {
         return SFMatrix3d (field: Internal (wrappedValue: field .wrappedValue .transpose))
      }

      public final func inverse () -> SFMatrix3d
      {
         return SFMatrix3d (field: Internal (wrappedValue: field .wrappedValue .inverse))
      }
      
      public final func multLeft (_ matrix : SFMatrix3d) -> SFMatrix3d
      {
         return SFMatrix3d (field: Internal (wrappedValue: field .wrappedValue * matrix .field .wrappedValue))
      }
      
      public final func multRight (_ matrix : SFMatrix3d) -> SFMatrix3d
      {
         return SFMatrix3d (field: Internal (wrappedValue: matrix .field .wrappedValue * field .wrappedValue))
      }
      
      public final func multVecMatrix (_ vector : SFVec2d) -> SFVec2d
      {
         return SFVec2d (field: X3D .SFVec2d (wrappedValue: field .wrappedValue * vector .field .wrappedValue))
      }
      
      public final func multMatrixVec (_ vector : SFVec2d) -> SFVec2d
      {
         return SFVec2d (field: X3D .SFVec2d (wrappedValue: vector .field .wrappedValue * field .wrappedValue))
      }
      
      public final func multDirMatrix (_ vector : SFVec2d) -> SFVec2d
      {
         return SFVec2d (field: X3D .SFVec2d (wrappedValue: field .wrappedValue .submatrix * vector .field .wrappedValue))
      }
      
      public final func multMatrixDir (_ vector : SFVec2d) -> SFVec2d
      {
         return SFVec2d (field: X3D .SFVec2d (wrappedValue: vector .field .wrappedValue * field .wrappedValue .submatrix))
      }
   }
}
