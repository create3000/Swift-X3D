//
//  Script.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class Script :
   X3DScriptNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "Script" }
   internal final override class var component      : String { "Scripting" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }

   // Fields

   @SFBool public final var directOutput : Bool = false
   @SFBool public final var mustEvaluate : Bool = false
   
   // Properties
   
   private final var context : JavaScript .Context?
   
   // Static properties
   
   private static let ecmascript = try! NSRegularExpression (pattern: "^((?:ecmascript|vrmlscript|javascript):)")

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Script)

      addField (.inputOutput,    "metadata",     $metadata)
      addField (.inputOutput,    "url",          $url)
      addField (.initializeOnly, "directOutput", $directOutput)
      addField (.initializeOnly, "mustEvaluate", $mustEvaluate)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Script
   {
      return Script (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      $url .addInterest ("set_url", Script .set_url, self)

      requestImmediateLoad ()
   }
   
   // Event handlers
   
   private final func set_url ()
   {
      guard checkLoadState != .IN_PROGRESS_STATE else { return }
      
      setLoadState (.NOT_STARTED_STATE)
      
      requestImmediateLoad ()
   }

   public final override func requestImmediateLoad ()
   {
      guard checkLoadState != .COMPLETE_STATE && checkLoadState != .IN_PROGRESS_STATE else { return }
      
      setLoadState (.IN_PROGRESS_STATE)

      // Start load.

      let url      = self .url
      let worldURL = executionContext! .getWorldURL ()
      
      browser! .inlineQueue .async
      {
         guard let browser = self .browser else { return }
         
         for URL in url
         {
            var sourceText = ""
            
            if let matches = Script .ecmascript .matches (in: URL)
            {
               let index = URL .index (URL .startIndex, offsetBy: matches [1] .count)
               
               sourceText = String (URL .suffix (from: index))
            }
            else if let URL = Foundation .URL (string: URL, relativeTo: worldURL)
            {
               if let string = try? String (contentsOf: URL)
               {
                  sourceText = string
               }
               else
               {
                  browser .console .warn (t("Couldn't read ECMAScript source text from URL."))
                  continue
               }
            }
            else
            {
               browser .console .warn (t("Couldn't read ECMAScript source text."))
               continue
            }

            DispatchQueue .main .async
            {
               self .context = JavaScript .Context (scriptNode: self, sourceText: sourceText)
            }
            
            return
         }
         
         DispatchQueue .main .async
         {
            self .context = nil
         }
      }
   }
}
