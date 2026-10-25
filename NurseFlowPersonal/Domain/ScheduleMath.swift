import Foundation

public enum ScheduleMath {
    public static func dayKey(_ date: Date, calendar: Calendar = .current) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 1970, c.month ?? 1, c.day ?? 1)
    }

    public static func date(_ key: String, calendar: Calendar = .current) -> Date? {
        let parts = key.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3, let result = calendar.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2])), dayKey(result, calendar: calendar) == key else { return nil }
        return result
    }

    public static func interval(_ record: ShiftRecord, kind: ShiftKind, calendar: Calendar = .current) -> DateInterval? {
        guard kind.isWork, kind.durationMinutes > 0, let day = date(record.day, calendar: calendar),
              let start = calendar.date(byAdding: .minute, value: kind.startMinute, to: day),
              let end = calendar.date(byAdding: .minute, value: kind.durationMinutes, to: start) else { return nil }
        return DateInterval(start: start, end: end)
    }

    public static func timeStatus(now: Date, records: [ShiftRecord], kinds: [ShiftKind], calendar: Calendar = .current) -> (active: ShiftRecord?, upcoming: ShiftRecord?) {
        let shifts = records.compactMap { record -> (ShiftRecord, DateInterval)? in
            guard let kind = kinds.first(where: { $0.id == record.kindID }), let range = interval(record, kind: kind, calendar: calendar) else { return nil }
            return (record, range)
        }.sorted { $0.1.start < $1.1.start }
        let active = shifts.first { $0.1.start <= now && now < $0.1.end }?.0
        let upcoming = shifts.first { $0.1.start > now }?.0
        return (active, upcoming)
    }

    public static func conflictWarnings(for records: [ShiftRecord], kinds: [ShiftKind], minRestHours: Double, calendar: Calendar = .current) -> [String] {
        let shifts = records.compactMap { record -> (ShiftRecord, DateInterval)? in
            guard let kind = kinds.first(where: { $0.id == record.kindID }), let range = interval(record, kind: kind, calendar: calendar) else { return nil }
            return (record, range)
        }.sorted { $0.1.start < $1.1.start }
        var result: [String] = []
        guard shifts.count > 1 else { return [] }
        for i in 1..<shifts.count {
            let prev = shifts[i-1], current = shifts[i]
            let restMinutes = current.1.start.timeIntervalSince(prev.1.end) / 60
            if restMinutes < 0 { result.append("เวร \(prev.0.day) และ \(current.0.day) เวลาทับซ้อนกัน") }
            else if restMinutes < minRestHours * 60 { result.append("พักระหว่างเวร \(prev.0.day) ถึง \(current.0.day) เพียง \(Int(restMinutes)) นาที") }
        }
        return result
    }

    public static func summary(records: [ShiftRecord], kinds: [ShiftKind], settings: NurseSettings) -> (workDays: Int, shiftHours: Double, otHours: Double, allowance: Double, otPay: Double, total: Double) {
        var work = 0, scheduledMinutes = 0, otMinutes = 0
        var allowances: Double = 0
        for r in records {
            guard let k = kinds.first(where: { $0.id == r.kindID }), k.isWork else { continue }
            work += 1
            scheduledMinutes += max(0, k.durationMinutes)
            otMinutes += max(0, r.overtimeMinutes)
            allowances += max(0, k.allowance)
        }
        let otPay = Double(otMinutes) / 60 * max(0, settings.overtimeHourlyRate) * max(0, settings.overtimeMultiplier)
        return (work, Double(scheduledMinutes)/60, Double(otMinutes)/60, allowances, otPay, allowances + otPay)
    }

    public static func copiedWeek(records: [ShiftRecord], from start: Date, to target: Date, calendar: Calendar = .current) -> [ShiftRecord] {
        let keys = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }.map { dayKey($0, calendar: calendar) }
        return records.filter { keys.contains($0.day) }.compactMap { record in
            guard let offset = keys.firstIndex(of: record.day), let destDate = calendar.date(byAdding: .day, value: offset, to: target) else { return nil }
            return ShiftRecord(day: dayKey(destDate, calendar: calendar), kindID: record.kindID, overtimeMinutes: record.overtimeMinutes, note: record.note)
        }
    }
}
