SWIFT_IMAGE_VER=5.3

.PHONY: test-linux-setup test-linux linux test-macos test-all-platform

test-linux-setup:
	docker run --rm \
		--volume "$(CURDIR):/src" \
		--workdir "/src" \
		swift:$(SWIFT_IMAGE_VER) \
		swift test --generate-linuxmain

test-linux: test-linux-setup
	docker run --rm \
		--volume "$(CURDIR):/src" \
		--workdir "/src" \
		swift:$(SWIFT_IMAGE_VER) \
		swift test

linux:
	docker run --rm -it \
		--volume "$(CURDIR):/src" \
		--workdir "/src" \
		swift:$(SWIFT_IMAGE_VER)

test-macos:
	swift test
