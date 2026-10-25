import SwiftUI

struct EditShiftSheet: View {
    @EnvironmentObject private var store: ShiftStore
    @Environment(\.dismiss) private var dismiss
    let days: [String]
    @State private var chosen = "D"
    @State private var overtime = 0
    @State private var note = ""
    @State private var showDelete = false

    private var oneDay: Bool { days.count == 1 }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(oneDay ? (days.first ?? "") : "เลือกแล้ว \(days.count) วัน")
                        .font(.title2.weight(.bold)).foregroundStyle(Palette.ink)
                    Text("ประเภทเวร").font(.headline).foregroundStyle(Palette.ink)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(store.kinds) { kind in
                            Button { chosen = kind.id } label: {
                                HStack(spacing: 8) {
                                    ShiftPill(kind: kind)
                                    Text(kind.title).font(.subheadline).lineLimit(1).minimumScaleFactor(0.8)
                                    Spacer(minLength: 0)
                                }.foregroundStyle(Palette.ink).padding(12).frame(maxWidth: .infinity)
                                    .background(Color(hex: kind.color), in: RoundedRectangle(cornerRadius: 14))
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(chosen == kind.id ? Palette.blue : .clear, lineWidth: 2.5))
                            }.buttonStyle(.plain)
                        }
                    }
                    if store.kind(for: chosen)?.isWork == true {
                        PastelCard(background: Color(hex: "#F4F7FF")) {
                            VStack(spacing: 14) {
                                HStack {
                                    Label("OT เพิ่มเติม", systemImage: "clock").font(.headline).foregroundStyle(Palette.ink)
                                    Spacer()
                                    Text("\(Double(overtime)/60, specifier: "%.1f") ชม.").foregroundStyle(Palette.blue)
                                }
                                Stepper("เพิ่ม/ลดครั้งละ 30 นาที", value: $overtime, in: 0...720, step: 30)
                                    .font(.subheadline).foregroundStyle(Palette.muted)
                                Text("OT นับแยกจากชั่วโมงกะปกติ").font(.caption).foregroundStyle(Palette.muted)
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("หมายเหตุ").font(.headline).foregroundStyle(Palette.ink)
                        TextField("เช่น ICU, OT เพิ่ม, แลกเวร", text: $note, axis: .vertical)
                            .lineLimit(2...5).textInputAutocapitalization(.sentences)
                            .padding(14).background(.white, in: RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Palette.border))
                    }
                    Button {
                        store.upsert(days: days, kindID: chosen, otMinutes: store.kind(for: chosen)?.isWork == true ? overtime : 0, note: note)
                        dismiss()
                    } label: {
                        Text("บันทึกเวร").frame(maxWidth: .infinity).padding(.vertical, 15).font(.headline)
                    }.buttonStyle(.borderedProminent).tint(Palette.blue)
                    if oneDay && store.record(on: days[0]) != nil {
                        Button("ลบเวรวันนี้", role: .destructive) { showDelete = true }.frame(maxWidth: .infinity)
                    }
                }.padding(18)
            }.background(Palette.canvas)
                .navigationTitle("เพิ่ม / แก้ไขเวร").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("ปิด") { dismiss() } } }
        }.presentationDetents([.large]).presentationDragIndicator(.visible)
            .onAppear {
                if oneDay, let rec = store.record(on: days[0]) { chosen = rec.kindID; overtime = rec.overtimeMinutes; note = rec.note }
            }
            .confirmationDialog("ลบข้อมูลเวรวันที่เลือก?", isPresented: $showDelete) {
                Button("ลบเวร", role: .destructive) { store.remove(day: days[0]); dismiss() }
            }
    }
}
