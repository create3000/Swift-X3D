//
//  MFColorRGBA.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class MFColorRGBA :
   X3DArrayField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Element = Color4f
   public typealias Value   = [Element]

   // Property wrapper handling
   
   public final var projectedValue : MFColorRGBA { self }
   public final var wrappedValue   : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "MFColorRGBA" }
   internal final override class var type     : X3DFieldType { .MFColorRGBA }

   // Construction
   
   required public override init ()
   {
      self .wrappedValue = Value ()
   }
   
   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> MFColorRGBA { MFColorRGBA (wrappedValue: wrappedValue) }

   // Value handling
   
   public final override func equals (to field : X3DField) -> Bool
   {
      guard let field = field as? Self else { return false }
      
      return wrappedValue == field .wrappedValue
   }

   internal final override func set (value field : X3DField)
   {
      guard let field = field as? Self else { return }

      wrappedValue = field .wrappedValue
   }
   
   // Input/Output

   internal final override func toStream (_ stream : X3DOutputStream)
   {
      toVRMLStream (stream)
   }
   
   internal final override func toVRMLStream (_ stream : X3DOutputStream)
   {
      switch wrappedValue .count
      {
         case 0:
            stream += "["
            stream += stream .TidySpace
            stream += "]"
         case 1:
            stream += "\(wrappedValue .first! .r) \(wrappedValue .first! .g) \(wrappedValue .first! .b) \(wrappedValue .first! .a)"
         default:
            stream += "["
            stream += stream .ListBreak
            
            stream .incIndent ()
            
            stream += stream .TidyIndent
            stream += "\(wrappedValue .map { "\($0 .r) \($0 .g) \($0 .b) \($0 .a)" } .joined (separator: stream .Separator))"
            stream += stream .ListBreak
            
            stream .decIndent ()
            
            stream += stream .TidyIndent
            stream += "]"
      }
   }

   internal final override func toDisplayStream (_ stream : X3DOutputStream)
   {
      stream += "\(wrappedValue .map { "\($0 .r) \($0 .g) \($0 .b) \($0 .a)" } .joined (separator: ",\n"))"
   }
   
   internal final override func fromDisplayStream (_ parser : VRMLParser) -> Bool
   {
      parser .sfcolorrgbaValues (for: self)
      return true
   }
}
