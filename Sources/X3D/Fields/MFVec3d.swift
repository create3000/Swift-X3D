//
//  MFVec3d.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class MFVec3d :
   X3DArrayField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Element = Vector3d
   public typealias Value   = [Element]

   // Property wrapper handling
   
   public final var projectedValue : MFVec3d { self }
   public final var wrappedValue   : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "MFVec3d" }
   internal final override class var type     : X3DFieldType { .MFVec3d }

   // Construction
   
   required public override init ()
   {
      self .wrappedValue = Value ()
   }
   
   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> MFVec3d { MFVec3d (wrappedValue: wrappedValue) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? Self else { return }

      wrappedValue = field .wrappedValue
   }
   
   public final override var count : Int { wrappedValue .count }

   // Input/Output
   
   public final override func equals (to field : X3DField) -> Bool
   {
      guard let field = field as? Self else { return false }
      
      return wrappedValue == field .wrappedValue
   }

   internal final override func toStream (_ stream : X3DOutputStream)
   {
      toVRMLStream (stream)
   }
   
   internal final override func toXMLStream (_ stream : X3DOutputStream)
   {
      let format = "\(stream .doubleFormat) \(stream .doubleFormat) \(stream .doubleFormat)"
      
      stream += wrappedValue .map { String (format: format, stream .toUnit (unit, value: $0.x), stream .toUnit (unit, value: $0.y), stream .toUnit (unit, value: $0.z)) } .joined (separator: stream .Comma + stream .TidySpace)
   }

   internal final override func toJSONStream (_ stream : X3DOutputStream)
   {
      let format = "\(stream .doubleFormat),\(stream .TidySpace)\(stream .doubleFormat),\(stream .TidySpace)\(stream .doubleFormat)"

      stream += "["
      stream += stream .TidySpace
      stream += wrappedValue .map { String (format: format, stream .toUnit (unit, value: $0.x), stream .toUnit (unit, value: $0.y), stream .toUnit (unit, value: $0.z)) } .joined (separator: "," + stream .TidySpace)
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
            let format = "\(stream .doubleFormat) \(stream .doubleFormat) \(stream .doubleFormat)"
            
            stream += String (format: format, stream .toUnit (unit, value: wrappedValue .first! .x), stream .toUnit (unit, value: wrappedValue .first! .y), stream .toUnit (unit, value: wrappedValue .first! .z))
         default:
            let format = "\(stream .doubleFormat) \(stream .doubleFormat) \(stream .doubleFormat)"
            
            stream += "["
            stream += stream .ListBreak
            stream += stream .IncIndent ()
            stream += stream .TidyIndent
            stream += wrappedValue .map { String (format: format, stream .toUnit (unit, value: $0.x), stream .toUnit (unit, value: $0.y), stream .toUnit (unit, value: $0.z)) } .joined (separator: stream .ListSeparator)
            stream += stream .ListBreak
            stream += stream .DecIndent ()
            stream += stream .TidyIndent
            stream += "]"
      }
   }

   internal final override func toDisplayStream (_ stream : X3DOutputStream)
   {
      stream += wrappedValue .map { "\(stream .toUnit (unit, value: $0 .x)) \(stream .toUnit (unit, value: $0 .y)) \(stream .toUnit (unit, value: $0 .z))" } .joined (separator: ",\n")
   }

   internal final override func fromDisplayStream (_ parser : VRMLParser) -> Bool
   {
      parser .sfvec3dValues (for: self)
      return true
   }
}
