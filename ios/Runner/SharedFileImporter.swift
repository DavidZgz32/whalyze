import Foundation

/// Almacena la ruta de un .txt / .zip abierto desde Archivos, la hoja Compartir u otra app (flujo similar al intent de Android).
enum SharedFileImporter {
    private static var pendingPath: String?
    private static let lock = NSLock()

    static func store(url: URL) {
        guard let path = copyToCache(url: url) else { return }
        lock.lock()
        pendingPath = path
        lock.unlock()
    }

    static func takePendingPath() -> String? {
        lock.lock()
        let path = pendingPath
        pendingPath = nil
        lock.unlock()
        return path
    }

    private static func copyToCache(url: URL) -> String? {
        let fm = FileManager.default
        guard let cacheDir = fm.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }

        var isDir: ObjCBool = false
        if fm.fileExists(atPath: url.path, isDirectory: &isDir), isDir.boolValue {
            return nil
        }

        let didAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        let ext = url.pathExtension.lowercased()
        let suffix: String
        switch ext {
        case "txt", "text", "log":
            suffix = ".txt"
        case "zip":
            suffix = ".zip"
        case "":
            suffix = ".bin"
        default:
            suffix = ".\(ext)"
        }

        let dest = cacheDir.appendingPathComponent(
            "shared_\(Int(Date().timeIntervalSince1970 * 1000))\(suffix)"
        )

        do {
            if fm.fileExists(atPath: dest.path) {
                try fm.removeItem(at: dest)
            }
            try fm.copyItem(at: url, to: dest)
            return dest.path
        } catch {
            guard let data = try? Data(contentsOf: url) else { return nil }
            do {
                try data.write(to: dest)
                return dest.path
            } catch {
                return nil
            }
        }
    }
}
