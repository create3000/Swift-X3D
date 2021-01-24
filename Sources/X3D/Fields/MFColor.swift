//
//  MFColor.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class MFColor :
   X3DArrayField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Element = Color3f
   public typealias Value   = [Element]

   // Property wrapper handling
   
   public final var projectedValue : MFColor { self }
   public final var wrappedValue   : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "MFColor" }
   internal final override class var type     : X3DFieldType { .MFColor }

   // Construction
   
   required public override init ()
   {
      self .wrappedValue = Value ()
   }
   
   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> MFColor { MFColor (wrappedValue: wrappedValue) }

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
   
   public final override var count : Int { wrappedValue .count }

   // Input/Output

   internal final override func toStream (_ stream : X3DOutputStream)
   {
      toVRMLStream (stream)
   }
   
   internal final override func toXMLStream (_ stream : X3DOutputStream)
   {
      let format = "\(stream .floatFormat) \(stream .floatFormat) \(stream .floatFormat)"
      
      stream += wrappedValue .map { String (format: format, $0.r, $0.g, $0.b) } .joined (separator: stream .Comma + stream .TidySpace)
   }

   internal final override func toJSONStream (_ stream : X3DOutputStream)
   {
      let format = "\(stream .floatFormat),\(stream .TidySpace)\(stream .floatFormat),\(stream .TidySpace)\(stream .floatFormat)"
      
      stream += "["
      stream += stream .TidySpace
      stream += wrappedValue .map { String (format: format, $0.r, $0.g, $0.b) } .joined (separator: "," + stream .TidySpace)
      stream += stream .TidySpace
      stream += "]"
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
            stream += String (format: "\(stream .floatFormat) \(stream .floatFormat) \(stream .floatFormat)", wrappedValue .first! .r, wrappedValue .first! .g, wrappedValue .first! .b)
         default:
            let format = "\(stream .floatFormat) \(stream .floatFormat) \(stream .floatFormat)"
            
            stream += "["
            stream += stream .ListBreak
            stream += stream .IncIndent ()
            stream += stream .TidyIndent
            stream += wrappedValue .map { String (format: format, $0.r, $0.g, $0.b) } .joined (separator: stream .ListSeparator)
            stream += stream .ListBreak
            stream += stream .DecIndent ()
            stream += stream .TidyIndent
            stream += "]"
      }
   }

   internal final override func toDisplayStream (_ stream : X3DOutputStream)
   {
      stream += wrappedValue .map { "\($0 .r) \($0 .g) \($0 .b)" } .joined (separator: ",\n")
   }

   internal final override func fromDisplayStream (_ parser : VRMLParser) -> Bool
   {
      parser .sfcolorValues (for: self)
      return true
   }
}
