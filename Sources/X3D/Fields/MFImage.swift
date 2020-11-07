//
//  MFImage.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class MFImage :
   X3DArrayField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Element = X3DImage
   public typealias Value   = X3DObjectArray <Element>

   // Property wrapper handling
   
   public final var projectedValue : MFImage { self }
   public final var wrappedValue : Value { value }
   private final let value = Value ()

   // Common properties
   
   internal final override class var typeName : String { "MFImage" }
   internal final override class var type     : X3DFieldType { .MFImage }

   // Construction
   
   public override init ()
   {
      super .init ()

      value .field = self
   }
   
   public convenience init <S> (wrappedValue : S)
      where Element? == S .Element, S : Sequence
   {
      self .init ()

      value .append (contentsOf: wrappedValue)
   }

   public final override func copy () -> MFImage { MFImage (wrappedValue: value .map { $0! .copy () }) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? MFImage else { return }

      value .set (field .value .map
      {
         (image) -> Element? in
         
         if let image = image
         {
            return image .copy ()
         }
         else
         {
            return nil
         }
      }
      .compactMap { $0 })
   }
}
