module: dylan-user

define library hash-set
  use common-dylan;
  use collections;
  export
    hash-set;
end library hash-set;

define module hash-set
  use common-dylan;
  use table-extensions;
  use set;
  export
    <hash-set>,
      set-add,
      set-add!,
      set-remove,
      set-remove!,
    set-element-hash,
    hash-set
end module hash-set;
