#!/bin/bash
#
# Script to selectively join inputs from 2 physical
# controllers into a single virtual one.
#
# Then it runs the HELI-X 11 sim.
#

#set -x
#DEBUG_MODE=1
CMD_PATH="/usr/local/bin"
CMD_NAME="evsieve"
COMMAND="${CMD_PATH}/${CMD_NAME}"
EVENTS_PATH="/dev/input/by-id"
JS_MATCH="*Saitek*X52*-event-joystick"
PDL_MATCH="*Saitek*Pedals*-event-joystick"
VIRT_COMBO="virtual-Saitek-combo-event"

# usage examples
#evtest ${EVENTS_PATH}/*Saitek*X52*-event-joystick
#evtest ${EVENTS_PATH}/*Saitek*Pedals*-event-joystick
#exit 0

# clear
PARAMS=""
# Define inputs with domain names:
# Joystick
PARAMS+=" --input ${EVENTS_PATH}/${JS_MATCH}  domain=S grab"
# Block rudder input from stick (twist)
# Directing it to a dummy domain since --block
# works globally on all previously defined inputs
PARAMS+=" --map abs:rz@S       abs:rz@NULL"
# Pass-through all this axes to the combined domain
PARAMS+=" --map abs:x@S        abs:x@COMBO"
PARAMS+=" --map abs:y@S        abs:y@COMBO"
PARAMS+=" --map abs:z@S        abs:z@COMBO"
PARAMS+=" --map abs:rx@S       abs:rx@COMBO"
PARAMS+=" --map abs:ry@S       abs:ry@COMBO"
PARAMS+=" --map abs:throttle@S abs:throttle@COMBO"
# Pedals
PARAMS+=" --input ${EVENTS_PATH}/${PDL_MATCH} domain=P grab"
# Block X/Y inputs from pedals (left/right breaks)
# Directing them to a dummy domain since --block
# works globally on all previously defined inputs
PARAMS+=" --map abs:x@P        abs:x@NULL"
PARAMS+=" --map abs:y@P        abs:y@NULL"
# Pass-through the rudder input
PARAMS+=" --map abs:rz@P       abs:rz@COMBO"
# Pass-through all buttons/keys from both devices
PARAMS+=" --toggle @S @COMBO"
PARAMS+=" --toggle @P @COMBO"

if [ -n "$DEBUG_MODE" ]; then
  PARAMS+=" --print @COMBO"
fi
# Define output to use all the combind events
PARAMS+=" --output @COMBO create-link=${EVENTS_PATH}/${VIRT_COMBO} name=\"HX\""

if [ -n "$DEBUG_MODE" ]; then
  echo "PARAMS='"$PARAMS"'"
#  exit 0
fi

# Execute the combind command
sudo $COMMAND $PARAMS &
# Save process id for the end
EVS_PID=$!
# Let everything settele
sleep 1

# Verify no errors from evsieve
PSCHECK=$(ps aux | awk '{print $2}' | grep $EVS_PID)
if [ -z "$PSCHECK" ]; then
  echo "error: evsieve failed to launch"
  exit 1
fi

if [ -n "$DEBUG_MODE" ]; then
  echo "EVS_PID='"$EVS_PID"'"
fi

# Run the simulator (or debug tools)
if [ -n "$DEBUG_MODE" ]; then
  jstest-gtk
#  evtest ${EVENTS_PATH}/${VIRT_COMBO}
else
  ~/SIMs/HELI-X11/runHELI-X.sh
fi

# Cleanup
sudo kill $EVS_PID
#sudo pkill $CMD_NAME
echo "Hardware restored to normal."
