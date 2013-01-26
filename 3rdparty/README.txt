3rd party components needed for The Advanced Online Translator.

The connys-qt-components folder contains Symbian Qt Components
adaptation for BlackBerry. This is needed to be able to use
Symbian-style Qt Components on BlackBerry.

More information is available here:
http://kodira.de/2012/12/qt-components-on-blackberry-10/

To build these components start your terminal/command line of choice,
run the Blackberry 10 development environment setup script (bbndk-env.sh
or bbndk-env.bat, depending on your platform), change to
connys-qt-components folder and run:
> configure -symbian -no-mobility -nomake tests -nomake examples -nomake demos
> make


$Id: $Format:%h %ai %an$ $
