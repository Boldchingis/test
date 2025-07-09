#include "DCG.h"

typedef struct Neuron {
    F64 *weights;
    F64 bias;
    F64 output;
    F64 delta;
    I64 num_inputs;
} Neuron;

typedef struct Layer {
    Neuron *neurons;
    I64 num_neurons;
    struct Layer *next;
} Layer;

typedef struct Network {
    Layer *layers;
    I64 num_layers;
    F64 learning_rate;
} Network;

U0 InitNeuron(Neuron *n, I64 num_inputs)
{
    n->num_inputs = num_inputs;
    n->weights = MAlloc(num_inputs * sizeof(F64));
    n->bias = (RandU16 % 200 - 100) / 100.0;
    
    for (I64 i = 0; i < num_inputs; i++) {
        n->weights[i] = (RandU16 % 200 - 100) / 100.0;
    }
}

F64 Sigmoid(F64 x)
{
    return 1.0 / (1.0 + Exp(-x));
}

F64 SigmoidDerivative(F64 x)
{
    return x * (1.0 - x);
}

F64 Forward(Neuron *n, F64 *inputs)
{
    F64 sum = n->bias;
    for (I64 i = 0; i < n->num_inputs; i++) {
        sum += inputs[i] * n->weights[i];
    }
    n->output = Sigmoid(sum);
    return n->output;
}

U0 ForwardPass(Network *net, F64 *inputs)
{
    Layer *layer = net->layers;
    F64 *current_inputs = inputs;
    
    while (layer) {
        F64 *layer_outputs = MAlloc(layer->num_neurons * sizeof(F64));
        
        for (I64 i = 0; i < layer->num_neurons; i++) {
            layer_outputs[i] = Forward(&layer->neurons[i], current_inputs);
        }
        
        if (current_inputs != inputs) {
            Free(current_inputs);
        }
        current_inputs = layer_outputs;
        layer = layer->next;
    }
}

U0 BackwardPass(Network *net, F64 *targets)
{
    Layer *layer = net->layers;
    I64 layer_index = 0;
    
    while (layer->next) {
        layer = layer->next;
        layer_index++;
    }
    
    for (I64 i = 0; i < layer->num_neurons; i++) {
        Neuron *n = &layer->neurons[i];
        n->delta = (targets[i] - n->output) * SigmoidDerivative(n->output);
    }
    
    layer = net->layers;
    for (I64 l = 0; l < layer_index; l++) {
        Layer *prev_layer = layer;
        layer = layer->next;
        
        for (I64 i = 0; i < prev_layer->num_neurons; i++) {
            Neuron *n = &prev_layer->neurons[i];
            F64 error = 0.0;
            
            for (I64 j = 0; j < layer->num_neurons; j++) {
                error += layer->neurons[j].delta * layer->neurons[j].weights[i];
            }
            
            n->delta = error * SigmoidDerivative(n->output);
        }
    }
}

U0 UpdateWeights(Network *net, F64 *inputs)
{
    Layer *layer = net->layers;
    F64 *current_inputs = inputs;
    
    while (layer) {
        for (I64 i = 0; i < layer->num_neurons; i++) {
            Neuron *n = &layer->neurons[i];
            
            for (I64 j = 0; j < n->num_inputs; j++) {
                n->weights[j] += net->learning_rate * n->delta * current_inputs[j];
            }
            n->bias += net->learning_rate * n->delta;
        }
        
        if (current_inputs != inputs) {
            Free(current_inputs);
        }
        
        if (layer->next) {
            current_inputs = MAlloc(layer->num_neurons * sizeof(F64));
            for (I64 i = 0; i < layer->num_neurons; i++) {
                current_inputs[i] = layer->neurons[i].output;
            }
        }
        
        layer = layer->next;
    }
}

Network* CreateNetwork(I64 *layer_sizes, I64 num_layers)
{
    Network *net = MAlloc(sizeof(Network));
    net->num_layers = num_layers;
    net->learning_rate = 0.1;
    net->layers = NULL;
    
    Layer *prev_layer = NULL;
    for (I64 i = 0; i < num_layers; i++) {
        Layer *layer = MAlloc(sizeof(Layer));
        layer->num_neurons = layer_sizes[i];
        layer->neurons = MAlloc(layer_sizes[i] * sizeof(Neuron));
        layer->next = NULL;
        
        I64 num_inputs = (i == 0) ? layer_sizes[0] : layer_sizes[i-1];
        for (I64 j = 0; j < layer_sizes[i]; j++) {
            InitNeuron(&layer->neurons[j], num_inputs);
        }
        
        if (prev_layer) {
            prev_layer->next = layer;
        } else {
            net->layers = layer;
        }
        prev_layer = layer;
    }
    
    return net;
}

F64 CalculateError(Network *net, F64 *targets)
{
    Layer *layer = net->layers;
    while (layer->next) {
        layer = layer->next;
    }
    
    F64 error = 0.0;
    for (I64 i = 0; i < layer->num_neurons; i++) {
        F64 diff = targets[i] - layer->neurons[i].output;
        error += diff * diff;
    }
    return error / layer->num_neurons;
}

U0 TrainNetwork(Network *net, F64 *inputs, F64 *targets)
{
    ForwardPass(net, inputs);
    BackwardPass(net, targets);
    UpdateWeights(net, inputs);
}

U0 FreeNetwork(Network *net)
{
    Layer *layer = net->layers;
    while (layer) {
        Layer *next_layer = layer->next;
        for (I64 i = 0; i < layer->num_neurons; i++) {
            Free(layer->neurons[i].weights);
        }
        Free(layer->neurons);
        Free(layer);
        layer = next_layer;
    }
    Free(net);
} 