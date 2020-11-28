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
   public typealias Value   = [Element]
   
   // Property wrapper handling
   
   public final var projectedValue : MFImage { self }
   public final var wrappedValue   : Value
   {
      willSet
      {
         let difference = newValue .difference (from: wrappedValue)
         
         for change in difference
         {
            switch change
            {
               case let .insert (_, newElement, _):
                  newElement .addParent (self)
               default:
                  break
            }
         }

         for change in difference
         {
            switch change
            {
              case let .remove (_, oldElement, _):
                  oldElement .removeParent (self)
               default:
                  break
            }
         }
      }
      
      didSet { addEvent () }
   }


   // Common properties
   
   internal final override class var typeName : String { "MFImage" }
   internal final override class var type     : X3DFieldType { .MFImage }

   // Construction
   
   required public override init ()
   {
      self .wrappedValue = [ ]
      
      super .init ()
   }
   
   public convenience init (wrappedValue : Value)
   {
      self .init ()

      self .wrappedValue = wrappedValue .map { $0 .copy () }
   }

   public final override func copy () -> MFImage { MFImage (wrappedValue: wrappedValue .map { $0 .copy () }) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? MFImage else { return }
      
      wrappedValue = field .wrappedValue .map { $0 .copy () }
   }
}
