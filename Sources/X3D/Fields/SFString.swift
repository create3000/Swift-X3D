//
//  SFString.swift
//  X3D
//
//  Created by Holger Seelig on 09.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class SFString :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = String
   
   // Property wrapper handling
   
   public final var projectedValue : SFString { self }
   public final var wrappedValue   : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "SFString" }
   internal final override class var type     : X3DFieldType { .SFString }

   // Construction
   
   public override init ()
   {
      self .wrappedValue = ""
   }

   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> SFString { SFString (wrappedValue: wrappedValue) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFString else { return }
      
      wrappedValue = field .wrappedValue
   }
}
