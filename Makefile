.PHONY: backend build
.DEFAULT_GOAL= help

user = root
password=root
remote=innocent@192.168.100.4
path_to_publick_key="ssh -i $$HOME/.ssh/debian"
# remote=innocent@51.83.77.123
host=192.168.100.4
path_to_backend=/var/www/mobipick.com/backend/
path_to_frontend=/var/www/mobipick.com/frontend
NODE_ENV=production
service_name=index.js

#colors
_NO_COLOR=\033[m
_WARN_COLOR=\033[0;33m
_BOLD=\033[0;45m
_BOLD2=\x1b[32;01m
_GREEN=\033[32m
_BLUE=$'\x1b[34m'


help: 
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-10s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

backend: backend ## Deploy the backend to remote server

	@printf "%b" "$(_WARN_COLOR)[*] Sending backend files to $(host) $(_NO_COLOR) \n"

	@rsync -avq -e $(path_to_publick_key) ./backend/ $(ssh) $(remote):$(path_to_backend) \
		--exclude Makefile \
		--exclude .git \
		--exclude .idea \
		--exclude node_modules \
		--exclude .editorconfig \
		--exclude .eslintrc.js \
		--exclude .gitignore \
		--exclude README.md
		
	@printf "%b" "$(_GREEN)[+] Sending backend files to $(host) [OK] $(_NO_COLOR) \n"

	@printf "%b" "$(_WARN_COLOR)[*] Stopping the pm2 service $(service_name) $(_NO_COLOR) \n"

	pm2 stop $(service_name);

	@printf "%b" "$(_WARN_COLOR)[*] Deleting the  pm2 service $(service_name) $(_NO_COLOR) \n"

	pm2 delete $(service_name);

	@printf "%b" "$(_WARN_COLOR) [*] Instanlling dependencies $(_NO_COLOR) \n"

	$(ssh) $(remote) "cd $(path_to_backend); \
		npm install;
		env NODE_ENV=$(NODE_ENV) \
		pm2 start \
		npm --name $(service_name) \
		--instances 1 \
		--max-restarts 5 \
		-- run start:prod \
		pm2 save"

build: build ## Build angular frontend project
	ng build --prod
	
front: front ## Deploy the frontend

	@printf "%b" "$(_WARN_COLOR)[*] Sending frontend files to $(host) $(_NO_COLOR) \n"

	@rsync -aqv -e $(path_to_publick_key) ./frontend/ $(ssh) $(remote):$(path_to_frontend) \
		--exclude Makefile \
		--exclude .git \
		--exclude .idea \
		--exclude node_modules \
		--exclude .editorconfig \
		--exclude .eslintrc.js \
		--exclude .gitignore \
		--exclude README.md

	@printf "%b" "$(_GREEN)[+] Sending frontend files to $(host) [OK] $(_NO_COLOR) \n"