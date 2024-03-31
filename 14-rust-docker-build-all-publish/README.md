```bash
$ nix run .#publish
hash for app_a: a366ac29952d978647627bf5b19ce92bac7201cd8c4e28ac3752e799730facf0
hash for app_b: 94f28fd76e7d61642f489bffa0f006bb301a73303f939f0ec6c92813df052d89
hash for TheB: e5636387cc9f925b4a09fdaf8b542e24ca5b538ab7a571f5993c53f137cdbefd
hash for docker-app_a: 075a0af4f90ba3d2e7fe80347385d950a732b01978f562809d711944b85353ed
$ nix build .#all && tree result
result
└── bin
    ├── app_a -> /nix/store/knnqbxvrhnmr3gnmzcxxz1jk1lh8fcfz-app_a/bin/app_a
    ├── app_b -> /nix/store/2gklp6bixwrg1jpcfrpdqqzrxg6b58m0-app_b/bin/app_b
    ├── gl1wfhrh4dqwcinlragl4h6bhyj97jw4-image-docker-app_a.json -> /nix/store/1qnpkzp80b2phfqkip5p8d2b2jmanblk-docker-app_a/bin/gl1wfhrh4dqwcinlragl4h6bhyj97jw4-image-docker-app_a.json
    └── m37rm8ly9v05yplx188p2h87g2dwnzfd-image-TheB.json -> /nix/store/s8b88zq29wfdwamljr8hbbddjv5fzhxs-TheB/bin/m37rm8ly9v05yplx188p2h87g2dwnzfd-image-TheB.json

2 directories, 4 files
```
