//
//  DocumentManager.swift
//  Polly
//

import Foundation

final class DocumentManager {
    static let shared = DocumentManager()
    private init() {}

    // MARK: - Directory

    private var directory: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pollyDocs = docs.appendingPathComponent("polly-documents", isDirectory: true)
        if !FileManager.default.fileExists(atPath: pollyDocs.path) {
            try? FileManager.default.createDirectory(
                at: pollyDocs,
                withIntermediateDirectories: true
            )
        }
        return pollyDocs
    }

    // MARK: - Public API

    /// Write data to disk and return the file URL.
    @discardableResult
    func save(data: Data, filename: String) throws -> URL {
        let url = directory.appendingPathComponent(filename)
        try data.write(to: url, options: .atomic)
        return url
    }

    /// Return the on-disk URL for a stored filename.
    func url(for filename: String) -> URL {
        directory.appendingPathComponent(filename)
    }

    /// Delete a stored file. Silently ignores missing files.
    func delete(filename: String) {
        let url = directory.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }

    /// Whether a file actually exists on disk.
    func exists(filename: String) -> Bool {
        FileManager.default.fileExists(atPath: url(for: filename).path)
    }
}
