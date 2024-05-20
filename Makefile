KUBERNETES_VERSION=1.22.4
DOCKER_CI=ghcr.io/someone-stole-my-name/yaml.nvim-ci:0.8.0

lint:
	stylua -c .

test: lint
	nvim --headless --noplugin -u tests/minimal_init.vim -c "PlenaryBustedDirectory tests  { minimal_init = './tests/minimal_init.vim' }"

packer:
	git clone --depth 1 https://github.com/wbthomason/packer.nvim \
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
	nvim --headless --noplugin -u tests/packer.lua -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

generate-kubernetes: generate_kubernetes_version generate_kubernetes_resources

generate_kubernetes_resources:
	perl resources/scripts/generate_kubernetes_resources.pl > lua/yaml-companion/builtin/kubernetes/resources.lua

generate_kubernetes_version:
	perl resources/scripts/generate_kubernetes_version.pl ${KUBERNETES_VERSION} > lua/yaml-companion/builtin/kubernetes/version.lua

docker-%:
	docker run \
		--rm \
		--privileged \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $(shell pwd):/data \
		-w /data $(DOCKER_EXTRA_ARGS) \
		$(DOCKER_CI) sh -c "rm -rf /root/.local/state && make packer && make $*"
