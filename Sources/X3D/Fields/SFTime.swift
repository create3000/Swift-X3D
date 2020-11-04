//
//  SFTime.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

@propertyWrapper
public final class SFTime :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = TimeInterval
   
   // Property wrapper handling
   
   public final var projectedValue : SFTime { self }
   public final var wrappedValue : Value { get { value } set { value = newValue; addEvent () } }
   private final var value : Value

   // Common properties
   
   public final override class var typeName : String { "SFTime" }
   public final override class var type     : X3DFieldType { .SFTime }

   // Construction
   
   public override init ()
   {
      value = 0
   }

   public init (wrappedValue : Value)
   {
      value = wrappedValue
   }
   
   public final override func copy () -> SFTime { SFTime (wrappedValue: value) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFTime else { return }
      
      value = field .value
   }
}