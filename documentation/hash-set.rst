####################
The hash-set library
####################

.. current-library:: hash-set

*******************
The hash-set module
*******************

.. current-module:: hash-set

.. class:: <hash-set>
   :open:

   :supers: :class:`<set>`

   :class:`<hash-set>` provides a more extensible implementation of
   :class:`<set>`. Primarily, it allows for custom hashing functions and
   key-tests for different object classes.

.. generic-function:: set-element-hash
   :open:

   :signature: set-element-hash *object* *initial-state* => 
        *id* *result-state*

   :param object:               Object to compute the hash of.
   :param initial-state:        Initial hash-state.
   :param id:                   Hash ID computed from *object*.
   :param result-state:         The resulting hash-state.

   This method is used to compute the hash-code of *object*. By default
   it simply calls :meth:`common-dylan:common-dylan:object-hash(<object>)`.

   By specializing this method and
   :meth:`common-dylan:common-dylan:\=(<object>, <object>)` for a subclass
   of :class:`<object>`, it can be given a custom hash function when used
   in a :class:`<hash-set>`.

   A good hash function will return the same ID for two objects
   **object1** and **object2** whenever **object1 = object2**, and will
   minimize collisions between hash IDs when **object1 ~= object2**.

   Example:

.. code-block:: dylan

   // Normally, an object's hash is based on its identity (\==) using
   // object-hash. However, in this example we want two <person> objects
   // to be considered the same (and produce the same hash) when their
   // ID is the same, regardless of whether or not they are the same
   // instance.
   define class <person> (<object>)
     constant slot id :: <integer>, required-init-keyword: id:;
   end class <person>;

   // First we specialize \= on <person>. As stated above, two <person>
   // objects are considered equal if their IDs are equal.
   define method \=
       (person1 :: <person>, person2 :: <person>)
    => (equal? :: <boolean>)
     person1.id = person2.id
   end method \=;

   // We also want to compute the hash code for a <person> object based
   // on its ID. In this case, we can just use the person's ID directly
   // as the hash ID, but in other cases another built-in hash function
   // might be more useful.
   define method set-element-hash
       (person :: <person>, initial-state :: <hash-state>)
    => (id :: <integer>, result-state :: <hash-state>)
     values(person.id, initial-state)
   end method set-element-hash;

   // Create some people
   let john-smith = make(<person>, id: 1);
   let jane-doe = make(<person>, id: 2);
   let bruce-wayne = make(<person>, id: 3);

   let people = hash-set(john-smith, jane-doe, bruce-wayne);

   // Different instance, same ID
   let batman = make(<person>, id: 3);

   if (member?(batman, people))
     format-out("One of these folks is hiding something...\n")
   end if

.. method:: set-add
   :specializer: <hash-set>

   :signature: set-add *set* *element* => *new-set*

   :param set:
   :param element:
   :value new-set:

   Creates a new set with the same elements as *set* with *element* added.

.. method:: set-add!
   :specializer: <hash-set>

   :signature: set-add! *set* *element* => *set*

   :param set:
   :param element:
   :value set: Same set as *set*

   Destructively adds *element* to *set* and returns the same set.

.. method:: set-remove
   :specializer: <hash-set>

   :signature: set-remove *set* *element* => *new-set*

   :param set:
   :param element:
   :value new-set:

   Creates a new set with the same elements as *set* minus *element*.

.. method:: set-remove!
   :specializer: <hash-set>

   :signature: set-remove! *set* *element* => *set*

   :param set: :class:`<hash-set>`
   :param element: :class:`<object>`
   :value set: Same set as *set*

   Destructively removes *element* from *set* and returns the same set.

.. function:: hash-set

   :signature: hash-set ``#rest`` *arguments* => *hash-set*

   :param #rest arguments: The elements of the hash-set.

   :value set: A freshly allocated instance of <hash-set>.

   Creates and returns a freshly allocated hash-set.

.. code-block:: dylan

   // See the example in set-element-hash
   // for the implementation of <person>.

   // Create some people
   let john-smith = make(<person>, id: 1);
   let jane-doe = make(<person>, id: 2);
   let bruce-wayne = make(<person>, id: 3);

   // Create some superpeople
   let batman = make(<person>, id: 3);
   let superman = make(<person>, id: 4);

   // Quickly construct some hash sets
   let gotham-population = hash-set(john-smith, jane-doe, bruce-wayne);
   let superheroes = hash-set(batman, superman);

   // Take the set-difference of people and superheroes, see the
   // set-operations library.
   let normal-citizens = people - superheroes;

   format-out("%=\n", normal-citizens); // #{john-smith, jane-doe}
