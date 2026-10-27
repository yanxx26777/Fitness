import Foundation

struct BackupExportFile: Identifiable {
    let id = UUID()
    let url: URL

    init(data: Data) throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("Fitness-Backup-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        url = directory.appendingPathComponent("Fitness-backup.json")
        do { try data.write(to: url, options: .atomic) }
        catch { try? FileManager.default.removeItem(at: directory); throw error }
    }
    func remove() { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
}
