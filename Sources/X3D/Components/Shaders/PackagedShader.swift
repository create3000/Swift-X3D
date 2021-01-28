//
//  PackagedShader.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal
import MetalKit
import Foundation

public final class PackagedShader :
   X3DShaderNode,
   X3DProgrammableShaderObject,
   X3DUrlObject,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "PackagedShader" }
   internal final override class var component      : String { "Shaders" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: false) }
   
   // Fields
   
   @MFString public final var url : [String]
   
   // Properties
   
   public final override var canUserDefinedFields : Bool { true }
   
   internal final override func getSourceText () ->  MFString? { $url }

   // X3DUrlObject
   
   public final var loadState = SFEnum <X3DLoadState> (wrappedValue: .NOT_STARTED_STATE)
   
   // Properties
   
   private final var library             : MTLLibrary?
   private final var renderPipelineState : [Bool : MTLRenderPipelineState] = [:]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initProgrammableShaderObject ()
      initUrlObject ()

      types .append (.PackagedShader)

      addField (.inputOutput,    "metadata",   $metadata)
      addField (.inputOnly,      "activate",   $activate)
      addField (.outputOnly,     "isSelected", $isSelected)
      addField (.outputOnly,     "isValid",    $isValid)
      addField (.initializeOnly, "language",   $language)
      addField (.inputOutput,    "url",        $url)

      addChildObjects (loadState)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> PackagedShader
   {
      return PackagedShader (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      addInterest ("set_fields", { $0 .set_fields () }, self)

      $url .addInterest ("set_url",  { $0 .set_url () },  self)
      
      requestImmediateLoad ()
   }

   // Event handlers
   
   private final func set_url ()
   {
      guard checkLoadState != .IN_PROGRESS_STATE else { return }
      
      setLoadState (.NOT_STARTED_STATE)
      
      requestImmediateLoad ()
   }
   
   // Operations

   public final func requestImmediateLoad ()
   {
      guard checkLoadState != .COMPLETE_STATE && checkLoadState != .IN_PROGRESS_STATE else { return }
      
      guard language == "MSL" else { return }

      setLoadState (.IN_PROGRESS_STATE)

      // Start load.

      let url = self .url
         .map (filter_data_url)
         .compactMap { $0 }
         .map { URL (string: $0, relativeTo: executionContext! .getWorldURL ()) }
         .compactMap { $0 }
      
      let name           = self .getName ()
      let constantValues = self .makeConstantValues ()

      browser! .shaderQueue .sync
      {
         guard let browser = self .browser else { return }
         
         let definitionsURL = Bundle .module .url (forResource: "ShaderDefinitions", withExtension: "h")!
         let definitions    = String (data: try! Data (contentsOf: definitionsURL), encoding: .utf8)!

         for URL in url
         {
            do
            {
               guard var sourceText = String (data: try Data (contentsOf: URL), encoding: .utf8) else
               {
                  throw X3DError .INVALID_URL (t("Could not read shader source for shader named '%@'.", name))
               }

               sourceText = "\(definitions)\n\(sourceText)"
               
               let library              = try browser .device! .makeLibrary (source: sourceText, options: nil)
               let renderPipelineState0 = try self .buildRenderPipelineState (library, constantValues, blending: false)
               let renderPipelineState1 = try self .buildRenderPipelineState (library, constantValues, blending: true)
               
               DispatchQueue .main .async
               {
                  self .library                     = library
                  self .renderPipelineState [false] = renderPipelineState0
                  self .renderPipelineState [true]  = renderPipelineState1
                  self .isValid                     = true
                  
                  self .setLoadState (.COMPLETE_STATE)
               }

               return
            }
            catch
            {
               browser .console .warn (t("Couldn't make shader named '%@' from source. %@", name, self .makeError (error, definitions)))
               continue
            }
         }
         
         DispatchQueue .main .async
         {
            self .library = nil
            self .isValid = false
            
            self .setLoadState (.FAILED_STATE)
            
            browser .console .warn (t("Couldn't make shader named '%@' from any source.", name))
         }
      }
   }
   
   private final func buildRenderPipelineState (_ library : MTLLibrary, _ constantValues : MTLFunctionConstantValues, blending : Bool) throws -> MTLRenderPipelineState
   {
      // Create a new pipeline descriptor.
      let pipelineDescriptor = MTLRenderPipelineDescriptor ()
      
      // Setup the shaders in the pipeline.
      let vertexShader   = try library .makeFunction (name: "vertexShader",   constantValues: constantValues)
      let fragmentShader = try library .makeFunction (name: "fragmentShader", constantValues: constantValues)
       
      pipelineDescriptor .vertexFunction   = vertexShader
      pipelineDescriptor .fragmentFunction = fragmentShader
      
      // Setup the output pixel format to match the pixel format of the metal kit view.
      pipelineDescriptor .colorAttachments [0] .pixelFormat                 = browser! .colorPixelFormat
      pipelineDescriptor .colorAttachments [0] .isBlendingEnabled           = blending
      pipelineDescriptor .colorAttachments [0] .sourceRGBBlendFactor        = .sourceAlpha
      pipelineDescriptor .colorAttachments [0] .sourceAlphaBlendFactor      = .one
      pipelineDescriptor .colorAttachments [0] .destinationRGBBlendFactor   = .oneMinusSourceAlpha
      pipelineDescriptor .colorAttachments [0] .destinationAlphaBlendFactor = .oneMinusSourceAlpha
      pipelineDescriptor .colorAttachments [0] .alphaBlendOperation         = .add
      pipelineDescriptor .colorAttachments [0] .rgbBlendOperation           = .add
      
      // Setup the output pixel format to match the pixel format of the metal kit view.
      pipelineDescriptor .depthAttachmentPixelFormat = browser! .depthStencilPixelFormat
      
      // Compile the configured pipeline descriptor to a pipeline state object.
      return try browser! .device! .makeRenderPipelineState (descriptor: pipelineDescriptor)
   }
   
   private final func makeError (_ error : Error, _ definitions : String) -> String
   {
      let programSourceLine = try! NSRegularExpression (pattern: "program_source:(\\d+):")
      var string            = error .localizedDescription
      
      guard let matches = programSourceLine .matches (in: string, all: true) else { return string }
      
      let lines        = definitions .reduce (0, { r, e in e == "\n" ? r + 1 : r })
      var replacements = [(String, String)] ()
      
      for i in stride (from: 1, to: matches .count, by: 2)
      {
         replacements .append ((matches [i-1], "program_source:\(Int (matches [i])! - lines - 1):"))
      }
      
      for r in replacements
      {
         string = string .replacingOccurrences (of: r.0, with: r.1)
      }
      
      return string
   }
   
   private final func set_fields ()
   {
      do
      {
         guard let library = library else { return }
         
         let constantValues = makeConstantValues ()
         
         renderPipelineState [false] = try buildRenderPipelineState (library, constantValues, blending: false)
         renderPipelineState [true]  = try buildRenderPipelineState (library, constantValues, blending: true)
      }
      catch
      {
         browser! .console .warn (t("Couldn't set fields for shader named '%@'. %@", getName (), error .localizedDescription))
      }
   }
   
   private final func makeConstantValues () -> MTLFunctionConstantValues
   {
      let constantValues = MTLFunctionConstantValues ()
      var index          = 0
      
      for field in getUserDefinedFields ()
      {
         switch field .getType ()
         {
            case .SFBool:
               let field = field as! SFBool
               constantValues .setConstantValue (&field .wrappedValue, type: .bool, index: index)
            case .SFColor:
               let field = field as! SFColor
               constantValues .setConstantValue (&field .wrappedValue, type: .float3, index: index)
            case .SFColorRGBA:
               let field = field as! SFColorRGBA
               constantValues .setConstantValue (&field .wrappedValue, type: .float4, index: index)
            case .SFDouble:
               let field = field as! SFDouble
               var value = Float (field .wrappedValue)
               constantValues .setConstantValue (&value, type: .float, index: index)
            case .SFFloat:
               let field = field as! SFFloat
               constantValues .setConstantValue (&field .wrappedValue, type: .float, index: index)
            case .SFImage:
               break
            case .SFInt32:
               let field = field as! SFInt32
               constantValues .setConstantValue (&field .wrappedValue, type: .int, index: index)
            case .SFMatrix3d:
               let field = field as! SFMatrix3d
               var value = Matrix3f (columns: (Vector3f (field .wrappedValue [0]), Vector3f (field .wrappedValue [1]), Vector3f (field .wrappedValue [2])))
               constantValues .setConstantValue (&value, type: .float3x3, index: index)
            case .SFMatrix3f:
               let field = field as! SFMatrix3f
               constantValues .setConstantValue (&field .wrappedValue, type: .float3x3, index: index)
            case .SFMatrix4d:
               let field = field as! SFMatrix4d
               var value = Matrix4f (columns: (Vector4f (field .wrappedValue [0]), Vector4f (field .wrappedValue [1]), Vector4f (field .wrappedValue [2]), Vector4f (field .wrappedValue [3])))
               constantValues .setConstantValue (&value, type: .float4x4, index: index)
            case .SFMatrix4f:
               let field = field as! SFMatrix4f
               constantValues .setConstantValue (&field .wrappedValue, type: .float4x4, index: index)
            case .SFNode:
               break
            case .SFRotation:
               let field = field as! SFRotation
               var value = Matrix3f (field .wrappedValue)
               constantValues .setConstantValue (&value, type: .float3x3, index: index)
            case .SFString:
               break
            case .SFTime:
               let field = field as! SFTime
               var value = Float (field .wrappedValue)
               constantValues .setConstantValue (&value, type: .float, index: index)
            case .SFVec2d:
               let field = field as! SFVec2d
               var value = Vector2f (field .wrappedValue)
               constantValues .setConstantValue (&value, type: .float2, index: index)
            case .SFVec2f:
               let field = field as! SFVec2f
               constantValues .setConstantValue (&field .wrappedValue, type: .float2, index: index)
            case .SFVec3d:
               let field = field as! SFVec3d
               var value = Vector3f (field .wrappedValue)
               constantValues .setConstantValue (&value, type: .float3, index: index)
            case .SFVec3f:
               let field = field as! SFVec3f
               constantValues .setConstantValue (&field .wrappedValue, type: .float3, index: index)
            case .SFVec4d:
               let field = field as! SFVec4d
               var value = Vector4f (field .wrappedValue)
               constantValues .setConstantValue (&value, type: .float4, index: index)
            case .SFVec4f:
               let field = field as! SFVec4f
               constantValues .setConstantValue (&field .wrappedValue, type: .float4, index: index)
            case .MFBool:
               break
            case .MFColor:
               break
            case .MFColorRGBA:
               break
            case .MFDouble:
               break
            case .MFFloat:
               break
            case .MFImage:
               break
            case .MFInt32:
               break
            case .MFMatrix3d:
               break
            case .MFMatrix3f:
               break
            case .MFMatrix4d:
               break
            case .MFMatrix4f:
               break
            case .MFNode:
               break
            case .MFRotation:
               break
            case .MFString:
               break
            case .MFTime:
               break
            case .MFVec2d:
               break
            case .MFVec2f:
               break
            case .MFVec3d:
               break
            case .MFVec3f:
               break
            case .MFVec4d:
               break
            case .MFVec4f:
               break
         }
         
         index += 1
      }
      
      return constantValues
   }

   internal final override func enable (_ renderEncoder : MTLRenderCommandEncoder, blending : Bool)
   {
      renderEncoder .setRenderPipelineState (renderPipelineState [blending]!)
   }
}
