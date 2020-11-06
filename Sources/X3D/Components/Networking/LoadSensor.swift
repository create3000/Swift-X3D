//
//  LoadSensor.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public final class LoadSensor :
   X3DNetworkSensorNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "LoadSensor" }
   public final override class var component      : String { "Networking" }
   public final override class var componentLevel : Int32 { 3 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFTime  public final var timeOut   : TimeInterval = 0
   @SFBool  public final var isLoaded  : Bool = false
   @SFFloat public final var progress  : Float = 0
   @SFTime  public final var loadTime  : TimeInterval = 0
   @MFNode  public final var watchList : MFNode <X3DNode> .Value

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.LoadSensor)

      addField (.inputOutput, "metadata",  $metadata)
      addField (.inputOutput, "enabled",   $enabled)
      addField (.inputOutput, "timeOut",   $timeOut)
      addField (.outputOnly,  "isActive",  $isActive)
      addField (.outputOnly,  "isLoaded",  $isLoaded)
      addField (.outputOnly,  "progress",  $progress)
      addField (.outputOnly,  "loadTime",  $loadTime)
      addField (.inputOutput, "watchList", $watchList)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> LoadSensor
   {
      return LoadSensor (with: executionContext)
   }
}
