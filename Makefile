run:
	odin run . -out:bin/main -define:HEADLESS=true

gui:
	odin run . -out:bin/main

build:
	mkdir -p bin
	odin build . -out:bin/main -define:HEADLESS=true

clean:
	rm -rf bin
