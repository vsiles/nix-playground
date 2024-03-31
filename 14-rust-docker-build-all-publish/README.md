```bash
$ direnv allow
$ nix flake check
$ nix build .#allow
$ tree result
result/:
total 1332
dr-xr-xr-x    3 vsiles vsiles    4096 Jan  1  1970 ./
drwxr-xr-x 2362 vsiles vsiles 1351680 Mar 31 17:20 ../
dr-xr-xr-x    2 vsiles vsiles    4096 Jan  1  1970 bin/

result/bin:
total 16
dr-xr-xr-x 2 vsiles vsiles 4096 Jan  1  1970 ./
dr-xr-xr-x 3 vsiles vsiles 4096 Jan  1  1970 ../
lrwxrwxrwx 1 vsiles vsiles   59 Jan  1  1970 app_a -> /nix/store/knnqbxvrhnmr3gnmzcxxz1jk1lh8fcfz-app_a/bin/app_a*
lrwxrwxrwx 1 vsiles vsiles   59 Jan  1  1970 app_b -> /nix/store/2gklp6bixwrg1jpcfrpdqqzrxg6b58m0-app_b/bin/app_b*
lrwxrwxrwx 1 vsiles vsiles  117 Jan  1  1970 gl1wfhrh4dqwcinlragl4h6bhyj97jw4-image-docker-app_a.json ->
/nix/store/1qnpkzp80b2phfqkip5p8d2b2jmanblk-docker-app_a/bin/gl1wfhrh4dqwcinlragl4h6bhyj97jw4-image-docker-app_a.json
lrwxrwxrwx 1 vsiles vsiles  101 Jan  1  1970 m37rm8ly9v05yplx188p2h87g2dwnzfd-image-TheB.json -> /nix/store/s8b88zq29wfdwamljr8hbbddjv5fzhxs-TheB/bin/m37rm8ly9v05yplx188p2h87g2dwnzfd-image-TheB.json
```
