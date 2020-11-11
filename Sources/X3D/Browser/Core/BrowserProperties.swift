//
//  X3DBrowserProperties.swift
//  X3D
//
//  Created by Holger Seelig on 08.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class BrowserProperties :
   X3DBaseNode
{
   // Fields
   
   @SFBool public final var ABSTRACT_NODES        : Bool = true
   @SFBool public final var CONCRETE_NODES        : Bool = true
   @SFBool public final var EXTERNAL_INTERACTIONS : Bool = false
   @SFBool public final var PROTOTYPE_CREATE      : Bool = true
   @SFBool public final var DOM_IMPORT            : Bool = false
   @SFBool public final var XML_ENCODING          : Bool = true
   @SFBool public final var CLASSIC_VRML_ENCODING : Bool = true
   @SFBool public final var BINARY_ENCODING       : Bool = false

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      addField (.inputOutput, "ABSTRACT_NODES",        $ABSTRACT_NODES)
      addField (.inputOutput, "CONCRETE_NODES",        $CONCRETE_NODES)
      addField (.inputOutput, "EXTERNAL_INTERACTIONS", $EXTERNAL_INTERACTIONS)
      addField (.inputOutput, "PROTOTYPE_CREATE",      $PROTOTYPE_CREATE)
      addField (.inputOutput, "DOM_IMPORT",            $DOM_IMPORT)
      addField (.inputOutput, "XML_ENCODING",          $XML_ENCODING)
      addField (.inputOutput, "CLASSIC_VRML_ENCODING", $CLASSIC_VRML_ENCODING)
      addField (.inputOutput, "BINARY_ENCODING",       $BINARY_ENCODING)
   }
}
