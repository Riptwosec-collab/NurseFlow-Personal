import SwiftUI
import UniformTypeIdentifiers
import PhotosUI
import UIKit

struct ShareFile: Identifiable { let id = UUID(); let url: URL }
struct NativeShareSheet: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> UIActivityViewController { UIActivityViewController(activityItems: [url], applicationActivities: nil) }
    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}

struct SettingsScreen: View {
    @EnvironmentObject private var store: ShiftStore
    @State private var showingFilePicker = false
    @State private var share: ShareFile?
    @State private var editKind: ShiftKind?
    @State private var selection: PhotosPickerItem?
    @State private var extractedRows: [ShiftRecord] = []
    @State private var recognizedRaw = ""
    @State private var showImportConfirm = false
    @State private var importMessage: String?
    @State private var showRestoreConfirmation = false
    @State private var pendingRestore: Data?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                ScreenTitle(title: "ตั้งค่า", subtitle: "ตั้งค่าเวรส่วนตัว • ทำงานแบบ Offline")
                PastelCard(background: Color(hex:"#EBF4FF")) {
                    VStack(alignment: .leading, spacing: 7) {
                        Label("iPhone Native App", systemImage:"iphone.gen3").font(.headline).foregroundStyle(Palette.ink)
                        Text("ไม่ใช้เว็บไซต์ · ไม่ต้องเชื่อม Cloudflare · เก็บข้อมูลในเครื่อง").font(.subheadline).foregroundStyle(Palette.muted)
                    }
                }
                settingsBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ค่าเวร / รายได้").font(.headline).foregroundStyle(Palette.ink)
                        HStack {
                            Text("ค่า OT ต่อชั่วโมง (บาท)").font(.subheadline).foregroundStyle(Palette.muted)
                            Spacer()
                            TextField("0", value: Binding(get: { store.settings.overtimeHourlyRate }, set: { v in changeSettings { $0.overtimeHourlyRate = max(0,v) } }), format: .number)
                                .keyboardType(.decimalPad).multilineTextAlignment(.trailing).frame(width: 100)
                        }
                        Divider()
                        HStack {
                            Text("ตัวคูณ OT").font(.subheadline).foregroundStyle(Palette.muted)
                            Spacer()
                            TextField("1", value: Binding(get: { store.settings.overtimeMultiplier }, set: { v in changeSettings { $0.overtimeMultiplier = max(0,v) } }), format: .number)
                                .keyboardType(.decimalPad).multilineTextAlignment(.trailing).frame(width: 65)
                        }
                        Divider()
                        HStack {
                            Text("พักระหว่างเวรขั้นต่ำ").font(.subheadline).foregroundStyle(Palette.muted)
                            Spacer()
                            TextField("11", value: Binding(get: { store.settings.minimumRestHours }, set: { v in changeSettings { $0.minimumRestHours = max(0,v) } }), format: .number)
                                .keyboardType(.decimalPad).multilineTextAlignment(.trailing).frame(width: 65)
                            Text("ชม.").font(.caption).foregroundStyle(Palette.muted)
                        }
                    }
                }
                settingsBox {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("รหัสเวรส่วนตัว").font(.headline).foregroundStyle(Palette.ink)
                            Spacer()
                            Button { editKind = ShiftKind(id:UUID().uuidString, code:"D1", title:"รหัสใหม่", color:"#E5EEFF", startMinute:7*60, durationMinutes:8*60) } label: { Label("เพิ่ม", systemImage:"plus") }.font(.subheadline)
                        }
                        ForEach(store.kinds) { kind in
                            Button { editKind = kind } label: {
                                HStack(spacing: 10) {
                                    ShiftPill(kind: kind)
                                    Text(kind.title).font(.subheadline).foregroundStyle(Palette.ink)
                                    Spacer()
                                    Text(kind.isWork ? "\(kind.durationMinutes/60) ชม." : "หยุด").font(.caption).foregroundStyle(Palette.muted)
                                    Image(systemName:"chevron.right").font(.caption).foregroundStyle(Palette.muted)
                                }
                            }.buttonStyle(.plain)
                            if kind.id != store.kinds.last?.id { Divider() }
                        }
                    }
                }
                settingsBox {
                    VStack(alignment: .leading, spacing: 14) {
                        Label("การแจ้งเตือนใน iPhone", systemImage:"bell.badge").font(.headline).foregroundStyle(Palette.ink)
                        Toggle("เตือนก่อนเข้าเวร", isOn: Binding(get: { store.settings.notifyEnabled }, set: { enabled in
                            if enabled { Task { if await ReminderService.requestAccess() { changeSettings { $0.notifyEnabled = true } } else { importMessage = "ต้องอนุญาตการแจ้งเตือนที่ Settings > NurseFlow" } } }
                            else { changeSettings { $0.notifyEnabled = false } }
                        })).tint(Palette.blue)
                        Picker("แจ้งเตือนก่อน", selection: Binding(get: { store.settings.notificationLeadMinutes }, set: { val in changeSettings { $0.notificationLeadMinutes = val } })) {
                            Text("30 นาที").tag(30); Text("1 ชั่วโมง").tag(60); Text("3 ชั่วโมง").tag(180); Text("6 ชั่วโมง").tag(360)
                        }.font(.subheadline)
                        Text("แจ้งเตือนแบบ Local Notification โดย iOS ไม่ใช้เซิร์ฟเวอร์").font(.caption).foregroundStyle(Palette.muted)
                    }
                }
                settingsBox {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("นำเข้า / ส่งออก / สำรองข้อมูล").font(.headline).foregroundStyle(Palette.ink)
                        action("นำเข้า CSV หรือ JSON", icon:"square.and.arrow.down") { showingFilePicker = true }
                        PhotosPicker(selection: $selection, matching: .images) {
                            Label("อ่านตารางเวรจากรูปภาพ (OCR)", systemImage:"photo.on.rectangle.angled")
                                .font(.subheadline).foregroundStyle(Palette.blue)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Text("นำเข้าจาก Excel: บันทึกเป็น CSV ก่อน แล้วเลือกไฟล์จาก iPhone").font(.caption).foregroundStyle(Palette.muted)
                        Divider()
                        action("สำรองข้อมูล JSON", icon:"externaldrive.badge.plus") { if let url = store.exportJSON() { share = ShareFile(url:url) } }
                        action("ส่งออก CSV", icon:"tablecells") { if let url = store.exportCSV() { share = ShareFile(url:url) } }
                        action("ส่งออก iPhone Calendar (.ics)", icon:"calendar.badge.plus") { if let url = store.exportICS() { share = ShareFile(url:url) } }
                        Text("จัดเก็บในเครื่องอัตโนมัติ และสร้างจุดกู้คืนก่อนนำเข้าหรือคัดลอกเวร").font(.caption).foregroundStyle(Palette.muted)
                    }
                }
                Text("NurseFlow Personal · Native iOS v1.0 • iPhone only")
                    .font(.caption).foregroundStyle(Palette.muted).frame(maxWidth:.infinity).padding(.top,8)
            }.padding(16).padding(.bottom, 30)
        }
        .background(Palette.canvas).navigationBarHidden(true)
        .sheet(item:$editKind) { KindEditor(kind:$0) }
        .sheet(item:$share) { NativeShareSheet(url:$0.url) }
        .fileImporter(isPresented:$showingFilePicker, allowedContentTypes:[.json,.commaSeparatedText,.plainText], allowsMultipleSelection:false) { result in
            do {
                guard let url = try result.get().first else { return }
                let scoped = url.startAccessingSecurityScopedResource()
                defer { if scoped { url.stopAccessingSecurityScopedResource() } }
                let data = try Data(contentsOf:url)
                if url.pathExtension.lowercased() == "json" { pendingRestore = data; showRestoreConfirmation = true }
                else { let count = try store.importCSV(String(decoding:data,as:UTF8.self)); importMessage = "นำเข้าสำเร็จ \(count) วัน" }
            } catch { importMessage = "นำเข้าไม่สำเร็จ: \(error.localizedDescription)" }
        }
        .confirmationDialog("กู้คืนข้อมูลจาก JSON?", isPresented:$showRestoreConfirmation) {
            Button("แทนที่ข้อมูลในเครื่อง", role:.destructive) {
                if let data = pendingRestore { do { try store.importJSON(data); importMessage = "กู้คืนข้อมูลสำเร็จ" } catch { importMessage = error.localizedDescription } }
                pendingRestore = nil
            }
        } message: { Text("ระบบจะเก็บสำรองปัจจุบันก่อนแทนที่") }
        .onChange(of:selection) { _, value in
            guard let value else { return }
            Task {
                do {
                    guard let data = try await value.loadTransferable(type:Data.self), let image = UIImage(data:data) else { return }
                    let lines = try await Task.detached(priority:.userInitiated) { try ImportService.readPhoto(image) }.value
                    recognizedRaw = lines.joined(separator:"\n")
                    extractedRows = ImportService.parseRecognizedText(lines, kinds:store.kinds)
                    showImportConfirm = true
                } catch { importMessage = "อ่านรูปภาพไม่สำเร็จ: \(error.localizedDescription)" }
            }
        }
        .sheet(isPresented:$showImportConfirm) {
            NavigationStack {
                ScrollView {
                    VStack(alignment:.leading,spacing:15) {
                        Text("ระบบ OCR อ่านได้ \(extractedRows.count) วันที่ — ตรวจสอบก่อนนำเข้า")
                            .font(.headline).foregroundStyle(Palette.ink)
                        ForEach(extractedRows) { row in
                            Text("\(row.day) • \(store.kind(for: row.kindID)?.code ?? row.kindID)")
                                .font(.subheadline).foregroundStyle(Palette.ink)
                        }
                        if extractedRows.isEmpty { Text("ไม่พบรูปแบบวันที่ + รหัสเวรที่รองรับ กรุณาใช้ CSV หรือลงเวรด้วยตนเอง").foregroundStyle(Palette.muted) }
                        Text("ข้อความที่อ่านจากรูป").font(.subheadline.weight(.bold))
                        Text(recognizedRaw).font(.caption).foregroundStyle(Palette.muted)
                        Button("ยืนยันนำเข้า \(extractedRows.count) วัน") { store.importPhotoRows(extractedRows); showImportConfirm = false; selection = nil }
                            .disabled(extractedRows.isEmpty).buttonStyle(.borderedProminent)
                    }.padding(20)
                }.navigationTitle("ตรวจสอบ OCR").navigationBarTitleDisplayMode(.inline)
                    .toolbar { ToolbarItem(placement:.topBarTrailing) { Button("ปิด") { showImportConfirm = false; selection = nil } } }
            }
        }
        .alert("NurseFlow", isPresented:Binding(get:{ importMessage != nil },set:{ if !$0 { importMessage = nil } })) {
            Button("ตกลง") { importMessage = nil }
        } message: { Text(importMessage ?? "") }
    }
    private func changeSettings(_ change: (inout NurseSettings)->Void) { var tmp = store.settings; change(&tmp); store.updateSettings(tmp) }
    private func action(_ title:String, icon:String, action:@escaping ()->Void)->some View {
        Button(action:action) { Label(title,systemImage:icon).font(.subheadline).frame(maxWidth:.infinity,alignment:.leading) }
    }
    private func settingsBox<Content:View>(@ViewBuilder content:()->Content)->some View { PastelCard { content() } }
}

struct KindEditor: View {
    @EnvironmentObject private var store: ShiftStore
    @Environment(\.dismiss) private var dismiss
    @State private var kind: ShiftKind
    init(kind: ShiftKind) { _kind = State(initialValue:kind) }
    private let colors = ["#DDEBFF", "#FFE3EE", "#E9E2FF", "#DFF5E9", "#FFF1D6", "#E3F6F5"]
    var body: some View {
        NavigationStack {
            Form {
                Section("รหัสเวร") {
                    TextField("รหัส เช่น D1, N2", text:$kind.code)
                    TextField("ชื่อเวร", text:$kind.title)
                    Toggle("นับเป็นวันทำงาน",isOn:$kind.isWork)
                }
                if kind.isWork {
                    Section("เวลาและค่าตอบแทน") {
                        Stepper("เริ่ม: \(String(format:"%02d:%02d",kind.startMinute/60,kind.startMinute%60))", value:$kind.startMinute,in:0...1410,step:30)
                        Stepper("ระยะเวลา: \(kind.durationMinutes/60) ชม.",value:$kind.durationMinutes,in:60...1440,step:60)
                        HStack {
                            Text("ค่าเวร (บาท)")
                            Spacer()
                            TextField("0",value:$kind.allowance,format:.number).keyboardType(.decimalPad).multilineTextAlignment(.trailing).frame(width:110)
                        }
                    }
                }
                Section("สีพาสเทล") {
                    HStack {
                        ForEach(colors,id:\.self) { color in
                            Button { kind.color = color } label: {
                                Circle().fill(Color(hex:color)).frame(width:32,height:32)
                                    .overlay(Circle().stroke(kind.color == color ? Palette.blue : .clear,lineWidth:3))
                            }.buttonStyle(.plain)
                        }
                    }
                }
                Section {
                    Button("บันทึกรหัสเวร") {
                        kind.code = String(kind.code.prefix(8)).trimmingCharacters(in:.whitespaces)
                        guard !kind.code.isEmpty, !kind.title.isEmpty else { return }
                        store.updateKind(kind); dismiss()
                    }.frame(maxWidth:.infinity)
                    Button("ลบรหัสเวร",role:.destructive) { store.deleteKind(kind.id); dismiss() }
                        .disabled(store.records.contains { $0.kindID == kind.id })
                }
            }
            .navigationTitle("ตั้งค่ารหัสเวร").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement:.topBarTrailing) { Button("ปิด") { dismiss() } } }
        }
    }
}
