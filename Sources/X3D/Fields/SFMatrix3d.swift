//
//  SFMatrix3d.swift
//  X3D
//
//  Created by Holger Seelig on 09.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class SFMatrix3d :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = Matrix3d
   
   // Property wrapper handling
   
   public final var projectedValue : SFMatrix3d { self }
   public final var wrappedValue   : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "SFMatrix3d" }
   internal final override class var type     : X3DFieldType { .SFMatrix3d }

   // Construction
   
   required public override init ()
   {
      self .wrappedValue = Matrix3d .identity
   }

   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> SFMatrix3d { SFMatrix3d (wrappedValue: wrappedValue) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFMatrix3d else { return }
      
      wrappedValue = field .wrappedValue
   }
   
   // Input/Output
   
   internal final override func toStream (_ stream : X3DOutputStream)
   {
      let c0 = wrappedValue [0]
      let c1 = wrappedValue [1]
      let c2 = wrappedValue [2]

      stream += "\(c0.x) \(c0.y) \(c0.z)"
      stream += " "
      stream += "\(c1.x) \(c1.y) \(c1.z)"
      stream += " "
      stream += "\(c2.x) \(c2.y) \(c2.z)"
   }
}
