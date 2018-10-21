.PHONY: docs

docs:
	jazzy \
		--clean \
		--author Guillaume Algis \
		--author_url http://twitter.com/guillaumealgis \
		--github_url https://github.com/guillaumealgis/simplemdm-swift \
		--github-file-prefix https://github.com/guillaumealgis/simplemdm-swift/tree/$(tr -d '\n' < VERSION) \
		--module-version $(tr -d '\n' < VERSION) \
		--module SimpleMDM-Swift
