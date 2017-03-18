/**
 * Class: CS 3360, Programming Languages
 * Instructor: Dr. Yoonsik Cheon
 * Author: Jose Perez and Michael Ellis
 * Contact: <josegperez@mail.com> or <jperez50@miners.utep.edu>
 * Last Date Modified: Nov 18, 2016
 * 
 * Allows the player to play against a CPU
 */
package cs3360.project2;

import java.awt.Color;
import java.awt.Graphics;
import java.awt.event.ItemEvent;
import java.awt.event.ItemListener;

import javax.swing.BorderFactory;
import javax.swing.JComboBox;
import javax.swing.JOptionPane;
import javax.swing.JPanel;

import c4.base.BoardPanel;
import c4.base.C4Dialog;
import c4.model.Board;
import c4.model.Board.Place;
import cs3360.project2.Strategy;

privileged aspect AddStrategy {
    // Static Variables
    private static final Color COLOR_HIGHLIGHT = Color.BLACK;
    private static boolean isAIPlaying = false;
    private static Strategy aiStrategy = null;
    private static Place lastAIPlace = null;
    
    // Problem 1: Adding a ComboBox
    pointcut addComboBox(C4Dialog dialog) : execution(JPanel C4Dialog.makeControlPanel()) && this(dialog);

    JPanel around(C4Dialog dialog) : addComboBox(dialog){
        JPanel content = proceed(dialog);

        JComboBox<String> opponentComboBox = new JComboBox<String>();
        opponentComboBox.setBorder(BorderFactory.createEmptyBorder(5, 15, 0, 0));
        opponentComboBox.addItem("Human");
        opponentComboBox.addItem("Random");
        opponentComboBox.addItem("Smart");

        opponentComboBox.addItemListener(new ItemListener() {

            @Override
            public void itemStateChanged(ItemEvent event) {
                if (event.getStateChange() == ItemEvent.SELECTED) {
                    String opponent = (String) event.getItem();
                    if (JOptionPane.showConfirmDialog(null, "Play a new game with a " + opponent + " opponent?",
                            "Connect Four", JOptionPane.YES_NO_OPTION) == JOptionPane.YES_OPTION) {
                        dialog.startNewGame();
                        
                        lastAIPlace = null;
                        aiStrategy = null;

                        if (opponent.equals("Human"))
                            isAIPlaying = false;
                        else {
                            isAIPlaying = true;
                            aiStrategy = Strategy.fromName(opponent, dialog.players[1], dialog.players[0]);
                        }

                    }
                    //System.out.println("[Dev] Event: Selected " + event.getItem() + ", isAiPlaying=" + isAIPlaying);
                }
            }

        });

        content.add(opponentComboBox);
        return content;
    }

    // Problem 2: AI
    // This is used so we can simulate playing as the CPU player
    pointcut addBoardPanel(C4Dialog dialog, Board board) : execution(BoardPanel C4Dialog.makeBoardPanel(Board)) && this(dialog) && args(board);

    BoardPanel around(C4Dialog dialog, Board board) : addBoardPanel(dialog, board){
        BoardPanel boardPanel = new BoardPanel(board, dialog);
        boardPanel.setBoardClickListener(new BoardPanel.BoardClickListener() {
            @Override
            public void slotClicked(int slot) {
                String playerName = dialog.currentPlayer().name();

                // Don't the the human play red tokens if the AI is active
                if (isAIPlaying && playerName.equals("Red"))
                    return;

                if (!dialog.isGameOver && board.isSlotOpen(slot)) {
                    dialog.makeMove(slot);

                    // If the human won, don't make a move
                    if (isAIPlaying && !dialog.isGameOver()) {
                        int cpuSlot = aiStrategy.selectColumn(board, slot);
                        dialog.makeMove(cpuSlot);
                        
                        // Figure out where the AI placed their token
                        int cpuHeight = 0;
                        for (; cpuHeight < board.slotHeight(); cpuHeight++)
                            if (board.isOccupiedBy(cpuSlot, cpuHeight, aiStrategy.playerAI))
                                break;

                        lastAIPlace = new Place(cpuSlot, cpuHeight);
                        boardPanel.repaint();
                    }
                }
            }
        });

        return boardPanel;
    }
    // Problem 3:
    // Highlight the AI's move
    pointcut highlightAI(BoardPanel boardPanel, Graphics g) : execution(void BoardPanel.drawPlacedCheckers(Graphics)) && this(boardPanel) && args(g);

    private static final int HIGHLIGHT_MARGIN = 2;

    void around(BoardPanel boardPanel, Graphics g) : highlightAI(boardPanel, g){
        proceed(boardPanel, g);

        if (lastAIPlace != null) {
            // Draw a rectangle around the AI's last position
            g.setColor(COLOR_HIGHLIGHT);
            int slot = lastAIPlace.x;
            int height = lastAIPlace.y;
            int xx = slot * boardPanel.placeSize + HIGHLIGHT_MARGIN;
            int yy = (height + 1) * boardPanel.placeSize + HIGHLIGHT_MARGIN;
            g.drawRect(xx, yy, boardPanel.placeSize - HIGHLIGHT_MARGIN * 2,
                    boardPanel.placeSize - HIGHLIGHT_MARGIN * 2);
        }
    }
}