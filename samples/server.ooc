use zeromq
import zeromq, threading/Thread, os/Time

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
    clients bind("tcp://0.0.0.0:5555")
 
    //  Launch 10 worker threads.
    for (i in 0..10) {
        Thread new(||
            //  This is the body of the worker thread(s).

            //  Worker thread is a 'replier', i.e. it receives requests and returns
            //  replies.
            s := Socket new(ctx, SocketType rep)

            //  Connect to the dispatcher (queue) running in the main thread.
            s connect("inproc://workers")

            while (true) {
                //  Get a request from the dispatcher.
                request := s recv()
                
                "Got a request!" println()
                
                //  Our server does no real processing. So let's sleep for a while
                //  to simulate actual processing.
                Time sleepSec(1)

                //  Send the reply. No point in filling the data in as the client
                //  is a dummy and won't check it anyway.
                s send(Message new(10))
            }
        ) start()
    }

    //  Use queue device as a dispatcher of messages from clients to worker
    //  threads.
    zmq_device (ZMQ_QUEUE, clients, workers)

    return 0;
    
}
