/**
 * Class: CS 3360, Programming Languages
 * Instructor: Dr. Yoonsik Cheon
 * Author: Jose G Perez (UTEP ID: 80473954)
 * Contact: <josegperez@mail.com> or <jperez50@miners.utep.edu>
 * Last Date Modified: Nov 18, 2016
 * Based on my PHP RandomStrategy
 */
package cs3360.project2;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import c4.model.Board;
import c4.model.Player;

public final class RandomStrategy extends Strategy {
    private Random rand;

    public RandomStrategy(Player playerAI, Player playerHuman) {
        super(playerAI, playerHuman);
        rand = new Random(System.nanoTime());
    }

    @Override
    public int selectColumn(Board board, int playerMove) {
        List<Integer> availableSlots = new ArrayList<Integer>(board.numOfSlots());

        // Get all the slots that are not full
        for (int slot = 0; slot < board.numOfSlots(); slot++) {
            if (!board.isSlotFull(slot))
                availableSlots.add(slot);
        }

        // Pick one of them randomly
        return availableSlots.get(rand.nextInt(availableSlots.size()));
    }

}
