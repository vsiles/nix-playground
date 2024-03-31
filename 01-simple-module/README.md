```bash
$ nix flake check
trace: hello
```

Now with error checking:

```bash
# Type checking
A definition for option `x' is not of type `signed integer'. Definition values:
       - In `<unknown-file>': "10"

# Missing argument or unknown input
error: The option `x' is used but not defined.

error: The option `u' does not exist. Definition values:
       - In `<unknown-file>': 10
```

# Reading material

- https://nix.dev/tutorials/module-system/module-system.html
- https://nixos.org/manual/nixos/stable/#sec-option-types-basic
