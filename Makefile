ifeq (.private, $(wildcard .private))
    PRIVATE = 1
endif

bootstrap: secrets

secrets:
ifdef PRIVATE
	@cat .env > NimbleSurvey/Secrets/Secrets.swift
else
	@cp NimbleSurvey/Secrets/Secrets.swift.example NimbleSurvey/Secrets/Secrets.swift
endif
