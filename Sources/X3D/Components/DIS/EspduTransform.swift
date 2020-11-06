//
//  EspduTransform.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public final class EspduTransform :
   X3DGroupingNode,
   X3DSensorNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "EspduTransform" }
   public final override class var component      : String { "DIS" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFFloat    public final var set_articulationParameterValue0            : Float = 0
   @SFFloat    public final var set_articulationParameterValue1            : Float = 0
   @SFFloat    public final var set_articulationParameterValue2            : Float = 0
   @SFFloat    public final var set_articulationParameterValue3            : Float = 0
   @SFFloat    public final var set_articulationParameterValue4            : Float = 0
   @SFFloat    public final var set_articulationParameterValue5            : Float = 0
   @SFFloat    public final var set_articulationParameterValue6            : Float = 0
   @SFFloat    public final var set_articulationParameterValue7            : Float = 0
   @SFString   public final var address                                    : String = "localhost"
   @SFInt32    public final var applicationID                              : Int32 = 1
   @SFInt32    public final var articulationParameterCount                 : Int32 = 0
   @MFInt32    public final var articulationParameterDesignatorArray       : MFInt32 .Value
   @MFInt32    public final var articulationParameterChangeIndicatorArray  : MFInt32 .Value
   @MFInt32    public final var articulationParameterIdPartAttachedToArray : MFInt32 .Value
   @MFInt32    public final var articulationParameterTypeArray             : MFInt32 .Value
   @MFFloat    public final var articulationParameterArray                 : MFFloat .Value
   @SFVec3f    public final var center                                     : Vector3f = .zero
   @SFInt32    public final var collisionType                              : Int32 = 0
   @SFInt32    public final var deadReckoning                              : Int32 = 0
   @SFVec3f    public final var detonationLocation                         : Vector3f = .zero
   @SFVec3f    public final var detonationRelativeLocation                 : Vector3f = .zero
   @SFInt32    public final var detonationResult                           : Int32 = 0
   @SFInt32    public final var entityCategory                             : Int32 = 0
   @SFInt32    public final var entityCountry                              : Int32 = 0
   @SFInt32    public final var entityDomain                               : Int32 = 0
   @SFInt32    public final var entityExtra                                : Int32 = 0
   @SFInt32    public final var entityID                                   : Int32 = 0
   @SFInt32    public final var entityKind                                 : Int32 = 0
   @SFInt32    public final var entitySpecific                             : Int32 = 0
   @SFInt32    public final var entitySubCategory                          : Int32 = 0
   @SFInt32    public final var eventApplicationID                         : Int32 = 1
   @SFInt32    public final var eventEntityID                              : Int32 = 0
   @SFInt32    public final var eventNumber                                : Int32 = 0
   @SFInt32    public final var eventSiteID                                : Int32 = 0
   @SFBool     public final var fired1                                     : Bool = false
   @SFBool     public final var fired2                                     : Bool = false
   @SFInt32    public final var fireMissionIndex                           : Int32 = 0
   @SFFloat    public final var firingRange                                : Float = 0
   @SFInt32    public final var firingRate                                 : Int32 = 0
   @SFInt32    public final var forceID                                    : Int32 = 0
   @SFInt32    public final var fuse                                       : Int32 = 0
   @SFVec3f    public final var linearVelocity                             : Vector3f = .zero
   @SFVec3f    public final var linearAcceleration                         : Vector3f = .zero
   @SFString   public final var marking                                    : String = ""
   @SFString   public final var multicastRelayHost                         : String = ""
   @SFInt32    public final var multicastRelayPort                         : Int32 = 0
   @SFInt32    public final var munitionApplicationID                      : Int32 = 1
   @SFVec3f    public final var munitionEndPoint                           : Vector3f = .zero
   @SFInt32    public final var munitionEntityID                           : Int32 = 0
   @SFInt32    public final var munitionQuantity                           : Int32 = 0
   @SFInt32    public final var munitionSiteID                             : Int32 = 0
   @SFVec3f    public final var munitionStartPoint                         : Vector3f = .zero
   @SFString   public final var networkMode                                : String = "standAlone"
   @SFInt32    public final var port                                       : Int32 = 0
   @SFTime     public final var readInterval                               : TimeInterval = 0.1
   @SFRotation public final var rotation                                   : Rotation4f = .identity
   @SFVec3f    public final var scale                                      : Vector3f = Vector3f (1, 1, 1)
   @SFRotation public final var scaleOrientation                           : Rotation4f = .identity
   @SFInt32    public final var siteID                                     : Int32 = 0
   @SFVec3f    public final var translation                                : Vector3f = .zero
   @SFInt32    public final var warhead                                    : Int32 = 0
   @SFTime     public final var writeInterval                              : TimeInterval = 1
   @SFFloat    public final var articulationParameterValue0_changed        : Float = 0
   @SFFloat    public final var articulationParameterValue1_changed        : Float = 0
   @SFFloat    public final var articulationParameterValue2_changed        : Float = 0
   @SFFloat    public final var articulationParameterValue3_changed        : Float = 0
   @SFFloat    public final var articulationParameterValue4_changed        : Float = 0
   @SFFloat    public final var articulationParameterValue5_changed        : Float = 0
   @SFFloat    public final var articulationParameterValue6_changed        : Float = 0
   @SFFloat    public final var articulationParameterValue7_changed        : Float = 0
   @SFTime     public final var collideTime                                : TimeInterval = 0
   @SFTime     public final var detonateTime                               : TimeInterval = 0
   @SFTime     public final var firedTime                                  : TimeInterval = 0
   @SFBool     public final var isCollided                                 : Bool = false
   @SFBool     public final var isDetonated                                : Bool = false
   @SFBool     public final var isNetworkReader                            : Bool = false
   @SFBool     public final var isNetworkWriter                            : Bool = false
   @SFBool     public final var isRtpHeaderHeard                           : Bool = false
   @SFBool     public final var isStandAlone                               : Bool = false
   @SFTime     public final var timestamp                                  : TimeInterval = 0
   @SFBool     public final var rtpHeaderExpected                          : Bool = false
   @SFBool     public final var enabled                                    : Bool = true
   @SFBool     public final var isActive                                   : Bool = false


   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initSensorNode ()

      types .append (.EspduTransform)

      addField (.inputOutput,    "metadata",                                   $metadata)
      addField (.inputOutput,    "enabled",                                    $enabled)
      addField (.initializeOnly, "bboxSize",                                   $bboxSize)
      addField (.initializeOnly, "bboxCenter",                                 $bboxCenter)
      addField (.inputOnly,      "addChildren",                                $addChildren)
      addField (.inputOnly,      "removeChildren",                             $removeChildren)
      addField (.inputOutput,    "children",                                   $children)
      addField (.outputOnly,     "isActive",                                   $isActive)
      addField (.inputOnly,      "set_articulationParameterValue0",            $set_articulationParameterValue0)
      addField (.inputOnly,      "set_articulationParameterValue1",            $set_articulationParameterValue1)
      addField (.inputOnly,      "set_articulationParameterValue2",            $set_articulationParameterValue2)
      addField (.inputOnly,      "set_articulationParameterValue3",            $set_articulationParameterValue3)
      addField (.inputOnly,      "set_articulationParameterValue4",            $set_articulationParameterValue4)
      addField (.inputOnly,      "set_articulationParameterValue5",            $set_articulationParameterValue5)
      addField (.inputOnly,      "set_articulationParameterValue6",            $set_articulationParameterValue6)
      addField (.inputOnly,      "set_articulationParameterValue7",            $set_articulationParameterValue7)
      addField (.inputOutput,    "address",                                    $address)
      addField (.inputOutput,    "applicationID",                              $applicationID)
      addField (.inputOutput,    "articulationParameterCount",                 $articulationParameterCount)
      addField (.inputOutput,    "articulationParameterDesignatorArray",       $articulationParameterDesignatorArray)
      addField (.inputOutput,    "articulationParameterChangeIndicatorArray",  $articulationParameterChangeIndicatorArray)
      addField (.inputOutput,    "articulationParameterIdPartAttachedToArray", $articulationParameterIdPartAttachedToArray)
      addField (.inputOutput,    "articulationParameterTypeArray",             $articulationParameterTypeArray)
      addField (.inputOutput,    "articulationParameterArray",                 $articulationParameterArray)
      addField (.inputOutput,    "center",                                     $center)
      addField (.inputOutput,    "collisionType",                              $collisionType)
      addField (.inputOutput,    "deadReckoning",                              $deadReckoning)
      addField (.inputOutput,    "detonationLocation",                         $detonationLocation)
      addField (.inputOutput,    "detonationRelativeLocation",                 $detonationRelativeLocation)
      addField (.inputOutput,    "detonationResult",                           $detonationResult)
      addField (.inputOutput,    "entityCategory",                             $entityCategory)
      addField (.inputOutput,    "entityCountry",                              $entityCountry)
      addField (.inputOutput,    "entityDomain",                               $entityDomain)
      addField (.inputOutput,    "entityExtra",                                $entityExtra)
      addField (.inputOutput,    "entityID",                                   $entityID)
      addField (.inputOutput,    "entityKind",                                 $entityKind)
      addField (.inputOutput,    "entitySpecific",                             $entitySpecific)
      addField (.inputOutput,    "entitySubCategory",                          $entitySubCategory)
      addField (.inputOutput,    "eventApplicationID",                         $eventApplicationID)
      addField (.inputOutput,    "eventEntityID",                              $eventEntityID)
      addField (.inputOutput,    "eventNumber",                                $eventNumber)
      addField (.inputOutput,    "eventSiteID",                                $eventSiteID)
      addField (.inputOutput,    "fired1",                                     $fired1)
      addField (.inputOutput,    "fired2",                                     $fired2)
      addField (.inputOutput,    "fireMissionIndex",                           $fireMissionIndex)
      addField (.inputOutput,    "firingRange",                                $firingRange)
      addField (.inputOutput,    "firingRate",                                 $firingRate)
      addField (.inputOutput,    "forceID",                                    $forceID)
      addField (.inputOutput,    "fuse",                                       $fuse)
      addField (.inputOutput,    "linearVelocity",                             $linearVelocity)
      addField (.inputOutput,    "linearAcceleration",                         $linearAcceleration)
      addField (.inputOutput,    "marking",                                    $marking)
      addField (.inputOutput,    "multicastRelayHost",                         $multicastRelayHost)
      addField (.inputOutput,    "multicastRelayPort",                         $multicastRelayPort)
      addField (.inputOutput,    "munitionApplicationID",                      $munitionApplicationID)
      addField (.inputOutput,    "munitionEndPoint",                           $munitionEndPoint)
      addField (.inputOutput,    "munitionEntityID",                           $munitionEntityID)
      addField (.inputOutput,    "munitionQuantity",                           $munitionQuantity)
      addField (.inputOutput,    "munitionSiteID",                             $munitionSiteID)
      addField (.inputOutput,    "munitionStartPoint",                         $munitionStartPoint)
      addField (.inputOutput,    "networkMode",                                $networkMode)
      addField (.inputOutput,    "port",                                       $port)
      addField (.inputOutput,    "readInterval",                               $readInterval)
      addField (.inputOutput,    "rotation",                                   $rotation)
      addField (.inputOutput,    "scale",                                      $scale)
      addField (.inputOutput,    "scaleOrientation",                           $scaleOrientation)
      addField (.inputOutput,    "siteID",                                     $siteID)
      addField (.inputOutput,    "translation",                                $translation)
      addField (.inputOutput,    "warhead",                                    $warhead)
      addField (.inputOutput,    "writeInterval",                              $writeInterval)
      addField (.outputOnly,     "articulationParameterValue0_changed",        $articulationParameterValue0_changed)
      addField (.outputOnly,     "articulationParameterValue1_changed",        $articulationParameterValue1_changed)
      addField (.outputOnly,     "articulationParameterValue2_changed",        $articulationParameterValue2_changed)
      addField (.outputOnly,     "articulationParameterValue3_changed",        $articulationParameterValue3_changed)
      addField (.outputOnly,     "articulationParameterValue4_changed",        $articulationParameterValue4_changed)
      addField (.outputOnly,     "articulationParameterValue5_changed",        $articulationParameterValue5_changed)
      addField (.outputOnly,     "articulationParameterValue6_changed",        $articulationParameterValue6_changed)
      addField (.outputOnly,     "articulationParameterValue7_changed",        $articulationParameterValue7_changed)
      addField (.outputOnly,     "collideTime",                                $collideTime)
      addField (.outputOnly,     "detonateTime",                               $detonateTime)
      addField (.outputOnly,     "firedTime",                                  $firedTime)
      addField (.outputOnly,     "isCollided",                                 $isCollided)
      addField (.outputOnly,     "isDetonated",                                $isDetonated)
      addField (.outputOnly,     "isNetworkReader",                            $isNetworkReader)
      addField (.outputOnly,     "isNetworkWriter",                            $isNetworkWriter)
      addField (.outputOnly,     "isRtpHeaderHeard",                           $isRtpHeaderHeard)
      addField (.outputOnly,     "isStandAlone",                               $isStandAlone)
      addField (.outputOnly,     "timestamp",                                  $timestamp)
      addField (.initializeOnly, "rtpHeaderExpected",                          $rtpHeaderExpected)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> EspduTransform
   {
      return EspduTransform (with: executionContext)
   }
}
