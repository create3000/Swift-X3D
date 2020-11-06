//
//  HAnimHumanoid.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class HAnimHumanoid :
   X3DChildNode,
   X3DBoundedObject,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "HAnimHumanoid" }
   public final override class var component      : String { "H-Anim" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFString   public final var name             : String = ""
   @SFString   public final var version          : String = ""
   @MFString   public final var info             : MFString .Value
   @SFVec3f    public final var translation      : Vector3f = .zero
   @SFRotation public final var rotation         : Rotation4f = .identity
   @SFVec3f    public final var scale            : Vector3f = Vector3f (1, 1, 1)
   @SFRotation public final var scaleOrientation : Rotation4f = .identity
   @SFVec3f    public final var center           : Vector3f = .zero
   @SFVec3f    public final var bboxSize         : Vector3f = Vector3f (-1, -1, -1)
   @SFVec3f    public final var bboxCenter       : Vector3f = .zero
   @MFNode     public final var viewpoints       : MFNode <X3DNode> .Value
   @MFNode     public final var sites            : MFNode <X3DNode> .Value
   @MFNode     public final var joints           : MFNode <X3DNode> .Value
   @MFNode     public final var segments         : MFNode <X3DNode> .Value
   @MFNode     public final var motions          : MFNode <X3DNode> .Value
   @MFNode     public final var skeleton         : MFNode <X3DNode> .Value
   @SFNode     public final var skinNormal       : X3DNode?
   @SFNode     public final var skinCoord        : X3DNode?
   @MFNode     public final var skin             : MFNode <X3DNode> .Value

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initBoundedObject (bboxSize: $bboxSize, bboxCenter: $bboxCenter)

      types .append (.HAnimHumanoid)

      addField (.inputOutput,    "metadata",         $metadata)
      addField (.inputOutput,    "name",             $name)
      addField (.inputOutput,    "version",          $version)
      addField (.inputOutput,    "info",             $info)
      addField (.inputOutput,    "translation",      $translation)
      addField (.inputOutput,    "rotation",         $rotation)
      addField (.inputOutput,    "scale",            $scale)
      addField (.inputOutput,    "scaleOrientation", $scaleOrientation)
      addField (.inputOutput,    "center",           $center)
      addField (.initializeOnly, "bboxSize",         $bboxSize)
      addField (.initializeOnly, "bboxCenter",       $bboxCenter)
      addField (.inputOutput,    "viewpoints",       $viewpoints)
      addField (.inputOutput,    "sites",            $sites)
      addField (.inputOutput,    "joints",           $joints)
      addField (.inputOutput,    "segments",         $segments)
      addField (.inputOutput,    "motions",          $motions)
      addField (.inputOutput,    "skeleton",         $skeleton)
      addField (.inputOutput,    "skinNormal",       $skinNormal)
      addField (.inputOutput,    "skinCoord",        $skinCoord)
      addField (.inputOutput,    "skin",             $skin)

      $translation .unit = .length
      $center      .unit = .length
      $bboxSize    .unit = .length
      $bboxCenter  .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> HAnimHumanoid
   {
      return HAnimHumanoid (with: executionContext)
   }
   
   // Bounded object
   
   public final var bbox : Box3f { Box3f () }
}
