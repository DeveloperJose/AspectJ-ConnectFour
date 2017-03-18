/**
 * Class: CS 3360, Programming Languages
 * Instructor: Dr. Yoonsik Cheon
 * Author: Jose G Perez (UTEP ID: 80473954)
 * Contact: <josegperez@mail.com> or <jperez50@miners.utep.edu>
 * Last Date Modified: Nov 18, 2016
 * Based on my PHP Strategy
 */
package cs3360.project2;
import c4.model.Board;
import c4.model.Player;

public abstract class Strategy {
    
    /**
     * Load a ConnectFour Strategy based on the name provided
     * @param name Name of strategy. Either Random or Smart
     * @param playerAI The Player instance the AI will be using
     * @param playerHuman The Player instance the player will be using
     * @return The selected strategy or null if the strategy is unknown
     */
    public static Strategy fromName(String name, Player playerAI, Player playerHuman){
        if(name.equals("Random"))
            return new RandomStrategy(playerAI, playerHuman);
        else if(name.equals("Smart"))
            return new SmartStrategy(playerAI, playerHuman);
        
        return null;
    }
    
    public Player playerAI;
    protected Player playerHuman;
    
    protected Strategy(Player playerAI, Player playerHuman){
        this.playerAI = playerAI;
        this.playerHuman = playerHuman;
    }
    
    public abstract int selectColumn(Board board, int playerMove);
}
