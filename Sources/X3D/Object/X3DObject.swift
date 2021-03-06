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
   
   internal func setName (_ value : String) { name = value }
 
   // Convert to string
   
   public final func toString () -> String
   {
      let stream = X3DOutputStream ()
      
      stream .units = false
      
      toStream (stream)
      
      return stream .string
   }

   public final func toXMLString (with scene : X3DScene, stream : X3DOutputStream = X3DOutputStream ()) -> String
   {
      stream .units = true

      stream .push (scene)

      toXMLStream (stream)
      
      return stream .string
   }
   
   public final func toJSONString (with scene : X3DScene, stream : X3DOutputStream = X3DOutputStream ()) -> String
   {
      stream .units = true

      stream .push (scene)

      toJSONStream (stream)
      
      return stream .string
   }

   public final func toVRMLString (with scene : X3DScene, stream : X3DOutputStream = X3DOutputStream ()) -> String
   {
      stream .units = true

      stream .push (scene)

      toVRMLStream (stream)
      
      return stream .string
   }
   
   // Convert to stream
   
   internal func toStream (_ stream : X3DOutputStream) { }
   
   internal func toXMLStream (_ stream : X3DOutputStream) { }
   
   internal func toJSONStream (_ stream : X3DOutputStream) { }
   
   internal func toVRMLStream (_ stream : X3DOutputStream) { }
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
