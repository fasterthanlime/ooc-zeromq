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
    //  Create an endpoint for client applications to connect to.
    //  We are using an XREP socket so that processing of one request
    s := Socket new(ctx,SocketType sub)
    //  won't block other requests.
    s bind("tcp://0.0.0.0:5555")
    s setOption(SocketOption subscribe, "", 0)
    while (true) {
        //  Get a request from the dispatcher.
        request := s recv()
        " < %s" printfln(request data())
    }
}
client: func(args: ArrayList<String>, ctx: Context) {
    //  The only application thread is the main thread.
    //  One I/O thread in the thread pool will do.
    //  This client is a requester
    //  Connect to the server
    addr := args size() < 2 ? "tcp://localhost:5555" : "tcp://%s:5555" format(args[1])
    "Connecting to %s" printfln(addr)
    s := Socket new(ctx, SocketType pub). connect(addr)
    
    while (true) {
        //scan the user's message
        " > " print(); stdout flush()
        message := stdin readLine()
        
        //  Send the request. No point in filling the content in as server
        //  is a dummy and won't use it anyway.
        s send(Message new(message, message length() + 1, null, null))
                
        //  Get the reply
    }
}
