32x-autohz
==========

   32X 50/60Hz automatic slave switch

   Copyright (C) 2012 by Maximilian Rehkopf (ikari_01) <otakon@gmx.net>
   Idea by n00b

   This program is designed to run on a PIC12F629 or compatible micro
   controller. It determines the frequency of the VSync signal on pin 5
   and switches the output level of pin 6 accordingly (50Hz = 0V; 60Hz = 5V).

   This program is released to the public domain; it is the wish of the
   author that the original attributions stated above remain unchanged.

 ---------------------------------------------------------------------

   pin configuration:

                       ,---_---.
                   +5V |1     8| GND
                    nc |2     7| nc
                    nc |3     6| 50/60Hz switch out
                    nc |4     5| Vsync in (TTL)
                       `-------'

  Vsync can be taken from cartridge slot pin B13 or CN4 pin 15.
  No sync separator required.
