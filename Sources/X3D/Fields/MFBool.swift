//
//  MFBool.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class MFBool :
   X3DArrayField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Element = Bool
   public typealias Value   = [Element]

   // Property wrapper handling
   
   public final var projectedValue : MFBool { self }
   public final var wrappedValue   : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "MFBool" }
   internal final override class var type     : X3DFieldType { .MFBool }

   // Construction
   
   required public override init ()
   {
      self .wrappedValue = Value ()
   }
   
   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> MFBool { MFBool (wrappedValue: wrappedValue) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? MFBool else { return }

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
            stream += wrappedValue .first! ? "TRUE" : "FALSE"
         default:
            stream += "[\(wrappedValue .map { $0 ? "TRUE" : "FALSE" } .joined (separator: ", "))]"
      }
   }
}
