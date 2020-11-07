//
//  X3DObject.swift
//  X3D
//
//  Created by Holger Seelig on 07.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DObject :
   X3DInputOutput
{
   // Object requirements
   
   internal class var typeName : String { "X3DObject" }
   private final var name : String = ""
   
   // Common properties
   
   public func getTypeName () -> String { Self .typeName }
   
   public final func getName () -> String { name }
   
   internal final func setName (_ value : String) { name = value }

   // Convert to string
   
   public final func toString () -> String
   {
      let stream = X3DOutputStream ()
      
      toStream (stream)
      
      return stream .description
   }

   public final func toXMLString () -> String
   {
      let stream = X3DOutputStream ()
      
      toXMLStream (stream)
      
      return stream .description
   }
   
   public final func toJSONString () -> String
   {
      let stream = X3DOutputStream ()
      
      toJSONStream (stream)
      
      return stream .description
   }

   public final func toVRMLString () -> String
   {
      let stream = X3DOutputStream ()
      
      toVRMLStream (stream)
      
      return stream .description
   }
   
   // Convert to stream
   
   internal func toStream (_ stream : X3DOutputStream)
   {
      stream += getTypeName ()
   }
   
   internal func toXMLStream (_ stream : X3DOutputStream)
   {
      stream += getTypeName ()
   }
   
   internal func toJSONStream (_ stream : X3DOutputStream)
   {
      stream += getTypeName ()
   }
   
   internal func toVRMLStream (_ stream : X3DOutputStream)
   {
      stream += getTypeName ()
   }
}

extension X3DObject :
   Hashable
{
   public static func == (lhs : X3DObject, rhs : X3DObject) -> Bool
   {
      return lhs === rhs
   }
   
   public final func hash (into hasher: inout Hasher)
   {
      hasher .combine (ObjectIdentifier (self) .hashValue)
   }
}

extension X3DObject :
   CustomDebugStringConvertible
{
   public var debugDescription : String
   {
      return "\(getTypeName ()) { }"
   }
}
