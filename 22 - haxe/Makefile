%.cpp: %.hx
	haxe --main $* --cpp build/$@

%.jar: %.hx
	haxe --main $* --jvm build/$@

clean:
	rm -r build && mkdir build