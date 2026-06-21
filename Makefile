IMAGE := cam-dof
TAG := $(shell git describe --tags --always --dirty)

.PHONY: build
build:
	docker build -t $(IMAGE) -t $(IMAGE):$(TAG) -t $(IMAGE):latest -t royratcliffe/$(IMAGE):latest .

# The container needs write-access to the host's /sys/class/pwm directory, so
# run it with --privileged and also with --network=host to allow it to access
# the Redis server running on the host.
.PHONY: run
run: build
	docker run --network=host --privileged --rm $(IMAGE):latest
