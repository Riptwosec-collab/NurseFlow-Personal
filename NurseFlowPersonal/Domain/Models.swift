import Foundation

public struct ShiftKind: Identifiable, Codable, Equatable, Sendable {
    public var id: String
    public var code: String
    public var title: String
    public var color: String
    public var startMinute: Int
    public var durationMinutes: Int
    public var allowance: Double
    public var isWork: Bool

    public init(id: String, code: String, title: String, color: String, startMinute: Int, durationMinutes: Int, allowance: Double = 0, isWork: Bool = true) {
        self.id = id; self.code = code; self.title = title; self.color = color
        self.startMinute = startMinute; self.durationMinutes = durationMinutes
        self.allowance = allowance; self.isWork = isWork
    }

    public static let defaults: [ShiftKind] = [
        .init(id: "D", code: "D", title: "เวรเช้า", color: "#DDEBFF", startMinute: 7*60, durationMinutes: 8*60, allowance: 0),
        .init(id: "E", code: "E", title: "เวรบ่าย", color: "#FFE3EE", startMinute: 15*60, durationMinutes: 8*60, allowance: 0),
        .init(id: "N", code: "N", title: "เวรดึก", color: "#E9E2FF", startMinute: 23*60, durationMinutes: 8*60, allowance: 0),
        .init(id: "OFF", code: "OFF", title: "วันหยุด", color: "#DFF5E9", startMinute: 0, durationMinutes: 0, isWork: false),
        .init(id: "LEAVE", code: "L", title: "วันลา", color: "#FFF1D6", startMinute: 0, durationMinutes: 0, isWork: false)
    ]
}

public struct ShiftRecord: Identifiable, Codable, Equatable, Sendable {
    public var id: UUID
    public var day: String      // ISO local calendar date: yyyy-MM-dd
    public var kindID: String
    public var overtimeMinutes: Int
    public var note: String
    public var createdAt: Date
    public init(id: UUID = UUID(), day: String, kindID: String, overtimeMinutes: Int = 0, note: String = "", createdAt: Date = Date()) {
        self.id = id; self.day = day; self.kindID = kindID; self.overtimeMinutes = overtimeMinutes
        self.note = note; self.createdAt = createdAt
    }
}

public struct NurseSettings: Codable, Equatable, Sendable {
    public var displayName: String = ""
    public var overtimeHourlyRate: Double = 0
    public var overtimeMultiplier: Double = 1
    public var minimumRestHours: Double = 11
    public var notificationLeadMinutes: Int = 60
    public var notifyEnabled: Bool = false
    public init() {}
}

public struct BackupData: Codable, Sendable {
    public var schemaVersion: Int = 1
    public var exportedAt: Date = Date()
    public var kinds: [ShiftKind]
    public var records: [ShiftRecord]
    public var settings: NurseSettings
    public init(kinds: [ShiftKind], records: [ShiftRecord], settings: NurseSettings) {
        self.kinds = kinds; self.records = records; self.settings = settings
    }
}
