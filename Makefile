
default:	build

clean:
	rm -rf Makefile objs

build:
	$(MAKE) -f objs/Makefile

install:
	$(MAKE) -f objs/Makefile install

modules:
	$(MAKE) -f objs/Makefile modules

upgrade:
	/system/bin/nginx -t

	kill -USR2 `cat /tmp/nginx.pid`
	sleep 1
	test -f /tmp/nginx.pid.oldbin

	kill -QUIT `cat /tmp/nginx.pid.oldbin`
