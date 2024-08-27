//
//  ContentView.swift
//  MatrixTest
//
//  Created by Nicholas Arner on 8/7/24.
//

import SwiftUI
import SceneKit
import simd

struct ContentView: View {
    @State private var position = SIMD3<Float>(repeating: 0)
    @State private var scale = SIMD3<Float>(repeating: 1)
    @State private var rotation = SIMD3<Float>(repeating: 0)  // In degrees

    var body: some View {
        VStack(spacing: 30) {
            
            HStack(alignment: .top, spacing: 40) {
                // Left column: Controls
                VStack(spacing: 30) {
                    ControlGroup(title: "Position", values: $position, range: -5...5)
                    ControlGroup(title: "Scale", values: $scale, range: 0.1...2)
                    ControlGroup(title: "Rotation (Degrees)", values: $rotation, range: -180...180)
                    
                    Button(action: resetValues) {
                        Text("Reset All Values")
                            .fontWeight(.medium)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, 20)
                }
                .frame(width: 320)
                
                // Right side: 3D visualization and Matrix displays
                VStack(spacing: 30) {
                    // 3D Visualization
                    VStack(spacing: 10) {
                        Text("3D Visualization")
                            .font(.title2)
                        SceneKitView(transformationMatrix: constructMatrix())
                            .frame(width: 500, height: 300)
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(15)
                    }
                    
                    // Matrix Information
                    HStack(alignment: .top, spacing: 30) {
                        VStack(spacing: 20) {
                            CompactMatrixView(title: "Transformation Matrix", matrix: constructMatrix())
                            CompactMatrixView(title: "Position Matrix", matrix: constructMatrix().positionMatrix)
                        }
                        VStack(spacing: 20) {
                            CompactMatrixView(title: "Scale Matrix", matrix: constructMatrix().scaleMatrix)
                            CompactRotationView(matrix: constructMatrix(), rotation: rotation)
                        }
                    }
                }
                .frame(width: 700)
            }
            .padding(.horizontal, 40)
        }
        .frame(minWidth: 1100, minHeight: 750)
        .background(Color.white)
    }

    func constructMatrix() -> simd_float4x4 {
        simd_float4x4(position: position, scale: scale, rotationZYX: rotation)
    }

    func resetValues() {
        position = SIMD3<Float>(repeating: 0)
        scale = SIMD3<Float>(repeating: 1)
        rotation = SIMD3<Float>(repeating: 0)
    }
}

struct ControlGroup: View {
    let title: String
    @Binding var values: SIMD3<Float>
    let range: ClosedRange<Float>

    var body: some View {
        GroupBox(label: Text(title).font(.headline)) {
            VStack(spacing: 15) {
                SliderRow(value: $values.x, label: "X", range: range)
                SliderRow(value: $values.y, label: "Y", range: range)
                SliderRow(value: $values.z, label: "Z", range: range)
            }
            .padding(.vertical, 10)
        }
    }
}

struct SliderRow: View {
    @Binding var value: Float
    let label: String
    let range: ClosedRange<Float>

    var body: some View {
        HStack(spacing: 15) {
            Text(label)
                .frame(width: 20)
            Slider(value: $value, in: range)
            Text(String(format: "%.2f", value))
                .frame(width: 50)
                .font(.system(.body, design: .monospaced))
        }
    }
}

struct CompactMatrixView: View {
    let title: String
    let matrix: simd_float4x4

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            ForEach(0..<4) { row in
                HStack(spacing: 8) {
                    ForEach(0..<4) { col in
                        Text(String(format: "%.2f", matrix[row][col]))
                            .frame(width: 60, alignment: .trailing)
                            .font(.system(.body, design: .monospaced))
                    }
                }
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct CompactRotationView: View {
    let matrix: simd_float4x4
    let rotation: SIMD3<Float>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Rotation Information")
                .font(.headline)
            Text("Euler Angles (degrees):")
                .font(.subheadline)
            HStack(spacing: 15) {
                Text("X: \(rotation.x, specifier: "%.2f")°")
                Text("Y: \(rotation.y, specifier: "%.2f")°")
                Text("Z: \(rotation.z, specifier: "%.2f")°")
            }
            .font(.system(.body, design: .monospaced))
            Text("Rotation Matrix:")
                .font(.subheadline)
                .padding(.top, 5)
            ForEach(0..<3) { row in
                HStack(spacing: 8) {
                    ForEach(0..<3) { col in
                        Text(String(format: "%.2f", matrix.rotationMatrix[row][col]))
                            .frame(width: 60, alignment: .trailing)
                            .font(.system(.body, design: .monospaced))
                    }
                }
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}


struct RotationDisplayView: View {
    let matrix: simd_float4x4
    let rotation: SIMD3<Float>

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Rotation Information")
                .font(.headline)

            Group {
                Text("Euler Angles (degrees):")
                    .font(.subheadline)
                Text("X: \(rotation.x, specifier: "%.2f")°")
                Text("Y: \(rotation.y, specifier: "%.2f")°")
                Text("Z: \(rotation.z, specifier: "%.2f")°")
            }

            Group {
                Text("Rotation Matrix:")
                    .font(.subheadline)
                    .padding(.top, 5)
                let rotMat = matrix.rotationMatrix
                ForEach(0..<3) { row in
                    HStack {
                        ForEach(0..<3) { col in
                            Text("\(rotMat[row][col], specifier: "%.4f")")
                                .frame(width: 70, alignment: .trailing)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct MatrixDisplayView: View {
    let title: String
    let matrix: simd_float4x4
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            
            // Matrix display
            VStack(alignment: .leading, spacing: 5) {
                ForEach(0..<4) { row in
                    MatrixRow(values: matrix[row])
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            if title == "Transformation Matrix" {
                MatrixExplanationView(matrix: matrix)
            }
        }
    }
}

struct MatrixExplanationView: View {
    let matrix: simd_float4x4
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What This Matrix Means:")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                explanationItem("Top-Left 3x3 Area (Rows 1-3, Columns 1-3):",
                                "Combines rotation and scaling of the object")
                explanationItem("Fourth Column (First 3 Rows):",
                                "Moves the object in 3D space (X, Y, Z positions)")
                explanationItem("Bottom Row:",
                                "Usually [0, 0, 0, 1] for standard 3D transformations")
            }
            
            Text("Matrix Effect:")
                .font(.headline)
                .padding(.top, 10)
            
            Text("This matrix transforms every point of your 3D object, including rotation, scaling, and translation.")
                .padding(.leading)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func explanationItem(_ title: String, _ description: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct MatrixRow: View {
    let values: SIMD4<Float>
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<4) { i in
                Text(formatFloat(values[i]))
                    .font(.system(.body, design: .monospaced))
                    .frame(width: 70, alignment: .trailing)
            }
        }
    }
    
    private func formatFloat(_ value: Float) -> String {
        String(format: "%.3f", value)
    }
}
