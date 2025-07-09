#include "DCG.h"

typedef struct HuffmanNode {
    U8 symbol;
    I64 frequency;
    struct HuffmanNode *left;
    struct HuffmanNode *right;
} HuffmanNode;

typedef struct LZ77Match {
    I64 offset;
    I64 length;
    U8 next_char;
} LZ77Match;

U8 *compressed_data = NULL;
I64 compressed_size = 0;
I64 compressed_capacity = 0;

U0 HuffmanNodeCreate(U8 symbol, I64 frequency)
{
    HuffmanNode *node = MAlloc(sizeof(HuffmanNode));
    node->symbol = symbol;
    node->frequency = frequency;
    node->left = NULL;
    node->right = NULL;
    return node;
}

I64 CountFrequencies(U8 *data, I64 length, I64 *frequencies)
{
    for (I64 i = 0; i < 256; i++) {
        frequencies[i] = 0;
    }
    
    for (I64 i = 0; i < length; i++) {
        frequencies[data[i]]++;
    }
    
    I64 unique_count = 0;
    for (I64 i = 0; i < 256; i++) {
        if (frequencies[i] > 0) {
            unique_count++;
        }
    }
    
    return unique_count;
}

HuffmanNode* BuildHuffmanTree(I64 *frequencies)
{
    HuffmanNode **nodes = MAlloc(256 * sizeof(HuffmanNode*));
    I64 node_count = 0;
    
    for (I64 i = 0; i < 256; i++) {
        if (frequencies[i] > 0) {
            nodes[node_count++] = HuffmanNodeCreate(i, frequencies[i]);
        }
    }
    
    while (node_count > 1) {
        I64 min1 = 0, min2 = 1;
        if (nodes[min1]->frequency > nodes[min2]->frequency) {
            I64 temp = min1;
            min1 = min2;
            min2 = temp;
        }
        
        for (I64 i = 2; i < node_count; i++) {
            if (nodes[i]->frequency < nodes[min1]->frequency) {
                min2 = min1;
                min1 = i;
            } else if (nodes[i]->frequency < nodes[min2]->frequency) {
                min2 = i;
            }
        }
        
        HuffmanNode *internal = HuffmanNodeCreate(0, nodes[min1]->frequency + nodes[min2]->frequency);
        internal->left = nodes[min1];
        internal->right = nodes[min2];
        
        nodes[min1] = internal;
        nodes[min2] = nodes[node_count - 1];
        node_count--;
    }
    
    HuffmanNode *root = nodes[0];
    Free(nodes);
    return root;
}

U0 GenerateHuffmanCodes(HuffmanNode *node, U8 *code, I64 depth, U8 **codes)
{
    if (node->left == NULL && node->right == NULL) {
        codes[node->symbol] = MAlloc(depth + 1);
        for (I64 i = 0; i < depth; i++) {
            codes[node->symbol][i] = code[i];
        }
        codes[node->symbol][depth] = 0;
        return;
    }
    
    if (node->left) {
        code[depth] = 0;
        GenerateHuffmanCodes(node->left, code, depth + 1, codes);
    }
    
    if (node->right) {
        code[depth] = 1;
        GenerateHuffmanCodes(node->right, code, depth + 1, codes);
    }
}

U0 HuffmanCompress(U8 *data, I64 length)
{
    I64 frequencies[256];
    I64 unique_count = CountFrequencies(data, length, frequencies);
    
    HuffmanNode *root = BuildHuffmanTree(frequencies);
    
    U8 **codes = MAlloc(256 * sizeof(U8*));
    for (I64 i = 0; i < 256; i++) {
        codes[i] = NULL;
    }
    
    U8 code[256];
    GenerateHuffmanCodes(root, code, 0, codes);
    
    compressed_capacity = length * 2;
    compressed_data = MAlloc(compressed_capacity);
    compressed_size = 0;
    
    U8 current_byte = 0;
    I64 bit_count = 0;
    
    for (I64 i = 0; i < length; i++) {
        U8 *symbol_code = codes[data[i]];
        if (symbol_code) {
            for (I64 j = 0; symbol_code[j] != 0; j++) {
                current_byte = (current_byte << 1) | symbol_code[j];
                bit_count++;
                
                if (bit_count == 8) {
                    compressed_data[compressed_size++] = current_byte;
                    current_byte = 0;
                    bit_count = 0;
                }
            }
        }
    }
    
    if (bit_count > 0) {
        current_byte <<= (8 - bit_count);
        compressed_data[compressed_size++] = current_byte;
    }
    
    for (I64 i = 0; i < 256; i++) {
        if (codes[i]) {
            Free(codes[i]);
        }
    }
    Free(codes);
    
    HuffmanNodeFree(root);
}

U0 HuffmanNodeFree(HuffmanNode *node)
{
    if (node) {
        HuffmanNodeFree(node->left);
        HuffmanNodeFree(node->right);
        Free(node);
    }
}

U0 LZ77Compress(U8 *data, I64 length)
{
    compressed_capacity = length * 2;
    compressed_data = MAlloc(compressed_capacity);
    compressed_size = 0;
    
    I64 pos = 0;
    while (pos < length) {
        LZ77Match best_match = {0, 0, data[pos]};
        
        I64 search_start = (pos > 4096) ? pos - 4096 : 0;
        for (I64 i = search_start; i < pos; i++) {
            I64 match_length = 0;
            while (pos + match_length < length && 
                   data[i + match_length] == data[pos + match_length] &&
                   match_length < 255) {
                match_length++;
            }
            
            if (match_length > best_match.length) {
                best_match.offset = pos - i;
                best_match.length = match_length;
                best_match.next_char = (pos + match_length < length) ? data[pos + match_length] : 0;
            }
        }
        
        if (best_match.length >= 3) {
            compressed_data[compressed_size++] = (best_match.offset >> 8) & 0xFF;
            compressed_data[compressed_size++] = best_match.offset & 0xFF;
            compressed_data[compressed_size++] = best_match.length;
            compressed_data[compressed_size++] = best_match.next_char;
            pos += best_match.length + 1;
        } else {
            compressed_data[compressed_size++] = 0;
            compressed_data[compressed_size++] = 0;
            compressed_data[compressed_size++] = 0;
            compressed_data[compressed_size++] = data[pos];
            pos++;
        }
    }
}

U0 RLECompress(U8 *data, I64 length)
{
    compressed_capacity = length * 2;
    compressed_data = MAlloc(compressed_capacity);
    compressed_size = 0;
    
    I64 i = 0;
    while (i < length) {
        U8 current = data[i];
        I64 count = 1;
        
        while (i + count < length && data[i + count] == current && count < 255) {
            count++;
        }
        
        if (count >= 4) {
            compressed_data[compressed_size++] = 0;
            compressed_data[compressed_size++] = count;
            compressed_data[compressed_size++] = current;
            i += count;
        } else {
            compressed_data[compressed_size++] = count;
            for (I64 j = 0; j < count; j++) {
                compressed_data[compressed_size++] = data[i + j];
            }
            i += count;
        }
    }
}

U0 DeltaCompress(U8 *data, I64 length)
{
    compressed_capacity = length * 2;
    compressed_data = MAlloc(compressed_capacity);
    compressed_size = 0;
    
    I8 previous = 0;
    for (I64 i = 0; i < length; i++) {
        I8 delta = data[i] - previous;
        compressed_data[compressed_size++] = delta;
        previous = data[i];
    }
}

U0 BurrowsWheelerTransform(U8 *data, I64 length, I64 *index)
{
    U8 **rotations = MAlloc(length * sizeof(U8*));
    
    for (I64 i = 0; i < length; i++) {
        rotations[i] = MAlloc(length);
        for (I64 j = 0; j < length; j++) {
            rotations[i][j] = data[(i + j) % length];
        }
    }
    
    for (I64 i = 0; i < length - 1; i++) {
        for (I64 j = 0; j < length - 1 - i; j++) {
            I64 cmp = 0;
            for (I64 k = 0; k < length; k++) {
                if (rotations[j][k] != rotations[j + 1][k]) {
                    cmp = rotations[j][k] - rotations[j + 1][k];
                    break;
                }
            }
            if (cmp > 0) {
                U8 *temp = rotations[j];
                rotations[j] = rotations[j + 1];
                rotations[j + 1] = temp;
            }
        }
    }
    
    for (I64 i = 0; i < length; i++) {
        if (rotations[i][0] == data[0] && rotations[i][1] == data[1]) {
            *index = i;
            break;
        }
    }
    
    for (I64 i = 0; i < length; i++) {
        data[i] = rotations[i][length - 1];
    }
    
    for (I64 i = 0; i < length; i++) {
        Free(rotations[i]);
    }
    Free(rotations);
}

U0 MoveToFrontEncode(U8 *data, I64 length)
{
    U8 alphabet[256];
    for (I64 i = 0; i < 256; i++) {
        alphabet[i] = i;
    }
    
    for (I64 i = 0; i < length; i++) {
        U8 symbol = data[i];
        I64 index = 0;
        
        while (alphabet[index] != symbol) {
            index++;
        }
        
        data[i] = index;
        
        for (I64 j = index; j > 0; j--) {
            alphabet[j] = alphabet[j - 1];
        }
        alphabet[0] = symbol;
    }
}

U0 FreeCompression()
{
    if (compressed_data) {
        Free(compressed_data);
        compressed_data = NULL;
    }
    compressed_size = 0;
    compressed_capacity = 0;
} 