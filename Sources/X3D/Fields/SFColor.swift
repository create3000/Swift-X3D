//
//  SFColor.swift
//  X3D
//
//  Created by Holger Seelig on 09.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public class SFColor :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = Color3f
   
   // Property wrapper handling
   
   public final var projectedValue : SFColor { self }
   public var wrappedValue         : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "SFColor" }
   internal final override class var type     : X3DFieldType { .SFColor }

   // Construction
   
   required public override init ()
   {
      self .wrappedValue = Color3f .zero
   }

   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> SFColor { SFColor (wrappedValue: wrappedValue) }

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
      stream += "\(wrappedValue .r) \(wrappedValue .g) \(wrappedValue .b)"
   }
   
   internal final override func toXMLStream (_ stream : X3DOutputStream)
   {
      toStream (stream)
   }
   
   internal final override func toVRMLStream (_ stream : X3DOutputStream)
   {
      toStream (stream)
   }

   internal final override func fromDisplayStream (_ parser : VRMLParser) -> Bool
   {
      return parser .sfcolorValue (for: self)
   }
}
