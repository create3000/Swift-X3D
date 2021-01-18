//
//  SFFloat.swift
//  X3D
//
//  Created by Holger Seelig on 09.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class SFFloat :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = Float
   
   // Property wrapper handling
   
   public final var projectedValue : SFFloat { self }
   public final var wrappedValue   : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "SFFloat" }
   internal final override class var type     : X3DFieldType { .SFFloat }

   // Construction
   
   required public override init ()
   {
      self .wrappedValue = 0
   }

   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> SFFloat { SFFloat (wrappedValue: wrappedValue) }

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
   
   internal final override func toXMLStream (_ stream : X3DOutputStream)
   {
      toVRMLStream (stream)
   }
   
   internal final override func toVRMLStream (_ stream : X3DOutputStream)
   {
      stream += String (format: stream .floatFormat, stream .toUnit (unit, value: wrappedValue))
   }

   internal final override func toDisplayStream (_ stream : X3DOutputStream)
   {
      stream += String (stream .toUnit (unit, value: wrappedValue))
   }

   internal final override func fromDisplayStream (_ parser : VRMLParser) -> Bool
   {
      return parser .sffloatValue (for: self)
   }
}
