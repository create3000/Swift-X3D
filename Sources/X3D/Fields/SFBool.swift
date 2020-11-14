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
   public final var wrappedValue : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "SFBool" }
   internal final override class var type     : X3DFieldType { .SFBool }

   // Construction
   
   public override init ()
   {
      self .wrappedValue = false
   }
   
   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> SFBool { SFBool (wrappedValue: wrappedValue) }
   
   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFBool else { return }
      
      wrappedValue = field .wrappedValue
   }
}
