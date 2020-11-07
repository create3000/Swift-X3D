//
//  X3DScene.swift
//  X3D
//
//  Created by Holger Seelig on 08.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public final class X3DScene :
   X3DExecutionContext
{
   // Common properties
   
   internal final override class var typeName : String { "X3DScene" }
   
   // Properties
   
   public final override var scene : X3DScene? { self }

   // Construction
   
   internal init (with browser : X3DBrowser)
   {
      super .init (browser, nil)
      
      executionContext = self
      
      types .append (.X3DScene)
      
      addChildObjects ($isLive)

      $rootNodes .setAccessType (.inputOutput)
   }
   
   internal override func initialize ()
   {
      super .initialize ()
   }
   
   public internal(set) final override weak var executionContext : X3DExecutionContext?
   {
      willSet
      {
         executionContext? .scene? .$isLive .removeInterest (X3DScene .set_live, self)
      }
      
      didSet
      {
         guard executionContext! .scene !== self else { return }
         
         executionContext! .scene! .$isLive .addInterest (X3DScene .set_live, self)
         
         set_live ()
      }
   }
   
   // Scene properties
   
   private final var _encoding             : String = "SCRIPTED"
   private final var _specificationVersion : String = "3.3"
   private final var _characterEncoding    : String = "utf8"
   private final var _comment              : String = ""
   private final var _worldURL             : URL    = URLComponents () .url!

   public internal(set) override var encoding             : String { get { _encoding }             set { _encoding             = newValue } }
   public internal(set) override var specificationVersion : String { get { _specificationVersion } set { _specificationVersion = newValue } }
   public internal(set) override var characterEncoding    : String { get { _characterEncoding }    set { _characterEncoding    = newValue } }
   public internal(set) override var comment              : String { get { _comment }              set { _comment              = newValue } }
   public internal(set) override var worldURL             : URL    { get { _worldURL }             set { _worldURL             = newValue } }

   // Configuration handling
   
   private final var _profile    : X3DProfileInfo        = X3DSupportedProfiles .profiles ["Full"]!
   private final var _components : X3DComponentInfoArray = [ ]
   
   public internal(set) override var profile    : X3DProfileInfo        { get { _profile }     set { _profile    = newValue } }
   public internal(set) override var components : X3DComponentInfoArray { get { _components }  set { _components = newValue } }
   
   // Unit handling
   
   private final let ANGLE  = 0
   private final let FORCE  = 1
   private final let LENGTH = 2
   private final let MASS   = 3

   private final var _units : X3DUnitInfoArray = [
      X3DUnitInfo (category: .angle,  name: "radian",   conversionFactor: 1),
      X3DUnitInfo (category: .force,  name: "newton",   conversionFactor: 1),
      X3DUnitInfo (category: .length, name: "metre",    conversionFactor: 1),
      X3DUnitInfo (category: .mass,   name: "kilogram", conversionFactor: 1),
   ]
   
   public internal(set) override var units : X3DUnitInfoArray { get { _units } set { _units = newValue } }

   public final override func updateUnit (_ category : X3DUnitCategory, name : String, conversionFactor : Double)
   {
      switch category
      {
         case .angle:  _units [ANGLE]  = X3DUnitInfo (category: category,  name: name, conversionFactor: conversionFactor)
         case .force:  _units [FORCE]  = X3DUnitInfo (category: category,  name: name, conversionFactor: conversionFactor)
         case .length: _units [LENGTH] = X3DUnitInfo (category: category,  name: name, conversionFactor: conversionFactor)
         case .mass:   _units [MASS]   = X3DUnitInfo (category: category,  name: name, conversionFactor: conversionFactor)
         default: break
      }
   }

   public final override func fromUnit (_ category : X3DUnitCategory, value : Double) -> Double
   {
      switch category
      {
         // Unitless
         
         case .unitless: return value
         
         // Base units

         case .angle:  return value * _units [ANGLE]  .conversionFactor
         case .force:  return value * _units [FORCE]  .conversionFactor
         case .length: return value * _units [LENGTH] .conversionFactor
         case .mass:   return value * _units [MASS]   .conversionFactor

         // Derived units

         case .acceleration: return value * _units [LENGTH] .conversionFactor
         case .angular_rate: return value * _units [ANGLE] .conversionFactor
         case .area:         return value * pow (_units [LENGTH] .conversionFactor, 2)
         case .speed:        return value * _units [LENGTH] .conversionFactor
         case .volume:       return value * pow (_units [LENGTH] .conversionFactor, 3)
      }
   }
   
   public final override func toUnit (_ category : X3DUnitCategory, value : Double) -> Double
   {
      switch category
      {
         // Unitless
         
         case .unitless: return value
         
         // Base units

         case .angle:  return value / _units [ANGLE]  .conversionFactor
         case .force:  return value / _units [FORCE]  .conversionFactor
         case .length: return value / _units [LENGTH] .conversionFactor
         case .mass:   return value / _units [MASS]   .conversionFactor

         // Derived units

         case .acceleration: return value / _units [LENGTH] .conversionFactor
         case .angular_rate: return value / _units [ANGLE] .conversionFactor
         case .area:         return value / pow (_units [LENGTH] .conversionFactor, 2)
         case .speed:        return value / _units [LENGTH] .conversionFactor
         case .volume:       return value / pow (_units [LENGTH] .conversionFactor, 3)
      }
   }
   
   // Metadata handling

   private final var _metadata : [String : [String]] = [:]
   
   public internal(set) override var metadata : [String : [String]] { get { _metadata } set { _metadata = newValue } }
   
   // Exported node handling
   
   public final func getExportedNode (exportedName : String) throws -> X3DNode
   {
      throw X3DError .NOT_SUPPORTED ("getExportedNode")
   }

   public final func addExportedNode (exportedName : String, node : X3DNode) throws
   {
   }
   
   public final func updateExportedNode (exportedName : String, node : X3DNode) throws
   {
   }
   
   public final func removeExportedNode (exportedName : String)
   {
   }

   // Update control
   
   @SFBool internal private(set) var isLive : Bool = false
   private final var live : Bool = false
   
   internal final func beginUpdate ()
   {
      live = true
      
      set_live ()
   }
   
   internal final func endUpdate ()
   {
      live = false
      
      set_live ()
   }
   
   private func set_live ()
   {
      let isLive = live || (executionContext !== self && executionContext! .scene! .isLive)
      
      if isLive != self .isLive
      {
         self .isLive = isLive
      }
   }

   // Destruction
   
   deinit
   {
      debugPrint (#file, #function)
   }
}
