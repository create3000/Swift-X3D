//
//  X3DNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public class X3DNode :
   X3DBaseNode
{
   // Common properties
   
   internal class var component : String { "Sunrise" }
   internal class var componentLevel : Int32 { 0 }
   internal class var containerField : String { "sunrise" }
   
   // Common properties
   
   public final func getComponent () -> String { Self .component }
   public final func getComponentLevel () -> Int32 { Self .componentLevel }
   public final func getContainerField () -> String { Self .containerField }
   
   // Fields

   @SFNode public final var metadata : X3DNode?
   
   // Properties
   
   internal func getSourceText () -> MFString? { nil }

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DNode)
   }
   
   internal func create (with executionContext : X3DExecutionContext) -> X3DNode
   {
      assert (false, "'\(getTypeName ()).create' is not supported.")
      return self
   }
   
   /// Copies this node into prototype instance
   internal final func copy (with protoInstance : X3DPrototypeInstance) -> X3DNode
   {
      let body = protoInstance .body!
      
      if let namedNode = try? body .getNamedNode (name: getName ())
      {
         return namedNode
      }
      
      let copy = self .create (with: body)
      
      if !getName () .isEmpty
      {
         try! body .updateNamedNode (name: getName (), node: copy)
      }
      
      // Pre defined fields
      
      for preDefinedField in getPreDefinedFields ()
      {
         guard let field = try? copy .getField (name: preDefinedField .getName ()) else
         {
            continue
         }
         
         guard field .getAccessType () == preDefinedField .getAccessType () && field .getType () == preDefinedField .getType () else
         {
            continue
         }
         
         field .isSet = preDefinedField .isSet

         if preDefinedField .references .count == 0
         {
            if preDefinedField .isInitializable
            {
               field .set (with: protoInstance, value: preDefinedField)
            }
         }
         else
         {
            // IS relationship
            
            for originalReference in preDefinedField .references .allObjects
            {
               guard let reference = try? protoInstance .getField (name: originalReference .getName ()) else
               {
                  continue
               }
               
               field .addReference (to: reference)
            }
         }
      }
      
      // User defined fields from Script and Shader
      
      for userDefinedField in getUserDefinedFields ()
      {
         let field = userDefinedField .copy ()
         
         copy .addUserDefinedField (userDefinedField .getAccessType (), userDefinedField .getName (), field)
         
         field .isSet = userDefinedField .isSet

         if userDefinedField .references .count == 0
         {
            if userDefinedField .isInitializable
            {
               field .set (with: protoInstance, value: userDefinedField)
            }
         }
         else
         {
            // IS relationship

            for originalReference in userDefinedField .references .allObjects
            {
               guard let reference = try? protoInstance .getField (name: originalReference .getName ()) else
               {
                  continue
               }
               
               field .addReference (to: reference)
            }
         }
      }
      
      copy .setup ()
      
      return copy
   }

   // Prototype handling
   
   /// Returns the innermost node of an X3DPrototypeInstance or self.
   internal var innerNode : X3DNode? { self }
}
