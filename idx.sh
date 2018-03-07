#!/bin/sh

deploy="deploy.tar.gz"

if [ -f "$deploy" ]; then
	tar -xzf "$deploy"
	rm "$deploy"
	echo "Deployed successfully"
fi

./bin/idx data/img.idx data/lbl.idx

