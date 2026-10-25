import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var store: ShiftStore
    @Binding var showAdd: Bool
    private var now: Date { Date() }
    private var stats: (workDays: Int, shiftHours: Double, otHours: Double, allowance: Double, otPay: Double, total: Double) { store.monthlySummary(now) }
    private var active: (active: ShiftRecord?, upcoming: ShiftRecord?) { ScheduleMath.timeStatus(now: now, records: store.records, kinds: store.kinds) }
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("NurseFlow").font(.system(size: 17, weight: .heavy, design: .rounded)).foregroundStyle(Palette.blue)
                        Text("ตารางเวรของฉัน ✳").font(.system(size: 27, weight: .bold, design: .rounded)).foregroundStyle(Palette.ink)
                        Text("วางแผนการทำงานและวันพักผ่อน").font(.subheadline).foregroundStyle(Palette.muted)
                    }
                    Spacer()
                    Image(systemName: "cross.case.fill").font(.title2).foregroundStyle(Palette.blue)
                        .frame(width: 50, height: 50).background(Color(hex: "#E4F0FF"), in: RoundedRectangle(cornerRadius: 17))
                }
                PastelCard(background: Color(hex: "#EDF5FF")) {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Label(active.active != nil ? "กำลังเข้าเวร" : "เวรถัดไป", systemImage: active.active != nil ? "clock.fill" : "sun.max.fill")
                                .font(.subheadline.weight(.semibold)).foregroundStyle(Palette.muted)
                            Spacer()
                            Image(systemName: "heart.text.square.fill").foregroundStyle(Palette.blue)
                        }
                        if let rec = active.active ?? active.upcoming, let kind = store.kind(for: rec.kindID) {
                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(kind.title).font(.system(size: 27, weight: .bold, design: .rounded)).foregroundStyle(Palette.ink)
                                    Text(rec.day).font(.subheadline).foregroundStyle(Palette.muted)
                                    Text(timeLabel(kind)).font(.headline).foregroundStyle(Palette.blue)
                                }
                                Spacer()
                                ShiftPill(kind: kind).scaleEffect(1.25).padding(.trailing, 6)
                            }
                        } else {
                            Text("ยังไม่มีเวรที่กำลังทำหรือเวรถัดไป").foregroundStyle(Palette.muted).padding(.vertical, 12)
                        }
                        Button { showAdd = true } label: {
                            Label("เพิ่มเวร", systemImage: "plus.circle.fill")
                                .font(.subheadline.weight(.bold)).frame(maxWidth: .infinity).padding(.vertical, 13)
                                .foregroundStyle(.white).background(Palette.blue, in: RoundedRectangle(cornerRadius: 14))
                        }
                    }
                }
                HStack(spacing: 10) {
                    statCard("วันทำงาน", "\(stats.workDays)", color: Color(hex: "#E8F1FF"), symbol: "calendar")
                    statCard("เวรดึก", "\(store.records(inMonth: now).filter { $0.kindID == "N" }.count)", color: Palette.violet, symbol: "moon.stars.fill")
                    statCard("OT (ชม.)", String(format: "%.1f", stats.otHours), color: Palette.pink, symbol: "clock.arrow.circlepath")
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("7 วันข้างหน้า").font(.title3.weight(.bold)).foregroundStyle(Palette.ink)
                    ForEach(0..<7, id: \.self) { day in
                        if let date = Calendar.current.date(byAdding: .day, value: day, to: Date()) {
                            let key = ScheduleMath.dayKey(date)
                            HStack(spacing: 12) {
                                Text(date.formatted(.dateTime.day().weekday(.abbreviated)))
                                    .font(.subheadline.weight(.semibold)).frame(width: 62, alignment: .leading).foregroundStyle(Palette.muted)
                                if let entry = store.record(on: key), let kind = store.kind(for: entry.kindID) {
                                    ShiftPill(kind: kind)
                                    Text(kind.title).font(.subheadline.weight(.medium)).foregroundStyle(Palette.ink)
                                    Spacer()
                                    Text(kind.isWork ? timeLabel(kind) : "พักผ่อน").font(.caption).foregroundStyle(Palette.muted)
                                } else {
                                    Text("ยังไม่ได้ลงเวร").font(.subheadline).foregroundStyle(Palette.muted)
                                    Spacer()
                                }
                            }.padding(.vertical, 9)
                            if day != 6 { Divider().overlay(Palette.border) }
                        }
                    }
                }
                .padding(16).background(.white, in: RoundedRectangle(cornerRadius: 22))
                if !store.warnings().isEmpty {
                    PastelCard(background: Color(hex: "#FFF2DE")) {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("ตรวจสอบเวลาพัก", systemImage: "exclamationmark.triangle.fill").font(.headline).foregroundStyle(Palette.ink)
                            ForEach(store.warnings().prefix(3), id: \.self) { Text($0).font(.caption).foregroundStyle(Palette.muted) }
                        }
                    }
                }
                Spacer(minLength: 16)
            }.padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 28)
        }.background(Palette.canvas).navigationBarHidden(true)
    }
    private func statCard(_ title: String, _ value: String, color: Color, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: symbol).foregroundStyle(Palette.blue).font(.subheadline)
            Text(value).font(.system(size: 24, weight: .bold, design: .rounded)).foregroundStyle(Palette.ink)
            Text(title).font(.system(size: 11)).foregroundStyle(Palette.muted).lineLimit(1).minimumScaleFactor(0.8)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(12).background(color, in: RoundedRectangle(cornerRadius: 18))
    }
    private func timeLabel(_ kind: ShiftKind) -> String {
        func fmt(_ m: Int) -> String { String(format: "%02d:%02d", (m/60)%24, m%60) }
        return "\(fmt(kind.startMinute))–\(fmt(kind.startMinute + kind.durationMinutes))"
    }
}
