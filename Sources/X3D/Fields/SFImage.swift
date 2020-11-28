//
//  SFImage.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public class SFImage :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = X3DImage
   
   // Property wrapper handling
   
   public final var projectedValue : SFImage { self }
   public var wrappedValue : Value { value }
   private final let value : Value

   // Common properties
   
   internal final override class var typeName : String { "SFImage" }
   internal final override class var type     : X3DFieldType { .SFImage }

   // Construction
   
   required public override init ()
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

   public final override func copy () -> SFImage { SFImage (wrappedValue: wrappedValue .copy ()) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFImage else { return }
      
      wrappedValue .width  = field .wrappedValue .width
      wrappedValue .height = field .wrappedValue .height
      wrappedValue .comp   = field .wrappedValue .comp
      wrappedValue .array  = field .wrappedValue .array
   }
   
   // Input/Output
   
   internal final override func toStream (_ stream : X3DOutputStream)
   {
      stream += String (wrappedValue .width)
      stream += " "
      stream += String (wrappedValue .height)
      stream += " "
      stream += String (wrappedValue .comp)
      
      if !wrappedValue .array .isEmpty
      {
         stream += " "
      }
   }
}
