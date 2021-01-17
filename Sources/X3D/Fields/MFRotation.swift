//
//  MFRotation.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class MFRotation :
   X3DArrayField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Element = Rotation4f
   public typealias Value   = [Element]

   // Property wrapper handling
   
   public final var projectedValue : MFRotation { self }
   public final var wrappedValue   : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "MFRotation" }
   internal final override class var type     : X3DFieldType { .MFRotation }

   // Construction
   
   required public override init ()
   {
      self .wrappedValue = Value ()
   }
   
   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> MFRotation { MFRotation (wrappedValue: wrappedValue) }

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
            let axis = wrappedValue .first! .axis
            stream += "\(axis .x) \(axis .y) \(axis .z) \(stream .toUnit (.angle, value: wrappedValue .first! .angle))"
         default:
            stream += "["
            stream += stream .ListBreak
            
            stream .incIndent ()
            
            stream += stream .Indent
            stream += "\(wrappedValue .map { let axis = $0 .axis; return "\(axis .x) \(axis .y) \(axis .z) \(stream .toUnit (.angle, value: $0 .angle))" } .joined (separator: stream .Separator))"
            stream += stream .ListBreak
            
            stream .decIndent ()
            
            stream += stream .TidyIndent
            stream += "]"
      }
   }

   internal final override func toDisplayStream (_ stream : X3DOutputStream)
   {
      let executionContext = stream .executionContext
      
      stream += "\(wrappedValue .map { let axis = $0 .axis; return "\(axis .x) \(axis .y) \(axis .z) \(executionContext .toUnit (.angle, value: $0 .angle))" } .joined (separator: ",\n"))"
   }

   internal final override func fromDisplayStream (_ parser : VRMLParser) -> Bool
   {
      parser .sfrotationValues (for: self)
      return true
   }
}
