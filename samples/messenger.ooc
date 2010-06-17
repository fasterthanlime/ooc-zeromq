use zeromq
import zeromq
import structs/ArrayList
import threading/Thread
import os/Time
main: func (args: ArrayList<String>) {
    ctx := Context new(1)
    Thread new(|| server(ctx)) start()
    Thread new(|| client(args, ctx)) start().wait()
}

server: func(ctx: Context) {
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
                " < %s" printfln(request data())
                
                //  Send the reply. No point in filling the data in as the client
                //  is a dummy and won't check it anyway.
                s send(Message new(10))
            }
        ) start()
    }

    //  Use queue device as a dispatcher of messages from clients to worker
    //  threads.
    zmq_device (ZMQ_QUEUE, clients, workers)
}
client: func(args: ArrayList<String>, ctx: Context) {
    //  The only application thread is the main thread.
    //  One I/O thread in the thread pool will do.
    //  This client is a requester
    //  Connect to the server
    addr := args size() < 2 ? "tcp://localhost:5555" : "tcp://%s:5555" format(args[1])
    "Connecting to %s" printfln(addr)
    s := Socket new(ctx, SocketType req). connect(addr)
    
    //  Send 20 requests and receive 20 replies
    for (i in 0..26) {
        //scan the user's message
        " > " print(); stdout flush()
        message := stdin readLine()
        
        //  Send the request. No point in filling the content in as server
        //  is a dummy and won't use it anyway.
        s send(Message new(message, message length() + 1, null, null))
                
        //  Get the reply
        reply := s recv()
    }
}
