-module(emotw_array).

% Application: stdlib
% Source: https://github.com/erlang/otp/blob/7ca7a6c59543db8a6d26b95ae434e61a044b0800/lib/stdlib/src/array.erl
% Introduced: Before R13B

demo_array() ->

% If you are coming from a non-functional background, this module may at first
% sight appear to be very useful and important. In reality however it is not
% really a good fit for the Erlang style of programming and in almost all cases
% it is not a good choice and a regular list should be used instead.

% One capability it has over a regular list is the ability to create an array
% of a fixed size containing uninitialised elements. This might be used for...

% It is very important to note the following part of the documentation:

% Arrays uses zero-based indexing. This is a deliberate design choice and
% differs from other Erlang data structures, for example, tuples.

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
  A2 = array:set(3, V, A0),
  V  = array:get(3, A0),

% The array automatically resized since the element was added beyond the end:

  3 = array:size(A2).

% Arrays created with array:new/0,1 will by default have all entires set to the
% atom "undefined".

  A2 = array:new().
  undefined = array:get(1, A2).

% Additionally they will automatically resize when entries are added beyond the
% end of the array, as seen above. If we want fixed-size arrays, this can be
% specified in the Options argument of array:new/2.

  A4 = 

% Alternatively, the functions fix/1 and relax/1 can be used to enable and
% disable whether an array is a fixed size.

% Arrays are optimised to improve their performance and this means that an array
% is actually a record in the background. This is how it looks as of OTP 23.2.1:

-record(array, {size :: non_neg_integer(),      %% number of defined entries
                max  :: non_neg_integer(),      %% maximum number of entries
                                                %% in current tree
                default,                        %% the default value
                                                %% (usually 'undefined')
                elements :: elements(_)         %% the tuple tree
               }).

% However this should be considered opaque and can potentially change in future.
% This is another weakness of arrays: you cannot pattern match on them, unlike
% built-in datastructures like lists, maps and tuples.

% I could only find one usage of the module in the standard library, in the
% module lib/observer/src/observer_tv_table.erl. Here it is used as a table to
% hold ...


