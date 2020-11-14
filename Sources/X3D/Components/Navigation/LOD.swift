//
//  LOD.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public final class LOD :
   X3DGroupingNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "LOD" }
   internal final override class var component      : String { "Navigation" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "children" }

   // Fields

   @SFBool  public final var forceTransitions : Bool = false
   @SFVec3f public final var center           : Vector3f = .zero
   @MFFloat public final var range            : [Float]
   @SFInt32 public final var level_changed    : Int32 = -1
   
   // Properties
   
   private final let FRAMES         : Int = 180   // Number of frames after wich a level change takes in affect.
   private final let FRAME_RATE_MIN : Double = 20 // Lowest level of detail.
   private final let FRAME_RATE_MAX : Double = 55 // Highest level of detail.

   private final var frameRate        : Double = 0
   private final var changeLevel      : Bool = true
   private final var keepCurrentLevel : Bool = false

   @SFNode private final var childNode : X3DChildNode?

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.LOD)

      addField (.inputOutput,    "metadata",         $metadata)
      addField (.initializeOnly, "forceTransitions", $forceTransitions)
      addField (.initializeOnly, "center",           $center)
      addField (.initializeOnly, "range",            $range)
      addField (.outputOnly,     "level_changed",    $level_changed)
      addField (.initializeOnly, "bboxSize",         $bboxSize)
      addField (.initializeOnly, "bboxCenter",       $bboxCenter)
      addField (.inputOnly,      "addChildren",      $addChildren)
      addField (.inputOnly,      "removeChildren",   $removeChildren)
      addField (.inputOutput,    "children",         $children)
      
      if executionContext .getSpecificationVersion () == "2.0"
      {
         addFieldAlias (alias: "level", name: "children")
      }
      
      addChildObjects ($childNode)

      $center .unit = .length
      $range  .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> LOD
   {
      return LOD (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
   }
   
   // Property access
   
   public final override var bbox : Box3f
   {
      if bboxSize == -.one
      {
         if let boundedObject = childNode as? X3DBoundedObject
         {
            return boundedObject .bbox
         }

         return .empty
      }

      return Box3f (size: bboxSize, center: bboxCenter)
   }

   // Event handlers
   
   internal final override func set_cameraObjects ()
   {
      setCameraObject (childNode? .isCameraObject ?? false)
   }

   internal final override func set_pickableObjects ()
   {
      setPickableObject (childNode? .isPickableObject ?? false || !transformSensorNodes .isEmpty)
   }

   private final func set_childNode (_ level : Int)
   {
      if children .indices .contains (level)
      {
         childNode = children [level]? .innerNode as? X3DChildNode
      }
      else
      {
         childNode = nil
      }
            
      set_cameraObjects ()
      set_pickableObjects ()
   }
   
   private final func getLevel (_ browser : X3DBrowser, _ modelViewMatrix : Matrix4f) -> Int
   {
      if range .isEmpty
      {
         frameRate = (Double (FRAMES - 1) * frameRate + browser .currentFrameRate) / Double (FRAMES)

         let size = children .count

         if size < 2
         {
            return 0
         }

         if size == 2
         {
            return frameRate > FRAME_RATE_MAX ? 1 : 0
         }

         let fraction = 1 - clamp ((frameRate - FRAME_RATE_MIN) / (FRAME_RATE_MAX - FRAME_RATE_MIN), min: 0, max: 1)

         return min (Int (fraction * Double (size)), size - 1)
      }

      let distance = getDistance (modelViewMatrix)
      let index    = range .upperBound (value: distance, comp: <)

      return index
   }
   
   private final func getDistance (_ modelViewMatrix : Matrix4f) -> Float
   {
      return length (modelViewMatrix .translate (center) .origin)
   }
   
   // Rendering
   
   internal final override func traverse (_ type: X3DTraverseType, _ renderer: X3DRenderer)
   {
      switch type
      {
         case .Pointer:
            break
         case .Picking:
            break
         case .Render: do
         {
            if !keepCurrentLevel
            {
               var level = getLevel (renderer .browser, renderer .modelViewMatrix .top)
         
               if forceTransitions
               {
                  if level > level_changed
                  {
                     level = Int (level_changed + 1)
                  }
                  else if level < level_changed
                  {
                     level = Int (level_changed - 1)
                  }
               }
         
               if level != level_changed
               {
                  level_changed = Int32 (level)
      
                  set_childNode (level)
               }
            }

            childNode? .traverse (type, renderer)
         }
         default: do
         {
            childNode? .traverse (type, renderer)
         }
      }
   }
}
