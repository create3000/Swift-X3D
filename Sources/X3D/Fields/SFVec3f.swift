//
//  SFVec3f.swift
//  X3D
//
//  Created by Holger Seelig on 09.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public class SFVec3f :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = Vector3f
   
   // Property wrapper handling
   
   public final var projectedValue : SFVec3f { self }
   public var wrappedValue         : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "SFVec3f" }
   internal final override class var type     : X3DFieldType { .SFVec3f }

   // Construction
   
   required public override init ()
   {
      self .wrappedValue = Vector3f .zero
   }

   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> SFVec3f { SFVec3f (wrappedValue: wrappedValue) }

   // Value handling
   
   public final override var isDefaultValue : Bool { wrappedValue == .zero }

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
   
   internal final override func toJSONStream (_ stream : X3DOutputStream)
   {
      let x = stream .toUnit (unit, value: wrappedValue .x)
      let y = stream .toUnit (unit, value: wrappedValue .y)
      let z = stream .toUnit (unit, value: wrappedValue .z)

      stream += "["
      stream += stream .TidySpace
      stream += String (format: "\(stream .floatFormat),\(stream .TidySpace)\(stream .floatFormat),\(stream .TidySpace)\(stream .floatFormat)", x, y, z)
      stream += stream .TidySpace
      stream += "]"
   }

   internal final override func toVRMLStream (_ stream : X3DOutputStream)
   {
      let x = stream .toUnit (unit, value: wrappedValue .x)
      let y = stream .toUnit (unit, value: wrappedValue .y)
      let z = stream .toUnit (unit, value: wrappedValue .z)

      stream += String (format: "\(stream .floatFormat) \(stream .floatFormat) \(stream .floatFormat)", x, y, z)
   }

   internal final override func toDisplayStream (_ stream : X3DOutputStream)
   {
      let x = stream .toUnit (unit, value: wrappedValue .x)
      let y = stream .toUnit (unit, value: wrappedValue .y)
      let z = stream .toUnit (unit, value: wrappedValue .z)

      stream += "\(x) \(y) \(z)"
   }

   internal final override func fromDisplayStream (_ parser : VRMLParser) -> Bool
   {
      return parser .sfvec3fValue (for: self)
   }
}
