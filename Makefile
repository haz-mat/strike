.DEFAULT_GOAL := build
.PHONY: run build clean docker docker-run
OS := $(shell uname | tr '[:upper:]' '[:lower:]')
ct_version = 0.4.2

ct_filename := ct-v$(ct_version)-x86_64-unknown-$(OS)-gnu
ct_sha256 := 9b6e2c1a1ea9e0f85f6b1e8711932c4761965a800f3381a75f960a493162502a

build: | app/bin/$(ct_filename)
	cd app; \
		python3 -m venv venv && \
		. "venv/bin/activate" && \
			pip3 install -Ur requirements.txt

app/bin/$(ct_filename):
	cd app; \
		mkdir -p bin && \
		cd ./bin && \
			curl -OL 'https://github.com/coreos/container-linux-config-transpiler/releases/download/v$(ct_version)/$(ct_filename)' && \
			echo "$(ct_sha256)  $(ct_filename)" | sha256sum -c && \
			chmod +x '$(ct_filename)' && \
			ln -sf '$(ct_filename)' ct

run: build
	mkdir -p srv
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
		--env=FLASK_DEBUG=1 \
		strike

clean:
	rm -rf app/venv app/bin app/__pycache__
	docker stop strike || :
	docker rm strike || :
	docker rmi strike || :
