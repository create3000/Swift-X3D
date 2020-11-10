//
//  X3DRenderingProperties.swift
//  X3D
//
//  Created by Holger Seelig on 08.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class X3DRenderingProperties :
   X3DBaseNode
{
   // Fields
   
   @SFString public final var Shading                : String = ""
   @SFInt32  public final var MaxTextureSize         : Int32 = 0
   @SFInt32  public final var TextureChannels        : Int32 = 0
   @SFInt32  public final var MaxLights              : Int32 = 0
   @SFBool   public final var Antialiased            : Bool = false
   @SFInt32  public final var ColorDepth             : Int32 = 0
   @SFDouble public final var TextureMemory          : Double = 0
   
   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      addField (.inputOutput, "Shading",         $Shading)
      addField (.inputOutput, "MaxTextureSize",  $MaxTextureSize)
      addField (.inputOutput, "TextureChannels", $TextureChannels)
      addField (.inputOutput, "MaxLights",       $MaxLights)
      addField (.inputOutput, "Antialiased",     $Antialiased)
      addField (.inputOutput, "ColorDepth",      $ColorDepth)
      addField (.inputOutput, "TextureMemory",   $TextureMemory)
      
      if executionContext .getSpecificationVersion () == "2.0"
      {
         addFieldAlias (alias: "AntiAliased", name: "Antialiased")
      }
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      TextureChannels = Int32 (Mirror (reflecting: x3d_VertexIn () .texCoords) .children .count)
   }
}
