
## How to use Roswell to build and share binaries

From the project root:

Run as a script:

    chmod +x roswell/calimero.ros
    ./roswell/calimero.ros

Build a binary:

    ros build roswell/calimero.ros

and run it:

    ./roswell/calimero

Or install it in ~/.roswell/bin:

    ros install roswell/calimero.ros

It creates the binary in ~/.roswell/bin/
Run it:

    ~/.roswell/bin/calimero [name]~&

Your users can install the script with ros install vendethiel/calimero

Use `+Q` if you don't have Quicklisp dependencies to save startup time.
Use `ros build --disable-compression` to save on startup time and loose on application size.


## See

- https://github.com/roswell/roswell/wiki/
- https://github.com/roswell/roswell/wiki/Reducing-Startup-Time
