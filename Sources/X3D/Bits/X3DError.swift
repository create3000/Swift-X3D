//
//  Error.swift
//  X3D
//
//  Created by Holger Seelig on 07.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public enum X3DError :
   LocalizedError,
   CustomStringConvertible
{
   case BROWSER_UNAVAILABLE (String)
   case CONNECTION_ERROR (String)
   case DISPOSED (String)
   case IMPORTED_NODE (String)
   case INITIALIZED_ERROR (String)
   case INSUFFICIENT_CAPABILITIES (String)
   case INVALID_ACCESS_TYPE (String)
   case INVALID_BROWSER (String)
   case INVALID_DOCUMENT (String)
   case INVALID_EXECUTION_CONTEXT (String)
   case INVALID_FIELD (String)
   case INVALID_NAME (String)
   case INVALID_NODE (String)
   case INVALID_OPERATION_TIMING (String)
   case INVALID_SCENE (String)
   case INVALID_URL (String)
   case INVALID_X3D (String)
   case NODE_IN_USE (String)
   case NODE_NOT_AVAILABLE (String)
   case NOT_SHARED (String)
   case NOT_SUPPORTED (String)
   case URL_UNAVAILABLE (String)

   public var description : String
   {
      switch self
      {
         case .BROWSER_UNAVAILABLE       (let message): return message
         case .CONNECTION_ERROR          (let message): return message
         case .DISPOSED                  (let message): return message
         case .IMPORTED_NODE             (let message): return message
         case .INITIALIZED_ERROR         (let message): return message
         case .INSUFFICIENT_CAPABILITIES (let message): return message
         case .INVALID_ACCESS_TYPE       (let message): return message
         case .INVALID_BROWSER           (let message): return message
         case .INVALID_DOCUMENT          (let message): return message
         case .INVALID_EXECUTION_CONTEXT (let message): return message
         case .INVALID_FIELD             (let message): return message
         case .INVALID_NAME              (let message): return message
         case .INVALID_NODE              (let message): return message
         case .INVALID_OPERATION_TIMING  (let message): return message
         case .INVALID_SCENE             (let message): return message
         case .INVALID_URL               (let message): return message
         case .INVALID_X3D               (let message): return message
         case .NODE_IN_USE               (let message): return message
         case .NODE_NOT_AVAILABLE        (let message): return message
         case .NOT_SHARED                (let message): return message
         case .NOT_SUPPORTED             (let message): return message
         case .URL_UNAVAILABLE           (let message): return message
      }
   }

   public var errorDescription : String?
   {
      switch self
      {
         case .BROWSER_UNAVAILABLE       (let message): return t("Browser unavailable: %@", message)
         case .CONNECTION_ERROR          (let message): return t("Connection error: %@", message)
         case .DISPOSED                  (let message): return t("Disposed: %@", message)
         case .IMPORTED_NODE             (let message): return t("Imported node: %@", message)
         case .INITIALIZED_ERROR         (let message): return t("Initialized error: %@", message)
         case .INSUFFICIENT_CAPABILITIES (let message): return t("Insufficient capabilities: %@", message)
         case .INVALID_ACCESS_TYPE       (let message): return t("Invalid access type: %@", message)
         case .INVALID_BROWSER           (let message): return t("Invalid browser: %@", message)
         case .INVALID_DOCUMENT          (let message): return t("Invalid document: %@", message)
         case .INVALID_EXECUTION_CONTEXT (let message): return t("Invalid execution context: %@", message)
         case .INVALID_FIELD             (let message): return t("Invalid field: %@", message)
         case .INVALID_NAME              (let message): return t("Invalid name: %@", message)
         case .INVALID_NODE              (let message): return t("Invalid node: %@", message)
         case .INVALID_OPERATION_TIMING  (let message): return t("Invalid %@", message)
         case .INVALID_SCENE             (let message): return t("Invalid scene: %@", message)
         case .INVALID_URL               (let message): return t("Invalid URL: %@", message)
         case .INVALID_X3D               (let message): return t("Invalid X3D: %@", message)
         case .NODE_IN_USE               (let message): return t("Node in use: %@", message)
         case .NODE_NOT_AVAILABLE        (let message): return t("Node not available: %@", message)
         case .NOT_SHARED                (let message): return t("Not shared: %@", message)
         case .NOT_SUPPORTED             (let message): return t("Not supported: %@", message)
         case .URL_UNAVAILABLE           (let message): return t("URL unavailable: %@", message)
      }
   }
}
