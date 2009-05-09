-module(ring).
-compile(export_all).

start(N, M) when is_integer(N), is_integer(M) ->
    First = spawn(ring, first_loop, [nopid, M]),
    io:format("First ~p~n", [First]),
    Last = make_pid(N - 1, First),
    io:format("***~n", []),
    First ! {start, Last}.

first_loop(Pid, 0) ->
    receive
        ring ->
            io:format("Done sending messages ~p~n", [self()]),
            Pid ! done,
            done
    end;
first_loop(Pid, M) ->
    receive
        ring ->
            io:format("Starting next cycle ~p~n", [self()]),
            Pid ! ring,
            first_loop(Pid, M-1);
        {start, LastPid} ->
            LastPid ! ring,
            first_loop(LastPid, M-1)
    end.

make_pid(0, Pid) ->
    Pid;
make_pid(N, Pid) ->
    Next = spawn(ring, loop, [Pid]),
    io:format("Next ~p~n", [Next]),
    make_pid(N-1, Next).

loop(Pid) ->
    receive
        done ->
            io:format("done ~p~n", [self()]),
            Pid ! done,
            done;
        ring ->
            io:format("ring ~p~n", [self()]),
            Pid ! ring,
            loop(Pid)
    end.
