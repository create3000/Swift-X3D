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
   public final var wrappedValue : Value { get { value } set { value = newValue; addEvent () } }
   private final var value : Value

   // Common properties
   
   public final override class var typeName : String { "SFString" }
   public final override class var type     : X3DFieldType { .SFString }

   // Construction
   
   public override init ()
   {
      value = ""
   }

   public init (wrappedValue : Value)
   {
      value = wrappedValue
   }
   
   public final override func copy () -> SFString { SFString (wrappedValue: value) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFString else { return }
      
      value = field .value
   }
}
