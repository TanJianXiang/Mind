const http = require('http');
const url = require('url');
const fs = require('fs');

let users = [];
let chatMessages = [];
let artworks = [];
let emotionRecords = [];
let userIdCounter = 1;
let messageIdCounter = 1;
let artworkIdCounter = 1;
let emotionIdCounter = 1;

const AI_RESPONSES = [
    "我理解你的感受，谢谢你的分享。我会一直在这里陪伴你。",
    "听起来你今天经历了很多，我很愿意倾听。",
    "你并不孤单，我们一起面对。",
    "谢谢你愿意和我分享这些，这需要很大的勇气。",
    "我能感受到你的情绪，让我们一起探讨一下。",
    "你的感受很重要，我在听。",
    "有时候表达出来就是一种释放，你做得很好。",
    "我明白这种感觉，让我们一起想办法。"
];

function hashString(str) {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
        hash = str.charCodeAt(i) + ((hash << 5) - hash);
    }
    return Math.abs(hash);
}

const server = http.createServer((req, res) => {
    const parsedUrl = url.parse(req.url, true);
    const path = parsedUrl.pathname;
    const method = req.method;

    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (method === 'OPTIONS') {
        res.writeHead(200);
        res.end();
        return;
    }

    let body = '';
    req.on('data', chunk => {
        body += chunk.toString();
    });

    req.on('end', () => {
        try {
            const data = body ? JSON.parse(body) : {};

            if (path === '/api/health') {
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ status: 'ok' }));
            }

            else if (path === '/api/register') {
                const { name, email, password } = data;
                if (!name || !email || !password) {
                    res.writeHead(400, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ status: 'error', detail: '请填写所有字段' }));
                    return;
                }

                const existingUser = users.find(u => u.email === email);
                if (existingUser) {
                    res.writeHead(400, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ status: 'error', detail: '邮箱已被注册' }));
                    return;
                }

                const passwordHash = require('crypto').createHash('sha256').update(password).digest('hex');
                const user = {
                    id: userIdCounter++,
                    name,
                    email,
                    passwordHash,
                    createdAt: new Date().toISOString()
                };
                users.push(user);

                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ status: 'success', user_id: user.id, message: '注册成功' }));
            }

            else if (path === '/api/login') {
                const { email, password } = data;
                if (!email || !password) {
                    res.writeHead(400, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ status: 'error', detail: '请填写所有字段' }));
                    return;
                }

                const user = users.find(u => u.email === email);
                if (!user) {
                    res.writeHead(400, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ status: 'error', detail: '邮箱或密码错误' }));
                    return;
                }

                const passwordHash = require('crypto').createHash('sha256').update(password).digest('hex');
                if (user.passwordHash !== passwordHash) {
                    res.writeHead(400, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ status: 'error', detail: '邮箱或密码错误' }));
                    return;
                }

                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ status: 'success', user_id: user.id, name: user.name, email: user.email }));
            }

            else if (path === '/api/chat') {
                const { user_id, message } = data;
                if (!user_id || !message) {
                    res.writeHead(400, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ status: 'error', detail: '缺少参数' }));
                    return;
                }

                chatMessages.push({
                    id: messageIdCounter++,
                    userId: user_id,
                    content: message,
                    isUser: true,
                    createdAt: new Date().toISOString()
                });

                const response = AI_RESPONSES[hashString(message) % AI_RESPONSES.length];

                chatMessages.push({
                    id: messageIdCounter++,
                    userId: user_id,
                    content: response,
                    isUser: false,
                    createdAt: new Date().toISOString()
                });

                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ status: 'success', response }));
            }

            else if (path.startsWith('/api/chat/')) {
                const userId = parseInt(path.split('/')[3]);
                const userMessages = chatMessages.filter(m => m.userId === userId);
                const formattedMessages = userMessages.map(m => ({
                    content: m.content,
                    is_user: m.isUser,
                    created_at: m.createdAt
                }));

                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ status: 'success', messages: formattedMessages }));
            }

            else if (path === '/api/generate-art') {
                const { user_id, prompt, style } = data;
                if (!user_id || !prompt) {
                    res.writeHead(400, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ status: 'error', detail: '缺少参数' }));
                    return;
                }

                const encodedPrompt = encodeURIComponent(`情绪艺术: ${prompt}，风格: ${style}`);
                const imageUrl = `https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=${encodedPrompt}&image_size=landscape_16_9`;

                artworks.push({
                    id: artworkIdCounter++,
                    userId: user_id,
                    prompt,
                    style,
                    imageUrl,
                    createdAt: new Date().toISOString()
                });

                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ status: 'success', image_url: imageUrl }));
            }

            else if (path.startsWith('/api/artworks/')) {
                const userId = parseInt(path.split('/')[3]);
                const userArtworks = artworks.filter(a => a.userId === userId).reverse();
                const formattedArtworks = userArtworks.map(a => ({
                    id: a.id,
                    prompt: a.prompt,
                    style: a.style,
                    image_url: a.imageUrl,
                    created_at: a.createdAt
                }));

                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ status: 'success', artworks: formattedArtworks }));
            }

            else if (path.startsWith('/api/emotion-analysis/')) {
                const userId = parseInt(path.split('/')[3]);
                const userRecords = emotionRecords.filter(r => r.userId === userId);

                if (userRecords.length === 0) {
                    res.writeHead(200, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({
                        status: 'success',
                        trend: [65, 59, 80, 81, 56, 55, 70],
                        distribution: { '平静': 45, '开心': 30, '焦虑': 15, '难过': 10 },
                        report: {
                            overall_status: '稳定',
                            main_emotion: '平静',
                            fluctuation: '低',
                            suggestion: '继续保持积极心态'
                        }
                    }));
                    return;
                }

                const trend = userRecords.slice(-7).map(r => r.score);
                const distribution = {};
                userRecords.forEach(r => {
                    distribution[r.emotionType] = (distribution[r.emotionType] || 0) + 1;
                });
                const total = Object.values(distribution).reduce((a, b) => a + b, 0);
                const normalizedDistribution = {};
                Object.keys(distribution).forEach(k => {
                    normalizedDistribution[k] = Math.round((distribution[k] / total) * 100);
                });

                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({
                    status: 'success',
                    trend,
                    distribution: normalizedDistribution,
                    report: {
                        overall_status: (Math.max(...trend) - Math.min(...trend) < 20) ? '稳定' : '波动',
                        main_emotion: Object.keys(normalizedDistribution).reduce((a, b) => normalizedDistribution[a] > normalizedDistribution[b] ? a : b),
                        fluctuation: (Math.max(...trend) - Math.min(...trend) < 15) ? '低' : '高',
                        suggestion: '继续保持积极心态'
                    }
                }));
            }

            else {
                res.writeHead(404, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ status: 'error', message: 'Not found' }));
            }
        } catch (error) {
            res.writeHead(500, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ status: 'error', message: error.message }));
        }
    });
});

server.listen(8000, () => {
    console.log('Server running on http://localhost:8000');
});