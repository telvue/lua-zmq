Steps to install on Windows XP (using MinGW+MSYS)
-------------------------------------------------

1. Download source code of ZeroMQ-2.1.7

2. Use mingw+msys to compile

	$ sh configure --prefix=c:/zeromq

	$ make

	$ make install

	copy the header & lib to c:\mingw\include_or_lib

3. Download source code of luajit-2.0.0-beta7

	$ make

	$ make install

	copy the header & lib to c:\mingw\include_or_lib

4. Install cmake-2.8.4-win32-x86

5. Download Neopallium-lua-zmq-1.1

6. Use cmake+mingw+msys to build

	$ mkdir build

	$ cd build

	$ cmake -G "MSYS Makefiles" -D ZMQ_PATH=c:/zeromq ..

 	$ make

	$ make install

	Files zmq.dll, poller.lua and threads.lua are installed in c:\program files\lua-zmq

Author
------
 xumingyong@gmail.com
xumingyong@ehdc.com.cn


