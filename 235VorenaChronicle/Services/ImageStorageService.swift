import UIKit

enum ImageStorageService {
    private static var directoryURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folder = docs.appendingPathComponent("StoryImages", isDirectory: true)
        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder
    }

    static func saveImage(_ data: Data) -> String? {
        let fileName = UUID().uuidString + ".jpg"
        let url = directoryURL.appendingPathComponent(fileName)
        do {
            try data.write(to: url)
            return fileName
        } catch {
            return nil
        }
    }

    static func loadImage(fileName: String) -> UIImage? {
        let url = directoryURL.appendingPathComponent(fileName)
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    static func deleteImage(fileName: String) {
        let url = directoryURL.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: url)
    }

    static func deleteAllImages() {
        guard let files = try? FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil) else { return }
        for file in files {
            try? FileManager.default.removeItem(at: file)
        }
    }
}
