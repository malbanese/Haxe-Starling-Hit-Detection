all:
	mkdir -p bin
	haxe -cp ../../src \
	-swf-header 1280:720:120:000000 \
	-swf-version 11.3 \
	-swf bin/Circles.swf \
	-swf-lib ../../starling.swc \
	--macro "patchTypes('../../starling.patch')" \
	-main com.cykon.haxe.example.Circles

run:
	make
	cygstart bin/Circles.swf

clean:
	rm bin/Circles.swf
	mkdir -p bin