.DEFAULT_GOAL := build
.PHONY: run build clean docker docker-run
OS := $(shell uname | tr '[:upper:]' '[:lower:]')

ct_filename = ct-v$(ct_version)-x86_64-unknown-$(OS)-gnu
ct_version = 0.7.0
ct_sha256 := dca78785b487ad4fae135699ca0f48aa95ce736b0a67c2ec6bdc14ca4cbe05c4

build: | app/bin/$(ct_filename)
	cd app; \
		python3 -m venv venv && \
		. "venv/bin/activate" && \
			pip3 install -U pip && \
			pip3 install -Ur requirements.txt

app/bin/$(ct_filename):
	cd app; \
		mkdir -p bin && \
		cd ./bin && \
			curl -OL 'https://github.com/coreos/container-linux-config-transpiler/releases/download/v$(ct_version)/$(ct_filename)' && \
			{ \
				echo "$(ct_sha256)  $(ct_filename)" | sha256sum -c || rm "$(ct_filename)"; \
			} && \
			chmod +x '$(ct_filename)' && \
			ln -sf '$(ct_filename)' ct

run: build
	mkdir -p srv/ignition srv/static
	cd app; \
		. "venv/bin/activate" && \
			FLASK_DEBUG=1 FLASK_APP=strike.py STRIKE_SRV_DIR=../srv flask run

docker-build:
	docker stop strike || :
	docker rm strike || :
	docker rmi strike || :
	docker build -t strike .

docker-run: docker-build
	docker run \
		--rm \
		--tty=true \
		--interactive=true \
		--net=host \
		--name strike \
		-v $(shell pwd)/srv:/srv/strike \
		strike

clean:
	rm -rf app/venv app/bin app/__pycache__
	docker stop strike || :
	docker rm strike || :
	docker rmi strike || :
