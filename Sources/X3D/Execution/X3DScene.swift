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
         executionContext? .scene? .$isLive .removeInterest ("set_live", X3DScene .set_live, self)
      }
      
      didSet
      {
         guard executionContext! .scene !== self else { return }
         
         executionContext! .scene! .$isLive .addInterest ("set_live", X3DScene .set_live, self)
         
         set_live ()
      }
   }
   
   // Scene properties
   
   private final var encoding             : String = "SCRIPTED"
   private final var specificationVersion : String = "3.3"
   private final var characterEncoding    : String = "utf8"
   private final var comment              : String = ""
   private final var worldURL             : URL    = URLComponents () .url!
   
   public final override func getEncoding () -> String { encoding }
   
   internal final override func setEncoding (_ value : String) { encoding = value }

   public final override func getSpecificationVersion () -> String { specificationVersion }
   
   internal final override func setSpecificationVersion (_ value : String) { specificationVersion = value }

   public final override func getCharacterEncoding () -> String { characterEncoding }

   internal final override func setCharacterEncoding (_ value : String) { characterEncoding = value }

   public final override func getComment () -> String { comment }

   internal final override func setComment (_ value : String) { comment = value }

   public final override func getWorldURL () -> URL { worldURL }

   internal final override func setWorldURL (_ value : URL) { worldURL = value }

   // Configuration handling
   
   private final var profile    : ProfileInfo     = SupportedProfiles .profiles ["Full"]!
   private final var components : [ComponentInfo] = [ ]
   
   public final override func getProfile () -> ProfileInfo { profile }
   
   internal final override func setProfile (_ value : ProfileInfo) { profile = value }
   
   public final override func getComponents () -> [ComponentInfo] { components }
   
   internal final override func setComponents (_ value : [ComponentInfo]) { components = value }
   
   internal final override func addComponent (_ component : ComponentInfo) { components .append (component) }
   
   // Unit handling
   
   private final let ANGLE  = 0
   private final let FORCE  = 1
   private final let LENGTH = 2
   private final let MASS   = 3

   private final var units : [X3DUnitInfo] = [
      X3DUnitInfo (category: .angle,  name: "radian",   conversionFactor: 1),
      X3DUnitInfo (category: .force,  name: "newton",   conversionFactor: 1),
      X3DUnitInfo (category: .length, name: "metre",    conversionFactor: 1),
      X3DUnitInfo (category: .mass,   name: "kilogram", conversionFactor: 1),
   ]
   
   public final override func getUnits () -> [X3DUnitInfo] { units }

   public final override func updateUnit (_ category : X3DUnitCategory, name : String, conversionFactor : Double)
   {
      switch category
      {
         case .angle:  units [ANGLE]  = X3DUnitInfo (category: category, name: name, conversionFactor: conversionFactor)
         case .force:  units [FORCE]  = X3DUnitInfo (category: category, name: name, conversionFactor: conversionFactor)
         case .length: units [LENGTH] = X3DUnitInfo (category: category, name: name, conversionFactor: conversionFactor)
         case .mass:   units [MASS]   = X3DUnitInfo (category: category, name: name, conversionFactor: conversionFactor)
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

         case .angle:  return value * units [ANGLE]  .conversionFactor
         case .force:  return value * units [FORCE]  .conversionFactor
         case .length: return value * units [LENGTH] .conversionFactor
         case .mass:   return value * units [MASS]   .conversionFactor

         // Derived units

         case .acceleration: return value * units [LENGTH] .conversionFactor
         case .angular_rate: return value * units [ANGLE] .conversionFactor
         case .area:         return value * pow (units [LENGTH] .conversionFactor, 2)
         case .speed:        return value * units [LENGTH] .conversionFactor
         case .volume:       return value * pow (units [LENGTH] .conversionFactor, 3)
      }
   }
   
   public final override func fromUnit (_ category : X3DUnitCategory, value : Float) -> Float
   {
      return Float (fromUnit (category, value: Double (value)))
   }

   public final override func toUnit (_ category : X3DUnitCategory, value : Double) -> Double
   {
      switch category
      {
         // Unitless
         
         case .unitless: return value
         
         // Base units

         case .angle:  return value / units [ANGLE]  .conversionFactor
         case .force:  return value / units [FORCE]  .conversionFactor
         case .length: return value / units [LENGTH] .conversionFactor
         case .mass:   return value / units [MASS]   .conversionFactor

         // Derived units

         case .acceleration: return value / units [LENGTH] .conversionFactor
         case .angular_rate: return value / units [ANGLE] .conversionFactor
         case .area:         return value / pow (units [LENGTH] .conversionFactor, 2)
         case .speed:        return value / units [LENGTH] .conversionFactor
         case .volume:       return value / pow (units [LENGTH] .conversionFactor, 3)
      }
   }
   
   public final override func toUnit (_ category : X3DUnitCategory, value : Float) -> Float
   {
      return Float (toUnit (category, value: Double (value)))
   }

   // Metadata handling
   
   public final var metadata : [String : [String]] = [:]
   
   // Exported node handling
   
   public private(set) final var exportedNodes = [String : X3DExportedNode] ()

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
   
   // Input/Output
   
   internal final override func toVRMLStream (_ stream : X3DOutputStream)
   {
      // Output header.
      
      var specificationVersion = getSpecificationVersion ()

      if specificationVersion == "2.0"
      {
         specificationVersion = "3.3"
      }

      stream += "#X3D V"
      stream += specificationVersion
      stream += " "
      stream += "utf8"
      stream += " "
      stream += browser! .getName ()
      stream += " "
      stream += "V"
      stream += browser! .getVersion ()
      stream += "\n"
      stream += "\n"
      
      // Enter stream.

      stream .push (self)
      stream .enterScope ()
      stream .setExportedNodes (exportedNodes)

      super .toVRMLStream (stream)

      // Leave stream.
      
      stream .leaveScope ()
      stream .pop (self)
   }

   // Destruction
   
   deinit
   {
      #if DEBUG
      //debugPrint (#file, #function)
      #endif
   }
}
