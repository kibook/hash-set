module: hash-set
author: kibook
synopsis: A set that allows different subclasses of objects to be
          compared and hashed differently.
version: 18-02-2015

// <hash-set> is built on the hash table (<table>) that is part of the
// standard Dylan collections.
define sealed class <hash-set-table> (<table>) end;

define open class <hash-set> (<set>)
  constant slot set-elements :: <hash-set-table> = make(<hash-set-table>);
end class <hash-set>;

// Compute the hash of a set element.
define open generic set-element-hash
    (object, initial-state :: <hash-state>)
 => (id :: <integer>, result-state :: <hash-state>);

// Default set-element-hash uses object-hash
define method set-element-hash
    (object, initial-state :: <hash-state>)
 => (id :: <integer>, result-state :: <hash-state>)
  object-hash(object, initial-state)
end method set-element-hash;

// Define a table-protocol for <hash-set-table> which uses \= to test keys
// and a custom hash function
define method table-protocol
    (hash-set-table :: <hash-set-table>)
 => (test :: <function>, hash :: <function>)
  values(\=, set-element-hash)
end method table-protocol;

define method member?
    (key, set :: <hash-set>, #key test)
 => (member :: <boolean>)
  element(set.set-elements, key, default: #f) ~== #f
end method member?;

// The set- prefix method names are meant to be consistent with the
// other <set> extension in the dylan library (<bit-set>)

define method set-add
    (set :: <hash-set>, key)
 => (new-set :: <hash-set>)
  let new-set = shallow-copy(set);
  set-add!(new-set, key);
  new-set
end method set-add;

define method set-add!
    (set :: <hash-set>, key)
 => (set :: <hash-set>)
  set.set-elements[key] := key;
  set
end method set-add!;

define method add!
    (set :: <hash-set>, key)
 => (set :: <hash-set>)
  set-add!(set, key)
end method add!;

define method set-remove
    (set :: <hash-set>, key)
 => (new-set :: <hash-set>)
  let new-set = shallow-copy(set);
  set-remove!(new-set, key);
  new-set
end method set-remove;

define method set-remove!
    (set :: <hash-set>, key)
 => (set :: <hash-set>)
  remove-key!(set.set-elements, key);
  set
end method set-remove!;

define method remove!
    (set :: <hash-set>, key, #key test, count)
 => (set :: <hash-set>)
  set-remove!(set, key)
end method remove!;

define method size
    (set :: <hash-set>)
 => (count :: <integer>)
  set.set-elements.size
end method size;

define method element
    (set :: <hash-set>, key, #key default = unsupplied())
 => (key-or-default-or-error)
  if (member?(key, set))
    key
  elseif (supplied?(default))
    default
  else
    error(make(<simple-error>,
               format-string: "No such element %= in %=",
               format-arguments: list(key, set)))
  end if
end method element;

define method element-setter
    (object, set :: <hash-set>, key)
 => (object)
  if (key = object)
    add!(set, object)
  else
    if (member?(key, set))
      remove!(set, key)
    end if;
    add!(set, object)
  end if;
  object
end method element-setter;

define method key-test
    (set :: <hash-set>)
 => (test :: <function>)
  \=
end method key-test;

// Basically just iterate over the key-sequence of the <hash-set-table>
define method forward-iteration-protocol
    (set :: <hash-set>)
 => (initial-state :: <integer>,
     limit :: <integer>,
     next-state :: <function>,
     finished-state? :: <function>,
     current-key :: <function>,
     current-element :: <function>,
     current-element-setter :: <function>,
     copy-state :: <function>)
  values(
         // initial-state
         0,
         
         // limit
         set.size,

         // next-state
         method(set :: <hash-set>, state :: <integer>)
           state + 1
         end,

         // finished-state?
         method(set :: <hash-set>, state :: <integer>, limit :: <integer>)
           state = limit
         end,

         // current-key
         method(set :: <hash-set>, state :: <integer>)
           set.set-elements.key-sequence[state]
         end,

         // current-element
         method(set :: <hash-set>, state :: <integer>)
           set.set-elements.key-sequence[state]
         end,

         // current-element-setter
         method(value, set :: <hash-set>, state :: <integer>)
           error(make(<simple-error>,
                      format-string: "Cannot update current element of a "
                                     "set during iteration."))
         end,

         // copy-state
         identity)
end method forward-iteration-protocol;

define function hash-set
    (#rest args)
 => (new-set :: <hash-set>)
  let new-set = make(<hash-set>);
  do(curry(set-add!, new-set), args);
  new-set
end function hash-set;
