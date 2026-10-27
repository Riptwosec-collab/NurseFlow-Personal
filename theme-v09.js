/* NurseFlow v0.9: independently persisted device theme. */
(()=>{'use strict';
const KEY='nurseflow-ui-theme',root=document.documentElement;
function get(){return root.dataset.theme==='dark'?'dark':'light'}
function reflect(){const dark=get()==='dark',b=document.getElementById('theme-toggle');
if(b){b.setAttribute('aria-label',dark?'Switch to light mode / เปลี่ยนเป็นโหมดสว่าง':'Switch to dark mode / เปลี่ยนเป็นโหมดมืด');b.setAttribute('title',dark?'Light mode':'Dark mode');b.setAttribute('aria-pressed',String(dark));b.querySelector('use')?.setAttribute('href',dark?'#ic-sun':'#ic-moon')}
const meta=document.querySelector('meta[name="theme-color"]');if(meta)meta.content=dark?'#101827':'#ffffff'}
function set(val){root.dataset.theme=val==='dark'?'dark':'light';try{localStorage.setItem(KEY,root.dataset.theme)}catch{}reflect()}
document.addEventListener('click',e=>{if(e.target.closest('#theme-toggle'))set(get()==='dark'?'light':'dark')});
if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',reflect,{once:true});else reflect();
window.NurseFlowTheme={get,set};
})();
