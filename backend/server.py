#!/usr/bin/env python3
import http.server
import json
import hashlib
import sqlite3
import urllib.parse
from datetime import datetime

# 初始化数据库
conn = sqlite3.connect('test.db')
cursor = conn.cursor()

# 创建表
cursor.execute('''
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    email TEXT UNIQUE,
    password_hash TEXT,
    created_at TEXT
)
''')

cursor.execute('''
CREATE TABLE IF NOT EXISTS chat_messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    content TEXT,
    is_user INTEGER,
    created_at TEXT
)
''')

cursor.execute('''
CREATE TABLE IF NOT EXISTS artworks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    prompt TEXT,
    style TEXT,
    image_url TEXT,
    created_at TEXT
)
''')

cursor.execute('''
CREATE TABLE IF NOT EXISTS emotion_records (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    emotion_text TEXT,
    emotion_type TEXT,
    score REAL,
    created_at TEXT
)
''')

conn.commit()

# AI回复模板
AI_RESPONSES = [
    "我理解你的感受，谢谢你的分享。我会一直在这里陪伴你。",
    "听起来你今天经历了很多，我很愿意倾听。",
    "你并不孤单，我们一起面对。",
    "谢谢你愿意和我分享这些，这需要很大的勇气。",
    "我能感受到你的情绪，让我们一起探讨一下。",
    "你的感受很重要，我在听。",
    "有时候表达出来就是一种释放，你做得很好。",
    "我明白这种感觉，让我们一起想办法。"
]

class RequestHandler(http.server.BaseHTTPRequestHandler):
    def send_json_response(self, data, status_code=200):
        self.send_response(status_code)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode('utf-8'))
    
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
    
    def do_GET(self):
        parsed_path = urllib.parse.urlparse(self.path)
        path = parsed_path.path
        
        if path == '/api/health':
            self.send_json_response({'status': 'ok'})
        
        elif path.startswith('/api/chat/'):
            try:
                user_id = int(path.split('/')[-1])
                cursor.execute('SELECT content, is_user, created_at FROM chat_messages WHERE user_id = ? ORDER BY created_at', (user_id,))
                messages = []
                for row in cursor.fetchall():
                    messages.append({
                        'content': row[0],
                        'is_user': bool(row[1]),
                        'created_at': row[2]
                    })
                self.send_json_response({'status': 'success', 'messages': messages})
            except Exception as e:
                self.send_json_response({'status': 'error', 'message': str(e)}, 500)
        
        elif path.startswith('/api/artworks/'):
            try:
                user_id = int(path.split('/')[-1])
                cursor.execute('SELECT id, prompt, style, image_url, created_at FROM artworks WHERE user_id = ? ORDER BY created_at DESC', (user_id,))
                artworks = []
                for row in cursor.fetchall():
                    artworks.append({
                        'id': row[0],
                        'prompt': row[1],
                        'style': row[2],
                        'image_url': row[3],
                        'created_at': row[4]
                    })
                self.send_json_response({'status': 'success', 'artworks': artworks})
            except Exception as e:
                self.send_json_response({'status': 'error', 'message': str(e)}, 500)
        
        elif path.startswith('/api/emotion-analysis/'):
            try:
                user_id = int(path.split('/')[-1])
                cursor.execute('SELECT emotion_type, score, created_at FROM emotion_records WHERE user_id = ? ORDER BY created_at', (user_id,))
                records = cursor.fetchall()
                
                if not records:
                    self.send_json_response({
                        'status': 'success',
                        'trend': [65, 59, 80, 81, 56, 55, 70],
                        'distribution': {'平静': 45, '开心': 30, '焦虑': 15, '难过': 10},
                        'report': {
                            'overall_status': '稳定',
                            'main_emotion': '平静',
                            'fluctuation': '低',
                            'suggestion': '继续保持积极心态'
                        }
                    })
                else:
                    trend = [r[1] for r in records[-7:]]
                    distribution = {}
                    for r in records:
                        distribution[r[0]] = distribution.get(r[0], 0) + 1
                    total = sum(distribution.values())
                    distribution = {k: round(v/total*100) for k, v in distribution.items()}
                    
                    self.send_json_response({
                        'status': 'success',
                        'trend': trend,
                        'distribution': distribution,
                        'report': {
                            'overall_status': '稳定' if max(trend) - min(trend) < 20 else '波动',
                            'main_emotion': max(distribution, key=distribution.get),
                            'fluctuation': '低' if max(trend) - min(trend) < 15 else '高',
                            'suggestion': '继续保持积极心态'
                        }
                    })
            except Exception as e:
                self.send_json_response({'status': 'error', 'message': str(e)}, 500)
        
        else:
            self.send_json_response({'status': 'error', 'message': 'Not found'}, 404)
    
    def do_POST(self):
        parsed_path = urllib.parse.urlparse(self.path)
        path = parsed_path.path
        
        try:
            content_length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(content_length).decode('utf-8')
            data = json.loads(body) if body else {}
        except Exception as e:
            self.send_json_response({'status': 'error', 'message': 'Invalid JSON'}, 400)
            return
        
        if path == '/api/register':
            try:
                name = data.get('name')
                email = data.get('email')
                password = data.get('password')
                
                if not name or not email or not password:
                    self.send_json_response({'status': 'error', 'detail': '请填写所有字段'}, 400)
                    return
                
                cursor.execute('SELECT id FROM users WHERE email = ?', (email,))
                if cursor.fetchone():
                    self.send_json_response({'status': 'error', 'detail': '邮箱已被注册'}, 400)
                    return
                
                password_hash = hashlib.sha256(password.encode()).hexdigest()
                created_at = datetime.now().isoformat()
                
                cursor.execute('INSERT INTO users (name, email, password_hash, created_at) VALUES (?, ?, ?, ?)',
                            (name, email, password_hash, created_at))
                conn.commit()
                
                user_id = cursor.lastrowid
                self.send_json_response({'status': 'success', 'user_id': user_id, 'message': '注册成功'})
            except Exception as e:
                self.send_json_response({'status': 'error', 'message': str(e)}, 500)
        
        elif path == '/api/login':
            try:
                email = data.get('email')
                password = data.get('password')
                
                if not email or not password:
                    self.send_json_response({'status': 'error', 'detail': '请填写所有字段'}, 400)
                    return
                
                cursor.execute('SELECT id, name, password_hash FROM users WHERE email = ?', (email,))
                user = cursor.fetchone()
                
                if not user:
                    self.send_json_response({'status': 'error', 'detail': '邮箱或密码错误'}, 400)
                    return
                
                password_hash = hashlib.sha256(password.encode()).hexdigest()
                if user[2] != password_hash:
                    self.send_json_response({'status': 'error', 'detail': '邮箱或密码错误'}, 400)
                    return
                
                self.send_json_response({'status': 'success', 'user_id': user[0], 'name': user[1], 'email': email})
            except Exception as e:
                self.send_json_response({'status': 'error', 'message': str(e)}, 500)
        
        elif path == '/api/chat':
            try:
                user_id = data.get('user_id')
                message = data.get('message')
                
                if not user_id or not message:
                    self.send_json_response({'status': 'error', 'detail': '缺少参数'}, 400)
                    return
                
                created_at = datetime.now().isoformat()
                cursor.execute('INSERT INTO chat_messages (user_id, content, is_user, created_at) VALUES (?, ?, 1, ?)',
                            (user_id, message, created_at))
                conn.commit()
                
                # 生成AI回复
                response = AI_RESPONSES[hash(message) % len(AI_RESPONSES)]
                
                created_at = datetime.now().isoformat()
                cursor.execute('INSERT INTO chat_messages (user_id, content, is_user, created_at) VALUES (?, ?, 0, ?)',
                            (user_id, response, created_at))
                conn.commit()
                
                self.send_json_response({'status': 'success', 'response': response})
            except Exception as e:
                self.send_json_response({'status': 'error', 'message': str(e)}, 500)
        
        elif path == '/api/generate-art':
            try:
                user_id = data.get('user_id')
                prompt = data.get('prompt')
                style = data.get('style')
                
                if not user_id or not prompt:
                    self.send_json_response({'status': 'error', 'detail': '缺少参数'}, 400)
                    return
                
                # 生成图像URL
                prompt_encoded = urllib.parse.quote(f'情绪艺术: {prompt}，风格: {style}')
                image_url = f'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt={prompt_encoded}&image_size=landscape_16_9'
                
                created_at = datetime.now().isoformat()
                cursor.execute('INSERT INTO artworks (user_id, prompt, style, image_url, created_at) VALUES (?, ?, ?, ?, ?)',
                            (user_id, prompt, style, image_url, created_at))
                conn.commit()
                
                self.send_json_response({'status': 'success', 'image_url': image_url})
            except Exception as e:
                self.send_json_response({'status': 'error', 'message': str(e)}, 500)
        
        else:
            self.send_json_response({'status': 'error', 'message': 'Not found'}, 404)
    
    def log_message(self, format, *args):
        pass

if __name__ == '__main__':
    server = http.server.HTTPServer(('0.0.0.0', 8000), RequestHandler)
    print('Server running on http://localhost:8000')
    server.serve_forever()