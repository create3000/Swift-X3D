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
   typealias X3DBrowser = JavaScript .X3DBrowser

   init ()
   
   func equals (_ array : MFMatrix3d?) -> Any?
   func assign (_ array : MFMatrix3d?)

   func get1Value (_ index : Int) -> SFMatrix3d
   func set1Value (_ index : Int, _ value : SFMatrix3d?)
   
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
      
      internal private(set) final var field : Internal

      // Registration
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFMatrix3d"] = Self .self
         
         context .evaluateScript ("MakeX3DArrayField (this, targets, true, \"MFMatrix3d\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .field = Internal (wrappedValue: args .map
            {
               ($0 .toObjectOf (SFMatrix3d .self) as? SFMatrix3d)? .field .wrappedValue ?? .identity
            })
         }
         else
         {
            self .field = Internal ()
         }
         
         super .init (field)
      }

      private init (field : Internal)
      {
         self .field = field
         
         super .init (field)
      }
      
      internal static func initWithProxy (_ context : JSContext, field : Internal) -> JSValue!
      {
         return context ["MFMatrix3d"]! .construct (withArguments: [MFMatrix3d (field: field)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFMatrix3d?) -> Any?
      {
         guard let array = array else { return exception (t("Invalid argument.")) }
         
         return field .wrappedValue == array .field .wrappedValue
      }

      public final func assign (_ array : MFMatrix3d?)
      {
         guard let array = array else { return exception (t("Invalid argument.")) }
         
         field .wrappedValue = array .field .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ index : Int) -> SFMatrix3d
      {
         if index >= field .wrappedValue .count
         {
            field .wrappedValue .resize (index + 1, fillWith: .identity)
         }

         return SFMatrix3d (field: SFMatrix3dReference (field, index))
      }
      
      public final func set1Value (_ index : Int, _ value : SFMatrix3d?)
      {
         guard let value = value else { return exception (t("Invalid argument.")) }
         
         if index >= field .wrappedValue .count
         {
            field .wrappedValue .resize (index + 1, fillWith: .identity)
         }
         
         field .wrappedValue [index] = value .field .wrappedValue
      }
      
      // Properties
      
      dynamic public final var length : Int
      {
         get { field .wrappedValue .count }
         set { field .wrappedValue .resize (newValue, fillWith: .identity) }
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
