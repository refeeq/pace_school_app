import UIKit

enum FileHelperError: LocalizedError {
    case unreadable(String)

    var errorDescription: String? {
        switch self {
        case .unreadable(let message):
            return message
        }
    }
}

class FileHelper {
    /// Reads a UTF-8 file. Throws instead of trapping so a bad path cannot kill the process.
    class func getContent(from filePath: String) throws -> String {
        let fileURL = URL(fileURLWithPath: filePath)
        do {
            return try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            throw FileHelperError.unreadable(error.localizedDescription)
        }
    }
}
