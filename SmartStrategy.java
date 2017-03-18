/**
 * Class: CS 3360, Programming Languages
 * Instructor: Dr. Yoonsik Cheon
 * Author: Jose G Perez (UTEP ID: 80473954)
 * Contact: <josegperez@mail.com> or <jperez50@miners.utep.edu>
 * Last Date Modified: Nov 18, 2016
 * Based on my PHP SmartStrategy
 */
package cs3360.project2;

import c4.base.ColorPlayer;
import c4.model.Board;
import c4.model.Player;

public final class SmartStrategy extends Strategy {
    private static final String EMPTY = "None";
    private static final String HUMAN = "Blue";
    private static final String CPU = "Red";
    private static final int[] COLUMNS = new int[] { 3, 2, 4, 1, 5, 0, 6 };

    // From strategy.php
    private static final int D_LEFT = 1;
    private static final int D_RIGHT = 2;
    private static final int D_UP = 3;
    private static final int D_DOWN = 4;
    private static final int D_LEFT_DIAGONAL_DOWN = 5;
    private static final int D_RIGHT_DIAGONAL_DOWN = 6;
    private static final int D_LEFT_DIAGONAL_UP = 7;
    private static final int D_RIGHT_DIAGONAL_UP = 8;

    public SmartStrategy(Player playerAI, Player playerHuman) {
        super(playerAI, playerHuman);
    }

    private String getPlayerAt(Board board, int slot, int height) {
        if (!inBounds(board, slot, height))
            return "";
        
        ColorPlayer p = (ColorPlayer) board.playerAt(slot, height);
        if (p == null)
            return EMPTY;
        else
            return p.name();
    }

    @Override
    public int selectColumn(Board board, int playerSlot) {
        // Check if we can win somewhere
        for(int slot = 0; slot < board.numOfSlots(); slot++) {
           for(int height = board.slotHeight() - 1; height >= 0; height --) {
               String playerName = getPlayerAt(board, slot, height);
              
              // We found one of our tokens
              if (playerName.equals(CPU)) {
                 // Down
                 String upOne = getPlayerAt(board, slot, height+1);
                 String downOne = getPlayerAt(board, slot, height-1);
                 String downTwo = getPlayerAt(board, slot, height-2);
                 boolean matchingTokens = downOne.equals(CPU) && downTwo.equals(CPU);
                 
                 if (upOne.equals(EMPTY) && matchingTokens) {
                    return slot;
                 }
                 
                 // Left
                 String leftOne = getPlayerAt(board, slot-1, height );
                 String leftTwo = getPlayerAt(board, slot-2, height );
                 
                 matchingTokens = (leftOne.equals(CPU) && leftTwo.equals(CPU));
                 
                 // Bottom row
                 if (height == board.slotHeight()-1) {
                    String leftThree = getPlayerAt(board, slot-3, height);
                    matchingTokens &= leftThree.equals(EMPTY);
                 } else {
                    String leftThreeDownOne = getPlayerAt(board, slot-3, height-1 );
                    matchingTokens &= (leftThreeDownOne.equals(HUMAN) || leftThreeDownOne.equals(CPU));
                 }
                 
                 if (matchingTokens) {
                    return slot - 3;
                 }
                 
                 // Right
                 String rightOne = getPlayerAt(board, slot+1, height);
                 String rightTwo = getPlayerAt(board, slot+2, height);
                 
                 matchingTokens = (rightOne.equals(CPU) && rightTwo.equals(CPU));
                 
                 // Bottom row
                 if (height == board.slotHeight() - 1) {
                    String rightThree = getPlayerAt(board, slot+3, height);
                    matchingTokens &= rightThree.equals(EMPTY);
                 } else {
                    String rightThreeDownOne = getPlayerAt(board, slot+3, height-1);
                    matchingTokens &= (rightThreeDownOne.equals(HUMAN) || rightThreeDownOne.equals(CPU));
                 }
                 
                 if (matchingTokens) {
                    return slot + 3;
                 }
              }
           }
        }
        
        int highestRow = -1;
        // Find what row the player placed their
        // token in
        for(int row = 0; row < board.slotHeight(); row ++) {
           if (getPlayerAt(board, playerSlot, row).equals(HUMAN)) {
              highestRow = row;
              break;
           }
        }
        // Check if the player might win in any
        // direction
        for(int direction = 1; direction <= 8; direction ++) {
           boolean gameWon = check_win(board, playerSlot, highestRow, HUMAN, direction);
           if (gameWon) {
              // The player might win to the left
              // Check if placing a token will make
              // them win
              if (direction == D_LEFT) {
                 // print "Left <br/ >";
                 if (highestRow == board.slotHeight() - 1) {
                    // Check if we can place our token
                    boolean slotAvailable = getPlayerAt(board, playerSlot + 1, highestRow).equals(EMPTY);
                    return (slotAvailable) ? playerSlot + 1 : 0;
                 }
                 
                 String slot = getPlayerAt(board, playerSlot + 1, highestRow + 1);
                 boolean slotAvailable = slot.equals(HUMAN) || slot.equals(CPU);
                 if (slotAvailable)
                    return playerSlot + 1;
                 
              } else if (direction == D_RIGHT) {
                 // print "Right <br/ >";
                 // Check if we are at the bottom
                 if (highestRow == board.slotHeight() - 1) {
                    // Check if we can place our
                    // token
                    boolean $slotAvailable = getPlayerAt(board, playerSlot-1, highestRow).equals(EMPTY);
                    return ($slotAvailable) ? playerSlot - 1 : 0;
                 }
                 
                 String slot = getPlayerAt(board, playerSlot - 1, highestRow + 1);
                 boolean slotAvailable = slot.equals(HUMAN) || slot.equals(CPU);
                 
                 if (slotAvailable)
                    return playerSlot - 1;
                 
              } else if (direction == D_LEFT_DIAGONAL_UP) {
                 String slot = getPlayerAt(board, playerSlot - 3, highestRow - 2);
                 boolean slotAvailable = slot.equals(HUMAN) || slot.equals(CPU);
                 if (slotAvailable)
                    return playerSlot - 3;
              } else if (direction == D_RIGHT_DIAGONAL_UP) {
                 String slot = getPlayerAt(board, playerSlot+3, highestRow - 2);
                 boolean slotAvailable = slot.equals(HUMAN) || slot.equals(CPU);
                 if (slotAvailable)
                    return playerSlot + 3;
              } else if (direction == D_LEFT_DIAGONAL_DOWN) {
                 String slot = getPlayerAt(board,  playerSlot-3 , highestRow + 3);
                 boolean slotAvailable = slot.equals(HUMAN) || slot.equals(CPU);
                 if (slotAvailable)
                    return playerSlot - 3;
              } else if (direction == D_RIGHT_DIAGONAL_DOWN) {
                  String slot = getPlayerAt(board,  playerSlot+3 , highestRow+3);
                  boolean slotAvailable = slot.equals(HUMAN) || slot.equals(CPU);
                 if (slotAvailable)
                    return playerSlot + 3;
              } else if (direction == D_UP) {
                 // Player will win by placing a token in the same column
                 // Check if we can put it down first
                 boolean slotAvailable = getPlayerAt(board, playerSlot, highestRow - 1).equals(EMPTY);
                 if (slotAvailable)
                    return playerSlot;
              }
           }
        }
        
        // We aren't in danger of losing. Select
        // something near the center
        // Find the columns that are not full
        for (int col : COLUMNS) {
           if (board.isSlotOpen(col) && playerSlot != col)
              return col;
        }
        return - 2;
    }

    public boolean inBounds(Board board, int slot, int height) {
        return (slot >= 0 && slot < board.numOfSlots() && height >= 0 && height < board.slotHeight());
    }

    public boolean check_win(Board board, int slot, int height, String token, int direction) {
        for (int count = 1; count <= 2; count++) {
            int tempHeight = height + (get_height_offset(direction) * count);
            int tempSlot = slot + (get_slot_offset(direction) * count);

            if (!getPlayerAt(board, tempSlot, tempHeight).equals(token))
                return false;
        }
        return true;
    }

    private int get_height_offset(int direction) {
        switch (direction) {
            case D_UP:
            case D_LEFT_DIAGONAL_UP:
            case D_RIGHT_DIAGONAL_UP:
                return 1;

            case D_DOWN:
            case D_LEFT_DIAGONAL_DOWN:
            case D_RIGHT_DIAGONAL_DOWN:
                return -1;
        }
        return 0;
    }

    private int get_slot_offset(int direction) {
        switch (direction) {
            case D_RIGHT:
            case D_RIGHT_DIAGONAL_DOWN:
            case D_RIGHT_DIAGONAL_UP:
                return 1;

            case D_LEFT:
            case D_LEFT_DIAGONAL_DOWN:
            case D_LEFT_DIAGONAL_UP:
                return -1;
        }
        return 0;
    }
}
