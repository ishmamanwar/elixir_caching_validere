# ElixirCachingValidere

**REST Endpoints**
1. localhost:4001/api/get/:key [GET]
2. localhost:4001/api/value [POST]
3. localhost:4001/api/post [POST]

## LRU Caching
A Least Recently Used (LRU) Cache organizes items in order of use, allowing you to quickly identify which item hasn't been used for the longest amount of time.

## REST API
A REST API (also known as RESTful API) is an application programming interface (API or web API) that conforms to the constraints of REST architectural style and allows for interaction with RESTful web services. REST stands for representational state transfer.

## Project Map
1. **lru_cache.ex** -> Contains the logic and implementation for the LRU Caching system
2. **application.ex** ->  Starts the Supervisor tree (The cache can be initialized as a worker under the tree)
3. **web_server.ex** -> Simple WebServer initialization using Cowboy Plug
4. **router.ex** -> Creating the endpoints for the REST API
5. **server_utils.ex** -> Format response as JSON using Poison.encode
6. **elixir_caching_validere_test.exs** -> Testing the logic of the **LruCache** module

## Assumptions
1. No function or endpoint returns the entire cache table (as per specifications and clarification)
2. Value can be any data type in the cache table

## Caching Tech
1. GenServer
2. Agent
3. ETS table

## Testing
Testing only provided for the LruCache module. Failed to personally setup the LruCache module under the supervision tree so could not create Unit Tests for the endpoints.

## Dependencies
1. Plug Cowboy,
2. Poison

## Notes
This is my first **Elixir** project (other than generic "hello world" apps). This was a huge learning oppurtunity for me not just for Elixir but for functional languages in general. In span of 48 hours I have went through half a book about **Phoenix** and a **Udemy** course on **Elixir**. I would continue to increase my understanding on the language and the framework. Very challenging first project and rewarding as well.
