CORPUS = ../wlmarkdown/corpus
RULES = Sources/WLMarkdown/Resources
CASES = Tests/WLMarkdownTests/Resources

.DEFAULT_GOAL := build

.PHONY: format lint test-build test docs build sync-corpus install

format:
	swiftlint --fix

lint:
	swiftlint --strict

test-build:
	swift build --build-tests

test:
	swift test

docs:
	swift package --allow-writing-to-directory .build/docc generate-documentation \
		--target WLMarkdown --output-path .build/docc \
		--warnings-as-errors \
		--transform-for-static-hosting \
		--hosting-base-path wlmarkdown-swift

build: lint test-build test docs
	swift build

sync-corpus:
	cp $(CORPUS)/rules.yaml $(RULES)/
	cp $(CORPUS)/dialect.yaml $(CASES)/
	cp $(CORPUS)/plain_text.yaml $(CASES)/

install:
	brew install swiftlint
