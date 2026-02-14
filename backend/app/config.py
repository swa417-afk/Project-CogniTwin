from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str = "postgresql://cognitwin:cognitwin@db:5432/cognitwin"
    cors_origins: str = "http://localhost:5173,http://localhost:3000"
    
    class Config:
        env_file = ".env"

settings = Settings()
