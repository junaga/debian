#!/usr/bin/node
import { chromium } from '/usr/lib/node_modules/playwright-core/index.mjs';
import { readFile } from 'node:fs/promises';

const [keyId, key] = process.argv.slice(2);
if (!keyId || !key || process.argv.length !== 4) {
  console.error('Usage: cloudflare-speedtest <turn-key-id> <turn-key>');
  process.exit(1);
}
const response = await fetch(`https://rtc.live.cloudflare.com/v1/turn/keys/${encodeURIComponent(keyId)}/credentials/generate-ice-servers`, {
  method: 'POST',
  headers: { Authorization: `Bearer ${key}`, 'Content-Type': 'application/json' },
  body: JSON.stringify({ ttl: 300 }),
  signal: AbortSignal.timeout(15000)
});
if (!response.ok) throw new Error(`TURN credentials request failed: HTTP ${response.status}`);
const { iceServers } = await response.json();
const server = iceServers?.find(server => server.username && server.credential);
const uri = [server?.urls].flat().find(url => url?.startsWith('turn:') && url.includes('transport=udp'));
if (!uri) throw new Error('TURN response contains no UDP credentials');
const turn = { turnServerUri: uri.slice(5).split('?')[0], turnServerUser: server.username, turnServerPass: server.credential };

const browser = await chromium.launch({ channel: 'chrome', chromiumSandbox: true });
try {
  const page = await browser.newPage();
  await page.route('http://localhost/', route => route.fulfill({ body: '<!doctype html>' }));
  await page.goto('http://localhost/');
  const source = await readFile('/usr/lib/node_modules/@cloudflare/speedtest/dist/speedtest.js', 'utf8');
  const result = await page.evaluate(async ({ source, turn }) => {
    const { default: SpeedTest } = await import(URL.createObjectURL(new Blob([source], { type: 'text/javascript' })));
    return new Promise((resolve, reject) => {
      const test = new SpeedTest({ autoStart: false, logAimApiUrl: null, ...turn });
      test.onError = reject;
      test.onFinish = results => resolve({ summary: results.getSummary(), scores: results.getScores() });
      setTimeout(() => reject(new Error('Speed test timed out')), 120000);
      test.play();
    });
  }, { source, turn });
  if (!Number.isFinite(result.summary.packetLoss)) throw new Error('Packet-loss measurement incomplete');
  const levels = ['streaming', 'gaming', 'rtc'].map(key => result.scores[key]?.classificationIdx);
  if (!levels.every(Number.isInteger)) throw new Error('Incomplete Cloudflare scores');
  console.log(JSON.stringify({ ...result, wanHealth: `${Math.min(...levels) + 1}/5` }));
} finally {
  await browser.close();
}
