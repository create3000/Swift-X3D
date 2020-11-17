//
//  Switch.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public final class Switch :
   X3DGroupingNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "Switch" }
   internal final override class var component      : String { "Grouping" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "children" }
   
   // Fields
   
   @SFInt32 public final var whichChoice : Int32 = 0
   
   // Properties
   
   @SFNode private final var childNode : X3DChildNode?

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Switch)

      addField (.inputOutput,    "metadata",       $metadata)
      addField (.inputOutput,    "whichChoice",    $whichChoice)
      addField (.initializeOnly, "bboxSize",       $bboxSize)
      addField (.initializeOnly, "bboxCenter",     $bboxCenter)
      addField (.inputOnly,      "addChildren",    $addChildren)
      addField (.inputOnly,      "removeChildren", $removeChildren)
      addField (.inputOutput,    "children",       $children)
      
      if executionContext .getSpecificationVersion () == "2.0"
      {
         addFieldAlias (alias: "choice", name: "children")
      }
      
      addChildObjects ($childNode)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Switch
   {
      return Switch (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      $whichChoice .addInterest ("set_whichChoice", Switch .set_whichChoice, self)
      $children    .addInterest ("set_whichChoice", Switch .set_whichChoice, self)
      
      set_whichChoice ()
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
   
   private final func set_whichChoice ()
   {
      if children .indices .contains (Int (whichChoice))
      {
         childNode = children [Int (whichChoice)]? .innerNode as? X3DChildNode
      }
      else
      {
         childNode = nil
      }

      set_cameraObjects ()
      set_pickableObjects ()
   }
   
   internal final override func set_cameraObjects ()
   {
      setCameraObject (childNode? .isCameraObject ?? false)
   }

   internal final override func set_pickableObjects ()
   {
      setPickableObject ((childNode? .isPickableObject ?? false) || !transformSensorNodes .isEmpty)
   }
   
   // Rendering
   
   internal final override func traverse (_ type : TraverseType, _ renderer : Renderer)
   {
      guard let childNode = childNode else { return }
      
      switch type
      {
         default:
            childNode .traverse (type, renderer)
      }
   }
}
