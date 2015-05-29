.PHONY : all 51 clean

macosx :
	cd ./pbc/; pwd; make lib
	gcc -O2 -Wall --shared -o ./../source/libs/protobuf.so -I./pbc/ -I/usr/local/include -I../skynet/3rd/lua/ -L/usr/local/bin -L../skynet/3rd/lua/ -L./pbc/build ./pbc/binding/lua/pbc-lua.c -lpbc -llua

linux :
	cd ./pbc/; pwd; make lib
	gcc -O2 -Wall --shared -o ./../source/libs/protobuf.so -I./pbc/ -I/usr/local/include -I../skynet/3rd/lua/ -L/usr/local/bin -L../skynet/3rd/lua/ -L./pbc/build ./pbc/binding/lua/pbc-lua.c -lpbc -llua


clean :
	rm ../source/libs/protobuf.so
	rm -rf ./pbc/build
