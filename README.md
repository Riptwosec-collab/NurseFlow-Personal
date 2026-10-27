## v0.9 — Editable presets / Dark mode (27 October 2026)

- Edit saved preset name, code, schedule times, overtime type/hours, break duration and extra pay in a separate inline editor. No existing dated shift changes until that preset is explicitly reapplied and saved.
- Night pastel theme accessible from a top-bar moon/sun toggle, persisted locally across browser reloads; default is light.
- Theme applies to calendars, forms, statistics, Supabase account panel and shift editor. TH/EN preserved.
- Existing local data key, backup schema and Supabase synchronization unchanged. Theme preference remains local to the device.

## v0.8 — แตะวันที่เปิดฟอร์ม / Presets

- แตะวันที่ในปฏิทินเปิดฟอร์มแก้ไขเวรทันทีโดยไม่ต้องกดปุ่มเพิ่มซ้ำ
- มีพรีเซตตามรหัสเวรเดิมและพรีเซตส่วนตัว บันทึกชื่อ เวลา OT และค่าเพิ่มพิเศษได้สูงสุด 12 รายการ
- การเลือกพรีเซตเพียงเติมฟอร์ม ยังไม่เขียนเวรลงวันที่จนกดบันทึกเวร
- พรีเซตเก็บใน settings ของข้อมูลเดิม จึงรวมอยู่ใน JSON Backup และ Supabase snapshot; ไม่เปลี่ยน schema ฐานข้อมูล
- TH/EN รองรับข้อความใหม่และยังคงพื้นที่จอ iPhone

## v0.5 — Pastel Pop visual refresh (26 Oct 2026)

- Light pastel visual polish across Dashboard, Calendar, statistics, settings and shift editor.
- Improved contrast, card hierarchy, icon badges, tap states, and soft decorative accents.
- On desktop, the app remains in the 402px iPhone-like frame; on iPhone it fills the screen.
- Fixed the shift-code editor's desktop-browser overflow in phone preview mode.
- All scheduling data models, localStorage keys and backup format remain unchanged.
- Added `pastel-polish.css` as the final cascade layer, and advanced the PWA cache to v0.5.

# NurseFlow Personal v0.3 — เว็บแอปขนาด iPhone เท่านั้น

เปิดผ่านเว็บเบราว์เซอร์ได้ แต่ UI ใช้ขนาดโทรศัพท์ตลอด: บน iPhone เต็มหน้าจอ; บนคอมพิวเตอร์และแท็บเล็ตแสดงคอลัมน์กว้างไม่เกิน **430 CSS px** ตรงกลางโดยไม่สลับเป็น Desktop Dashboard. ธีม White × Minimal × Pastel และข้อมูล Local เดิมยังใช้ได้. เวอร์ชัน Native SwiftUI ถูกเก็บไว้ใน branch `archive/native-ios-v1.0` และเวอร์ชัน PWA ก่อนปรับโทรศัพท์อยู่ `archive/pwa-v0.2.1`.

# NurseFlow Personal v0.2 — Minimal White × Pastel

แอป PWA จัดตารางเวรพยาบาลส่วนตัว ใช้ต่อจากข้อมูลเดิม v0.1 (`localStorage` key `nurseflow-personal-v1`) โดยคงสีขาวและพาสเทล รองรับมือถือ / Desktop. ไม่ต้องสมัครสมาชิกสำหรับโหมด Local.

## ฟีเจอร์ในเวอร์ชันนี้

1. **เพิ่มเวรหลายวัน** — เลือกช่วงวันที่ 1–366 วัน, กรองวันในสัปดาห์, ใส่เวรเดียวหรือวนแพตเทิร์น (เช่น `M,M,E,N,OFF,OFF`), ค่าเริ่มต้นข้ามวันที่มีเวรเดิมแล้ว
2. **คัดลอกเวร** — คัดลอก 7 วัน หรือคัดลอกเดือนก่อนหน้าให้ตรงตามเลขวันที่เดือนใหม่; ตรวจความเสี่ยงเวลาพักก่อนยืนยัน
3. **รหัสเวรเอง** — เพิ่มตัวอย่าง `D1 D2 D3 D4 N1 N2` และแก้ชื่อ/เวลา/ค่าเวรได้; รองรับรหัสอังกฤษ 1–8 ตัว รวมสูงสุด 24 แบบ
4. **OT รายวัน** — เลือก OT แบบต่อท้ายกะ (บวกชั่วโมงเพิ่ม) หรือ OT ภายในกะ (ไม่นับชั่วโมงซ้ำ), เวลาพักภายในกะ และเงินพิเศษรายวัน
5. **การตรวจเวรซ้อนและเวลาพัก** — คิดช่วงเวรข้ามเที่ยงคืนได้, แจ้งเตือนและถามยืนยันก่อนบันทึกเมื่อช่วงเวลาพักต่ำกว่าเกณฑ์ที่กำหนด
6. **Dashboard / เวรถัดไป** — แยกเวรที่กำลังทำอยู่กับเวรถัดไป, สรุปจำนวนวัน ชั่วโมงปกติ OT รายได้ประมาณการ และข้อเตือนเวลาพัก
7. **นำเข้าตารางเวร** — CSV, XLSX / XLS และรูป JPG/PNG/WEBP แบบ OCR แล้วแสดงตัวอย่างให้แก้วันที่/รหัส/เวลา/OT เลือกแถวก่อนยืนยัน; ไม่เขียนทับของเดิมโดยค่าเริ่มต้น
8. **รายงานรายได้** — เงินเดือนฐานถ้าระบุ, ค่าเวรตามรหัส, ค่า OT, เงินพิเศษรายวัน/รายเดือน, ตารางรายวัน, ส่งออก CSV
9. **Auto Backup ในเครื่อง** — บันทึก Recovery Point ใน IndexedDB โดยอัตโนมัติหลังมีการแก้ไขข้อมูล (สูงสุด 10 จุด), มีหน้ากู้คืนก่อนย้อนข้อมูล; ยังควรดาวน์โหลด JSON เป็นระยะ
10. **Cloud Sync แบบเข้ารหัส (เลือกเปิดใช้เอง)** — มีโค้ด Backend Cloudflare Workers + D1 แยกมาในโฟลเดอร์ `cloudflare-sync/`; ต้อง Deploy เองก่อนใช้งาน, ฝั่ง Browser เข้ารหัส AES-256-GCM ด้วย PBKDF2-SHA256, เซิร์ฟเวอร์เก็บ ciphertext ไม่เห็นตารางเวรจริง
11. **แจ้งเตือน** — Notification API เมื่อแอปเปิดอยู่และผู้ใช้อนุญาต (ต้องใช้ HTTPS/localhost); export ICS เพื่อนำเข้าแอปปฏิทินที่รองรับแจ้งเตือนระหว่างปิด NurseFlow

## การติดตั้ง / เปิดใช้งาน

### บนคอมพิวเตอร์

แตก ZIP แล้วรันในโฟลเดอร์ที่มี `index.html`:

```bash
python -m http.server 8080
```

เปิด `http://localhost:8080`. เปิดไฟล์ Standalone HTML โดยตรงก็ได้สำหรับโหมด Local (ไม่ติดตั้ง PWA / ไม่ทำงานออฟไลน์ผ่าน service worker).

### บน iPhone / Android

นำไฟล์ของแอป (ไม่จำเป็นต้องนำโฟลเดอร์ tests หรือ cloudflare-sync ขึ้นเว็บ) ไปโฮสต์บน HTTPS เช่น Cloudflare Pages. จาก iPhone Safari: แชร์ → เพิ่มไปยังหน้าจอโฮม → เปิดเป็นเว็บแอป. Android Chrome: Install app.

### โหมด Cloud

ดู `cloudflare-sync/README.md`. จะต้องมีบัญชี Cloudflare, D1 database ID และ Worker URL จริงก่อน ซิงก์จะยังทำงานไม่ได้เมื่อไม่มี Backend. การดึงข้อมูลจาก Cloud ต้องยืนยันก่อนเขียนทับ และมีระบบ version/revision ปฏิเสธการอัปโหลดเมื่อมีข้อมูลใหม่จากอีกอุปกรณ์; ในกรณีขัดแย้งต้องดึงข้อมูลก่อนและตรวจความเปลี่ยนแปลงเอง (ยังไม่มี merge ระดับรายการ).

## รูปแบบไฟล์นำเข้าที่รองรับ

- CSV / Excel: คอลัมน์หัวตาราง `วันที่`, `รหัสเวร` (option: `เริ่ม`, `สิ้นสุด`, `OT ชั่วโมง`, `หมายเหตุ`)
- ตัวอย่าง:

```csv
วันที่,รหัสเวร,เริ่ม,สิ้นสุด,OT ชั่วโมง,หมายเหตุ
2026-10-26,M,07:00,15:00,0,ประจำ ICU
2026-10-27,N,23:00,07:00,2,เวรดึก
```

- รูปภาพ: OCR รองรับบรรทัดตรงไปตรงมาเช่น `26/10/2026 N` หรือ `27 OFF` (วันล้วนใช้เดือนที่เปิดอยู่); ตารางแบบกริดที่ซับซ้อนหรือภาพไม่ชัดอาจอ่านไม่ออกหรือคลาดเคลื่อน ผู้ใช้ต้องตรวจและแก้ผลก่อนบันทึก
- `.xlsx` ต้องดาวน์โหลด SheetJS 0.20.3 ในครั้งที่ใช้งาน, ภาพใช้ Tesseract.js 5.1.1 พร้อมไฟล์โมเดลภาษาไทย/อังกฤษครั้งแรก (ต้องออนไลน์). CSV รองรับขณะออฟไลน์
- **หมายเหตุความเป็นส่วนตัว:** การประมวลผล OCR ทำในเบราว์เซอร์โดยไลบรารี Tesseract.js และอาจดาวน์โหลดภาษาจาก CDN ไม่ใช่ API วิเคราะห์รูปบนเซิร์ฟเวอร์ของแอป; อย่านำเข้าภาพที่มีข้อมูลผู้ป่วย/ข้อมูลอ่อนไหวโดยไม่ตัดส่วนเหล่านั้นออก

## นิยามชั่วโมงและค่าตอบแทน

- เวร 23:00–07:00 = 8 ชม. (ระบบรู้ว่าข้ามเที่ยงคืน)
- ชั่วโมงกะสุทธิ = เวลาสิ้นสุด − เริ่ม − พักภายในกะ
- OT **ต่อท้ายกะ** = ชั่วโมงสุทธิ + OT (เพิ่มจากกะ)
- OT **ภายในกะ** = ชั่วโมงปกติ `(สุทธิ − OT)` + OT (ไม่เพิ่มชั่วโมงรวม)
- รายได้ = เงินเดือนฐาน + ค่าตอบแทนรายกะ + OT × ค่า OT/ชม. + เงินเพิ่มรายวัน + รายได้อื่นรายเดือน. ไม่มีคำนวณภาษี ประกันสังคม การหักเงิน หรือกฎค่าจ้างตามกฎหมายอัตโนมัติ

## ข้อจำกัดและความปลอดภัย

- 1 รหัสเวรหลักต่อวัน; OT แยกอยู่ในวันเดียวกัน. ยังไม่รองรับหลายกะอิสระในวันเดียว
- การเตือนผ่าน Notification API ทำงานได้ **เมื่อเปิดแอปอยู่เท่านั้น**, ไม่ใช่ Push Notification ตอนปิดแอป. การเตือนตอนปิดแอปใช้ไฟล์ `.ics` ในแอปปฏิทินแทน
- ข้อมูล Local อยู่ใน browser storage และ IndexedDB; ล้าง Site Data อาจทำข้อมูลและจุดสำรองในเครื่องหายพร้อมกัน; ควร export JSON หรือเปิด Cloud Sync ของตัวเอง
- Cloud token เก็บใน LocalStorage เพื่อใช้ auto upload **เฉพาะตอนเปิดแอปอยู่**; Encryption passphrase เก็บในหน่วยความจำเท่านั้นและต้องกรอกใหม่เมื่อรีเฟรช/เปิดใหม่. หากลืม Token + Passphrase จะกู้ข้อมูล Cloud ไม่ได้
- เว็บแอปนี้ออกแบบเป็นเครื่องมือจัดตารางส่วนตัว ไม่ใช่โปรแกรมข้อมูลผู้ป่วยหรือระบบตัดสินใจด้านความปลอดภัยของผู้ป่วย

## QA ที่ทำไปแล้ว

- `node --check app.js` — ผ่าน
- `node tests/test_logic.js` — ผ่าน 11 กรณี: OT 2 แบบ, เวรดึกข้ามวัน/เวลาพัก, รหัสเวรเอง, CSV และ OCR Parser, พ.ศ./ค.ศ., รายงานเดือน, หน้า UI render เป็น HTML, AES-GCM round-trip
- `node tests/test_worker.mjs` — ผ่าน: PUT/GET/optimistic conflict 409/unauthorized 403 จากฐานข้อมูลจำลอง
- **ยังไม่ได้ตรวจ Visual QA จริงบน Chromium ใน runtime รอบนี้**: เบราว์เซอร์ปฏิเสธการเปิด localhost และ file ด้วย `ERR_BLOCKED_BY_ADMINISTRATOR` จึงยังไม่รับรองการคลิกบนอุปกรณ์จริง, ความสวย/การวางตำแหน่งทุก breakpoint, หรือการเชื่อมต่อ CDN และ Cloudflare หลัง Deploy. ควรทำ Manual QA ก่อนใช้เป็นแอปหลัก

## แหล่งอ้างอิงเทคนิค

- Cloudflare D1 bindings: https://developers.cloudflare.com/d1/get-started/
- SheetJS browser standalone: https://docs.sheetjs.com/docs/getting-started/installation/standalone/
- Tesseract.js: https://github.com/naptha/tesseract.js

## iPhone PWA layout patch v0.2.1
- New `iphone-pwa.css` preserves White / Minimal / Pastel, loaded after existing `styles.css`.
- Optimized for iPhone 16 Pro ~402×874 CSS px in portrait, 320/375/390 px phones and landscape at 874×402; tablet up to 900 px uses bottom navigation.
- Fixed header and bottom nav honor the safe-area inset on all four sides, and page content leaves room below for navigation plus the Home indicator.
- Calendar remains seven columns without horizontal overflow; forms use 16px inputs to prevent iOS automatic zoom and modals use a full-width bottom sheet.
- `service-worker.js` caches the new stylesheet with a new `nurseflow-personal-v021` cache key. Publish all files together to Cloudflare Pages.
- QA: 6 Chromium simulated viewports, 4 sections, add-shift modal and no horizontal overflow or JavaScript exceptions. Actual Safari standalone mode still needs an on-device smoke test.
- Install on iPhone: open HTTPS page in Safari -> Share -> Add to Home Screen -> Open as Web App. If an old install is stale, reload or re-add the Home Screen shortcut.
