import Foundation
import Vision
import UIKit

enum ImportService {
    // Understands CSV with quoted values. .xlsx can be exported as CSV in Excel/Numbers.
    static func rows(_ csv: String) -> [[String]] {
        var output: [[String]] = [], row: [String] = [], field = "", inQuotes = false
        let chars = Array(csv.replacingOccurrences(of: "\u{FEFF}", with: ""))
        var i = 0
        while i < chars.count {
            let c = chars[i]
            if c == "\"" {
                if inQuotes && i+1 < chars.count && chars[i+1] == "\"" { field.append("\""); i += 1 }
                else { inQuotes.toggle() }
            } else if c == "," && !inQuotes { row.append(field); field = "" }
            else if (c == "\n" || c == "\r") && !inQuotes {
                if c == "\r" && i+1 < chars.count && chars[i+1] == "\n" { i += 1 }
                row.append(field); field = ""
                if row.contains(where: { !$0.isEmpty }) { output.append(row) }
                row = []
            } else { field.append(c) }
            i += 1
        }
        row.append(field); if row.contains(where: { !$0.isEmpty }) { output.append(row) }
        return output
    }
    static func parseCSV(_ csv: String, kinds: [ShiftKind]) -> [ShiftRecord] {
        let rows = rows(csv)
        guard !rows.isEmpty else { return [] }
        let first = rows[0].map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
        let hasHeader = first.contains(where: { ["date", "day", "วันที่"].contains($0) })
        let dateIdx = first.firstIndex(where: { ["date", "day", "วันที่"].contains($0) }) ?? 0
        let shiftIdx = first.firstIndex(where: { ["shift", "code", "เวร", "รหัสเวร"].contains($0) }) ?? 1
        let otIdx = first.firstIndex(where: { ["ot_minutes", "ot", "โอที"].contains($0) }) ?? 2
        let noteIdx = first.firstIndex(where: { ["note", "หมายเหตุ"].contains($0) }) ?? 3
        return rows.dropFirst(hasHeader ? 1 : 0).compactMap { row in
            guard row.indices.contains(dateIdx), row.indices.contains(shiftIdx) else { return nil }
            let rawDate = row[dateIdx].trimmingCharacters(in: .whitespacesAndNewlines)
            let day = normalizedDay(rawDate)
            guard let day, let kind = kinds.first(where: { $0.code.caseInsensitiveCompare(row[shiftIdx].trimmingCharacters(in: .whitespacesAndNewlines)) == .orderedSame || $0.id == row[shiftIdx].trimmingCharacters(in: .whitespacesAndNewlines) }) else { return nil }
            let minutes = row.indices.contains(otIdx) ? (Int(row[otIdx].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0) : 0
            let note = row.indices.contains(noteIdx) ? row[noteIdx] : ""
            return ShiftRecord(day: day, kindID: kind.id, overtimeMinutes: max(0, minutes), note: note)
        }
    }
    static func normalizedDay(_ str: String) -> String? {
        if ScheduleMath.date(str) != nil { return str }
        let match = str.trimmingCharacters(in: .whitespacesAndNewlines).split(whereSeparator: { $0 == "/" || $0 == "-" })
        guard match.count == 3, let d = Int(match[0]), let m = Int(match[1]), let y = Int(match[2]) else { return nil }
        let key = String(format:"%04d-%02d-%02d", y < 100 ? y + 2000 : y, m, d)
        return ScheduleMath.date(key) == nil ? nil : key
    }
    static func readPhoto(_ image: UIImage) throws -> [String] {
        guard let cg = image.cgImage else { return [] }
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["th-TH", "en-US"]
        request.usesLanguageCorrection = true
        try VNImageRequestHandler(cgImage: cg).perform([request])
        return (request.results ?? []).compactMap { $0.topCandidates(1).first?.string }
    }
    static func parseRecognizedText(_ lines: [String], kinds: [ShiftKind]) -> [ShiftRecord] {
        let regex = try! NSRegularExpression(pattern: #"\b(\d{4}-\d{2}-\d{2}|\d{1,2}/\d{1,2}/\d{4})\b"#)
        return lines.compactMap { line -> ShiftRecord? in
            let ns = line as NSString, full = NSRange(location: 0, length: ns.length)
            guard let match = regex.firstMatch(in: line, range: full), let day = normalizedDay(ns.substring(with: match.range)) else { return nil }
            let tail = ns.substring(from: NSMaxRange(match.range)).trimmingCharacters(in: .whitespacesAndNewlines)
            let tokens = tail.split(whereSeparator: { !$0.isLetter && !$0.isNumber }).map(String.init)
            guard let kind = kinds.first(where: { k in tokens.contains { $0.caseInsensitiveCompare(k.code) == .orderedSame || $0.caseInsensitiveCompare(k.id) == .orderedSame } }) else { return nil }
            return ShiftRecord(day: day, kindID: kind.id)
        }
    }
}
