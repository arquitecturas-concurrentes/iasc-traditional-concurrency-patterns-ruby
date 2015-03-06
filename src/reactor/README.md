#Reactor Pattern

![Alt text](/path/to/reactor.jpg "Reactor")

The reactor design pattern is an event handling pattern for handling service requests delivered concurrently to a service handler by one or more inputs. The service handler then demultiplexes the incoming requests and dispatches them synchronously to the associated request handlers.

##Structure
- Resources: Any resource that can provide input to or consume output from the system.
- Synchronous Event Demultiplexer: Uses an event loop to block on all resources. When it is possible to start a synchronous operation on a resource without blocking, the demultiplexer sends the resource to the dispatcher.
- Dispatcher: Handles registering and unregistering of request handlers. Dispatches resources from the demultiplexer to the associated request handler.
- Request Handler: An application defined request handler and its associated resource.

Properties[edit]
All reactor systems are single threaded by definition, but can exist in a multithreaded environment.

##Benefits

The reactor pattern completely separates application specific code from the reactor implementation, which means that application components can be divided into modular, reusable parts. Also, due to the synchronous calling of request handlers, the reactor pattern allows for simple coarse-grain concurrency while not adding the complexity of multiple threads to the system.

##Limitations
The reactor pattern can be more difficult to debug[2] than a procedural pattern due to the inverted flow of control. Also, by only calling request handlers synchronously, the reactor pattern limits maximum concurrency, especially on Symmetric multiprocessing hardware. The scalability of the reactor pattern is limited not only by calling request handlers synchronously, but also by the demultiplexer.

