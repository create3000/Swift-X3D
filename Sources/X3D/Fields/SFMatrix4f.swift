//
//  SFMatrix4f.swift
//  X3D
//
//  Created by Holger Seelig on 09.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public class SFMatrix4f :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = Matrix4f
   
   // Property wrapper handling
   
   public final var projectedValue : SFMatrix4f { self }
   public var wrappedValue         : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "SFMatrix4f" }
   internal final override class var type     : X3DFieldType { .SFMatrix4f }

   // Construction
   
   required public override init ()
   {
      self .wrappedValue = Matrix4f .identity
   }

   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> SFMatrix4f { SFMatrix4f (wrappedValue: wrappedValue) }

   // Value handling
   
   public final override var isDefaultValue : Bool { wrappedValue == .identity }

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
      toVRMLStream (stream)
   }
   
   internal final override func toXMLStream (_ stream : X3DOutputStream)
   {
      toVRMLStream (stream)
   }
   
   internal final override func toJSONStream (_ stream : X3DOutputStream)
   {
      let c0 = wrappedValue [0]
      let c1 = wrappedValue [1]
      let c2 = wrappedValue [2]
      let c3 = wrappedValue [3]
      
      let format = "\(stream .floatFormat),\(stream .TidySpace)\(stream .floatFormat),\(stream .TidySpace)\(stream .floatFormat),\(stream .TidySpace)\(stream .floatFormat)"

      stream += "["
      stream += stream .TidySpace
      stream += String (format: format, c0.x, c0.y, c0.z, c0.w)
      stream += ","
      stream += stream .TidySpace
      stream += String (format: format, c1.x, c1.y, c1.z, c1.w)
      stream += ","
      stream += stream .TidySpace
      stream += String (format: format, c2.x, c2.y, c2.z, c2.w)
      stream += ","
      stream += stream .TidySpace
      stream += String (format: format, c3.x, c3.y, c3.z, c3.w)
      stream += stream .TidySpace
      stream += "]"
   }

   internal final override func toVRMLStream (_ stream : X3DOutputStream)
   {
      let c0 = wrappedValue [0]
      let c1 = wrappedValue [1]
      let c2 = wrappedValue [2]
      let c3 = wrappedValue [3]
      
      let format = "\(stream .floatFormat) \(stream .floatFormat) \(stream .floatFormat) \(stream .floatFormat)"

      stream += String (format: format, c0.x, c0.y, c0.z, c0.w)
      stream += " "
      stream += String (format: format, c1.x, c1.y, c1.z, c1.w)
      stream += " "
      stream += String (format: format, c2.x, c2.y, c2.z, c2.w)
      stream += " "
      stream += String (format: format, c3.x, c3.y, c3.z, c3.w)
   }

   internal final override func toDisplayStream (_ stream : X3DOutputStream)
   {
      let c0 = wrappedValue [0]
      let c1 = wrappedValue [1]
      let c2 = wrappedValue [2]
      let c3 = wrappedValue [3]

      stream += "\(c0.x) \(c0.y) \(c0.z) \(c0.w)"
      stream += " "
      stream += "\(c1.x) \(c1.y) \(c1.z) \(c1.w)"
      stream += " "
      stream += "\(c2.x) \(c2.y) \(c2.z) \(c2.w)"
      stream += " "
      stream += "\(c3.x) \(c3.y) \(c3.z) \(c3.w)"
   }

   internal final override func fromDisplayStream (_ parser : VRMLParser) -> Bool
   {
      return parser .sfmatrix4fValue (for: self)
   }
}
