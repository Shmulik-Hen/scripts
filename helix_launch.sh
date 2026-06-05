#!/bin/bash

#set -x
#DEBUG_MODE=1
CMD_PATH="/usr/local/bin"
CMD_NAME="evsieve"
COMMAND="${CMD_PATH}/${CMD_NAME}"
EVENTS_PATH="/dev/input/by-id"
VIRT_COMBO="virtual-Saitek-combo-event"

PARAMS=""
PARAMS+=" --input ${EVENTS_PATH}/*Saitek*X52*-event-joystick    domain=S grab"
PARAMS+=" --input ${EVENTS_PATH}/*Saitek*Pedals*-event-joystick domain=P grab"
PARAMS+=" --map abs:x@S        abs:x@COMBO"
PARAMS+=" --map abs:y@S        abs:y@COMBO"
PARAMS+=" --map abs:z@S        abs:z@COMBO"
PARAMS+=" --map abs:rx@S       abs:rx@COMBO"
PARAMS+=" --map abs:ry@S       abs:ry@COMBO"
PARAMS+=" --map abs:throttle@S abs:throttle@COMBO"
PARAMS+=" --map abs:rz@S       abs:rz@NULL"
PARAMS+=" --map abs:rz@P       abs:rz@COMBO"
PARAMS+=" --map abs:x@P        abs:x@NULL"
PARAMS+=" --map abs:y@P        abs:y@NULL"
if [ -n "$DEBUG_MODE" ]; then
  PARAMS+=" --print @COMBO"
fi
PARAMS+=" --output @COMBO create-link=${EVENTS_PATH}/${VIRT_COMBO} name=\"HX\""

if [ -n "$DEBUG_MODE" ]; then
  echo "PARAMS='"$PARAMS"'"
#  exit 0
fi

sudo $COMMAND $PARAMS &
EVS_PID=$!
sleep 1

PSCHECK=$(ps aux | awk '{print $2}' | grep $EVS_PID)
if [ -z "$PSCHECK" ]; then
  echo "error: evsieve failed to launch"
  exit 1
fi

if [ -n "$DEBUG_MODE" ]; then
  echo "EVS_PID='"$EVS_PID"'"
fi

if [ -n "$DEBUG_MODE" ]; then
  jstest-gtk
#  evtest ${EVENTS_PATH}/${VIRT_COMBO}
else
  ~/SIMs/HELI-X11/runHELI-X.sh
fi

sudo kill $EVS_PID
#sudo pkill $CMD_NAME
echo "Hardware restored to normal."
