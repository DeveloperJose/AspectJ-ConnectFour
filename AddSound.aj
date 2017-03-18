/**
 * Class: CS 3360, Programming Languages
 * Instructor: Dr. Yoonsik Cheon
 * Author: Jose Perez and Michael Ellis
 * Contact: <josegperez@mail.com> or <jperez50@miners.utep.edu>
 * Last Date Modified: Nov 18, 2016
 */
package cs3360.project2;

import java.io.IOException;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.Clip;
import javax.sound.sampled.LineUnavailableException;
import javax.sound.sampled.UnsupportedAudioFileException;

import c4.base.C4Dialog;

privileged aspect AddSound {
        
        pointcut addMoveSound(C4Dialog c4Dialog): call(* C4Dialog.makeMove(int)) && target(c4Dialog);

        pointcut winning(): call(* C4Dialog.markWin());
        
        //plays sound based on current player's turn
        before(C4Dialog c4Dialog) : addMoveSound(c4Dialog) {  
                //if blue turn
                if(c4Dialog.currentPlayer.name().equals("Blue")){
                        playAudio("chip1.wav");
                }
                //if red turn
                if(c4Dialog.currentPlayer.name().equals("Red")){
                        playAudio("chip2.wav");
                }
        }
        //play winning sound
        before () : winning(){
                playAudio("cheering.wav");
        }
        

    /** Directory where audio files are stored. */
    private static final String SOUND_DIR = "/sounds/";

    /** Play the given audio file. Inefficient because a file will be 
     * (re)loaded each time it is played. */
    public static void playAudio(String filename) {
      try {
          AudioInputStream audioIn = AudioSystem.getAudioInputStream(
            AddSound.class.getResource(SOUND_DIR + filename));
          Clip clip = AudioSystem.getClip();
          clip.open(audioIn);
          clip.start();
      } catch (UnsupportedAudioFileException 
            | IOException | LineUnavailableException e) {
          e.printStackTrace();
      }
    }
}