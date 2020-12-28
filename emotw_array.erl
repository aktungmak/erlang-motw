-module(emotw_array).

-include_lib("eunit/include/eunit.hrl").

% Application: stdlib
% Source: https://github.com/erlang/otp/blob/7ca7a6c59543db8a6d26b95ae434e61a044b0800/lib/stdlib/src/array.erl
% Introduced: Before R13B

demo_array() ->

% If you are coming from a non-functional background, this module may at first
% sight appear to be very useful and important. In reality however it is not
% really a good fit for the Erlang style of programming and in almost all cases
% it is not a good choice and a regular list should be used instead.

% One capability it has over a regular list is the ability to create an array
% of a fixed size containing uninitialised elements. This might be useful in
% situations where you have sparse data.

% It is very important to note the following part of the documentation:
%     Arrays uses zero-based indexing. This is a deliberate design choice and
%     differs from other Erlang data structures, for example, tuples.
% It is not clear what the reasoning was behind this design decision, perhaps
% to align with the definitions of arrays in other languages. In any case it
% is important to bear this in mind to avoid the second most common programming
% mistake, off-by-one errors.

% How does one use arrays then? We can create new arrays by using the
% array:new/0 function, or specify the initial size using array:new/1.

  A0 = array:new(),
  0  = array:size(A0),
  A1 = array:new(10),
  10 = array:size(A1),

% We can set and get values at arbitrary indices of this array:

  V  = an_example_atom,
  A2 = array:set(11, V, A0),
  V  = array:get(11, A2),

% The array automatically resized since the element was added beyond the end:

  12 = array:size(A2),

% Arrays created with array:new will by default have all entires set to the
% atom "undefined".

  A3 = array:new(),
  undefined = array:get(1, A3),

% Additionally they will automatically resize when entries are added beyond the
% end of the array, as seen above. If we want fixed-size arrays, this can be
% specified in the Options argument of array:new/1,2. Any attempt to set a value
% beyond the end of the array will result in a badarg error.

  A4 = array:new([fixed, 3]),
  {'EXIT', {badarg, _}} = (catch array:set(4, some_atom, A4)),

% Alternatively, the functions fix/1 and relax/1 can be used to enable and
% disable whether an array is a fixed size.

% Finally, one can convert to and from a list using the array:to_list/1 and 
% array:from_list/1 functions.

  A5 = array:from_list([1, 2, 3]),
  [1, 2, 3] = array:to_list(A5).

% Arrays are optimised to improve their performance and this means that an array
% is actually a record in the background. This is how it looks as of OTP 23.2.1:

-record(array, {size :: non_neg_integer(), %% number of defined entries
                max  :: non_neg_integer(), %% maximum number of entries
                                           %% in current tree
                default,                   %% the default value
                                           %% (usually 'undefined')
                elements                   %% the tuple tree
               }).

% However this should be considered opaque and can potentially change in future.
% This is another weakness of arrays: you cannot pattern match on them, unlike
% built-in datastructures like lists, maps and tuples.

% I could only find one usage of the module in the standard library, in the
% module lib/observer/src/observer_tv_table.erl. Here it is used as a table to
% hold details of ETS tables that are being displayed in the Table Viewer.

-record(holder, {node, parent, pid,
                 table=array:new(), n=0, columns,
                 temp=[],
                 search,
                 source, tabid,
                 sort,
                 key,
                 type,
                 attrs
                }).

% It is not clear why an array was used instead of a list, since in many places
% the array is converted to and from a list to be operated on.

% One reason may be that specific indices of the array are often accessed in the
% module, however the same can be achieved with lists:nth/2, albeit with more
% overhead since the list must be traversed.

% The key takeaway is: use a list unless you are absolutely certain that you
% need an array!

demo_array_test() ->
  demo_array().
