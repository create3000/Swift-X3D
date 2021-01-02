//
//  MFVec4d.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class MFVec4d :
   X3DArrayField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Element = Vector4d
   public typealias Value   = [Element]

   // Property wrapper handling
   
   public final var projectedValue : MFVec4d { self }
   public final var wrappedValue   : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "MFVec4d" }
   internal final override class var type     : X3DFieldType { .MFVec4d }

   // Construction
   
   required public override init ()
   {
      self .wrappedValue = Value ()
   }
   
   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> MFVec4d { MFVec4d (wrappedValue: wrappedValue) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? MFVec4d else { return }

      wrappedValue = field .wrappedValue
   }
   
   // Input/Output
   
   public final override var description : String
   {
      return "\(wrappedValue .map { "\($0 .x) \($0 .y) \($0 .z) \($0 .w)" } .joined (separator: ",\n"))"
   }

   internal final override func toStream (_ stream : X3DOutputStream)
   {
      switch wrappedValue .count
      {
         case 0:
            stream += "[ ]"
         case 1:
            stream += "\(wrappedValue .first! .x) \(wrappedValue .first! .y) \(wrappedValue .first! .z) \(wrappedValue .first! .w)"
         default:
            stream += "[\(wrappedValue .map { "\($0 .x) \($0 .y) \($0 .z) \($0 .w)" } .joined (separator: ", "))]"
      }
   }
}
