from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Integer, String, DateTime, Text, Float
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from datetime import datetime
import hashlib
import uuid
import os

# 创建数据库
SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# 数据库模型
class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    email = Column(String, unique=True, index=True)
    password_hash = Column(String)
    created_at = Column(DateTime, default=datetime.now)

class ChatMessage(Base):
    __tablename__ = "chat_messages"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer)
    content = Column(Text)
    is_user = Column(Integer)
    created_at = Column(DateTime, default=datetime.now)

class EmotionRecord(Base):
    __tablename__ = "emotion_records"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer)
    emotion_text = Column(Text)
    emotion_type = Column(String)
    score = Column(Float)
    created_at = Column(DateTime, default=datetime.now)

class Artwork(Base):
    __tablename__ = "artworks"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer)
    prompt = Column(Text)
    style = Column(String)
    image_url = Column(String)
    created_at = Column(DateTime, default=datetime.now)

Base.metadata.create_all(bind=engine)

app = FastAPI(title="心迹 - AI情感陪伴与情绪艺术生成系统")

# CORS配置
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 依赖项
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# 请求模型
class UserRegister(BaseModel):
    name: str
    email: str
    password: str

class UserLogin(BaseModel):
    email: str
    password: str

class ChatRequest(BaseModel):
    user_id: int
    message: str

class ArtGenerateRequest(BaseModel):
    user_id: int
    prompt: str
    style: str

# 用户认证API
@app.post("/api/register")
def register(user: UserRegister, db: Session = Depends(get_db)):
    # 检查邮箱是否已存在
    existing_user = db.query(User).filter(User.email == user.email).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="邮箱已被注册")
    
    # 创建新用户
    password_hash = hashlib.sha256(user.password.encode()).hexdigest()
    new_user = User(name=user.name, email=user.email, password_hash=password_hash)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    return {"status": "success", "user_id": new_user.id, "message": "注册成功"}

@app.post("/api/login")
def login(user: UserLogin, db: Session = Depends(get_db)):
    # 查找用户
    db_user = db.query(User).filter(User.email == user.email).first()
    if not db_user:
        raise HTTPException(status_code=400, detail="邮箱或密码错误")
    
    # 验证密码
    password_hash = hashlib.sha256(user.password.encode()).hexdigest()
    if db_user.password_hash != password_hash:
        raise HTTPException(status_code=400, detail="邮箱或密码错误")
    
    return {"status": "success", "user_id": db_user.id, "name": db_user.name, "email": db_user.email}

# 聊天API
@app.post("/api/chat")
def chat(request: ChatRequest, db: Session = Depends(get_db)):
    # 保存用户消息
    user_message = ChatMessage(user_id=request.user_id, content=request.message, is_user=1)
    db.add(user_message)
    db.commit()
    
    # 生成AI回复（模拟，实际需要接入AI API）
    ai_response = generate_ai_response(request.message)
    
    # 保存AI消息
    ai_message = ChatMessage(user_id=request.user_id, content=ai_response, is_user=0)
    db.add(ai_message)
    db.commit()
    
    return {"status": "success", "response": ai_response}

@app.get("/api/chat/{user_id}")
def get_chat_history(user_id: int, db: Session = Depends(get_db)):
    messages = db.query(ChatMessage).filter(ChatMessage.user_id == user_id).order_by(ChatMessage.created_at).all()
    return {"status": "success", "messages": [
        {"content": msg.content, "is_user": bool(msg.is_user), "created_at": msg.created_at.isoformat()}
        for msg in messages
    ]}

# 艺术生成API
@app.post("/api/generate-art")
def generate_art(request: ArtGenerateRequest, db: Session = Depends(get_db)):
    # 生成艺术作品（模拟，实际需要接入图像生成API）
    image_url = generate_image(request.prompt, request.style)
    
    # 保存记录
    artwork = Artwork(user_id=request.user_id, prompt=request.prompt, style=request.style, image_url=image_url)
    db.add(artwork)
    db.commit()
    
    return {"status": "success", "image_url": image_url}

@app.get("/api/artworks/{user_id}")
def get_artworks(user_id: int, db: Session = Depends(get_db)):
    artworks = db.query(Artwork).filter(Artwork.user_id == user_id).order_by(Artwork.created_at.desc()).all()
    return {"status": "success", "artworks": [
        {"id": art.id, "prompt": art.prompt, "style": art.style, "image_url": art.image_url, "created_at": art.created_at.isoformat()}
        for art in artworks
    ]}

# 情绪分析API
@app.get("/api/emotion-analysis/{user_id}")
def get_emotion_analysis(user_id: int, db: Session = Depends(get_db)):
    # 获取用户情绪记录
    records = db.query(EmotionRecord).filter(EmotionRecord.user_id == user_id).order_by(EmotionRecord.created_at).all()
    
    if not records:
        # 返回默认数据
        return {
            "status": "success",
            "trend": [65, 59, 80, 81, 56, 55, 70],
            "distribution": {"平静": 45, "开心": 30, "焦虑": 15, "难过": 10},
            "report": {
                "overall_status": "稳定",
                "main_emotion": "平静",
                "fluctuation": "低",
                "suggestion": "继续保持积极心态"
            }
        }
    
    # 计算情绪趋势（最近7天）
    trend = [record.score for record in records[-7:]]
    
    # 计算情绪分布
    distribution = {}
    for record in records:
        distribution[record.emotion_type] = distribution.get(record.emotion_type, 0) + 1
    
    total = sum(distribution.values())
    distribution = {k: round(v/total*100) for k, v in distribution.items()}
    
    return {
        "status": "success",
        "trend": trend,
        "distribution": distribution,
        "report": {
            "overall_status": "稳定" if max(trend) - min(trend) < 20 else "波动",
            "main_emotion": max(distribution, key=distribution.get),
            "fluctuation": "低" if max(trend) - min(trend) < 15 else "高",
            "suggestion": "继续保持积极心态"
        }
    }

# 模拟AI回复（实际需要接入AI API）
def generate_ai_response(message: str) -> str:
    # 这里应该调用真正的AI API
    # 示例：使用模拟回复
    responses = [
        "我理解你的感受，谢谢你的分享。我会一直在这里陪伴你。",
        "听起来你今天经历了很多，我很愿意倾听。",
        "你并不孤单，我们一起面对。",
        "谢谢你愿意和我分享这些，这需要很大的勇气。",
        "我能感受到你的情绪，让我们一起探讨一下。"
    ]
    return responses[hash(message) % len(responses)]

# 模拟图像生成（实际需要接入图像生成API）
def generate_image(prompt: str, style: str) -> str:
    # 使用Trae API生成图像
    prompt_encoded = prompt.replace(" ", "%20")
    return f"https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt={prompt_encoded}&image_size=landscape_16_9"

# 健康检查
@app.get("/api/health")
def health_check():
    return {"status": "ok"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)