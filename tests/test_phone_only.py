"""Basic responsive regression test (pip install playwright + Chromium).
Run: python tests/test_phone_only.py
"""
from pathlib import Path
from playwright.sync_api import sync_playwright
ROOT=Path(__file__).resolve().parents[1]
with sync_playwright() as pw:
 browser=pw.chromium.launch(headless=True)
 for width,height in [(320,700),(375,812),(402,874),(430,932),(768,1024),(1440,900)]:
  page=browser.new_page(viewport={'width':width,'height':height})
  page.goto('http://localhost:8000/',wait_until='networkidle')
  for tab in ['home','calendar','stats','settings']:
   page.locator(f'.bottom-link[data-page="{tab}"]').click()
   dims=page.evaluate('''() => ({doc:document.documentElement.scrollWidth, shell:document.querySelector('.app-shell').getBoundingClientRect().width,sidebar:getComputedStyle(document.querySelector('.sidebar')).display})''')
   assert dims['doc']<=width and dims['shell']<=430 and dims['sidebar']=='none', (width,tab,dims)
  page.locator('#mobile-add').click()
  assert page.locator('.modal-card').is_visible()
  page.close()
 browser.close()
