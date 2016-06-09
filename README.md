# Pandora's Box
A dynamic music visualizer built in Processing that utilizes the Minim audio library.

-------------------------
Requirements
-------------------------
This program requires Processing version 3.0 or higher as well as the Minim audio library

-Processing can be downloaded here: https://processing.org/download/
-Minim can be downloaded within the Processing environment

-------------------------
Running Pandora's Box
-------------------------
After downloading and opening Processing, simply paste the provided code in and press play.
You should be prompted with a file selector. The program will run any audio files of format  WAV, AIFF, AU, SND, or MP3.
If your file is not playing, it is most likely of type M4A and will need to be converted into a different format.

-------------------------
Performance Issues
-------------------------
Pandora's Box may run slowly depending on the computer you run it on. 
This is because the program is constantly updating the screen with up to 200 squares.
To fix this, change the variable MAX_SQUARES found in the first few lines of code.
(Note: This will simplify the look of the visualizer and make it a bit more basic)
