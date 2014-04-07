require 'socket'
require 'json'
require 'rubygems'

class FrontEnd
    def self.findIntegral(a, b, n, f)
        cmdStr = "elixir simpson.exs #{a}, #{b}, #{n}, #{f}"
        fork do
            exec cmdStr # execute command which start elixir program
        end
        resultStr = receiveResults(2000)    # receive results on port 2000
        puts "front end: Result string : #{resultStr}"
        jo = JSON.parse(resultStr)
        puts "front end:Reslut : #{jo["result"]}"
        jo["result"]
    end

    # receive results fron Elixir program
    def self.receiveResults(port)
        server = TCPServer.open(port)
        client = server.accept
        res = client.gets
        client.close
        return res
    end

    # simpson method which solve integration in parallel
    def self.simpson(a, b, n, f)
        val = FrontEnd.findIntegral(a, b, n, f)
        val.to_f
    end

end

## example ##
puts FrontEnd.simpson(0, 10, 40000000, "x*x*x*x-x*x+2*x")
