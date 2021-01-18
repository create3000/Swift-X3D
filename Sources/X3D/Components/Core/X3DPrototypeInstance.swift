//
//  X3DPrototypeInstance.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public class X3DPrototypeInstance :
   X3DNode
{
   // Common properties
   
   internal final override class var typeName       : String { "X3DPrototypeInstance" }
   internal final override class var component      : String { "Core" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "children" }
   
   public final override func getTypeName () -> String { protoNode! .getName () }

   // Properties
   
   @SFNode public var protoNode : X3DProtoDeclarationNode?
   @SFNode public var body      : X3DExecutionContext?
   
   // Construction
   
   internal init (with executionContext : X3DExecutionContext, from protoNode : X3DProtoDeclarationNode)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.X3DPrototypeInstance)

      addField (.inputOutput, "metadata", $metadata)
      
      for protoField in protoNode .getUserDefinedFields ()
      {
         addField (protoField .getAccessType (), protoField .getName (), protoField .copy ())
      }

      addChildObjects ($protoNode,
                       $body)
      
      self .protoNode = protoNode
      
      if let externproto = protoNode as? X3DExternProtoDeclaration
      {
         DispatchQueue .main .async { externproto .requestImmediateLoad () }
      }
   }
   
   internal final override func create (with executionContext : X3DExecutionContext) -> X3DPrototypeInstance
   {
      return X3DPrototypeInstance (with: executionContext, from: protoNode!)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      protoNode! .addInterest ("update", X3DPrototypeInstance .update, self)
      
      update ()
   }
   
   private func update ()
   {
      guard let proto = protoNode! .proto else
      {
         body = X3DExecutionContext (browser!, executionContext!)
         
         body! .setup ()

         // Inform parents about root node change.
         addEvent ()
         return
      }
      
      if protoNode! .isExternProto
      {
         for protoField in proto .getUserDefinedFields ()
         {
            if let field = try? getField (name: protoField .getName ())
            {
               // Continue if something is wrong.
               guard field .getAccessType () == protoField .getAccessType () else { continue }
 
               // Continue if something is wrong.
               guard field .getType () == protoField .getType () else { continue }

               // Continue if field is eventIn or eventOut.
               guard field .isInitializable else { continue }

               // Is set during parse or later.
               guard !field .isSet else { continue }

               // Has IS references.
               guard field .references .count == 0 else { continue }

               // Fields are equal.
               //guard !field .equals (protoField)) else { continue }
               
               // If default value of protoField is different from field update default value for field.
               field .set (value: protoField)
            }
            else
            {
               // Definition exists in proto but does not exist in extern proto.
               addField (protoField .getAccessType (), protoField .getName (), protoField .copy ())
            }
         }
      }
      
      // Create body.

      body = X3DExecutionContext (browser!, proto .executionContext)
      
      // Extern protos
      
      for externproto in proto .getBody () .getExternProtoDeclarations ()
      {
         try! body! .updateExternProtoDeclaration (name: externproto .getName (), externproto: externproto)
      }
      
      // Protos
      
      for proto in proto .getBody () .getProtoDeclarations ()
      {
         try! body! .updateProtoDeclaration (name: proto .getName (), proto: proto)
      }
      
      // Root nodes
      
      for rootNode in proto .getBody () .rootNodes
      {
         if rootNode == nil
         {
            body! .rootNodes .append (nil)
         }
         else
         {
            body! .rootNodes .append (rootNode! .copy (with: self))
         }
      }
      
      // Imported nodes
      
      // Routes
      
      for route in proto .getBody () .getRoutes ()
      {
         let sourceNode       = try! body! .getNamedNode (name: route .sourceNode! .getName ())
         let sourceField      = route .sourceField! .getName ()
         let destinationNode  = try! body! .getNamedNode (name: route .destinationNode! .getName ())
         let destinationField = route .destinationField! .getName ()
         
         _ = try! body! .addRoute (sourceNode: sourceNode,
                                   sourceField: sourceField,
                                   destinationNode: destinationNode,
                                   destinationField: destinationField)
      }
      
      body! .setup ()

      // Inform parents about root node change.
      addEvent ()
   }
   
   internal final func getBody () -> X3DExecutionContext { body! }

   // Root node handling

   internal final override var innerNode : X3DNode?
   {
      guard !body! .rootNodes .isEmpty else { return nil }

      return body! .rootNodes [0]? .innerNode
   }
   
   // Field handling
   
   public final override func isDefaultValue (fieldName : String) throws -> Bool
   {
      let field = try getField (name: fieldName)
      
      if field === $metadata
      {
         return metadata == nil
      }
      
      guard let other = try? protoNode? .getField (name: field .getName ()) else
      {
         return false
      }
      
      return other .equals (to: field)
   }
}
