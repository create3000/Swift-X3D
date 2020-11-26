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

   init ()
   
   func equals (_ color : SFMatrix4f) -> JSValue
   func assign (_ color : SFMatrix4f)
   
   func get1Value (_ column : Int, _ row : Int) -> Float
   func set1Value (_ column : Int, _ row : Int, _ value : Float)
   
   func inverse () -> SFMatrix4f
   func transpose () -> SFMatrix4f
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
   var get1Value = SFMatrix4f .prototype .get1Value;
   var set1Value = SFMatrix4f .prototype .set1Value;

   delete SFMatrix4f .prototype .get1Value;
   delete SFMatrix4f .prototype .set1Value;

   function defineProperty (column, row)
   {
      Object .defineProperty (SFMatrix4f .prototype, column * 4 + row, {
         get: function () { return get1Value .call (this, column, row); },
         set: function (newValue) { set1Value .call (this, column, row, newValue); },
         enumerable: true,
         configurable: false,
      });
   }

   for (var column = 0; column < 4; ++ column)
   {
      for (var row = 0; row < 4; ++ row)
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
         
         super .init (self .object)
         
         JSContext .current () .fix (self)
      }
      
      required internal init (object : Internal)
      {
         self .object = object
         
         super .init (self .object)
         
         JSContext .current () .fix (self)
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
      
      public final func get1Value (_ column : Int, _ row : Int) -> Float
      {
         return object .wrappedValue [column] [row]
      }
      
      public final func set1Value (_ column : Int, _ row : Int, _ value : Float)
      {
         object .wrappedValue [column] [row] = value
      }
      
      // Functions
      
      public final func inverse () -> SFMatrix4f
      {
         return SFMatrix4f (object: Internal (wrappedValue: object .wrappedValue .inverse))
      }
      
      public final func transpose () -> SFMatrix4f
      {
         return SFMatrix4f (object: Internal (wrappedValue: object .wrappedValue .transpose))
      }
   }
}
