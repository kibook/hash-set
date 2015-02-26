module: dylan-user

define library hash-set
  use common-dylan;
  use collections;
  use custom-hash;
  export
    hash-set;
end library hash-set;

define module hash-set
  use common-dylan;
  use table-extensions;
  use set;
  use custom-hash;
  export
    <hash-set>,
      set-add,
      set-add!,
      set-remove,
      set-remove!,
    hash-set
end module hash-set;
