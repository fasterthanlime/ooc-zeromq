use zeromq
import zeromq, threading/Thread, os/Time, structs/ArrayList

main: func {
    
    //  We'll use 11 application threads. Main thread will be used to run
    //  'dispatcher' (queue). Aside of that there'll be 10 worker threads.
    ctx := Context new(1)
    
    //  Create an endpoint for worker threads to connect to.
    //  We are using an XREQ socket so that processing of one request
    //  won't block other requests.
    workers := Socket new(ctx, SocketType xreq)
    workers bind("inproc://workers")
    
    //  Create an endpoint for client applications to connect to.
    //  We are using an XREP socket so that processing of one request
    //  won't block other requests.
    clients := Socket new(ctx, SocketType xrep)
    port := 5555
    clients bind("tcp://0.0.0.0:%d" format(port))

    "Now listening on port %d" printfln(port)

    //  Launch 10 worker threads.
    for (i in 0..10) {
        t := Thread new(||
            //  This is the body of the worker thread(s).

            //  Worker thread is a 'replier', i.e. it receives requests and returns
            //  replies.
            s := Socket new(ctx, SocketType rep)

            //  Connect to the dispatcher (queue) running in the main thread.
            s connect("inproc://workers")

            while (true) {
                //  Get a request from the dispatcher.
                request := s recv()

                "> %s" printfln(request data())
            
                resp := String new(request data()) + " LOOOL"   
                "< %s" printfln(resp)

                s send(Message new(resp toCString(), resp length() + 1, null, null))
            }
        )
        t start()
    }

    //  Use queue device as a dispatcher of messages from clients to worker
    //  threads.
    zmq_device (ZMQ_QUEUE, clients, workers)

    return 0;
    
}
