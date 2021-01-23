//
//  X3DPtr.swift
//  X3D
//
//  Created by Holger Seelig on 08.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public class SFNode <Type : X3DBaseNode> :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = Type
   
   // Property wrapper handling
   
   public final var projectedValue : SFNode { self }
   public var wrappedValue         : Value!
   {
      willSet
      {
         guard newValue !== wrappedValue else { return }
         
         newValue? .addParent (self)
         wrappedValue? .removeParent (self)
      }
      didSet { addEvent () }
   }
   
   // Common properties
   
   internal final override class var typeName : String { "SFNode" }
   internal final override class var type     : X3DFieldType { .SFNode }

   // Construction
   
   required public override init () { }

   public init (wrappedValue : Value!)
   {
      self .wrappedValue = wrappedValue
      
      super .init ()
      
      wrappedValue? .addParent (self)
   }
   
   public final override func copy () -> SFNode { SFNode (wrappedValue: wrappedValue) }

   // Value handling
   
   public final override func equals (to field : X3DField) -> Bool
   {
      guard let field = field as? Self else { return false }
      
      return wrappedValue === field .wrappedValue
   }

   internal final override func set (value field : X3DField)
   {
      guard let field = field as? Self else { return }
      
      wrappedValue = field .wrappedValue
   }
   
   internal final override func set (with protoInstance : X3DPrototypeInstance, value field : X3DField)
      where Type == X3DNode
   {
      guard let field = field as? Self else { return }
      
      wrappedValue = field .wrappedValue? .copy (with: protoInstance)
   }
   
   // Input/Output
   
   internal final override func toStream (_ stream : X3DOutputStream)
   {
      stream += wrappedValue? .toString () ?? "NULL"
   }
   
   internal final override func toXMLStream (_ stream : X3DOutputStream)
   {
      if let node = wrappedValue
      {
         stream += stream .toXMLStream (node)
         stream += stream .TidyBreak
      }
      else
      {
         stream += "NULL"
      }
   }
   
   internal final override func toJSONStream (_ stream : X3DOutputStream)
   {
      if let node = wrappedValue
      {
         node .toJSONStream (stream)
      }
      else
      {
         stream += "null"
      }
   }
   
   internal final override func toVRMLStream (_ stream : X3DOutputStream)
   {
      if let node = wrappedValue
      {
         stream += stream .toVRMLStream (node)
      }
      else
      {
         stream += "NULL"
      }
   }
}
