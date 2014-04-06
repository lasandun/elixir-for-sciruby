require 'socket'
require 'json'
require 'rubygems'

class FrontEnd
    def self.findIntegral(a, b, n, f)
        cmdStr = "elixir simpson.exs #{a}, #{b}, #{n}, #{f}"
        fork do
            exec cmdStr
        end
        resultStr = receiveResults(2000)
        puts "front end: Result string : #{resultStr}"
        jo = JSON.parse(resultStr)
        puts "front end:Reslut : #{jo["result"]}"
    end

    def self.receiveResults(port)
        server = TCPServer.open(port)
        client = server.accept
        res = client.gets
        client.close
        return res
    end

end

#exec 'elixir simpson.exs 0, 10, 16000000, x*x*x*x-x*x+2*x'

FrontEnd.findIntegral(0, 10, 16000000, "x*x*x*x-x*x+2*x")
