/**
 * Class: CS 3360, Programming Languages
 * Instructor: Dr. Yoonsik Cheon
 * Author: Jose Perez and Michael Ellis
 * Contact: <josegperez@mail.com> or <jperez50@miners.utep.edu>
 * Last Date Modified: Nov 18, 2016
 */
package cs3360.project2;

import java.awt.Color;
import java.awt.Graphics;
import java.awt.event.ActionEvent;
import java.awt.event.KeyEvent;

import javax.swing.AbstractAction;
import javax.swing.ActionMap;
import javax.swing.InputMap;
import javax.swing.JComponent;
import javax.swing.KeyStroke;

import c4.base.BoardPanel;
import c4.base.C4Dialog;
import c4.base.ColorPlayer;

privileged aspect AddCheatKey {
        /** Color to highlight the checkers (discs) of the possible winning row. */
        private final Color cheatColorPlayer = Color.GREEN;

        /** Color to highlight the checkers (discs) of the possible winning row. */
        private final Color cheatColorOpponent = Color.YELLOW;
        
        /**number of Columns*/
        private final int NUMCOLS = 7;
        /**number of rows*/
        private final int NUMROWS = 6;
        /** Boolean corresponding to weather or not the cheat key is pressed*/
        private static boolean isCheatEnabled = false;

        pointcut highlightCheckers(BoardPanel bp, Graphics g): execution (void BoardPanel.paint(Graphics)) && args(g) && this(bp);
        
        void around(BoardPanel boardPanel, Graphics g) : highlightCheckers(boardPanel, g){
                proceed(boardPanel, g);
                Color paint_token = Color.BLACK; //initialized value, never actually used
                ColorPlayer player = (ColorPlayer) boardPanel.board.playerAt(0,0);//initialized value, never actually used
                if (isCheatEnabled) { // checks possible winning 3 in a row
                        for(int col = 0; col < NUMCOLS; col++){//traverse columns
                                for(int row = 0; row < NUMROWS; row ++){//traverse rows
                                        //obtain player at the row/column in question
                                        player = (ColorPlayer) boardPanel.board.playerAt(col,row);
                                        
                                        //change highlight color based on current player's relation to that player
                                        if( player == boardPanel.game.currentPlayer()){//player occupies
                                                paint_token = cheatColorPlayer;
                                        }
                                        else{//opponent occupies
                                                paint_token = cheatColorOpponent;
                                        }
                                        if (player != null && !boardPanel.game.isGameOver()){//a token is there and the game is not over
                                        draw_vertical(row, col, boardPanel, g, paint_token);
                                        draw_horizontal(row, col, boardPanel, g, paint_token);
                                        diagonal_backslash(row, col, boardPanel, g, paint_token);
                                        diagonal_forwardslash(row, col, boardPanel, g, paint_token);
                                        }//draw all possible hints
                                }
                        }
                }
                boardPanel.repaint();
        }

        //key listener for f5 being pressed
        void around(C4Dialog dialog) : execution(C4Dialog.new()) && this(dialog) {
                proceed(dialog);

                ActionMap actionMap = dialog.getRootPane().getActionMap();
                int condition = JComponent.WHEN_IN_FOCUSED_WINDOW;
                InputMap inputMap = dialog.getRootPane().getInputMap(condition);
                String cheat = "Cheat";
                inputMap.put(KeyStroke.getKeyStroke(KeyEvent.VK_F5, 0), cheat);
                actionMap.put(cheat, new KeyAction());

                //System.out.println("Added CheatKey");
        }

        // !not the value of the current isCheatEnabled value based on when f5 is pressed
        @SuppressWarnings("serial")
        private static class KeyAction extends AbstractAction {
                /** Called when a cheat is requested. */
                public void actionPerformed(ActionEvent event) {
                        isCheatEnabled = !isCheatEnabled;
                }
        }
        
public void draw_vertical(int row, int col, BoardPanel boardPanel, Graphics g, Color paint_token){
        //if slot equals the two above it fill in all three slots
        if(row+2 < NUMROWS && row-1 >= 0){//check bounds of board
                if((ColorPlayer) boardPanel.board.playerAt(col,row) == (ColorPlayer) boardPanel.board.playerAt(col,row+1)//one above it is same color
                                &&(ColorPlayer) boardPanel.board.playerAt(col,row) == (ColorPlayer) boardPanel.board.playerAt(col,row+2)//two above it is same color
                                && (ColorPlayer) boardPanel.board.playerAt(col,row-1) == null){ // one above it is not blocked off
                                //draw
                                boardPanel.drawChecker(g, paint_token, col, row, 10);
                                boardPanel.drawChecker(g, paint_token, col, row+1, 10);
                                boardPanel.drawChecker(g, paint_token, col, row+2, 10);
                }//end draw
        }//end bounds check
}//end vertical

public void draw_horizontal(int row, int col, BoardPanel boardPanel, Graphics g, Color paint_token){
        if(col+2 < NUMCOLS){//check bounds of board
                //check uninterrupted 3 in a row
                if((ColorPlayer) boardPanel.board.playerAt(col,row) == (ColorPlayer) boardPanel.board.playerAt(col+1,row)//one right to leftmost checker is same color
                                &&(ColorPlayer) boardPanel.board.playerAt(col,row) == (ColorPlayer) boardPanel.board.playerAt(col+2,row)//two right to leftmost checker is same color
                                && ((col - 1 >= 0 && ((ColorPlayer) boardPanel.board.playerAt(col-1,row) == null)) //left side not blocked off and within bounds
                                                || (col + 3 < NUMCOLS && (ColorPlayer) boardPanel.board.playerAt(col+3,row) ==  null))){ //right side not blocked off and within bounds
                                //draw
                                boardPanel.drawChecker(g, paint_token, col, row, 10);
                                boardPanel.drawChecker(g, paint_token, col+1, row, 10);
                                boardPanel.drawChecker(g, paint_token, col+2, row, 10);
                }
                //the space next to THE LEFTMOST checker is blank
                if((ColorPlayer) boardPanel.board.playerAt(col,row) == (ColorPlayer) boardPanel.board.playerAt(col+2,row)//one right to leftmost is same color
                                && col + 3 < NUMCOLS && (ColorPlayer) boardPanel.board.playerAt(col,row) == (ColorPlayer) boardPanel.board.playerAt(col+3,row)//three right to leftmost checker is same color and within bounds
                                                && (ColorPlayer) boardPanel.board.playerAt(col+1,row) ==  null){ //one right to leftmost checker is not locked off
                                //draw
                                boardPanel.drawChecker(g, paint_token, col, row, 10);
                                boardPanel.drawChecker(g, paint_token, col+2, row, 10);
                                boardPanel.drawChecker(g, paint_token, col+3, row, 10);
                }
                //two spaces away from THE LEFTMOST checker is blank
                if((ColorPlayer) boardPanel.board.playerAt(col,row) == (ColorPlayer) boardPanel.board.playerAt(col+1,row)//one right to leftmost checker  is same color
                                && col + 3 < NUMCOLS && (ColorPlayer) boardPanel.board.playerAt(col,row) == (ColorPlayer) boardPanel.board.playerAt(col+3,row)//two right of the leftmost checker is same color
                                                && (ColorPlayer) boardPanel.board.playerAt(col+2,row) ==  null){ //two to the right of leftmost checker is not blocked off
                                //draw
                                boardPanel.drawChecker(g, paint_token, col, row, 10);
                                boardPanel.drawChecker(g, paint_token, col+1, row, 10);
                                boardPanel.drawChecker(g, paint_token, col+3, row, 10);
                }
        }
}//end horizontal

//diagonal \
public void diagonal_backslash(int row, int col, BoardPanel boardPanel, Graphics g, Color paint_token){
        if(col+2 < NUMCOLS //column bounds
                        && row+2 < NUMROWS){// row bounds
                //Uninterrupted 3 in a row
                if((ColorPlayer) boardPanel.board.playerAt(col,row) == (ColorPlayer) boardPanel.board.playerAt(col+1,row+1)//one diagonally  to leftmost is same color
                                &&(ColorPlayer) boardPanel.board.playerAt(col,row) == (ColorPlayer) boardPanel.board.playerAt(col+2,row+2)//two diagonally from leftmost is same color
                                && (((col - 1 >= 0 &&  row-1 >= 0) && ((ColorPlayer) boardPanel.board.playerAt(col-1,row-1) == null)) //left side not blocked off and within bounds
                                                || ((col + 3 < NUMCOLS && row + 3 < NUMROWS) && (ColorPlayer) boardPanel.board.playerAt(col+3,row+3) ==  null))){ //right side not blocked off and within bounds
                                //draw
                                boardPanel.drawChecker(g, paint_token, col, row, 10);
                                boardPanel.drawChecker(g, paint_token, col+1, row+1, 10);
                                boardPanel.drawChecker(g, paint_token, col+2, row+2, 10);
                }
                //the checker next to the leftmost is blank
                if((ColorPlayer) boardPanel.board.playerAt(col,row) == (ColorPlayer) boardPanel.board.playerAt(col+2,row+2)//two diagonally form leftmost is same color
                                &&(col + 3 < NUMCOLS && row + 3 < NUMROWS) && (ColorPlayer) boardPanel.board.playerAt(col,row) == (ColorPlayer) boardPanel.board.playerAt(col+3,row+3)//three diagonally leftmost is same color and within bounds
                                && ((ColorPlayer) boardPanel.board.playerAt(col+1,row+1) ==  null)){ //one diagonally from leftmost is not blocked off
                                //draw
                                boardPanel.drawChecker(g, paint_token, col, row, 10);
                                boardPanel.drawChecker(g, paint_token, col+2, row+2, 10);
                                boardPanel.drawChecker(g, paint_token, col+3, row+3, 10);
                }
                //the checker two from the leftmost is blank
                if((ColorPlayer) boardPanel.board.playerAt(col,row) == (ColorPlayer) boardPanel.board.playerAt(col+1,row+1)//one diagonally form leftmost is same color
                                &&(col + 3 < NUMCOLS && row + 3 < NUMROWS) && (ColorPlayer) boardPanel.board.playerAt(col,row) == (ColorPlayer) boardPanel.board.playerAt(col+3,row+3)//three diagonally leftmost is same color and within bounds
                                && ((ColorPlayer) boardPanel.board.playerAt(col+2,row+2) ==  null)){ //two diagonally from leftmost is not blocked off
                                //draw
                                boardPanel.drawChecker(g, paint_token, col, row, 10);
                                boardPanel.drawChecker(g, paint_token, col+1, row+1, 10);
                                boardPanel.drawChecker(g, paint_token, col+3, row+3, 10);
                }
        }
}//end backslash

//diagonal /
public void diagonal_forwardslash(int row, int col, BoardPanel boardPanel, Graphics g, Color paint_token){
        if(col+2 < NUMCOLS //column bounds
                        && row-2 >= 0){// row bounds
                if((ColorPlayer) boardPanel.board.playerAt(col,row) == (ColorPlayer) boardPanel.board.playerAt(col+1,row-1)//one diagonally from leftmost is same color
                                &&(ColorPlayer) boardPanel.board.playerAt(col,row) == (ColorPlayer) boardPanel.board.playerAt(col+2,row-2)//two diagonally from leftmost is same color
                                && (((col - 1 >= 0 && row +1 < NUMROWS) && ((ColorPlayer) boardPanel.board.playerAt(col-1,row+1) == null)) //left side not blocked off and within bounds
                                                || ((col + 3 < NUMCOLS && row - 3 > 0) && (ColorPlayer) boardPanel.board.playerAt(col+3,row-3) ==  null))){ //right side not blocked off and within bounds
                                //draw
                                boardPanel.drawChecker(g, paint_token, col, row, 10);
                                boardPanel.drawChecker(g, paint_token, col+1, row-1, 10);
                                boardPanel.drawChecker(g, paint_token, col+2, row-2, 10);
                }
                //the checker next to the leftmost is blank
                if((ColorPlayer) boardPanel.board.playerAt(col,row) == (ColorPlayer) boardPanel.board.playerAt(col+2,row-2)//one diagonally from leftmost is same color
                                && (col + 3 < NUMCOLS && row - 3 >= 0) && (ColorPlayer) boardPanel.board.playerAt(col,row) == (ColorPlayer) boardPanel.board.playerAt(col+3,row-3)//two diagonally from leftmost is same color and within bounds
                                && ((ColorPlayer) boardPanel.board.playerAt(col+1,row-1) ==  null)){ //right side not blocked off and within bounds
                                //draw
                                boardPanel.drawChecker(g, paint_token, col, row, 10);
                                boardPanel.drawChecker(g, paint_token, col+2, row-2, 10);
                                boardPanel.drawChecker(g, paint_token, col+3, row-3, 10);
                }
                //the checker two from the leftmost is blank
                if((ColorPlayer) boardPanel.board.playerAt(col,row) == (ColorPlayer) boardPanel.board.playerAt(col+1,row-1)//one diagonally from leftmost is same color
                                && (col + 3 < NUMCOLS && row - 3 >= 0) && (ColorPlayer) boardPanel.board.playerAt(col,row) == (ColorPlayer) boardPanel.board.playerAt(col+3,row-3)//two diagonally from leftmost is same color and within bounds
                                && ((ColorPlayer) boardPanel.board.playerAt(col+2,row-2) ==  null)){ //right side not blocked off and within bounds
                                //draw
                                boardPanel.drawChecker(g, paint_token, col, row, 10);
                                boardPanel.drawChecker(g, paint_token, col+1, row-1, 10);
                                boardPanel.drawChecker(g, paint_token, col+3, row-3, 10);
                }
        }
}

}//end aspect
