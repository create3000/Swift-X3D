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
   typealias SFImage    = JavaScript .SFImage
   typealias MFImage    = JavaScript .MFImage
   typealias X3DBrowser = JavaScript .X3DBrowser

   init ()
   
   func equals (_ array : MFImage?) -> Any?
   func assign (_ array : MFImage?)

   func get1Value (_ index : Int) -> SFImage
   func set1Value (_ index : Int, _ value : SFImage?)
   
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
      
      internal private(set) final var field : Internal

      // Registration
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFImage"] = Self .self
         
         context .evaluateScript ("MakeX3DArrayField (this, targets, true, \"MFImage\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .field = Internal (wrappedValue: args .map
            {
               ($0 .toObjectOf (SFImage .self) as? SFImage)? .field .wrappedValue ?? X3DImage ()
            })
         }
         else
         {
            self .field = Internal ()
         }
         
         super .init (field)
      }

      internal init (field : Internal)
      {
         self .field = field
         
         super .init (field)
      }
      
      internal static func initWithProxy (_ context : JSContext, field : Internal) -> JSValue!
      {
         return context ["MFImage"]! .construct (withArguments: [MFImage (field: field)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFImage?) -> Any?
      {
         guard let array = array else { return exception (t("Invalid argument.")) }
         
         return field .wrappedValue == array .field .wrappedValue
      }

      public final func assign (_ array : MFImage?)
      {
         guard let array = array else { return exception (t("Invalid argument.")) }
         
         field .wrappedValue = array .field .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ index : Int) -> SFImage
      {
         if index >= field .wrappedValue .count
         {
            for _ in field .wrappedValue .count ... index
            {
               field .wrappedValue .append (X3DImage ())
            }
         }

         return SFImage (field: SFImageReference (field, index))
      }
      
      public final func set1Value (_ index : Int, _ value : SFImage?)
      {
         guard let value = value else { return exception (t("Invalid argument.")) }
         
         if index >= field .wrappedValue .count
         {
            for _ in field .wrappedValue .count ... index
            {
               field .wrappedValue .append (X3DImage ())
            }
         }

         field .wrappedValue [index] = value .field .wrappedValue
      }
      
      // Properties
      
      dynamic public final var length : Int
      {
         get { field .wrappedValue .count }
         
         set
         {
            if newValue < field .wrappedValue .count
            {
               field .wrappedValue .removeLast (field .wrappedValue .count - newValue)
            }
            else
            {
               for _ in field .wrappedValue .count ..< newValue
               {
                  field .wrappedValue .append (X3DImage ())
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
