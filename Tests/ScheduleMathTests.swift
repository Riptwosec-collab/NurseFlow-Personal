import XCTest
@testable import NurseFlowCore
final class ScheduleMathTests: XCTestCase {
    func testNightShiftSpansMidnight() throws {
        let n = ShiftKind.defaults[2], rec = ShiftRecord(day: "2026-10-25", kindID: "N")
        let interval = try XCTUnwrap(ScheduleMath.interval(rec, kind: n))
        XCTAssertEqual(interval.duration, 8 * 3600)
        XCTAssertEqual(ScheduleMath.dayKey(interval.end), "2026-10-26")
    }
    func testCurrentNightShift() throws {
        let cal = Calendar.current
        let n = ShiftKind.defaults[2]
        let rec = ShiftRecord(day: "2026-10-25", kindID: "N")
        let interval = try XCTUnwrap(ScheduleMath.interval(rec, kind: n))
        let status = ScheduleMath.timeStatus(now: interval.start.addingTimeInterval(3*3600), records: [rec], kinds: [n], calendar: cal)
        XCTAssertEqual(status.active?.id, rec.id)
    }
    func testNoOvertimeDoubleCounted() {
        let entry = ShiftRecord(day: "2026-10-25", kindID: "D", overtimeMinutes: 120)
        var settings = NurseSettings(); settings.overtimeHourlyRate = 100; settings.overtimeMultiplier = 1.5
        let sum = ScheduleMath.summary(records: [entry], kinds: ShiftKind.defaults, settings: settings)
        XCTAssertEqual(sum.shiftHours, 8)
        XCTAssertEqual(sum.otHours, 2)
        XCTAssertEqual(sum.otPay, 300)
    }
    func testRestViolation() {
        let a = ShiftRecord(day: "2026-10-25", kindID: "N"), b = ShiftRecord(day: "2026-10-26", kindID: "D")
        XCTAssertTrue(ScheduleMath.conflictWarnings(for: [a,b], kinds: ShiftKind.defaults, minRestHours: 11).count > 0)
    }
    func testCopyPreservesWeekOrder() throws {
        let cal = Calendar.current
        let start = try XCTUnwrap(ScheduleMath.date("2026-10-05")), dest = try XCTUnwrap(ScheduleMath.date("2026-10-12"))
        let recs = [ShiftRecord(day: "2026-10-05", kindID: "D"), ShiftRecord(day: "2026-10-11", kindID: "N")]
        let copies = ScheduleMath.copiedWeek(records: recs, from: start, to: dest, calendar: cal)
        XCTAssertEqual(copies.map(\.day).sorted(), ["2026-10-12", "2026-10-18"])
    }
}

extension ScheduleMathTests {
    func testEmptyScheduleHasNoWarnings() {
        XCTAssertTrue(ScheduleMath.conflictWarnings(for: [], kinds: ShiftKind.defaults, minRestHours: 11).isEmpty)
    }
    func testZeroOrOffShiftsDontAddWork() {
        let rec = ShiftRecord(day: "2026-10-25", kindID: "OFF", overtimeMinutes: 90)
        let sum = ScheduleMath.summary(records: [rec], kinds: ShiftKind.defaults, settings: NurseSettings())
        XCTAssertEqual(sum.workDays, 0)
        XCTAssertEqual(sum.otHours, 0)
    }
}
