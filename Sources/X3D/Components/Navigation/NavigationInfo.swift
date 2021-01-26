//
//  NavigationInfo.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public final class NavigationInfo :
   X3DBindableNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "NavigationInfo" }
   internal final override class var component      : String { "Navigation" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @MFString public final var type               : [String] = ["EXAMINE", "ANY"]
   @MFFloat  public final var avatarSize         : [Float] = [0.25, 1.6, 0.75]
   @SFFloat  public final var speed              : Float = 1
   @SFBool   public final var headlight          : Bool = true
   @SFFloat  public final var visibilityLimit    : Float = 0
   @MFString public final var transitionType     : [String] = ["LINEAR"]
   @SFTime   public final var transitionTime     : TimeInterval = 1
   @SFBool   public final var transitionComplete : Bool = false
   
   // Properties
   
   @MFEnum public final var availableViewers   : [X3DViewerType]
   @SFEnum public final var viewer             : X3DViewerType = .EXAMINE
   @SFBool public final var transitionStart    : Bool = false
   @SFBool public final var transitionActive   : Bool = false

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.NavigationInfo)

      addField (.inputOutput, "metadata",           $metadata)
      addField (.inputOnly,   "set_bind",           $set_bind)
      addField (.inputOutput, "type",               $type)
      addField (.inputOutput, "avatarSize",         $avatarSize)
      addField (.inputOutput, "speed",              $speed)
      addField (.inputOutput, "headlight",          $headlight)
      addField (.inputOutput, "visibilityLimit",    $visibilityLimit)
      addField (.inputOutput, "transitionType",     $transitionType)
      addField (.inputOutput, "transitionTime",     $transitionTime)
      addField (.outputOnly,  "transitionComplete", $transitionComplete)
      addField (.outputOnly,  "isBound",            $isBound)
      addField (.outputOnly,  "bindTime",           $bindTime)
      
      addChildObjects ($availableViewers,
                       $viewer,
                       $transitionStart,
                       $transitionActive)

      $avatarSize      .unit = .length
      $speed           .unit = .speed
      $visibilityLimit .unit = .speed
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> NavigationInfo
   {
      return NavigationInfo (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      $type               .addInterest ("set_type",               NavigationInfo .set_type,               self)
      $transitionStart    .addInterest ("set_transitionStart",    NavigationInfo .set_transitionStart,    self)
      $transitionComplete .addInterest ("set_transitionComplete", NavigationInfo .set_transitionComplete, self)
      
      set_type ()
   }
   
   // Property access
   
   internal final var collisionRadius : Float
   {
      avatarSize .count > 0 && avatarSize [0] > 0 ? avatarSize [0] : 0.25
   }
   
   internal final var avatarHeight : Float
   {
      avatarSize .count > 1 ? avatarSize [1] : 1.6
   }
   
   internal final var stepHeight : Float
   {
      avatarSize .count > 2 ? avatarSize [2] : 0.75
   }
   
   internal final var nearValue : Float
   {
      let collisionRadius = self .collisionRadius
      
      return collisionRadius == 0 ? 1e-5 : collisionRadius / 2
   }
   
   internal final func farValue (_ viewpoint : X3DViewpointNode) -> Float
   {
      visibilityLimit > 0 ? visibilityLimit : viewpoint .maxFarValue
   }
   
   // Event handlers

   private final func set_type ()
   {
      // Determine active viewer.

      viewer = .EXAMINE

      for string in type
      {
         switch string
         {
            case "EXAMINE":
               viewer = .EXAMINE
            case "WALK":
               viewer = .WALK
            case "FLY":
               viewer = .FLY
            case "PLANE", "PLANE_create3000.de":
               viewer = .PLANE
            case "LOOKAT":
               viewer = .LOOKAT
            case "NONE":
               viewer = .NONE
            default:
               continue
         }

         // Leave for loop.
         break
      }

      // Determine available viewers.

      var examineViewer = false
      var walkViewer    = false
      var flyViewer     = false
      var planeViewer   = false
      var noneViewer    = false
      var lookAt        = false

      if type .isEmpty
      {
         examineViewer = true
         walkViewer    = true
         flyViewer     = true
         planeViewer   = true
         noneViewer    = true
         lookAt        = true
      }
      else
      {
         for string in type
         {
            switch string
            {
               case "EXAMINE":
                  examineViewer = true
                  continue
               case "WALK":
                  walkViewer = true
                  continue
              case "FLY":
                  flyViewer = true
                  continue
               case "LOOKAT":
                  lookAt = true
                  continue
               case "PLANE":
                  planeViewer = true
                  continue
               case "NONE":
                  noneViewer = true
                  continue
               case "ANY":
                  examineViewer = true
                  walkViewer    = true
                  flyViewer     = true
                  planeViewer   = true
                  noneViewer    = true
                  lookAt        = true
              default:
                  // Some string defaults to EXAMINE.
                  examineViewer = true
                  continue
            }
            
            // Leave for loop.
            break
         }
      }

      availableViewers .removeAll (keepingCapacity: true)
      
      if examineViewer { availableViewers .append (.EXAMINE) }
      if walkViewer    { availableViewers .append (.WALK) }
      if flyViewer     { availableViewers .append (.FLY) }
      if planeViewer   { availableViewers .append (.PLANE) }
      if lookAt        { availableViewers .append (.LOOKAT) }
      if noneViewer    { availableViewers .append (.NONE) }
   }
   
   private final func set_transitionStart ()
   {
      if !transitionActive
      {
         transitionActive = true
      }
   }

   private final func set_transitionComplete ()
   {
      if transitionActive
      {
         transitionActive = false
      }
   }
   
   // Traverse camera

   internal final override func traverse (_ type : TraverseType, _ renderer : Renderer)
   {
      renderer .layerNode! .navigationInfoList .append (node: self)
   }
   
   internal final func push (_ renderer : Renderer)
   {
      guard headlight else { return }
      
      renderer .globalLights .append (renderer .browser .headlightContainer)
   }
   
   internal final func pop (_ renderer : Renderer) { }
}
