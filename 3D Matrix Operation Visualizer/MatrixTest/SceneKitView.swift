//
//  SceneKitView.swift
//  MatrixTest
//
//  Created by Nicholas Arner on 8/7/24.
//

import SwiftUI
import SceneKit

// SwiftUI wrapper for SceneKit view
struct SceneKitView: NSViewRepresentable {
    var transformationMatrix: simd_float4x4
    
    // Create and configure the SceneKit view
    func makeNSView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = SCNScene()
        sceneView.backgroundColor = .clear
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = false

        // Set up camera
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        sceneView.scene?.rootNode.addChildNode(cameraNode)
        
        // Create and add cube to the scene
        let cubeGeometry = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0)
        let cubeMaterial = SCNMaterial()
        cubeMaterial.diffuse.contents = NSColor.blue
        cubeGeometry.materials = [cubeMaterial]
        
        let cubeNode = SCNNode(geometry: cubeGeometry)
        sceneView.scene?.rootNode.addChildNode(cubeNode)
        
        return sceneView
    }
    
    // Update the SceneKit view when the transformation matrix changes
    func updateNSView(_ nsView: SCNView, context: Context) {
        if let cubeNode = nsView.scene?.rootNode.childNodes.first(where: { $0.geometry is SCNBox }) {
            cubeNode.simdTransform = transformationMatrix
        }
    }
}
