ifeq (.private, $(wildcard .private))
    PRIVATE = 1
endif

bootstrap: setups secrets

setups:
	bundle install
	bundle exec pod install

secrets:
ifdef PRIVATE
	@cat .env > NimbleSurvey/Secrets/Secrets.swift
else
	@cp NimbleSurvey/Secrets/Secrets.swift.example NimbleSurvey/Secrets/Secrets.swift
endif
