//
//  SFImage.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public class SFImage :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = X3DImage
   
   // Property wrapper handling
   
   public final var projectedValue : SFImage { self }
   public var wrappedValue : Value { value }
   private final let value : Value

   // Common properties
   
   internal final override class var typeName : String { "SFImage" }
   internal final override class var type     : X3DFieldType { .SFImage }

   // Construction
   
   required public override init ()
   {
      value = Value ()
      
      super .init ()
      
      value .addParent (self)
   }
   
   public init (wrappedValue : Value)
   {
      value = wrappedValue
      
      super .init ()
      
      value .addParent (self)
   }

   public final override func copy () -> SFImage { SFImage (wrappedValue: wrappedValue .copy ()) }

   // Value handling
   
   public final override var isDefaultValue : Bool
   {
      return wrappedValue .width  == 0 &&
             wrappedValue .height == 0 &&
             wrappedValue .comp   == 0 &&
             wrappedValue .array .isEmpty
   }

   public final override func equals (to field : X3DField) -> Bool
   {
      guard let field = field as? Self else { return false }
      
      return wrappedValue .width  == field .wrappedValue .width  &&
             wrappedValue .height == field .wrappedValue .height &&
             wrappedValue .comp   == field .wrappedValue .comp   &&
             wrappedValue .array  == field .wrappedValue .array
   }

   internal final override func set (value field : X3DField)
   {
      guard let field = field as? Self else { return }
      
      wrappedValue .width  = field .wrappedValue .width
      wrappedValue .height = field .wrappedValue .height
      wrappedValue .comp   = field .wrappedValue .comp
      wrappedValue .array  = field .wrappedValue .array
   }
   
   // Input/Output
   
   internal final override func toStream (_ stream : X3DOutputStream)
   {
      toVRMLStream (stream)
   }
   
   internal final override func toXMLStream (_ stream : X3DOutputStream)
   {
      toVRMLStream (stream)
   }
   
   internal final override func toJSONStream (_ stream : X3DOutputStream)
   {
      stream += "["
      stream += stream .TidySpace
      stream += String (wrappedValue .width)
      stream += ","
      stream += stream .TidySpace
      stream += String (wrappedValue .height)
      stream += ","
      stream += stream .TidySpace
      stream += String (wrappedValue .comp)
      
      if !wrappedValue .array .isEmpty
      {
         stream += ","
         stream += stream .TidySpace
         stream += wrappedValue .array .map { String ($0) } .joined (separator: "," + stream .TidySpace)
      }
      
      stream += stream .TidySpace
      stream += "]"
  }
   
   internal final override func toVRMLStream (_ stream : X3DOutputStream)
   {
      stream += String (wrappedValue .width)
      stream += " "
      stream += String (wrappedValue .height)
      stream += " "
      stream += String (wrappedValue .comp)
      
      if !wrappedValue .array .isEmpty
      {
         stream += " "
         stream += wrappedValue .array .map { String (format: "0x%x", $0) } .joined (separator: " ")
      }
   }

   internal final override func fromDisplayStream (_ parser : VRMLParser) -> Bool
   {
      return (try? parser .sfimageValue (for: self)) ?? false
   }
}
