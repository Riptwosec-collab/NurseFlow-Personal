/* NurseFlow Personal: opt-in Supabase backup. No service-role/secret keys in browser. */
(()=>{'use strict';
  const ROOT='https://gfqkexnqbjtuwsyqacsw.supabase.co';
  const KEY='sb_publishable_jsDnGIrAjuf0b9w9Hy1z8g_u9SXAfht';
  const TABLE='nurseflow_user_backups';
  const SESSION_KEY='nurseflow-supabase-auth-v1';
  const SYNC_KEY='nurseflow-supabase-state-v1';
  const DATA_KEY='nurseflow-personal-v1';
  let session=null, syncState={}, timer=null, busy=false;
  const jread=(key,fallback)=>{try{return JSON.parse(localStorage.getItem(key)||'null')||fallback}catch{return fallback}};
  session=jread(SESSION_KEY,null);syncState=jread(SYNC_KEY,{});
  const t=(th,en)=>window.NurseFlowLocale?.get?.()==='en'?en:th;
  const el=(id)=>document.getElementById(id);
  const escapeHTML=s=>String(s||'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
  const saveSession=()=>session?localStorage.setItem(SESSION_KEY,JSON.stringify(session)):localStorage.removeItem(SESSION_KEY);
  const saveState=()=>localStorage.setItem(SYNC_KEY,JSON.stringify(syncState));
  function notify(message){const status=el('nf-sb-message');if(status){status.textContent=message;status.setAttribute('role','status')}else console.info('NurseFlow Supabase:',message)}
  function isSameUser(){return !!session?.user?.id&&syncState?.userId===session.user.id;}
  function resetSyncForUser(){if(!isSameUser()){syncState={userId:session?.user?.id||null,version:null,auto:false,dirty:false,lastSync:null,conflict:false};saveState();}}
  const authHeaders=()=>({'apikey':KEY,'Content-Type':'application/json','Cache-Control':'no-store'});
  async function api(path,{method='GET',body,authenticated=false,headers={}}={}){
    const h={...authHeaders(),...headers};
    if(authenticated){await ensureSession();if(!session?.access_token)throw Error(t('กรุณาเข้าสู่ระบบก่อน','Sign in first'));h.Authorization='Bearer '+session.access_token}
    let response;
    try{response=await fetch(ROOT+path,{method,headers:h,body:body===undefined?undefined:JSON.stringify(body),cache:'no-store'})}
    catch{throw Error(t('ไม่สามารถเชื่อมต่ออินเทอร์เน็ต ข้อมูลในเครื่องยังปลอดภัย','Network unavailable. Local data is safe.'))}
    const responseText=await response.text();let payload;try{payload=responseText?JSON.parse(responseText):null}catch{payload={message:responseText.slice(0,140)}}
    if(!response.ok){const msg=payload?.msg||payload?.message||payload?.error_description||payload?.error||`HTTP ${response.status}`;const error=Error(msg);error.status=response.status;throw error}
    return payload;
  }
  async function ensureSession(){
    if(!session?.access_token)return;
    if((session.expires_at||0)*1000 > Date.now()+90000)return;
    if(!session.refresh_token){session=null;saveSession();return}
    const old=session;
    // Public key only. A refresh token never appears in source code.
    const res=await api('/auth/v1/token?grant_type=refresh_token',{method:'POST',body:{refresh_token:old.refresh_token}});
    session={...res,user:res.user||old.user,expires_at:res.expires_at||Math.floor(Date.now()/1000)+(res.expires_in||3600)};
    saveSession();
  }
  function saveAuth(res){
    if(!res?.access_token||!res.user?.id)throw Error(t('ยังไม่ได้รับ Session โปรดยืนยันอีเมลก่อน','No session. Please verify your email first.'));
    const oldId=session?.user?.id;
    session={access_token:res.access_token,refresh_token:res.refresh_token,expires_at:res.expires_at||Math.floor(Date.now()/1000)+(res.expires_in||3600),user:{id:res.user.id,email:res.user.email}};
    saveSession();if(oldId!==session.user.id)resetSyncForUser();
  }
  async function signIn(signup=false){
    if(busy)return;const email=el('nf-sb-email')?.value.trim().toLowerCase();const password=el('nf-sb-password')?.value||'';
    if(!email||!email.includes('@')||password.length<8){notify(t('กรอกอีเมล และรหัสผ่านอย่างน้อย 8 ตัวอักษร','Enter an email and password of at least 8 characters'));return}
    busy=true;controls(true);
    try{
      if(signup){
        const res=await api('/auth/v1/signup?redirect_to='+encodeURIComponent('https://nurseflow-personal.vercel.app/'),{method:'POST',body:{email,password,data:{app:'nurseflow-personal'}}});
        if(res?.access_token){saveAuth(res);notify(t('สร้างบัญชีและเข้าสู่ระบบแล้ว','Account created and signed in'))}
        else notify(t('ตรวจอีเมลเพื่อยืนยันบัญชี แล้วกลับมาลงชื่อเข้าใช้','Check your email to confirm, then return to sign in'));
      }else{
        const res=await api('/auth/v1/token?grant_type=password',{method:'POST',body:{email,password}});saveAuth(res);notify(t('เข้าสู่ระบบแล้ว — เลือกสำรองหรือดึงข้อมูลจาก Cloud','Signed in. Choose upload or restore.'));
      }
    }catch(err){notify(t('เข้าสู่ระบบไม่สำเร็จ: ','Authentication failed: ')+err.message)}
    finally{busy=false;mount();}
  }
  async function logout(){
    if(busy)return;
    try{if(session?.access_token)await api('/auth/v1/logout',{method:'POST',authenticated:true})}catch{}
    clearTimeout(timer);session=null;saveSession();syncState={};saveState();mount();notify(t('ออกจากบัญชีแล้ว ข้อมูลในเครื่องยังอยู่','Signed out. Your local data remains.'));
  }
  async function remoteRead(){
    const userId=session?.user?.id;if(!userId)throw Error('Missing user');
    const q=`?select=owner_id,snapshot,version,updated_at&owner_id=eq.${encodeURIComponent(userId)}&limit=1`;
    const arr=await api('/rest/v1/'+TABLE+q,{authenticated:true});return arr?.[0]||null;
  }
  async function updateStatus(){
    if(!session)return;
    if(busy)return;busy=true;controls(true);
    try{
      const remote=await remoteRead();
      const remoteInfo=el('nf-sb-remote');
      if(!remote){if(remoteInfo)remoteInfo.textContent=t('Cloud ยังไม่มีข้อมูล (เริ่มสำรองได้)','Cloud has no backup (ready for first upload)');syncState.conflict=false;}
      else{
        if(remoteInfo)remoteInfo.textContent=t('Cloud มีข้อมูล ','Cloud backup: ')+Object.keys(remote.snapshot?.shifts||{}).length+t(' วัน · รุ่น ',' days · revision ')+remote.version;
        if(isSameUser()&&syncState.version!=null&&remote.version!==syncState.version){syncState.auto=false;syncState.conflict=true;notify(t('ตรวจพบ Cloud เปลี่ยนจากอุปกรณ์อื่น: ปิด Auto Sync เพื่อป้องกันข้อมูลทับกัน','Cloud changed on another device. Auto Sync paused.'));}
      }
      saveState();
    }catch(err){notify(t('ตรวจ Cloud ไม่สำเร็จ: ','Cloud check failed: ')+err.message)}
    finally{busy=false;controls(false);renderStatus();}
  }
  const localBackup=()=>{
    const text=localStorage.getItem(DATA_KEY);if(!text)throw Error(t('ไม่พบข้อมูลในเครื่อง','No local data'));
    const value=JSON.parse(text);
    if(!value||typeof value!=='object'||!value.settings||!value.shifts)throw Error(t('ข้อมูลในเครื่องไม่ถูกต้อง','Invalid local data'));
    return value;
  };
  function setVersion(version){syncState={...syncState,userId:session.user.id,version,dirty:false,conflict:false,lastSync:new Date().toISOString()};saveState();renderStatus()}
  async function push(automatic=false){
    if(busy||!session)return;
    if(automatic&&(!syncState.auto||syncState.conflict||syncState.version==null))return;
    busy=true;controls(true);
    try{
      const payload=localBackup();
      if(!automatic&&!confirm(t('สำรองข้อมูลจากเครื่องนี้ขึ้น Supabase ใช่หรือไม่?','Upload this device’s schedule to Supabase?')))return;
      let remote=await remoteRead();
      if(remote&&(!isSameUser()||syncState.version==null)){
        syncState.auto=false;syncState.conflict=true;saveState();
        throw Error(t('Cloud มีข้อมูลอยู่แล้ว กรุณาดึงข้อมูลลงเครื่องก่อน หากต้องการแทนที่ให้กด “แทนที่ Cloud”','Cloud already has a backup. Restore first, or explicitly choose Replace cloud.'));
      }
      if(remote&&remote.version!==syncState.version){syncState.auto=false;syncState.conflict=true;saveState();throw Error(t('ข้อมูล Cloud เปลี่ยนแล้ว กรุณาดึงลงเครื่องก่อน','Cloud revision changed. Restore before uploading.'))}
      if(remote){
        const query=`?owner_id=eq.${encodeURIComponent(session.user.id)}&version=eq.${syncState.version}&select=version`;
        const rows=await api('/rest/v1/'+TABLE+query,{method:'PATCH',authenticated:true,headers:{Prefer:'return=representation'},body:{snapshot:payload,version:syncState.version+1,updated_at:new Date().toISOString()}});
        if(!rows?.length)throw Error(t('เกิดข้อขัดแย้งขณะบันทึก Cloud โปรดลองดึงข้อมูลใหม่','Cloud update conflict. Restore or retry.'));
        setVersion(Number(rows[0].version));
      }else{
        const rows=await api('/rest/v1/'+TABLE+'?select=version',{method:'POST',authenticated:true,headers:{Prefer:'return=representation'},body:{owner_id:session.user.id,snapshot:payload,version:1}});
        if(!rows?.length)throw Error('Cloud insert returned no row');setVersion(Number(rows[0].version));
      }
      if(!automatic)notify(t('สำรองข้อมูลขึ้น Supabase สำเร็จ','Backup uploaded successfully'));
    }catch(err){
      if(err.status===409||/conflict|duplicate|ขัดแย้ง/i.test(err.message)){syncState.auto=false;syncState.conflict=true;saveState()}
      notify(t('สำรองไม่สำเร็จ: ','Backup failed: ')+err.message);
    }finally{busy=false;controls(false);renderStatus();}
  }
  async function pull(){
    if(busy||!session)return;busy=true;controls(true);
    try{
      const remote=await remoteRead();
      if(!remote){notify(t('ยังไม่มีข้อมูลใน Cloud','No cloud backup yet'));return}
      const content=remote.snapshot;
      if(!content||!content.settings||typeof content.shifts!=='object'||Array.isArray(content.shifts))throw Error(t('ข้อมูล Cloud ไม่ถูกต้อง','Invalid cloud backup'));
      if(!confirm(t(`จะดึงตารางเวร ${Object.keys(content.shifts).length} วันจาก Cloud มาแทนในเครื่องใช่หรือไม่? ระบบจะทำจุดกู้คืนก่อน`,`Replace local schedule with ${Object.keys(content.shifts).length} cloud entries? A recovery copy will be saved first.`)))return;
      if(!window.NurseFlowData?.restoreFromCloud)throw Error('NurseFlow local restore API unavailable');
      await window.NurseFlowData.restoreFromCloud(content);
      setVersion(Number(remote.version));notify(t('ดึงข้อมูลจาก Cloud สำเร็จ','Cloud backup restored successfully'));
    }catch(err){notify(t('ดึง Cloud ไม่สำเร็จ: ','Restore failed: ')+err.message)}
    finally{busy=false;controls(false);renderStatus();}
  }
  async function replace(){
    if(busy||!session)return;
    if(!confirm(t('ยืนยันแทนที่ข้อมูล Cloud ด้วยข้อมูลบนเครื่องนี้? ข้อมูล Cloud รุ่นก่อนจะถูกแทนที่','Replace the existing cloud backup with this device’s data? The previous cloud copy will be overwritten.')))return;
    busy=true;controls(true);
    try{
      const payload=localBackup();const remote=await remoteRead();
      if(!remote){busy=false;return push(false)}
      const q=`?owner_id=eq.${encodeURIComponent(session.user.id)}&version=eq.${remote.version}&select=version`;
      const rows=await api('/rest/v1/'+TABLE+q,{method:'PATCH',authenticated:true,headers:{Prefer:'return=representation'},body:{snapshot:payload,version:Number(remote.version)+1,updated_at:new Date().toISOString()}});
      if(!rows?.length)throw Error(t('ข้อมูล Cloud เปลี่ยนอีกครั้ง ยังไม่ได้เขียนทับ','Cloud changed again; no overwrite occurred'));
      setVersion(Number(rows[0].version));notify(t('แทนที่ข้อมูล Cloud เรียบร้อยแล้ว','Cloud backup replaced'));
    }catch(err){syncState.auto=false;syncState.conflict=true;saveState();notify(t('แทนที่ไม่สำเร็จ: ','Replace failed: ')+err.message)}
    finally{busy=false;controls(false);renderStatus()}
  }
  function controls(disabled){document.querySelectorAll('[data-nf-sb-action]').forEach(e=>{if(disabled)e.disabled=true;else e.disabled=false})}
  function renderStatus(){
    const status=el('nf-sb-status');if(!status)return;
    const account=session?.user?.email||'';
    status.textContent=account?t('บัญชี: ','Account: ')+account+' · '+(syncState.conflict?t('ข้อมูลขัดแย้ง','Conflict'):syncState.version==null?t('ยังไม่ซิงก์','Not synced'):t('รุ่น ','Rev ')+syncState.version+(syncState.dirty?t(' · รอซิงก์',' · Pending'):t(' · บันทึกแล้ว',' · Saved'))):t('ยังไม่ได้เข้าสู่ระบบ','Not signed in');
    const auto=el('nf-sb-auto');if(auto){auto.checked=!!(syncState.auto&&session&&!syncState.conflict);auto.disabled=!(session&&syncState.version!=null&&!syncState.conflict)}
  }
  function mount(){const mount=el('nf-supabase-mount');if(!mount)return;
    mount.innerHTML=session?`<div class="panel nf-sb-panel"><div class="panel-head"><h2 class="panel-title">Supabase <span class="nf-sb-pill">Cloud</span></h2><span class="nf-sb-dot"></span></div><p class="caption" id="nf-sb-status"></p><p class="caption" id="nf-sb-remote"></p><div class="settings-actions"><button type="button" class="action-button pale" data-nf-sb-action="push">${t('สำรองขึ้น Cloud','Upload backup')}</button><button type="button" class="action-button ghost" data-nf-sb-action="pull">${t('ดึงข้อมูลจาก Cloud','Restore backup')}</button><button type="button" class="action-button ghost" data-nf-sb-action="check">${t('ตรวจ Cloud','Check cloud')}</button></div><label class="nf-sb-toggle"><input type="checkbox" id="nf-sb-auto"> ${t('ซิงก์อัตโนมัติหลังสำรองครั้งแรก','Auto-sync after first backup')}</label><details class="nf-sb-advanced"><summary>${t('ตัวเลือกเพิ่มเติม','More options')}</summary><button type="button" class="action-button danger" data-nf-sb-action="replace">${t('แทนที่ Cloud (ยืนยันอีกครั้ง)','Replace cloud (confirm)')}</button></details><button type="button" class="nf-sb-signout" data-nf-sb-action="logout">${t('ออกจากบัญชี','Sign out')}</button><p class="caption" id="nf-sb-message" role="status"></p><p class="nf-sb-note">${t('ข้อมูลในเครื่องยังอยู่ · Cloud เก็บสำเนาแบบ JSON ภายใต้ RLS · ไม่ใช่การเข้ารหัสแบบ End-to-End · อย่าบันทึกข้อมูลผู้ป่วย','Local data remains · Cloud stores JSON protected by RLS · Not end-to-end encrypted · Do not store patient details')}</p></div>`:
    `<div class="panel nf-sb-panel"><div class="panel-head"><h2 class="panel-title">Supabase <span class="nf-sb-pill">Cloud</span></h2><span class="nf-sb-dot"></span></div><p class="caption">${t('เข้าสู่ระบบเพื่อสำรองและย้ายตารางเวรระหว่างโทรศัพท์และคอมพิวเตอร์','Sign in to back up and transfer schedules across devices')}</p><label class="form-label" for="nf-sb-email">Email</label><input class="form-input" type="email" id="nf-sb-email" autocomplete="email" placeholder="you@example.com"/><label class="form-label" for="nf-sb-password" style="margin-top:12px">${t('รหัสผ่าน','Password')}</label><input class="form-input" type="password" id="nf-sb-password" autocomplete="current-password" minlength="8" placeholder="••••••••"/><div class="settings-actions" style="margin-top:14px"><button type="button" class="action-button" data-nf-sb-action="signin">${t('เข้าสู่ระบบ','Sign in')}</button><button type="button" class="action-button ghost" data-nf-sb-action="signup">${t('สร้างบัญชี','Create account')}</button></div><p class="caption" id="nf-sb-message" role="status"></p><p class="nf-sb-note">${t('การเชื่อมครั้งแรกไม่อัปโหลดข้อมูลอัตโนมัติ · ห้ามใช้ข้อมูลระบุตัวผู้ป่วย','No automatic upload on first connection · Do not store patient identifiers')}</p></div>`;
    renderStatus();
  }
  function localChanged(){
    if(!session||!isSameUser())return;
    syncState.dirty=true;saveState();renderStatus();
    if(syncState.auto&&!syncState.conflict&&syncState.version!=null){clearTimeout(timer);timer=setTimeout(()=>{if(navigator.onLine)push(true)},2200)}
  }
  document.addEventListener('click',e=>{
    const button=e.target.closest('[data-nf-sb-action]');if(!button)return;
    e.preventDefault();if(busy)return;
    const action=button.dataset.nfSbAction;
    if(action==='signup')signIn(true);
    else if(action==='signin')signIn(false);
    else if(action==='logout')logout();
    else if(action==='push')push(false);
    else if(action==='pull')pull();
    else if(action==='replace')replace();
    else if(action==='check')updateStatus();
  });
  document.addEventListener('change',e=>{
    if(e.target?.id==='nf-sb-auto'){
      if(!session||syncState.version==null||syncState.conflict){e.target.checked=false;return}
      syncState.auto=e.target.checked;saveState();renderStatus();
      if(syncState.auto&&syncState.dirty)localChanged();
    }
  });
  window.addEventListener('online',()=>{if(syncState.auto&&syncState.dirty)localChanged()});
  window.addEventListener('offline',()=>{});
  window.NurseFlowSupabase={mount,localChanged,debugState:()=>({hasSession:!!session,revision:syncState.version,auto:syncState.auto,dirty:syncState.dirty,conflict:syncState.conflict})};
})();
