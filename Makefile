PATH := ./node_modules/.bin:$(PATH)

.PHONY: build

build: assets
	zig build

.PHONY: build-pi

build-pi:
	zig build -Dtarget=arm-linux-musl -Doptimize=ReleaseFast

.PHONY: run

run: build
	./zig-out/bin/rm500

.PHONY: clean

clean:
	rm -fr run.sh
	rm -fr zig-out
	rm -fr zig-cache
	rm -fr src/main.css
	rm -fr src/main.js
	rm -fr src/index.html
	rm -fr node_modules

.PHONY: assets

assets: js css
	cp assets/index.html src/index.html

.PHONY: css
css: export NODE_ENV=production
css: node_modules
	tailwindcss -i assets/main.css -o src/main.css --minify

.PHONY: js

js: export NODE_ENV=production
js: node_modules
	esbuild assets/main.js --minify --bundle --outfile=src/main.js

node_modules: package.json 
	npm install

watch:
	fswatch --event=Updated --event=AttributeModified -o -0 -r assets src/main.zig \
		| xargs -0 -n1 bash -c "./run.sh"
