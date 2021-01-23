//
//  MFMatrix3f.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class MFMatrix3f :
   X3DArrayField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Element = Matrix3f
   public typealias Value   = [Element]

   // Property wrapper handling
   
   public final var projectedValue : MFMatrix3f { self }
   public final var wrappedValue   : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "MFMatrix3f" }
   internal final override class var type     : X3DFieldType { .MFMatrix3f }

   // Construction
   
   required public override init ()
   {
      self .wrappedValue = Value ()
   }
   
   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> MFMatrix3f { MFMatrix3f (wrappedValue: wrappedValue) }

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
   
   public final override var count : Int { wrappedValue .count }

   // Input/Output
   
   internal final override func toStream (_ stream : X3DOutputStream)
   {
      toVRMLStream (stream)
   }

   internal final override func toXMLStream (_ stream : X3DOutputStream)
   {
      let format = "\(stream .floatFormat) \(stream .floatFormat) \(stream .floatFormat)"

      stream += wrappedValue .map
      {
         let c0 = $0 [0]
         let c1 = $0 [1]
         let c2 = $0 [2]

         var string = ""

         string += String (format: format, c0.x, c0.y, c0.z)
         string += " "
         string += String (format: format, c1.x, c1.y, c1.z)
         string += " "
         string += String (format: format, c2.x, c2.y, c2.z)

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
            let c0 = wrappedValue .first! [0]
            let c1 = wrappedValue .first! [1]
            let c2 = wrappedValue .first! [2]

            let format = "\(stream .floatFormat) \(stream .floatFormat) \(stream .floatFormat)"
            
            stream += String (format: format, c0.x, c0.y, c0.z)
            stream += " "
            stream += String (format: format, c1.x, c1.y, c1.z)
            stream += " "
            stream += String (format: format, c2.x, c2.y, c2.z)
         default:
            let format = "\(stream .floatFormat) \(stream .floatFormat) \(stream .floatFormat)"
            
            stream += "["
            stream += stream .ListBreak
            stream += stream .IncIndent ()
            stream += stream .TidyIndent
            stream += wrappedValue .map
            {
               let c0 = $0 [0]
               let c1 = $0 [1]
               let c2 = $0 [2]
               
               var string = ""
               
               string += String (format: format, c0.x, c0.y, c0.z)
               string += " "
               string += String (format: format, c1.x, c1.y, c1.z)
               string += " "
               string += String (format: format, c2.x, c2.y, c2.z)

               return string
            }
            .joined (separator: stream .ListSeparator)
            stream += stream .ListBreak
            stream += stream .DecIndent ()
            stream += stream .TidyIndent
            stream += "]"
      }
   }

   internal final override func toDisplayStream (_ stream : X3DOutputStream)
   {
      stream += wrappedValue .map
      {
         let c0 = $0 [0]
         let c1 = $0 [1]
         let c2 = $0 [2]

         var string = ""

         string += "\(c0.x) \(c0.y) \(c0.z)"
         string += " "
         string += "\(c1.x) \(c1.y) \(c1.z)"
         string += " "
         string += "\(c2.x) \(c2.y) \(c2.z)"

         return string
      }
      .joined (separator: ",\n")
   }

   internal final override func fromDisplayStream (_ parser : VRMLParser) -> Bool
   {
      parser .sfmatrix3fValues (for: self)
      return true
   }
}
