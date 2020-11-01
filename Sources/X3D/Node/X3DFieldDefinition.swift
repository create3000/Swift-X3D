//
//  X3DFieldDefinition.swift
//  X3D
//
//  Created by Holger Seelig on 11.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DFieldDefinition :
   X3DChildObject
{
   // Common properties
   
   public class var type : X3DFieldType { .SFBool }
   public final var type : X3DFieldType { Swift .type (of: self) .type }

   // Access type handling
   
   public internal(set) final var accessType : X3DAccessType = .initializeOnly

   public final var isInitializable : Bool { accessType .rawValue & X3DAccessType .initializeOnly .rawValue != 0 }
   public final var isInput : Bool { accessType .rawValue & X3DAccessType .inputOnly .rawValue != 0 }
   public final var isOutput : Bool { accessType .rawValue & X3DAccessType .outputOnly .rawValue != 0 }

   // Unit handling
   
   public internal(set) final var unit : X3DUnitCategory = .unitless
}
