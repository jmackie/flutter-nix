# WIP

```
nix-env -f default.nix -iA flutter
flutter --version
```

### Issues

-   Flutter expects to be able to write to the Nix store. We could hack around
    this with `nix.readOnlyStore = false;` but a better solution would be nice.
