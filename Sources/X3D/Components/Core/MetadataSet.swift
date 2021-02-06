//
//  MetadataSet.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class MetadataSet :
   X3DNode,
   X3DMetadataObject,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "MetadataSet" }
   internal final override class var component      : String { "Core" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "metadata" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @SFString public final var name      : String = ""
   @SFString public final var reference : String = ""
   @MFNode   public final var value     : [X3DNode?]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initMetadataObject ()

      types .append (.MetadataSet)

      addField (.inputOutput, "metadata",  $metadata)
      addField (.inputOutput, "name",      $name)
      addField (.inputOutput, "reference", $reference)
      addField (.inputOutput, "value",     $value)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> MetadataSet
   {
      return MetadataSet (with: executionContext)
   }
   
   internal final func getSet (_ path : [String]) -> MetadataSet
   {
      guard !path .isEmpty else { return self }
      
      var path = path
      let name = path .removeFirst ()
      let set  = getData (name, of: MetadataSet .self)
      
      return set .getSet (path)
   }
   
   internal final func getBoolean (_ name : String) -> MetadataBoolean
   {
      return getData (name, of: MetadataBoolean .self)
   }
   
   internal final func getDouble (_ name : String) -> MetadataDouble
   {
      return getData (name, of: MetadataDouble .self)
   }
   
   internal final func getFloat (_ name : String) -> MetadataFloat
   {
      return getData (name, of: MetadataFloat .self)
   }
   
   internal final func getInteger (_ name : String) -> MetadataInteger
   {
      return getData (name, of: MetadataInteger .self)
   }
   
   internal final func getString (_ name : String) -> MetadataString
   {
      return getData (name, of: MetadataString .self)
   }
   
   private final func getData <Type : X3DNode> (_ name : String, of type : Type .Type) -> Type
   {
      if let data = value .first (where:
      {
         if let data = $0 as? X3DMetadataObject
         {
            return data .name == name
         }
         else
         {
            return false
         }
      }) as? Type
      {
         return data
      }
      else
      {
         let data = executionContext! .createNode (of: type) as! X3DMetadataObject
         
         data .name      = name
         data .reference = X3DBrowser .providerUrl .absoluteString
         
         value .append (data as! Type)
         
         return data as! Type
      }
   }
}
