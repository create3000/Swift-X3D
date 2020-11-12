//
//  SignalPdu.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public final class SignalPdu :
   X3DChildNode,
   X3DSensorNode,
   X3DBoundedObject,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "SignalPdu" }
   internal final override class var component      : String { "DIS" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }

   // Fields

   @SFString public final var address            : String = "localhost"
   @SFInt32  public final var applicationID      : Int32 = 1
   @MFInt32  public final var data               : MFInt32 .Value
   @SFInt32  public final var dataLength         : Int32 = 0
   @SFInt32  public final var encodingScheme     : Int32 = 0
   @SFInt32  public final var entityID           : Int32 = 0
   @SFString public final var multicastRelayHost : String = ""
   @SFInt32  public final var multicastRelayPort : Int32 = 0
   @SFString public final var networkMode        : String = "standAlone"
   @SFInt32  public final var port               : Int32 = 0
   @SFInt32  public final var radioID            : Int32 = 0
   @SFFloat  public final var readInterval       : Float = 0.1
   @SFBool   public final var rtpHeaderExpected  : Bool = false
   @SFInt32  public final var sampleRate         : Int32 = 0
   @SFInt32  public final var samples            : Int32 = 0
   @SFInt32  public final var siteID             : Int32 = 0
   @SFInt32  public final var tdlType            : Int32 = 0
   @SFInt32  public final var whichGeometry      : Int32 = 1
   @SFFloat  public final var writeInterval      : Float = 1
   @SFBool   public final var isNetworkReader    : Bool = false
   @SFBool   public final var isNetworkWriter    : Bool = false
   @SFBool   public final var isRtpHeaderHeard   : Bool = false
   @SFBool   public final var isStandAlone       : Bool = false
   @SFTime   public final var timestamp          : TimeInterval = 0
   @SFBool   public final var enabled            : Bool = true
   @SFBool   public final var isActive           : Bool = false
   @SFVec3f  public final var bboxSize           : Vector3f = -.one
   @SFVec3f  public final var bboxCenter         : Vector3f = .zero

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initSensorNode ()
      initBoundedObject (bboxSize: $bboxSize, bboxCenter: $bboxCenter)

      types .append (.SignalPdu)

      addField (.inputOutput,    "metadata",           $metadata)
      addField (.initializeOnly, "bboxSize",           $bboxSize)
      addField (.initializeOnly, "bboxCenter",         $bboxCenter)
      addField (.inputOutput,    "enabled",            $enabled)
      addField (.outputOnly,     "isActive",           $isActive)
      addField (.inputOutput,    "address",            $address)
      addField (.inputOutput,    "applicationID",      $applicationID)
      addField (.inputOutput,    "data",               $data)
      addField (.inputOutput,    "dataLength",         $dataLength)
      addField (.inputOutput,    "encodingScheme",     $encodingScheme)
      addField (.inputOutput,    "entityID",           $entityID)
      addField (.inputOutput,    "multicastRelayHost", $multicastRelayHost)
      addField (.inputOutput,    "multicastRelayPort", $multicastRelayPort)
      addField (.inputOutput,    "networkMode",        $networkMode)
      addField (.inputOutput,    "port",               $port)
      addField (.inputOutput,    "radioID",            $radioID)
      addField (.inputOutput,    "readInterval",       $readInterval)
      addField (.inputOutput,    "rtpHeaderExpected",  $rtpHeaderExpected)
      addField (.inputOutput,    "sampleRate",         $sampleRate)
      addField (.inputOutput,    "samples",            $samples)
      addField (.inputOutput,    "siteID",             $siteID)
      addField (.inputOutput,    "tdlType",            $tdlType)
      addField (.inputOutput,    "whichGeometry",      $whichGeometry)
      addField (.inputOutput,    "writeInterval",      $writeInterval)
      addField (.outputOnly,     "isNetworkReader",    $isNetworkReader)
      addField (.outputOnly,     "isNetworkWriter",    $isNetworkWriter)
      addField (.outputOnly,     "isRtpHeaderHeard",   $isRtpHeaderHeard)
      addField (.outputOnly,     "isStandAlone",       $isStandAlone)
      addField (.outputOnly,     "timestamp",          $timestamp)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> SignalPdu
   {
      return SignalPdu (with: executionContext)
   }
   
   // Bounded object
   
   public final var bbox : Box3f { .empty }
}
