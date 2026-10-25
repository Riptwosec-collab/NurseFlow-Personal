const fs=require('fs'),vm=require('vm'),assert=require('assert'),crypto=require('crypto');
const code=fs.readFileSync(__dirname+'/../app.js','utf8');
const injected=code.replace('render();setInterval(checkReminder,30000);checkReminder();',`window.__nf={normalize,summary,timeBreakdown,warnings,currentOrNext,parseCSV,parseOCR,fromTable,normDate,renderHome,renderCalendar,renderStats,renderSettings,encryptCloud,decryptCloud,raw:()=>data,setPass:p=>syncPassword=p,setState:p=>data=normalize(p)}; render();setInterval(checkReminder,30000);checkReminder();`);
const saved={};const els={};function elem(key){if(!els[key])els[key]={innerHTML:'',textContent:'',classList:{add(){},remove(){},toggle(){}},value:'',setAttribute(){}};return els[key]}
const sandbox={window:{addEventListener(){}},document:{getElementById:elem,querySelector:elem,querySelectorAll(){return[]},addEventListener(){}},localStorage:{getItem:k=>saved[k]||null,setItem:(k,v)=>saved[k]=v,removeItem:k=>delete saved[k]},sessionStorage:{getItem(){return null},setItem(){}},navigator:{},indexedDB:null,crypto:crypto.webcrypto,Date,JSON,Number,Intl,String,Array,Object,Math,RegExp,Blob,setInterval(){},setTimeout(){return 1},clearTimeout(){},alert(){},confirm(){return true},console,TextEncoder,TextDecoder,btoa,atob};sandbox.window.crypto=sandbox.crypto;sandbox.window.isSecureContext=true;
vm.runInNewContext(injected,sandbox);const n=sandbox.window.__nf;
function test(label,fn){Promise.resolve().then(fn).then(()=>console.log('PASS',label)).catch(e=>{console.error('FAIL',label,e);process.exitCode=1})}
const specimen={shifts:{'2026-10-25':{code:'N',start:'23:00',end:'07:00',ot:2,otMode:'additional',breakMinutes:0,extra:50},'2026-10-26':{code:'M',start:'07:00',end:'15:00',ot:2,otMode:'within',breakMinutes:0}},settings:{minRestHours:11,shifts:{N:{label:'Night',start:'23:00',end:'07:00',rate:100},M:{label:'Morning',start:'07:00',end:'15:00',rate:80}}}};
n.setState(specimen);const first=n.raw().shifts['2026-10-25'],second=n.raw().shifts['2026-10-26'];
test('OT outside shift does not double-count',()=>{const p=n.timeBreakdown(first);assert.equal(p.regular,8);assert.equal(p.ot,2);assert.equal(p.total,10)});
test('OT inside shift is not double counted',()=>{const p=n.timeBreakdown(second);assert.equal(p.regular,6);assert.equal(p.ot,2);assert.equal(p.total,8)});
test('Overnight rest/overlap detected',()=>{const w=n.warnings();assert.equal(w.length,1);assert.equal(w[0].overlap,true);assert.equal(w[0].rest,-2)});
test('Custom shifts migrate and validate',()=>{const d=n.normalize({settings:{shifts:{D1:{label:'D1 nurse',start:'08:00',end:'16:00',rate:150}}},shifts:{'2026-10-20':{code:'D1',start:'08:00',end:'16:00'}}});assert.equal(d.shifts['2026-10-20'].code,'D1')});
test('CSV handles quoted commas',()=>{const rows=n.parseCSV('วันที่,รหัสเวร,หมายเหตุ\n2026-10-26,N,"ICU, Bed 2"');assert.equal(rows[1][2],'ICU, Bed 2')});
test('OCR only matches explicit dates and codes',()=>{const rows=n.parseOCR('26/10/2026 N\n27 OFF\nXXX\n28/10/2026 HELLO');assert.equal(rows.length,2)});
test('Buddhist year normalized',()=>{assert.equal(n.normDate('26/10/2569'),'2026-10-26')});
test('Month stats compute current subset',()=>{const s=n.summary(Object.entries(n.raw().shifts));assert.equal(s.regular,14);assert.equal(s.ot,4);assert.equal(s.total,18);assert.equal(s.shiftPay,180);assert.equal(s.otPay,0);assert.equal(s.extra,50);assert.equal(s.income,230)});
test('Settings and calendar render',()=>{assert(n.renderSettings().includes('Cloud Sync'));assert(n.renderCalendar().includes('ลงเวรหลายวัน'));assert(n.renderStats().includes('รายละเอียดรายวัน'))});
test('AES-GCM browser-side encryption round trip',async()=>{n.setPass('supersecretpassphrase123');const obj={app:'NurseFlow Personal',foo:2};const p=await n.encryptCloud(obj);assert.deepEqual(await n.decryptCloud(p),obj);assert(!JSON.stringify(p).includes('NurseFlow Personal'))});

test('CSV import recognizes Thai headers, OT and notes',()=>{const rows=n.fromTable(n.parseCSV('วันที่,รหัสเวร,เริ่ม,สิ้นสุด,OT ชั่วโมง,หมายเหตุ\n2026-10-26,N,23:00,07:00,2,night shift'));assert.equal(rows[0].ot,2);assert.equal(rows[0].code,'N');assert.equal(rows[0].note,'night shift')});
