//
//  SFRotation.swift
//  X3D
//
//  Created by Holger Seelig on 09.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public class SFRotation :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = Rotation4f
   
   // Property wrapper handling
   
   public final var projectedValue : SFRotation { self }
   public var wrappedValue         : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "SFRotation" }
   internal final override class var type     : X3DFieldType { .SFRotation }

   // Construction
   
   required public override init ()
   {
      self .wrappedValue = Rotation4f .identity
   }

   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> SFRotation { SFRotation (wrappedValue: wrappedValue) }

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
      let axis  = wrappedValue .axis
      let angle = wrappedValue .angle

      stream += String (format: "\(stream .floatFormat) \(stream .floatFormat) \(stream .floatFormat) \(stream .floatFormat)", axis .x, axis .y, axis .z, stream .toUnit (.angle, value: angle))
   }

   internal final override func toDisplayStream (_ stream : X3DOutputStream)
   {
      let axis  = wrappedValue .axis
      let angle = wrappedValue .angle

      stream += "\(axis .x) \(axis .y) \(axis .z) \(stream .toUnit (.angle, value: angle))"
   }

   internal final override func fromDisplayStream (_ parser : VRMLParser) -> Bool
   {
      return parser .sfrotationValue (for: self)
   }
}
