module: meta
synopsis: exports other modules and provides common scan functions
author:  Douglas M. Auclair
copyright: (c) 2001, LGPL

// a word is delimited by non-graphic characters: spaces, <>, {}, [],
// punctuation, or the single- or double- quotation-mark.

define collector word(w)
  loop([element-of($any-char, w), do(collect(w))]),
  (str.size > 0)
end collector word;

define constant $graphic-digit = concatenate($digit, "+-");

define collector int(i) => (as(<string>, str).string-to-integer)
  loop([element-of($graphic-digit, i), do(collect(i))]),
  (str.size > 0)
end collector int;

define collector number(n) => (as(<string>, str).string-to-number)
  loop([element-of($num-char, n), do(collect(n))]),
  (str.size > 0)
end collector number;

define meta s(c)
  element-of($space, c), loop(element-of($space, c))
end meta s;

define function digit?(c :: <character>) => (ans :: <boolean>)
  c >= '0' & c <= '9'
end function digit?;

define constant $zero :: <integer> = as(<integer>, '0');
define function digit(c :: <character>) => (ans :: <integer>)
  as(<integer>, c) - $zero;
end function digit;

define function string-to-number(s :: <string>, #key base :: <integer> = 10)
 => (n :: <number>)
  let the-base :: <real> = base * 1.0;
  let num :: <real> = 0.0;
  let sign :: <integer> = if(s[0] = '-') -1 else 1 end if;
  let exp :: <integer> = 0;

  let str = copy-sequence(s, start: if(s[0] = '+' | s[0] = '-') 1 else 0 end);

  let non-number :: false-or(<character>) = #f;
  let it :: false-or(<character>) = #f;

  let stream = make(<string-stream>, contents: str);

  let iterator = method(fn)
                     non-number := #f;
                     while(~ non-number & peek(stream, on-end-of-stream: #f))
                       it := read-element(stream);
                       if(it.digit?) fn(it.digit) else non-number := it end if;
                     end while;
                 end method;

  iterator(method(x) num := num * the-base + x end);

  if(non-number = '.')
    let div :: <integer> = 1;
    iterator(method(x) num := num + (x / (the-base ^ div)); div := div + 1 end)
  end if;

  if(non-number = 'e')
    let sign = select(peek(stream))
                 '+' => begin read-element(stream); 1 end;
                 '-' => begin read-element(stream); -1 end;
                 otherwise => 1;
               end select;
    iterator(method(x) exp := exp * base + x end);
    exp := exp * sign;
  end if;

  sign * num * (the-base ^ exp)
end function string-to-number;
