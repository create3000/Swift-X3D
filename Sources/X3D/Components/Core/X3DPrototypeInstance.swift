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
   
   public final override class var typeName       : String { "X3DPrototypeInstance" }
   public final override var typeName             : String { protoNode! .identifier }
   public final override class var component      : String { "Core" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "children" }

   // Properties
   
   @SFNode public private(set) var protoNode : X3DProtoDeclarationNode?
   @SFNode public private(set) var body      : X3DExecutionContext?
   
   // Construction
   
   internal init (with executionContext : X3DExecutionContext, from protoNode : X3DProtoDeclarationNode)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.X3DPrototypeInstance)

      addField (.inputOutput, "metadata", $metadata)
      
      for protoField in protoNode .userDefinedFields
      {
         let field = protoField .copy ()

         addField (protoField .accessType, protoField .identifier, field)
     }

      addChildObjects ($protoNode,
                       $body)
      
      self .protoNode = protoNode
      self .body      = X3DExecutionContext (executionContext .browser!, executionContext)
   }
   
   internal final override func create (with executionContext : X3DExecutionContext) -> X3DPrototypeInstance
   {
      return X3DPrototypeInstance (with: executionContext, from: protoNode!)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      if protoNode! .isExternProto
      {
         
      }
      else
      {
         update (with: protoNode as! X3DProtoDeclaration)
      }
   }
   
   private func update (with proto : X3DProtoDeclaration)
   {
      body = X3DExecutionContext (executionContext! .browser!, executionContext)
      
      body! .executionContext = executionContext!
      
      // Extern protos
      
      for externproto in proto .body! .externprotos
      {
         try! body! .updateExternProtoDeclaration (name: externproto .identifier, externproto: externproto)
      }
      
      // Protos
      
      for proto in proto .body! .protos
      {
         try! body! .updateProtoDeclaration (name: proto .identifier, proto: proto)
      }
      
      // Root nodes
      
      for rootNode in proto .body! .rootNodes
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
      
      for route in proto .body! .routes
      {
         let sourceNode       = try! body! .getNamedNode (name: route .sourceNode! .identifier)
         let sourceField      = route .sourceField! .identifier
         let destinationNode  = try! body! .getNamedNode (name: route .destinationNode! .identifier)
         let destinationField = route .destinationField! .identifier
         
         _ = try! body! .addRoute (sourceNode: sourceNode,
                                   sourceField: sourceField,
                                   destinationNode: destinationNode,
                                   destinationField: destinationField)
      }
      
      // Inform parents about root node change.
      addEvent ()
   }

   // Root node handling

   internal final override var innerNode : X3DNode?
   {
      guard body! .rootNodes .count > 0 else { return nil }

      return body! .rootNodes [0]? .innerNode
   }
}
