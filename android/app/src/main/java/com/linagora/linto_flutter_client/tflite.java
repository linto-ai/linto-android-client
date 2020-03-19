package com.linagora.linto_flutter_client;

import androidx.annotation.NonNull;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import android.content.res.AssetFileDescriptor;
import android.content.res.AssetManager;
import android.util.Log;

import org.tensorflow.lite.Interpreter;

public class tflite {
    private Interpreter _interpreter;
    private boolean _isReady = false;

    public void loadModel(AssetManager assets, String modelPath) throws RuntimeException {
        try {
            _interpreter = new Interpreter(loadModelFile(assets, modelPath));
            _isReady = true;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public float detect(byte[] net_input) {
        ByteBuffer input = ByteBuffer.wrap(net_input);
        ByteBuffer output = ByteBuffer.allocate(4);
        _interpreter.run(input, output);

        output.rewind();
        float prob = output.order(ByteOrder.LITTLE_ENDIAN).getFloat();
        return prob;
    }

    public boolean isReady() {
        return _isReady;
    }

    private static MappedByteBuffer loadModelFile(AssetManager assets, String modelFileName) throws IOException {
        AssetFileDescriptor fileDescriptor = assets.openFd(modelFileName);
        FileInputStream inputStream = new FileInputStream(fileDescriptor.getFileDescriptor());
        FileChannel fileChannel = inputStream.getChannel();
        long startOffset = fileDescriptor.getStartOffset();
        long declaredLength = fileDescriptor.getDeclaredLength();
        return fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength);
    }
}