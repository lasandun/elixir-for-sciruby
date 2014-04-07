def simpson(a, b, n)
    if((n/2)*2 != n) 
        n=n+1
    end
    s = 0.0
    dx = (b-a)/(n*1.0)
    i = 2
    while(i <= n-1)
       x = a+i*dx
       s = s + 2.0*f(x) + 4.0*f(x+dx)
       i = i + 2
    end
    s = (s + f(a)+f(b)+4.0*f(a+dx) )*dx/3.0
    return s
end
def f(x)
    return (x*x*x*x-x*x+2*x)
end

var = simpson(0, 10, 40000000)
puts var
