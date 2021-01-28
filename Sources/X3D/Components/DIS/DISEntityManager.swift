//
//  DISEntityManager.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class DISEntityManager :
   X3DChildNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "DISEntityManager" }
   internal final override class var component      : String { "DIS" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: false) }

   // Fields

   @SFString public final var address         : String = "localhost"
   @SFInt32  public final var applicationID   : Int32 = 1
   @MFNode   public final var mapping         : [X3DNode?]
   @SFInt32  public final var port            : Int32 = 0
   @SFInt32  public final var siteID          : Int32 = 0
   @MFNode   public final var addedEntities   : [X3DNode?]
   @MFNode   public final var removedEntities : [X3DNode?]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.DISEntityManager)

      addField (.inputOutput, "metadata",        $metadata)
      addField (.inputOutput, "address",         $address)
      addField (.inputOutput, "applicationID",   $applicationID)
      addField (.inputOutput, "mapping",         $mapping)
      addField (.inputOutput, "port",            $port)
      addField (.inputOutput, "siteID",          $siteID)
      addField (.outputOnly,  "addedEntities",   $addedEntities)
      addField (.outputOnly,  "removedEntities", $removedEntities)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> DISEntityManager
   {
      return DISEntityManager (with: executionContext)
   }
}
