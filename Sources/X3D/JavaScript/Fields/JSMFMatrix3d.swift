//
//  JSMFMatrix3d.swift
//
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol MFMatrix3dExports :
   JSExport
{
   typealias SFMatrix3d = JavaScript .SFMatrix3d
   typealias MFMatrix3d = JavaScript .MFMatrix3d
   
   init ()
   
   func equals (_ array : MFMatrix3d) -> JSValue
   func assign (_ array : MFMatrix3d)

   func get1Value (_ index : Int) -> SFMatrix3d
   func set1Value (_ index : Int, _ value : SFMatrix3d)
   
   var length : Int { get set }
}

extension JavaScript
{
   @objc internal class MFMatrix3d :
      X3DArrayField,
      MFMatrix3dExports
   {
      typealias Internal = X3D .MFMatrix3d

      // Private properties
      
      internal private(set) final var object : Internal

      // Registration
      
      private static var proxy : JSValue!
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFMatrix3d"] = Self .self
         
         proxy = context .evaluateScript ("X3DArrayFieldWrapper (this, \"MFMatrix3d\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .object = Internal (wrappedValue: args .map
            {
               ($0 .toObjectOf (SFMatrix3d .self) as? SFMatrix3d)? .object .wrappedValue ?? .identity
            })
         }
         else
         {
            self .object = Internal ()
         }
         
         super .init (object)
      }

      internal init (object : Internal)
      {
         self .object = object
         
         super .init (object)
      }
      
      internal static func initWithProxy (object : Internal) -> JSValue!
      {
         return proxy .construct (withArguments: [MFMatrix3d (object: object)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFMatrix3d) -> JSValue
      {
         return JSValue (bool: object .wrappedValue == array .object .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ array : MFMatrix3d)
      {
         object .wrappedValue = array .object .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ index : Int) -> SFMatrix3d
      {
         if index >= object .wrappedValue .count
         {
            object .wrappedValue .resize (index + 1, fillWith: .identity)
         }

         return SFMatrix3d (object: SFMatrix3dReference (object, index))
      }
      
      public final func set1Value (_ index : Int, _ value : SFMatrix3d)
      {
         if index >= object .wrappedValue .count
         {
            object .wrappedValue .resize (index + 1, fillWith: .identity)
         }
         
         object .wrappedValue [index] = value .object .wrappedValue
      }
      
      // Properties
      
      dynamic public final var length : Int
      {
         get { object .wrappedValue .count }
         set { object .wrappedValue .resize (newValue, fillWith: .identity) }
      }
   }
}

extension JavaScript
{
   internal final class SFMatrix3dReference :
      X3D .SFMatrix3d
   {
      public final override var wrappedValue : Value
      {
         get { resizeIfNeeded (); return array .wrappedValue [index] }
         set { resizeIfNeeded (); array .wrappedValue [index] = newValue }
      }
      
      private final let array : X3D .MFMatrix3d
      private final let index : Int

      internal init (_ array : X3D .MFMatrix3d, _ index : Int)
      {
         self .array = array
         self .index = index
         
         super .init ()
      }
      
      required public init ()
      {
         fatalError ("init() has not been implemented")
      }
      
      private final func resizeIfNeeded ()
      {
         if index >= array .wrappedValue .count
         {
            array .wrappedValue .resize (index + 1, fillWith: .identity)
         }
      }
   }
}
