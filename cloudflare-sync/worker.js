// NurseFlow Personal optional sync API. Only opaque AES-GCM ciphertext is stored in D1.
const HEADERS={'Access-Control-Allow-Origin':'*','Access-Control-Allow-Methods':'GET,PUT,OPTIONS','Access-Control-Allow-Headers':'Authorization, Content-Type','Cache-Control':'no-store'};
const respond=(body,status=200)=>new Response(JSON.stringify(body),{status,headers:{...HEADERS,'Content-Type':'application/json; charset=utf-8','X-Content-Type-Options':'nosniff'}});
const hash=async str=>Array.from(new Uint8Array(await crypto.subtle.digest('SHA-256',new TextEncoder().encode(str))),x=>x.toString(16).padStart(2,'0')).join('');
export default {
 async fetch(request,env){
  if(request.method==='OPTIONS')return new Response(null,{status:204,headers:HEADERS});
  const u=new URL(request.url),match=u.pathname.match(/^\/api\/sync\/([a-f0-9]{32})$/);
  if(!match)return respond({error:'Not Found'},404);
  if(!['GET','PUT'].includes(request.method))return respond({error:'Method Not Allowed'},405);
  if(!env.DB)return respond({error:'D1 binding DB is not configured'},503);
  const token=(request.headers.get('Authorization')||'').match(/^Bearer ([a-f0-9]{64})$/);
  if(!token)return respond({error:'Invalid token'},401);
  const id=match[1],tokenHash=await hash(token[1]);
  try{
   const row=await env.DB.prepare('SELECT token_hash,revision,payload FROM sync_profiles WHERE id=?').bind(id).first();
   if(row&&row.token_hash!==tokenHash)return respond({error:'Unauthorized profile'},403);
   if(request.method==='GET')return row?respond({exists:true,revision:row.revision,packet:JSON.parse(row.payload)}):respond({exists:false,revision:0});
   if(Number(request.headers.get('Content-Length')||0)>750000)return respond({error:'Payload too large'},413);
   let body;try{body=await request.json()}catch{return respond({error:'Invalid JSON'},400)}
   const {packet,expectedRevision}=body||{};
   if(!Number.isInteger(expectedRevision)||expectedRevision<0||!packet||packet.v!==1||typeof packet.cipher!=='string'||typeof packet.iv!=='string'||typeof packet.salt!=='string'||packet.cipher.length>500000||!/^[A-Za-z0-9+/=]+$/.test(packet.cipher)||!/^[A-Za-z0-9+/=]+$/.test(packet.iv)||!/^[A-Za-z0-9+/=]+$/.test(packet.salt))return respond({error:'Invalid payload or revision'},400);
   const payload=JSON.stringify({v:1,salt:packet.salt,iv:packet.iv,cipher:packet.cipher});
   if(!row){if(expectedRevision!==0)return respond({error:'Conflict: profile does not exist'},409);const result=await env.DB.prepare('INSERT INTO sync_profiles (id,token_hash,revision,payload,updated_at) VALUES (?,?,1,?,?) ON CONFLICT(id) DO NOTHING').bind(id,tokenHash,payload,new Date().toISOString()).run();return result.meta.changes===1?respond({ok:true,revision:1}):respond({error:'Conflict: profile changed'},409)}
   if(row.revision!==expectedRevision)return respond({error:'Conflict: another device updated this profile. Pull first.'},409);
   const result=await env.DB.prepare('UPDATE sync_profiles SET revision=revision+1,payload=?,updated_at=? WHERE id=? AND token_hash=? AND revision=?').bind(payload,new Date().toISOString(),id,tokenHash,expectedRevision).run();
   return result.meta.changes===1?respond({ok:true,revision:expectedRevision+1}):respond({error:'Conflict: another device updated the profile'},409);
  }catch(error){console.error('NurseFlow D1 error',error);return respond({error:'Sync server unavailable'},503)}
 }
};
