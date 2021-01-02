//
//  SFDouble.swift
//  X3D
//
//  Created by Holger Seelig on 09.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class SFDouble :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = Double
   
   // Property wrapper handling
   
   public final var projectedValue : SFDouble { self }
   public final var wrappedValue   : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "SFDouble" }
   internal final override class var type     : X3DFieldType { .SFDouble }

   // Construction
   
   required public override init ()
   {
      self .wrappedValue = 0
   }

   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> SFDouble { SFDouble (wrappedValue: wrappedValue) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFDouble else { return }
      
      wrappedValue = field .wrappedValue
   }
   
   // Input/Output

   internal final override func toStream (_ stream : X3DOutputStream)
   {
      stream += String (wrappedValue)
   }
}
