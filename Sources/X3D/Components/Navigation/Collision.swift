//
//  Collision.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public final class Collision :
   X3DGroupingNode,
   X3DSensorNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "Collision" }
   internal final override class var component      : String { "Navigation" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @SFBool public final var enabled     : Bool = true
   @SFTime public final var collideTime : TimeInterval = 0
   @SFBool public final var isActive    : Bool = false
   @SFNode public final var proxy       : X3DNode?
   
   // Properties
   
   private final var proxyNode : X3DChildNode?

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initSensorNode ()

      types .append (.Collision)

      addField (.inputOutput,    "metadata",       $metadata)
      addField (.inputOutput,    "enabled",        $enabled)
      addField (.outputOnly,     "isActive",       $isActive)
      addField (.outputOnly,     "collideTime",    $collideTime)
      addField (.initializeOnly, "bboxSize",       $bboxSize)
      addField (.initializeOnly, "bboxCenter",     $bboxCenter)
      addField (.initializeOnly, "proxy",          $proxy)
      addField (.inputOnly,      "addChildren",    $addChildren)
      addField (.inputOnly,      "removeChildren", $removeChildren)
      addField (.inputOutput,    "children",       $children)
      
      if executionContext .getSpecificationVersion () == "2.0"
      {
         addFieldAlias (alias: "collide", name: "enabled")
      }
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Collision
   {
      return Collision (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      scene! .$isLive .addInterest ("set_live", { $0 .set_live () }, self)
      
      $enabled .addInterest ("set_live",  { $0 .set_live () },  self)
      $proxy   .addInterest ("set_proxy", { $0 .set_proxy () }, self)
      
      DispatchQueue .main .async { self .set_live () }
      set_proxy ()
   }
   
   // Event handlers
   
   private final func set_live ()
   {
      guard let browser = browser, let scene = scene else { return }
      
      if scene .isLive && enabled
      {
         browser .addCollision (object: self)
      }
      else
      {
         browser .removeCollision (object: self)
      }
   }
   
   private final func set_proxy ()
   {
      proxyNode = proxy? .innerNode as? X3DChildNode
   }
   
   internal final func set_active (_ value : Bool)
   {
      guard value != isActive else { return }
      
      isActive = value
      
      if isActive
      {
         collideTime = browser! .currentTime
      }
   }
   
   // Rendering
   
   internal final override func traverse (_ type: TraverseType, _ renderer: Renderer)
   {
      switch type
      {
         case .Collision: do
         {
            guard enabled else { break }
            
            renderer .collisions .append (self)
            
            defer { renderer .collisions .removeLast () }
            
            if let proxyNode = proxyNode
            {
               proxyNode .traverse (type, renderer)
            }
            else
            {
               super .traverse (type, renderer)
            }
         }
         default: do
         {
            super .traverse (type, renderer)
         }
      }
   }
}
