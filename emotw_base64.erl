-module(emotw_base64).

-include_lib("eunit/include/eunit.hrl").

% Application: stdlib
% Source: https://github.com/erlang/otp/blob/master/lib/stdlib/src/base64.erl
% Introduced: Before R13B

demo_base64() ->

% This is a very small and simple module that can be used to encode and decode
% data from and to the base64 format (https://en.wikipedia.org/wiki/Base64).

% The base64:encode/1 function accepts both lists and binaries as input, but it
% always returns a binary.

  <<"aGVsbG8=">> = base64:encode("hello"),
  <<"aGVsbG8=">> = base64:encode(<<"hello">>),

% If you really want a list as the output, you can use the alternative function
% base64:encode_to_string/1.

  "aGVsbG8=" = base64:encode_to_string("hello"),
  "aGVsbG8=" = base64:encode_to_string(<<"hello">>),

% Be careful what you encode however - the elements of the list are expected to
% be integers in the range 0..255. If they are outside this range, you will get
% a badarg error.

  {'EXIT', {badarg, _}} = (catch base64:encode([256])),

% (FYI: The brackets around the catch expression are needed due to the clash of
% operator precedence between = and catch).

% In the other direction, the base64:decode/1 and base64:decode_to_string/1
% functions work like their encode counterparts:

  <<"hello">> = base64:decode(<<"aGVsbG8=">>),
  <<"hello">> = base64:decode("aGVsbG8="),
  "hello"     = base64:decode_to_string(<<"aGVsbG8=">>),
  "hello"     = base64:decode_to_string("aGVsbG8=").

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

