#
# PROLOG
#

# enter lolo directory
cd ../lolo-cli

#
# AKT 1: LICHTER
#

# print listing
./lolo.rb list

# Licht an! Dann rot, blau, gruen, hex. Dann kalt, warm.
./lolo.rb light L1 on
./lolo.rb light L1 red
./lolo.rb light L1 blue
./lolo.rb light L1 green
./lolo.rb light L1 hex 942b85
./lolo.rb light L1 cold
./lolo.rb light L1 warm

# Licht aus, naechster Akt.
./lolo.rb light L1 off

#
# AKT 2: GRUPPEN
#

# print listing
./lolo.rb list

# we're hopefully empty, create group All
./lolo.rb add group All

# add all lights to All
./lolo.rb add light L1 All
./lolo.rb add light L2 All
./lolo.rb add light L3 All

# list all lights
./lolo.rb list

# create group G1 with L1,L2
./lolo.rb add group G1
./lolo.rb add light L1 G1
./lolo.rb add light L2 G1

# create group G2 with L2, L3
./lolo.rb add group G2
./lolo.rb add light L2 G2
./lolo.rb add light L3 G2

# list all lights
./lolo.rb list

# Licht an! Dann rot, blau, hex. Dann kalt, warm.
./lolo.rb group All on
./lolo.rb group All red
./lolo.rb group All blue
./lolo.rb group All hex 942b85
./lolo.rb group All cold
./lolo.rb group All warm

# Erst G1 rot, dann wechseln zwei. Dann G2 rot, dann wechselt eine von vorher und eine neue.
# Dann alle auf kalt. Also, viele Kombinationen.
./lolo.rb group G1 red
./lolo.rb group G2 blue
./lolo.rb group All cold

# Licht aus, naechster Akt.
./lolo.rb group All off

#
# AKT 3: SZENEN
#

# print listing
./lolo.rb list

# Alle an, kalt speichern.
./lolo.rb light L1 blue
./lolo.rb light L2 white
./lolo.rb add scene blauweiss G1

# Rot, blau, speichern.
./lolo.rb light L1 red
./lolo.rb light L2 blue
./lolo.rb add scene rotblau G1

# Szene blauweiss!
./lolo.rb scene blauweiss on

# Szene rotblau!
./lolo.rb scene rotblau on

# Licht aus, naechster Akt.
./lolo.rb group All off

#
# AKT 4: OPTIONEN
#

# Licht an, kalt.
./lolo.rb group All cold

# Transition
./lolo.rb group All -t 0 blue
./lolo.rb group All -t 100 red

# Brightness
./lolo.rb group All bri 0
./lolo.rb group All bri 128
./lolo.rb group All bri 255
./lolo.rb group All -t 0 bri 0
./lolo.rb group All -t 0 bri 255

# Licht aus, naechster Akt.
./lolo.rb group All off

#
# EPILOG
#
