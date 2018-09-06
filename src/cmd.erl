-module(cmd).

-type atom_opt() :: output | return_code.

-type cmd_opt() :: {mode, atom_opt()}
                | {max_size, non_neg_integer()}.

-type atom_or_proplist() :: atom_opt()
                         | list(cmd_opt()).

%% API exports
-export([run/1, run/2]).

%%====================================================================
%% API functions
%%====================================================================

run(Command) ->
    do_run(Command, [{mode, output}]).

run(Command, Arg) when is_integer(Arg) ->
    do_run(Command, [{mode, output}, {max_size, Arg}]);

run(Command, Arg) ->
    do_run(Command, Arg).

%%====================================================================
%% Internal functions
%%====================================================================
-spec run(Command :: string(), Option :: atom_or_proplist()) ->
    string() | integer().

do_run(Command, output) ->
    os:cmd(Command);

do_run(Command, [{mode, output}]) ->
    os:cmd(Command);

do_run(Command, [{mode, output}, {max_size, Arg}]) ->
    os:cmd(Command, #{max_size => Arg});

do_run(Command, return_code) ->
    Res = os:cmd(Command ++ "\nRET_CODE=$?\necho \"\n$RET_CODE\""),
    [[], RetCode | _Rest] = lists:reverse(string:split(Res, "\n", all)),
    list_to_integer(RetCode).

%%====================================================================
%% EUnit tests
%%====================================================================
-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

-define(NUM_BYTES, 100000000). %% ~10MiB

return_code_success_test() ->
    ?assertEqual(0, ?MODULE:run("ls", return_code)).

return_code_failure_test() ->
    ?assertEqual(get_unix_error_code(), ?MODULE:run("cp /", return_code)).

return_code_from_text_output_with_breakline_test() ->
    ?assertEqual(0, ?MODULE:run("echo \"..........1\"", return_code)).

return_code_from_text_output_without_breakline_test() ->
    Command = "perl -e \"print '.' x 10;\"",
    ?assertEqual(0, ?MODULE:run(Command, return_code)).

simple_output_command_test() ->
    {ok, Cwd} = file:get_cwd(),
    {ok, Ls} = file:list_dir(Cwd),
    DirContents = string:join(lists:sort(Ls), "\n") ++ "\n",
    ?assertEqual(DirContents, string:sub_string(?MODULE:run("ls -a"), 6)).

big_return_code_test_() ->
    {timeout, 120, fun() ->
        NumBytes = integer_to_list(?NUM_BYTES),
        Command = "perl -e \"print '.' x " ++ NumBytes ++ ";\"",
        ?assertEqual(0, ?MODULE:run(Command, return_code))
    end}.

big_output_test_() ->
    {timeout, 120, fun() ->
        NumBytes = integer_to_list(?NUM_BYTES),
        Command = "perl -e \"print '.' x " ++ NumBytes ++ ";\"",
        ?assertEqual(?NUM_BYTES, length(?MODULE:run(Command)))
    end}.

big_truncated_output_test_() ->
    {timeout, 120, fun() ->
        NumBytes = integer_to_list(?NUM_BYTES),
        MaxOutputBytes = 256,
        Command = "perl -e \"print '.' x " ++ NumBytes ++ ";\"",
        Opts = [{mode, output}, {max_size, MaxOutputBytes}],
        ?assertEqual(MaxOutputBytes, length(?MODULE:run(Command, Opts)))
    end}.

get_unix_error_code() ->
    case os:type() of
        {unix, darwin} -> 64;
        _ -> 1
    end.

-endif.
