# Roadmap
## V 0.1 Release
### Art Assets
* Images
    * Card Front
    * Card Back
    * 3 Opponent Placeholders
        * Jack
        * Queen
        * King
* Icons
    * Heart
    * Sword
    * Shield
    * Energy  (Fire/Lightning)
    * Deck
    * Campfire / Bed
    * Draw Action
    * X-Cross Stamp
    * Fist Knockout Stamp
    * Check Mark Stamp
    * Arrow Forward
    * Arrow Back
    * Fast Forward
* Animation
    * Slice
    * Burn
    * Block
* Font
    * Title Font
    * Readable Font
    * Numeric Font
    
### Theming
* Theme
    * Dynamic Fonts
        * Game Title
        * Card Title
        * Card Content
        * Card Numbers
        * Button Text
    * Label
    * Buttons
    * Text
    * Panel Background
* Cards
    * Action Cards
        * Energy Cost
        * Title
        * Text
        * Tags
        * Image
    * Character Cards
        * Title
        * Stats
        * Image
* Deck Icon w/ Card Count
    * Draw Pile
    * Discard Pile
    * Exhaust Pile
* Card Glow and Highlighting
    * Yellow / Active
    * Blue
    * Red

### Scenes
* Game View
    * Border UI
        * View Deck Button 
        * View Map Button
        * Health Bar
            * "Current / Max" Text
            * Heart Icon
            * Progress Bar
            * Room for Armor Icon and Counter
    * Hint Box w/ position relative to mouse hover
* Combat View
    * Foreground
        * Player Hand
        * Decks / Piles
            * Draw Pile
            * Discard Pile
            * Exhaust Pile
        * Battle Deck Energy
        * Stage Order
        * Round Count
    * Background
        * Opponents Cards
            * Opponent Image
            * Mouse Over area for cards with targets
                * Split area by number of enemies
                * Mouse over effect for matching cards
        * Opponent's Played Cards
        * Player's Played Cards
* Deck View
    * Show all cards in a deck
        * Scrolling
        * 4 columns

### Scripting
* Card
    * Title
    * Description
    * Value
    * Action / Script
* Deck
    * Stacking
    * Shuffling
    * Drawing
    * Inspecting
* Player
    * Health and Armor
    * Battle Deck Energy
    * Decks
    * Map position
* Opponent
    * Decks
    * Hand
    * Pick Action
        * Tiered Difficulty / Strategies
* Battle
    * Stage transitions
        * Move controls from player to opponent
        * Transition stages triggers actions / cards
        * Timer + Buttons to trigger next stages
        * Highlight active character
        * Stages for each player
            * Resolution (cards from previous turn that activate)
            * Discard unactivated cards in play area
            * Recharge
            * Draw cards
            * Play cards
            * Complete turn
            * Discard remaining cards
    * Drawing cards into hand
        * Animate in and tween to position
        * Draw random cards from draw pile
    * Discarding cards from hand
        * Tween to discard pile
        * Animate away
    * Fanning out cards in hand dynamically
    * Adjusting card positions based on mouse hover
    * Dragging cards from hand to play area
    * Cards lock to play area
    * Button to complete turn
    * Cards in play areas activate when owner resolution stage reached
    * Cards in play area highlight owner when mouse over
* Hint box support

### Audio
* Sounds
  * Hover Button
  * Click Button
  * Draw Card
  * Discard Card
  * Burning
  * Attack (Slashing)
  * Block (Metallic Ding)

## V 0.2
### Art Assets
* Icons
    * Pause / Play
    * Arrow to End
    * Arrow to Beginning
* Images
    * Card Front (2nd Pass)
    * Card Back (2nd Pass)
    * Description / Paper surface
    * Title / Flag or Banner surface
    * Player Character Placeholder
    * Villain Placeholder
    * Boss Placeholder

### Scenes
* Main Menu
    * Single-player / New Game / New Deck
    * Attribution
    * Exit
* Map View
    * 3 lanes of cards
    * Only first 2 steps of options revealed
    * Further options are flipped over 
    * Selecting an option transitions to battle
    * Completing a battle triggers actions
        * Covers completed card with stamp
        * Flips over 3 cards in following next step
        * Allows the player to choose one of 3 cards in next step
    * Table Surface
        * Import from __Fleeting Cards__
* Game View
    * Border UI
        * Health Bar
            * Animation
            * Glow
### Scripting
* Map
    * Tiling of cards
    * Revealing of rows
    * Card selection from current position
    * Marking cards complete
    * Tally of rows passed

### Audio
* Music
  
## V 0.3
### Scenes
* Story View
    * Between Map to Battle
    * Between Battle to Map
    * Content
    * Dynamic Text
    * Timer that triggers Continue
        * Pause / Play Button controls Timer
    * Continue Button
    * Skip Button
* Map View
    * Table Surface (2nd pass)
    
## V 0.4
### Scenes
* Main Menu
  * Load Deck / Multi-player
    * Host
    * Join
* Story View
  * Content
    * Dynamic Images
    * Dialogue
### Scripting
* Multi-player
