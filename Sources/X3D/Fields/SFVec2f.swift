//
//  SFVec2f.swift
//  X3D
//
//  Created by Holger Seelig on 09.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public class SFVec2f :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = Vector2f
   
   // Property wrapper handling
   
   public final var projectedValue : SFVec2f { self }
   public var wrappedValue         : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "SFVec2f" }
   internal final override class var type     : X3DFieldType { .SFVec2f }

   // Construction
   
   required public override init ()
   {
      self .wrappedValue = Vector2f .zero
   }

   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> SFVec2f { SFVec2f (wrappedValue: wrappedValue) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFVec2f else { return }
      
      wrappedValue = field .wrappedValue
   }
   
   // Input/Output
   
   internal final override func toStream (_ stream : X3DOutputStream)
   {
      stream += "\(wrappedValue .x) \(wrappedValue .y)"
   }
}
