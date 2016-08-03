require 'socket'

# Running `nc -l 4444` and this program we should be able
# to execute `curl localhost:2222` (proxy host:port) and
# receive what is written in the running netcat.
module SimpleTCPProxy
  PROXY_HOST = 'localhost'
  PROXY_PORT = 2222

  HOST = 'localhost'
  PORT = 4444

  class << self
    def request(client)
      proxy_client = tcp_client(HOST, PORT)
      proxy_client.puts(client.gets)
      while line = proxy_client.gets
        client.puts(line)
      end
    end

    def server
      proxy = TCPServer.open(PROXY_PORT)
      loop do
        client = proxy.accept
        request(client)
        client.close
      end
    end

    def tcp_client(host, port)
      @tcp_client ||= TCPSocket.open(HOST, PORT)
    end

    def serve!
      server
    end
  end
end

SimpleTCPProxy.serve!
