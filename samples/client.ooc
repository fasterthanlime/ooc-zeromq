use zeromq
import zeromq, structs/ArrayList

main: func (args: ArrayList<String>) {
    
    //  The only application thread is the main thread.
    //  One I/O thread in the thread pool will do.
    //  This client is a requester
    //  Connect to the server
    addr := args size < 2 ? "tcp://localhost:5555" : "tcp://%s:5555" format(args[1])
    "Connecting to %s" format(addr toCString()) println()
    s := Socket new(Context new(1), SocketType req). connect(addr)
    
    //  Send 20 requests and receive 20 replies
    for (i in 0..20) {
        //scan the user's message
        message := stdin readLine()
        
        //  Send the request. No point in filling the content in as server
        //  is a dummy and won't use it anyway.
        s send(Message new(message toCString(), message length(), null, null))
        
        "Sent request %d" format(i) println()
        
        //  Get the reply
        reply := s recv()
        
        "Got reply %d" format(i) println()
    }
    
}
