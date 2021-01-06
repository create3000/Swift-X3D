//
//  SFVec4d.swift
//  X3D
//
//  Created by Holger Seelig on 09.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public class SFVec4d :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = Vector4d
   
   // Property wrapper handling
   
   public final var projectedValue : SFVec4d { self }
   public var wrappedValue         : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "SFVec4d" }
   internal final override class var type     : X3DFieldType { .SFVec4d }

   // Construction
   
   required public override init ()
   {
      self .wrappedValue = Vector4d .zero
   }

   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> SFVec4d { SFVec4d (wrappedValue: wrappedValue) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFVec4d else { return }
      
      wrappedValue = field .wrappedValue
   }
   
   // Input/Output
   
   internal final override func toStream (_ stream : X3DOutputStream)
   {
      stream += "\(wrappedValue .x) \(wrappedValue .y) \(wrappedValue .z) \(wrappedValue .w)"
   }
   
   internal final override func toPrettyStream (_ stream : X3DOutputStream)
   {
      let x = stream .executionContext .toUnit (unit, value: wrappedValue .x)
      let y = stream .executionContext .toUnit (unit, value: wrappedValue .y)
      let z = stream .executionContext .toUnit (unit, value: wrappedValue .z)
      let w = stream .executionContext .toUnit (unit, value: wrappedValue .w)

      stream += "\(x) \(y) \(z) \(w)"
   }

   internal final override func fromPrettyStream (_ parser : VRMLParser) -> Bool
   {
      return parser .sfvec4dValue (for: self)
   }
}
