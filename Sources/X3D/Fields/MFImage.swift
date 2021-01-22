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
   
   public final override func equals (to field : X3DField) -> Bool
   {
      guard let field = field as? Self else { return false }
      
      return wrappedValue == field .wrappedValue
   }

   internal final override func set (value field : X3DField)
   {
      guard let field = field as? Self else { return }
      
      wrappedValue = field .wrappedValue .map { $0 .copy () }
   }
   
   public final override var count : Int { wrappedValue .count }

   // Input/Output

   internal final override func toStream (_ stream : X3DOutputStream)
   {
      toVRMLStream (stream)
   }
   
   internal final override func toXMLStream (_ stream : X3DOutputStream)
   {
      stream += wrappedValue .map
      {
         var string = ""

         string += String ($0 .width)
         string += " "
         string += String ($0 .height)
         string += " "
         string += String ($0 .comp)

         if !$0 .array .isEmpty
         {
            string += " "
            string += $0 .array .map { String (format: "0x%x", $0) } .joined (separator: " ")
         }

         return string
      }
      .joined (separator: stream .Comma + stream .TidySpace)
   }

   internal final override func toVRMLStream (_ stream : X3DOutputStream)
   {
      switch wrappedValue .count
      {
         case 0:
            stream += "["
            stream += stream .TidySpace
            stream += "]"
         case 1:
            stream += String (wrappedValue .first! .width)
            stream += " "
            stream += String (wrappedValue .first! .height)
            stream += " "
            stream += String (wrappedValue .first! .comp)
            
            if !wrappedValue .first! .array .isEmpty
            {
               stream += " "
               stream += wrappedValue .first! .array .map { String (format: "0x%x", $0) } .joined (separator: " ")
            }
         default:
            stream += "["
            stream += stream .ListBreak
            
            stream .incIndent ()
            
            stream += stream .TidyIndent
            stream += wrappedValue .map
            {
               var string = ""
               
               string += String ($0 .width)
               string += " "
               string += String ($0 .height)
               string += " "
               string += String ($0 .comp)
               
               if !$0 .array .isEmpty
               {
                  string += " "
                  string += $0 .array .map { String (format: "0x%x", $0) } .joined (separator: " ")
               }
               
               return string
            }
            .joined (separator: stream .ListSeparator)
            stream += stream .ListBreak
            
            stream .decIndent ()
            
            stream += stream .TidyIndent
            stream += "]"
      }
   }

   internal final override func toDisplayStream (_ stream : X3DOutputStream)
   {
      stream += wrappedValue .map
      {
         var string = ""

         string += String ($0 .width)
         string += " "
         string += String ($0 .height)
         string += " "
         string += String ($0 .comp)

         if !$0 .array .isEmpty
         {
            string += " "
            string += $0 .array .map { String (format: "0x%x", $0) } .joined (separator: " ")
         }

         return string
      }
      .joined (separator: ",\n")
   }

   internal final override func fromDisplayStream (_ parser : VRMLParser) -> Bool
   {
      try? parser .sfimageValues (for: self)
      return true
   }
}
