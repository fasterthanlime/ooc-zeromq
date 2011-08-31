use zeromq
import zeromq, structs/ArrayList

main: func (args: ArrayList<String>) {
    
    //  The only application thread is the main thread.
    //  One I/O thread in the thread pool will do.
    //  This client is a requester
    //  Connect to the server
    port := 5555

    addr := "tcp://%s:%d" format(match {
        case args size > 1 => args[1]
        case               => "localhost"
    }, port)

    "Connecting to %s" format(addr toCString()) println()
    s := Socket new(Context new(1), SocketType req). connect(addr)
    
    while (true) {
        "> " print()
        stdout flush()

        message := stdin readLine()

        // zeromq messages are binary strings, they don't care about encoding and stuff
        // we just use C-style zero-terminated strings here.
        s send(Message new(message toCString(), message length() + 1, null, null))

        // recv is a blocking call
        reply := s recv()

        // Let's hope the server isn't sending some carefully crafted byte sequence
        // that might make our client execute code as root. Oh noes!
        "< %s" printfln(reply data())
    }
    
}
