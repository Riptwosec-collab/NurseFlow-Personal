/* NurseFlow UI translation: keeps data values and shift codes unchanged. */
(()=>{'use strict';
const KEY='nurseflow-ui-language';let lang='th';try{lang=localStorage.getItem(KEY)==='en'?'en':'th'}catch{}
const map={
'พรีเซตเวร':'Shift presets','เลือกเวรได้ทันที':'Pick a shift','พรีเซตของฉัน':'My presets','บันทึกเป็นพรีเซต':'Save as preset','ชื่อพรีเซต':'Preset name','บันทึกพรีเซต':'Save preset','ลบพรีเซต':'Delete preset','ยังไม่มีพรีเซตที่บันทึก':'No saved presets','เลือกแล้วกดบันทึกเวรเพื่อยืนยัน':'Tap Save shift to confirm','แตะวันที่เพื่อเพิ่มหรือแก้ไขเวร':'Tap a date to add or edit','เวรเช้า + OT':'Day shift + OT','แก้ไขพรีเซต':'Edit preset','ประเภทเวร':'Shift type','เริ่ม':'Start','สิ้นสุด':'End','พัก (นาที)':'Break (min)','เงินเพิ่ม (บาท)':'Extra pay','ต่อท้ายกะ':'After shift','ภายในกะ':'Within shift','บันทึกพรีเซต':'Save preset','แก้ไขพรีเซตแล้ว':'Preset updated','สลับโหมดมืด':'Toggle dark mode','หน้าหลัก':'Home','ตารางเวร':'Schedule','สถิติ':'Reports','ตั้งค่า':'Settings','สถิติของฉัน':'Reports','พื้นที่ส่วนตัว':'Personal',
'สวัสดี คุณ':'Hello!','ตารางเวรของคุณ':'Your personal shift planner','ตารางเวรของฉัน':'My schedule',
'วันทำงาน':'Work days','เวรดึก':'Night shifts','เวลารวม':'Total hours','รายได้ประมาณการ':'Estimated pay',
'เดือนนี้':'This month','กะในเดือนนี้':'This month','รวม OT ไม่ซ้ำ':'OT counted once','ตามอัตราที่ตั้งไว้':'Based on your rates',
'7 วันข้างหน้า':'Next 7 days','ดูปฏิทิน':'Calendar','กำลังเข้าเวร':'On shift','เวรถัดไป':'Next shift',
'เข้าเวรอยู่ตอนนี้':'Currently on shift','กำลังจะมาถึง':'Upcoming','ภาพรวมและความปลอดภัย':'Overview','รายงาน':'Reports',
'ชั่วโมงปกติ':'Regular hours','วันหยุด':'Day off','วันลา':'Leave','ลา':'Leave','หยุด':'Off',
'เวรเช้า':'Day shift','เวรบ่าย':'Evening shift','ไม่พบเวลาพักต่ำกว่าเกณฑ์':'No rest warnings',
'ยังไม่พบเวรปัจจุบันหรือถัดไป':'No upcoming shifts','เพิ่มเวรในปฏิทินเพื่อเริ่มใช้งาน':'Add a shift to get started',
'ชม.':'hrs','ทั้งวัน':'All day','เลือกวัน แล้วลงเวรได้เลย':'Tap a date to add a shift',
'เพิ่มเวร':'Add shift','แก้ไขเวร':'Edit shift','เพิ่ม':'Add','แก้ไข':'Edit',
'วันหยุด / วันลา':'Off / Leave','ลงหลายวัน':'Bulk add','ลงเวรหลายวัน':'Bulk shifts',
'เครื่องมือเพิ่มเติม':'More tools','คัดลอกเวร':'Copy shifts','คัดลอกตาราง':'Copy schedule',
'นำเข้าไฟล์ / รูป':'Import file / photo','นำเข้าไฟล์/รูป':'Import file / photo',
'รายการเวรเดือนนี้':'Monthly shifts','รายการ':'entries','แสดงน้อยลง':'Show less',
'ยังไม่มีเวรในเดือนนี้':'No shifts this month','เริ่มเพิ่มเวรหรืออัปโหลดตารางของคุณ':'Add a shift or import your schedule',
'ยังไม่มีเวรที่บันทึกไว้':'No shift saved','ยังไม่มีเวร':'No shift','ปฏิทิน ICS':'Calendar ICS',
'รายละเอียดรายวัน':'Daily details','วันที่':'Date','ประเภทเวร':'Shift type','เวร':'Shift',
'ก่อนหน้า':'Previous','ถัดไป':'Next','เลือกวัน':'Choose days',
'สถิติและรายได้':'Stats & income','สรุปเวรและรายได้โดยประมาณ':'Monthly shifts and pay',
'OT รวม':'Total OT','ชั่วโมงทั้งหมด':'Total hours','รายได้รวมประมาณ':'Estimated income',
'หลังหักพัก / OT ภายในกะ':'After breaks','ปกติ + OT':'Regular + OT',
'รวมฐานเงินเดือนถ้าตั้งไว้':'Including base pay','แจกแจงรายได้เดือนนี้':'Income breakdown',
'เงินเดือนฐาน (ถ้ากรอก)':'Base salary','ค่าตอบแทนตามเวร':'Shift allowances',
'ค่าล่วงเวลา OT':'Overtime pay','รายได้เพิ่มเติมรายวัน':'Daily extra pay',
'รายได้พิเศษรายเดือน':'Monthly extra pay','รวมประมาณการ':'Estimated total',
'ส่งออกรายงาน CSV':'Export report CSV','จำนวนกะแต่ละแบบ':'Shift counts',
'กะ':'Shift','ปกติ':'Regular','ค่าเวร':'Allowance','ค่า OT':'OT pay','พิเศษ':'Extra','รวม':'Total',
'ตั้งค่าส่วนตัว':'Settings','ปรับเวรและข้อมูลของคุณ':'Shifts, pay & backup',
'ข้อมูลและอัตราค่าตอบแทน':'Profile & pay','ชื่อที่แสดง':'Display name','ชื่อเล่น':'Nickname',
'ค่า OT ต่อชั่วโมง (บาท)':'OT rate (THB/hr)','เวลาพักขั้นต่ำ (ชั่วโมง)':'Min rest (hrs)',
'เงินเดือนฐาน (ไม่จำเป็น)':'Base salary (optional)','รายได้พิเศษ/เดือน':'Extra monthly income',
'แจ้งเตือนในไฟล์ปฏิทิน (ICS)':'Calendar reminder (ICS)','ไม่เตือน':'Off',
'ก่อน 30 นาที':'30 minutes before','ก่อน 1 ชั่วโมง':'1 hour before','ก่อน 3 ชั่วโมง':'3 hours before',
'ก่อน 6 ชั่วโมง':'6 hours before','ก่อน 12 ชั่วโมง':'12 hours before',
'บันทึกการตั้งค่า':'Save settings','รหัสเวรของฉัน':'My shift codes',
'รหัส / ชื่อเวร / เริ่ม / สิ้นสุด / ค่าเวร':'Code / Label / Start / End / Pay',
'รหัสใหม่':'New code','ชื่อเวร':'Shift name','เพิ่มรหัสเวร':'Add shift code',
'บันทึกรหัสและเวลา':'Save shift codes','เริ่ม':'Start','สิ้นสุด':'End',
'เช่น D1':'e.g. D1','เช่น เวรเช้า D1':'e.g. Day shift D1',
'สำรองและนำเข้าข้อมูล':'Backup & import','สำรอง JSON':'Backup JSON','นำเข้า JSON':'Import JSON',
'รูป / Excel':'Photo / Excel','จุดสำรองในเครื่อง':'Recovery points',
'แจ้งเตือนก่อนเข้าเวร':'Shift reminders','เปิดการแจ้งเตือนเมื่อแอปเปิด':'Enable in-app alerts',
'จัดการข้อมูล':'Manage data','เพิ่มเวรตัวอย่าง':'Add sample shifts','ลบเวรตัวอย่าง':'Remove sample shifts',
'ลองเวรตัวอย่าง':'Try sample shifts','ล้างข้อมูลทั้งหมด':'Erase all data',
'ยังไม่ได้เชื่อม Cloud':'Cloud not connected','Cloud Sync (ตั้งค่าเอง)':'Cloud Sync (optional)',
'สร้าง Profile/Token':'Generate ID / token','บันทึกการเชื่อมต่อ':'Save connection',
'ดึงจาก Cloud':'Download from cloud','อัปโหลดขึ้น Cloud':'Upload to cloud',
'รหัสผ่านเข้ารหัส (เฉพาะเซสชัน)':'Encryption passphrase (session only)',
'อย่างน้อย 12 ตัวอักษร':'At least 12 characters',
'เพิ่มเวรหลายวัน':'Add multiple shifts','เวลาเริ่ม':'Start time','เวลาสิ้นสุด':'End time',
'วันเริ่ม':'Start date','วันสิ้นสุด':'End date','ถึงวันที่':'End date',
'เลือกช่วงวัน / วันในสัปดาห์ / แพตเทิร์นกะที่วนซ้ำ':'Choose dates or a repeating pattern',
'รูปแบบเวร':'Shift pattern','เวรเดียวทุกวันที่เลือก':'Same shift each day',
'วนแพตเทิร์น เช่น M,M,E,N,OFF':'Repeat pattern (M,M,E,N,OFF)',
'แพตเทิร์นรหัส คั่นด้วยจุลภาค':'Comma-separated shift codes',
'เลือกเฉพาะวัน':'Include weekdays','เขียนทับวันที่มีเวรแล้ว (ปกติจะข้าม)':'Overwrite existing shifts',
'บันทึกหลายวัน':'Save multiple days','คัดลอกทั้งสัปดาห์ หรือย้ายแพตเทิร์นเดือนก่อนหน้า':'Copy a week or previous month',
'รูปแบบ':'Mode','คัดลอก 7 วันจากวันเริ่มต้น':'Copy 7 days from start',
'คัดลอกเดือนก่อนมาตามเลขวันที่':'Copy previous month',
'วันเริ่มต้นต้นทาง (แบบสัปดาห์)':'Source start date',
'วันเริ่มต้นปลายทาง':'Destination start date',
'เขียนทับเวรที่มีอยู่แล้ว':'Overwrite existing shifts',
'ยกเลิก':'Cancel','บันทึก':'Save','บันทึกเวร':'Save shift','ลบ':'Delete',
'เลือกวัน แล้วบันทึกได้เลย':'Choose dates and save','ประเภทวัน':'Day type',
'แทนที่เวรเดิม (ถ้ามี)':'Replace existing shifts','แก้ไขได้ภายหลังทุกครั้ง':'You can edit this later',
'OT (ชั่วโมง)':'OT (hours)','รูปแบบ OT':'OT type','ต่อท้ายกะ (บวกเพิ่ม)':'After shift (extra hours)',
'ภายในกะ (ไม่บวกเพิ่ม)':'During shift (no double count)','เวลาพักระหว่างกะ (นาที)':'Break (minutes)',
'เงินเพิ่มพิเศษ (บาท)':'Extra pay (THB)','บันทึกข้อมูลในเครื่องส่วนตัว':'Saved privately on this device',
'นำเข้าตารางเวร':'Import schedule','ไฟล์ตารางเวร':'Schedule file','ปิด':'Close',
'ยืนยันนำเข้า':'Confirm import','ยังไม่มีข้อมูล':'No data yet',
'คำนวณจากเวรที่บันทึกไว้ ไม่ใช่การรับรองความปลอดภัยทางคลินิก':'Calculated from saved shifts; not clinical advice.',
'ใช้สำหรับจดและประมาณการรายได้ส่วนตัว ไม่ใช่เครื่องคิดเงินเดือนตามระเบียบของโรงพยาบาลหรือการคิดภาษี':'Personal estimates, not official payroll or tax calculations.',
'แยกชั่วโมงปกติและ OT: OT แบบต่อท้ายกะจะถูกบวกเพิ่ม; OT ภายในกะจะถูกหักจากชั่วโมงปกติ ไม่บวกซ้ำ':'Extra OT adds hours; in-shift OT is not counted twice.',
'เพิ่ม D1, D2, N1 ฯลฯ':'Add D1, D2, N1, etc.',
'Auto Backup เก็บจุดย้อนกลับใน IndexedDB ของเครื่องนี้ สูงสุด 10 เวอร์ชัน ข้อมูลอาจหายหากล้างข้อมูลเว็บไซต์':'Up to 10 local backups. Clearing browser data can erase them.',
'ต้อง Deploy Cloudflare Worker + D1 ก่อน บนเซิร์ฟเวอร์เก็บเฉพาะข้อมูลที่เข้ารหัส AES-GCM เท่านั้น รหัสผ่านเข้ารหัสไม่ถูกส่งไปเซิร์ฟเวอร์ และไม่บันทึกไว้ในเครื่อง':'Requires a separate Cloudflare Worker and D1. Cloud stores only encrypted data.',
'Sync Token (เก็บในเบราว์เซอร์)':'Sync token (stored in browser)',
'ขอสิทธิ์แจ้งเตือนระหว่างที่แอปเปิดอยู่เท่านั้น หากปิดแอปให้ใช้ไฟล์ ICS กับแอปปฏิทินที่รองรับการเตือน':'Alerts work while app is open. Export ICS for calendar alerts when closed.',
'เช้า':'Day','บ่าย':'Evening','ดึก':'Night'
};
const patterns=[
 [/^สวัสดี คุณ(.+)$/,(_,n)=>'Hello, '+n],
 [/^(.+) ชั่วโมง$/,(_,n)=>n+' hours'],
 [/^(.+) ชม\.$/,(_,n)=>n+' hrs'],
 [/^(\d+) เวร$/,(_,n)=>n+' shifts'],
 [/^แสดงทั้งหมด (\d+) รายการ$/,(_,n)=>'Show all '+n+' entries'],
 [/^พบความเสี่ยงเวลาพัก (\d+) จุด$/,(_,n)=>n+' rest warnings'],
 [/^มีเวรที่พักน้อยกว่า (\d+(?:\.\d+)?) ชั่วโมง.+$/,(_,n)=>'Shifts have less than '+n+' hours rest'],
 [/^บันทึก (\d+) วันแล้ว.*$/,(_,n)=>'Saved '+n+' days'],
 [/^ยังไม่มีตารางเวรจริงของคุณ.+$/,()=> 'No shifts yet. Add your first shift.'],
 [/^มีเวรตัวอย่าง (\d+) วัน$/,(_,n)=>n+' sample days']
];
function tr(s){const x=s.trim();if(!x)return s;let y=map[x];if(y===undefined){for(const [pat,fn] of patterns){if(pat.test(x)){y=x.replace(pat,fn);break}}}
if(y===undefined){y=x.replace(/(\d+(?:\.\d+)?) ชม\./g,'$1 hrs').replace(/(\d+) วัน/g,'$1 days').replace(/เวรเช้า/g,'Day shift').replace(/เวรบ่าย/g,'Evening shift').replace(/เวรดึก/g,'Night shift').replace(/วันหยุด/g,'Day off').replace(/วันลา/g,'Leave')}
if(y===x)return s;return s.slice(0,s.indexOf(x))+y+s.slice(s.indexOf(x)+x.length)}
function translate(root){if(!root||lang!=='en')return;const walker=document.createTreeWalker(root,NodeFilter.SHOW_TEXT),nodes=[];while(walker.nextNode())nodes.push(walker.currentNode);
for(const node of nodes){const p=node.parentElement;if(!p||p.closest('script,style,textarea,[contenteditable="true"]'))continue;const v=tr(node.nodeValue);if(v!==node.nodeValue)node.nodeValue=v}
for(const el of [root,...root.querySelectorAll('[placeholder],[aria-label],[title]')]){if(!el?.getAttribute)continue;for(const attr of ['placeholder','aria-label','title'])if(el.hasAttribute(attr)){const v=el.getAttribute(attr),n=tr(v);if(n!==v)el.setAttribute(attr,n)}}}
function apply(){document.documentElement.lang=lang;document.querySelectorAll('[data-lang]').forEach(b=>{const on=b.dataset.lang===lang;b.classList.toggle('active',on);b.setAttribute('aria-pressed',on?'true':'false')});translate(document.querySelector('.app-shell'))}
window.NurseFlowLocale={get:()=>lang,apply};
document.addEventListener('click',evt=>{const b=evt.target.closest('[data-lang]');if(!b)return;evt.preventDefault();evt.stopImmediatePropagation();if(b.dataset.lang===lang)return;try{localStorage.setItem(KEY,b.dataset.lang)}catch{}location.reload()},true);
const ob=new MutationObserver(changes=>{if(lang==='en'&&changes.some(x=>x.type==='childList'&&x.addedNodes.length||x.type==='characterData'&&/[ก-๙]/.test(x.target.nodeValue||'')))queueMicrotask(apply)});
const start=()=>{apply();const root=document.querySelector('.app-shell');if(root)ob.observe(root,{childList:true,characterData:true,subtree:true})};
if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',start,{once:true});else start();
})();