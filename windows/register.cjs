const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
const log = process.env.REGISTRATION_LOG || '/usr/local/data/.config/tailcat/registrations.jsonl';
process.umask(0o077);
fs.mkdirSync(path.dirname(log), { recursive: true, mode: 0o700 });
const server = http.createServer(async (req, res) => {
    if (req.method === 'GET' && req.url === '/health') return res.end('ok');
    if (req.method !== 'POST' || req.url !== '/register') { res.writeHead(404); return res.end(); }
    try {
        let body = '';
        for await (const chunk of req) {
            body += chunk;
            if (Buffer.byteLength(body) > 4096) { res.writeHead(413); return res.end(); }
        }
        const { hostname, address } = JSON.parse(body);
        if (typeof hostname !== 'string' || typeof address !== 'string' || !/^[a-z0-9_-]{1,63}$/i.test(hostname) || !/^tc[A-Za-z0-9_-]{20,2048}$/.test(address)) throw new Error('Invalid registration');
        if (fs.existsSync(log) && fs.statSync(log).size > 1048576) fs.renameSync(log, log + '.1');
        fs.appendFileSync(log, JSON.stringify({ date: new Date().toISOString(), hostname, address }) + '\n', { mode: 0o600 });
        res.end('ok');
    } catch { res.writeHead(400); res.end('Invalid registration'); }
});
server.requestTimeout = 15000;
server.headersTimeout = 10000;
server.listen(Number(process.env.PORT || 8080), '0.0.0.0');
