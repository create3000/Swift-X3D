//
//  File.swift
//  
//
//  Created by Holger Seelig on 12.02.21.
//

public protocol X3DTransformObject :
   X3DMatrixObject
{
   func setMatrix (_ matrix : Matrix4f)
   
   func setMatrix (_ matrix : Matrix4f, with center : Vector3f)
}
