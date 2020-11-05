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
   
   public class var component : String { "Titania" }
   public final var component : String { Self .component }
   public class var componentLevel : Int32 { 0 }
   public final var componentLevel : Int32 { Self .componentLevel }
   public class var containerField : String { "Titania" }
   public final var containerField : String { Self .containerField }
   
   // Fields

   @SFNode public final var metadata : X3DNode?
   
   // Properties
   
   public var sourceText : MFString? { nil }

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DNode)
   }
   
   internal func create (with executionContext : X3DExecutionContext) -> X3DNode
   {
      assert (false, "'\(typeName).create' is not supported.")
      return self
   }
   
   /// Copies this node into prototype instance
   internal final func copy (with protoInstance : X3DPrototypeInstance) -> X3DNode
   {
      let body = protoInstance .body!
      
      if let namedNode = try? body .getNamedNode (name: identifier)
      {
         return namedNode
      }
      
      let copy = self .create (with: body)
      
      if !identifier .isEmpty
      {
         try! body .updateNamedNode (name: identifier, node: copy)
      }
      
      // Pre defined fields
      
      for preDefinedField in preDefinedFields
      {
         guard let field = try? copy .getField (name: preDefinedField .identifier) else
         {
            continue
         }
         
         guard field .accessType == preDefinedField .accessType && field .type == preDefinedField .type else
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
               guard let reference = try? protoInstance .getField (name: originalReference .identifier) else
               {
                  continue
               }
               
               field .addReference (to: reference)
            }
         }
      }
      
      // User defined fields from Script and Shader
      
      for userDefinedField in userDefinedFields
      {
         let field = userDefinedField .copy ()
         
         copy .addUserDefinedField (userDefinedField .accessType, userDefinedField .identifier, field)
         
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
               guard let reference = try? protoInstance .getField (name: originalReference .identifier) else
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
