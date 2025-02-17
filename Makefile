
UNAME := $(shell uname)
ifeq ($(UNAME),Darwin)
	OS := "macos"
else ifeq ($(UNAME),Linux)
	OS := "linux"
endif

setup:
	@docker compose -f docker-compose-$(OS).yaml up -d
