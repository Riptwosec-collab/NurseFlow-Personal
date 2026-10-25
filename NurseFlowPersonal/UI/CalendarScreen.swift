import SwiftUI

struct CalendarScreen: View {
    @EnvironmentObject private var store: ShiftStore
    @Binding var showAdd: Bool
    @State private var month = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date())) ?? Date()
    @State private var bulkMode = false
    @State private var daysSelected: Set<String> = []
    @State private var editorDays: [String] = []
    @State private var showCopyOptions = false

    private var dates: [Date?] {
        let cal = Calendar.current
        guard let range = cal.range(of: .day, in: .month, for: month) else { return [] }
        let offset = (cal.component(.weekday, from: month) + 5) % 7
        let startPadding = Array<Date?>(repeating: nil, count: offset)
        return startPadding + range.compactMap { cal.date(bySetting: .day, value: $0, of: month) }.map(Optional.some)
    }
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                ScreenTitle(title: "ตารางเวร", subtitle: "แตะวันที่เพื่อแก้ไข หรือเลือกหลายวันพร้อมกัน")
                HStack {
                    Button { stepMonth(-1) } label: { Image(systemName: "chevron.left").frame(width: 38, height: 38) }
                    Spacer()
                    Text(month.formatted(.dateTime.month(.wide).year())).font(.headline).foregroundStyle(Palette.ink)
                    Spacer()
                    Button { stepMonth(1) } label: { Image(systemName: "chevron.right").frame(width: 38, height: 38) }
                }.foregroundStyle(Palette.blue)
                .padding(.horizontal, 6).padding(.vertical, 6)
                .background(.white, in: RoundedRectangle(cornerRadius: 18))
                PastelCard {
                    VStack(spacing: 8) {
                        let weekdays = ["จ", "อ", "พ", "พฤ", "ศ", "ส", "อา"]
                        HStack(spacing: 4) {
                            ForEach(weekdays, id: \.self) { day in
                                Text(day).font(.caption2.weight(.bold)).foregroundStyle(Palette.muted).frame(maxWidth: .infinity)
                            }
                        }
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 6) {
                            ForEach(0..<dates.count, id: \.self) { i in
                                if let date = dates[i] {
                                    let key = ScheduleMath.dayKey(date)
                                    let entry = store.record(on: key)
                                    let kind = entry.flatMap { store.kind(for: $0.kindID) }
                                    Button {
                                        if bulkMode { if daysSelected.contains(key) { daysSelected.remove(key) } else { daysSelected.insert(key) } }
                                        else { editorDays = [key] }
                                    } label: {
                                        VStack(spacing: 5) {
                                            Text("\(Calendar.current.component(.day, from: date))")
                                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                                .foregroundStyle(Palette.ink)
                                            Text(kind?.code ?? "·")
                                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                                .foregroundStyle(Palette.ink)
                                                .lineLimit(1).minimumScaleFactor(0.65)
                                                .frame(maxWidth: .infinity, minHeight: 20)
                                                .background(kind.map { Color(hex: $0.color) } ?? Color(hex: "#F6F8FC"), in: RoundedRectangle(cornerRadius: 6))
                                        }
                                        .padding(.horizontal, 1).padding(.vertical, 7)
                                        .background(daysSelected.contains(key) ? Color(hex: "#DBEBFF") : (Calendar.current.isDateInToday(date) ? Color(hex: "#F4F7FF") : .white), in: RoundedRectangle(cornerRadius: 11))
                                        .overlay(RoundedRectangle(cornerRadius: 11).stroke(daysSelected.contains(key) ? Palette.blue : Palette.border.opacity(0.6), lineWidth: daysSelected.contains(key) ? 2 : 0.6))
                                    }.buttonStyle(.plain)
                                } else { Color.clear.frame(height: 59) }
                            }
                        }
                    }
                }
                HStack(spacing: 8) {
                    ForEach(store.kinds.prefix(5)) { kind in
                        HStack(spacing: 3) {
                            Circle().fill(Color(hex: kind.color)).frame(width: 8, height: 8)
                            Text(kind.code).font(.caption2).foregroundStyle(Palette.muted)
                        }
                        Spacer(minLength: 0)
                    }
                }.padding(.horizontal, 8)
                HStack(spacing: 10) {
                    Button { bulkMode.toggle(); if !bulkMode { daysSelected = [] } } label: {
                        Label(bulkMode ? "ยกเลิกเลือก" : "เลือกหลายวัน", systemImage: "checkmark.circle")
                            .font(.subheadline.weight(.semibold)).frame(maxWidth: .infinity).padding(.vertical, 14)
                    }.buttonStyle(.bordered).tint(Palette.blue)
                    Button { showCopyOptions = true } label: {
                        Label("คัดลอกเวร", systemImage: "doc.on.doc")
                            .font(.subheadline.weight(.semibold)).frame(maxWidth: .infinity).padding(.vertical, 14)
                    }.buttonStyle(.bordered).tint(Palette.blue)
                }
                if bulkMode {
                    Button {
                        editorDays = daysSelected.sorted()
                    } label: {
                        Text("ลงเวรพร้อมกัน (\(daysSelected.count) วัน)").font(.headline)
                            .frame(maxWidth: .infinity).padding(15).foregroundStyle(.white)
                            .background(Palette.blue, in: RoundedRectangle(cornerRadius: 14))
                    }.disabled(daysSelected.isEmpty)
                }
                let notes = store.records(inMonth: month).filter { !$0.note.isEmpty }
                if !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("บันทึกในเดือนนี้").font(.headline).foregroundStyle(Palette.ink)
                        ForEach(notes) { rec in
                            HStack(alignment: .top) {
                                Text(rec.day.suffix(2)).foregroundStyle(Palette.blue).font(.subheadline.weight(.bold))
                                Text(rec.note).foregroundStyle(Palette.muted).font(.subheadline)
                                Spacer()
                            }.padding(10).background(.white, in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }.padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 28)
        }
        .background(Palette.canvas)
        .toolbar { ToolbarItem(placement: .topBarTrailing) { Button { editorDays = [ScheduleMath.dayKey(Date())] } label: { Image(systemName: "plus.circle.fill") } } }
        .sheet(isPresented: Binding(get: { !editorDays.isEmpty }, set: { if !$0 { editorDays = []; bulkMode = false; daysSelected = [] } })) {
            EditShiftSheet(days: editorDays)
        }
        .confirmationDialog("คัดลอกเวร", isPresented: $showCopyOptions, titleVisibility: .visible) {
            Button("สัปดาห์ก่อน → สัปดาห์ปัจจุบัน") { store.copyPreviousWeek(to: Date()) }
            Button("เดือนก่อน → เดือนที่เปิดดู") { store.copyPreviousMonth(to: month) }
        } message: { Text("ระบบจะเขียนทับเฉพาะวันที่มีข้อมูลจากช่วงต้นทาง และสร้างจุดสำรองก่อนเปลี่ยน") }
    }
    private func stepMonth(_ offset: Int) { if let d = Calendar.current.date(byAdding: .month, value: offset, to: month) { month = d } }
}
