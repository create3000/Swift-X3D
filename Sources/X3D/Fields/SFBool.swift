//
//  SFBool.swift
//  X3D
//
//  Created by Holger Seelig on 09.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class SFBool :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = Bool
   
   // Property wrapper handling
   
   public final var projectedValue : SFBool { self }
   public final var wrappedValue : Value { get { value } set { value = newValue; addEvent () } }
   private final var value : Value
   
   // Common properties
   
   internal final override class var typeName : String { "SFBool" }
   internal final override class var type     : X3DFieldType { .SFBool }

   // Construction
   
   public override init ()
   {
      value = false
   }
   
   public init (wrappedValue : Value)
   {
      value = wrappedValue
   }
   
   public final override func copy () -> SFBool { SFBool (wrappedValue: value) }
   
   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFBool else { return }
      
      value = field .value
   }
}
