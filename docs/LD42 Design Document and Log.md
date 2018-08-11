LD42 Design Document and Log

THEME: **Running out of space**

# Brainstorm

## Space =
space bar
text space
outer space
teeth space
drawer space
people space (e.g. elevator, phone box)
town space (zoning...)
container space
backpack space
chessboard space
musical chairs

## Running out of =
Having too little of
Fleeing
Sprinting through

## Concepts

Tetris/Phit grid squeeze
Analog version of the same; tetrominoes
Typesetter
Elite with cargo hold: tetris-shaped elements/commodities
Countertop simulator
Storage room
Town simulator; tenement block; dwarf fortress-style room builder as family grows

## Ideas

Grid-type "squeezers" need angled pieces. Else, the "squeezing" is trivial: of course build more rooms if you can, create more "floor"; the relationship between "spending units" and "spendable units" is linear. Angled pieces make the solution non-trivial.

I'm a little bummed that I just have these TWO ideas, though they're both good. It worries me creatively. But I think I'll pick the cheaper of these two and run with it.

**THINKING** 9:33 AM Saturday

### Tetris fortress

One idea would be a sort of **dwarf-fortress, but where both rooms and _people_ are tetris-shaped**. People belonging to the same family have the same color, and want to be together in the same room: they insist on being at least one space away from other family members, and maybe pose some other cost too. So you need to build enough rooms for families to live in separate rooms, but each room costs. Pieces are cute: tetris pieces with nice outlines and shading, but eyeballs and little legs. Maybe "comfort" is the positive commodity (the score) and money is the negative commodity (the cost). Money controls what you can do; comfort judges how well you do it. When comfort reaches zero, you lose. Babies are slowly born. They always start 1x1 in size (despite shape), but pop up to their full size after ~20 seconds. This seems like a reasonable idea. Not too difficult maybe. Probably needs touch/mouse. Not too easy either. But I'm not in love with it.

### Elite with backpack (Running Around In Space)

An elite clone recommends itself for fun and simplicity.

- You're a spaceship in a very large universe of planets at various distances. 
- Each planet has a "market" with buying and selling of certain commodities at randomized prices.
- Your ship has a hold of a certain grid size.
- You must position everything you buy into the hold. Commodities are tetris-shaped.
- You can toss things out from the hold for a very cheap payout.

So, the game is a simple decision loop:

1. Choose a planet to travel to, recalling past knowledge of commodity prices. Burn gas proportionate with distance.
2. When you're out of gas, game over.
3. At the planet, sell commodities and buy them. Buy gas.
4. Go to 1.

Reach some basic amount of wealth to win.

This feels a little too linear. There needs to be some complicator. One would be that planet prices are more "extreme" as you move away from the starting position; that is, the really big payouts are had by going outward and then traveling far.

"Stories" at the beginning of each planet would really help the feel, but I fear the complexity of creating and randomizing them.

I think I actually like the instant-warp approach rather than navigating, but there will need to be some theatrics to make it not too perfunctory or clipped in pace.

#### STRETCH GOALS

Planets should look as cool as possible, with a lot of distinctiveness and animated bits.

Interesting story bits when reaching a planet, maybe with conversation options that give bonuses or cause trouble.

Combat.

At a planet, upgrade ship. Larger hold, better defenses, better weapons, gas efficiency.

Cool warp animation for travel.

#### Questions

Flying between planets is just a warp animation, or do you actually navigate there? Navigating would only be interesting if the path was interesting: avoiding clouds or asteroids for example.