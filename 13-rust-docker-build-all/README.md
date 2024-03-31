```bash
$ direnv allow
$ nix flake check
$ nix build .#app_a .#app_b .#docker-app_a .#TheB && tree result && tree result-1 && file result-2 && file result-3
result
└── bin
    └── app_a

2 directories, 1 file
result-1
└── bin
    └── app_b

2 directories, 1 file
result-2: symbolic link to /nix/store/k86xgd1f4xayvqv200p9xg7da5szn3s5-docker-image-docker-app_a.tar.gz
result-3: symbolic link to /nix/store/dmvmp78pahmlnmy3w0djm2rhhpswagiq-docker-image-TheB.tar.gz
```
