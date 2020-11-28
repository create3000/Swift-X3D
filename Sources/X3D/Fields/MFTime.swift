//
//  MFTime.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

@propertyWrapper
public final class MFTime :
   X3DArrayField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Element = TimeInterval
   public typealias Value   = [Element]

   // Property wrapper handling
   
   public final var projectedValue : MFTime { self }
   public final var wrappedValue   : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "MFTime" }
   internal final override class var type     : X3DFieldType { .MFTime }

   // Construction
   
   required public override init ()
   {
      self .wrappedValue = Value ()
   }
   
   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> MFTime { MFTime (wrappedValue: wrappedValue) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? MFTime else { return }

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
}
