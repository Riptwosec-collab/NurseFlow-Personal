import SwiftUI

struct ReportsView: View {
    @EnvironmentObject private var store: ShiftStore
    @State private var month = Date()
    private var summary: (workDays: Int, shiftHours: Double, otHours: Double, allowance: Double, otPay: Double, total: Double) { store.monthlySummary(month) }
    private var byKind: [(ShiftKind, Int)] {
        store.kinds.map { k in (k, store.records(inMonth: month).filter { $0.kindID == k.id }.count) }.filter { $0.1 > 0 }
    }
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                ScreenTitle(title: "รายงานเวร", subtitle: "ชั่วโมงงาน · ค่าเวร · รายได้จาก OT")
                HStack {
                    Button { month = Calendar.current.date(byAdding: .month, value: -1, to: month) ?? month } label: { Image(systemName:"chevron.left") }
                    Spacer()
                    Text(month.formatted(.dateTime.month(.wide).year())).font(.headline).foregroundStyle(Palette.ink)
                    Spacer()
                    Button { month = Calendar.current.date(byAdding: .month, value: 1, to: month) ?? month } label: { Image(systemName:"chevron.right") }
                }.padding(14).background(.white, in: RoundedRectangle(cornerRadius: 16))
                PastelCard(background: Color(hex: "#EBF3FF")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("รายได้รวมจากค่าเวรและ OT (ประมาณการ)").font(.subheadline).foregroundStyle(Palette.muted)
                        Text(summary.total, format: .currency(code: "THB")).font(.system(size: 30, weight: .bold, design: .rounded)).foregroundStyle(Palette.ink).minimumScaleFactor(0.7)
                        Text("ไม่รวมเงินเดือนหรือรายการอื่นที่ไม่ได้กำหนด").font(.caption).foregroundStyle(Palette.muted)
                    }
                }
                HStack(spacing: 10) {
                    metric("วันทำงาน", "\(summary.workDays)", tint: Color(hex: "#FFEBF1"))
                    metric("ชั่วโมงเวร", String(format:"%.1f",summary.shiftHours), tint: Palette.mint)
                    metric("OT ชั่วโมง", String(format:"%.1f",summary.otHours), tint: Palette.violet)
                }
                PastelCard {
                    VStack(spacing: 13) {
                        breakdown("ค่าเวร", amount: summary.allowance)
                        breakdown("ค่าล่วงเวลา", amount: summary.otPay)
                        Divider()
                        breakdown("รายได้รวม", amount: summary.total, bold: true)
                    }
                }
                PastelCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("สัดส่วนประเภทเวร").font(.headline).foregroundStyle(Palette.ink)
                        if byKind.isEmpty { Text("ยังไม่มีเวรในเดือนนี้").font(.subheadline).foregroundStyle(Palette.muted) }
                        ForEach(byKind.indices, id: \.self) { index in
                            let (kind, count) = byKind[index]
                            HStack {
                                ShiftPill(kind: kind)
                                Text(kind.title).font(.subheadline).foregroundStyle(Palette.ink)
                                GeometryReader { g in
                                    RoundedRectangle(cornerRadius: 5).fill(Color(hex: kind.color))
                                        .frame(width: g.size.width * CGFloat(count) / CGFloat(max(1, byKind.map(\.1).max() ?? 1)))
                                }.frame(height: 10)
                                Text("\(count)").font(.caption.weight(.bold)).foregroundStyle(Palette.muted).frame(width: 25, alignment: .trailing)
                            }
                        }
                    }
                }
                if !store.warnings().isEmpty {
                    PastelCard(background: Palette.peach) {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("แจ้งเตือนเวลาพัก / เวรซ้อน", systemImage:"exclamationmark.triangle.fill").font(.headline).foregroundStyle(Palette.ink)
                            ForEach(store.warnings(), id: \.self) { Text($0).font(.caption).foregroundStyle(Palette.muted) }
                        }
                    }
                }
            }.padding(16).padding(.bottom, 24)
        }.background(Palette.canvas).navigationBarHidden(true)
    }
    private func breakdown(_ label: String, amount: Double, bold: Bool = false) -> some View {
        HStack {
            Text(label).foregroundStyle(Palette.ink).font(bold ? .headline : .subheadline)
            Spacer()
            Text(amount, format: .currency(code:"THB")).foregroundStyle(Palette.ink).font(bold ? .headline : .subheadline)
        }
    }
    private func metric(_ label: String, _ val: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(val).font(.system(size: 24, weight: .bold, design: .rounded)).foregroundStyle(Palette.ink)
            Text(label).font(.caption2).foregroundStyle(Palette.muted).lineLimit(1).minimumScaleFactor(0.75)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(12).background(tint, in: RoundedRectangle(cornerRadius: 17))
    }
}
