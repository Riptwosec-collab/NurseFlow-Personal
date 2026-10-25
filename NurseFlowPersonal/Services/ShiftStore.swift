import Foundation
import SwiftUI

@MainActor
final class ShiftStore: ObservableObject {
    @Published private(set) var kinds: [ShiftKind] = ShiftKind.defaults
    @Published private(set) var records: [ShiftRecord] = []
    @Published private(set) var settings = NurseSettings()
    @Published var lastError: String?

    private var root: URL { FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("NurseFlow", isDirectory: true) }
    private var dataFile: URL { root.appendingPathComponent("schedule.json") }
    private var snapshotFolder: URL { root.appendingPathComponent("backups", isDirectory: true) }

    init() {
        do {
            try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
            try FileManager.default.createDirectory(at: snapshotFolder, withIntermediateDirectories: true)
            if FileManager.default.fileExists(atPath: dataFile.path) {
                let decoded = try JSONDecoder().decode(BackupData.self, from: Data(contentsOf: dataFile))
                kinds = decoded.kinds; records = decoded.records; settings = decoded.settings
            }
        } catch { lastError = "เปิดข้อมูลไม่ได้: \(error.localizedDescription)" }
    }

    var backup: BackupData { BackupData(kinds: kinds, records: records, settings: settings) }
    private func persist(snapshot: Bool = false) {
        do {
            let encoder = JSONEncoder(); encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let payload = try encoder.encode(backup)
            if snapshot && FileManager.default.fileExists(atPath: dataFile.path) {
                let filename = "nurseflow-\(Int(Date().timeIntervalSince1970))-\(UUID().uuidString.prefix(6)).json"
                try FileManager.default.copyItem(at: dataFile, to: snapshotFolder.appendingPathComponent(filename))
                let backups = try FileManager.default.contentsOfDirectory(at: snapshotFolder, includingPropertiesForKeys: [.contentModificationDateKey])
                    .sorted { $0.lastPathComponent > $1.lastPathComponent }
                for old in backups.dropFirst(10) { try? FileManager.default.removeItem(at: old) }
            }
            try payload.write(to: dataFile, options: .atomic)
        } catch { lastError = "บันทึกข้อมูลไม่ได้: \(error.localizedDescription)" }
    }

    func records(inMonth date: Date) -> [ShiftRecord] {
        let cal = Calendar.current
        return records.filter { rec in
            guard let d = ScheduleMath.date(rec.day) else { return false }
            return cal.isDate(d, equalTo: date, toGranularity: .month)
        }.sorted { $0.day < $1.day }
    }

    func record(on day: String) -> ShiftRecord? { records.first { $0.day == day } }
    func kind(for id: String) -> ShiftKind? { kinds.first { $0.id == id } }

    func upsert(days: [String], kindID: String, otMinutes: Int = 0, note: String = "") {
        guard kinds.contains(where: { $0.id == kindID }) else { return }
        let daySet = Set(days)
        records.removeAll { daySet.contains($0.day) }
        records += daySet.sorted().map { ShiftRecord(day: $0, kindID: kindID, overtimeMinutes: max(0, otMinutes), note: note) }
        records.sort { $0.day < $1.day }
        persist()
        refreshNotifications()
    }
    func remove(day: String) {
        records.removeAll { $0.day == day }
        persist(); refreshNotifications()
    }
    func copyPreviousWeek(to targetDate: Date) {
        var cal = Calendar.current; cal.firstWeekday = 2
        guard let week = cal.dateInterval(of: .weekOfYear, for: targetDate),
              let prev = cal.date(byAdding: .day, value: -7, to: week.start) else { return }
        let copied = ScheduleMath.copiedWeek(records: records, from: prev, to: week.start)
        let newDays = Set(copied.map(\.day))
        records.removeAll { newDays.contains($0.day) }
        records += copied; records.sort { $0.day < $1.day }
        persist(snapshot: true); refreshNotifications()
    }
    func copyPreviousMonth(to month: Date) {
        let cal = Calendar.current
        guard let prev = cal.date(byAdding: .month, value: -1, to: month),
              let prevRange = cal.range(of: .day, in: .month, for: prev),
              let thisRange = cal.range(of: .day, in: .month, for: month) else { return }
        var copied: [ShiftRecord] = []
        for d in thisRange {
            guard prevRange.contains(d), let fromDate = cal.date(bySetting: .day, value: d, of: prev),
                  let toDate = cal.date(bySetting: .day, value: d, of: month),
                  let old = record(on: ScheduleMath.dayKey(fromDate)) else { continue }
            copied.append(ShiftRecord(day: ScheduleMath.dayKey(toDate), kindID: old.kindID, overtimeMinutes: old.overtimeMinutes, note: old.note))
        }
        let keys = Set(copied.map(\.day)); records.removeAll { keys.contains($0.day) }
        records += copied; records.sort { $0.day < $1.day }
        persist(snapshot: true); refreshNotifications()
    }
    func updateKind(_ kind: ShiftKind) {
        guard !kinds.contains(where: { $0.id != kind.id && $0.code.caseInsensitiveCompare(kind.code) == .orderedSame }) else { lastError = "รหัสเวรนี้มีอยู่แล้ว"; return }
        if let index = kinds.firstIndex(where: { $0.id == kind.id }) { kinds[index] = kind }
        else { kinds.append(kind) }
        persist(); refreshNotifications()
    }
    func deleteKind(_ id: String) {
        guard !records.contains(where: { $0.kindID == id }) else { lastError = "ลบรหัสที่ยังมีเวรอยู่ไม่ได้"; return }
        kinds.removeAll { $0.id == id }; persist()
    }
    func updateSettings(_ updated: NurseSettings) { settings = updated; persist(); refreshNotifications() }

    func warnings() -> [String] { ScheduleMath.conflictWarnings(for: records, kinds: kinds, minRestHours: settings.minimumRestHours) }
    func monthlySummary(_ month: Date) -> (workDays: Int, shiftHours: Double, otHours: Double, allowance: Double, otPay: Double, total: Double) {
        ScheduleMath.summary(records: records(inMonth: month), kinds: kinds, settings: settings)
    }

    func exportJSON() -> URL? {
        do {
            let encoder = JSONEncoder(); encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("NurseFlow-Backup.json")
            try encoder.encode(backup).write(to: url, options: .atomic)
            return url
        } catch { lastError = error.localizedDescription; return nil }
    }
    func exportCSV() -> URL? {
        let lines = ["date,shift,ot_minutes,note"] + records.sorted { $0.day < $1.day }.map { rec in
            [rec.day, kind(for: rec.kindID)?.code ?? rec.kindID, "\(rec.overtimeMinutes)", rec.note]
                .map { "\"" + $0.replacingOccurrences(of: "\"", with: "\"\"") + "\"" }.joined(separator: ",")
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("NurseFlow-Schedule.csv")
        do { try ("\u{FEFF}" + lines.joined(separator: "\r\n")).write(to: url, atomically: true, encoding: .utf8); return url }
        catch { lastError = error.localizedDescription; return nil }
    }
    func exportICS() -> URL? {
        let formatter = DateFormatter(); formatter.locale = Locale(identifier: "en_US_POSIX"); formatter.dateFormat = "yyyyMMdd'T'HHmmss"
        var parts = ["BEGIN:VCALENDAR", "VERSION:2.0", "PRODID:-//NurseFlow Personal//Native iOS//TH", "CALSCALE:GREGORIAN"]
        for rec in records {
            guard let kind = kind(for: rec.kindID), let range = ScheduleMath.interval(rec, kind: kind) else { continue }
            let title = kind.title.replacingOccurrences(of: ",", with: "\\,").replacingOccurrences(of: "\n", with: "\\n")
            parts += ["BEGIN:VEVENT", "UID:\(rec.id.uuidString)@nurseflow.local", "DTSTAMP:\(formatter.string(from: Date()))", "DTSTART:\(formatter.string(from: range.start))", "DTEND:\(formatter.string(from: range.end))", "SUMMARY:\(title)", "END:VEVENT"]
        }
        parts += ["END:VCALENDAR"]
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("NurseFlow-Calendar.ics")
        do { try parts.joined(separator: "\r\n").write(to: url, atomically: true, encoding: .utf8); return url }
        catch { lastError = error.localizedDescription; return nil }
    }

    func importJSON(_ raw: Data) throws {
        let incoming = try JSONDecoder().decode(BackupData.self, from: raw)
        guard incoming.schemaVersion == 1, !incoming.kinds.isEmpty,
              incoming.records.allSatisfy({ rec in incoming.kinds.contains(where: { $0.id == rec.kindID }) && ScheduleMath.date(rec.day) != nil }) else {
            throw NSError(domain: "NurseFlow", code: 1, userInfo: [NSLocalizedDescriptionKey: "ไฟล์สำรองไม่ถูกต้อง"])
        }
        persist(snapshot: true)
        kinds = incoming.kinds; records = incoming.records; settings = incoming.settings
        persist(); refreshNotifications()
    }
    func importCSV(_ raw: String) throws -> Int {
        let parsed = ImportService.parseCSV(raw, kinds: kinds)
        guard !parsed.isEmpty else { throw NSError(domain: "NurseFlow", code: 2, userInfo: [NSLocalizedDescriptionKey: "ไม่พบวันที่และรหัสเวรใน CSV"] ) }
        persist(snapshot: true)
        for rec in parsed { records.removeAll { $0.day == rec.day }; records.append(rec) }
        records.sort { $0.day < $1.day }; persist(); refreshNotifications()
        return parsed.count
    }
    func importPhotoRows(_ rows: [ShiftRecord]) {
        guard !rows.isEmpty else { return }
        persist(snapshot: true)
        for rec in rows { records.removeAll { $0.day == rec.day }; records.append(rec) }
        records.sort { $0.day < $1.day }; persist(); refreshNotifications()
    }
    func refreshNotifications() {
        Task { await ReminderService.reschedule(records: records, kinds: kinds, settings: settings) }
    }
}
