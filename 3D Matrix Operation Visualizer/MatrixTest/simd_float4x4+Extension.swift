//
//  simd_float4x4+Extension.swift
//  MatrixTest
//
//  Created by Nicholas Arner on 8/7/24.
//

import simd

extension simd_float4x4 {
    // Create a 4x4 rotation matrix from Euler angles (in degrees)
    init(rotationZYX eulerAngles: SIMD3<Float>) {
        // Convert degrees to radians
        let radiansX = eulerAngles.x * Float.pi / 180
        let radiansY = eulerAngles.y * Float.pi / 180
        let radiansZ = eulerAngles.z * Float.pi / 180

        let cx = cos(radiansX), sx = sin(radiansX)
        let cy = cos(radiansY), sy = sin(radiansY)
        let cz = cos(radiansZ), sz = sin(radiansZ)

        let rotationMatrix = simd_float3x3(
            SIMD3<Float>(cy * cz, cy * sz, -sy),
            SIMD3<Float>(sx * sy * cz - cx * sz, sx * sy * sz + cx * cz, sx * cy),
            SIMD3<Float>(cx * sy * cz + sx * sz, cx * sy * sz - sx * cz, cx * cy)
        )

        self.init(rotationMatrix)
    }

    // Initialize from a 3x3 rotation matrix
    init(_ rotationMatrix: simd_float3x3) {
        self.init(
            SIMD4<Float>(rotationMatrix.columns.0, 0),
            SIMD4<Float>(rotationMatrix.columns.1, 0),
            SIMD4<Float>(rotationMatrix.columns.2, 0),
            SIMD4<Float>(0, 0, 0, 1)
        )
    }

    // Extract position from the matrix
    var position: SIMD3<Float> {
        .init(columns.3.x, columns.3.y, columns.3.z)
    }

    // Extract scale from the matrix
    var scale: SIMD3<Float> {
        .init(
            simd_length(SIMD3<Float>(columns.0.x, columns.0.y, columns.0.z)),
            simd_length(SIMD3<Float>(columns.1.x, columns.1.y, columns.1.z)),
            simd_length(SIMD3<Float>(columns.2.x, columns.2.y, columns.2.z))
        )
    }

    // Extract rotation matrix (3x3)
    var rotationMatrix: simd_float3x3 {
        let scale = self.scale
        return simd_float3x3(
            SIMD3<Float>(columns.0.x, columns.0.y, columns.0.z) / scale.x,
            SIMD3<Float>(columns.1.x, columns.1.y, columns.1.z) / scale.y,
            SIMD3<Float>(columns.2.x, columns.2.y, columns.2.z) / scale.z
        )
    }

    // Extract rotation in degrees
    var rotationInDegrees: SIMD3<Float> {
        let rotMatrix = rotationMatrix

        // Extract rotation angles using a more robust method
        let sy = sqrt(rotMatrix[0, 0] * rotMatrix[0, 0] + rotMatrix[1, 0] * rotMatrix[1, 0])
        let singular = sy < 1e-6

        var x, y, z: Float

        if !singular {
            x = atan2(rotMatrix[2, 1], rotMatrix[2, 2])
            y = atan2(-rotMatrix[2, 0], sy)
            z = atan2(rotMatrix[1, 0], rotMatrix[0, 0])
        } else {
            x = atan2(-rotMatrix[1, 2], rotMatrix[1, 1])
            y = atan2(-rotMatrix[2, 0], sy)
            z = 0
        }

        // Convert radians to degrees
        return SIMD3<Float>(
            x * (180 / .pi),
            y * (180 / .pi),
            z * (180 / .pi)
        )
    }

    // Create a 4x4 matrix from position, scale, and rotation (in degrees)
    init(position: SIMD3<Float>, scale: SIMD3<Float>, rotationZYX: SIMD3<Float>) {
        let scaleMatrix = simd_float4x4(diagonal: SIMD4(scale, 1))
        let rotationMatrix = simd_float4x4(rotationZYX: rotationZYX)
        let translationMatrix = simd_float4x4(
            SIMD4<Float>(1, 0, 0, 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(position.x, position.y, position.z, 1)
        )

        // Combine transformations: translation * rotation * scale
        self = translationMatrix * rotationMatrix * scaleMatrix
    }

    // Extract position matrix
    var positionMatrix: simd_float4x4 {
        var result = matrix_identity_float4x4
        result.columns.3 = SIMD4<Float>(position.x, position.y, position.z, 1)
        return result
    }

    // Extract scale matrix
    var scaleMatrix: simd_float4x4 {
        let scale = self.scale
        return simd_float4x4(diagonal: SIMD4<Float>(scale.x, scale.y, scale.z, 1))
    }
}
