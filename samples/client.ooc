use zeromq
import zeromq

main: func {
    
    //  The only application thread is the main thread.
    //  One I/O thread in the thread pool will do.
    //  This client is a requester
    //  Connect to the server
    s := Socket new(Context new(1), SocketType req). connect("tcp://localhost:5555")
    
    //  Send 20 requests and receive 20 replies
    for (i in 0..20) {
        
        //  Send the request. No point in filling the content in as server
        //  is a dummy and won't use it anyway.
        s send(Message new(10))
        
        "Sent request %d" format(i) println()
        
        //  Get the reply
        reply := s recv()
        
        "Got reply %d" format(i) println()
    }
    
}
