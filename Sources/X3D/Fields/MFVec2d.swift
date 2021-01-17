//
//  MFVec2d.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class MFVec2d :
   X3DArrayField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Element = Vector2d
   public typealias Value   = [Element]

   // Property wrapper handling
   
   public final var projectedValue : MFVec2d { self }
   public final var wrappedValue   : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "MFVec2d" }
   internal final override class var type     : X3DFieldType { .MFVec2d }

   // Construction
   
   required public override init ()
   {
      self .wrappedValue = Value ()
   }
   
   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> MFVec2d { MFVec2d (wrappedValue: wrappedValue) }

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
   
   internal final override func toVRMLStream (_ stream : X3DOutputStream)
   {
      switch wrappedValue .count
      {
         case 0:
            stream += "["
            stream += stream .TidySpace
            stream += "]"
         case 1:
            let format = "\(stream .doubleFormat) \(stream .doubleFormat)"
            
            stream += String (format: format, stream .toUnit (unit, value: wrappedValue .first! .x), stream .toUnit (unit, value: wrappedValue .first! .y))
         default:
            let format = "\(stream .doubleFormat) \(stream .doubleFormat)"
            
            stream += "["
            stream += stream .ListBreak
            
            stream .incIndent ()
            
            stream += stream .TidyIndent
            stream += "\(wrappedValue .map { String (format: format, stream .toUnit (unit, value: $0.x), stream .toUnit (unit, value: $0.y)) } .joined (separator: stream .Separator))"
            stream += stream .ListBreak
            
            stream .decIndent ()
            
            stream += stream .TidyIndent
            stream += "]"
      }
   }

   internal final override func toDisplayStream (_ stream : X3DOutputStream)
   {
      stream += "\(wrappedValue .map { "\(stream .toUnit (unit, value: $0 .x)) \(stream .toUnit (unit, value: $0 .y))" } .joined (separator: ",\n"))"
   }

   internal final override func fromDisplayStream (_ parser : VRMLParser) -> Bool
   {
      parser .sfvec2dValues (for: self)
      return true
   }
}
