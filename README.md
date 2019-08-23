# Q-SYS-Lighting-Desk
A virtual lighting desk for QSC Q-SYS system.
# What is this?
This is a virtual lighting desk for Q-SYS that will output a maximum of 512 channels of decimal binary ranging from 0-255 in value. This mixer also has a scenes that are programmable by lifting the faders and pressing the momentary button asscociated with the scenes fader. The script then be used via sACN or Art-Net to communicate with your lighting equipment.

# How to Use
Either copy the design in the .qsys file or copy the script into a control script component to implement your own design.
Within the script there are two variables NUM_CHANNELS and NUM_SCENES, edit these values to match the number of scene faders and channels faders needed. below are the constraints for the design

* Momentary components must equal the number of scene faders

* CHANNEL FADERS ARE CONNECTED TO CONTROL SCRIPT FIRST AND MUST BE AN INTEGER FADER/KNOB FROM 0 - 255 IN VALUE

* SCENES FADER ARE CONNECTED TO THE CONTROL SCRIPT INPUT NUMBER : NUM_CHANNELS +1 AND ALSO BE AN INTEGER FADER/KNOB FROM 0 - 255 IN VALUE
* MASTER FADER MUST BE CONNECTED TO CONTROL SCRIPT INPUT NUMBER : NUM_CHANNELS + NUM_SCENES +1. 

* MOMENTARY BUTTON ARE USED FOR SCENE STATE RECORDERS THEY ARE CONNECTED TO CONTROL SCRIPT INPUT NUMBER: NUM_CHANNELS + NUM_SCENES +2 

* OUTPUT CUSTOM CONTROL LEDS ARE TO BE LINKED UP ON THE OUPUT PINS AFTER THE TEXT/VALUE OUTPUT. BOTH THESE OUPUT PINS ARE EQUAL TO THE NUMBER OF CHANNELS


![Image of ExamnpleDesign](https://github.com/adamrcarter/Q-SYS-Lighting-Desk/blob/master/ExampleDesign.png)
