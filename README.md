# vir

simple tool to quickly jump into your predefined directorieis.

## setup

1. install vir however you want.
2. add a script on your shell to automatically make it work.

example with fish:

```fish
function vir
    set dest (command vir $argv)
    and cd $dest
end
```

note: i don't think i'm adding commands to update or delete dirs anytime soon.

# license

cc0 1.0 universal <3
