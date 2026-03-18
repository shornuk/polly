//
//  Document.swift
//  Polly
//

import Foundation
import SwiftData

@Model
final class PolicyDocument {
    var id: UUID
    var label: String
    var filename: String
    var fileType: FileType
    var fileSize: Int
    var addedAt: Date
    var policy: Policy?

    init(
        label: String,
        filename: String,
        fileType: FileType,
        fileSize: Int
    ) {
        self.id = UUID()
        self.label = label
        self.filename = filename
        self.fileType = fileType
        self.fileSize = fileSize
        self.addedAt = Date()
    }
}
