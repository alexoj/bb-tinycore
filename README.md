# TinyCore for BeagleBone Black and BeagleBoard xM

This project is a migration of TinyCore to the ARM development boards
BeagleBone Black and BeagleBoard xM.

It was developed by me, Alejandro Ojeda Gutiérrez <alex@x3y.org>,
as a final degree project for the University of Seville, under the supervision
of professor Daniel Cagigas Muñiz <http://personal.us.es/dcagigas>.

To build the project, have Docker installed and type:

    $ make shell        # Start a shell inside the container with all
                        # the build tools.

    # Inside the container shell, type:

    $ make bbblack      # or make beaglexm
    $ make

Full documentation for the project is available under `docs/report.pdf`

Any code written by me is licensed under GPLv2, any other projects used are
under their respective licenses. Please check their websites for details.

Note that as I do not hold the hardware in my possession anymore, I am
unable to give any sort of support. The project is provided as is without
warranty of any kind.
