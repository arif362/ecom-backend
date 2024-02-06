#!/bin/bash
	cd $EB_CONFIG_APP_CURRENT
	wget https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-0.5.0.tar.gz
	tar xvzf libwebp-0.5.0.tar.gz
	cd libwebp-0.5.0
	sudo ./configure
	sudo make
	sudo make install