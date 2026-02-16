import logging
import os
from logging.config import dictConfig


def setup_logging() -> None:
    """Configure console logging for local + container runs.

    Environment:
      - LOG_LEVEL (default: INFO)
    """
    level = os.getenv("LOG_LEVEL", "INFO").upper()

    dictConfig({
        "version": 1,
        "disable_existing_loggers": False,
        "formatters": {
            "default": {
                "format": "%(asctime)s | %(levelname)s | %(name)s | %(message)s"
            }
        },
        "handlers": {
            "console": {
                "class": "logging.StreamHandler",
                "formatter": "default",
            }
        },
        "root": {
            "level": level,
            "handlers": ["console"]
        },
        "loggers": {
            "uvicorn": {"level": level},
            "uvicorn.error": {"level": level},
            "uvicorn.access": {"level": level},
        }
    })

    logging.getLogger(__name__).info("Logging configured (level=%s)", level)
