defmodule Simpson do
    def f(x) do
        (x*x*x - x*x + x*2)
    end

    def simpson(parentPID, a, b, n) do
        if((n/2)*2 != n) do
            samples = n + 1
        else
            samples = n
        end
        
        dx = ((b-a)*1.0)/samples

        i = 2
        ret = iterate(i, samples, dx, a)
        sol = ( ret + f(a) + f(b) + 4.0 * f(a+dx) ) * dx / 3.0
        send parentPID, {:result, sol}
    end

    def iterate(i, n, dx, a) do
        if(i <= n - 1) do
            x  = a + i * dx
            ss = 2.0 * f(x) + 4.0 * f(x+dx)
            ii = i + 2
            iterate(ii, n, dx, a) + ss
        else
            0
        end
    end

    def simpsonParallel do
        args = System.argv()
        [aa|temp1] = args
        [bb|temp2] = temp1
        [nn|_] = temp2
        {a, _} = :string.to_integer(to_char_list(aa))
        {b, _} = :string.to_integer(to_char_list(bb))
        {n, _} = :string.to_integer(to_char_list(nn))

        noOfProcesses = :erlang.system_info(:logical_processors_available)
        stepSize = 1.0*(b-a)/noOfProcesses

        val = iteratorSP(a, n/noOfProcesses, stepSize, noOfProcesses)
        IO.puts "****** #{val} ********"
    end

    def iteratorSP(a, n, stepSize, remainingIterations) do
        b = a + stepSize
        if(remainingIterations>0) do
            spawn(Simpson, :simpson, [self, a, b, n])
            nextVal = iteratorSP(b, n, stepSize, remainingIterations-1)
            receive do
                {:result, val} -> IO.puts "result is #{val}"
                val+nextVal
            end
        else
            0
        end
    end
end


Simpson.simpsonParallel
IO.puts "#####################"
#IO.puts "#{:erlang.system_info(:logical_processors_available)}"
#IO.puts "#{:erlang.system_info(:logical_processors)}"
