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
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFRotation else { return }
      
      wrappedValue = field .wrappedValue
   }
   
   // Input/Output
   
   internal final override func toStream (_ stream : X3DOutputStream)
   {
      let axis  = wrappedValue .axis
      let angle = wrappedValue .angle

      stream += "\(axis .x) \(axis .y) \(axis .z) \(angle)"
   }
}
