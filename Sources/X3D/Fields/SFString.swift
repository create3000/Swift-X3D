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
   public final var wrappedValue   : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "SFString" }
   internal final override class var type     : X3DFieldType { .SFString }

   // Construction
   
   required public override init ()
   {
      self .wrappedValue = ""
   }

   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> SFString { SFString (wrappedValue: wrappedValue) }

   // Value handling
   
   public final override func equals (to field : X3DField) -> Bool
   {
      guard let field = field as? Self else { return false }
      
      return wrappedValue == field .wrappedValue
   }

   internal final override func set (value field : X3DField)
   {
      guard let field = field as? Self else { return }
      
      wrappedValue = field .wrappedValue
   }
   
   // Input/Output

   internal final override func toStream (_ stream : X3DOutputStream)
   {
      stream += wrappedValue
   }
   
   public final override func fromDisplayString (_ string : String, scene : X3DScene) -> Bool
   {
      wrappedValue = string
      return true
   }
}

extension String
{
   var escaped : String
   {
      var escaped = "";
   
      for c in self
      {
         switch c
         {
            case "\"", "\\":
               escaped += "\\"
               fallthrough
            default:
               escaped += String (c)
         }
      }
      
      return escaped
   }
   
   var unescaped : String
   {
      let entities = ["\0", "\t", "\n", "\r", "\"", "\'", "\\"]
      var current  = self
      
      for entity in entities
      {
         let descriptionCharacters = entity .debugDescription .dropFirst () .dropLast ()
         let description           = String (descriptionCharacters)
         
         current = current .replacingOccurrences (of: description, with: entity)
      }
       
      return current
   }
}
