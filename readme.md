# Adventure Tropics

## Notes

1. for gameplay to begin, the following variables need to become global:
    - p1
    - lvl
    - cam
    - fruits
    - bads
    - spawners
    - the are declared via init_level()

    - a single function should make lvl, fruits, bads, and spawners. this would make it a lot easier to design levels.
        - make_level = must define lvl, fruits, bads, spawners

### Making enemies
- need to make a spawners table first, this doesnt need its own function, can be global
- 