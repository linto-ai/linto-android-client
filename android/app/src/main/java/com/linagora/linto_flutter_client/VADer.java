package com.linagora.linto_flutter_client;

import android.util.Log;

import com.konovalov.vad.VadConfig;
import com.konovalov.vad.Vad;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

public class VADer {
    private Vad engine = new Vad(VadConfig.newBuilder()
            .setSampleRate(VadConfig.SampleRate.SAMPLE_RATE_16K)
            .setFrameSize(VadConfig.FrameSize.FRAME_SIZE_480)
            .setMode(VadConfig.Mode.VERY_AGGRESSIVE)
            .build());
    VADer() {
        engine.start();
    }



    public boolean isSpeech(byte[] frame) {
        short[] frameFormated = _bytesToShortList(frame);

        return engine.isSpeech(frameFormated);
    }

    private short[] _bytesToShortList(byte[] frame) {
        short[] ret = new short[frame.length/2];
        ByteBuffer.wrap(frame).order(ByteOrder.LITTLE_ENDIAN).asShortBuffer().get(ret);
        return ret;
    }

}
