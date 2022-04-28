NEOVIM_VERSION=0.7.0

lint:
	hadolint tests/Dockerfile
	stylua -c .

test: lint
	nvim --headless --noplugin -u tests/minimal_init.vim -c "PlenaryBustedDirectory tests  { minimal_init = './tests/minimal_init.vim' }"

packer:
	git clone --depth 1 https://github.com/wbthomason/packer.nvim \
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
	nvim --headless --noplugin -u tests/packer.lua -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

docker-build:
	docker build -t ci --build-arg NEOVIM_VERSION=${NEOVIM_VERSION} -f tests/Dockerfile .

docker-%: docker-build
	docker run \
		--rm \
		--privileged \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $(shell pwd):/data \
		-w /data $(DOCKER_EXTRA_ARGS) \
		ci sh -c "make packer && make $*"
