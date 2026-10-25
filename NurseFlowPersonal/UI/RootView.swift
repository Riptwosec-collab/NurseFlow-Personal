import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: ShiftStore
    @State private var selected = 0
    @State private var showAdd = false
    var body: some View {
        TabView(selection: $selected) {
            NavigationStack { DashboardView(showAdd: $showAdd) }.tabItem { Label("วันนี้", systemImage: "house.fill") }.tag(0)
            NavigationStack { CalendarScreen(showAdd: $showAdd) }.tabItem { Label("ตารางเวร", systemImage: "calendar") }.tag(1)
            NavigationStack { ReportsView() }.tabItem { Label("สถิติ", systemImage: "chart.bar.fill") }.tag(2)
            NavigationStack { SettingsScreen() }.tabItem { Label("ตั้งค่า", systemImage: "gearshape.fill") }.tag(3)
        }
        .background(Palette.canvas)
        .sheet(isPresented: $showAdd) { EditShiftSheet(days: [ScheduleMath.dayKey(Date())]) }
        .alert("NurseFlow", isPresented: Binding(get: { store.lastError != nil }, set: { if !$0 { store.lastError = nil } })) {
            Button("รับทราบ", role: .cancel) { store.lastError = nil }
        } message: { Text(store.lastError ?? "") }
    }
}
