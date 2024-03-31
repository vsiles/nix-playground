```bash
$ nix flake check
trace: More of the first
text
This is the first
text===
This is some other
text
```

Merging of options like `lines` should be tested file:
- no newline at the end, only as an inner separator (`=== is not on a new line`)
- ordering seems backward
