//
//  MFFloat.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class MFFloat :
   X3DArrayField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Element = Float
   public typealias Value   = [Element]

   // Property wrapper handling
   
   public final var projectedValue : MFFloat { self }
   public final var wrappedValue   : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "MFFloat" }
   internal final override class var type     : X3DFieldType { .MFFloat }

   // Construction
   
   required public override init ()
   {
      self .wrappedValue = Value ()
   }
   
   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> MFFloat { MFFloat (wrappedValue: wrappedValue) }

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
      switch wrappedValue .count
      {
         case 0:
            stream += "[ ]"
         case 1:
            stream += String (wrappedValue .first!)
         default:
            stream += "[\(wrappedValue .map { String ($0) } .joined (separator: ", "))]"
      }
   }
   
   internal final override func toDisplayStream (_ stream : X3DOutputStream)
   {
      let executionContext = stream .executionContext
      
      stream += "\(wrappedValue .map { String (executionContext .toUnit (unit, value: $0)) } .joined (separator: ",\n"))"
   }

   internal final override func fromDisplayStream (_ parser : VRMLParser) -> Bool
   {
      parser .sffloatValues (for: self)
      return true
   }
}
