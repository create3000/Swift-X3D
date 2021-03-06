//
//  SFVec2d.swift
//  X3D
//
//  Created by Holger Seelig on 09.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public class SFVec2d :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = Vector2d
   
   // Property wrapper handling
   
   public final var projectedValue : SFVec2d { self }
   public var wrappedValue         : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "SFVec2d" }
   internal final override class var type     : X3DFieldType { .SFVec2d }

   // Construction
   
   required public override init ()
   {
      self .wrappedValue = Vector2d .zero
   }

   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> SFVec2d { SFVec2d (wrappedValue: wrappedValue) }

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

      stream += "["
      stream += stream .TidySpace
      stream += String (format: "\(stream .doubleFormat),\(stream .TidySpace)\(stream .doubleFormat)", x, y)
      stream += stream .TidySpace
      stream += "]"
   }

   internal final override func toVRMLStream (_ stream : X3DOutputStream)
   {
      let x = stream .toUnit (unit, value: wrappedValue .x)
      let y = stream .toUnit (unit, value: wrappedValue .y)

      stream += String (format: "\(stream .doubleFormat) \(stream .doubleFormat)", x, y)
   }

   internal final override func toDisplayStream (_ stream : X3DOutputStream)
   {
      let x = stream .toUnit (unit, value: wrappedValue .x)
      let y = stream .toUnit (unit, value: wrappedValue .y)

      stream += "\(x) \(y)"
   }
   
   internal final override func fromDisplayStream (_ parser : VRMLParser) -> Bool
   {
      return parser .sfvec2dValue (for: self)
   }
}
