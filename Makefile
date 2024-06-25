SHELL := /bin/bash
PWD:=$(shell pwd)
SCHEME ?= LuLu
WORKSPACE_DIR=$(PWD)/lulu.xcworkspace
DSTROOT=/tmp/Applications/
XCODEBUILD=xcodebuild -workspace $(WORKSPACE_DIR) -scheme $(SCHEME)

help:
	@printf "Available targets:\n\n"
	@printf "	help				Show this help message\n"
	@printf "	clean				Clean build products on actual build folder\n"
	@printf "	build				Build the project\n"
	@printf "	test				Run the unit tests\n"
	@printf "	install				Install application\n"

all: clean install

clean:
	$(XCODEBUILD) clean

test:
	$(XCODEBUILD) test

build: test
	$(XCODEBUILD) build

install: test
	$(XCODEBUILD) install DSTROOT=$(DSTROOT)

default: help
