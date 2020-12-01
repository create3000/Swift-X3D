//
//  X3DBrowserOptions.swift
//  X3D
//
//  Created by Holger Seelig on 30.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class BrowserOptions :
   X3DBaseNode
{
   // Common properties
   
   internal final override class var typeName : String { "BrowserOptions" }
   
   // Fields
   
   @SFBool   public final var SplashScreen           : Bool = true
   @SFBool   public final var Dashboard              : Bool = true
   @SFBool   public final var Rubberband             : Bool = true
   @SFBool   public final var EnableInlineViewpoints : Bool = true
   @SFBool   public final var Antialiased            : Bool = true
   @SFString public final var TextureQuality         : String = "MEDIUM"
   @SFString public final var PrimitiveQuality       : String = "MEDIUM"
   @SFString public final var QualityWhenMoving      : String = "MEDIUM"
   @SFString public final var Shading                : String = "GOURAUD"
   @SFBool   public final var MotionBlur             : Bool = false
   
   // Non-standard fields
   
   @SFFloat  public final var Gravity                : Float = 9.80665
   @SFBool   public final var StraightenHorizon      : Bool = true
   @SFBool   public final var LogarithmicDepthBuffer : Bool = false
   
   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      addField (.inputOutput, "SplashScreen",           $SplashScreen)
      addField (.inputOutput, "Dashboard",              $Dashboard)
      addField (.inputOutput, "Rubberband",             $Rubberband)
      addField (.inputOutput, "EnableInlineViewpoints", $EnableInlineViewpoints)
      addField (.inputOutput, "Antialiased",            $Antialiased)
      addField (.inputOutput, "TextureQuality",         $TextureQuality)
      addField (.inputOutput, "PrimitiveQuality",       $PrimitiveQuality)
      addField (.inputOutput, "QualityWhenMoving",      $QualityWhenMoving)
      addField (.inputOutput, "Shading",                $Shading)
      addField (.inputOutput, "MotionBlur",             $MotionBlur)
      
      addField (.inputOutput, "Gravity",                $Gravity)
      addField (.inputOutput, "StraightenHorizon",      $StraightenHorizon)
      addField (.inputOutput, "LogarithmicDepthBuffer", $LogarithmicDepthBuffer)
      
      if executionContext .getSpecificationVersion () == "2.0"
      {
         addFieldAlias (alias: "AntiAliased", name: "Antialiased")
      }
   }
}
