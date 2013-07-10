
VC=valac-0.20
VFLAGS=--pkg gtk+-3.0 --pkg gmodule-2.0
VSRC=main.vala

main: $(SRC_FILE)
#	$(VC) $(VFLAGS) $(VSRC) --disable-warnings -q --use-header -C -H main.h
	$(VC) $(VFLAGS) $(VSRC) -o main

clean:
	rm -f main

