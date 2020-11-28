//
//  TransmitterPdu.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public final class TransmitterPdu :
   X3DChildNode,
   X3DSensorNode,
   X3DBoundedObject,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "TransmitterPdu" }
   internal final override class var component      : String { "DIS" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }

   // Fields

   @SFString public final var address                            : String = "localhost"
   @SFVec3f  public final var antennaLocation                    : Vector3f = .zero
   @SFInt32  public final var antennaPatternLength               : Int32 = 0
   @SFInt32  public final var antennaPatternType                 : Int32 = 0
   @SFInt32  public final var applicationID                      : Int32 = 1
   @SFInt32  public final var cryptoKeyID                        : Int32 = 0
   @SFInt32  public final var cryptoSystem                       : Int32 = 0
   @SFInt32  public final var entityID                           : Int32 = 0
   @SFInt32  public final var frequency                          : Int32 = 0
   @SFInt32  public final var inputSource                        : Int32 = 0
   @SFInt32  public final var lengthOfModulationParameters       : Int32 = 0
   @SFInt32  public final var modulationTypeDetail               : Int32 = 0
   @SFInt32  public final var modulationTypeMajor                : Int32 = 0
   @SFInt32  public final var modulationTypeSpreadSpectrum       : Int32 = 0
   @SFInt32  public final var modulationTypeSystem               : Int32 = 0
   @SFString public final var multicastRelayHost                 : String = ""
   @SFInt32  public final var multicastRelayPort                 : Int32 = 0
   @SFString public final var networkMode                        : String = "standAlone"
   @SFInt32  public final var port                               : Int32 = 0
   @SFFloat  public final var power                              : Float = 0
   @SFInt32  public final var radioEntityTypeCategory            : Int32 = 0
   @SFInt32  public final var radioEntityTypeCountry             : Int32 = 0
   @SFInt32  public final var radioEntityTypeDomain              : Int32 = 0
   @SFInt32  public final var radioEntityTypeKind                : Int32 = 0
   @SFInt32  public final var radioEntityTypeNomenclature        : Int32 = 0
   @SFInt32  public final var radioEntityTypeNomenclatureVersion : Int32 = 0
   @SFInt32  public final var radioID                            : Int32 = 0
   @SFFloat  public final var readInterval                       : Float = 0.1
   @SFVec3f  public final var relativeAntennaLocation            : Vector3f = .zero
   @SFBool   public final var rtpHeaderExpected                  : Bool = false
   @SFInt32  public final var siteID                             : Int32 = 0
   @SFFloat  public final var transmitFrequencyBandwidth         : Float = 0
   @SFInt32  public final var transmitState                      : Int32 = 0
   @SFInt32  public final var whichGeometry                      : Int32 = 1
   @SFFloat  public final var writeInterval                      : Float = 1
   @SFBool   public final var isNetworkReader                    : Bool = false
   @SFBool   public final var isNetworkWriter                    : Bool = false
   @SFBool   public final var isRtpHeaderHeard                   : Bool = false
   @SFBool   public final var isStandAlone                       : Bool = false
   @SFTime   public final var timestamp                          : TimeInterval = 0
   @SFBool   public final var enabled                            : Bool = true
   @SFBool   public final var isActive                           : Bool = false
   @SFVec3f  public final var bboxSize                           : Vector3f = -.one
   @SFVec3f  public final var bboxCenter                         : Vector3f = .zero

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initSensorNode ()
      initBoundedObject (bboxSize: $bboxSize, bboxCenter: $bboxCenter)

      types .append (.TransmitterPdu)

      addField (.inputOutput,    "metadata",                           $metadata)
      addField (.initializeOnly, "bboxSize",                           $bboxSize)
      addField (.initializeOnly, "bboxCenter",                         $bboxCenter)
      addField (.inputOutput,    "enabled",                            $enabled)
      addField (.outputOnly,     "isActive",                           $isActive)
      addField (.inputOutput,    "address",                            $address)
      addField (.inputOutput,    "antennaLocation",                    $antennaLocation)
      addField (.inputOutput,    "antennaPatternLength",               $antennaPatternLength)
      addField (.inputOutput,    "antennaPatternType",                 $antennaPatternType)
      addField (.inputOutput,    "applicationID",                      $applicationID)
      addField (.inputOutput,    "cryptoKeyID",                        $cryptoKeyID)
      addField (.inputOutput,    "cryptoSystem",                       $cryptoSystem)
      addField (.inputOutput,    "entityID",                           $entityID)
      addField (.inputOutput,    "frequency",                          $frequency)
      addField (.inputOutput,    "inputSource",                        $inputSource)
      addField (.inputOutput,    "lengthOfModulationParameters",       $lengthOfModulationParameters)
      addField (.inputOutput,    "modulationTypeDetail",               $modulationTypeDetail)
      addField (.inputOutput,    "modulationTypeMajor",                $modulationTypeMajor)
      addField (.inputOutput,    "modulationTypeSpreadSpectrum",       $modulationTypeSpreadSpectrum)
      addField (.inputOutput,    "modulationTypeSystem",               $modulationTypeSystem)
      addField (.inputOutput,    "multicastRelayHost",                 $multicastRelayHost)
      addField (.inputOutput,    "multicastRelayPort",                 $multicastRelayPort)
      addField (.inputOutput,    "networkMode",                        $networkMode)
      addField (.inputOutput,    "port",                               $port)
      addField (.inputOutput,    "power",                              $power)
      addField (.inputOutput,    "radioEntityTypeCategory",            $radioEntityTypeCategory)
      addField (.inputOutput,    "radioEntityTypeCountry",             $radioEntityTypeCountry)
      addField (.inputOutput,    "radioEntityTypeDomain",              $radioEntityTypeDomain)
      addField (.inputOutput,    "radioEntityTypeKind",                $radioEntityTypeKind)
      addField (.inputOutput,    "radioEntityTypeNomenclature",        $radioEntityTypeNomenclature)
      addField (.inputOutput,    "radioEntityTypeNomenclatureVersion", $radioEntityTypeNomenclatureVersion)
      addField (.inputOutput,    "radioID",                            $radioID)
      addField (.inputOutput,    "readInterval",                       $readInterval)
      addField (.inputOutput,    "relativeAntennaLocation",            $relativeAntennaLocation)
      addField (.inputOutput,    "rtpHeaderExpected",                  $rtpHeaderExpected)
      addField (.inputOutput,    "siteID",                             $siteID)
      addField (.inputOutput,    "transmitFrequencyBandwidth",         $transmitFrequencyBandwidth)
      addField (.inputOutput,    "transmitState",                      $transmitState)
      addField (.inputOutput,    "whichGeometry",                      $whichGeometry)
      addField (.inputOutput,    "writeInterval",                      $writeInterval)
      addField (.outputOnly,     "isNetworkReader",                    $isNetworkReader)
      addField (.outputOnly,     "isNetworkWriter",                    $isNetworkWriter)
      addField (.outputOnly,     "isRtpHeaderHeard",                   $isRtpHeaderHeard)
      addField (.outputOnly,     "isStandAlone",                       $isStandAlone)
      addField (.outputOnly,     "timestamp",                          $timestamp)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> TransmitterPdu
   {
      return TransmitterPdu (with: executionContext)
   }
   
   // Bounded object
   
   public final var bbox : Box3f { .empty }
}
