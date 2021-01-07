//
//  MFMatrix4f.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class MFMatrix4f :
   X3DArrayField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Element = Matrix4f
   public typealias Value   = [Element]

   // Property wrapper handling
   
   public final var projectedValue : MFMatrix4f { self }
   public final var wrappedValue   : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "MFMatrix4f" }
   internal final override class var type     : X3DFieldType { .MFMatrix4f }

   // Construction
   
   required public override init ()
   {
      self .wrappedValue = Value ()
   }
   
   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> MFMatrix4f { MFMatrix4f (wrappedValue: wrappedValue) }

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
      switch wrappedValue .count
      {
         case 0:
            stream += "[ ]"
         case 1:
            let c0 = wrappedValue .first! [0]
            let c1 = wrappedValue .first! [1]
            let c2 = wrappedValue .first! [2]
            let c3 = wrappedValue .first! [3]

            stream += "\(c0.x) \(c0.y) \(c0.z) \(c0.w)"
            stream += " "
            stream += "\(c1.x) \(c1.y) \(c1.z) \(c1.w)"
            stream += " "
            stream += "\(c2.x) \(c2.y) \(c2.z) \(c2.w)"
            stream += " "
            stream += "\(c3.x) \(c3.y) \(c3.z) \(c3.w)"
         default:
            stream += """
[\(wrappedValue .map
{
   let c0 = $0 [0]
   let c1 = $0 [1]
   let c2 = $0 [2]
   let c3 = $0 [3]
   
   var string = ""
   
   string += "\(c0.x) \(c0.y) \(c0.z) \(c0.w)"
   string += " "
   string += "\(c1.x) \(c1.y) \(c1.z) \(c1.w)"
   string += " "
   string += "\(c2.x) \(c2.y) \(c2.z) \(c2.w)"
   string += " "
   string += "\(c3.x) \(c3.y) \(c3.z) \(c3.w)"
   
   return string
}
.joined (separator: ", "))]
"""
      }
   }
   
   internal final override func toDisplayStream (_ stream : X3DOutputStream)
   {
      stream += """
\(wrappedValue .map
{
   let c0 = $0 [0]
   let c1 = $0 [1]
   let c2 = $0 [2]
   let c3 = $0 [3]

   var string = ""

   string += "\(c0.x) \(c0.y) \(c0.z) \(c0.w)"
   string += "\n"
   string += "\(c1.x) \(c1.y) \(c1.z) \(c1.w)"
   string += "\n"
   string += "\(c2.x) \(c2.y) \(c2.z) \(c2.w)"
   string += "\n"
   string += "\(c3.x) \(c3.y) \(c3.z) \(c3.w)"

   return string
}
.joined (separator: ", "))
"""
   }

   internal final override func fromDisplayStream (_ parser : VRMLParser) -> Bool
   {
      parser .sfmatrix4fValues (for: self)
      return true
   }
}
