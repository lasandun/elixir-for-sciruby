defmodule Simpson do

    # create a temporary module 'TempModule' with a method 'f/1'.
    # create an Elixir method which represent the integrating function at run time.
    def initIntegrationFunction(function) do
        Code.compile_string("defmodule TempModule do\n def f(x) do \n " <> function <> " \n end\n end", "nofile")
    end

    # integrating function
    def f(x) do
        TempModule.f(x)
    end

    # find integral on interval (a, b) in n steps
    def simpson(parentPID, a, b, n) do
        if((n/2)*2 != n) do
            samples = n + 1
        else
            samples = n
        end
        
        dx = ((b-a)*1.0)/samples

        i = 2
        ret = iterateSimpson(i, samples, dx, a)
        sol = ( ret + f(a) + f(b) + 4.0 * f(a+dx) ) * dx / 3.0
        send parentPID, {:result, sol}
    end

    def iterateSimpson(i, n, dx, a) do
        if(i <= n - 1) do
            x  = a + i * dx
            ss = 2.0 * f(x) + 4.0 * f(x+dx)
            ii = i + 2
            iterateSimpson(ii, n, dx, a) + ss
        else
            0
        end
    end

    # run simpson on clusters
    def simpsonParallel do
        # read arguments
        args = System.argv()
        [aa|temp1] = args
        [bb|temp2] = temp1
        [nn|temp3] = temp2
        [f|_]      = temp3
        {a, _} = :string.to_integer(to_char_list(aa))
        {b, _} = :string.to_integer(to_char_list(bb))
        {n, _} = :string.to_integer(to_char_list(nn))

        initIntegrationFunction(f) # create a temporary module

        noOfProcesses = :erlang.system_info(:logical_processors_available) # determine the available cores
        stepSize = 1.0*(b-a)/noOfProcesses

        val = iteratorSP(a, n/noOfProcesses, stepSize, noOfProcesses)
        IO.puts "Back end: ****** #{val} ********"
        sendResultsToFrontEnd(val)
    end

    def iteratorSP(a, n, stepSize, remainingIterations) do
        b = a + stepSize
        if(remainingIterations>0) do
            spawn(Simpson, :simpson, [self, a, b, n])
            nextVal = iteratorSP(b, n, stepSize, remainingIterations-1)
            receive do
                {:result, val} -> #IO.puts "result is #{val}"
                val+nextVal
            end
        else
            0
        end
    end
    
    # create json object and send it to front end 
    def sendResultsToFrontEnd(result) do
        {:ok, socket} = :gen_tcp.connect({127, 0, 0, 1} ,2000, [:binary, {:active,true}])
        jsonStr = '{"result":"#{result}", "status":"ok"}'  # create json object
        :gen_tcp.send(socket, jsonStr)#to_string(result))
        :gen_tcp.close(socket)
    end
end

Simpson.simpsonParallel

