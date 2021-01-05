//
//  SFTime.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

@propertyWrapper
public final class SFTime :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = TimeInterval
   
   // Property wrapper handling
   
   public final var projectedValue : SFTime { self }
   public final var wrappedValue   : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "SFTime" }
   internal final override class var type     : X3DFieldType { .SFTime }

   // Construction
   
   required public override init ()
   {
      self .wrappedValue = 0
   }

   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> SFTime { SFTime (wrappedValue: wrappedValue) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFTime else { return }
      
      wrappedValue = field .wrappedValue
   }
   
   // Input/Output
   
   internal final override func toStream (_ stream : X3DOutputStream)
   {
      stream += String (wrappedValue)
   }
   
   internal final override func parse (_ parser : VRMLParser) -> Bool
   {
      return parser .sftimeValue (for: self)
   }
}
