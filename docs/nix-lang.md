# NIX language

## Attrs

Static attrs (attribute set) called `outputs`.

```nix
outputs = {
  foo = "bar";
};
```

## Functions

### Simple

Now `outputs` is a function, which takes a `attrs` as input-parameter.
The `attrs` contains a attribute called `inputParam`.

```nix
outputs = { inputParam }: {
  foo = "bar";
  inputParam = inputParam;
}
```

### Pattern matching

We call the function form above with the `attrs` `someSet` as parameter.
`someSet` has multiple subsets, and nix will automatically "ignore" `something` & `other`.
So the outputs function will only recvice the `inputParam` set.

```nix
someSet = {
  inputParam = {};
  something = {};
  other = {};
};

test = outputs someSet;
```

### Aliasing

With the `@` parameter we define a `alias` for the entire `{ ... }` input set.
Now its accessible via `inputs` attribute.
The `pattern matching` still applies and we can acess things directly aswell as all inputs.

```nix
outputs = inputs @ { inputParam }: {
  foo = "bar";
  inputParam = inputParam;
  something = inputs.something;
  other = inputs.other;
}
```

## Type signatures

The `function` `genAttrs` takes following inputs `::`
- list of strings `[String]`
- anonymous `function` or `lamda` which takes a `string` and returns `any`
and will return `->` a `AttrSet`.

```nix
genAttrs :: [String] -> (String -> Any) -> AttrSet
```

    forAllSystems = function:
      lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ] (system: function nixpkgs.legacyPackages.${system})

## systems or not to system

Some attributes in `nix` need to know for which `system` its used for and some not.

```nix
nixosConfiguration = {};
homeConfiguration = {};
packages.x86_64-linux = {};
devShells.x86_64-linux = {};
```

To correctly configure this for a single system we have to:

```nix
devShells.x86_64-linux = let
    pkgs = import nixpkgs { system = "x86_64-linux"; }
in {};
```

Which is very repetitive for multiple systems.
Therefore we can use some helper functions.

```nix
      # pkgsFor: imports nixpkgs and sets the system for it.
      pkgsFor = system: import nixpkgs { system = system; };
      # forAllSystems: takes a function and injects all systems into it by using genAttrs,
      # special in genAttrs is that it will return the system as root name of the attrs.
      # e.g. genAttrs [ "foo" ... ] (name: {name = name;}) will return: foo = { name = "foo";}
      # so its used to add the system after the attribute which called the function as well as injecting into nixpkgs.
      forAllSystems = f: lib.genAttrs systems (system: f (pkgsFor system));
```

## Overlays

```nix
final: prev: {
  python313Packages =
    prev.python313Packages
    // {
      i3ipc = prev.python313Packages.i3ipc.overrideAttrs (old: {
        doCheck = false;
      });
    };
}
```

Final is the package after this overlay. (Not needed often)
Prev is the package before this overlay, may after some other overlays from upstream.

This overlay function will be executed while instantiating `<nixpkgs>`, `prev` is the `pkgs` instance with correct `system`, before the overlay is applied.
