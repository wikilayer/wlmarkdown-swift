CORPUS = ../wlmarkdown/corpus
RULES = Sources/WLMarkdown/Resources
CASES = Tests/WLMarkdownTests/Resources

.PHONY: format lint test-build test build sync-corpus install

format:
	swiftlint --fix

lint:
	swiftlint --strict

test-build:
	swift build --build-tests

test:
	swift test

build:
	swift build

sync-corpus:
	cp $(CORPUS)/rules.yaml $(RULES)/
	cp $(CORPUS)/dialect.yaml $(CASES)/

install:
	brew install swiftlint
