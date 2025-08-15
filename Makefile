.PHONY: build run clean init

IMAGE_NAME := google-auth-lib-test
GCLOUD_PROJECT_ID ?= avalabs-sec-app-env
SKIP_GCLOUD_AUTH_LOGIN ?=
SKIP_GCLOUD_CONFIG_SET_PROJECT ?=
SKIP_FIRST_TEST ?=
RUN_SLOW_TEST_AGAIN ?=
RUN_CURL_METADATA ?=
TCPDUMP ?=

init:
	git submodule update --init --recursive

build:
	docker build -t $(IMAGE_NAME) .

run:
	mkdir -p traces
	docker run -it --cap-add=NET_RAW --cap-add=SYS_PTRACE \
		-v $(PWD)/traces:/traces \
		--env GCLOUD_PROJECT_ID=$(GCLOUD_PROJECT_ID) \
		$(if $(SKIP_GCLOUD_AUTH_LOGIN),--env SKIP_GCLOUD_AUTH_LOGIN=$(SKIP_GCLOUD_AUTH_LOGIN)) \
		$(if $(SKIP_GCLOUD_CONFIG_SET_PROJECT),--env SKIP_GCLOUD_CONFIG_SET_PROJECT=$(SKIP_GCLOUD_CONFIG_SET_PROJECT)) \
		$(if $(SKIP_FIRST_TEST),--env SKIP_FIRST_TEST=$(SKIP_FIRST_TEST)) \
		$(if $(RUN_SLOW_TEST_AGAIN),--env RUN_SLOW_TEST_AGAIN=$(RUN_SLOW_TEST_AGAIN)) \
		$(if $(RUN_CURL_METADATA),--env RUN_CURL_METADATA=$(RUN_CURL_METADATA)) \
		$(if $(TCPDUMP),--env TCPDUMP=$(TCPDUMP)) \
		$(IMAGE_NAME)

clean:
	docker rmi $(IMAGE_NAME) 2>/dev/null || true

help:
	@echo "Available targets:"
	@echo "  init   - Initialize git submodules"
	@echo "  build  - Build the Docker image"
	@echo "  run    - Run the container with debugging capabilities"
	@echo "  clean  - Remove the Docker image"
	@echo "  help   - Show this help message"
	@echo ""
	@echo "Customization:"
	@echo "  GCLOUD_PROJECT_ID - Google Cloud project ID (default: $(GCLOUD_PROJECT_ID))"
	@echo "  SKIP_GCLOUD_AUTH_LOGIN - Skip 'gcloud auth login' step (unset by default)"
	@echo "  SKIP_GCLOUD_CONFIG_SET_PROJECT - Skip 'gcloud config set project' step (unset by default)"
	@echo ""
	@echo "Usage examples:"
	@echo "  make build GCLOUD_PROJECT_ID=your-project-id"
	@echo "  GCLOUD_PROJECT_ID=your-project-id make build"
	@echo "  make run SKIP_GCLOUD_AUTH_LOGIN=1"
	@echo "  SKIP_GCLOUD_AUTH_LOGIN=1 SKIP_GCLOUD_CONFIG_SET_PROJECT=1 make run"
