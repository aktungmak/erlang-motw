-module(emotw_binary).

-include_lib("eunit/include/eunit.hrl").

% Application: stdlib
% Source: https://github.com/erlang/otp/blob/master/lib/stdlib/src/binary.erl
% Introduced: R13B

demo_binary() ->

% The binary datatype is one of the core datatypes of erlang and many useful
% operations on binaries are built in to the syntax of erlang, mostly around
% pattern matching but also conversions to/from other types.
% The binary module in the stdlib application provides some additional utilities
% for working with binaries, and this edition of EMOTW will focus only on that
% module, rather than binaries in general.
% It is also worthwhile noting that most of the functions in this module are
% implemented as NIFs, so they are often more efficient than a pure erlang
% implementation.

% For many of the examples below, we will use the following binary as a sample:

  B = <<1, 2, 3, 4, 5, 6>>,

% This binary is 6 bytes long, and should not be confused with a binary string.
% If you are handling a binary string (which may contain non-ASCII characters)
% you should use the string module instead since it handles unicode characters
% properly.

% The most basic functions in the module are used for extracting specific parts
% of a binary, and are fairly self-explanatory. Unlike other parts of erlang,
% the indexing is 0-based (more on this later).

  3 = binary:at(B, 2),
  1 = binary:first(B),
  6 = binary:last(B),

% The part/2,3 functions are equally self-explanatory and both perform the same
% operation, it is just that the arity 2 version takes a tuple of
% {StartPos, Length} and the arity 3 version splits this into separate args.

  <<2, 3, 4>> = binary:part(B, {1, 3}),
  <<2, 3, 4>> = binary:part(B, 1, 3),

% It is worth noting that they accept a negative value for the length which
% is useful for extracting the end of binaries. Again, this approach is only
% suitable for binaries containing byte-oriented data. For similar operations
% on binary strings, use string:slice/2,3.

  <<2, 3, 4>> = binary:part(B, 3, -3),
  <<4, 5, 6>> = binary:part(B, byte_size(B), -3),

% They are exactly the same as the erlang:binary_part/2,3 functions which have
% the added benefit of being allowed in guard expressions, so in practice
% there is little use for the versions in this module.

% The split/2,3 functions are used to break up a binary based on a pattern.
% split/2 will break the binary into two parts, the part before the patter and
% the part after.

  C = <<55, 1, 1, 66, 1, 1, 77, 1, 1>>,
  [<<55>>, <<66, 1, 1, 77, 1, 1>>] = binary:split(C, <<1, 1>>),

% You can also provide a list of patterns to split on, the first one to match
% will be used:

  [<<55,1>>,<<1,1,77,1,1>>] = binary:split(C, [<<1, 66>>, <<1, 77>>]),

% split/3 adds an extra parameter which accepts a list with options. global is
% used to split on all occurrences of the pattern, not just the first.

  [<<55>>,<<66>>,<<77>>,<<>>] = binary:split(C, <<1, 1>>, [global]),

% Note that there was a trailing empty binary since C ended with the pattern.
% The trim option can be used to remove this.

  [<<55>>,<<66>>,<<77>>,<<>>] = binary:split(C, <<1, 1>>, [global, trim]),

% Similarly, trim_all can be used in cases where you would like to avoid empty
% binaries in the middle of the pattern.

  Ones = <<1,1,1,1,1,1,1>>,
  [<<>>,<<>>,<<>>,<<1>>] = binary:split(Ones, <<1, 1>>, [global]),
  [<<1>>]                = binary:split(Ones, <<1, 1>>, [global, trim_all]),

% Like part/2,3, the functions bin_to_list/1-3 are also available in the erlang
% module as erlang:binary_to_list/1,3. The difference is in the indexing - the
% erlang module uses 1-based indexing and this module uses 0-based indexing.
% According to the documentation, the versions in the erlang module are 
% deprecated and the 0-based versions in this module are to be used instead.

  [2, 3, 4] = erlang:binary_to_list(B, 1, 3),
  [2, 3, 4] = binary:bin_to_list(B, 1, 3),

% In the other direction, the function binary:list_to_bin/1 is also present but
% this is an exact duplicate of erlang:list_to_binary/1. In my opinion the
% erlang version is preferred since one can avoid writing the module name.

  L = [1, 2, 3],
  list_to_binary(L) = binary:list_to_bin(L),

% Binaries are a special type of erlang term since the memory management is
% slightly more complicated in order to be efficient when handling large
% binaries. Essentially, the runtime will often use references to the same
% underlying data when creating subbinaries, in order to avoid duplication.
% This can sometimes result in a single subbinary preventing a larger binary
% from being garbage collected. To avoid this, the copy/1,2 functions can be
% used to copy the binary and deassociate the subbinary from its parent.

copy/1
copy/2

% Full details of this are outside the scope of this discussion but
% https://erlang.org/doc/efficiency_guide/binaryhandling.html is a great
% resource for finding out more.
% On the subject of subbinaries, one can use the referenced_byte_size/1 to find
% the size of the parent binary. It also provides a way of identifying whether
% this is indeed a subbinary, but it is rarely useful except for in debugging
% situations.

  8 = referenced_byte_size(B1),

decode_unsigned/1
decode_unsigned/2
encode_unsigned/1
encode_unsigned/2

% very useful

longest_common_prefix/1
longest_common_suffix/1

% Pattern matching

compile_pattern/1
match/2
match/3
matches/2
matches/3

% If you are performing string manipulation operations, you might also consider
% the string module, since despite its name it also operates quite happily on
% binaries.

% Perhaps the most common example of using this is to encode the username and
% password for HTTP Basic Auth. Here is an example from the httpc_request
% module in the inets application showing the credentials being encoded.
% https://github.com/erlang/otp/blob/master/lib/inets/src/http_client/httpc_request.erl

handle_user_info(UserInfo, Headers) ->
  case string:tokens(UserInfo, ":") of
    [User, Passwd] ->
      UserPasswd = base64:encode_to_string(User ++ ":" ++ Passwd),
      "Basic " ++ UserPasswd;
    [User] ->
      UserPasswd = base64:encode_to_string(User ++ ":"),
      "Basic " ++ UserPasswd;
    _ ->
      Headers
  end.

% At the other end, this (edited) example from the HTTP library cowlib shows the
% credentials being decoded.
% https://github.com/ninenines/cowlib/blob/master/src/cow_http_hd.erl#L1033

-spec parse_authorization(binary()) -> {basic, binary(), binary()}.
parse_authorization(<<"Basic ", R/bits >>) ->
  Token = base64:decode(R),
  [Username, Password] = string:split(Token, ":"),
  {basic, Username, Password}.

% Here are some test cases to ensure that the examples all work.
demo_test() ->
  demo_base64().

handle_user_info_test() ->
  "Basic dXNlcm5hbWU6cGFzc3dvcmQ=" = handle_user_info("username:password", []).

parse_authorization_test()->
  {basic, <<"username">>, <<"password">>} =
    parse_authorization(<<"Basic dXNlcm5hbWU6cGFzc3dvcmQ=">>).

