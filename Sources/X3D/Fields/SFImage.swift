//
//  SFImage.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class SFImage :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = X3DImage
   
   // Property wrapper handling
   
   public final var projectedValue : SFImage { self }
   public final var wrappedValue : Value { value }
   private final let value : Value

   // Common properties
   
   internal final override class var typeName : String { "SFImage" }
   internal final override class var type     : X3DFieldType { .SFImage }

   // Construction
   
   public override init ()
   {
      value = Value ()
      
      super .init ()
      
      value .addParent (self)
   }
   
   public init (wrappedValue : Value)
   {
      value = wrappedValue
      
      super .init ()
      
      value .addParent (self)
   }

   public final override func copy () -> SFImage { SFImage (wrappedValue: value .copy ()) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFImage else { return }
      
      value .width  = field .value .width
      value .height = field .value .height
      value .comp   = field .value .comp
      
      value .$array .set (value: field .value .$array)
   }
}
