#include "DCG.h"

typedef struct AudioSample {
    U8 *data;
    I64 length;
    I64 sample_rate;
    struct AudioSample *next;
} AudioSample;

AudioSample *audio_samples = NULL;

U0 PlayBeep(I64 frequency, I64 duration)
{
    I64 sample_rate = 44100;
    I64 samples = (duration * sample_rate) / 1000;
    U8 *buffer = MAlloc(samples * 2);
    
    for (I64 i = 0; i < samples; i++) {
        F64 t = (F64)i / sample_rate;
        I16 sample = (I16)(Sin(2.0 * 3.14159 * frequency * t) * 32767);
        buffer[i * 2] = sample & 0xFF;
        buffer[i * 2 + 1] = (sample >> 8) & 0xFF;
    }
    
    AudioSample *as = MAlloc(sizeof(AudioSample));
    as->data = buffer;
    as->length = samples;
    as->sample_rate = sample_rate;
    as->next = audio_samples;
    audio_samples = as;
}

U0 PlayTone(I64 frequency, I64 duration, F64 volume)
{
    I64 sample_rate = 44100;
    I64 samples = (duration * sample_rate) / 1000;
    U8 *buffer = MAlloc(samples * 2);
    
    for (I64 i = 0; i < samples; i++) {
        F64 t = (F64)i / sample_rate;
        I16 sample = (I16)(Sin(2.0 * 3.14159 * frequency * t) * 32767 * volume);
        buffer[i * 2] = sample & 0xFF;
        buffer[i * 2 + 1] = (sample >> 8) & 0xFF;
    }
    
    AudioSample *as = MAlloc(sizeof(AudioSample));
    as->data = buffer;
    as->length = samples;
    as->sample_rate = sample_rate;
    as->next = audio_samples;
    audio_samples = as;
}

U0 PlayChord(I64 *frequencies, I64 count, I64 duration)
{
    I64 sample_rate = 44100;
    I64 samples = (duration * sample_rate) / 1000;
    U8 *buffer = MAlloc(samples * 2);
    
    for (I64 i = 0; i < samples; i++) {
        F64 t = (F64)i / sample_rate;
        F64 sample = 0.0;
        
        for (I64 j = 0; j < count; j++) {
            sample += Sin(2.0 * 3.14159 * frequencies[j] * t);
        }
        
        sample = sample / count;
        I16 final_sample = (I16)(sample * 32767);
        buffer[i * 2] = final_sample & 0xFF;
        buffer[i * 2 + 1] = (final_sample >> 8) & 0xFF;
    }
    
    AudioSample *as = MAlloc(sizeof(AudioSample));
    as->data = buffer;
    as->length = samples;
    as->sample_rate = sample_rate;
    as->next = audio_samples;
    audio_samples = as;
}

U0 PlayMelody(I64 *notes, I64 *durations, I64 count)
{
    for (I64 i = 0; i < count; i++) {
        PlayTone(notes[i], durations[i], 0.5);
        MSleep(durations[i]);
    }
}

U0 CreateNoise(I64 duration, F64 intensity)
{
    I64 sample_rate = 44100;
    I64 samples = (duration * sample_rate) / 1000;
    U8 *buffer = MAlloc(samples * 2);
    
    for (I64 i = 0; i < samples; i++) {
        I16 sample = (I16)((RandU16 % 65536 - 32768) * intensity);
        buffer[i * 2] = sample & 0xFF;
        buffer[i * 2 + 1] = (sample >> 8) & 0xFF;
    }
    
    AudioSample *as = MAlloc(sizeof(AudioSample));
    as->data = buffer;
    as->length = samples;
    as->sample_rate = sample_rate;
    as->next = audio_samples;
    audio_samples = as;
}

U0 FreeAllAudio()
{
    while (audio_samples) {
        AudioSample *as = audio_samples;
        audio_samples = audio_samples->next;
        Free(as->data);
        Free(as);
    }
} 