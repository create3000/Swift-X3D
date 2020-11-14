//
//  SFColorRGBA.swift
//  X3D
//
//  Created by Holger Seelig on 09.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class SFColorRGBA :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = Color4f
   
   // Property wrapper handling
   
   public final var projectedValue : SFColorRGBA { self }
   public final var wrappedValue : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "SFColorRGBA" }
   internal final override class var type     : X3DFieldType { .SFColorRGBA }

   // Construction
   
   public override init ()
   {
      self .wrappedValue = Color4f .zero
   }

   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> SFColorRGBA { SFColorRGBA (wrappedValue: wrappedValue) }
   
   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFColorRGBA else { return }
      
      wrappedValue = field .wrappedValue
   }
}
