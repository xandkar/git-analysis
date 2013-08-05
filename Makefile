deps:
	@./DEPENDENCIES.install

install:
	@mkdir -p "$$HOME/bin"
	@ln -sfv "$$(pwd)/src/git-analysis" "$$HOME/bin/git-analysis"
