//
//  JSMFImage.swift
//
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol MFImageExports :
   JSExport
{
   typealias SFImage = JavaScript .SFImage
   typealias MFImage = JavaScript .MFImage
   
   init ()
   
   func equals (_ array : MFImage) -> JSValue
   func assign (_ array : MFImage)

   func get1Value (_ index : Int) -> SFImage
   func set1Value (_ index : Int, _ value : SFImage)
   
   var length : Int { get set }
}

extension JavaScript
{
   @objc internal class MFImage :
      X3DArrayField,
      MFImageExports
   {
      typealias Internal = X3D .MFImage

      // Private properties
      
      internal private(set) final var object : Internal

      // Registration
      
      private static var proxy : JSValue!
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFImage"] = Self .self
         
         proxy = context .evaluateScript ("X3DArrayFieldWrapper (this, targets, \"MFImage\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .object = Internal (wrappedValue: args .map
            {
               ($0 .toObjectOf (SFImage .self) as? SFImage)? .object .wrappedValue ?? X3DImage ()
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
         return proxy .construct (withArguments: [MFImage (object: object)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFImage) -> JSValue
      {
         return JSValue (bool: object .wrappedValue == array .object .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ array : MFImage)
      {
         object .wrappedValue = array .object .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ index : Int) -> SFImage
      {
         if index >= object .wrappedValue .count
         {
            for _ in object .wrappedValue .count ... index
            {
               object .wrappedValue .append (X3DImage ())
            }
         }

         return SFImage (object: SFImageReference (object, index))
      }
      
      public final func set1Value (_ index : Int, _ value : SFImage)
      {
         if index >= object .wrappedValue .count
         {
            for _ in object .wrappedValue .count ... index
            {
               object .wrappedValue .append (X3DImage ())
            }
         }

         object .wrappedValue [index] = value .object .wrappedValue
      }
      
      // Properties
      
      dynamic public final var length : Int
      {
         get { object .wrappedValue .count }
         
         set
         {
            if newValue < object .wrappedValue .count
            {
               object .wrappedValue .removeLast (object .wrappedValue .count - newValue)
            }
            else
            {
               for _ in object .wrappedValue .count ..< newValue
               {
                  object .wrappedValue .append (X3DImage ())
               }
            }
         }
      }
   }
}

extension JavaScript
{
   internal final class SFImageReference :
      X3D .SFImage
   {
      public final override var wrappedValue : Value
      {
         get { resizeIfNeeded (); return array .wrappedValue [index] }
         set { resizeIfNeeded (); array .wrappedValue [index] = newValue }
      }
      
      private final let array : X3D .MFImage
      private final let index : Int

      internal init (_ array : X3D .MFImage, _ index : Int)
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
            for _ in array .wrappedValue .count ... index
            {
               array .wrappedValue .append (X3DImage ())
            }
         }
      }
   }
}
