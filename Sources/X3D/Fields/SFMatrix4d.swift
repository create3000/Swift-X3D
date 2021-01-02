//
//  SFMatrix4d.swift
//  X3D
//
//  Created by Holger Seelig on 09.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public class SFMatrix4d :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = Matrix4d
   
   // Property wrapper handling
   
   public final var projectedValue : SFMatrix4d { self }
   public var wrappedValue         : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "SFMatrix4d" }
   internal final override class var type     : X3DFieldType { .SFMatrix4d }

   // Construction
   
   required public override init ()
   {
      self .wrappedValue = Matrix4d .identity
   }

   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> SFMatrix4d { SFMatrix4d (wrappedValue: wrappedValue) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFMatrix4d else { return }
      
      wrappedValue = field .wrappedValue
   }
   
   // Input/Output
   
   public final override var description : String
   {
      var string = ""
      
      let c0 = wrappedValue [0]
      let c1 = wrappedValue [1]
      let c2 = wrappedValue [2]
      let c3 = wrappedValue [3]

      string += "\(c0.x) \(c0.y) \(c0.z) \(c0.w)"
      string += " "
      string += "\(c1.x) \(c1.y) \(c1.z) \(c1.w)"
      string += " "
      string += "\(c2.x) \(c2.y) \(c2.z) \(c2.w)"
      string += " "
      string += "\(c3.x) \(c3.y) \(c3.z) \(c3.w)"

      return string
   }

   internal final override func toStream (_ stream : X3DOutputStream)
   {
      let c0 = wrappedValue [0]
      let c1 = wrappedValue [1]
      let c2 = wrappedValue [2]
      let c3 = wrappedValue [3]

      stream += "\(c0.x) \(c0.y) \(c0.z) \(c0.w)"
      stream += " "
      stream += "\(c1.x) \(c1.y) \(c1.z) \(c1.w)"
      stream += " "
      stream += "\(c2.x) \(c2.y) \(c2.z) \(c2.w)"
      stream += " "
      stream += "\(c3.x) \(c3.y) \(c3.z) \(c3.w)"
   }
}
